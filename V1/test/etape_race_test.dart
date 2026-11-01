import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/screens/creation/etape_race.dart';
import 'package:odyssee_vagabonds/theme.dart';
import 'package:odyssee_vagabonds/widgets/profil_classe.dart';

void main() {
  testWidgets(
      'création, race : modificateurs en couleur sur la ligne '
      '« Caractéristiques », origine dans le même style', (tester) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final races =
        (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
            .map((e) => Race.depuisJson(e as Map<String, dynamic>))
            .where((r) => r.id == 'demi-elfe' || r.id == 'demi-orque')
            .toList();
    final demiElfe = races.firstWhere((r) => r.id == 'demi-elfe');
    await tester.pumpWidget(
      MaterialApp(
        theme: themeOdv(Brightness.dark),
        home: Scaffold(
          body: EtapeRace(
            races: races,
            race: demiElfe,
            origineId: 'humaine',
            optionPassifId: null,
            onRace: (_) {},
            onOrigine: (_) {},
            onOptionPassif: (_) {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    // Demi-orque : « +3 FOR » une seule fois (plus à côté du dé de mana),
    // en vert.
    final force = find.text('+3 FOR');
    expect(force, findsOneWidget);
    expect(
      tester.widget<Text>(force).style?.color,
      couleurModificateur(3, Brightness.dark),
    );
    expect(find.byType(LigneModificateurs), findsNWidgets(2));
    // Origine humaine : modificateurs en couleur, passif en ligne libellée
    expect(
      tester.widget<Text>(find.text('−1 FOR')).style?.color,
      couleurModificateur(-1, Brightness.dark),
    );
    expect(
      find.textContaining('Entre deux mondes : ', findRichText: true),
      findsOneWidget,
    );
  });
}
