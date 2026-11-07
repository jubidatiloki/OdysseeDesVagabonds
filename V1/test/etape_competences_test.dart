import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/screens/creation/etape_competences.dart';

/// Répartition des points de compétence (30/10/2026) : points fixés en
/// haut, groupes d'aptitudes dans des cadres séparés.

List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

void main() {
  final humain = [
    for (final e in _json('races.json'))
      Race.depuisJson(e as Map<String, dynamic>),
  ].firstWhere((r) => r.id == 'humain');
  final guerrier = [
    for (final e in _json('classes.json'))
      Classe.depuisJson(e as Map<String, dynamic>),
  ].firstWhere((c) => c.id == 'guerrier');
  final catalogue = [
    for (final e in _json('aptitudes.json'))
      Aptitude.depuisJson(e as Map<String, dynamic>),
  ];

  testWidgets('points toujours visibles, groupes séparés avec compteur',
      (tester) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EtapeCompetences(
          race: humain,
          classe: guerrier,
          niveau: 1,
          rangsVoies: const {},
          aptitudes: const [AptitudeAcquise(id: 'pistage')],
          catalogueAptitudes: catalogue,
          intFinale: 10,
          onChange: (_) {},
          onAptitudes: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
    final haut = tester.getTopLeft(find.byKey(const Key('bandeau-points'))).dy;

    // Trois cadres : connaissances, aptitudes (savoir-faire), maîtrises.
    for (final f in FamilleAptitude.values) {
      final cadre = find.byKey(Key('famille-aptitudes-${f.name}'));
      await tester.scrollUntilVisible(
        cadre,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(cadre, findsOneWidget);
    }
    // Pistage (savoir-faire) acquis : compteur dans son cadre seulement.
    expect(
      find.descendant(
        of: find.byKey(const Key('famille-aptitudes-savoirFaire')),
        matching: find.text('1 acquise'),
      ),
      findsOneWidget,
    );
    expect(find.text('1 acquise'), findsOneWidget);

    // Après défilement, le bandeau des points n'a pas bougé.
    expect(find.byKey(const Key('points-competence')), findsOneWidget);
    expect(tester.getTopLeft(find.byKey(const Key('bandeau-points'))).dy, haut);
  });
}
