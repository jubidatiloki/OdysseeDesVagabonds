import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/montee_niveau.dart';

const _humain = Race(id: 'humain', nom: 'Humain', deVie: 6, deMana: 6);
const _hautElfe = Race(id: 'haut-elfe', nom: 'Haut-elfe', deVie: 4, deMana: 8);
const _barbare = Classe(
  id: 'barbare',
  nom: 'Barbare',
  modifDeVie: ModifDe.plus,
  modifDeMana: ModifDe.moins,
);
const _guerrier = Classe(
  id: 'guerrier',
  nom: 'Guerrier',
  modifDeVie: ModifDe.plus,
  modifDeMana: ModifDe.moins,
);
const _moine = Classe(
  id: 'moine',
  nom: 'Moine',
  modifDeVie: ModifDe.plus,
  modifDeMana: ModifDe.egal,
);

/// Barbare humain, FOR 16 (+3), CON 12 (+1).
Personnage _barbareHumain({Map<String, int>? rangs}) => Personnage(
      id: 'b',
      nom: 'Grok',
      raceId: 'humain',
      classeId: 'barbare',
      caracBase: {for (final c in Carac.values) c: 10}
        ..[Carac.force] = 16
        ..[Carac.con] = 12,
      rangsVoies: rangs ?? {},
    );

FicheCalculee _fiche(Personnage p, Race r, Classe c) =>
    FicheCalculee(personnage: p, race: r, classe: c);

void main() {
  group('Force de la nature (barbare, brute rang 1)', () {
    test('à la prise : + mod FOR aux PV max, avec son origine', () {
      final sans = _fiche(_barbareHumain(), _humain, _barbare);
      final avec = _fiche(
        _barbareHumain(rangs: {'barbare-brute': 1}),
        _humain,
        _barbare,
      );
      // d8 (humain d6 +1 cran) + CON +1 = 9 ; + FOR +3 = 12
      expect(sans.pvMax, 9);
      expect(avec.pvMax, 12);
      expect(avec.bonusPvCompetences, 3);
      final regle = avec.reglesParticulieres.single;
      expect(regle.nom, 'Force de la nature');
      expect(regle.origine, 'Barbare · Voie de la brute, rang 1');
    });

    test('montée de niveau : + la meilleure de CON / FOR aux PV gagnés', () {
      final p = _barbareHumain(rangs: {'barbare-brute': 1});
      final r = MonteeNiveau.appliquer(
        personnage: p,
        race: _humain,
        classe: _barbare,
        jetDeVie: 5,
        jetDeMana: 1,
        rangsVoies: p.rangsVoies,
        aptitudes: p.aptitudes,
      );
      expect(r.bonusRegle, 3); // FOR +3 > CON +1
      expect(r.pvMaxApres - r.pvMaxAvant, 8); // 5 + 3
      expect(p.bonusDeVie, [3]);
      expect(
        p.historique.first.message,
        contains('+3 Force de la nature (Barbare · Voie de la brute, rang 1)'),
      );
    });

    test('jamais de malus si FOR et CON sont négatives', () {
      final p = Personnage(
        id: 'x',
        nom: 'Chétif',
        raceId: 'humain',
        classeId: 'barbare',
        caracBase: {for (final c in Carac.values) c: 10}
          ..[Carac.force] = 8
          ..[Carac.con] = 8,
        rangsVoies: {'barbare-brute': 1},
      );
      final b = MonteeNiveau.bonusPvMonteeNiveau(_fiche(p, _humain, _barbare));
      expect(b.bonus, 0);
    });
  });

  test('Style barbaresque (brute rang 3) : + FOR + CON par niveau', () {
    final p = _barbareHumain(rangs: {'barbare-brute': 3})..niveau = 3;
    final b = MonteeNiveau.bonusPvMonteeNiveau(_fiche(p, _humain, _barbare));
    expect(b.bonus, 4); // +3 FOR, +1 CON
    expect(b.regle!.nom, 'Style barbaresque');
    expect(b.regle!.origine, 'Barbare · Voie de la brute, rang 3');
    // Affichage : seul le niveau le plus élevé (Force de la nature repris
    // dans la description de Style barbaresque).
    final regles = _fiche(p, _humain, _barbare).reglesParticulieres;
    expect(regles.map((r) => r.nom), ['Style barbaresque']);
    expect(regles.single.description, contains('Force de la nature'));
    expect(regles.single.description, contains('PV max à la prise'));
  });

  test('prendre Force de la nature pendant la montée : bonus à la prise', () {
    final p = _barbareHumain();
    final r = MonteeNiveau.appliquer(
      personnage: p,
      race: _humain,
      classe: _barbare,
      jetDeVie: 4,
      jetDeMana: 1,
      rangsVoies: {'barbare-brute': 1},
      aptitudes: const [],
    );
    // jet 4 + FOR +3 à la prise (pas de bonus par niveau ce niveau-ci)
    expect(r.bonusRegle, 0);
    expect(r.pvMaxApres - r.pvMaxAvant, 7);
    expect(r.nouvellesRegles.single.nom, 'Force de la nature');
    expect(
      p.historique.map((e) => e.message),
      contains(startsWith('Règle particulière active : Force de la nature')),
    );
  });

  test('Vitalité elfique (haut-elfe, rang racial 5) : d6, +10 PV max', () {
    // Haut-elfe guerrier : d4 → +1 cran = d6 ; avec Vitalité : d6 → d8
    final p = Personnage(
      id: 'h',
      nom: 'Elandril',
      raceId: 'haut-elfe',
      classeId: 'guerrier',
      niveau: 8,
      jetsDeVie: [3, 3, 3, 3, 3, 3, 3], // niveaux 2 à 8
      jetsDeMana: [1, 1, 1, 1, 1, 1, 1],
    );
    final avant = _fiche(p, _hautElfe, _guerrier);
    expect(avant.deVie, 6);
    expect(MonteeNiveau.desDuNiveauSuivant(avant).deVie, 8);
    final pvAvant = avant.pvMax; // 6 + 0 + 21 = 27

    final r = MonteeNiveau.appliquer(
      personnage: p,
      race: _hautElfe,
      classe: _guerrier,
      jetDeVie: 5,
      jetDeMana: 1,
      rangsVoies: p.rangsVoies,
      aptitudes: p.aptitudes,
      facesDeVie: 8,
    );
    final apres = _fiche(p, _hautElfe, _guerrier);
    expect(p.niveau, 9);
    expect(apres.deVie, 8);
    // +10 (à la prise) + 5 (jet au d8) ; le DV max du niveau 1 (d6) n'est
    // pas recalculé, les niveaux précédents non plus
    expect(apres.pvMax - pvAvant, 15);
    expect(apres.bonusPvCompetences, 10);
    expect(r.nouvellesRegles.single.nom, 'Vitalité elfique');
    expect(
        r.nouvellesRegles.single.origine, 'Haut-elfe · Voie raciale, rang 5');
  });

  test('Mental d\'acier (moine, ki rang 5) : dé de mana +1 cran', () {
    final p = Personnage(
      id: 'm',
      nom: 'Shen',
      raceId: 'humain',
      classeId: 'moine',
      niveau: 5,
      rangsVoies: {'moine-ki': 4},
    );
    expect(_fiche(p, _humain, _moine).deMana, 6);
    p.rangsVoies['moine-ki'] = 5;
    final f = _fiche(p, _humain, _moine);
    expect(f.deMana, 8);
    expect(f.reglesParticulieres.single.nom, 'Mental d\'acier');
    expect(f.reglesParticulieres.single.description, contains('d6 → d8'));
  });
}
