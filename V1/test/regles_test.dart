import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';

const draconien = Race(
  id: 'draconien',
  nom: 'Draconien',
  deVie: 8,
  deMana: 4,
  modificateurs: {Carac.con: 2, Carac.dex: -2, Carac.chan: -2},
  optionsPassif: [
    OptionPassif(id: 'souffle', nom: 'Souffle élémentaire', description: ''),
    OptionPassif(id: 'ailes', nom: 'Ailes vestigiales', description: ''),
  ],
);

const magicien = Classe(
  id: 'magicien',
  nom: 'Magicien',
  modifDeVie: ModifDe.moins,
  modifDeMana: ModifDe.plus,
);

void main() {
  group('ajusterDe', () {
    test('monte, descend ou garde le dé', () {
      expect(ajusterDe(6, ModifDe.plus), 8);
      expect(ajusterDe(6, ModifDe.moins), 4);
      expect(ajusterDe(6, ModifDe.egal), 6);
    });

    test('ne descend jamais sous le d4', () {
      expect(ajusterDe(4, ModifDe.moins), 4);
    });
  });

  test('modificateur : 2 points = 1, arrondi à l\'inférieur', () {
    expect(modificateur(7), -2);
    expect(modificateur(8), -1);
    expect(modificateur(9), -1);
    expect(modificateur(10), 0);
    expect(modificateur(11), 0);
    expect(modificateur(12), 1);
    expect(modificateur(13), 1);
    expect(modificateur(16), 3);
    expect(modificateur(18), 4);
  });

  test('formaterModificateur', () {
    expect(formaterModificateur(2), '+2');
    expect(formaterModificateur(0), '+0');
    expect(formaterModificateur(-1), '−1');
  });

  group('RepartitionCreation', () {
    test('départ : tout à 10, 12 points restants, incomplet', () {
      final base = RepartitionCreation.valeursDepart();
      expect(RepartitionCreation.pointsRestants(base), 12);
      expect(RepartitionCreation.estComplete(base), isFalse);
    });

    test('max 16, pas sous 10, CHAN bloquée', () {
      final base = RepartitionCreation.valeursDepart();
      base[Carac.force] = 16;
      expect(RepartitionCreation.peutAugmenter(base, Carac.force), isFalse);
      expect(RepartitionCreation.peutDiminuer(base, Carac.dex), isFalse);
      expect(RepartitionCreation.peutAugmenter(base, Carac.chan), isFalse);
      expect(RepartitionCreation.peutAugmenter(base, Carac.dex), isTrue);
    });

    test('complète quand les 12 points sont dépensés', () {
      final base = RepartitionCreation.valeursDepart();
      base[Carac.force] = 16; // 6
      base[Carac.con] = 14; // 4
      base[Carac.adc] = 12; // 2
      expect(RepartitionCreation.pointsRestants(base), 0);
      expect(RepartitionCreation.estComplete(base), isTrue);
      expect(RepartitionCreation.peutAugmenter(base, Carac.dex), isFalse);
    });

    test('une CHAN modifiée rend la répartition invalide', () {
      final base = RepartitionCreation.valeursDepart();
      base[Carac.force] = 16;
      base[Carac.con] = 16;
      base[Carac.chan] = 12;
      expect(RepartitionCreation.estComplete(base), isFalse);
    });
  });

  group('FicheCalculee : draconien magicien', () {
    final base = RepartitionCreation.valeursDepart()
      ..[Carac.adm] = 16
      ..[Carac.intel] = 16;
    Personnage perso() => Personnage(
          id: 'test',
          nom: 'Ignis',
          raceId: 'draconien',
          optionPassifId: 'souffle',
          classeId: 'magicien',
          caracBase: Map.of(base),
        );

    test('dés : exemple des règles → DV 6 / DM 6', () {
      final f =
          FicheCalculee(personnage: perso(), race: draconien, classe: magicien);
      expect(f.deVie, 6);
      expect(f.deMana, 6);
      expect(f.optionPassif?.nom, 'Souffle élémentaire');
    });

    test('la race s\'applique après la répartition', () {
      final f =
          FicheCalculee(personnage: perso(), race: draconien, classe: magicien);
      expect(f.carac(Carac.con), 12); // 10 + 2
      expect(f.mod(Carac.con), 1);
      expect(f.carac(Carac.dex), 8); // 10 − 2
      expect(f.mod(Carac.dex), -1);
    });

    test('PV max niveau 1 = DV max + mod CON, puis + jets de DV', () {
      final p = perso();
      final f = FicheCalculee(personnage: p, race: draconien, classe: magicien);
      expect(f.pvMax, 7); // 6 + 1
      p.jetsDeVie = [4, 3];
      expect(f.pvMax, 14);
      expect(f.pmMax, 6);
    });

    test('défense et attaque utilisent les modificateurs', () {
      final f =
          FicheCalculee(personnage: perso(), race: draconien, classe: magicien);
      // DEX 8 → −1 ; AdC, AdT 10 → +0 ; AdM 16 → +3 ; INT 16 → +3
      // Refonte du 29/10/2026 : CA = 10 + armure + DEX (limitée), jet
      // d'esquive = 1d20 + DEX (limitée) ; AdC / AdT / AdM ne défendent plus.
      expect(f.classeArmure, 9); // 10 − 1
      expect(f.bonusJetEsquive, -1); // jet d'esquive : 1d20 − 1
      // Initiative = valeur de DEX + bonus (31/10/2026) : 8, sans jet.
      expect(f.initiative, 8);
      expect(f.caCac, 9);
      expect(f.caDistance, 9);
      expect(f.caMagie, 9);
      expect(f.toucherCac, 0); // 1d20 + 0
      expect(f.toucherMagie, 3); // 1d20 + 3
      expect(f.degatsCac, 0);
      expect(f.degatsDistance, -1); // mod DEX
      expect(f.degatsMagie, 3); // mod INT
      expect(formaterJet('1d20', f.toucherMagie), '1d20 +3');
      expect(formaterJet('1d20', 0), '1d20');
    });

    test('nuit de repos', () {
      final f =
          FicheCalculee(personnage: perso(), race: draconien, classe: magicien);
      expect(f.pvRecuperesNuit(5), 6); // jet 5 + mod CON 1
      expect(f.pvRecuperesDemiNuit(5), 5); // demi-nuit : 1 DV, sans CON
      expect(f.pmRecuperesNuit(), 6);
      expect(f.pmRecuperesNuit(demiNuit: true), 3);
    });
  });

  test('les modificateurs d\'origine s\'ajoutent à ceux de la race', () {
    const humain = Race(
      id: 'humain',
      nom: 'Humain',
      deVie: 6,
      deMana: 6,
      origines: [
        OrigineRace(
          id: 'erudit',
          nom: 'Érudit',
          modificateurs: {Carac.intel: 2, Carac.force: -1, Carac.soc: -1},
        ),
      ],
    );
    const voleur = Classe(
      id: 'voleur',
      nom: 'Voleur',
      modifDeVie: ModifDe.egal,
      modifDeMana: ModifDe.egal,
    );
    final perso = Personnage(
      id: 't',
      nom: 'Lia',
      raceId: 'humain',
      origineId: 'erudit',
      classeId: 'voleur',
    );
    final f = FicheCalculee(personnage: perso, race: humain, classe: voleur);
    expect(f.carac(Carac.intel), 12);
    expect(f.mod(Carac.intel), 1);
    expect(f.carac(Carac.force), 9);
    expect(f.mod(Carac.force), -1);
  });

  test('un personnage survit à un aller-retour JSON', () {
    final p = Personnage(
      id: 'abc',
      nom: 'Brom',
      raceId: 'draconien',
      optionPassifId: 'ailes',
      classeId: 'guerrier',
      caracBase: {for (final c in Carac.values) c: 11},
      jetsDeVie: [5, 2],
      pvActuels: 7,
    );
    final copie = Personnage.depuisJson(p.versJson());
    expect(copie.nom, 'Brom');
    expect(copie.optionPassifId, 'ailes');
    expect(copie.caracBase[Carac.per], 11);
    expect(copie.jetsDeVie, [5, 2]);
    expect(copie.pvActuels, 7);
    expect(copie.pmActuels, isNull);
  });
}
