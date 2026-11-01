import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/effet.dart';
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/des.dart';
import 'package:odyssee_vagabonds/regles/ecuyers.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/inventaire.dart';
import 'package:odyssee_vagabonds/regles/savoirs.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';
import 'package:odyssee_vagabonds/widgets/carte_choix.dart';

/// Chevalier, voie de la noblesse : arme familiale (25/10/2026) — arme de
/// maître, trait de lignée I / II / III selon le rang, +1 AdC / +1 DMG au
/// rang 4, critique 19-20 au rang 5.

final _classes =
    (jsonDecode(File('assets/data/classes.json').readAsStringSync()) as List)
        .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
        .toList();
final _chevalier = _classes.firstWhere((c) => c.id == 'chevalier');
final _humain =
    (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
        .map((e) => Race.depuisJson(e as Map<String, dynamic>))
        .firstWhere((r) => r.id == 'humain');

Personnage _personnage({
  required int rang,
  String trait = 'guerriere',
  bool equipee = true,
  Map<String, String> choix = const {},
  Map<String, String> precisions = const {},
  Sexe? sexe,
}) =>
    Personnage(
      id: 'c',
      nom: 'Godefroy',
      raceId: 'humain',
      classeId: 'chevalier',
      niveau: 9,
      sexe: sexe,
      rangsVoies: {'chevalier-noblesse': rang},
      choix: {'arme-familiale': trait, ...choix},
      precisionsChoix: {'arme-familiale': 'Épée longue', ...precisions},
      caracBase: {for (final c in Carac.values) c: 12},
      inventaire: [
        Objet(
          nom: 'Épée longue',
          categorie: CategorieObjet.arme,
          degats: '1d8',
          equipe: equipee,
        ),
      ],
    );

FicheCalculee _fiche({
  required int rang,
  String trait = 'guerriere',
  bool equipee = true,
  Map<String, String> choix = const {},
  Map<String, String> precisions = const {},
  Sexe? sexe,
}) =>
    FicheCalculee(
      personnage: _personnage(
        rang: rang,
        trait: trait,
        equipee: equipee,
        choix: choix,
        precisions: precisions,
        sexe: sexe,
      ),
      race: _humain,
      classe: _chevalier,
    );

int _toucherFamiliale(FicheCalculee f) => f
    .bonusToucher(distance: false)
    .where((b) => b.nom == 'Arme familiale' || b.nom == 'Droit du sang')
    .fold(0, (n, b) => n + b.valeur);

List<String> _textes(FicheCalculee f) => [
      for (final s in f.effetsActifs)
        if (s.effet.typeNormalise == 'texte') s.effet.texte,
    ];

void main() {
  Referentiel.completerReferences([_humain], _classes);

  test('rang 2 : arme de maître (+1 AdC) et trait de lignée I', () {
    final f = _fiche(rang: 2);
    expect(_toucherFamiliale(f), 1);
    // Lignée guerrière I : +1 DMG avec l'arme familiale.
    final arme = f.personnage.inventaire.single;
    expect(
      f.desEnPlus(arme).map((s) => s.effet.valeur),
      contains('1'),
    );
    // Les niveaux II et III ne sont pas encore actifs.
    expect(_textes(f).any((t) => t.contains('relancer un jet de dégâts')),
        isFalse);
    expect(f.seuilCritique(distance: false).seuil, 20);
    // +2 SOC face aux nobles : situation à cocher.
    expect(
      f.bonusTestsSituationnels.any((s) =>
          s.effet.carac == Carac.soc && s.effet.condition.contains('nobles')),
      isTrue,
    );
  });

  test('rang 3 : trait II ; rang 4 : +1 AdC et +1 DMG ; rang 5 : critique', () {
    final r3 = _fiche(rang: 3);
    expect(_textes(r3).any((t) => t.contains('relancer un jet de dégâts')),
        isTrue);
    expect(_textes(r3).any((t) => t.contains('+1d6 DMG sur un critique')),
        isFalse);
    expect(_toucherFamiliale(r3), 1);

    final r4 = _fiche(rang: 4);
    expect(_toucherFamiliale(r4), 2);
    final arme = r4.personnage.inventaire.single;
    // +1 (lignée guerrière) et +1 (Droit du sang).
    expect(
      r4.desEnPlus(arme).where((s) => s.effet.valeur == '1'),
      hasLength(2),
    );

    final r5 = _fiche(rang: 5);
    expect(r5.seuilCritique(distance: false),
        (seuil: 19, origine: 'Titre de noblesse'));
    expect(
        _textes(r5).any((t) => t.contains('+1d6 DMG sur un critique')), isTrue);
    // Pas d'effet à distance, ni sans l'arme en main.
    expect(r5.seuilCritique(distance: true).seuil, 20);
    expect(_fiche(rang: 5, equipee: false).seuilCritique(distance: false).seuil,
        20);
    expect(_toucherFamiliale(_fiche(rang: 5, equipee: false)), 0);
  });

  test('traits : héritage élémentaire, serment de vengeance', () {
    // Feu : +1d4 DMG dès le rang 3.
    final feu2 = _fiche(rang: 2, trait: 'feu');
    final feu3 = _fiche(rang: 3, trait: 'feu');
    final arme = feu3.personnage.inventaire.single;
    expect(
        feu2
            .desEnPlus(feu2.personnage.inventaire.single)
            .any((s) => s.effet.valeur == '1d4'),
        isFalse);
    expect(feu3.desEnPlus(arme).any((s) => s.effet.valeur == '1d4'), isTrue);
    // Vengeance : +1 AdC jusqu'au rang 2, puis +2 (pas de cumul).
    int vengeance(FicheCalculee f) => f.bonusTestsSituationnels
        .where((s) => s.nom == 'Arme familiale' && s.effet.carac == Carac.adc)
        .fold(0, (n, s) => n + (s.effet.valeurEntiere ?? 0));
    expect(vengeance(_fiche(rang: 2, trait: 'vengeance')), 1);
    expect(vengeance(_fiche(rang: 3, trait: 'vengeance')), 2);
  });

  test('libellés : rang qui débloque, critique, {precision:cle}', () {
    expect(
      const Effet(type: 'texte', texte: 'Parade', rangMin: 3).libelle,
      'Parade (dès le rang 3)',
    );
    expect(
      const Effet(type: 'critique', valeur: '19', condition: 'Épée').libelle,
      'Critique sur 19-20 avec : Épée',
    );
    expect(
      const Effet(type: 'toucher', condition: '{precision:a}')
          .avecPrecisions({'a': 'Hache'}).condition,
      'Hache',
    );
  });

  test('critique sur 19-20 : un 19 naturel est une réussite critique', () {
    ResultatLancer r(int seuil) => ResultatLancer(
          libelle: 'Toucher CaC',
          formule: '1d20',
          des: const [19],
          garde: 19,
          d20: true,
          seuilCritique: seuil,
        );
    expect(r(20).reussiteCritique, isFalse);
    expect(r(19).reussiteCritique, isTrue);
  });

  testWidgets('page dé : toucher CaC « critique 19-20 » au rang 5',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = PersonnagesController(
        EnMemoirePersonnageRepository([_personnage(rang: 5)]));
    await controller.charger();
    await tester.pumpWidget(MaterialApp(
      home: DeScreen(
        referentiel: Referentiel(races: [_humain], classes: _classes),
        personnages: controller,
        preferences: PreferencesController(personnageActifId: 'c'),
      ),
    ));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('jet-toucher-cac')),
        matching: find.text('critique 19-20'),
      ),
      findsOneWidget,
    );
    expect(find.text('critique 19-20'), findsOneWidget);
  });

  test('Garde du roi : +1 CA CaC (esquive) avec l\'arme familiale en main', () {
    final base = _fiche(rang: 2, trait: 'guerriere').caCac;
    expect(_fiche(rang: 2, trait: 'garde').caCac, base + 1);
    expect(_fiche(rang: 2, trait: 'garde', equipee: false).caCac, base);
    expect(_fiche(rang: 2, trait: 'garde').bonusCACompetences,
        _fiche(rang: 2).bonusCACompetences);
  });

  test('rang 1 · Éducation : +1 par rang aux tests de la connaissance', () {
    FicheCalculee.savoirs = const {'faune': 'Faune', 'flore': 'Flore'};
    final aptitudes =
        (jsonDecode(File('assets/data/aptitudes.json').readAsStringSync())
                as List)
            .map((e) => Aptitude.depuisJson(e as Map<String, dynamic>))
            .toList();
    JetSavoir faune(int rang) => jetsSavoirs(
          _fiche(
            rang: rang,
            choix: {'education': 'savoir'},
            precisions: {'education': 'Faune'},
          ),
          aptitudes,
          FamilleAptitude.savoir,
        ).firstWhere((j) => j.libelle == 'Faune');
    expect(faune(1).bonus.single, (nom: 'Éducation', valeur: 1));
    expect(faune(3).total, 3); // non maîtrisé (0) + 3 (rang 3)
    expect(faune(3).mention, contains('+3 Éducation'));
    // Liste « Quelle connaissance ? » : les savoirs du jeu.
    expect(
      _fiche(rang: 1)
          .elementsChoix('savoirs', cle: 'education')
          .map((e) => e.nom),
      ['Faune', 'Flore'],
    );
  });

  test('rang 3 · Écuyer : 3 propositions, compagnon, +1 CA', () {
    final a = propositionsEcuyer('c');
    expect(a, hasLength(3));
    expect(a.map((e) => e.nom).toSet(), hasLength(3));
    // Toujours les mêmes pour le même personnage.
    expect(propositionsEcuyer('c').map((e) => e.texte), a.map((e) => e.texte));
    expect(a.first.description, contains('ans'));
    expect(lireEcuyer(a.first.texte).nom, a.first.nom);

    final sans = _fiche(rang: 3);
    final avec = _fiche(
      rang: 3,
      choix: {'ecuyer': 'ecuyer'},
      precisions: {'ecuyer': a[1].texte},
    );
    expect(sans.elementsChoix('ecuyers', cle: 'ecuyer').map((e) => e.nom),
        a.map((e) => e.texte));
    // Armure entretenue : +1 CA dès le rang 3.
    expect(_fiche(rang: 3).bonusCACompetences,
        _fiche(rang: 2).bonusCACompetences + 1);
    // L'écuyer choisi rejoint l'inventaire comme compagnon.
    final objet = avec.objetsARecevoir
        .firstWhere((o) => o.objet['categorie'] == 'compagnon')
        .objet;
    expect(objet['nom'], 'Écuyer · ${a[1].nom}');
    expect(objet['description'], startsWith(a[1].description));
    final p = avec.personnage;
    ObjetsDonnes.recevoir(avec);
    final compagnon =
        p.inventaire.firstWhere((o) => o.categorie == CategorieObjet.compagnon);
    expect(compagnon.nom, 'Écuyer · ${a[1].nom}');
    expect(compagnon.categorie.equipable, isFalse);
  });

  test('rang 4 · Droit du sang : RANG utilisations du titre par aventure', () {
    final r4 = _fiche(rang: 4);
    expect(r4.usages.single.nom, 'Faire jouer son titre');
    expect(r4.usages.single.max, 4);
    expect(r4.usages.single.periode, 'par aventure');
    expect(_fiche(rang: 5).usages.single.max, 5);
    r4.personnage.utilisations['Faire jouer son titre'] = 3;
    expect(r4.usages.single.restants, 1);
    // Sauvegardé avec le personnage.
    final relu = Personnage.depuisJson(r4.personnage.versJson());
    expect(relu.utilisations, {'Faire jouer son titre': 3});
    // +3 SOC face aux autorités : situation à cocher.
    expect(
      r4.bonusTestsSituationnels.any((s) =>
          s.effet.condition == 'face aux autorités' &&
          s.effet.valeurEntiere == 3),
      isTrue,
    );
  });

  test('rang 5 · Titre de noblesse : INT et SOC, titre selon le sexe', () {
    final r4 = _fiche(rang: 4);
    final r5 = _fiche(rang: 5, choix: {'titre-noblesse': 'baron'});
    expect(r5.carac(Carac.intel), r4.carac(Carac.intel) + 2);
    expect(r5.carac(Carac.soc), r4.carac(Carac.soc) + 2);
    expect(r5.titres, ['Baron']);
    expect(
      _fiche(rang: 5, choix: {'titre-noblesse': 'duc'}, sexe: Sexe.femme)
          .titres,
      ['Duchesse'],
    );
    expect(
      _fiche(rang: 5, choix: {'titre-noblesse': 'comte'}, sexe: Sexe.homme)
          .titres,
      ['Comte'],
    );
    expect(
      r5.bonusTestsSituationnels
          .any((s) => s.effet.carac == Carac.soc && s.effet.valeurEntiere == 5),
      isTrue,
    );
    expect(const Effet(type: 'titre', valeur: 'Duc|Duchesse').libelle,
        'Titre : Duc / Duchesse');
  });

  testWidgets('page dé : utiliser son titre, puis nouvelle aventure',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = _personnage(rang: 4);
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(MaterialApp(
      home: DeScreen(
        referentiel: Referentiel(races: [_humain], classes: _classes),
        personnages: controller,
        preferences: PreferencesController(personnageActifId: 'c'),
      ),
    ));
    await tester.pumpAndSettle();
    final bouton = find.byKey(const Key('usage-Faire jouer son titre'));
    expect(find.descendant(of: bouton, matching: find.text('4 / 4')), findsOne);
    await tester.tap(bouton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmer-usage')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: bouton, matching: find.text('3 / 4')), findsOne);
    expect(controller.personnages.single.utilisations,
        {'Faire jouer son titre': 1});
    await tester.tap(find.byKey(const Key('nouvelle-aventure')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: bouton, matching: find.text('4 / 4')), findsOne);
  });

  testWidgets('choix de l\'écuyer : trois cartes, une retenue', (tester) async {
    final c = _chevalier.voies.first.competence(3)!.choix!;
    var valeur = '';
    var precision = '';
    final f = _fiche(rang: 3);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: CarteChoix(
              nom: 'Écuyer',
              choix: c,
              valeur: valeur,
              precision: precision,
              onChoisir: (v) => setState(() => valeur = v),
              onPrecision: (t) => setState(() => precision = t),
              elements: (liste) => f.elementsChoix(liste, cle: c.cle),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('proposition-ecuyer-2')), findsOneWidget);
    await tester.tap(find.byKey(const Key('proposition-ecuyer-1')));
    await tester.pumpAndSettle();
    expect(valeur, 'ecuyer');
    expect(precision, propositionsEcuyer('c')[1].texte);
    expect(
      find.descendant(
        of: find.byKey(const Key('proposition-ecuyer-1')),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('proposition-ecuyer-0')),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsNothing,
    );
  });
}
