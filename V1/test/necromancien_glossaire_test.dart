import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/affliction.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/creature.dart';
import 'package:odyssee_vagabonds/models/equipement.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/causes_afflictions.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/invocations.dart';
import 'package:odyssee_vagabonds/screens/classes_screen.dart';
import 'package:odyssee_vagabonds/widgets/voie_detail.dart';

/// Lot du 11/11/2026 : nécrose, statistiques des invocations en fenêtre,
/// rang 4 de la voie des morts-vivants, Requiem, inventaire de base.
List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

void main() {
  final classes = [
    for (final e in _json('classes.json'))
      Classe.depuisJson(e as Map<String, dynamic>),
  ];
  final races = [
    for (final e in _json('races.json'))
      Race.depuisJson(e as Map<String, dynamic>),
  ];
  final creatures = [
    for (final e in _json('bestiaire.json'))
      Creature.depuisJson(e as Map<String, dynamic>),
  ];
  final equipements = Referentiel.enregistrerGroupesArmes([
    for (final e in _json('equipements.json'))
      Equipement.depuisJson(e as Map<String, dynamic>),
  ]);
  enregistrerCreatures(creatures);
  final necro = classes.firstWhere((c) => c.id == 'necromancien');
  final mortsVivants =
      necro.voies.firstWhere((v) => v.id == 'necromancien-morts-vivants');

  Future<void> afficher(WidgetTester tester, Widget w) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: w)));
    await tester.pumpAndSettle();
  }

  test('nécrose : affliction du glossaire, causée par le Toucher nécrotique',
      () {
    expect(kAfflictions.map((a) => a.nom), contains('Nécrose'));
    final causes =
        causesAfflictions(classes: classes, races: races, creatures: creatures);
    expect(causes['Nécrose'], contains('Nécromancien · Toucher nécrotique'));
  });

  test('séance : compagnons et familiers qui se battent', () {
    FicheCalculee fiche(String classe, Map<String, int> rangs,
            [Map<String, String> choix = const {}]) =>
        FicheCalculee(
          personnage: Personnage(
            id: 'p',
            nom: 'P',
            raceId: 'humain',
            classeId: classe,
            rangsVoies: rangs,
            choix: choix,
          ),
          race: races.firstWhere((r) => r.id == 'humain'),
          classe: classes.firstWhere((c) => c.id == classe),
        );
    // Rôdeur : compagnon adulte (rang 3) avec une attaque.
    final rodeur = compagnonsCombattants(
      fiche('rodeur', {'rodeur-animaux': 3}, {'compagnon-rodeur': 'loup'}),
    );
    expect(rodeur.map((x) => (x.creature.id, x.type)),
        [('rodeur-loup-adulte', 'Compagnon')]);
    // Nécromancien : invocations temporaires exclues, serviteur permanent
    // gardé ; familiers sans attaque exclus.
    final necroFiche = fiche('necromancien', {
      'necromancien-morts-vivants': 4,
      'necromancien-invocation': 3,
    });
    expect(
      compagnonsCombattants(necroFiche).map((x) => x.creature.id),
      ['serviteur-permanent'],
    );
  });

  test('Requiem : 1d4 + INT morts-vivants', () {
    expect(mortsVivants.competence(5)!.effet, contains('1d4 + INT'));
  });

  testWidgets('voie des morts-vivants : un seul numéro de rang 4',
      (tester) async {
    await afficher(
        tester, SingleChildScrollView(child: VoieDetail(voie: mortsVivants)));
    expect(find.text('4'), findsOneWidget);
    expect(
      find.byKey(const Key('sous-competence-Serviteur permanent')),
      findsOneWidget,
    );
  });

  testWidgets('statistiques d\'une invocation : dans une fenêtre',
      (tester) async {
    final diablotin = necro.voies
        .expand((v) => v.competences)
        .firstWhere((c) => c.nom == 'Diablotin');
    await afficher(tester, LigneCompetence(competence: diablotin));
    await tester.tap(find.byKey(const Key('statistiques-diablotin')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fenetre-creature-diablotin')), findsOneWidget);
    // Pas de nouvelle page : la ligne de compétence reste dessous.
    expect(find.byType(LigneCompetence, skipOffstage: false), findsOneWidget);
    await tester.tap(find.byTooltip('Fermer'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fenetre-creature-diablotin')), findsNothing);
  });

  testWidgets('glossaire des classes : inventaire de base', (tester) async {
    await afficher(
      tester,
      ClasseDetail(
        classe: classes.firstWhere((c) => c.id == 'barbare'),
        equipements: equipements,
      ),
    );
    expect(find.byKey(const Key('inventaire-base-classe')), findsOneWidget);
    expect(find.text('• Hache de guerre'), findsOneWidget);
  });
}
