import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/type_sort.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/savoirs.dart';
import 'package:odyssee_vagabonds/widgets/resume_fiche.dart';

/// Magicien : sept voies adaptées (26/10/2026) — sorts, boule de feu
/// modulable, résistances, artéfact (−1 PM), éclat des arcanes par rang.

List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

final _classes = [
  for (final e in _json('classes.json'))
    Classe.depuisJson(e as Map<String, dynamic>),
];
final _magicien = _classes.firstWhere((c) => c.id == 'magicien');
final _humain = [
  for (final e in _json('races.json'))
    Race.depuisJson(e as Map<String, dynamic>),
].firstWhere((r) => r.id == 'humain');
final _aptitudes = [
  for (final e in _json('aptitudes.json'))
    Aptitude.depuisJson(e as Map<String, dynamic>),
];

FicheCalculee _fiche(Map<String, int> rangs,
        {Map<String, String> choix = const {}}) =>
    FicheCalculee(
      personnage: Personnage(
        id: 'm',
        nom: 'Merlin',
        raceId: 'humain',
        classeId: 'magicien',
        niveau: 9,
        rangsVoies: Map.of(rangs),
        choix: Map.of(choix),
        caracBase: {for (final c in Carac.values) c: 12},
      ),
      race: _humain,
      classe: _magicien,
    );

void main() {
  Referentiel.completerReferences([_humain], _classes);

  test('les pouvoirs actifs sont des sorts typés, les passifs non', () {
    final f = _fiche({
      for (final v in _magicien.voies) v.id: 5,
    });
    final noms = {for (final s in f.sorts) s.competence.nom};
    expect(
        noms,
        containsAll([
          'Cercle de protection',
          'Téléportation',
          'Mur de flamme',
          'Contrôle du feu',
          'Élémentaire de feu',
          'Poing de pierre',
          'Chaîne d\'éclairs',
          'Éclat des arcanes',
          'Bannissement',
        ]));
    expect(noms, isNot(contains('Esprit du Phénix')));
    expect(noms, isNot(contains('Transfert de mana')));
    expect(noms, isNot(contains('Sens tellurique')));
    for (final s in f.sorts) {
      expect(s.competence.typesSort, isNotEmpty, reason: s.competence.nom);
    }
    final controle =
        f.sorts.firstWhere((s) => s.competence.nom == 'Contrôle du feu');
    expect(controle.cout, FicheCalculee.coutsSorts[0]);
    // Attaque magique contre la CA de la cible (refonte du 29/10/2026).
    final chaine =
        f.sorts.firstWhere((s) => s.competence.nom == 'Chaîne d\'éclairs');
    expect(f.jetReussite(chaine.competence)!.carac, Carac.adm);
    expect(chaine.competence.degats, startsWith('3d6 foudre'));
    final poing =
        f.sorts.firstWhere((s) => s.competence.nom == 'Poing de pierre');
    expect(poing.competence.reussite!.contre, contains('CA de la cible'));
    expect(
      f.sorts
          .firstWhere((s) => s.competence.nom == 'Élémentaire d\'air')
          .competence
          .typesSort,
      [TypeSort.invocation, TypeSort.transformation],
    );
  });

  test('boule de feu modulable : une carte par puissance', () {
    final r3 = _fiche({'magicien-feu': 3});
    final boules = [
      for (final s in r3.sorts)
        if (s.competence.nom.startsWith('Boule de feu')) s,
    ];
    expect(boules.map((s) => s.competence.nom), [
      'Boule de feu (1d6)',
      'Boule de feu (2d6)',
      'Boule de feu (3d6)',
    ]);
    expect(boules.map((s) => s.cout), [1, 3, 6]);
    expect(boules[2].competence.degats, '3d6 feu');
    expect(r3.jetsEffetSort(boules[1].competence).first.des, '2d6');
  });

  test('résistances : RD +RANG par voie, additionnées par type', () {
    final f = _fiche({'magicien-feu': 3, 'magicien-terre': 2});
    final rd = {for (final r in f.resistances) r.type: r.total};
    expect(rd, {'physique': 2, 'feu': 3});
    expect(f.resistances.first.sources.single.nom, 'Esprit de Gaïa');
  });

  test('arcanes : éclat 1d4 → 2d4 → 3d4 + INT, artéfact −1 PM', () {
    JetDisponible degats(FicheCalculee f) {
      final eclat = f.sorts
          .firstWhere((s) => s.competence.nom == 'Éclat des arcanes')
          .competence;
      final jets = f
          .jetsEffetSort(eclat)
          .where((j) => j.libelle.endsWith('dégâts'))
          .toList();
      expect(jets, hasLength(1));
      return jets.single;
    }

    expect(degats(_fiche({'magicien-arcanes': 1})).des, '1d4');
    expect(degats(_fiche({'magicien-arcanes': 3})).des, '2d4');
    final r5 = _fiche({'magicien-arcanes': 5}, choix: {'focaliseur': 'orbe'});
    expect(degats(r5).des, '3d4');
    expect(degats(r5).carac, Carac.intel);
    expect(degats(r5).bonus, r5.mod(Carac.intel));
    // Artéfact : −1 PM sur les sorts des arcanes (min. 1).
    int cout(FicheCalculee f, String nom) =>
        f.sorts.firstWhere((s) => s.competence.nom == nom).cout;
    expect(cout(_fiche({'magicien-arcanes': 3}), 'Agrandissement'), 6);
    expect(cout(r5, 'Agrandissement'), 5);
    expect(cout(r5, 'Éclat des arcanes'), 1);
    expect(cout(r5, 'Déchaînement des arcanes'), 14);
    // +2 au toucher magique (test d'AdM), pas à la stat.
    expect(r5.carac(Carac.adm), _fiche({}).carac(Carac.adm));
    expect(
      r5.bonusTestsPermanents
          .any((s) => s.effet.carac == Carac.adm && s.effet.valeurEntiere == 2),
      isTrue,
    );
    expect(
      r5.objetsARecevoir.any((o) => o.objet['nom'] == 'Orbe focaliseur'),
      isTrue,
    );
    expect(r5.usages.single.nom, 'Sort stocké');
  });

  test('archimage, bannissement, savoir magique, états', () {
    final base = _fiche({});
    final f = _fiche({
      'magicien-magie-universelle': 5,
      'magicien-lumiere': 5,
      'magicien-air': 3,
      'magicien-feu': 5,
    });
    expect(f.carac(Carac.intel), base.carac(Carac.intel) + 4);
    expect(f.carac(Carac.adm), base.carac(Carac.adm) + 4);
    expect(f.titres, contains('Archimage'));
    final arcanes = jetsSavoirs(f, _aptitudes, FamilleAptitude.savoir)
        .firstWhere((j) => j.aptitude.id == 'arcanes');
    expect(arcanes.bonus.single.valeur, 5);
    expect(
      f.etatsPossibles.map((e) => e.etat.nom),
      containsAll(['Mur d\'air', 'Forme d\'élémentaire de feu']),
    );
    expect(
      f.situationsHorsTests.any((s) => s.nom == 'Cercle de protection'),
      isTrue,
    );
    expect({for (final u in f.usages) u.nom}, {'Bouclier du zénith'});
  });

  testWidgets('fiche : cases de résistance (RD)', (tester) async {
    final f = _fiche({'magicien-feu': 3, 'magicien-eau': 2});
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: ResumeFiche(fiche: f))),
    ));
    await tester.pumpAndSettle();
    bool vide(String t) => find
        .descendant(of: find.byKey(Key('stat-rd-$t')), matching: find.text('—'))
        .evaluate()
        .isNotEmpty;
    expect(vide('feu'), isFalse);
    expect(vide('glace'), isFalse);
    expect(vide('foudre'), isTrue);
    // Sans RD : les 5 cases restent, à « — ».
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: SingleChildScrollView(child: ResumeFiche(fiche: _fiche({})))),
    ));
    await tester.pumpAndSettle();
    for (final t in ['physique', 'magique', 'feu', 'glace', 'foudre']) {
      expect(vide(t), isTrue, reason: t);
    }
  });
}
