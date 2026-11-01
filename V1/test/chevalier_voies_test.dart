import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/savoirs.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/historique_lancers.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';

/// Chevalier : voies de la cavalerie, du duel et du commandement remises en
/// forme (25/10/2026) — esquives typées, monté, situations de dégâts et de
/// CA, usages par combat, état d'un seul coup (Feinte).

final _classes =
    (jsonDecode(File('assets/data/classes.json').readAsStringSync()) as List)
        .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
        .toList();
final _chevalier = _classes.firstWhere((c) => c.id == 'chevalier');
final _humain =
    (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
        .map((e) => Race.depuisJson(e as Map<String, dynamic>))
        .firstWhere((r) => r.id == 'humain');
final _aptitudes =
    (jsonDecode(File('assets/data/aptitudes.json').readAsStringSync()) as List)
        .map((e) => Aptitude.depuisJson(e as Map<String, dynamic>))
        .toList();

Objet _epee() => Objet(
      nom: 'Épée longue',
      categorie: CategorieObjet.arme,
      degats: '1d6',
      equipe: true,
    );

Personnage _perso({
  Map<String, int> rangs = const {},
  Map<String, String> choix = const {},
  List<Objet>? inventaire,
  Set<String> etats = const {},
}) =>
    Personnage(
      id: 'k',
      nom: 'Lancelin',
      raceId: 'humain',
      classeId: 'chevalier',
      niveau: 9,
      rangsVoies: Map.of(rangs),
      choix: Map.of(choix),
      etats: Set.of(etats),
      caracBase: {for (final c in Carac.values) c: 12},
      inventaire: inventaire ?? [_epee()],
    );

FicheCalculee _fiche({
  Map<String, int> rangs = const {},
  Map<String, String> choix = const {},
  List<Objet>? inventaire,
  Set<String> etats = const {},
}) =>
    FicheCalculee(
      personnage: _perso(
          rangs: rangs, choix: choix, inventaire: inventaire, etats: etats),
      race: _humain,
      classe: _chevalier,
    );

void main() {
  Referentiel.completerReferences([_humain], _classes);

  group('cavalerie', () {
    test('rang 1 : cheval, lance d\'arçon, équitation offerte', () {
      final f = _fiche(rangs: {'chevalier-cavalerie': 1});
      final objets = f.objetsARecevoir.map((o) => o.objet).toList();
      expect(
          objets.any((o) =>
              o['nom'] == 'Cheval de guerre' && o['categorie'] == 'monture'),
          isTrue);
      expect(objets.any((o) => o['nom'] == 'Lance d\'arçon'), isTrue);
      expect(f.aptitudesOffertes, contains('equitation'));
      final equitation = jetsSavoirs(f, _aptitudes, FamilleAptitude.savoirFaire)
          .firstWhere((j) => j.aptitude.id == 'equitation');
      expect(equitation.maitrise, isTrue);
      expect(equitation.modificateur, 5);
      // La lance est au catalogue.
      final catalogue =
          jsonDecode(File('assets/data/equipements.json').readAsStringSync())
              as List;
      expect(catalogue.any((e) => e['nom'] == 'Lance d\'arçon'), isTrue);
    });

    test('rang 2 : charge (+2 AdC, +1d6) et charge à la lance (+2d6)', () {
      final f = _fiche(rangs: {'chevalier-cavalerie': 2});
      final charge = f.jetsCompetences.firstWhere((j) => j.libelle == 'Charge');
      final lance =
          f.jetsCompetences.firstWhere((j) => j.libelle == 'Charge à la lance');
      expect(charge.attaque!.toucher, 2);
      expect(charge.attaque!.degatsEnPlus, '1d6');
      expect(lance.attaque!.degatsEnPlus, '2d6');
      // Sans lance en main : charge à la lance impossible.
      expect(f.armeAttaque(charge.attaque!)?.nom, 'Épée longue');
      expect(f.armeAttaque(lance.attaque!), isNull);
      final avecLance = _fiche(rangs: {
        'chevalier-cavalerie': 2
      }, inventaire: [
        Objet(
          nom: 'Lance d\'arçon',
          categorie: CategorieObjet.arme,
          degats: '1d8',
          equipe: true,
        ),
      ]);
      expect(avecLance.armeAttaque(lance.attaque!)?.nom, 'Lance d\'arçon');
    });

    test('rang 3 : monté = +2 CA CaC (esquive), +3 AdC à cocher', () {
      Objet cheval({required bool monte}) => Objet(
            nom: 'Cheval de guerre',
            categorie: CategorieObjet.monture,
            equipe: monte,
          );
      final aPied = _fiche(
          rangs: {'chevalier-cavalerie': 3},
          inventaire: [_epee(), cheval(monte: false)]);
      final monte = _fiche(
          rangs: {'chevalier-cavalerie': 3},
          inventaire: [_epee(), cheval(monte: true)]);
      expect(monte.estMonte, isTrue);
      expect(monte.caCac, aPied.caCac + 2);
      expect(monte.classeArmure, aPied.classeArmure);
      expect(
        monte.bonusTestsSituationnels.any((s) =>
            s.effet.carac == Carac.adc &&
            s.effet.valeurEntiere == 3 &&
            s.effet.condition == 'monté'),
        isTrue,
      );
    });

    test('rang 4 et 5 : piétinement, drake, +2 SOC', () {
      final r4 = _fiche(rangs: {'chevalier-cavalerie': 4});
      expect(r4.jetsCompetences.any((j) => j.libelle == 'Piétinement'), isTrue);
      final r5 = _fiche(rangs: {'chevalier-cavalerie': 5});
      expect(r5.carac(Carac.soc), r4.carac(Carac.soc) + 2);
      expect(r5.jetsCompetences.any((j) => j.libelle == 'Drake : attaque'),
          isTrue);
      expect(
        r5.objetsARecevoir.any((o) =>
            o.objet['nom'] == 'Drake' && o.objet['categorie'] == 'monture'),
        isTrue,
      );
    });
  });

  group('duel', () {
    test('rang 1 : parade CaC ou distance, +1 par rang', () {
      final base = _fiche();
      final cac =
          _fiche(rangs: {'chevalier-duel': 3}, choix: {'parade': 'cac'});
      final dist =
          _fiche(rangs: {'chevalier-duel': 3}, choix: {'parade': 'dist'});
      expect(cac.caCac, base.caCac + 3);
      expect(cac.caDistance, base.caDistance);
      expect(dist.caDistance, base.caDistance + 3);
    });

    test('Ouverture : +2 au toucher, +4 dès Dehors les importuns', () {
      int ouverture(FicheCalculee f) => f.bonusTestsSituationnels
          .where((s) => s.nom == 'Ouverture' && s.effet.carac == Carac.adc)
          .single
          .effet
          .valeurEntiere!;
      expect(ouverture(_fiche(rangs: {'chevalier-duel': 2})), 2);
      expect(ouverture(_fiche(rangs: {'chevalier-duel': 4})), 4);
    });

    test('situations de dégâts et de CA : à cocher, jamais comptées seules',
        () {
      final base = _fiche(rangs: {'chevalier-duel': 3});
      final f = _fiche(rangs: {'chevalier-duel': 5});
      final hors = f.situationsHorsTests;
      expect(hors.map((s) => s.effet.valeur),
          containsAll(['2d6', '5', '1d6', '3']));
      // Ni la CA, ni les esquives, ni les dés de l'arme ne changent.
      expect(f.classeArmure, base.classeArmure);
      expect(f.caCac, base.caCac);
      final arme = f.personnage.inventaire.single;
      expect(
          f.desEnPlus(arme).map((s) => s.effet.valeur), isNot(contains('1d6')));
      expect(f.bonusTestsSituationnels, containsAll(hors));
    });

    test('Feinte préparée : +5 AdC et +2d6 tant qu\'elle est active', () {
      final f = _fiche(rangs: {'chevalier-duel': 3});
      final etat = f.etatsPossibles.single.etat;
      expect(etat.nom, 'Feinte préparée');
      expect(etat.finApresDegats, isTrue);
      final active =
          _fiche(rangs: {'chevalier-duel': 3}, etats: {'Feinte préparée'});
      expect(
        active.bonusTestsPermanents.any(
            (s) => s.effet.carac == Carac.adc && s.effet.valeurEntiere == 5),
        isTrue,
      );
      expect(
        active
            .desEnPlus(active.personnage.inventaire.single)
            .map((s) => s.effet.valeur),
        contains('2d6'),
      );
    });
  });

  group('commandement', () {
    test('Meneur +RANG, usages par combat, Général +2 SOC', () {
      final r1 = _fiche(rangs: {'chevalier-commandement': 1});
      final r5 = _fiche(rangs: {'chevalier-commandement': 5});
      expect(
        r5.bonusTestsSituationnels
            .firstWhere((s) => s.nom == 'Meneur')
            .effet
            .valeurEntiere,
        5,
      );
      expect(r5.carac(Carac.soc), r1.carac(Carac.soc) + 2);
      final usages = {for (final u in r5.usages) u.nom: u};
      expect(usages['Montrer l\'exemple']!.max, 1);
      expect(usages['Cri de ralliement']!.max, 1);
      expect(usages['Ordre d\'attaque']!.max, 2);
      expect(usages.values.every((u) => u.periode == 'par combat'), isTrue);
      expect(
        r5.jetsCompetences
            .any((j) => j.libelle == 'Cri de ralliement : PV temporaires'),
        isTrue,
      );
    });
  });

  Future<(PersonnagesController, HistoriqueLancers)> ouvrir(
    WidgetTester tester,
    Personnage p,
  ) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    final historique = HistoriqueLancers();
    addTearDown(historique.dispose);
    await tester.pumpWidget(MaterialApp(
      home: DeScreen(
        referentiel: Referentiel(races: [_humain], classes: _classes),
        personnages: controller,
        preferences: PreferencesController(personnageActifId: 'k'),
        historique: historique,
        aleatoire: Random(5),
      ),
    ));
    await tester.pumpAndSettle();
    return (controller, historique);
  }

  testWidgets('page dé : duelliste coché (+1d6), feinte annulée après dégâts',
      (tester) async {
    final (controller, historique) = await ouvrir(
      tester,
      _perso(rangs: {'chevalier-duel': 5}, etats: {'Feinte préparée'}),
    );
    // Groupes « Dégâts CaC » et « CA ».
    expect(find.byKey(const Key('groupe-situation-degats')), findsOneWidget);
    expect(find.byKey(const Key('groupe-situation-ca')), findsOneWidget);
    await tester.tap(find.byKey(
        const Key('situation-Duelliste|+1d6 aux dégâts (en 1 contre 1)')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('jet-degats-cac-0')));
    await tester.pumpAndSettle();
    final r = historique.lancers.first;
    // 1d6 (duelliste) + arme 1d6 + 2d6 (feinte).
    expect(r.des, hasLength(4));
    // La feinte ne vaut que pour ce coup.
    expect(controller.personnages.single.etats, isEmpty);
  });

  testWidgets('page dé : usages par combat et « Nouveau combat »',
      (tester) async {
    final (controller, _) =
        await ouvrir(tester, _perso(rangs: {'chevalier-commandement': 3}));
    final cri = find.byKey(const Key('usage-Cri de ralliement'));
    await tester.tap(cri);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmer-usage')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: cri, matching: find.text('0 / 1')), findsOne);
    await tester.tap(find.byKey(const Key('nouveau-combat')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: cri, matching: find.text('1 / 1')), findsOne);
    expect(controller.personnages.single.utilisations, isEmpty);
  });
}
