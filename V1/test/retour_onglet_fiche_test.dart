import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/screens/fiche/vues_fiche.dart';

/// Rectangle gris de la fiche (03/11/2026) : la position de défilement de
/// l'onglet était relue comme l'état d'un bloc dépliable au retour sur
/// l'onglet (`PageStorage`).
void main() {
  List<Map<String, dynamic>> lire(String f) => [
        for (final e
            in jsonDecode(File('assets/data/$f').readAsStringSync()) as List)
          e as Map<String, dynamic>,
      ];

  testWidgets('retour sur la fiche après avoir défilé : pas d\'erreur',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ref = Referentiel(
      races: lire('races.json').map(Race.depuisJson).toList(),
      classes: lire('classes.json').map(Classe.depuisJson).toList(),
    );
    // Comme au chargement de l'application : « Effets reçus » lit ces voies.
    FicheCalculee.voiesDesClasses = [
      for (final c in ref.classes)
        for (final v in c.voies) (voie: v, classe: c.nom),
    ];
    addTearDown(() => FicheCalculee.voiesDesClasses = const []);
    final p = Personnage(
      id: 'o',
      nom: 'Octavius',
      raceId: 'gnome',
      classeId: 'ingenieur',
      rangsVoies: {'ingenieur-chimiste': 1},
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FicheComplete(
          fiche: FicheCalculee(
            personnage: p,
            race: ref.race('gnome')!,
            classe: ref.classe('ingenieur')!,
          ),
          referentiel: ref,
          onModifie: () async {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const PageStorageKey('onglet-fiche')),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    final etat = tester.state<ScrollableState>(find
        .descendant(
          of: find.byKey(const PageStorageKey('onglet-fiche')),
          matching: find.byType(Scrollable),
        )
        .first);
    expect(etat.position.pixels, greaterThan(0));
    expect(find.byKey(const Key('effets-recus')), findsOneWidget);
    await tester.tap(find.byKey(const Key('vue-inventaire')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vue-fiche')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(ErrorWidget), findsNothing);
  });
}
