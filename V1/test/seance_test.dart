import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/campagnes.dart';
import 'package:odyssee_vagabonds/data/compte.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/data/seance.dart';
import 'package:odyssee_vagabonds/models/campagne.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/creature.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/seance.dart';
import 'package:odyssee_vagabonds/screens/campagnes/campagnes_screen.dart';
import 'package:odyssee_vagabonds/screens/campagnes/seance_screen.dart';
import 'package:odyssee_vagabonds/screens/fiche_screen.dart';
import 'package:odyssee_vagabonds/state/campagnes_controller.dart';
import 'package:odyssee_vagabonds/state/compte_controller.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/seance_controller.dart';

/// Interface de jeu d'une séance (03/11/2026) : tours par initiative en
/// combat, créatures cachées, jets et leur visibilité, ressources selon les
/// paramètres, notes personnelles.

class _Compte implements ServiceCompte {
  _Compte(this._actuel);

  final Utilisateur? _actuel;

  @override
  bool get disponible => true;
  @override
  Utilisateur? get actuel => _actuel;
  @override
  Stream<Utilisateur?> get changements => const Stream.empty();
  @override
  Future<void> connexionEmail(String email, String motDePasse) async {}
  @override
  Future<void> creerCompte(String email, String motDePasse) async {}
  @override
  Future<void> connexionGoogle() async {}
  @override
  Future<void> motDePasseOublie(String email) async {}
  @override
  Future<void> deconnexion() async {}
  @override
  Future<void> supprimerCompte() async {}
}

const _nain = Race(id: 'nain', nom: 'Nain', deVie: 8, deMana: 4);
const _guerrier = Classe(
  id: 'guerrier',
  nom: 'Guerrier',
  modifDeVie: ModifDe.plus,
  modifDeMana: ModifDe.moins,
);
const _loup = Creature(
  id: 'loup',
  nom: 'Loup',
  famille: 'Bêtes',
  archetype: 'Meute',
  taille: TailleCreature.standard,
  description: 'Un grand loup gris.',
  initiative: 14,
  pv: 12,
  attaques: [
    AttaqueCreature(nom: 'Morsure', toucher: '1d20 +2', degats: '1d6 +1'),
  ],
);

const _referentiel = Referentiel(
  races: [_nain],
  classes: [_guerrier],
  creatures: [_loup],
);

Personnage _brom() =>
    Personnage(id: 'brom', nom: 'Brom', raceId: 'nain', classeId: 'guerrier');

MembreCampagne _membre(String uid, String perso, {int initiative = 10}) =>
    MembreCampagne(
      uid: uid,
      nom: uid,
      personnageId: perso,
      personnageNom: perso,
      personnageResume: 'Nain · Guerrier · niveau 1',
      statut: StatutMembre.accepte,
      date: DateTime(2026, 11, 3),
      initiative: initiative,
    );

CreatureSeance _creature(String id, int init) =>
    CreatureSeance(id: id, nom: id, initiative: init);

/// Campagne avec un MJ et deux joueurs acceptés, séance démarrée.
Future<({BaseCampagnesMemoire base, Campagne campagne})> _partie({
  ParametresCampagne parametres = const ParametresCampagne(),
}) async {
  final base = BaseCampagnesMemoire(Random(2));
  final mj = ServiceCampagnesMemoire(base, 'mj');
  final c = await mj.creer(
    nom: 'Valfroid',
    mjNom: 'Ben',
    prive: const PriveCampagne(script: 'Acte I'),
    parametres: parametres,
  );
  for (final (uid, perso) in [('j1', 'brom'), ('j2', 'aria')]) {
    await ServiceCampagnesMemoire(base, uid)
        .demander(base.campagnes[c.id]!, _membre(uid, perso));
    await mj.accepter(base.campagnes[c.id]!, uid);
  }
  await mj.demarrerSeance(base.campagnes[c.id]!);
  return (base: base, campagne: base.campagnes[c.id]!);
}

void main() {
  group('tours', () {
    test('initiative décroissante ; à égalité, les PJ d\'abord', () {
      expect(
        ordreCombat(
          [_membre('j1', 'Brom', initiative: 12), _membre('j2', 'Aria')],
          [_creature('loup', 12), _creature('rat', 3)],
        ),
        ['j1', 'loup', 'j2', 'rat'],
      );
    });

    test('suivant, précédent, manches', () {
      var e = const EtatJeu(mode: ModeJeu.combat, ordre: ['a', 'b']);
      expect(e.actif, 'a');
      expect(e.precedent().index, 0); // rien avant le premier tour
      e = e.suivant().suivant();
      expect((e.actif, e.manche), ('a', 2));
      e = e.precedent();
      expect((e.actif, e.manche), ('b', 1));
      expect(const EtatJeu(ordre: ['a']).actif, isNull); // pas en exploration
    });

    test('ordre recalculé : le tour reste à celui qui joue', () {
      const e = EtatJeu(mode: ModeJeu.combat, ordre: ['a', 'b', 'c'], index: 1);
      expect(e.avecOrdre(['z', 'a', 'b', 'c']).actif, 'b');
      expect(e.avecOrdre(['a', 'c']).actif, 'c'); // b retiré : au suivant
    });

    test('un PJ ne passe que son tour, le MJ tous ; retour MJ seul', () async {
      final p = await _partie();
      final c = p.campagne;
      final mj = ServiceCampagnesMemoire(p.base, 'mj').seance;
      final j1 = ServiceCampagnesMemoire(p.base, 'j1').seance;
      final j2 = ServiceCampagnesMemoire(p.base, 'j2').seance;
      await expectLater(
          j1.demarrerCombat(c, const []), throwsA(isA<ErreurCampagne>()));
      await mj.demarrerCombat(c, ['j1', 'j2']);
      await expectLater(j2.passerTour(c), throwsA(isA<ErreurCampagne>()));
      await j1.passerTour(c);
      expect(p.base.parties[c.id]!.etat.actif, 'j2');
      await expectLater(j2.tourPrecedent(c), throwsA(isA<ErreurCampagne>()));
      await mj.tourPrecedent(c);
      expect(p.base.parties[c.id]!.etat.actif, 'j1');
      await mj.passerEnExploration(c);
      expect(p.base.parties[c.id]!.etat.enCombat, isFalse);
    });
  });

  group('créatures', () {
    test('état approximatif selon les PV ; noms numérotés', () {
      expect(EtatCreature.depuisPv(12, 12), EtatCreature.indemne);
      expect(EtatCreature.depuisPv(4, 12), EtatCreature.blessee);
      expect(EtatCreature.depuisPv(3, 12), EtatCreature.gravement);
      expect(EtatCreature.depuisPv(0, 12), EtatCreature.vaincue);
      expect(nomNumerote('Loup', ['Rat']), 'Loup');
      expect(nomNumerote('Loup', ['Loup', 'Loup 2']), 'Loup 3');
    });

    test('un PJ ne reçoit ni carte cachée, ni vrai nom, ni PV', () async {
      final p = await _partie();
      final c = p.campagne;
      final mj = ServiceCampagnesMemoire(p.base, 'mj').seance;
      final j1 = ServiceCampagnesMemoire(p.base, 'j1').seance;
      await mj.ajouterCreature(
          c, const CreatureSeance(id: 'a', nom: 'Ombre', cachee: true));
      await mj.ajouterCreature(
        c,
        const CreatureSeance(
            id: 'b', nom: 'Liche', nomCache: true, pv: 40, pvMax: 40),
      );
      expect(await mj.ecouterCreatures(c).first, hasLength(2));
      final vues = await j1.ecouterCreatures(c).first;
      expect(vues.single.nom, CreatureSeance.nomInconnu);
      expect(vues.single.pv, isNull);
      expect(vues.single.creatureId, isEmpty);
      // Partie publique en ligne : ni vrai nom, ni PV.
      const liche = CreatureSeance(
          id: 'b', nom: 'Liche', nomCache: true, pv: 40, pvMax: 40);
      expect(liche.versPublic(const ParametresCampagne())['nom'],
          CreatureSeance.nomInconnu);
      expect(liche.versPublic(const ParametresCampagne()).containsKey('pv'),
          isFalse);
      await expectLater(
          j1.retirerCreature(c, 'a'), throwsA(isA<ErreurCampagne>()));
    });
  });

  test('jets : chacun ne lit que ceux dont il est lecteur', () async {
    final p = await _partie();
    final c = p.campagne;
    final mj = ServiceCampagnesMemoire(p.base, 'mj').seance;
    final j1 = ServiceCampagnesMemoire(p.base, 'j1').seance;
    final j2 = ServiceCampagnesMemoire(p.base, 'j2').seance;
    JetSeance jet(String auteur, VisibiliteJet v, {String? cible}) => JetSeance(
          auteur: auteur,
          auteurNom: auteur,
          libelle: '1d20',
          detail: '12',
          total: 12,
          date: DateTime(2026, 11, 3),
          seance: 1,
          visibilite: v,
          lecteurs: lecteursDuJet(c, v, auteur: auteur, cible: cible),
        );
    Future<List<int>> vus() async => [
          for (final s in <ServiceSeance>[mj, j1, j2])
            (await s.ecouterJets(c, 1).first).length,
        ];

    await j1.lancer(c, jet('j1', VisibiliteJet.tous));
    expect(await vus(), [1, 1, 1]);
    // PJ : caché aux autres joueurs.
    await j1.lancer(c, jet('j1', VisibiliteJet.mjEtAuteur));
    expect(await vus(), [2, 2, 1]);
    // PJ : caché pour lui aussi, le MJ seul le voit.
    await j1.lancer(c, jet('j1', VisibiliteJet.mjSeul));
    expect(await vus(), [3, 2, 1]);
    // MJ : visible d'un seul PJ.
    await mj.lancer(c, jet('mj', VisibiliteJet.unJoueur, cible: 'j2'));
    expect(await vus(), [4, 2, 2]);
  });

  group('ressources', () {
    const r = RessourcesPj(pv: 9, pvMax: 13, pe: 3, peMax: 6);

    Future<void> publier(BaseCampagnesMemoire b, Campagne c) =>
        ServiceCampagnesMemoire(b, 'j1')
            .seance
            .publierPersonnage(c, r, resume: 'x', initiative: 11);

    test('fiches non partagées entre joueurs : PV, PM, PE cachés', () async {
      final p = await _partie();
      await publier(p.base, p.campagne);
      Future<Map<String, RessourcesPj>> vues(String uid) =>
          ServiceCampagnesMemoire(p.base, uid)
              .seance
              .ecouterRessources(p.campagne)
              .first;
      expect((await vues('mj'))['j1'], r);
      expect((await vues('j1'))['j1'], r);
      expect(await vues('j2'), isEmpty);
      expect(p.base.membres[p.campagne.id]!['j1']!.initiative, 11);
    });

    test('fiches partagées entre joueurs : visibles ; MJ selon le paramètre',
        () async {
      final p = await _partie(
        parametres: const ParametresCampagne(
          fichesVisiblesMj: false,
          pjVoientRessources: true,
        ),
      );
      await publier(p.base, p.campagne);
      Future<Map<String, RessourcesPj>> vues(String uid) =>
          ServiceCampagnesMemoire(p.base, uid)
              .seance
              .ecouterRessources(p.campagne)
              .first;
      expect((await vues('j2'))['j1'], r);
      expect(await vues('mj'), isEmpty);
    });
  });

  test('notes de séance : propres au joueur et à la séance', () async {
    final p = await _partie();
    final c = p.campagne;
    final j1 = ServiceCampagnesMemoire(p.base, 'j1').seance;
    final j2 = ServiceCampagnesMemoire(p.base, 'j2').seance;
    await j1.ecrireNote(c, 1, 'Se méfier du maire');
    expect(await j1.lireNote(c, 1), 'Se méfier du maire');
    expect(await j1.lireNote(c, 2), isEmpty);
    expect(await j2.lireNote(c, 1), isEmpty);
  });

  test('contrôleur : ressources et résumé publiés par le joueur', () async {
    final p = await _partie();
    final personnages = PersonnagesController(
      EnMemoirePersonnageRepository([_brom()]),
    );
    await personnages.charger();
    final compte = CompteController(
      service: _Compte(const Utilisateur(uid: 'j1')),
      personnages: personnages,
      local: personnages.repository,
      depotEnLigne: (_) => EnMemoireDepotEnLigne([_brom()]),
    );
    await compte.demarrer();
    final campagnes = CampagnesController(
      compte: compte,
      service: (u) => ServiceCampagnesMemoire(p.base, u.uid),
    );
    await pumpEventQueue();
    final s = SeanceController(
      campagnes: campagnes,
      personnages: personnages,
      referentiel: _referentiel,
      campagneId: p.campagne.id,
    );
    await pumpEventQueue();
    final r = p.base.parties[p.campagne.id]!.ressources['j1'];
    expect(r?.peMax, 6);
    expect(r?.pmMax, 0);
    expect(p.base.membres[p.campagne.id]!['j1']!.personnageResume,
        'Nain · Guerrier · niveau 1');
    s.dispose();
    campagnes.dispose();
    compte.dispose();
    personnages.dispose();
  });
  group('permissions', () {
    test('créatures : PV et fiche selon les permissions, nom caché prioritaire',
        () {
      const loup = CreatureSeance(
        id: 'a',
        nom: 'Loup',
        creatureId: 'loup',
        pv: 8,
        pvMax: 12,
      );
      const rien = ParametresCampagne();
      const tout = ParametresCampagne(
        pjVoientPvCreatures: true,
        pjVoientFichesCreatures: true,
      );
      expect(loup.pourJoueur(rien).pv, isNull);
      expect(loup.pourJoueur(rien).creatureId, isEmpty);
      expect(loup.pourJoueur(tout).pv, 8);
      expect(loup.pourJoueur(tout).creatureId, 'loup');
      expect(loup.versPublic(rien).containsKey('pv'), isFalse);
      expect(loup.versPublic(tout)['pv'], 8);
      // Nom caché : la fiche le révélerait.
      final cache = loup.copie(nomCache: true);
      expect(cache.pourJoueur(tout).creatureId, isEmpty);
      expect(cache.versPublic(tout).containsKey('creatureId'), isFalse);
    });

    test('inventaire et compétences verrouillés hors séance seulement',
        () async {
      final p = await _partie(
        parametres: const ParametresCampagne(
          pjInventaireHorsSeance: false,
          pjCompetencesHorsSeance: false,
        ),
      );
      final personnages = PersonnagesController(
        EnMemoirePersonnageRepository([_brom()]),
      );
      await personnages.charger();
      final compte = CompteController(
        service: _Compte(const Utilisateur(uid: 'j1')),
        personnages: personnages,
        local: personnages.repository,
        depotEnLigne: (_) => EnMemoireDepotEnLigne([_brom()]),
      );
      await compte.demarrer();
      final campagnes = CampagnesController(
        compte: compte,
        service: (u) => ServiceCampagnesMemoire(p.base, u.uid),
      );
      await pumpEventQueue();
      // Séance en cours : rien de verrouillé.
      expect(personnages.restrictionsDe('brom').inventaire, isFalse);
      await ServiceCampagnesMemoire(p.base, 'mj')
          .terminerSeance(p.base.campagnes[p.campagne.id]!);
      await pumpEventQueue();
      expect(personnages.restrictionsDe('brom').inventaire, isTrue);
      expect(personnages.restrictionsDe('brom').competences, isTrue);
      expect(personnages.restrictionsDe('autre').inventaire, isFalse);
      campagnes.dispose();
      compte.dispose();
      personnages.dispose();
    });

    test('le MJ modifie une fiche que le joueur lui a ouverte', () async {
      final p = await _partie();
      final brom = _brom();
      p.base.fiches['brom'] = (
        fiche: brom,
        proprietaire: 'j1',
        partage: ['mj'],
        editeurs: <String>[],
      );
      final mj = ServiceCampagnesMemoire(p.base, 'mj');
      await expectLater(mj.ecrireFiche(brom), throwsA(isA<ErreurCampagne>()));
      await ServiceCampagnesMemoire(p.base, 'j1')
          .partagerFiche('brom', ['mj'], editeurs: ['mj']);
      await mj.ecrireFiche(brom..pvActuels = 3);
      expect(p.base.fiches['brom']!.fiche.pvActuels, 3);
      expect(p.base.fiches['brom']!.proprietaire, 'j1');
    });
  });

  test('taille des portions : le total reste 100 %, 15 % au moins', () {
    var r = ajusterPortions(0.22, 0.26, changee: 0, valeur: 0.3);
    expect(r.gauche, closeTo(0.3, 0.001));
    expect(1 - r.gauche - r.droite, greaterThanOrEqualTo(kPortionMin));
    r = ajusterPortions(0.22, 0.26, changee: 1, valeur: 0.7);
    expect(r.gauche, closeTo(0.15, 0.001));
    expect(r.droite, closeTo(0.15, 0.001));
    r = ajusterPortions(0.22, 0.26, changee: 2, valeur: 0.05);
    expect(r.droite, kPortionMin);
    expect(r.gauche + (1 - r.gauche - r.droite) + r.droite, closeTo(1, 0.001));
  });

  group('écran', () {
    Future<({BaseCampagnesMemoire base, Campagne campagne})> ouvrir(
      WidgetTester tester,
      String uid, {
      Size taille = const Size(1400, 1000),
      List<Personnage> fiches = const [],
      Future<void> Function(BaseCampagnesMemoire, Campagne)? avant,
    }) async {
      tester.view.physicalSize = taille;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final p = await _partie();
      await avant?.call(p.base, p.campagne);
      final personnages = PersonnagesController(
        EnMemoirePersonnageRepository(),
      );
      await personnages.charger();
      final compte = CompteController(
        service: _Compte(Utilisateur(uid: uid, nom: uid)),
        personnages: personnages,
        local: personnages.repository,
        depotEnLigne: (_) => EnMemoireDepotEnLigne(fiches),
      );
      await compte.demarrer();
      final campagnes = CampagnesController(
        compte: compte,
        service: (u) => ServiceCampagnesMemoire(p.base, u.uid),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(MaterialApp(
        home: SeanceScreen(
          contexte: ContexteCampagnes(
            campagnes: campagnes,
            personnages: personnages,
            referentiel: _referentiel,
          ),
          campagneId: p.campagne.id,
          aleatoire: Random(1),
        ),
      ));
      await tester.pumpAndSettle();
      return p;
    }

    // Pas de ensureVisible ici : il ferait défiler les onglets de la séance.
    Future<void> tap(WidgetTester tester, Finder f) async {
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    testWidgets('MJ : navigation, créature ajoutée, combat', (tester) async {
      final x = await ouvrir(tester, 'mj');
      expect(find.byKey(const Key('seance-creatures')), findsOneWidget);
      expect(find.byKey(const Key('carte-script')), findsOneWidget);
      expect(find.byKey(const Key('carte-notes')), findsNothing);
      expect(find.byKey(const Key('carte-j1')), findsOneWidget);
      expect(find.byKey(const Key('passer-tour')), findsNothing);

      // Onglet Créatures : ajout avec le nom caché.
      await tap(tester, find.byKey(const Key('seance-creatures')));
      // Le bestiaire s'ouvre au centre : cartes et dés restent visibles.
      expect(find.byKey(const Key('liste-cartes')), findsOneWidget);
      expect(find.byKey(const Key('lancer-seance')), findsOneWidget);
      await tap(tester, find.text('Loup'));
      expect(find.text('Un grand loup gris.'), findsOneWidget);
      await tap(tester, find.byKey(const Key('ajouter-loup')));
      await tap(tester, find.byKey(const Key('ajout-nom-cache')));
      await tap(tester, find.byKey(const Key('confirmer-ajout')));
      final partie = x.base.parties[x.campagne.id]!;
      final loup = partie.creatures.values.single;
      expect((loup.nom, loup.nomCache, loup.pv), ('Loup', true, 12));
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // La carte s'affiche sous les PJ, avec sa croix rouge.
      await tap(tester, find.byKey(const Key('seance-tableau')));
      final carte = find.byKey(Key('carte-${loup.id}'));
      expect(carte, findsOneWidget);
      expect(tester.getTopLeft(carte).dy,
          greaterThan(tester.getTopLeft(find.byKey(const Key('carte-j2'))).dy));
      await tap(tester, carte);
      await tap(tester, find.byKey(const Key('creature-pv-moins')));
      expect(partie.creatures[loup.id]!.pv, 11);

      // Créature sélectionnée : ses attaques dans le lancer de dés.
      await tap(tester, find.byKey(const Key('attaque-0')));
      expect(partie.jets.single.libelle, 'Loup · Morsure · toucher');
      await tap(tester, find.byKey(const Key('attaque-1')));
      expect(partie.jets.last.libelle, 'Loup · Morsure · dégâts');

      // Combat : le loup (14) passe avant les PJ (0), retour possible.
      await tap(tester, find.byKey(const Key('basculer-mode')));
      // En combat, l'initiative s'affiche sur les cartes.
      expect(find.byKey(Key('carte-${loup.id}-initiative')), findsOneWidget);
      expect(find.byKey(const Key('carte-j1-initiative')), findsOneWidget);
      expect(partie.etat.enCombat, isTrue);
      expect(partie.etat.actif, loup.id);
      await tap(tester, find.byKey(const Key('passer-tour')));
      expect(partie.etat.index, 1);
      await tap(tester, find.byKey(const Key('tour-precedent')));
      expect(partie.etat.index, 0);

      // Croix rouge : retirée de la partie et de l'ordre.
      await tap(tester, find.byKey(Key('retirer-${loup.id}')));
      expect(partie.creatures, isEmpty);
      expect(partie.etat.ordre, isNot(contains(loup.id)));
    });

    testWidgets('MJ : jet visible par un seul PJ', (tester) async {
      final x = await ouvrir(tester, 'mj');
      await tap(tester, find.byKey(const Key('visibilite-jet')));
      await tap(tester, find.text('Visible par un seul joueur').last);
      // Sans joueur choisi : pas de lancer.
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('lancer-seance')))
            .onPressed,
        isNull,
      );
      await tap(tester, find.byKey(const Key('cible-jet')));
      await tap(tester, find.text('aria').last);
      await tap(tester, find.byKey(const Key('lancer-seance')));
      final j = x.base.parties[x.campagne.id]!.jets.single;
      expect(j.lecteurs, unorderedEquals(['mj', 'j2']));
      await tap(tester, find.byKey(const Key('onglet-historique')));
      expect(find.byKey(const Key('historique-seance')), findsOneWidget);
    });

    testWidgets('PJ : pas de Créatures, notes, carte cachée invisible, tour',
        (tester) async {
      final x = await ouvrir(
        tester,
        'j1',
        fiches: [_brom()],
        avant: (b, c) async {
          final mj = ServiceCampagnesMemoire(b, 'mj').seance;
          await mj.ajouterCreature(
              c, const CreatureSeance(id: 'a', nom: 'Ombre', cachee: true));
          await mj.ajouterCreature(
            c,
            const CreatureSeance(
              id: 'b',
              nom: 'Liche',
              nomCache: true,
              description: 'Une silhouette décharnée.',
              pv: 3,
              pvMax: 40,
              etat: EtatCreature.gravement,
            ),
          );
          await mj.demarrerCombat(c, ['j1', 'a', 'b']);
        },
      );
      expect(find.byKey(const Key('seance-creatures')), findsNothing);
      expect(find.byKey(const Key('carte-script')), findsNothing);
      expect(find.byKey(const Key('basculer-mode')), findsNothing);
      expect(find.byKey(const Key('tour-precedent')), findsNothing);
      expect(find.byKey(const Key('carte-a')), findsNothing);

      // Nom caché : « Créature inconnue », état sans PV.
      await tap(tester, find.byKey(const Key('carte-b')));
      expect(find.text(CreatureSeance.nomInconnu), findsNWidgets(2));
      expect(find.text('Liche'), findsNothing);
      expect(find.textContaining('PV 3'), findsNothing);
      expect(find.byKey(const Key('creature-etat')), findsOneWidget);
      expect(find.byKey(const Key('retirer-b')), findsNothing);

      // Notes personnelles de la séance.
      await tap(tester, find.byKey(const Key('carte-notes')));
      await tester.enterText(
          find.byKey(const Key('texte-seance')), 'Se méfier du maire');
      await tap(tester, find.byKey(const Key('enregistrer-texte-seance')));
      final partie = x.base.parties[x.campagne.id]!;
      expect(partie.notes['j1/1'], 'Se méfier du maire');
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Jet caché pour le joueur aussi : le résultat ne s'affiche pas.
      await tap(tester, find.byKey(const Key('visibilite-jet')));
      await tap(tester, find.text('Caché pour moi aussi (MJ seul)').last);
      await tap(tester, find.byKey(const Key('lancer-seance')));
      expect(partie.jets.single.lecteurs, ['mj']);
      expect(find.text('Jet envoyé au MJ : résultat caché.'), findsOneWidget);

      // C'est son tour : il le passe ; la carte cachée joue → « MJ ».
      expect(find.text('Manche 1 · À toi de jouer'), findsOneWidget);
      await tap(tester, find.byKey(const Key('passer-tour')));
      expect(partie.etat.actif, 'a');
      expect(find.text('Manche 1 · Tour : MJ'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('passer-tour')))
            .onPressed,
        isNull,
      );
    });
    testWidgets('PJ : sa fiche complète au centre et ses attaques',
        (tester) async {
      await ouvrir(tester, 'j1', fiches: [_brom()]);
      await tap(tester, find.byKey(const Key('carte-j1')));
      expect(find.byKey(const Key('vue-fiche')), findsOneWidget);
      await tap(tester, find.byKey(const Key('vue-competences')));
      expect(find.byKey(const Key('points-disponibles')), findsOneWidget);
      await tap(tester, find.byKey(const Key('vue-inventaire')));
      expect(find.byKey(const Key('attaque-0')), findsOneWidget);
      expect(find.textContaining('Toucher CaC'), findsOneWidget);
    });

    testWidgets('fiche hors séance : inventaire et compétences verrouillés',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final personnages = PersonnagesController(
        EnMemoirePersonnageRepository([_brom()]),
      )..restrictions = (_) => (inventaire: true, competences: true);
      await personnages.charger();
      await tester.pumpWidget(MaterialApp(
        home: FicheScreen(
          personnageId: 'brom',
          referentiel: _referentiel,
          controller: personnages,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bouton-monter-niveau')), findsNothing);
      await tap(tester, find.text('Compétences').first);
      expect(find.byKey(const Key('competences-verrouillees')), findsOneWidget);
      expect(find.byKey(const Key('depenser-points')), findsNothing);
      await tap(tester, find.text('Inventaire').first);
      expect(find.byKey(const Key('inventaire-lecture')), findsOneWidget);
    });

    testWidgets('MJ : permissions et taille des portions', (tester) async {
      final x = await ouvrir(tester, 'mj');
      await tap(tester, find.byKey(const Key('seance-parametres')));
      expect(find.byKey(const Key('portion-centre')), findsOneWidget);
      await tap(tester, find.byKey(const Key('pj-voient-pv-creatures')));
      expect(
        x.base.campagnes[x.campagne.id]!.parametres.pjVoientPvCreatures,
        isTrue,
      );
    });

    testWidgets('téléphone : trois vues, une carte ouvre le détail',
        (tester) async {
      await ouvrir(tester, 'mj', taille: const Size(420, 900));
      expect(find.byKey(const Key('vue-cartes')), findsOneWidget);
      await tap(tester, find.byKey(const Key('carte-script')));
      expect(find.byKey(const Key('texte-seance')), findsOneWidget);
      await tap(tester, find.byKey(const Key('vue-des')));
      expect(find.byKey(const Key('lancer-seance')), findsOneWidget);
    });
  });
}
