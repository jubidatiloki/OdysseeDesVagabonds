import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/theme.dart';
import 'package:odyssee_vagabonds/widgets/libelles_sort.dart';
import 'package:odyssee_vagabonds/widgets/voie_detail.dart';

/// Compétence `nom` des classes réelles.
Competence _competence(String nom) {
  final classes =
      (jsonDecode(File('assets/data/classes.json').readAsStringSync()) as List)
          .map((e) => Classe.depuisJson(e as Map<String, dynamic>));
  return classes
      .expand((c) => c.voies)
      .expand((v) => v.competences)
      .firstWhere((c) => c.nom == nom);
}

Widget _app(Widget enfant) => MaterialApp(
      theme: themeOdv(Brightness.dark),
      home: Scaffold(body: SingleChildScrollView(child: enfant)),
    );

void main() {
  testsReussite();

  test('données : dégâts, effet appliqué et coût des sorts', () {
    final toucher = _competence('Toucher nécrotique');
    expect(toucher.degats, '1d6');
    expect(toucher.effetApplique, contains('PV'));
    expect(FicheCalculee.coutSort(toucher), (rang: 1, cout: 1));
    expect(_competence('Soin modéré').soin, startsWith('2D6 PV'));
    final guerison = _competence('Guérison');
    expect(guerison.soin, '5D6 PV');
    expect(guerison.effetApplique, startsWith('Guérit'));
    expect(_competence('Dissipation').mana, 'Coût du sort dissipé');
    expect(
      FicheCalculee.coutSort(
          const Competence(rang: 1, nom: 'x', type: 'sort, coût rang 3')),
      (rang: 3, cout: 6),
    );
    expect(
      FicheCalculee.coutSort(
          const Competence(rang: 2, nom: 'p', type: 'passif')),
      isNull,
    );
  });

  testWidgets('libellés : mana, dégâts, effet ; rien hors sort',
      (tester) async {
    await tester.pumpWidget(_app(const Column(children: [
      LibellesSort(Competence(
        rang: 2,
        nom: 'Lumière',
        type: 'actif, sort',
        degats: '1d8 chaos',
        effetApplique: 'Aveuglé 1 tour',
      )),
      LibellesSort(Competence(
        rang: 1,
        nom: 'Soin',
        type: 'actif, sort',
        soin: '1D6 PV',
      )),
      LibellesSort(Competence(
        rang: 3,
        nom: 'Dissiper',
        type: 'sort',
        mana: 'Coût du sort dissipé',
      )),
      LibellesSort(Competence(rang: 1, nom: 'Garde', type: 'passif')),
    ])));
    expect(find.text('3 PM'), findsOneWidget);
    expect(find.text('1d8 chaos'), findsOneWidget);
    expect(find.text('Aveuglé 1 tour'), findsOneWidget);
    expect(find.text('Coût du sort dissipé'), findsOneWidget);
    expect(find.byIcon(Icons.water_drop), findsNWidgets(3));
    expect(find.text('1D6 PV'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.bolt), findsOneWidget);
    expect(find.byIcon(Icons.auto_fix_high), findsOneWidget);
  });

  testWidgets('carte de rangs d\'une classe : libellés des sorts',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final classes =
        (jsonDecode(File('assets/data/classes.json').readAsStringSync())
                as List)
            .map((e) => Classe.depuisJson(e as Map<String, dynamic>));
    final mort = classes.expand((c) => c.voies).firstWhere(
        (v) => v.competences.any((c) => c.nom == 'Toucher nécrotique'));
    await tester.pumpWidget(_app(VoieDetail(voie: mort)));
    expect(tester.takeException(), isNull);
    expect(find.text('1d6'), findsOneWidget);
    expect(find.text('1 PM'), findsWidgets);
  });
}

List<Classe> _classes() =>
    (jsonDecode(File('assets/data/classes.json').readAsStringSync()) as List)
        .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
        .toList();

List<Race> _races() =>
    (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
        .map((e) => Race.depuisJson(e as Map<String, dynamic>))
        .toList();

/// Nécromancien niveau 1 avec Toucher nécrotique (rang 1, voie de la mort).
(Personnage, Classe, Race) _necromancien() {
  final necro = _classes().firstWhere((c) => c.id == 'necromancien');
  final voie = necro.voies.firstWhere(
      (v) => v.competences.any((c) => c.nom == 'Toucher nécrotique'));
  final p = Personnage(
    id: 'n',
    nom: 'Morgane',
    raceId: 'humain',
    classeId: 'necromancien',
    rangsVoies: {voie.id: 1},
    caracBase: {for (final c in Carac.values) c: 12}
      ..[Carac.adm] = 16
      ..[Carac.intel] = 14,
  );
  return (p, necro, _races().firstWhere((r) => r.id == 'humain'));
}

void testsReussite() {
  test('sort à jet de réussite : attaque magique puis dégâts à part', () {
    final (p, necro, humain) = _necromancien();
    final f = FicheCalculee(personnage: p, race: humain, classe: necro);
    final toucher = f.sorts.single.competence;
    expect(toucher.reussite!.carac, 'ADM');
    final r = f.jetReussite(toucher)!;
    expect(r.des, '1d20');
    expect(r.bonus, f.mod(Carac.adm));
    expect(r.libelle, 'Toucher nécrotique · Attaque magique');
    final effets = f.jetsEffetSort(toucher);
    expect(effets.single.des, '1d6');
    expect(effets.single.bonus, f.degatsMagie);
    expect(FicheCalculee.desDans('5D6 PV'), '5d6');
    expect(FicheCalculee.desDans('+ dé de mana'), isNull);
    // Soin : dés seuls
    const soin =
        Competence(rang: 1, nom: 'Soin', type: 'sort', soin: '2D6 PV (20 m)');
    expect(f.jetsEffetSort(soin).single.des, '2d6');
    expect(f.jetsEffetSort(soin).single.bonus, 0);
    expect(f.jetReussite(soin), isNull);
  });

  testWidgets('page dé : lancer le sort sans les dégâts, puis les dégâts',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final (p, necro, _) = _necromancien();
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      MaterialApp(
        home: DeScreen(
          referentiel: Referentiel(races: _races(), classes: [necro]),
          personnages: controller,
          preferences: PreferencesController(personnageActifId: 'n'),
          aleatoire: Random(3),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    expect(find.textContaining('contre CA de la cible'), findsOneWidget);
    int pmActuels() => FicheCalculee(
            personnage: p,
            race: _races().firstWhere((r) => r.id == 'humain'),
            classe: necro)
        .pmActuels;
    final pm = pmActuels();
    await tap(find.byKey(const Key('lancer-sort-0')));
    final messages = p.historique.map((e) => e.message).toList();
    expect(messages, contains(startsWith('Sort lancé : Toucher nécrotique')));
    expect(messages,
        contains(startsWith('Lancer · Toucher nécrotique · Attaque magique')));
    expect(messages.where((m) => m.contains('· dégâts')), isEmpty);
    expect(pmActuels(), pm - 1); // sort de rang 1 : 1 PM

    await tap(find.byKey(const Key('effet-sort-0')));
    expect(
      p.historique.map((e) => e.message),
      contains(startsWith('Lancer · Toucher nécrotique · dégâts')),
    );
    await tester.pumpWidget(const SizedBox());
  });
}
