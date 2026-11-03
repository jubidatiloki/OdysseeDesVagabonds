import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/app.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/equipement.dart';
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/regles/des.dart';
import 'package:odyssee_vagabonds/regles/inventaire.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/widgets/carte_choix.dart';

/// Races réelles (`assets/data/races.json`), options « reference » remplies
/// comme au chargement de l'application.
List<Race> _races() {
  final races =
      (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
          .map((e) => Race.depuisJson(e as Map<String, dynamic>))
          .toList();
  Referentiel.completerReferences(races, const []);
  return races;
}

const _guerrier = Classe(
  id: 'g',
  nom: 'Guerrier',
  modifDeVie: ModifDe.egal,
  modifDeMana: ModifDe.egal,
);

const _mage = Classe(
  id: 'm',
  nom: 'Mage',
  modifDeVie: ModifDe.egal,
  modifDeMana: ModifDe.egal,
  lanceurDeSorts: true,
  profil: ProfilClasse.lanceur,
);

const _barde = Classe(
  id: 'b',
  nom: 'Barde',
  modifDeVie: ModifDe.egal,
  modifDeMana: ModifDe.egal,
  profil: ProfilClasse.hybride,
);

FicheCalculee _fiche(
  Race r, {
  required int niveau,
  String? passif,
  String? origine,
  Map<String, String> choix = const {},
  Classe classe = _guerrier,
}) =>
    FicheCalculee(
      personnage: Personnage(
        id: 'p',
        nom: 'Test',
        raceId: r.id,
        classeId: 'g',
        niveau: niveau,
        optionPassifId: passif,
        origineId: origine,
        caracBase: {for (final c in Carac.values) c: 10}..[Carac.force] = 14,
        choix: Map.of(choix),
      ),
      race: r,
      classe: classe,
    );

void main() {
  testsSangMelePolyglotte();
  final races = _races();
  Race race(String id) => races.firstWhere((r) => r.id == id);

  group('draconien', () {
    test('souffle : élément choisi à la création, repris par Cuir de dragon',
        () {
      final d = race('draconien');
      // Sans élément : à choisir (le souffle le demande dès la création)
      final sans = _fiche(d, niveau: 1, passif: 'souffle');
      expect(sans.choixEnAttente.single.choix.cle, 'element-draconien');

      final f = _fiche(
        d,
        niveau: 3,
        passif: 'souffle',
        choix: {'element-draconien': 'feu'},
      );
      // Cuir de dragon (rang 2) : élément repris automatiquement
      expect(f.choixEnAttente, isEmpty);
      final cuir = f.competencesAcquises
          .firstWhere((c) => c.competence.nom.startsWith('Cuir de dragon'));
      expect(cuir.competence.effet, contains('(Feu)'));

      // Jets : souffle 1D6 + recharge, griffes 1D6 + FOR (14 → +2)
      final jets = {for (final j in f.jetsCompetences) j.libelle: j};
      expect(jets['Souffle élémentaire (Feu)']?.des, '1d6');
      expect(jets['Souffle élémentaire (Feu)']?.recharge, '1d4');
      expect(jets['Griffes et crocs']?.bonus, 2);
      // Rang 3 (niveau 5) pas encore : pas de coup de queue
      expect(jets.containsKey('Coup de queue'), isFalse);
    });

    test('cuir de dragon : RD de son élément, +2 puis +4 (Libération)', () {
      ({String type, int total})? rd(int niveau, String element) {
        final f = _fiche(
          race('draconien'),
          niveau: niveau,
          passif: 'souffle',
          choix: {'element-draconien': element},
        );
        return [for (final r in f.resistances) (type: r.type, total: r.total)]
            .singleOrNull;
      }

      expect(rd(1, 'feu'), isNull);
      expect(rd(3, 'feu'), (type: 'feu', total: 2));
      expect(rd(3, 'glace'), (type: 'glace', total: 2));
      expect(rd(7, 'foudre'), (type: 'foudre', total: 4));
    });

    test('souffle au rang 5 : 2D6, variante du souffle affichée', () {
      final f = _fiche(
        race('draconien'),
        niveau: 9,
        passif: 'souffle',
        choix: {'element-draconien': 'glace'},
      );
      final jets = {for (final j in f.jetsCompetences) j.libelle: j};
      expect(jets['Souffle élémentaire (Glace)']?.des, '2d6');
      expect(jets['Coup de queue']?.des, '1d6');
      expect(jets['Coup de queue']?.bonus, 0);
      final accroissement = f.competencesAcquises
          .firstWhere((c) => c.competence.nom == 'Accroissement draconique');
      expect(accroissement.competence.effet, startsWith('Améliore le souffle'));
    });

    test('ailes : élément choisi au rang 2, vol en déplacement', () {
      final d = race('draconien');
      expect(d.optionPassif('ailes')!.type, 'mouvement');
      // Niveau 1 : rien à choisir
      expect(_fiche(d, niveau: 1, passif: 'ailes').choixEnAttente, isEmpty);
      // Niveau 3 : Cuir de dragon demande l'élément
      final f = _fiche(d, niveau: 3, passif: 'ailes');
      expect(f.choixEnAttente.single.nom, 'Cuir de dragon (niveau 1)');
      // Pas de souffle ; au rang 5, variante des ailes
      final f9 = _fiche(
        d,
        niveau: 9,
        passif: 'ailes',
        choix: {'element-draconien': 'foudre'},
      );
      expect(
        f9.jetsCompetences.where((j) => j.libelle.startsWith('Souffle')),
        isEmpty,
      );
      final accroissement = f9.competencesAcquises
          .firstWhere((c) => c.competence.nom == 'Accroissement draconique');
      expect(accroissement.competence.effet, startsWith('Améliore les ailes'));
    });
  });

  test('demi-elfe : Sang mêlé, compétence de rang 1 au choix', () {
    final de = race('demi-elfe');
    final options = de.voieRaciale!.competence(2)!.choix!.options;
    // Reprises des autres voies raciales au chargement
    expect(options.map((o) => o.id), ['humain', 'elfe-sylvain', 'haut-elfe']);
    expect(options[1].effets, isNotEmpty);

    final sans = _fiche(de, niveau: 3, origine: 'humaine');
    expect(sans.choixEnAttente.single.nom, 'Sang mêlé');

    final f = _fiche(
      de,
      niveau: 3,
      origine: 'humaine',
      choix: {'sang-mele': 'elfe-sylvain'},
    );
    expect(f.choixEnAttente, isEmpty);
    final sang = f.competencesAcquises
        .firstWhere((c) => c.competence.nom == 'Sang mêlé');
    expect(sang.competence.effet, contains('Nature primordiale'));
    // Les bonus de test de l'option choisie comptent
    expect(
      f.bonusTests.map((s) => s.effet.libelle),
      contains('+5 aux tests de INT (Connaissance faune)'),
    );
  });

  test('demi-orque : Chef de guerre, +2 CON et +2 INT ou SOC', () {
    final o = race('demi-orque');
    final sans = _fiche(o, niveau: 9);
    expect(sans.choixEnAttente.single.choix.cle, 'chef-de-guerre');
    expect(sans.bonusEffets(Carac.con), 2);

    final f = _fiche(o, niveau: 9, choix: {'chef-de-guerre': 'INT'});
    expect(f.bonusEffets(Carac.intel), 2);
    expect(f.bonusEffets(Carac.soc), 0);
    expect(f.bonusEffets(Carac.con), 2);
  });

  testWidgets('page dé : souffle lancé avec sa recharge, griffes',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = Personnage(
      id: 'k',
      nom: 'Kael',
      raceId: 'draconien',
      classeId: 'g',
      niveau: 1,
      optionPassifId: 'souffle',
      choix: {'element-draconien': 'feu'},
    );
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      MaterialApp(
        home: DeScreen(
          referentiel: Referentiel(races: races, classes: const [_guerrier]),
          personnages: controller,
          preferences: PreferencesController(
            personnageActifId: 'k',
            // Groupes de la page dé ouverts (cachés par défaut).
            affichages: {
              for (final g in GroupeJets.values) g: AffichageGroupe.visible,
            },
          ),
          aleatoire: Random(5),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final souffle = find.text('Souffle élémentaire (Feu)');
    await tester.ensureVisible(souffle);
    await tester.pumpAndSettle();
    await tester.tap(souffle);
    await tester.pumpAndSettle();
    // Dernier lancer : la recharge (1d4 tours) ; juste avant : les dégâts
    final messages = p.historique.map((e) => e.message).toList();
    expect(messages[messages.length - 2],
        startsWith('Lancer · Souffle élémentaire (Feu) : '));
    expect(messages.last,
        startsWith('Lancer · Recharge (tours) · Souffle élémentaire (Feu) : '));
    final tours = int.parse(
      tester.widget<Text>(find.byKey(const Key('resultat-de'))).data!,
    );
    expect(tours, inInclusiveRange(1, 4));
    expect(find.text('Griffes et crocs'), findsOneWidget);
  });

  group('elfe-sylvain', () {
    test('Équipement naturel : +1d6 aux armes non métalliques, +2 CA', () {
      final e = race('elfe-sylvain');
      final baton = Objet(
        nom: 'Bâton',
        categorie: CategorieObjet.arme,
        degats: '1d6',
        matiere: MatiereObjet.bois,
        equipe: true,
      );
      final epee = Objet(
        nom: 'Épée',
        categorie: CategorieObjet.arme,
        degats: '1d8',
        matiere: MatiereObjet.metal,
        equipe: true,
      );
      final cuir = Objet(
        nom: 'Armure de cuir',
        categorie: CategorieObjet.armure,
        bonusCA: 1,
        matiere: MatiereObjet.cuir,
        equipe: true,
      );
      final f = _fiche(e, niveau: 7);
      f.personnage.inventaire.addAll([baton, epee, cuir]);
      expect(f.bonusCACompetences, 2);
      final cac = f.detailDegatsCac;
      expect(cac.des(baton), '1d6 + 1d6');
      expect(cac.des(epee), '1d8');
      expect(cac.explication, contains('+1d6 (Équipement naturel'));
      // Armure métallique : plus de +2 CA
      cuir.matiere = MatiereObjet.metal;
      expect(f.bonusCACompetences, 0);
      // Avant le rang 4 (niveau 5) : rien
      final f5 = _fiche(e, niveau: 5)..personnage.inventaire.add(baton);
      expect(f5.detailDegatsCac.des(baton), '1d6');
    });

    test('Cri sauvage (difficulté), Amis de la forêt (paliers, avantage)', () {
      final e = race('elfe-sylvain');
      final f5 = _fiche(e, niveau: 5);
      final jets = {for (final j in f5.jetsCompetences) j.libelle: j};
      expect(jets['Cri sauvage']?.difficulte, 10);
      expect(jets['Cri sauvage']?.carac, Carac.soc);
      expect(jets['Amis de la forêt']?.paliers, hasLength(5));
      expect(jets['Amis de la forêt']?.avantage, isFalse);
      // Niveau 1 : 1d20 + mod CON
      expect(jets['Amis de la forêt']?.des, '1d20');
      expect(jets['Amis de la forêt']?.carac, Carac.con);
      // Rang 5 : le même jet passe en avantage
      final f9 = _fiche(e, niveau: 9);
      final amis =
          f9.jetsCompetences.firstWhere((j) => j.libelle == 'Amis de la forêt');
      expect(amis.avantage, isTrue);
      // Niveau 2 : 1d20 + mod CON, avec avantage
      expect(amis.carac, Carac.con);
      expect(amis.paliers.first.des, '1d6');
      // Le renforcement relie bien la compétence de niveau 1
      final niveau1 = e.voieRaciale!.competence(3)!;
      expect(f9.ameliorationDe(niveau1)?.nom, 'Harmonie avec la nature');
    });
  });

  group('haut-elfe', () {
    test('Puits d\'arcane : selon le profil de la classe', () {
      final h = race('haut-elfe');
      List<JetDisponible> puits(Classe c, int niveau) =>
          _fiche(h, niveau: niveau, classe: c)
              .jetsCompetences
              .where((j) => j.libelle.startsWith('Puits'))
              .toList();
      // Lanceur de sorts : RANG d6 PM, sans perte de PV.
      final lanceur = puits(_mage, 5).single;
      expect((lanceur.des, lanceur.applique), ('3d6', '+pm'));
      expect(lanceur.suite, isNull);
      expect(puits(_mage, 9).single.des, '5d6');
      // Classe physique : RANG dés de vie en PV (haut-elfe : d4).
      final physique = puits(_guerrier, 5).single;
      expect((physique.des, physique.applique), ('3d4', '+pv'));
      // Hybride : au choix, PM ou PV.
      expect(
        [for (final j in puits(_barde, 5)) (j.des, j.applique)],
        [('3d6', '+pm'), ('3d4', '+pv')],
      );
    });

    test('Visage impensable : bonus seulement quand l\'apparence est active',
        () {
      final f = _fiche(race('haut-elfe'), niveau: 7);
      expect(f.etatsPossibles.single.etat.nom, 'Apparence monstrueuse');
      bool aBonus() => f.bonusTests
          .any((s) => s.effet.libelle.startsWith('+10 aux tests de SOC'));
      expect(aBonus(), isFalse);
      f.personnage.etats.add('Apparence monstrueuse');
      expect(aBonus(), isTrue);
    });
  });

  test('formules à plusieurs dés et difficulté', () {
    final f = lireFormule('1d8 + 1d6 +3 phy')!;
    expect(f.groupes, [(nombre: 1, faces: 8), (nombre: 1, faces: 6)]);
    expect(f.bonus, 3);
    expect(lireFormule('2d6 − 1')!.bonus, -1);
    expect(lireFormule('+3'), isNull);
    ResultatLancer test(int de, int bonus) => ResultatLancer(
          libelle: 'Cri sauvage',
          formule: '1d20',
          des: [de],
          garde: de,
          bonus: bonus,
          difficulte: 10,
          d20: true,
        );
    expect(test(8, 2).reussite, isTrue); // 10 ≥ 10
    expect(test(7, 2).reussite, isFalse);
    expect(test(1, 15).reussite, isFalse); // 1 naturel
    expect(test(20, -15).reussite, isTrue); // 20 naturel
    expect(test(8, 2).detail, endsWith('réussite (diff. 10)'));
  });

  testWidgets('page dé : situations, Puits d\'arcane, apparence',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = Personnage(
      id: 'h',
      nom: 'Elandril',
      raceId: 'haut-elfe',
      classeId: 'm',
      niveau: 7,
      pmActuels: 2,
    );
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      MaterialApp(
        home: DeScreen(
          referentiel: Referentiel(races: races, classes: const [_mage]),
          personnages: controller,
          preferences: PreferencesController(
            personnageActifId: 'h',
            // Groupes de la page dé ouverts (cachés par défaut).
            affichages: {
              for (final g in GroupeJets.values) g: AffichageGroupe.visible,
            },
          ),
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

    String detail() =>
        tester.widget<Text>(find.byKey(const Key('detail-de'))).data!;

    // Situations regroupées : « Tous les jets » (vision), « Tests INT »…
    expect(find.byKey(const Key('groupe-situation-tous')), findsOneWidget);
    expect(find.byKey(const Key('groupe-situation-INT')), findsOneWidget);
    // Situation « en forêt » (+1, tous les jets) cochée : ajoutée au test
    await tap(find.byKey(const Key('situation-Vision elfique|+1 aux tests '
        '(se trouve en forêts ou chez les elfes)')));
    await tap(find.byKey(const Key('test-FOR')));
    // Provenance de chaque bonus : caractéristique et trait de la situation
    expect(detail(), contains('(FOR)'));
    expect(detail(), contains('+1 (Vision elfique)'));
    final provenance = find.byKey(const Key('provenance-de'));
    expect(
      find.descendant(of: provenance, matching: find.text('Vision elfique +1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: provenance, matching: find.textContaining('FOR ')),
      findsOneWidget,
    );

    // Puits d'arcane (lanceur de sorts) : mana regagné (4d6 au niveau 7),
    // sans perte de PV.
    final fiche = FicheCalculee(
      personnage: p,
      race: race('haut-elfe'),
      classe: _mage,
    );
    await tap(find.text('Puits d\'arcane · mana regagné'));
    expect(p.pvActuels, isNull);
    expect(p.pmActuels, greaterThan(2));
    expect(p.pmActuels, lessThanOrEqualTo(fiche.pmMax));
    expect(
      p.historique.where((e) => e.message.startsWith('PM : 2 → ')),
      hasLength(1),
    );

    // Apparence monstrueuse : activée puis annulée
    await tap(find.byKey(const Key('etat-Apparence monstrueuse')));
    expect(p.etats, {'Apparence monstrueuse'});
    expect(
      find.descendant(
        of: find.byKey(const Key('groupe-situation-SOC')),
        matching: find.textContaining('faire fuir ou intimider'),
      ),
      findsOneWidget,
    );
    await tap(find.byKey(const Key('etat-Apparence monstrueuse')));
    expect(p.etats, isEmpty);
  });

  testWidgets('page dé : Cri sauvage (difficulté), Amis de la forêt (paliers)',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = Personnage(
      id: 'e',
      nom: 'Lyra',
      raceId: 'elfe-sylvain',
      classeId: 'm',
      niveau: 5,
    );
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      MaterialApp(
        home: DeScreen(
          referentiel: Referentiel(races: races, classes: const [_mage]),
          personnages: controller,
          preferences: PreferencesController(
            personnageActifId: 'e',
            // Groupes de la page dé ouverts (cachés par défaut).
            affichages: {
              for (final g in GroupeJets.values) g: AffichageGroupe.visible,
            },
          ),
          aleatoire: Random(11),
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

    // Cri sauvage est un sort : un seul bouton (zone Sorts), qui dépense le
    // mana puis lance le test de SOC (diff. 10)
    expect(find.text('Cri sauvage'), findsOneWidget);
    // Libellés du sort : mana dépensé et effet appliqué
    expect(find.text('3 PM'), findsOneWidget);
    expect(
        find.text("Imite le cri d'un animal (SOC diff. 10)"), findsOneWidget);
    final pmMax = FicheCalculee(
      personnage: p,
      race: race('elfe-sylvain'),
      classe: _mage,
    ).pmMax;
    await tap(find.text('Cri sauvage'));
    expect(p.pmActuels, pmMax - 3); // sort de rang 2 : 3 PM
    expect(
      p.historique.map((e) => e.message),
      contains(startsWith('Sort lancé : Cri sauvage (−3 PM)')),
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('detail-de'))).data,
      contains('(diff. 10)'),
    );
    // Bandeau « RÉUSSITE » ou « ÉCHEC » bien visible
    expect(find.byKey(const Key('bandeau-reussite')), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'^(RÉUSSITE|ÉCHEC).*diff\. 10$')),
      findsOneWidget,
    );
    await tap(find.text('Amis de la forêt'));
    final messages = p.historique.map((e) => e.message).toList();
    expect(messages[messages.length - 2],
        startsWith('Lancer · Amis de la forêt : '));
    expect(messages.last, startsWith('Lancer · Amis de la forêt · dégâts ('));
  });

  testWidgets('elfe-sylvain niveau 9 : Amis de la forêt lancé avec avantage',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = Personnage(
      id: 'e',
      nom: 'Lyra',
      raceId: 'elfe-sylvain',
      classeId: 'g',
      niveau: 9,
    );
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      MaterialApp(
        home: DeScreen(
          referentiel: Referentiel(races: races, classes: const [_guerrier]),
          personnages: controller,
          preferences: PreferencesController(
            personnageActifId: 'e',
            // Groupes de la page dé ouverts (cachés par défaut).
            affichages: {
              for (final g in GroupeJets.values) g: AffichageGroupe.visible,
            },
          ),
          aleatoire: Random(2),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final amis = find.text('Amis de la forêt');
    await tester.ensureVisible(amis);
    await tester.pumpAndSettle();
    // Le bouton annonce l'avantage
    expect(find.text('avantage'), findsOneWidget);
    await tester.tap(amis);
    await tester.pumpAndSettle();
    final test = p.historique
        .map((e) => e.message)
        .firstWhere((m) => m.startsWith('Lancer · Amis de la forêt : '));
    // Origine de l'avantage et du bonus (1d20 + mod CON) dans le détail
    expect(test, contains('Avantage (Harmonie avec la nature) : '));
    expect(test, contains('(CON)'));
  });

  group('gnome', () {
    test('passif : avantage aux jets de CHAN, toujours appliqué', () {
      final f = _fiche(race('gnome'), niveau: 1);
      expect(
        f.bonusTestsPermanents.map((s) => s.effet.libelle),
        contains('Avantage aux tests de CHAN'),
      );
      expect(f.bonusTestsSituationnels, isEmpty);
    });

    test('porte-bonheur et sacoche donnés une seule fois, +2 CHAN équipé', () {
      final f = _fiche(race('gnome'), niveau: 9);
      final p = f.personnage;
      expect(f.objetsARecevoir.map((o) => o.objet['nom']),
          ['Porte-bonheur', 'Sacoche du gnome']);
      ObjetsDonnes.recevoir(f);
      final porte = f.objetNomme('Porte-bonheur')!;
      expect(porte.categorie, CategorieObjet.extra);
      expect(porte.equipe, isTrue);
      expect(porte.origine, OrigineObjet.race);
      expect(f.objetNomme('Sacoche du gnome'), isNotNull);
      // Porte-bonheur (+2) et Chanceux (+2)
      expect(f.bonusEffets(Carac.chan), 4);
      // Jamais redonnés, même détruits
      p.inventaire.remove(porte);
      expect(f.bonusEffets(Carac.chan), 2);
      expect(f.objetsARecevoir, isEmpty);
      expect(ObjetsDonnes.recevoir(f), isEmpty);
      // Extra : sans limite ni main
      expect(CategorieObjet.extra.emplacementsMax, isNull);
      expect(porte.mains, 0);
    });

    test('rang 1 : arme déjà maîtrisée (+1 au toucher), instrument (+2)', () {
      final g = race('gnome');
      // Option choisie sans précision : encore à faire
      final sans = _fiche(g, niveau: 1, choix: {'accessoire-gnome': 'arme'});
      expect(sans.choixEnAttente.single.choix.cle, 'accessoire-gnome');

      final f =
          _fiche(g, niveau: 1, choix: {'accessoire-gnome': 'arme-maitrisee'});
      f.personnage.precisionsChoix['accessoire-gnome'] = 'Épée';
      expect(f.choixEnAttente, isEmpty);
      final epee = Objet(
        nom: 'Épée longue',
        categorie: CategorieObjet.arme,
        degats: '1d6',
        equipe: true,
      );
      f.personnage.inventaire.add(epee);
      // FOR 14 → AdC 10 (+0) ; +1 avec l'épée choisie
      expect(f.bonusToucher(distance: false).single.valeur, 1);
      expect(f.toucherCac, f.mod(Carac.adc) + 1);
      epee.equipe = false;
      expect(f.bonusToucher(distance: false), isEmpty);

      final fi = _fiche(
        g,
        niveau: 1,
        choix: {'accessoire-gnome': 'instrument-maitrise'},
      );
      fi.personnage.precisionsChoix['accessoire-gnome'] = 'Luth';
      final luth = fi.instrumentsMaitrises.single;
      expect(luth.nom, 'Luth');
      expect(luth.bonus, 2);
    });

    test('rang 2 : deux compétences distinctes ; rang 5 : Chanceux', () {
      final f = _fiche(race('gnome'), niveau: 9);
      final noms = f.competencesAcquises.map((c) => c.competence.nom);
      expect(
          noms,
          containsAll([
            'Discussion insensée (en combat)',
            'Discussion insensée (hors combat)',
          ]));
      final chanceux =
          f.jetsCompetences.firstWhere((j) => j.libelle.startsWith('Chanceux'));
      expect(chanceux.applique, '=pv');
      expect(chanceux.requiert, 'Porte-bonheur');
      expect(chanceux.detruit, 'Porte-bonheur');
    });
  });

  testWidgets('page dé : gnome, Chanceux détruit le porte-bonheur',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = Personnage(
      id: 'g',
      nom: 'Pip',
      raceId: 'gnome',
      classeId: 'g',
      niveau: 9,
      pvActuels: -3,
    );
    ObjetsDonnes.recevoir(
      FicheCalculee(personnage: p, race: race('gnome'), classe: _guerrier),
    );
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      MaterialApp(
        home: DeScreen(
          referentiel: Referentiel(races: races, classes: const [_guerrier]),
          personnages: controller,
          preferences: PreferencesController(
            personnageActifId: 'g',
            // Groupes de la page dé ouverts (cachés par défaut).
            affichages: {
              for (final g in GroupeJets.values) g: AffichageGroupe.visible,
            },
          ),
          aleatoire: Random(4),
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

    // Test de CHAN : avantage automatique (passif)
    await tap(find.byKey(const Key('test-CHAN')));
    expect(
      tester.widget<Text>(find.byKey(const Key('detail-de'))).data,
      startsWith('Avantage (D\'une nature chanceuse)'),
    );
    // Mains nues (aucune arme) et pas d'instrument maîtrisé
    expect(find.byKey(const Key('jet-degats-mains-nues')), findsOneWidget);
    expect(find.byKey(const Key('aucun-instrument')), findsOneWidget);

    // Chanceux : confirmation, PV = 2d6, porte-bonheur détruit
    await tap(find.text('Chanceux : échapper à la mort (PV = 2d6)'));
    expect(find.text('Utiliser Chanceux ?'), findsOneWidget);
    await tap(find.byKey(const Key('confirmer-competence')));
    expect(p.pvActuels, inInclusiveRange(2, 12));
    expect(p.inventaire.where((o) => o.nom == 'Porte-bonheur'), isEmpty);
    expect(
      p.historique.map((e) => e.message),
      contains('Objet détruit : Porte-bonheur (Chanceux)'),
    );
    // Plus de porte-bonheur : le bouton est grisé
    expect(find.text('sans porte-bonheur · détruit porte-bonheur'),
        findsOneWidget);
  });

  test('gnome : arme choisie reçue (catalogue), porte-bonheur décrit', () {
    final catalogue = [
      for (final e in jsonDecode(
        File('assets/data/equipements.json').readAsStringSync(),
      ) as List)
        Equipement.depuisJson(e as Map<String, dynamic>),
    ];
    final f = _fiche(
      race('gnome'),
      niveau: 1,
      choix: {'accessoire-gnome': 'arme'},
    );
    // Sans précision : choix incomplet, l'arme n'est pas encore donnée
    expect(f.objetsARecevoir.map((o) => o.objet['nom']), ['Porte-bonheur']);
    f.personnage.precisionsChoix['accessoire-gnome'] = 'Bâton';
    final cles = {for (final o in f.objetsARecevoir) o.objet['nom']: o.cle};
    expect(cles.keys, containsAll(['Porte-bonheur', 'Bâton']));
    ObjetsDonnes.recevoir(
      f,
      catalogue: catalogue,
      descriptions: {cles['Porte-bonheur']!: 'Un dé en os de mon grand-père'},
    );
    // Bâton repris du catalogue : une ou deux mains
    final baton = f.objetNomme('Bâton')!;
    expect(baton.polyvalente, isTrue);
    expect(baton.origine, OrigineObjet.race);
    expect(
      f.objetNomme('Porte-bonheur')!.description,
      startsWith('Un dé en os de mon grand-père\n'),
    );
  });

  testWidgets('fiche d\'un gnome niveau 3 : pas d\'erreur (rang 2 double)',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = Personnage(
      id: 'g',
      nom: 'Pip',
      raceId: 'gnome',
      classeId: 'g',
      niveau: 3,
    );
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      OdvApp(
        referentiel: Referentiel(races: races, classes: const [_guerrier]),
        controller: controller,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pip'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Discussion insensée (en combat)'), findsOneWidget);
    expect(find.text('Discussion insensée (hors combat)'), findsOneWidget);
    // Objets à recevoir (personnage créé avant la règle)
    expect(find.byKey(const Key('objets-a-recevoir')), findsOneWidget);
  });

  test('sorts : coût en PM selon le rang (coût rang N prioritaire)', () {
    const mage = Classe(
      id: 'm',
      nom: 'Mage',
      modifDeVie: ModifDe.egal,
      modifDeMana: ModifDe.egal,
      voies: [
        Voie(
          id: 'm-feu',
          nom: 'Voie du feu',
          competences: [
            Competence(rang: 1, nom: 'Étincelle', type: 'sort, coût rang 2'),
            Competence(rang: 2, nom: 'Boule de feu', type: 'actif, sort'),
            Competence(rang: 3, nom: 'Garde', type: 'passif'),
          ],
        ),
      ],
    );
    final f = FicheCalculee(
      personnage: Personnage(
        id: 'm',
        nom: 'Mira',
        raceId: 'humain',
        classeId: 'm',
        niveau: 3,
        rangsVoies: {'m-feu': 3},
      ),
      race: race('humain'),
      classe: mage,
    );
    expect(
      {for (final s in f.sorts) s.competence.nom: s.cout},
      {'Étincelle': 3, 'Boule de feu': 3},
    );
  });

  test('gnome : liste des armes, déjà maîtrisées repérées', () {
    final catalogue = [
      for (final e in jsonDecode(
        File('assets/data/equipements.json').readAsStringSync(),
      ) as List)
        Equipement.depuisJson(e as Map<String, dynamic>),
    ];
    final f = _fiche(race('gnome'), niveau: 1);
    f.personnage.aptitudes = [
      const AptitudeAcquise(id: 'arme', precision: 'Bâton'),
      const AptitudeAcquise(id: 'instrument', precision: 'Luth'),
    ];
    final armes = f.elementsChoix(
      'armes',
      catalogue: catalogue,
      cle: 'accessoire-gnome',
    );
    expect(armes.first, (nom: 'Bâton', maitrise: true));
    expect(armes.map((a) => a.nom), contains('Épée longue'));
    expect(armes.firstWhere((a) => a.nom == 'Épée longue').maitrise, isFalse);
    final instruments = f.elementsChoix('instruments', cle: 'accessoire-gnome');
    expect(instruments.single, (nom: 'Luth', maitrise: true));
    // Le choix lui-même ne compte pas comme maîtrise déjà acquise
    f.personnage.choix['accessoire-gnome'] = 'arme';
    f.personnage.precisionsChoix['accessoire-gnome'] = 'Épée longue';
    expect(
      f
          .elementsChoix('armes', catalogue: catalogue, cle: 'accessoire-gnome')
          .firstWhere((a) => a.nom == 'Épée longue')
          .maitrise,
      isFalse,
    );
  });

  testWidgets('fiche : liste déroulante du gnome, arme déjà maîtrisée → bonus',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = Personnage(
      id: 'g',
      nom: 'Pip',
      raceId: 'gnome',
      classeId: 'g',
      aptitudes: [const AptitudeAcquise(id: 'arme', precision: 'Bâton')],
    );
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      OdvApp(
        referentiel: Referentiel(races: races, classes: const [_guerrier]),
        controller: controller,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pip'));
    await tester.pumpAndSettle();
    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    // Pastilles visibles : Arme / Instrument (pas les options internes)
    expect(
        find.byKey(const Key('option-accessoire-gnome-arme')), findsOneWidget);
    expect(find.byKey(const Key('option-accessoire-gnome-arme-maitrisee')),
        findsNothing);
    await tap(find.byKey(const Key('option-accessoire-gnome-arme')));
    await tap(find.byKey(const Key('liste-elements-accessoire-gnome')));
    expect(find.textContaining('déjà maîtrisé → +1 au toucher'), findsWidgets);
    await tap(find.textContaining('Bâton').last);
    expect(p.choix['accessoire-gnome'], 'arme-maitrisee');
    expect(p.precisionsChoix['accessoire-gnome'], 'Bâton');
  });

  testWidgets('page dé : CHAN en vert (avantage), instrument en DEX, sort',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = Personnage(
      id: 'g',
      nom: 'Pip',
      raceId: 'gnome',
      classeId: 'g',
      aptitudes: [const AptitudeAcquise(id: 'instrument', precision: 'Luth')],
      // DEX 14 → +2 (gnome : pas de modificateur racial de DEX)
      caracBase: {for (final c in Carac.values) c: 10}..[Carac.dex] = 14,
    );
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      MaterialApp(
        home: DeScreen(
          referentiel: Referentiel(races: races, classes: const [_guerrier]),
          personnages: controller,
          preferences: PreferencesController(
            personnageActifId: 'g',
            // Groupes de la page dé ouverts (cachés par défaut).
            affichages: {
              for (final g in GroupeJets.values) g: AffichageGroupe.visible,
            },
          ),
          aleatoire: Random(8),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // CHAN : avantage permanent signalé sur le bouton
    expect(
      find.descendant(
        of: find.byKey(const Key('test-CHAN')),
        matching: find.text('avantage'),
      ),
      findsOneWidget,
    );
    final instrument = find.byKey(const Key('jet-instrument-0'));
    await tester.ensureVisible(instrument);
    await tester.pumpAndSettle();
    await tester.tap(instrument);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('commentaire-de'))).data,
      startsWith('Pip · Jouer : Luth'),
    );
    expect(
      p.historique.last.message,
      contains('+2 (DEX)'),
    );
  });

  test('les choix survivent à un aller-retour JSON', () {
    final p = Personnage(
      id: 'p',
      nom: 'Kael',
      raceId: 'draconien',
      classeId: 'g',
      choix: {'element-draconien': 'foudre'},
    );
    expect(Personnage.depuisJson(p.versJson()).choix,
        {'element-draconien': 'foudre'});
  });
}

void testsSangMelePolyglotte() {
  final races = _races();
  Race race(String id) => races.firstWhere((r) => r.id == id);

  test('demi-elfe, Sang mêlé → Polyglotte : une nouvelle langue à choisir', () {
    final f = _fiche(
      race('demi-elfe'),
      niveau: 3,
      origine: 'humaine',
      choix: {'sang-mele': 'humain'},
    );
    final c =
        f.choixEnAttente.firstWhere((x) => x.choix.cle == 'sang-mele').choix;
    final o = c.option('humain')!;
    expect(o.question, 'Quelle langue ?');
    expect(o.liste, 'langues');
    // Langues proposées : celles qu'il ne parle pas encore marquées à part
    final langues = f.elementsChoix('langues', cle: 'sang-mele');
    expect(
      [
        for (final l in langues)
          if (l.maitrise) l.nom
      ],
      containsAll(['Commun', 'Elfique']),
    );
    f.personnage.precisionsChoix['sang-mele'] = 'Nain';
    expect(f.langues, contains('Nain'));
    expect(
        f.choixEnAttente.map((x) => x.choix.cle), isNot(contains('sang-mele')));
  });

  testWidgets('carte de choix : seulement les langues non parlées',
      (tester) async {
    final f = _fiche(
      race('demi-elfe'),
      niveau: 3,
      origine: 'humaine',
      choix: {'sang-mele': 'humain'},
    );
    final c =
        f.choixEnAttente.firstWhere((x) => x.choix.cle == 'sang-mele').choix;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CarteChoix(
              nom: 'Sang mêlé',
              choix: c,
              valeur: 'humain',
              onChoisir: (_) {},
              elements: (liste) => f.elementsChoix(liste, cle: 'sang-mele'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('liste-elements-sang-mele')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nain', findRichText: true), findsWidgets);
    expect(find.textContaining('Elfique', findRichText: true), findsNothing);
    expect(find.textContaining('Commun', findRichText: true), findsNothing);
  });
}
