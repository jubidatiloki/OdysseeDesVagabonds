import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/effet.dart';
import 'package:odyssee_vagabonds/models/equipement.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';

String _libelle(Map<String, dynamic> j) => Effet.depuisJson(j).libelle;

void main() {
  testsDemiElfeHumaine();
  test('libellé lisible des effets', () {
    expect(
      _libelle(
          {'type': 'maitrise', 'categorie': 'langue', 'valeur': 'Elfique'}),
      'Langue : Elfique',
    );
    expect(
      _libelle({
        'type': 'bonus',
        'carac': 'SOC',
        'valeur': 2,
        'condition': 'pour servir d\'intermédiaire',
      }),
      '+2 SOC pour servir d\'intermédiaire',
    );
    // « categorie » accepté à la place de « carac », valeur en texte
    expect(
      _libelle({'type': 'bonus', 'categorie': 'SOC', 'valeur': '2'}),
      '+2 SOC',
    );
    expect(
      _libelle({
        'type': 'test',
        'categorie': 'MEN',
        'valeur': '5',
        'condition': 'intimidation',
      }),
      '+5 aux tests de MEN (intimidation)',
    );
    expect(
      _libelle({
        'type': 'renforcement',
        'nom': 'adaptabilité (niveau 2)',
        'typeCompetence': 'gratuit, 2×/jour',
        'effet': 'Relance un test raté.',
      }),
      'Améliore Adaptabilité (niveau 2) · gratuit, 2×/jour : Relance un test raté.',
    );
    expect(_libelle({'type': 'texte', 'texte': 'Libre'}), 'Libre');
  });

  test('races.json : effets détaillés lus', () {
    final races =
        (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
            .map((e) => Race.depuisJson(e as Map<String, dynamic>))
            .toList();
    final demiElfe = races.firstWhere((r) => r.id == 'demi-elfe');
    final humaine = demiElfe.origine('humaine')!;
    expect(humaine.passif!.effets, hasLength(3));
    expect(humaine.passif!.effets.first.libelle, 'Langue : Commun');
    final batard = demiElfe.voieRaciale!.competence(1)!;
    expect(batard.effet, 'Est habitué au rejet'); // « description » accepté
    expect(batard.effets, hasLength(2));
    expect(demiElfe.voieRaciale!.competence(5)!.effets, hasLength(2));
  });

  test('equipements.json : catégorie Consommables', () {
    final equipements =
        (jsonDecode(File('assets/data/equipements.json').readAsStringSync())
                as List)
            .map((e) => Equipement.depuisJson(e as Map<String, dynamic>))
            .toList();
    final potion = equipements.firstWhere((e) => e.id == 'potion-sante-1');
    expect(potion.categorie, CategorieEquipement.consommable);
    final epee = equipements.firstWhere((e) => e.id == 'epee-longue');
    expect(epee.categorie, CategorieEquipement.arme);
    expect(epee.etiquettes, ['CaC', 'Épée', 'une main', 'tranchante']);
    final baton = equipements.firstWhere((e) => e.id == 'baton');
    expect(baton.proprietes['Dégâts (une main)'], '1D6 phy');
    expect(baton.proprietes['Dégâts (deux mains)'], '1D8 phy');
  });

  test(
      'fiche : bonus de caractéristique appliqué, bonus de test listé, '
      'compétence améliorée', () {
    final races =
        (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
            .map((e) => Race.depuisJson(e as Map<String, dynamic>))
            .toList();
    final demiElfe = races.firstWhere((r) => r.id == 'demi-elfe');
    const classe = Classe(
      id: 'g',
      nom: 'Guerrier',
      modifDeVie: ModifDe.egal,
      modifDeMana: ModifDe.egal,
    );
    final p = Personnage(
      id: 'p',
      nom: 'Elrond',
      raceId: 'demi-elfe',
      classeId: 'g',
      origineId: 'humaine',
    );
    var f = FicheCalculee(personnage: p, race: demiElfe, classe: classe);
    // Niveau 1 : SOC 10 + 1 (origine humaine) ; « +2 SOC pour servir
    // d'intermédiaire » a une condition → bonus de test, pas de valeur.
    expect(f.carac(Carac.soc), 11);
    expect(f.bonusTests.map((s) => s.nom), contains('Bâtard'));
    expect(f.bonusTests.map((s) => s.nom), contains('Entre deux mondes'));

    // Niveau 9 : rang 5 « Le meilleur des deux mondes » → +2 SOC permanent
    p.niveau = 9;
    f = FicheCalculee(personnage: p, race: demiElfe, classe: classe);
    expect(f.bonusEffets(Carac.soc), 2);
    expect(f.carac(Carac.soc), 13);
    final adaptabilite = demiElfe.voieRaciale!.competence(4)!;
    expect(f.ameliorationDe(adaptabilite)?.nom, 'Le meilleur des deux mondes');
  });

  test('races.json : toutes les races se lisent au niveau 9 (rangs 1 à 5)', () {
    final races =
        (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
            .map((e) => Race.depuisJson(e as Map<String, dynamic>))
            .toList();
    const classe = Classe(
      id: 'g',
      nom: 'Guerrier',
      modifDeVie: ModifDe.egal,
      modifDeMana: ModifDe.egal,
    );
    FicheCalculee fiche(Race r) => FicheCalculee(
          personnage: Personnage(
            id: r.id,
            nom: r.nom,
            raceId: r.id,
            classeId: 'g',
            niveau: 9,
            origineId: r.aDesOrigines ? r.origines.first.id : null,
            optionPassifId:
                r.aUnChoixDePassif ? r.optionsPassif.first.id : null,
          ),
          race: r,
          classe: classe,
        );
    for (final r in races) {
      final f = fiche(r);
      // Aucun calcul ni libellé ne plante
      for (final c in Carac.values) {
        f.carac(c);
      }
      for (final s in f.effetsActifs) {
        expect(s.effet.libelle, isNotEmpty, reason: '${r.nom} · ${s.nom}');
      }
    }

    // Demi-orque : passif « gratuit, 1×/jour », amélioré par Chef de guerre
    // (renforcement aux effets imbriqués) ; +2 CON permanent.
    final orque = races.firstWhere((r) => r.id == 'demi-orque');
    final fo = fiche(orque);
    expect(orque.passif!.type, 'gratuit, 1×/jour');
    expect(fo.bonusEffets(Carac.con), 2);
    final chef = fo.ameliorationDeNom(orque.passif!.nom)!;
    expect(chef.nom, 'Chef de guerre');
    expect(chef.effet.libelle, contains('+5 aux tests de SOC'));

    // Haut-elfe : test sans caractéristique
    final hautElfe = races.firstWhere((r) => r.id == 'haut-elfe');
    expect(
      hautElfe.passif!.effets.map((e) => e.libelle),
      contains('+1 aux tests (se trouve en forêts ou chez les elfes)'),
    );
    // Vitalité elfique (rang 5) : +3 aux tests de CON
    expect(
      fiche(hautElfe).bonusTests.map((s) => s.effet.libelle),
      contains('+3 aux tests de CON'),
    );

    // Nain : « +2 RD phy » n'est pas un bonus de test
    final fn = fiche(races.firstWhere((r) => r.id == 'nain'));
    expect(
      fn.bonusTests.map((s) => s.effet.libelle).where((l) => l.contains('RD')),
      isEmpty,
    );
    expect(fn.bonusEffets(Carac.con), 2);
  });
}

void testsDemiElfeHumaine() {
  test('demi-elfe d\'origine humaine : +2 aux tests de SOC (situation)', () {
    final races = [
      for (final e in jsonDecode(
        File('assets/data/races.json').readAsStringSync(),
      ) as List)
        Race.depuisJson(e as Map<String, dynamic>),
    ];
    final e = races
        .firstWhere((r) => r.id == 'demi-elfe')
        .origine('humaine')!
        .passif!
        .effets
        .last;
    expect(e.typeNormalise, 'test');
    expect(e.carac, Carac.soc);
    expect(e.estBonusCarac, isFalse);
    expect(e.estBonusTest, isTrue);
    expect(e.libelle, contains('tests de SOC'));
  });
}
