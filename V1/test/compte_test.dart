import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/compte.dart';
import 'package:odyssee_vagabonds/data/depot_differe.dart';
import 'package:odyssee_vagabonds/data/firebase_compte.dart';
import 'package:odyssee_vagabonds/data/firestore_personnage_repository.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/screens/compte_screen.dart';
import 'package:odyssee_vagabonds/state/compte_controller.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';

/// Compte et sauvegarde en ligne (02/11/2026) : sans compte, fiches sur
/// l'appareil ; à la connexion, envoi sans doublon puis liste en ligne qui
/// suit les autres appareils ; déconnexion ; suppression du compte.

/// Faux compte : connexion immédiate, mot de passe « secret ».
class _FauxCompte implements ServiceCompte {
  final _flux = StreamController<Utilisateur?>.broadcast();
  Utilisateur? _actuel;
  bool supprime = false;

  void _changer(Utilisateur? u) {
    _actuel = u;
    _flux.add(u);
  }

  @override
  bool get disponible => true;
  @override
  Utilisateur? get actuel => _actuel;
  @override
  Stream<Utilisateur?> get changements => _flux.stream;
  @override
  Future<void> connexionEmail(String email, String motDePasse) async {
    if (motDePasse != 'secret') {
      throw const ErreurCompte('E-mail ou mot de passe incorrect.');
    }
    _changer(Utilisateur(uid: 'u1', email: email));
  }

  @override
  Future<void> creerCompte(String email, String motDePasse) =>
      connexionEmail(email, motDePasse);
  @override
  Future<void> connexionGoogle() async =>
      _changer(const Utilisateur(uid: 'u1', nom: 'Joueur'));
  @override
  Future<void> motDePasseOublie(String email) async {}
  @override
  Future<void> deconnexion() async => _changer(null);
  @override
  Future<void> supprimerCompte() async {
    supprime = true;
    _changer(null);
  }
}

Personnage _p(String id, String nom, DateTime modifie) => Personnage(
      id: id,
      nom: nom,
      raceId: 'humain',
      classeId: 'guerrier',
      modifieLe: modifie,
    );

void main() {
  final hier = DateTime(2026, 11, 1);
  final aujourdhui = DateTime(2026, 11, 2);

  late EnMemoirePersonnageRepository local;
  late EnMemoireDepotEnLigne enLigne;
  late PersonnagesController personnages;
  late _FauxCompte service;
  late CompteController compte;
  late StockageCompteMemoire stockage;

  setUp(() async {
    local = EnMemoirePersonnageRepository();
    enLigne = EnMemoireDepotEnLigne();
    personnages = PersonnagesController(local);
    service = _FauxCompte();
    stockage = StockageCompteMemoire();
    compte = CompteController(
      stockage: stockage,
      service: service,
      personnages: personnages,
      local: local,
      depotEnLigne: (uid) => uid == 'u1' ? enLigne : EnMemoireDepotEnLigne(),
    );
  });

  tearDown(() {
    compte.dispose();
    personnages.dispose();
  });

  test('sans compte : fiches sur l\'appareil', () async {
    await local.sauvegarder(_p('a', 'Brom', hier));
    await personnages.charger();
    await compte.demarrer();
    expect(compte.etat, EtatSynchro.surAppareil);
    expect(personnages.personnages.map((p) => p.nom), ['Brom']);
  });

  test('connexion : fiches de l\'appareil envoyées, la plus récente gagne',
      () async {
    // Sur l'appareil : Brom (modifié aujourd'hui) et Lya ; en ligne : Brom
    // plus ancien et Kael (créé sur un autre appareil).
    final brom = _p('a', 'Brom (appareil)', aujourdhui);
    local
      ..sauvegarder(brom)
      ..sauvegarder(_p('b', 'Lya', hier));
    brom.modifieLe = aujourdhui;
    await enLigne.importer([
      _p('a', 'Brom (en ligne)', hier),
      _p('c', 'Kael', hier),
    ]);
    await compte.demarrer();
    await service.connexionEmail('joueur@exemple.fr', 'secret');
    await pumpEventQueue();

    expect(compte.etat, EtatSynchro.synchronise);
    expect(compte.message, '2 fiches de cet appareil envoyées sur ton compte.');
    expect(
      (await enLigne.tous()).map((p) => p.nom),
      unorderedEquals(['Brom (appareil)', 'Lya', 'Kael']),
    );
    // Plus rien sur l'appareil ; la liste vient du compte.
    expect(await local.tous(), isEmpty);
    expect(personnages.repository, isA<DepotDiffere>());
    expect(personnages.personnages, hasLength(3));
  });

  test('une fiche en ligne plus récente n\'est pas écrasée', () async {
    await local.sauvegarder(_p('a', 'Vieux Brom', hier));
    (await local.tous()).single.modifieLe = hier;
    await enLigne.importer([_p('a', 'Brom à jour', aujourdhui)]);
    expect(await CompteController.envoyer(local, enLigne), 0);
    expect((await enLigne.tous()).single.nom, 'Brom à jour');
    expect(await local.tous(), isEmpty);
  });

  test('envoi impossible : les fiches restent sur l\'appareil', () async {
    await local.sauvegarder(_p('a', 'Brom', hier));
    enLigne.enPanne = true;
    await compte.demarrer();
    await service.connexionGoogle();
    await pumpEventQueue();
    expect(compte.etat, EtatSynchro.erreur);
    expect(compte.message, contains('restent sur l\'appareil'));
    expect((await local.tous()).single.nom, 'Brom');
    // Réseau revenu : « Réessayer l'envoi ».
    enLigne.enPanne = false;
    await compte.envoyerFichesLocales();
    expect(compte.etat, EtatSynchro.synchronise);
    expect((await enLigne.tous()).single.nom, 'Brom');
    expect(await local.tous(), isEmpty);
  });

  test('en ligne : la liste suit les changements d\'un autre appareil',
      () async {
    await compte.demarrer();
    await service.connexionEmail('joueur@exemple.fr', 'secret');
    await pumpEventQueue();
    expect(personnages.personnages, isEmpty);
    // Autre appareil : nouvelle fiche.
    await enLigne.importer([_p('z', 'Fiche du téléphone', aujourdhui)]);
    await pumpEventQueue();
    expect(personnages.personnages.single.nom, 'Fiche du téléphone');
  });

  test('déconnexion : retour à l\'appareil ; suppression : fiches recopiées',
      () async {
    await enLigne.importer([_p('a', 'Brom', hier)]);
    await compte.demarrer();
    await service.connexionEmail('joueur@exemple.fr', 'secret');
    await pumpEventQueue();
    expect(personnages.personnages, hasLength(1));
    await compte.deconnexion();
    await pumpEventQueue();
    expect(compte.etat, EtatSynchro.surAppareil);
    expect(personnages.personnages, isEmpty);

    await service.connexionEmail('joueur@exemple.fr', 'secret');
    await pumpEventQueue();
    await compte.supprimerCompte();
    await pumpEventQueue();
    expect(service.supprime, isTrue);
    expect(await enLigne.tous(), isEmpty);
    expect(personnages.personnages.single.nom, 'Brom');
  });

  test('document Firestore : propriétaire, partage, fiche complète', () {
    final p = _p('a', 'Brom', hier);
    final d = FirestorePersonnageRepository.versDocument(p, 'u1');
    expect(d['proprietaire'], 'u1');
    expect(d['partageAvec'], isEmpty);
    expect(d['nom'], 'Brom');
    final relu = FirestorePersonnageRepository.depuisDocument(d)!;
    expect((relu.id, relu.nom, relu.modifieLe), ('a', 'Brom', hier));
    expect(
        FirestorePersonnageRepository.depuisDocument({'fiche': '{'}), isNull);
  });

  test('messages d\'erreur en français', () {
    expect(FirebaseServiceCompte.messageErreur('wrong-password'),
        'E-mail ou mot de passe incorrect.');
    expect(FirebaseServiceCompte.messageErreur('email-already-in-use'),
        contains('existe déjà'));
    expect(FirebaseServiceCompte.messageErreur('zzz'), contains('zzz'));
  });

  testWidgets('page Compte : connexion, erreur, puis compte connecté',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await compte.demarrer();
    await tester.pumpWidget(MaterialApp(home: CompteScreen(compte: compte)));
    expect(find.text('Sur cet appareil'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('compte-email')), 'joueur@exemple.fr');
    await tester.enterText(
        find.byKey(const Key('compte-mot-de-passe')), 'faux');
    await tester.tap(find.byKey(const Key('compte-connexion')));
    await tester.pumpAndSettle();
    expect(find.text('E-mail ou mot de passe incorrect.'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('compte-mot-de-passe')), 'secret');
    await tester.tap(find.byKey(const Key('compte-connexion')));
    await tester.pumpAndSettle();
    expect(find.text('Synchronisé'), findsOneWidget);
    expect(find.textContaining('joueur@exemple.fr'), findsOneWidget);
    expect(find.byKey(const Key('compte-deconnexion')), findsOneWidget);
  });

  testWidgets('sans compte possible (Windows) : message', (tester) async {
    final hors = CompteController.horsLigne(personnages);
    await tester.pumpWidget(MaterialApp(home: CompteScreen(compte: hors)));
    expect(find.text('Compte indisponible'), findsOneWidget);
    expect(find.byKey(const Key('compte-email')), findsNothing);
  });

  group('méthode de sauvegarde', () {
    Future<Personnage> connecte() async {
      await enLigne.importer([_p('a', 'Brom', hier)]);
      await compte.demarrer();
      await service.connexionEmail('joueur@exemple.fr', 'secret');
      await pumpEventQueue();
      return personnages.personnages.single;
    }

    test('par défaut : automatique, envoi à chaque modification ; date',
        () async {
      expect(compte.derniereSynchro, isNull);
      final brom = await connecte();
      expect(compte.derniereSynchro, isNotNull);
      expect((
        compte.automatique,
        compte.aChaqueModification,
        compte.aChaqueLancer
      ), (
        true,
        true,
        true
      ));
      brom.nom = 'Brom le Brave';
      await personnages.sauvegarder(brom);
      expect((await enLigne.tous()).single.nom, 'Brom le Brave');
      expect(compte.nbEnAttente, 0);
      expect(stockage.valeurs['derniereSynchro'], isNotNull);
    });

    test('manuelle : en attente sur l\'appareil jusqu\'au bouton', () async {
      final brom = await connecte();
      await compte.regler(automatique: false);
      expect(stockage.valeurs['automatique'], 'false');
      brom.nom = 'Brom le Brave';
      await personnages.sauvegarder(brom);
      await personnages.sauvegarder(brom, lancer: true);
      await pumpEventQueue();
      // Rien n'est parti ; la liste montre la version de l'appareil.
      expect((await enLigne.tous()).single.nom, 'Brom');
      expect(personnages.personnages.single.nom, 'Brom le Brave');
      expect(compte.nbEnAttente, 1);
      expect(compte.etat, EtatSynchro.enAttente);
      // Gardé sur l'appareil (survit à la fermeture de l'app).
      expect(stockage.valeurs['attente.u1'], contains('Brom le Brave'));

      expect(await compte.synchroniser(), 1);
      expect((await enLigne.tous()).single.nom, 'Brom le Brave');
      expect(compte.etat, EtatSynchro.synchronise);
      expect(stockage.valeurs['attente.u1'], isNull);
    });

    test('à chaque lancer seulement : envoi au lancer de dé', () async {
      final brom = await connecte();
      await compte.regler(aChaqueModification: false);
      brom.pvActuels = 3;
      await personnages.sauvegarder(brom);
      expect((await enLigne.tous()).single.pvActuels, isNot(3));
      expect(compte.nbEnAttente, 1);
      // Lancer de dé : le lancer et les PV partent ensemble.
      brom.journaliser('Lancer · Attaque : 17');
      await personnages.sauvegarder(brom, lancer: true);
      final envoye = (await enLigne.tous()).single;
      expect(envoye.pvActuels, 3);
      expect(envoye.historique.last.message, 'Lancer · Attaque : 17');
      expect(compte.nbEnAttente, 0);
    });

    test('suppression en attente ; repasser en immédiat envoie tout', () async {
      await connecte();
      await compte.regler(automatique: false);
      await personnages.supprimer('a');
      expect(personnages.personnages, isEmpty);
      expect(await enLigne.tous(), hasLength(1));
      await compte.regler(automatique: true);
      expect(await enLigne.tous(), isEmpty);
      expect(compte.nbEnAttente, 0);
    });

    test('réglages relus au démarrage', () async {
      stockage.valeurs
        ..['automatique'] = 'true'
        ..['aChaqueModification'] = 'false'
        ..['derniereSynchro'] = '2026-11-02T19:42:00.000';
      await compte.demarrer();
      expect(compte.aChaqueModification, isFalse);
      expect(compte.aChaqueLancer, isTrue);
      expect(dateHeure(compte.derniereSynchro!), '02/11/2026 à 19:42');
    });

    testWidgets('page Compte : bloc Synchronisation', (tester) async {
      tester.view.physicalSize = const Size(900, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await compte.demarrer();
      await service.connexionEmail('joueur@exemple.fr', 'secret');
      await tester.pumpWidget(MaterialApp(home: CompteScreen(compte: compte)));
      await tester.pumpAndSettle();
      expect(
          find.textContaining('Dernière synchronisation : '), findsOneWidget);
      expect(find.byKey(const Key('sauvegarde-modification')), findsOneWidget);
      expect(find.byKey(const Key('synchroniser-maintenant')), findsNothing);
      // Manuelle : plus de cases, bouton « Synchroniser maintenant ».
      await tester.tap(find.text('Manuelle'));
      await tester.pumpAndSettle();
      expect(compte.automatique, isFalse);
      expect(find.byKey(const Key('sauvegarde-lancer')), findsNothing);
      await tester
          .ensureVisible(find.byKey(const Key('synchroniser-maintenant')));
      await tester.tap(find.byKey(const Key('synchroniser-maintenant')));
      await tester.pumpAndSettle();
      expect(find.text('Tout est déjà à jour.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });
}
