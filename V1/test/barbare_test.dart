import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/equipement.dart';
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/inventaire.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';
import 'package:odyssee_vagabonds/widgets/resume_fiche.dart';

/// Barbare (classes_2, 24/10/2026) : Brutalité, Style barbaresque,
/// Armement barbare, Moulinet, Légèreté animale, Assaut, rage, Frénésie.

final _barbare =
    (jsonDecode(File('assets/data/classes.json').readAsStringSync()) as List)
        .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
        .firstWhere((c) => c.id == 'barbare');

final _humain =
    (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
        .map((e) => Race.depuisJson(e as Map<String, dynamic>))
        .firstWhere((r) => r.id == 'humain');

Objet _arme(String nom, {bool deuxMains = false, bool equipe = true}) => Objet(
      nom: nom,
      categorie: CategorieObjet.arme,
      degats: '1d10',
      deuxMains: deuxMains,
      equipe: equipe,
    );

FicheCalculee _fiche({
  int niveau = 9,
  Map<String, int> rangs = const {},
  List<Objet> inventaire = const [],
  Set<String> etats = const {},
}) =>
    FicheCalculee(
      personnage: Personnage(
        id: 'b',
        nom: 'Grom',
        raceId: 'humain',
        classeId: 'barbare',
        niveau: niveau,
        rangsVoies: Map.of(rangs),
        inventaire: List.of(inventaire),
        etats: Set.of(etats),
        caracBase: {for (final c in Carac.values) c: 12}
          ..[Carac.force] = 16
          ..[Carac.con] = 14,
      ),
      race: _humain,
      classe: _barbare,
    );

void main() {
  testsDeplacement();
  testsPageDeBerzerker();

  test('données : JSON corrigé, 4 voies de 5 rangs', () {
    expect(_barbare.voies.map((v) => v.competences.length), [5, 5, 5, 5]);
    final athlete = _barbare.voies[1];
    expect(athlete.competence(4)!.nom, 'Moulinet (niveau 2)');
  });

  test('Brutalité : arme à 2 mains requise, +2×RANG aux dégâts', () {
    final sans =
        _fiche(rangs: {'barbare-brute': 3}, inventaire: [_arme('Épée')]);
    final j = sans.jetsCompetences.firstWhere((j) => j.libelle == 'Brutalité');
    expect(j.attaque!.deuxMains, isTrue);
    expect(j.attaque!.degatsEnPlus, '6'); // 2 × rang 3
    expect(sans.armeAttaque(j.attaque!), isNull);
    final avec = _fiche(
      rangs: {'barbare-brute': 3},
      inventaire: [_arme('Espadon', deuxMains: true)],
    );
    expect(avec.armeAttaque(j.attaque!)!.nom, 'Espadon');
    expect(FicheCalculee.evaluerRang('2×RANG', 4), '8');
    expect(FicheCalculee.evaluerRang('1d6', 4), '1d6');
  });

  test('Style barbaresque : mod FOR à tous les tests de MEN', () {
    final f = _fiche(rangs: {'barbare-brute': 3});
    final cha =
        f.bonusTestsPermanents.firstWhere((s) => s.nom == 'Style barbaresque');
    expect(cha.effet.carac, Carac.men);
    expect(cha.effet.valeurEntiere, f.mod(Carac.force));
  });

  test('Armement barbare : deux armes à 2 mains, principale d20 / d12', () {
    final a = _arme('Hache', deuxMains: true);
    final b = _arme('Marteau', deuxMains: true, equipe: false);
    final inventaire = [a, b];
    // Sans la compétence : refusé (mains)
    expect(ReglesInventaire.refusEquipement(inventaire, b), isNotNull);
    expect(
      ReglesInventaire.refusEquipement(inventaire, b, deuxArmesDeuxMains: true),
      isNull,
    );
    b.equipe = true;
    // Un bouclier en plus : refusé
    final bouclier = Objet(nom: 'Pavois', categorie: CategorieObjet.bouclier);
    expect(
      ReglesInventaire.refusEquipement([...inventaire, bouclier], bouclier,
          deuxArmesDeuxMains: true),
      isNotNull,
    );
    final f = _fiche(rangs: {'barbare-brute': 4}, inventaire: inventaire);
    expect(f.deuxArmesDeuxMains, isTrue);
    expect(f.armesDoubles!.principale.nom, 'Hache');
    f.personnage.inventaire.last.principale = true;
    expect(f.armesDoubles!.principale.nom, 'Marteau');
    expect(f.armesDoubles!.secondaire.nom, 'Hache');
    expect(
      ReglesInventaire.mainsDepassees(f.personnage.inventaire,
          deuxArmesDeuxMains: true),
      isFalse,
    );
  });

  test('Légèreté animale : CA + RANG en armure légère ou sans armure', () {
    int ca(List<Objet> inv) =>
        _fiche(rangs: {'barbare-sauvage': 3}, inventaire: inv)
            .bonusCACompetences;
    expect(ca(const []), 3);
    final legere = Objet(
      nom: 'Cuir',
      categorie: CategorieObjet.armure,
      equipe: true,
      poidsArmure: PoidsArmure.legere,
    );
    expect(ca([legere]), 3);
    final lourde = Objet(
      nom: 'Cotte',
      categorie: CategorieObjet.armure,
      equipe: true,
      poidsArmure: PoidsArmure.lourde,
    );
    expect(ca([lourde]), 0);
  });

  test('poids d\'armure repris du catalogue', () {
    final catalogue = [
      for (final e in jsonDecode(
        File('assets/data/equipements.json').readAsStringSync(),
      ) as List)
        Equipement.depuisJson(e as Map<String, dynamic>),
    ];
    Objet objet(String nom) =>
        ObjetDuCatalogue.depuis(catalogue.firstWhere((e) => e.nom == nom));
    expect(objet('Vêtement en tissu').poidsArmure, PoidsArmure.legere);
    expect(objet('Bikini de plaque').poidsArmure, PoidsArmure.lourde);
    final o = objet('Vêtement en tissu');
    expect(
      Objet.depuisJson(o.versJson()).poidsArmure,
      PoidsArmure.legere,
    );
  });

  test('Assaut : bélier et échelle à fabriquer', () {
    final f = _fiche(rangs: {'barbare-sauvage': 3});
    expect(f.fabrications.map((x) => x.objet['nom']),
        ['Bélier en tronc', 'Échelle basique']);
  });

  test('rage : +1d6 DM, −2 attaque, −3 CA ; niveau 3 : +1d10 sans malus', () {
    final epee = _arme('Épée');
    final calme = _fiche(
      niveau: 1,
      rangs: {'barbare-berzerker': 1},
      inventaire: [epee],
    );
    expect(calme.etatsPossibles.single.etat.nom, 'Rage berzerker');
    final rage = _fiche(
      niveau: 1,
      rangs: {'barbare-berzerker': 1},
      inventaire: [epee],
      etats: {'Rage berzerker'},
    );
    expect(rage.detailDegatsCac.des(rage.personnage.inventaire.single),
        '1d10 + 1d6');
    expect(rage.toucherCac, calme.toucherCac - 2);
    expect(rage.bonusCACompetences, -3);
    // Mains nues aussi
    final mainsNues = _fiche(
      niveau: 1,
      rangs: {'barbare-berzerker': 1},
      etats: {'Rage berzerker'},
    );
    expect(mainsNues.detailDegatsCac.desMainsNuesAvec, '1d4 + 1d6');
    // Niveau 3 (rang 5) : remplace le niveau 1, plus de malus d'attaque
    final maitrisee = _fiche(
      rangs: {'barbare-berzerker': 5},
      inventaire: [_arme('Épée')],
      etats: {'Rage berzerker'},
    );
    expect(maitrisee.etatsPossibles, hasLength(1));
    expect(
      maitrisee.detailDegatsCac.des(maitrisee.personnage.inventaire.single),
      '1d10 + 1d10',
    );
    expect(maitrisee.bonusToucher(distance: false), isEmpty);
    final sortir = maitrisee.jetsCompetences
        .firstWhere((j) => j.libelle == 'Sortir de la rage');
    expect(sortir.difficulte, 10);
    expect(sortir.finEtat, 'Rage berzerker');
    final duree = maitrisee.jetsCompetences
        .firstWhere((j) => j.libelle == 'Durée de la rage (tours)');
    expect(duree.des, '1d6');
    expect(duree.bonus, maitrisee.mod(Carac.force) + maitrisee.mod(Carac.con));
    expect(duree.libelleCaracs, 'FOR + CON');
  });

  test('Frénésie : niveau 1 puis Déchaînement', () {
    final n1 = _fiche(rangs: {'barbare-berzerker': 2});
    final f1 = n1.jetsCompetences.firstWhere((j) => j.libelle == 'Frénésie');
    expect(f1.attaque!.degatsEnPlus, '1d6');
    expect(f1.attaque!.explosion, 1);
    final n2 = _fiche(rangs: {'barbare-berzerker': 4});
    final f2 = n2.jetsCompetences.firstWhere((j) => j.libelle == 'Frénésie');
    expect(f2.attaque!.degatsArme, '1d6');
    expect(f2.attaque!.explosion, 99);
    expect(f2.attaque!.degatsEnPlus, '1d6');
  });

  testWidgets('page dé : Brutalité grisée sans arme à 2 mains ; Moulinet',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = Personnage(
      id: 'b',
      nom: 'Grom',
      raceId: 'humain',
      classeId: 'barbare',
      niveau: 3,
      rangsVoies: {'barbare-brute': 2, 'barbare-athlete': 2},
      inventaire: [_arme('Épée')],
    );
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    Future<void> afficher() async {
      await tester.pumpWidget(
        MaterialApp(
          home: DeScreen(
            referentiel: Referentiel(races: [_humain], classes: [_barbare]),
            personnages: controller,
            preferences: PreferencesController(personnageActifId: 'b'),
            aleatoire: Random(4),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await afficher();
    Finder bouton(String libelle) => find.ancestor(
          of: find.text(libelle),
          matching: find.byType(OutlinedButton),
        );
    expect(find.text('arme à 2 mains requise'), findsNWidgets(2));
    expect(
      tester.widget<OutlinedButton>(bouton('Brutalité')).onPressed,
      isNull,
    );

    // Arme à 2 mains équipée : Brutalité lance attaque puis dégâts (+4)
    p.inventaire
      ..clear()
      ..add(_arme('Espadon', deuxMains: true));
    await afficher();
    await tester.ensureVisible(bouton('Brutalité'));
    await tester.tap(bouton('Brutalité'));
    await tester.pumpAndSettle();
    // Attaque seule : les dégâts se lancent à part
    expect(p.historique.map((e) => e.message),
        isNot(contains(startsWith('Lancer · Brutalité · dégâts'))));
    await tester.ensureVisible(bouton('Dégâts · Brutalité'));
    await tester.tap(bouton('Dégâts · Brutalité'));
    await tester.pumpAndSettle();
    final messages = p.historique.map((e) => e.message).toList();
    expect(messages, contains(startsWith('Lancer · Brutalité · attaque')));
    expect(messages, contains(startsWith('Lancer · Brutalité · dégâts')));
    expect(
      messages.firstWhere((m) => m.contains('Brutalité · dégâts')),
      contains('+4 (Brutalité)'),
    );

    // Moulinet : état activé, cible suivante avec −1 DM, puis Terminer
    await tester.ensureVisible(bouton('Moulinet'));
    await tester.tap(bouton('Moulinet'));
    await tester.pumpAndSettle();
    expect(p.etats, contains('Moulinet (défense réduite)'));
    expect(find.text('Moulinet · cible 2'), findsOneWidget);
    await tester.tap(bouton('Moulinet · cible 2'));
    await tester.pumpAndSettle();
    await tester.tap(bouton('Dégâts · Moulinet (cible 2)'));
    await tester.pumpAndSettle();
    expect(
      p.historique.map((e) => e.message),
      contains(contains('(Cible 2)')),
    );
    await tester.tap(find.textContaining('Terminer moulinet'));
    await tester.pumpAndSettle();
    expect(p.etats, isEmpty);
    expect(find.text('Moulinet · cible 2'), findsNothing);
  });
}

/// Barbare niveau 9 avec toute la voie du berzerker (rage aux 3 niveaux) :
/// un seul bouton d'état sur la page dé (pas de clé en double).
void testsPageDeBerzerker() {
  testWidgets('page dé : un seul bouton « Rage berzerker » (3 niveaux)',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = Personnage(
      id: 'g',
      nom: 'Grodébile',
      raceId: 'humain',
      classeId: 'barbare',
      niveau: 9,
      rangsVoies: {'barbare-berzerker': 5, 'barbare-athlete': 4},
    );
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      MaterialApp(
        home: DeScreen(
          referentiel: Referentiel(races: [_humain], classes: [_barbare]),
          personnages: controller,
          preferences: PreferencesController(personnageActifId: 'g'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('etat-Rage berzerker')), findsOneWidget);
    await tester.tap(find.byKey(const Key('etat-Rage berzerker')));
    await tester.pumpAndSettle();
    expect(p.etats, {'Rage berzerker'});
    expect(tester.takeException(), isNull);
  });
}

void testsDeplacement() {
  test('déplacement : 10 m, +5 m avec Colosse infatigable', () {
    expect(_fiche(rangs: const {}).deplacement, 10);
    final colosse = _fiche(rangs: {'barbare-athlete': 5});
    expect(colosse.deplacement, 15);
    expect(colosse.bonusDeplacement.single.nom, 'Colosse infatigable');
  });

  testWidgets('fiche : case Déplacement', (tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ResumeFiche(fiche: _fiche(rangs: {'barbare-athlete': 5})),
          ),
        ),
      ),
    );
    final c = find.byKey(const Key('stat-deplacement'));
    expect(find.descendant(of: c, matching: find.text('15 m')), findsOneWidget);
    expect(
      find.descendant(
          of: c, matching: find.textContaining('+5 m Colosse infatigable')),
      findsOneWidget,
    );
  });
}
