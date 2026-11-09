import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/butin.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/equipement.dart';
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/inventaire.dart';
import 'package:odyssee_vagabonds/regles/maitrises.dart';
import 'package:odyssee_vagabonds/screens/creation/etape_recapitulatif.dart';
import 'package:odyssee_vagabonds/screens/fiche/onglet_inventaire.dart';
import 'package:odyssee_vagabonds/widgets/maitrises_restrictions.dart';

/// Maîtrises d'armes, restrictions et inventaire de base (07/11/2026), avec
/// les vraies données du jeu.

List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

void main() {
  final races = [
    for (final e in _json('races.json'))
      Race.depuisJson(e as Map<String, dynamic>),
  ];
  final classes = [
    for (final e in _json('classes.json'))
      Classe.depuisJson(e as Map<String, dynamic>),
  ];
  final catalogue = Referentiel.enregistrerGroupesArmes([
    for (final e in _json('equipements.json'))
      Equipement.depuisJson(e as Map<String, dynamic>),
  ]);

  Objet objet(String id) => ObjetDuCatalogue.depuis(
        catalogue.firstWhere((e) => e.id == id),
      );

  FicheCalculee fiche(
    String race,
    String classe, {
    List<Objet> objets = const [],
    String? origine,
  }) =>
      FicheCalculee(
        personnage: Personnage(
          id: 'p',
          nom: 'Test',
          raceId: race,
          classeId: classe,
          origineId: origine,
        )..inventaire.addAll(objets),
        race: races.firstWhere((r) => r.id == race),
        classe: classes.firstWhere((c) => c.id == classe),
      );

  test('données : toutes les classes et races ont leurs maîtrises', () {
    expect(classes, hasLength(12));
    for (final c in classes) {
      expect(c.maitrisesArmes, contains('civile'), reason: c.id);
      for (final b in c.inventaireBase) {
        expect(catalogue.map((e) => e.id), contains(b.id), reason: c.id);
      }
    }
    for (final r in races) {
      expect(r.maitrisesArmes, isNotEmpty, reason: r.id);
    }
  });

  test('catalogue : armes et armures ajoutées le 07/11/2026', () {
    // Lance : une ou deux mains ; arbalète : distance, deux mains.
    final lance = objet('lance');
    expect((lance.polyvalente, lance.degats, lance.degatsDeuxMains),
        (true, '1d6', '1d8'));
    final arbalete = objet('arbalete-lourde');
    expect((arbalete.distance, arbalete.deuxMains), (true, true));
    expect(objet('tromblon').groupeArme, 'poudre');
    expect(objet('dague').groupeArme, 'civile');
    // Gnome : pas d'arme au-delà du d8, mais le 2d6 reste permis.
    final gnome = fiche('gnome', 'guerrier');
    expect(gnome.refusRestriction(objet('hallebarde')), isNotNull);
    expect(gnome.refusRestriction(objet('epee-a-deux-mains')), isNull);
    // Armures : la matelassée est du tissu, la demi-plaque est lourde ; les
    // casques (heaume) ne sont pas soumis aux limites d'armure.
    final magicien = fiche('humain', 'magicien');
    expect(magicien.refusRestriction(objet('armure-matelassee')), isNull);
    expect(magicien.refusRestriction(objet('demi-plaque')), isNotNull);
    expect(magicien.refusRestriction(objet('heaume')), isNull);
    final ecailles = objet('armure-ecailles');
    expect((ecailles.bonusCA, ecailles.dexMax), (4, 1));
    expect(objet('pavois').categorie, CategorieObjet.bouclier);
  });

  test('catalogue : rapière et objets de marchand', () {
    final rapiere = objet('rapiere');
    expect((rapiere.groupeArme, rapiere.degats, rapiere.deuxMains),
        ('commune-melee', '1d6', false));
    // Lanterne : objet divers, ne s'équipe pas ; ses propriétés (sauf le
    // prix) sont lisibles dans la description.
    final lanterne = objet('lanterne');
    expect(lanterne.categorie, CategorieObjet.divers);
    expect(lanterne.categorie.equipable, isFalse);
    expect(lanterne.description, contains('Lumière : 10 m'));
    expect(lanterne.description, isNot(contains('Prix')));
    expect(objet('torche').categorie, CategorieObjet.consommable);
    expect(objet('fleches').categorie, CategorieObjet.consommable);
    expect(objet('symbole-sacre').categorie, CategorieObjet.divers);
  });

  test('arme non maîtrisée : −5 au toucher ; maîtrisée : rien', () {
    final epee = objet('epee-longue')..equipe = true;
    final magicien = fiche('demi-orque', 'magicien');
    // Le demi-orque maîtrise les armes communes de mêlée.
    expect(magicien.armeMaitrisee(epee), isTrue);
    final gnome = fiche('gnome', 'magicien', objets: [objet('mousquet')]);
    expect(gnome.armeMaitrisee(gnome.personnage.inventaire.first), isFalse);

    final sans = fiche('humain', 'magicien');
    final avec = fiche(
      'humain',
      'magicien',
      objets: [objet('mousquet')..equipe = true],
    );
    expect(avec.toucherDistance, sans.toucherDistance + kMalusArmeNonMaitrisee);
    expect(
      avec.bonusToucher(distance: true).map((b) => b.nom),
      contains('Arme non maîtrisée'),
    );
    // Au corps à corps, l'arme à distance ne change rien.
    expect(avec.toucherCac, sans.toucherCac);
  });

  test('groupes : civiles, communes, poudre et mots', () {
    final ingenieur = fiche('gnome', 'ingenieur');
    expect(ingenieur.armeMaitrisee(objet('mousquet')), isTrue);
    final barde = fiche('gnome', 'barde');
    // « 1 main communes » : pas l'arc, à deux mains.
    expect(barde.armeMaitrisee(objet('arc-court')), isFalse);
    expect(barde.armeMaitrisee(objet('epee-longue')), isTrue);
    // « arc » ne se confond pas avec la lance d'arçon.
    final sylvain = fiche('elfe-sylvain', 'magicien');
    expect(sylvain.armeMaitrisee(objet('arc-long')), isTrue);
    final hautElfe = fiche('haut-elfe', 'magicien');
    expect(hautElfe.armeMaitrisee(objet('lance-arcon')), isFalse);
    // Arc du demi-elfe : seulement par une origine elfique.
    expect(
      fiche('demi-elfe', 'magicien', origine: 'haut-elfe')
          .armeMaitrisee(objet('arc-long')),
      isTrue,
    );
    expect(
      fiche('demi-elfe', 'magicien', origine: 'humaine')
          .armeMaitrisee(objet('arc-long')),
      isFalse,
    );
  });

  test('maîtrise d\'une compétence : le savoir-faire est maîtrisé', () {
    final barbare = classes.firstWhere((c) => c.id == 'barbare');
    final voie = barbare.voies.firstWhere(
      (v) => v.competences.any(
        (k) => k.effets.any((e) => e.valeur == 'Escalade'),
      ),
    );
    final competence = voie.competences.firstWhere(
      (k) => k.effets.any((e) => e.valeur == 'Escalade'),
    );
    final f = fiche('humain', 'barbare');
    expect(f.savoirsMaitrises, isNot(contains('escalade')));
    f.personnage.rangsVoies[voie.id] = competence.rang;
    expect(f.savoirsMaitrises, contains('escalade'));
  });

  test('inventaire de base : chaque kit respecte sa classe', () {
    for (final c in classes) {
      final objets = ObjetDuCatalogue.inventaireBase(c, catalogue);
      expect(objets, hasLength(c.inventaireBase.length), reason: c.id);
      expect(
        objets.where((o) => o.categorie == CategorieObjet.arme),
        isNotEmpty,
        reason: c.id,
      );
      // Sans race : seules les maîtrises et limites de la classe comptent.
      final f = FicheCalculee(
        personnage: Personnage(id: 'p', nom: 'T', raceId: 'r', classeId: c.id),
        race: const Race(id: 'r', nom: 'R', deVie: 8, deMana: 4),
        classe: c,
      );
      for (final o in objets) {
        expect(f.refusRestriction(o), isNull, reason: '${c.id} ${o.nom}');
        expect(f.armeMaitrisee(o), isTrue, reason: '${c.id} ${o.nom}');
      }
    }
  });

  test('arme personnalisée : aucun malus', () {
    final o = Objet(nom: 'Fouet maudit', categorie: CategorieObjet.arme);
    expect(fiche('gnome', 'magicien').armeMaitrisee(o), isTrue);
  });

  test('ancienne fiche : groupe retrouvé par le nom', () {
    final o = Objet(nom: 'Mousquet', categorie: CategorieObjet.arme);
    expect(fiche('gnome', 'magicien').armeMaitrisee(o), isFalse);
  });

  test('restrictions d\'armure : classe et race', () {
    final plaques = objet('armure-plaques');
    final cotte = objet('cotte-de-mailles');
    final cuir = objet('armure-cuir');
    expect(fiche('humain', 'guerrier').refusRestriction(plaques), isNull);
    expect(fiche('humain', 'barbare').refusRestriction(plaques), isNotNull);
    expect(fiche('humain', 'barbare').refusRestriction(cotte), isNull);
    expect(fiche('humain', 'magicien').refusRestriction(cotte), isNotNull);
    expect(fiche('humain', 'magicien').refusRestriction(cuir), isNull);
    expect(fiche('humain', 'pretre').refusRestriction(cotte), isNull);
    expect(fiche('haut-elfe', 'guerrier').refusRestriction(plaques), isNotNull);
    // Plaques ajustées du gnome : permises.
    final ajustees = Objet(
      nom: 'Plaques ajustées',
      categorie: CategorieObjet.armure,
      poidsArmure: PoidsArmure.lourde,
    );
    expect(fiche('gnome', 'guerrier').refusRestriction(plaques), isNotNull);
    expect(fiche('gnome', 'guerrier').refusRestriction(ajustees), isNull);
  });

  test('restrictions d\'armes de race : nain, gnome, haut-elfe', () {
    expect(fiche('nain', 'guerrier').refusRestriction(objet('arc-long')),
        isNotNull);
    expect(
        fiche('nain', 'guerrier').refusRestriction(objet('arc-court')), isNull);
    final gnome = fiche('gnome', 'guerrier');
    expect(gnome.refusRestriction(objet('petoire')), isNotNull); // 1d10
    expect(gnome.refusRestriction(objet('canon-a-mains')), isNotNull);
    expect(gnome.refusRestriction(objet('mousquet')), isNull); // 2d6
    expect(gnome.refusRestriction(objet('baton')), isNull);

    final elfe = fiche(
      'haut-elfe',
      'ingenieur',
      objets: [objet('mousquet')..equipe = true],
    );
    final sans = fiche('haut-elfe', 'ingenieur');
    expect(elfe.toucherDistance, sans.toucherDistance - 2);
  });

  test('inventaire de base : ids du catalogue, quantités, ids inconnus', () {
    final c = Classe.depuisJson({
      'id': 'x',
      'nom': 'X',
      'inventaireBase': [
        'baton',
        {'id': 'potion-fer', 'quantite': 2},
        'inconnu',
      ],
    });
    final objets = ObjetDuCatalogue.inventaireBase(c, catalogue);
    expect(objets.map((o) => o.nom), ['Bâton', 'Potion de fer']);
    expect(objets.last.quantite, 2);
  });

  test('butin : une partie d\'une pile', () {
    final o = Objet(nom: 'Flèche', quantite: 10);
    final b = ButinSeance(nom: 'Carquois', objets: [o]);
    final pris = b.prendre(objetId: o.id, quantite: 3);
    expect(pris.objet!.quantite, 3);
    expect(pris.objet!.id, isNot(o.id));
    expect(pris.reste.objets.single.quantite, 7);
    expect(pris.reste.objets.single.id, o.id);
    expect(o.quantite, 10);
    expect(b.prendre(objetId: o.id).reste.objets, isEmpty);
  });

  testWidgets('inventaire : objet interdit refusé, arme non maîtrisée signalée',
      (tester) async {
    final plaques = objet('armure-plaques');
    final mousquet = objet('mousquet');
    final f = fiche('humain', 'magicien', objets: [plaques, mousquet]);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OngletInventaire(
          personnage: f.personnage,
          onModifie: () async {},
          refusRestriction: f.refusRestriction,
          alerteObjet: (o) => f.armeMaitrisee(o) ? null : 'Non maîtrisée',
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('alerte-objet-${mousquet.id}')), findsOneWidget);
    await tester.tap(find.byKey(Key('equiper-${plaques.id}')));
    await tester.pump();
    expect(plaques.equipe, isFalse);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  group('affichage', () {
    Future<void> afficher(WidgetTester tester, Widget w) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: w)));
      await tester.pumpAndSettle();
    }

    testWidgets('classe : armes, armure, survol des armes du groupe',
        (tester) async {
      await afficher(
        tester,
        MaitrisesRestrictions(
          classe: classes.firstWhere((c) => c.id == 'magicien'),
        ),
      );
      expect(find.text('Civiles'), findsOneWidget);
      expect(find.text('Armures légères maximum'), findsOneWidget);
      expect(find.byKey(const Key('groupe-interdits')), findsNothing);
      final survol = tester.widget<Tooltip>(find.byType(Tooltip).first);
      expect(survol.message, contains('Bâton'));
    });

    testWidgets('race : interdits, malus, précisions', (tester) async {
      await afficher(
        tester,
        MaitrisesRestrictions(race: races.firstWhere((r) => r.id == 'gnome')),
      );
      expect(find.text('Armes au-delà du d8 (2d6 permis)'), findsOneWidget);
      expect(find.byKey(const Key('note-restrictions')), findsOneWidget);
      await afficher(
        tester,
        MaitrisesRestrictions(
          race: races.firstWhere((r) => r.id == 'haut-elfe'),
        ),
      );
      expect(find.text('Armes à poudre : −2 au toucher'), findsOneWidget);
    });

    testWidgets('race à origines : l\'arc selon l\'origine', (tester) async {
      await afficher(
        tester,
        MaitrisesRestrictions(
          race: races.firstWhere((r) => r.id == 'demi-elfe'),
        ),
      );
      expect(find.text('Arc (selon l\'origine)'), findsOneWidget);
    });

    testWidgets('fiche : classe et race réunies, limite la plus stricte',
        (tester) async {
      final f = fiche('haut-elfe', 'magicien');
      await afficher(
        tester,
        MaitrisesRestrictions(
          classe: f.classe,
          race: f.race,
          origineId: '',
          armesEnPlus: const ['Mousquet'],
        ),
      );
      expect(find.text('Civiles'), findsOneWidget);
      expect(find.text('Mousquet'), findsOneWidget);
      expect(find.text('Armures légères maximum'), findsOneWidget);
    });
  });

  testWidgets('récapitulatif : l\'inventaire de base se refuse',
      (tester) async {
    bool? choix;
    final f = fiche('humain', 'guerrier');
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EtapeRecapitulatif(
          fiche: f,
          competences: const [],
          inventaireBase: [objet('baton')],
          onInventaire: (v) => choix = v,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inventaire-base')));
    expect(choix, isFalse);
  });
}
