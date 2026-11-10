import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/creature.dart';
import 'package:odyssee_vagabonds/models/equipement.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/screens/bestiaire_screen.dart';
import 'package:odyssee_vagabonds/screens/equipements_screen.dart';
import 'package:odyssee_vagabonds/widgets/maitrises_restrictions.dart';

/// Glossaire (09/11/2026) : armures par famille, détail au toucher, familles
/// et filtres des équipements, origine des créatures.
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
  final equipements = Referentiel.enregistrerGroupesArmes([
    for (final e in _json('equipements.json'))
      Equipement.depuisJson(e as Map<String, dynamic>),
  ]);
  final creatures = [
    for (final e in _json('bestiaire.json'))
      Creature.depuisJson(e as Map<String, dynamic>),
  ];
  final ref = Referentiel(
    classes: classes,
    races: races,
    equipements: equipements,
    creatures: creatures,
  );

  Future<void> afficher(WidgetTester tester, Widget w) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: w)));
    await tester.pumpAndSettle();
  }

  testWidgets('armures par famille ; détail des armures permises au toucher',
      (tester) async {
    final barbare = classes.firstWhere((c) => c.id == 'barbare');
    await afficher(tester, MaitrisesRestrictions(classe: barbare));
    expect(find.text('Armures intermédiaires maximum'), findsOneWidget);
    // Téléphone : un toucher ouvre le détail.
    await tester.tap(find.text('Armures intermédiaires maximum'));
    await tester.pumpAndSettle();
    final detail =
        tester.widget<Text>(find.byKey(const Key('detail-pastille'))).data!;
    expect(detail, contains('Légère : '));
    expect(detail, contains('Cotte de mailles'));
    expect(detail, isNot(contains('Lourde')));
    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();
    // Classe sans limite : toutes.
    await afficher(
      tester,
      MaitrisesRestrictions(
          classe: classes.firstWhere((c) => c.id == 'guerrier')),
    );
    expect(find.text('Toutes'), findsOneWidget);
    // Groupe d'armes : le toucher montre aussi les armes concernées.
    await tester.tap(find.text('Civiles'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('detail-pastille'))).data,
      contains('Bâton'),
    );
  });

  test('familles des équipements', () {
    Equipement e(String id) => equipements.firstWhere((x) => x.id == id);
    expect(familleEquipement(e('baton')), 'Arme civile');
    expect(familleEquipement(e('arbalete-lourde')), 'Arme commune à distance');
    expect(familleEquipement(e('tromblon')), 'Arme à poudre');
    expect(familleEquipement(e('armure-plaques')), 'Armure lourde');
    expect(familleEquipement(e('cotte-de-mailles')), 'Armure intermédiaire');
    expect(familleEquipement(e('armure-matelassee')), 'Armure légère');
    expect(familleEquipement(e('lanterne')), isNull);
  });

  testWidgets('équipements : filtre par étiquette après la catégorie',
      (tester) async {
    await afficher(tester, EquipementsScreen(referentiel: ref));
    expect(find.byKey(const Key('filtres-etiquettes')), findsNothing);
    await tester.tap(find.byKey(const Key('categorie-armure')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('filtres-etiquettes')), findsOneWidget);
    await tester.tap(find.byKey(const Key('etiquette-lourde')));
    await tester.pumpAndSettle();
    expect(find.text('Armure de plaques'), findsOneWidget);
    expect(find.text('Armure de cuir'), findsNothing);
    // Famille affichée sur la carte.
    expect(find.text('Armure lourde'), findsWidgets);
  });

  testWidgets('bestiaire : plus de famille Invocations, origine affichée',
      (tester) async {
    expect(creatures.where((c) => c.famille == 'Invocations'), isEmpty);
    // Plus d'archétype « Compagnon » ni de rang entre parenthèses.
    expect(creatures.where((c) => c.archetype == 'Compagnon'), isEmpty);
    expect(
      creatures.where((c) => RegExp(r'\(rang \d\)').hasMatch(c.description)),
      isEmpty,
    );
    expect(
      creatures.firstWhere((c) => c.id == 'druide-aigle').archetype,
      'Rapide, Volant',
    );
    expect(
      ref.originesCreature('druide-loup'),
      ['Druide · Voie bestiale · Animal de compagnie'],
    );
    expect(ref.originesCreature('bouquetin-nain').single, startsWith('Nain'));
    expect(ref.originesCreature('ours-brun'), isEmpty);
    final loup = creatures.firstWhere((c) => c.id == 'druide-loup');
    expect(loup.famille, 'Bêtes');
    await afficher(
      tester,
      CreatureDetail(
        creature: loup,
        origines: ref.originesCreature(loup.id),
      ),
    );
    expect(find.byKey(const Key('creature-origines')), findsOneWidget);
    // Infobulle des statistiques (créature avec ses modificateurs).
    await afficher(
      tester,
      CreatureDetail(creature: creatures.firstWhere((c) => c.mods.isNotEmpty)),
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is Tooltip && (w.message ?? '').startsWith('Force'),
      ),
      findsOneWidget,
    );
  });
}
