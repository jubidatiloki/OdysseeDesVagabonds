import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/creature.dart';
import 'package:odyssee_vagabonds/screens/bestiaire_screen.dart';

/// Bestiaire (31/10/2026) : statistiques (CA, PV, initiative, modificateurs,
/// attaques) du loup, loup alpha, ours noir et ours-hibou.
void main() {
  final creatures = {
    for (final e
        in jsonDecode(File('assets/data/bestiaire.json').readAsStringSync())
            as List)
      (e as Map<String, dynamic>)['id']: Creature.depuisJson(e),
  };

  test('statistiques des bêtes', () {
    final attendu = {
      // id : CA, PV, init, AdC, FOR, DEX, CON, attaque
      'loup': (14, 9, 12, 1, 1, 1, 1, 'Morsure', '1d20 +1', '1d6 +1'),
      'loup-alpha': (15, 15, 16, 3, 3, 1, 3, 'Morsure', '1d20 +3', '1d6 +3'),
      'ours-noir': (15, 35, 15, 3, 3, 2, 3, 'Morsure', '1d20 +3', '1d6 +3'),
      'ours-hibou': (
        16,
        40,
        12,
        6,
        6,
        1,
        6,
        'Bec et griffes',
        '1d20 +6',
        '3d6 +6'
      ),
      'ours-brun': (17, 50, 12, 6, 6, 1, 1, 'Morsure', '1d20 +6', '1d6 +6'),
    };
    for (final MapEntry(key: id, value: v) in attendu.entries) {
      final c = creatures[id]!;
      expect((c.ca, c.pv, c.initiative), (v.$1, v.$2, v.$3), reason: id);
      expect(
        [c.mods[Carac.adc], c.mods[Carac.force], c.mods[Carac.dex]],
        [v.$4, v.$5, v.$6],
        reason: id,
      );
      expect(c.mods[Carac.con], v.$7, reason: id);
      expect((c.mods[Carac.intel], c.mods[Carac.per]), (-4, 2), reason: id);
      expect(c.mods[Carac.soc], isNull, reason: id); // +0
      final a = c.attaques.single;
      expect((a.nom, a.portee, a.toucher, a.degats), (v.$8, 'CaC', v.$9, v.$10),
          reason: id);
      expect(c.aDesStatistiques, isTrue);
      expect(c.note, isEmpty, reason: id);
    }
    expect(creatures['loup-alpha']!.archetype, 'Meute, Chef');
    expect(creatures['ours-hibou']!.archetype, 'Puissant, Berzerk');
    expect(creatures['ours-noir']!.taille, TailleCreature.grande);
    expect(creatures['loup']!.taille, TailleCreature.standard);
  });

  test('dragons : morsure, coup de queue gratuit, souffle sans jet', () {
    final attendu = {
      // id : CA, PV, init, AdC, FOR, DEX, CON, INT, morsure, queue, souffle
      'dragon-juvenile': (16, 35, 22, 6, 4, 5, 4, null, '2d6 +4', null, '4d6'),
      'jeune-dragon': (20, 80, 20, 8, 6, 4, 8, 2, '3d6 +6', '2d6', '6d6'),
      'dragon-adulte': (24, 160, 17, 12, 12, 3, 12, 4, '4d6 +12', '3d6', '8d6'),
      'dragon-ancien': (
        25,
        260,
        15,
        15,
        15,
        0,
        15,
        6,
        '4d6 +15',
        '4d6',
        '10d6'
      ),
    };
    for (final MapEntry(key: id, value: v) in attendu.entries) {
      final c = creatures[id]!;
      expect(c.famille, 'Dragons', reason: id);
      expect((c.ca, c.pv, c.initiative), (v.$1, v.$2, v.$3), reason: id);
      expect(
        [
          c.mods[Carac.adc],
          c.mods[Carac.force],
          c.mods[Carac.dex] ?? 0,
          c.mods[Carac.con],
          c.mods[Carac.intel],
        ],
        [v.$4, v.$5, v.$6, v.$7, v.$8],
        reason: id,
      );
      final a = {for (final x in c.attaques) x.nom: x};
      // Morsure : toucher = AdC (dragon adulte corrigé à +12).
      expect(a['Morsure']!.toucher, '1d20 +${v.$4}', reason: id);
      expect(a['Morsure']!.degats, v.$9, reason: id);
      expect(a['Coup de queue']?.degats, v.$10, reason: id);
      if (v.$10 != null) expect(a['Coup de queue']!.note, 'action gratuite');
      final souffle = a['Souffle élémentaire']!;
      expect(souffle.toucher, isEmpty, reason: id);
      expect(souffle.degats, startsWith(v.$11), reason: id);
      expect(souffle.note, contains('moitié des dégâts'), reason: id);
    }
    expect(creatures['dragon-ancien']!.taille, TailleCreature.titanesque);
    expect(creatures['jeune-dragon']!.taille, TailleCreature.gigantesque);
    expect(creatures['dragon-juvenile']!.taille, TailleCreature.grande);
  });

  test('toutes les créatures : statistiques complètes et cohérentes', () {
    expect(creatures, hasLength(38));
    const familles = {
      'Bêtes',
      'Monstres',
      'Gobelinoïdes',
      'Humanoïdes',
      'Fées',
      'Élémentaires',
      'Créatures artificielles',
      'Géants',
      'Dragons',
      'Morts-vivants',
    };
    for (final c in creatures.values) {
      expect(familles, contains(c.famille), reason: c.id);
      expect(c.description, isNotEmpty, reason: c.id);
      if (c.id == 'zombie') continue; // statistiques à définir
      expect((c.ca, c.pv, c.initiative), isNot((null, null, null)),
          reason: c.id);
      expect(c.mods, isNotEmpty, reason: c.id);
      expect(c.attaques, isNotEmpty, reason: c.id);
      // Toucher = 1d20 + AdC (contact), AdT (distance) ou AdM (magie).
      for (final a in c.attaques.where((a) => a.toucher.isNotEmpty)) {
        final apt = a.note.contains('magique')
            ? Carac.adm
            : a.portee == 'distance'
                ? Carac.adt
                : Carac.adc;
        final m = c.mods[apt] ?? 0;
        expect(a.toucher, '1d20 ${m < 0 ? '−' : '+'}${m.abs()}',
            reason: '${c.id} · ${a.nom}');
      }
    }
    // Nouvelles créatures du 31/10/2026 (échantillon).
    expect(creatures['gobelours']!.taille, TailleCreature.grande);
    expect(creatures['geant-collines']!.taille, TailleCreature.tresGrande);
    expect(creatures['wyverne']!.famille, 'Dragons');
    expect(creatures.values.where((c) => c.famille == 'Élémentaires'),
        hasLength(4));
  });

  testWidgets('fiche : CA · PV · initiative, modificateurs, attaque',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CreatureDetail(creature: creatures['loup-alpha']!),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('CA 15 · PV 15 · Initiative 16'), findsOneWidget);
    String mod(String code) => tester
        .widget<Text>(find
            .descendant(
                of: find.byKey(Key('creature-mod-$code')),
                matching: find.byType(Text))
            .last)
        .data!;
    expect(mod('FOR'), '+3');
    expect(mod('INT'), '−4');
    expect(mod('SOC'), '+0');
    expect(find.byKey(const Key('creature-mod-CHAN')), findsNothing);
    expect(find.textContaining('Morsure (CaC)', findRichText: true),
        findsOneWidget);
  });
}
