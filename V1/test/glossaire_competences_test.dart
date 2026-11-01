import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/index_competences.dart';
import 'package:odyssee_vagabonds/screens/competences_glossaire_screen.dart';

/// Glossaire, onglet Compétences : index par voie, filtres, recherche.

Referentiel _referentiel() {
  List<dynamic> lire(String f) =>
      jsonDecode(File('assets/data/$f').readAsStringSync()) as List;
  return Referentiel(
    races: [
      for (final e in lire('races.json'))
        Race.depuisJson(e as Map<String, dynamic>),
    ],
    classes: [
      for (final e in lire('classes.json'))
        Classe.depuisJson(e as Map<String, dynamic>),
    ],
    aptitudes: Referentiel.enregistrerSortsRang0([
      for (final e in lire('sorts_rang0.json'))
        Aptitude.depuisJson(e as Map<String, dynamic>),
    ]),
  );
}

void main() {
  testsSortsMineurs();
  final ref = _referentiel();
  final index = IndexCompetences.construire(ref);
  EntreeCompetence entree(String nom) =>
      index.firstWhere((e) => e.competence.nom == nom);

  test('index : voies de classe, sorts de rang 0, voies raciales', () {
    expect(index.first.titreGroupe, 'Barbare · Voie de la brute');
    expect(entree('Étincelle').titreGroupe, 'Sorts mineurs (rang 0)');
    expect(entree('Outils de nain').origine, OrigineCompetence.race);
    expect(entree('Outils de nain').titreGroupe, 'Nain · Voie du nain');
    // « aussi » : compétences données au même rang (gnome, humain)
    expect(index.any((e) => e.competence.nom == 'Bonus d\'origine'), isTrue);
  });

  test('catégories : sort, compétence, soutien, soin, dégâts', () {
    expect(entree('Soin léger').categories,
        containsAll({CategorieCompetence.sort, CategorieCompetence.soin}));
    expect(
        entree('Brutalité').categories,
        containsAll({
          CategorieCompetence.competence,
          CategorieCompetence.degats,
        }));
    expect(entree('Acolyte des montagnes').categories,
        contains(CategorieCompetence.soutien));
    expect(entree('Chanceux').categories, contains(CategorieCompetence.soin));
    // « ne peut pas regagner de PV », « regagner du mana » : pas un soin
    expect(entree('Toucher nécrotique').categories,
        isNot(contains(CategorieCompetence.soin)));
    expect(entree('Méditation').categories,
        isNot(contains(CategorieCompetence.soin)));
  });

  test('filtres et recherche (sans accents)', () {
    final races =
        IndexCompetences.filtrer(index, origines: {OrigineCompetence.race});
    expect(races.every((e) => e.origine == OrigineCompetence.race), isTrue);
    final soins = IndexCompetences.filtrer(index,
        origines: {OrigineCompetence.classe},
        categories: {CategorieCompetence.soin});
    expect(soins.map((e) => e.competence.nom), contains('Guérison'));
    expect(soins.map((e) => e.competence.nom), isNot(contains('Chanceux')));
    // Plusieurs catégories : toutes à la fois (sorts ET dégâts).
    final sortsDegats = IndexCompetences.filtrer(index, categories: {
      CategorieCompetence.sort,
      CategorieCompetence.degats,
    });
    expect(sortsDegats, isNotEmpty);
    expect(
      sortsDegats.every((e) =>
          e.categories.contains(CategorieCompetence.sort) &&
          e.categories.contains(CategorieCompetence.degats)),
      isTrue,
    );
    final sorts =
        IndexCompetences.filtrer(index, categories: {CategorieCompetence.sort});
    expect(sortsDegats.length, lessThan(sorts.length));
    // Classes + Races : l'une ou l'autre (une compétence n'a qu'une
    // origine).
    expect(
      IndexCompetences.filtrer(index, origines: {
        OrigineCompetence.classe,
        OrigineCompetence.race,
      }),
      hasLength(index.length),
    );
    final r = IndexCompetences.filtrer(index, recherche: 'frenesie');
    expect(r.map((e) => e.competence.nom), contains('Frénésie (niveau 1)'));
    // La voie compte dans la recherche
    final brute =
        IndexCompetences.filtrer(index, recherche: 'voie de la brute');
    expect(brute, hasLength(5));
  });

  testWidgets('onglet : filtres, recherche, groupes par voie', (tester) async {
    tester.view.physicalSize = const Size(900, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CompetencesGlossaireScreen(referentiel: ref)),
      ),
    );
    String compte() =>
        tester.widget<Text>(find.byKey(const Key('compte-competences'))).data!;
    expect(compte(), startsWith('${index.length} compétences'));
    expect(find.byKey(const Key('groupe-barbare-brute')), findsOneWidget);

    await tester.tap(find.byKey(const Key('filtre-origine-race')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('groupe-barbare-brute')), findsNothing);
    expect(find.byKey(const Key('groupe-race-demi-elfe')), findsOneWidget);

    await tester.tap(find.byKey(const Key('filtre-categorie-soin')));
    await tester.pumpAndSettle();
    expect(find.text('Chanceux'), findsOneWidget);

    await tester.tap(find.byKey(const Key('effacer-filtres')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('champ-recherche')), 'rage');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('groupe-barbare-berzerker')), findsOneWidget);
    expect(find.text('Rage berzerker (niveau 1)'), findsOneWidget);
    expect(find.byKey(const Key('groupe-barbare-brute')), findsNothing);
  });
}

void testsSortsMineurs() {
  final ref = _referentiel();
  final index = IndexCompetences.construire(ref);

  test('filtre « Sorts mineurs » : les 22 sorts de rang 0, avec leurs classes',
      () {
    final mineurs = IndexCompetences.filtrer(index,
        categories: {CategorieCompetence.sortMineur});
    expect(mineurs, hasLength(22));
    expect(mineurs.every((e) => e.competence.rang == 0), isTrue);
    final epine = mineurs.firstWhere((e) => e.competence.nom == 'Épine');
    expect(epine.mention, 'Pour : Druide');
    // Les sorts de classe (rang 1 à 5) n'en font pas partie
    final sorts =
        IndexCompetences.filtrer(index, categories: {CategorieCompetence.sort});
    expect(sorts.length, greaterThan(mineurs.length));
    // Recherche par classe autorisée
    expect(
      IndexCompetences.filtrer(index,
              categories: {CategorieCompetence.sortMineur},
              recherche: 'necromancien')
          .map((e) => e.competence.nom),
      containsAll(['Frisson nécrotique', 'Regard troublant']),
    );
  });

  testWidgets('onglet Compétences : pastille « Sorts mineurs »',
      (tester) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CompetencesGlossaireScreen(referentiel: ref)),
      ),
    );
    await tester.tap(find.byKey(const Key('filtre-categorie-sortMineur')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('compte-competences'))).data,
      '22 compétences · 1 voie',
    );
    expect(find.text('Sorts mineurs (rang 0)'), findsOneWidget);
    expect(find.text('Pour : Druide'), findsWidgets);
  });
}
