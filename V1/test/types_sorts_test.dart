import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/type_sort.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/index_competences.dart';
import 'package:odyssee_vagabonds/screens/competences_glossaire_screen.dart';
import 'package:odyssee_vagabonds/widgets/libelles_sort.dart';

/// Types de sorts (tableau validé le 26/10/2026) : 8 types, 1 ou 2 par
/// sort, étiquettes et filtre du Glossaire.
List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

final _classes = [
  for (final e in _json('classes.json'))
    Classe.depuisJson(e as Map<String, dynamic>),
];
final _races = [
  for (final e in _json('races.json'))
    Race.depuisJson(e as Map<String, dynamic>),
];
final _rang0 = [
  for (final e in _json('sorts_rang0.json'))
    Aptitude.depuisJson(e as Map<String, dynamic>),
];

List<Competence> get _sorts => [
      for (final c in _classes)
        for (final v in c.voies)
          for (final k in v.competences)
            if (FicheCalculee.coutSort(k) != null) k,
      for (final a in _rang0) a.sort!,
      // Sorts des voies raciales (Cri sauvage, Visage impensable).
      for (final r in _races)
        for (final k in r.voieRaciale?.competences ?? const <Competence>[])
          if (FicheCalculee.coutSort(k) != null) k,
    ];

void main() {
  test('chaque sort a 1 ou 2 types', () {
    expect(_sorts, hasLength(99));
    for (final s in _sorts) {
      expect(s.typesSort.length, inInclusiveRange(1, 2), reason: s.nom);
    }
    Competence sort(String nom) => _sorts.firstWhere((s) => s.nom == nom);
    expect(
        sort('Brume').typesSort, [TypeSort.support, TypeSort.controlePhysique]);
    expect(
        sort('Charme mineur (niveau 1)').typesSort, [TypeSort.controleMental]);
    expect(sort('Lumière').typesSort, [TypeSort.utilitaire]);
    expect(sort('Cri sauvage').typesSort, [TypeSort.illusion]);
    expect(sort('Visage impensable').typesSort,
        [TypeSort.transformation, TypeSort.controleMental]);
    expect(sort('Plante carnivore').typesSort,
        [TypeSort.invocation, TypeSort.offensif]);
    // Les 8 types sont utilisés.
    expect({for (final s in _sorts) ...s.typesSort}, TypeSort.values.toSet());
    expect(TypeSort.depuisCode('Contrôle mental'), TypeSort.controleMental);
  });

  testWidgets('étiquettes des types avant le mana', (tester) async {
    final brume = _sorts.firstWhere((s) => s.nom == 'Brume');
    await tester
        .pumpWidget(MaterialApp(home: Scaffold(body: LibellesSort(brume))));
    expect(find.byKey(const Key('type-sort-support')), findsOneWidget);
    expect(
        find.byKey(const Key('type-sort-controle-physique')), findsOneWidget);
    expect(find.text('Contrôle physique'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('type-sort-support'))).dx,
      lessThan(tester.getTopLeft(find.byIcon(Icons.water_drop)).dx),
    );
  });

  test('Glossaire : types de sort cumulés avec les catégories', () {
    final ref = Referentiel(
      races: _races,
      classes: _classes,
      aptitudes: Referentiel.enregistrerSortsRang0(_rang0),
    );
    final index = IndexCompetences.construire(ref);
    final offensifs =
        IndexCompetences.filtrer(index, typesSort: {TypeSort.offensif});
    expect(offensifs, isNotEmpty);
    expect(
        offensifs
            .every((e) => e.competence.typesSort.contains(TypeSort.offensif)),
        isTrue);
    final deux = IndexCompetences.filtrer(index,
        typesSort: {TypeSort.offensif, TypeSort.controlePhysique});
    expect(deux.map((e) => e.competence.nom), contains('Éclat de givre'));
    expect(deux.map((e) => e.competence.nom), isNot(contains('Étincelle')));
    // Sorts mineurs + Contrôle mental.
    final mineurs = IndexCompetences.filtrer(index,
        categories: {CategorieCompetence.sortMineur},
        typesSort: {TypeSort.controleMental});
    expect(mineurs.map((e) => e.competence.nom).toSet(),
        {'Charme fugace', 'Regard troublant'});
    // Recherche par type.
    expect(
      IndexCompetences.filtrer(index, recherche: 'invocation')
          .map((e) => e.competence.nom),
      contains('Diablotin'),
    );
  });

  testWidgets('Glossaire : pastilles de type de sort', (tester) async {
    tester.view.physicalSize = const Size(1400, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ref = Referentiel(
      races: _races,
      classes: _classes,
      aptitudes: Referentiel.enregistrerSortsRang0(_rang0),
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CompetencesGlossaireScreen(referentiel: ref)),
    ));
    await tester.pumpAndSettle();
    for (final t in TypeSort.values) {
      expect(find.byKey(Key('filtre-type-sort-${t.code}')), findsOneWidget);
    }
    await tester.tap(find.byKey(const Key('filtre-type-sort-invocation')));
    await tester.pumpAndSettle();
    final compte =
        tester.widget<Text>(find.byKey(const Key('compte-competences'))).data!;
    expect(compte, startsWith('15 compétences'));
    await tester.tap(find.byKey(const Key('effacer-filtres')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilterChip>(
              find.byKey(const Key('filtre-type-sort-invocation')))
          .selected,
      isFalse,
    );
  });
}
