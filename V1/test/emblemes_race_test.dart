import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/theme.dart';
import 'package:odyssee_vagabonds/widgets/cadre_classe.dart';
import 'package:odyssee_vagabonds/widgets/emblemes_race.dart';

void main() {
  test('chaque race des données a son emblème', () {
    final ids = [
      for (final r
          in jsonDecode(File('assets/data/races.json').readAsStringSync())
              as List)
        (r as Map<String, dynamic>)['id'] as String,
    ];
    expect(ids.toSet(), kRacesAvecEmbleme);
  });

  test('fond du cercle : draconien selon l\'élément, neutre sans élément', () {
    final neutre = couleursFondRace('draconien').single;
    expect(couleursFondRace('draconien', element: 'feu').single, isNot(neutre));
    expect(couleursFondRace('draconien', element: 'glace').single,
        isNot(couleursFondRace('draconien', element: 'foudre').single));
    expect(couleursFondRace('demi-elfe'), hasLength(2));
    expect(couleursFondRace('inconnue'), isEmpty);
  });

  for (final sombre in [true, false]) {
    testWidgets(
        'avatars : emblème de race à la place de l\'initiale '
        '(${sombre ? 'sombre' : 'clair'})', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: themeOdv(sombre ? Brightness.dark : Brightness.light),
          home: Scaffold(
            body: Wrap(
              children: [
                for (final r in kRacesAvecEmbleme)
                  AvatarClasse(nom: 'Zoé', classeId: 'barde', raceId: r),
                const AvatarClasse(
                  nom: 'Kael',
                  classeId: 'magicien',
                  raceId: 'draconien',
                  element: 'feu',
                ),
                // Race inconnue : l'initiale reste
                const AvatarClasse(
                    nom: 'Bob', classeId: 'barde', raceId: 'inconnue'),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('embleme-race-nain')), findsOneWidget);
      expect(find.byKey(const Key('embleme-race-draconien')), findsNWidgets(2));
      expect(find.byType(EmblemeRace), findsNWidgets(9));
      expect(find.text('Z'), findsNothing);
      expect(find.text('B'), findsOneWidget);
    });
  }
}
