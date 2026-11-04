import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/compte.dart';
import '../data/depot_differe.dart';
import '../data/personnage_repository.dart';
import 'personnages_controller.dart';

/// Où sont les personnages et où en est l'envoi.
enum EtatSynchro {
  /// Sans compte : fiches sur cet appareil seulement.
  surAppareil('Sur cet appareil'),

  /// Connexion en cours : envoi des fiches de l'appareil.
  envoi('Synchronisation…'),

  /// Connecté : fiches en ligne, à jour sur tous les appareils.
  synchronise('Synchronisé'),

  /// Connecté, des modifications attendent d'être envoyées (sauvegarde
  /// au lancer de dé ou manuelle).
  enAttente('Modifications en attente'),

  /// Compte sans internet : copie des fiches sur l'appareil, envoyées au
  /// prochain démarrage connecté.
  horsConnexion('Hors connexion'),

  /// Connecté, mais des fiches de l'appareil n'ont pas pu être envoyées.
  erreur('Erreur de synchronisation');

  const EtatSynchro(this.libelle);
  final String libelle;
}

/// Compte du joueur : à la connexion, les fiches créées sur l'appareil sont
/// envoyées en ligne (sans doublon : la plus récente gagne) puis retirées de
/// l'appareil ; la liste des personnages vient alors du compte et suit les
/// autres appareils en direct. À la déconnexion : retour aux fiches de
/// l'appareil.
class CompteController extends ChangeNotifier {
  CompteController({
    required this.service,
    required this.personnages,
    required this.local,
    required this.depotEnLigne,
    StockageCompte? stockage,
  }) : stockage = stockage ?? StockageCompteMemoire();

  static const _cleDernierCompte = 'dernierCompte';
  static String _cleMiroir(String uid) => 'miroir.$uid';

  /// Firebase ne répond pas (web sans internet) : reprend le dernier compte
  /// depuis la copie de l'appareil ; sinon, fiches de l'appareil.
  static Future<CompteController> horsConnexion(
    PersonnagesController personnages,
    StockageCompte stockage,
  ) async {
    final compte = CompteController(
      service: const AucunCompte(),
      personnages: personnages,
      local: personnages.repository,
      depotEnLigne: (_) => throw UnsupportedError('hors connexion'),
      stockage: stockage,
    );
    final uid = await stockage.lire(_cleDernierCompte);
    if (uid == null) return compte;
    final depot = DepotDiffere(
      MiroirLocal(stockage, _cleMiroir(uid)),
      envoiImmediat: () => false,
      stockage: stockage,
      cle: 'attente.$uid',
      surAttente: compte.notifyListeners,
    );
    await depot.charger();
    compte
      .._depot = depot
      .._etat = EtatSynchro.horsConnexion;
    await personnages.utiliser(depot);
    return compte;
  }

  /// Sans compte possible (Windows, tests) : tout reste sur l'appareil.
  factory CompteController.horsLigne(PersonnagesController personnages) =>
      CompteController(
        service: const AucunCompte(),
        personnages: personnages,
        local: personnages.repository,
        depotEnLigne: (_) => throw UnsupportedError('pas de compte'),
      );

  final ServiceCompte service;
  final PersonnagesController personnages;

  /// Fiches gardées sur l'appareil (sans compte).
  final PersonnageRepository local;

  /// Stockage en ligne d'un compte (uid).
  final DepotEnLigne Function(String uid) depotEnLigne;

  /// Réglages gardés sur l'appareil (méthode de sauvegarde, date).
  final StockageCompte stockage;

  Utilisateur? _utilisateur;
  EtatSynchro _etat = EtatSynchro.surAppareil;
  String? _message;
  DepotDiffere? _depot;

  // Méthode de sauvegarde (par défaut : automatique, à chaque modification
  // et à chaque lancer de dé).
  bool _automatique = true;
  bool _aChaqueModification = true;
  bool _aChaqueLancer = true;
  DateTime? _derniereSynchro;

  /// Sauvegarde automatique (sinon : manuelle, bouton « Synchroniser
  /// maintenant »).
  bool get automatique => _automatique;

  /// Automatique : envoi à chaque modification d'un personnage.
  bool get aChaqueModification => _aChaqueModification;

  /// Automatique : envoi à chaque lancer de dé du personnage actif (le
  /// lancer est noté dans l'historique de la fiche).
  bool get aChaqueLancer => _aChaqueLancer;

  /// Dernier envoi réussi vers le compte ; `null` : jamais.
  DateTime? get derniereSynchro => _derniereSynchro;

  /// Modifications pas encore envoyées.
  int get nbEnAttente => _depot?.nbEnAttente ?? 0;

  /// Les modifications partent-elles tout de suite ?
  bool get envoiImmediat => _automatique && _aChaqueModification;
  StreamSubscription<Utilisateur?>? _ecoute;

  Utilisateur? get utilisateur => _utilisateur;
  EtatSynchro get etat => _etat == EtatSynchro.synchronise && nbEnAttente > 0
      ? EtatSynchro.enAttente
      : _etat;
  bool get connecte => _utilisateur != null;

  /// Dernier compte rendu (« 3 fiches envoyées », erreur…).
  String? get message => _message;

  /// Suit les connexions ; un compte déjà connecté est repris aussitôt.
  Future<void> demarrer() async {
    await _lireReglages();
    // Lancer de dé du personnage actif : envoi si la méthode le prévoit.
    // Envoi espacé d'au moins 5 s (DepotDiffere.delai).
    personnages.apresLancer = () async {
      if (_automatique && _aChaqueLancer && nbEnAttente > 0) {
        await _envoiAutomatique();
      }
    };
    _ecoute = service.changements.listen(_changement);
    await _changement(service.actuel);
  }

  Future<void> _changement(Utilisateur? u) async {
    if (u?.uid == _utilisateur?.uid) return;
    _utilisateur = u;
    if (u == null) {
      _depot?.fermer();
      _depot = null;
      // Déconnexion volontaire : plus de copie à reprendre hors connexion.
      await stockage.ecrire(_cleDernierCompte, null);
      _etat = EtatSynchro.surAppareil;
      notifyListeners();
      await personnages.utiliser(local);
      return;
    }
    final depot = DepotDiffere(
      depotEnLigne(u.uid),
      envoiImmediat: () => envoiImmediat,
      stockage: stockage,
      cle: 'attente.${u.uid}',
      surEnvoi: _marquerSynchro,
      surAttente: notifyListeners,
      surErreur: (_) => _erreurEnvoi(),
      cleMiroir: _cleMiroir(u.uid),
    );
    await stockage.ecrire(_cleDernierCompte, u.uid);
    await depot.charger();
    _depot = depot;
    await envoyerFichesLocales();
    await personnages.utiliser(depot);
    // Modifications restées en attente (app fermée avant l'envoi).
    if (envoiImmediat && nbEnAttente > 0) await _envoiAutomatique();
  }

  /// Envoie en ligne les fiches restées sur l'appareil (créées sans compte)
  /// puis les retire de l'appareil. Une fiche déjà en ligne n'est remplacée
  /// que si celle de l'appareil est plus récente.
  Future<void> envoyerFichesLocales() async {
    final depot = _depot;
    if (depot == null) return;
    _etat = EtatSynchro.envoi;
    notifyListeners();
    try {
      final n = await envoyer(local, depot);
      _etat = EtatSynchro.synchronise;
      _marquerSynchro();
      _message = n == 0
          ? null
          : '$n fiche${n > 1 ? 's' : ''} de cet appareil '
              'envoyée${n > 1 ? 's' : ''} sur ton compte.';
    } catch (e) {
      _etat = EtatSynchro.erreur;
      _message = 'Les fiches de cet appareil n\'ont pas pu être envoyées '
          '(connexion internet ?). Elles restent sur l\'appareil : '
          'réessaie plus tard.';
    }
    notifyListeners();
  }

  /// Envoie les fiches de [local] vers [depot] (la plus récente gagne) puis
  /// les retire de l'appareil ; renvoie le nombre de fiches envoyées.
  static Future<int> envoyer(
    PersonnageRepository local,
    DepotEnLigne depot,
  ) async {
    final locales = await local.tous();
    if (locales.isEmpty) return 0;
    final enLigne = {for (final p in await depot.tous()) p.id: p};
    final aEnvoyer = [
      for (final p in locales)
        if (enLigne[p.id] == null ||
            p.modifieLe.isAfter(enLigne[p.id]!.modifieLe))
          p,
    ];
    if (aEnvoyer.isNotEmpty) await depot.importer(aEnvoyer);
    // Envoi confirmé : les fiches ne restent plus que sur le compte.
    for (final p in locales) {
      await local.supprimer(p.id);
    }
    return aEnvoyer.length;
  }

  /// Envoi automatique, espacé d'au moins 5 s du précédent ; en cas
  /// d'échec, les modifications restent en attente.
  Future<void> _envoiAutomatique() async {
    try {
      await _depot?.planifierEnvoi();
    } catch (_) {
      _erreurEnvoi();
    }
  }

  void _erreurEnvoi() {
    _message = 'Synchronisation impossible (connexion internet ?) : les '
        'modifications restent en attente sur cet appareil.';
    notifyListeners();
  }

  /// Envoie maintenant les modifications en attente (bouton « Synchroniser
  /// maintenant », lancer de dé) ; renvoie leur nombre, ou `null` en cas
  /// d'échec (elles restent en attente).
  Future<int?> synchroniser() async {
    final depot = _depot;
    if (depot == null) return null;
    try {
      final n = await depot.envoyer().timeout(const Duration(seconds: 10));
      _etat = EtatSynchro.synchronise;
      _message = null;
      notifyListeners();
      return n;
    } catch (e) {
      _message = 'Synchronisation impossible (connexion internet ?) : les '
          'modifications restent en attente sur cet appareil.';
      notifyListeners();
      return null;
    }
  }

  /// Change la méthode de sauvegarde (gardée sur l'appareil). Repasser en
  /// envoi immédiat envoie ce qui attendait.
  Future<void> regler({
    bool? automatique,
    bool? aChaqueModification,
    bool? aChaqueLancer,
  }) async {
    _automatique = automatique ?? _automatique;
    _aChaqueModification = aChaqueModification ?? _aChaqueModification;
    _aChaqueLancer = aChaqueLancer ?? _aChaqueLancer;
    notifyListeners();
    await stockage.ecrire('automatique', '$_automatique');
    await stockage.ecrire('aChaqueModification', '$_aChaqueModification');
    await stockage.ecrire('aChaqueLancer', '$_aChaqueLancer');
    if (envoiImmediat && nbEnAttente > 0) await synchroniser();
  }

  Future<void> _lireReglages() async {
    Future<bool> oui(String cle) async => (await stockage.lire(cle)) != 'false';
    _automatique = await oui('automatique');
    _aChaqueModification = await oui('aChaqueModification');
    _aChaqueLancer = await oui('aChaqueLancer');
    _derniereSynchro =
        DateTime.tryParse(await stockage.lire('derniereSynchro') ?? '');
  }

  void _marquerSynchro() {
    _derniereSynchro = DateTime.now();
    stockage.ecrire('derniereSynchro', _derniereSynchro!.toIso8601String());
    notifyListeners();
  }

  Future<void> connexionEmail(String email, String motDePasse) =>
      service.connexionEmail(email, motDePasse);
  Future<void> creerCompte(String email, String motDePasse) =>
      service.creerCompte(email, motDePasse);
  Future<void> connexionGoogle() => service.connexionGoogle();
  Future<void> motDePasseOublie(String email) =>
      service.motDePasseOublie(email);
  Future<void> deconnexion() => service.deconnexion();

  /// Supprime le compte : les fiches sont d'abord recopiées sur cet
  /// appareil (rien n'est perdu), puis effacées en ligne.
  Future<void> supprimerCompte() async {
    final depot = _depot;
    if (depot != null) {
      for (final p in await depot.tous()) {
        await local.sauvegarder(p);
      }
      await depot.toutSupprimer();
    }
    await service.supprimerCompte();
  }

  @override
  void dispose() {
    _ecoute?.cancel();
    _depot?.fermer();
    super.dispose();
  }
}
