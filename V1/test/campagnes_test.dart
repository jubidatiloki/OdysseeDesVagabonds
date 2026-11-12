import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/campagnes.dart';
import 'package:odyssee_vagabonds/data/compte.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/campagne.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/screens/campagnes/campagnes_screen.dart';
import 'package:odyssee_vagabonds/screens/creation_screen.dart';
import 'package:odyssee_vagabonds/state/campagnes_controller.dart';
import 'package:odyssee_vagabonds/state/compte_controller.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';

/// Campagnes (03/11/2026) : parties à plusieurs menées par un MJ, code
/// d'invitation validé par le MJ, un personnage par joueur, fiches
/// partagées selon les paramètres, séances.

/// Compte déjà connecté (ou non) pour les tests.
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

Personnage _brom() => Personnage(
      id: 'brom',
      nom: 'Brom',
      raceId: 'nain',
      classeId: 'guerrier',
      niveau: 2,
    );

MembreCampagne _membre(String uid, String nom, Personnage p) => MembreCampagne(
      uid: uid,
      nom: nom,
      personnageId: p.id,
      personnageNom: p.nom,
      personnageResume: 'Nain · Guerrier · niveau ${p.niveau}',
      date: DateTime(2026, 11, 3),
    );

/// Contrôleurs d'un compte connecté à [base].
Future<
        ({
          CompteController compte,
          CampagnesController campagnes,
          PersonnagesController personnages,
        })>
    _connecter(BaseCampagnesMemoire base, Utilisateur? u,
        {List<Personnage> fiches = const []}) async {
  final personnages = PersonnagesController(EnMemoirePersonnageRepository());
  await personnages.charger();
  final compte = CompteController(
    service: _Compte(u),
    personnages: personnages,
    local: personnages.repository,
    depotEnLigne: (_) => EnMemoireDepotEnLigne(fiches),
  );
  await compte.demarrer();
  final campagnes = CampagnesController(
    compte: compte,
    service: (u) => ServiceCampagnesMemoire(base, u.uid),
  );
  return (compte: compte, campagnes: campagnes, personnages: personnages);
}

void main() {
  group('code d\'invitation', () {
    test('un mot et 4 chiffres, saisie tolérante', () {
      final code = CodeInvitation.generer(Random(1));
      expect(CodeInvitation.valide(code), isTrue);
      expect(code, matches(RegExp(r'^[A-Z]+-\d{4}$')));
      expect(CodeInvitation.normaliser(' loup 4827 '), 'LOUP-4827');
      expect(CodeInvitation.normaliser('loup4827'), 'LOUP-4827');
      expect(CodeInvitation.normaliser('Loup-4827'), 'LOUP-4827');
      expect(CodeInvitation.valide('LOUP-48'), isFalse);
    });
  });

  group('service (MJ et joueurs)', () {
    late BaseCampagnesMemoire base;
    late ServiceCampagnesMemoire mj, joueur, autre;

    setUp(() {
      base = BaseCampagnesMemoire(Random(3));
      mj = ServiceCampagnesMemoire(base, 'mj');
      joueur = ServiceCampagnesMemoire(base, 'j1');
      autre = ServiceCampagnesMemoire(base, 'j2');
    });

    test('création : nom obligatoire, code, script privé', () async {
      expect(() => mj.creer(nom: '  ', mjNom: 'Ben'),
          throwsA(isA<ErreurCampagne>()));
      final c = await mj.creer(
        nom: ' Les ombres de Valfroid ',
        mjNom: 'Ben',
        prive: const PriveCampagne(script: 'Acte I', notes: 'PNJ'),
        parametres: const ParametresCampagne(joueursMax: 2),
      );
      expect(c.nom, 'Les ombres de Valfroid');
      expect(CodeInvitation.valide(c.code), isTrue);
      expect((await mj.lirePrive(c.id)).script, 'Acte I');
      // Le script n'est pas lisible par un joueur.
      expect(() => joueur.lirePrive(c.id), throwsA(isA<ErreurCampagne>()));
    });

    test('rejoindre : code, demande, acceptation par le MJ', () async {
      final c = await mj.creer(
        nom: 'Valfroid',
        mjNom: 'Ben',
        parametres: const ParametresCampagne(joueursMax: 1),
      );
      final trouvee = await joueur.trouverParCode(c.code.toLowerCase());
      expect(trouvee.id, c.id);
      await joueur.demander(trouvee, _membre('j1', 'Léa', _brom()));
      expect(base.campagnes[c.id]!.demandes, ['j1']);
      expect(base.membres[c.id]!['j1']!.statut, StatutMembre.demande);
      // Un joueur ne peut pas accepter.
      expect(() => joueur.accepter(c, 'j1'), throwsA(isA<ErreurCampagne>()));
      await mj.accepter(c, 'j1');
      final apres = base.campagnes[c.id]!;
      expect(apres.joueurs, ['j1']);
      expect(apres.demandes, isEmpty);
      expect(base.membres[c.id]!['j1']!.statut, StatutMembre.accepte);
      // Complète (1 joueur max) : plus de demande possible.
      await expectLater(
        autre.demander(apres, _membre('j2', 'Tom', _brom())),
        throwsA(isA<ErreurCampagne>()
            .having((e) => e.message, 'message', contains('complète'))),
      );
      // Le MJ ne peut pas rejoindre sa propre campagne.
      expect(() => mj.demander(apres, _membre('mj', 'Ben', _brom())),
          throwsA(isA<ErreurCampagne>()));
    });

    test('refus, départ, nouveau code', () async {
      final c = await mj.creer(nom: 'Valfroid', mjNom: 'Ben');
      await joueur.demander(c, _membre('j1', 'Léa', _brom()));
      await mj.retirer(c, 'j1');
      expect(base.campagnes[c.id]!.demandes, isEmpty);
      expect(base.membres[c.id], isEmpty);
      await joueur.demander(c, _membre('j1', 'Léa', _brom()));
      await mj.accepter(c, 'j1');
      await joueur.quitter(base.campagnes[c.id]!);
      expect(base.campagnes[c.id]!.joueurs, isEmpty);
      // Nouveau code : l'ancien ne marche plus.
      final nouveau = await mj.nouveauCode(base.campagnes[c.id]!);
      expect(nouveau, isNot(c.code));
      await expectLater(
          joueur.trouverParCode(c.code), throwsA(isA<ErreurCampagne>()));
      expect((await joueur.trouverParCode(nouveau)).id, c.id);
    });

    test('séances numérotées, démarrées et terminées par le MJ', () async {
      final c = await mj.creer(nom: 'Valfroid', mjNom: 'Ben');
      expect(() => joueur.demarrerSeance(c), throwsA(isA<ErreurCampagne>()));
      await mj.demarrerSeance(c);
      expect(base.campagnes[c.id]!.seance?.numero, 1);
      expect(base.campagnes[c.id]!.seanceEnCours, isTrue);
      await mj.terminerSeance(c);
      expect(base.campagnes[c.id]!.seanceEnCours, isFalse);
      await mj.demarrerSeance(c);
      expect(base.campagnes[c.id]!.seance?.numero, 2);
    });

    test('suppression : campagne, code et membres', () async {
      final c = await mj.creer(nom: 'Valfroid', mjNom: 'Ben');
      expect(() => joueur.supprimer(c), throwsA(isA<ErreurCampagne>()));
      await mj.supprimer(c);
      expect(base.campagnes, isEmpty);
      expect(base.codes, isEmpty);
    });
  });

  group('contrôleur', () {
    test('changement de personnage : fiche partagée une fois en ligne',
        () async {
      final base = BaseCampagnesMemoire(Random(6));
      final brom = _brom();
      final aria = Personnage(
          id: 'aria', nom: 'Aria', raceId: 'nain', classeId: 'guerrier');
      base.fiches['brom'] =
          (fiche: brom, proprietaire: 'j1', partage: [], editeurs: []);
      final mj =
          await _connecter(base, const Utilisateur(uid: 'mj', nom: 'Ben'));
      final j = await _connecter(base, const Utilisateur(uid: 'j1', nom: 'Léa'),
          fiches: [brom, aria]);
      final s = mj.campagnes.serviceActuel!;
      final c = await s.creer(nom: 'Loup', mjNom: 'Ben');
      final sj = j.campagnes.serviceActuel!;
      await sj.demander(c, _membre('j1', 'Léa', brom));
      await s.accepter(base.campagnes[c.id]!, 'j1');
      await pumpEventQueue();
      expect(base.fiches['brom']!.partage, ['mj']);

      // Changement pour Aria, pas encore en ligne (envoi différé) : le
      // partage échoue, sans bloquer.
      await sj.quitter(base.campagnes[c.id]!);
      await sj.demander(base.campagnes[c.id]!, _membre('j1', 'Léa', aria));
      await s.accepter(base.campagnes[c.id]!, 'j1');
      await pumpEventQueue();
      expect(base.fiches['aria'], isNull);
      expect(base.fiches['brom']!.partage, isEmpty);

      // La fiche arrive en ligne ; à la synchronisation suivante, elle est
      // partagée avec le MJ (lecture et modification).
      base.fiches['aria'] =
          (fiche: aria, proprietaire: 'j1', partage: [], editeurs: []);
      await j.compte.synchroniser();
      await pumpEventQueue();
      expect(base.fiches['aria']!.partage, ['mj']);
      expect(base.fiches['aria']!.editeurs, ['mj']);
      expect(await s.lireFiche('aria'), isNotNull);

      for (final x in [mj, j]) {
        x.campagnes.dispose();
        x.compte.dispose();
        x.personnages.dispose();
      }
    });

    test('MJ / joueur, séance signalée, fiche partagée avec le MJ', () async {
      final base = BaseCampagnesMemoire(Random(5));
      final brom = _brom();
      base.fiches['brom'] =
          (fiche: brom, proprietaire: 'j1', partage: [], editeurs: []);
      final mj =
          await _connecter(base, const Utilisateur(uid: 'mj', nom: 'Ben'));
      final j = await _connecter(base, const Utilisateur(uid: 'j1', nom: 'Léa'),
          fiches: [brom]);
      final seances = <Campagne>[];
      final abonnement = j.campagnes.nouvellesSeances.listen(seances.add);

      final s = mj.campagnes.serviceActuel!;
      final c = await s.creer(nom: 'Valfroid', mjNom: 'Ben');
      await pumpEventQueue();
      expect(mj.campagnes.commeMj.single.nom, 'Valfroid');
      expect(mj.campagnes.commeJoueur, isEmpty);

      await j.campagnes.serviceActuel!.demander(c, _membre('j1', 'Léa', brom));
      await pumpEventQueue();
      expect(j.campagnes.commeJoueur.single.id, c.id);
      // Fiche visible du MJ (paramètre par défaut) dès la demande.
      expect(base.fiches['brom']!.partage, ['mj']);
      expect(await s.lireFiche('brom'), isNotNull);

      await s.accepter(c, 'j1');
      await s.demarrerSeance(base.campagnes[c.id]!);
      await pumpEventQueue();
      expect(j.campagnes.seancesEnCours.single.id, c.id);
      expect(seances.single.seance?.numero, 1);

      // Le joueur quitte : sa fiche n'est plus partagée.
      await j.campagnes.serviceActuel!.quitter(base.campagnes[c.id]!);
      await pumpEventQueue();
      expect(j.campagnes.commeJoueur, isEmpty);
      expect(base.fiches['brom']!.partage, isEmpty);
      expect(await s.lireFiche('brom'), isNull);

      await abonnement.cancel();
      for (final x in [mj, j]) {
        x.campagnes.dispose();
        x.compte.dispose();
        x.personnages.dispose();
      }
    });
  });

  group('écrans', () {
    Future<
        ({
          CompteController compte,
          CampagnesController campagnes,
          PersonnagesController personnages,
        })> ouvrir(
      WidgetTester tester,
      BaseCampagnesMemoire base,
      Utilisateur? u, {
      List<Personnage> fiches = const [],
    }) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final x = await _connecter(base, u, fiches: fiches);
      await tester.pumpWidget(MaterialApp(
        home: CampagnesScreen(
          contexte: ContexteCampagnes(
            campagnes: x.campagnes,
            personnages: x.personnages,
            referentiel: const Referentiel(
              races: [_nain],
              classes: [_guerrier],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      return x;
    }

    Future<void> tap(WidgetTester tester, Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    testWidgets('sans compte : invitation à se connecter', (tester) async {
      await ouvrir(tester, BaseCampagnesMemoire(), null);
      expect(find.byKey(const Key('campagnes-connexion')), findsOneWidget);
      expect(find.byKey(const Key('campagnes-mj')), findsNothing);
    });

    testWidgets('MJ : création en 4 étapes, code à envoyer, onglets',
        (tester) async {
      final base = BaseCampagnesMemoire(Random(9));
      await ouvrir(tester, base, const Utilisateur(uid: 'mj', nom: 'Ben'));
      expect(find.text('En tant que maître du jeu'), findsOneWidget);
      expect(find.text('En tant que joueur'), findsOneWidget);
      await tap(tester, find.byKey(const Key('campagnes-mj')));
      await tap(tester, find.byKey(const Key('nouvelle-campagne')));
      await tester.enterText(
          find.byKey(const Key('campagne-nom')), 'Les ombres de Valfroid');
      await tap(tester, find.byKey(const Key('etape-suivante-0')));
      await tester.enterText(
          find.byKey(const Key('campagne-script')), 'Acte I : la brume');
      await tap(tester, find.byKey(const Key('etape-suivante-1')));
      await tap(tester, find.byKey(const Key('etape-suivante-2')));
      // Paramètres : 3 joueurs au plus.
      await tap(tester, find.byKey(const Key('joueurs-max-moins')));
      await tap(tester, find.byKey(const Key('joueurs-max-moins')));
      await tap(tester, find.byKey(const Key('creer-campagne')));

      final c = base.campagnes.values.single;
      expect(c.nom, 'Les ombres de Valfroid');
      expect(c.parametres.joueursMax, 3);
      expect(base.prives[c.id]!.script, 'Acte I : la brume');
      // Directement la page de la campagne, avec le code à copier.
      expect(find.text(c.code), findsOneWidget);
      expect(find.byKey(const Key('copier-code')), findsOneWidget);
      expect(find.byKey(const Key('code-campagne')), findsOneWidget);
      expect(find.byKey(const Key('onglet-script')), findsOneWidget);

      // Démarrer une séance.
      await tap(tester, find.byKey(const Key('bouton-seance')));
      await tap(tester, find.byKey(const Key('confirmer-seance')));
      expect(base.campagnes[c.id]!.seanceEnCours, isTrue);
      await tap(tester, find.byKey(const Key('seance-parametres')));
      expect(find.byKey(const Key('etat-seance')), findsOneWidget);
      await tap(tester, find.byKey(const Key('terminer-seance')));
      await tap(tester, find.byKey(const Key('confirmer-cloture')));
      expect(base.campagnes[c.id]!.seanceEnCours, isFalse);
    });

    testWidgets('rejoindre la séance ferme le message d\'avertissement',
        (tester) async {
      final base = BaseCampagnesMemoire(Random(6));
      final mj = ServiceCampagnesMemoire(base, 'mj');
      final c = await mj.creer(nom: 'Valfroid', mjNom: 'Ben');
      await mj.demarrerSeance(c);
      final x = await ouvrir(tester, base, const Utilisateur(uid: 'j1'));
      final contexte = ContexteCampagnes(
        campagnes: x.campagnes,
        personnages: x.personnages,
        referentiel: const Referentiel(races: [_nain], classes: [_guerrier]),
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Séance démarrée')),
                );
              },
              onLongPress: () =>
                  ouvrirSeance(context, contexte, base.campagnes[c.id]!),
              child: const Text('action'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('action'));
      await tester.pumpAndSettle();
      expect(find.text('Séance démarrée'), findsOneWidget);
      await tester.longPress(find.text('action'));
      await tester.pumpAndSettle();
      expect(find.text('Séance démarrée'), findsNothing);
    });

    testWidgets('joueur : code, personnage, demande envoyée', (tester) async {
      final base = BaseCampagnesMemoire(Random(4));
      final c = await ServiceCampagnesMemoire(base, 'mj')
          .creer(nom: 'Valfroid', mjNom: 'Ben', description: 'Brume et loups');
      final x = await ouvrir(
        tester,
        base,
        const Utilisateur(uid: 'j1', nom: 'Léa'),
        fiches: [_brom()],
      );
      await tap(tester, find.byKey(const Key('campagnes-joueur')));
      await tap(tester, find.byKey(const Key('rejoindre-campagne')));
      // Code inconnu : message clair.
      await tester.enterText(
          find.byKey(const Key('code-rejoindre')), 'ours 1111');
      await tap(tester, find.byKey(const Key('chercher-campagne')));
      expect(find.byKey(const Key('erreur-rejoindre')), findsOneWidget);
      // Bon code (saisi en minuscules) : la campagne s'affiche.
      await tester.enterText(find.byKey(const Key('code-rejoindre')),
          c.code.toLowerCase().replaceAll('-', ' '));
      await tap(tester, find.byKey(const Key('chercher-campagne')));
      expect(find.text('Brume et loups'), findsOneWidget);
      await tap(tester, find.byKey(const Key('choisir-brom')));
      await tap(tester, find.byKey(const Key('envoyer-demande')));
      expect(base.campagnes[c.id]!.demandes, ['j1']);
      expect(base.membres[c.id]!['j1']!.personnageNom, 'Brom');
      expect(find.text('Valfroid'), findsOneWidget);
      expect(find.textContaining('En attente du MJ'), findsOneWidget);
      // Le message de confirmation se ferme tout seul.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      x.campagnes.dispose();
    });

    testWidgets('joueur sans personnage : le crée en rejoignant',
        (tester) async {
      final base = BaseCampagnesMemoire(Random(4));
      final c = await ServiceCampagnesMemoire(base, 'mj')
          .creer(nom: 'Valfroid', mjNom: 'Ben', description: 'Brume');
      final x = await ouvrir(
        tester,
        base,
        const Utilisateur(uid: 'j1', nom: 'Léa'),
      );
      await tap(tester, find.byKey(const Key('campagnes-joueur')));
      await tap(tester, find.byKey(const Key('rejoindre-campagne')));
      await tester.enterText(find.byKey(const Key('code-rejoindre')), c.code);
      await tap(tester, find.byKey(const Key('chercher-campagne')));
      expect(find.textContaining('crée-le maintenant'), findsOneWidget);
      await tap(tester, find.byKey(const Key('creer-personnage-rejoindre')));
      // L'assistant de création s'ouvre, en mode « rendre le nouveau ».
      final creation =
          tester.widget<CreationScreen>(find.byType(CreationScreen));
      expect(creation.rendreLeNouveau, isTrue);
      // Fin de l'assistant (simulée) : le personnage est enregistré, puis
      // choisi pour la demande.
      await x.personnages.sauvegarder(_brom());
      Navigator.of(tester.element(find.byType(CreationScreen))).pop('brom');
      await tester.pumpAndSettle();
      expect(find.byType(CreationScreen), findsNothing);
      expect(
        tester
            .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
            .groupValue,
        'brom',
      );
      await tap(tester, find.byKey(const Key('envoyer-demande')));
      expect(base.membres[c.id]!['j1']!.personnageNom, 'Brom');
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      x.campagnes.dispose();
    });
  });
}
