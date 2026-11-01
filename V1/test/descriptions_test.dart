import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/screens/classes_screen.dart';

/// Descriptions d'ambiance des classes et origine du pouvoir des lanceurs
/// de sorts (26/10/2026).
final _classes =
    (jsonDecode(File('assets/data/classes.json').readAsStringSync()) as List)
        .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
        .toList();

final _races =
    (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
        .map((e) => Race.depuisJson(e as Map<String, dynamic>))
        .toList();

void main() {
  test('races : une description chacune (validées le 26/10/2026)', () {
    expect(_races, hasLength(8));
    for (final r in _races) {
      expect(r.description.length, greaterThan(100), reason: r.id);
    }
    String desc(String id) => _races.firstWhere((r) => r.id == id).description;
    expect(desc('nain'), startsWith('Petit, têtu et barbu'));
    expect(desc('nain'), isNot(contains('paix')));
    expect(desc('haut-elfe'), isNot(contains('impensable')));
    expect(desc('draconien'), contains('esclaves'));
    expect(desc('draconien'), contains('libérer de leur joug'));
  });

  test('une description par classe, sans notes ni citations', () {
    expect(_classes, hasLength(12));
    for (final c in _classes) {
      expect(c.description.length, greaterThan(100), reason: c.id);
      expect(c.description, isNot(contains('Origine')), reason: c.id);
      expect(c.description, isNot(contains('Citation')), reason: c.id);
      expect(c.description, isNot(contains('voir les règles')), reason: c.id);
      expect(c.description, isNot(contains('(voir')), reason: c.id);
    }
  });

  test('origine du pouvoir : seulement les 6 lanceurs de sorts', () {
    final origines = {
      for (final c in _classes)
        if (c.originePouvoir.isNotEmpty) c.id: c.originePouvoir,
    };
    expect(origines, {
      'barde': 'Origine du pouvoir : appât du gain / spectacles ou assistant '
          'd\'un mage.',
      'druide': 'Origine du pouvoir : proximité avec la nature.',
      'magicien': 'Origine du pouvoir : connaissance et apprentissage.',
      'necromancien': 'Origine du pouvoir : connaissance et expérience.',
      'pretre': 'Origine du pouvoir : proximité avec sa divinité et la force '
          'de sa croyance.',
      'voleur': 'Origine du pouvoir : appât du gain / spectacles ou assistant '
          'd\'un mage.',
    });
  });

  testWidgets('fiche de la classe : description puis origine du pouvoir',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Future<void> afficher(String id) => tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: ClasseDetail(
              classe: _classes.firstWhere((c) => c.id == id),
            ),
          ),
        ));
    await afficher('druide');
    expect(find.textContaining('Gardien des forêts'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('origine-pouvoir'))).data,
      'Origine du pouvoir : proximité avec la nature.',
    );
    await afficher('guerrier');
    expect(find.byKey(const Key('origine-pouvoir')), findsNothing);
  });
}
