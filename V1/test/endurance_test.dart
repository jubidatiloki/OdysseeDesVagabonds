import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/montee_niveau.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';
import 'package:odyssee_vagabonds/widgets/libelles_sort.dart';
import 'package:odyssee_vagabonds/widgets/profil_classe.dart';

/// Endurance (03/11/2026) : les classes physiques n'ont plus de mana mais des
/// points d'endurance (PE, dé d'endurance DE) dépensés par leurs
/// compétences ; les lanceurs de sorts n'ont pas d'endurance ; les hybrides
/// ont les deux.
void main() {
  testsSortsEnEndurance();
  List<Map<String, dynamic>> lire(String fichier) => [
        for (final e
            in jsonDecode(File('assets/data/$fichier').readAsStringSync())
                as List)
          e as Map<String, dynamic>,
      ];
  final races = {
    for (final r in lire('races.json').map(Race.depuisJson)) r.id: r,
  };
  final classes = {
    for (final c in lire('classes.json').map(Classe.depuisJson)) c.id: c,
  };
  Competence comp(String classe, String nom) => classes[classe]!
      .voies
      .expand((v) => v.competences)
      .firstWhere((c) => c.nom == nom);

  test('races : DE 4 (gnome), 6 pour les autres', () {
    expect({
      for (final r in races.values) r.id: r.deEndurance
    }, {
      'demi-elfe': 6,
      'demi-orque': 6,
      'draconien': 6,
      'elfe-sylvain': 6,
      'haut-elfe': 6,
      'gnome': 4,
      'humain': 6,
      'nain': 6,
    });
  });

  test('classes : physiques PE seuls, lanceurs PM seuls, hybrides les deux',
      () {
    for (final c in classes.values) {
      switch (c.profil) {
        case ProfilClasse.physique:
          expect((c.aDuMana, c.aDeLEndurance), (false, true), reason: c.id);
        case ProfilClasse.lanceur:
          expect((c.aDuMana, c.aDeLEndurance), (true, false), reason: c.id);
        case ProfilClasse.hybride:
          expect((c.aDuMana, c.aDeLEndurance), (true, true), reason: c.id);
      }
      // DE inchangé (celui de la race) pour toutes les classes.
      expect(c.modifDeEndurance, ModifDe.egal, reason: c.id);
    }
    expect(
      [
        for (final c in classes.values)
          if (c.profil == ProfilClasse.physique) c.id,
      ],
      ['barbare', 'chevalier', 'guerrier', 'ingenieur', 'rodeur'],
    );
  });

  test('coûts en endurance des compétences', () {
    int cout(String classe, String nom) =>
        comp(classe, nom).endurance.single.cout;
    expect(cout('barbare', 'Moulinet (niveau 1)'), 2);
    expect(cout('barbare', 'Rage berzerker (niveau 1)'), 1);
    expect(cout('barde', 'Musique vivifiante'), 2);
    expect(cout('chevalier', 'Charge'), 2);
    expect(cout('guerrier', 'À couvert'), 1);
    expect(cout('moine', 'Kenn-do-ha'), 2);
    expect(cout('rodeur', 'Flèches multiples'), 2);
    expect(cout('voleur', 'Botte secrète'), 3);
    expect(cout('voleur', 'Riposte'), 1);
    // Actions nommées (ingénieur, moine, rôdeur).
    final potion = comp('ingenieur', 'Chimiste en herbe').endurance.single;
    expect((potion.libelle, potion.cout), ('Fabriquer une potion', 1));
    expect(comp('ingenieur', 'Golem').endurance.single.cout, 3);
    expect(comp('rodeur', 'Piège').endurance.single.libelle,
        'Poser un piège en combat');
    expect(comp('rodeur', 'Piège').effet, contains('0 PE hors combat'));
    // 38 compétences ont un coût, aucune chez les lanceurs de sorts.
    final avecCout = [
      for (final c in classes.values)
        for (final v in c.voies)
          for (final k in v.competences)
            if (k.endurance.isNotEmpty) (c, k),
    ];
    expect(avecCout, hasLength(38));
    expect(avecCout.where((e) => e.$1.profil == ProfilClasse.lanceur), isEmpty);
    // `"endurance": 2` ou liste d'actions.
    expect(CoutEndurance.listeDepuisJson(2).single.cout, 2);
    expect(
      CoutEndurance.listeDepuisJson([
        {'libelle': 'A', 'cout': 1},
        {'libelle': 'B', 'cout': 3},
      ]).map((e) => (e.libelle, e.cout)),
      [('A', 1), ('B', 3)],
    );
  });

  FicheCalculee fiche(String race, String classe, {int niveau = 1}) =>
      FicheCalculee(
        personnage: Personnage(
          id: 'p',
          nom: 'Test',
          raceId: race,
          classeId: classe,
          niveau: niveau,
        ),
        race: races[race]!,
        classe: classes[classe]!,
      );

  test('fiche : PE comme le mana (DE max au niveau 1, repos)', () {
    final g = fiche('nain', 'guerrier');
    expect((g.deEndurance, g.peMax, g.peActuels), (6, 6, 6));
    expect((g.pmMax, g.pmActuels), (0, 0));
    expect(g.peRecuperesNuit(), 6);
    expect(g.peRecuperesNuit(demiNuit: true), 3);
    expect(g.pmRecuperesNuit(), 0);
    // Jets de DE des montées de niveau ajoutés au maximum.
    g.personnage
      ..niveau = 3
      ..jetsDEndurance = [3, 7];
    expect(g.peMax, 16);
    // Ancien personnage sans jets de DE : moyenne du dé, arrondie au-dessus.
    g.personnage.jetsDEndurance = [];
    expect(g.peMax, 6 + 2 * 4);

    final m = fiche('haut-elfe', 'magicien');
    expect((m.deEndurance, m.peMax), (0, 0));
    expect(m.pmMax, greaterThan(0));

    final v = fiche('gnome', 'voleur');
    expect((v.deEndurance, v.peMax), (4, 4));
    expect(v.pmMax, greaterThan(0));
  });

  test('fiche : actions payées en endurance des compétences acquises', () {
    final g = fiche('humain', 'guerrier', niveau: 3);
    g.personnage.rangsVoies = {'guerrier-bouclier': 2};
    expect(
      g.actionsEndurance.map((a) => (a.libelle, a.cout)),
      [('À couvert', 1)],
    );
    // Lanceur de sorts : aucune action payée en endurance.
    expect(fiche('humain', 'magicien').actionsEndurance, isEmpty);
  });

  test('montée de niveau : jet de DE (physique), DM et DE (hybride)', () {
    for (final (classe, mana, endurance) in [
      ('guerrier', <int>[], [4]),
      ('voleur', [3], [4]),
      ('magicien', [3], <int>[]),
    ]) {
      final f = fiche('humain', classe);
      MonteeNiveau.appliquer(
        personnage: f.personnage,
        race: f.race,
        classe: f.classe,
        jetDeVie: 2,
        jetDeMana: 3,
        jetDEndurance: 4,
        rangsVoies: const {},
        aptitudes: const [],
      );
      expect(f.personnage.jetsDeMana, mana, reason: classe);
      expect(f.personnage.jetsDEndurance, endurance, reason: classe);
      final message = f.personnage.historique.first.message;
      expect(message.contains('PM max'), mana.isNotEmpty, reason: classe);
      expect(message.contains('PE max'), endurance.isNotEmpty, reason: classe);
    }
  });

  test('sauvegarde : PE actuels et jets de DE', () {
    final p = Personnage(
      id: 'p',
      nom: 'Brom',
      raceId: 'nain',
      classeId: 'guerrier',
      niveau: 2,
      peActuels: 3,
      jetsDEndurance: [5],
    );
    final copie = Personnage.depuisJson(p.versJson());
    expect(copie.peActuels, 3);
    expect(copie.jetsDEndurance, [5]);
    final json = p.versJson()
      ..remove('peActuels')
      ..remove('jetsDEndurance');
    final ancienne = Personnage.depuisJson(json);
    expect(ancienne.peActuels, isNull);
    expect(ancienne.jetsDEndurance, isEmpty);
  });

  testWidgets('infos de classe : croix sur le dé absent, libellé PE',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              InfosClasse(classes['guerrier']!),
              InfosClasse(classes['magicien']!),
              InfosClasse(classes['barde']!),
              LibellesSort(comp('voleur', 'Botte secrète')),
            ],
          ),
        ),
      ),
    );
    // Guerrier : pas de mana ; magicien : pas d'endurance ; barde : les deux.
    expect(find.byKey(const Key('curseur-mana-absent')), findsOneWidget);
    expect(find.byKey(const Key('curseur-endurance-absent')), findsOneWidget);
    expect(find.byKey(const Key('curseur-endurance-egal')), findsNWidgets(2));
    expect(find.byKey(const Key('curseur-mana-egal')), findsOneWidget);
    expect(find.byTooltip('Dé de mana : aucun (pas de PM)'), findsOneWidget);
    expect(find.text('3 PE'), findsOneWidget);
  });

  testWidgets('page dé : PE affichés, action payée en endurance',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = Personnage(
      id: 'g',
      nom: 'Brom',
      raceId: 'humain',
      classeId: 'guerrier',
      niveau: 3,
      rangsVoies: {'guerrier-bouclier': 2},
      peActuels: 1,
    );
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      MaterialApp(
        home: DeScreen(
          referentiel: Referentiel(
            races: [races['humain']!],
            classes: [classes['guerrier']!],
          ),
          personnages: controller,
          preferences: PreferencesController(personnageActifId: 'g'),
          aleatoire: Random(1),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Humain : DE d6 ; niveau 3 sans jets de DE : 6 + 2 × 4.
    expect(find.text('PE 1/14'), findsOneWidget);
    expect(find.textContaining('PM '), findsNothing);
    final bouton = find.byKey(const Key('endurance-0'));
    await tester.ensureVisible(bouton);
    await tester.pumpAndSettle();
    await tester.tap(bouton);
    await tester.pumpAndSettle();
    expect(p.peActuels, 0);
    expect(p.historique.last.message, 'À couvert (−1 PE) · PE : 1 → 0');
    // Plus assez de PE : bouton désactivé.
    expect(find.text('PE insuffisants'), findsOneWidget);
    await tester.tap(bouton);
    await tester.pumpAndSettle();
    expect(p.peActuels, 0);
  });
}

/// Sorts raciaux d'une classe sans mana : payés en PE (03/11/2026).
void testsSortsEnEndurance() {
  final races = {
    for (final e
        in jsonDecode(File('assets/data/races.json').readAsStringSync())
            as List)
      if (Race.depuisJson(e as Map<String, dynamic>) case final r) r.id: r,
  };
  final classes = {
    for (final e
        in jsonDecode(File('assets/data/classes.json').readAsStringSync())
            as List)
      if (Classe.depuisJson(e as Map<String, dynamic>) case final c) c.id: c,
  };

  testWidgets('page dé : Cri sauvage d\'un elfe guerrier payé en PE',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = Personnage(
      id: 'e',
      nom: 'Lyra',
      raceId: 'elfe-sylvain',
      classeId: 'guerrier',
      niveau: 3,
      jetsDEndurance: [4, 4],
    );
    final f = FicheCalculee(
      personnage: p,
      race: races['elfe-sylvain']!,
      classe: classes['guerrier']!,
    );
    expect((f.sortsEnEndurance, f.uniteSorts, f.pointsPourSorts),
        (true, 'PE', 14));
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      MaterialApp(
        home: DeScreen(
          referentiel: Referentiel(
            races: [races['elfe-sylvain']!],
            classes: [classes['guerrier']!],
          ),
          personnages: controller,
          preferences: PreferencesController(
            personnageActifId: 'e',
            affichages: {
              for (final g in GroupeJets.values) g: AffichageGroupe.visible,
            },
          ),
          aleatoire: Random(2),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Sort de rang 2 : 3 PE (pastille or), pas de PM.
    expect(find.text('3 PE'), findsOneWidget);
    expect(find.text('3 PM'), findsNothing);
    final sort = find.text('Cri sauvage');
    await tester.ensureVisible(sort);
    await tester.pumpAndSettle();
    await tester.tap(sort);
    await tester.pumpAndSettle();
    expect(p.peActuels, 11);
    expect(
      p.historique.map((e) => e.message),
      contains('Sort lancé : Cri sauvage (−3 PE) · PE : 14 → 11'),
    );
  });

  test('hybride et lanceur : sorts toujours payés en PM', () {
    for (final c in ['barde', 'druide']) {
      final f = FicheCalculee(
        personnage:
            Personnage(id: 'p', nom: 'T', raceId: 'humain', classeId: c),
        race: races['humain']!,
        classe: classes[c]!,
      );
      expect(f.uniteSorts, 'PM', reason: c);
    }
  });
}
