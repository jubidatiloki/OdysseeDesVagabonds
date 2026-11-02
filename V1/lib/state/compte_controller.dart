import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/compte.dart';
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
  });

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

  Utilisateur? _utilisateur;
  EtatSynchro _etat = EtatSynchro.surAppareil;
  String? _message;
  DepotEnLigne? _depot;
  StreamSubscription<Utilisateur?>? _ecoute;

  Utilisateur? get utilisateur => _utilisateur;
  EtatSynchro get etat => _etat;
  bool get connecte => _utilisateur != null;

  /// Dernier compte rendu (« 3 fiches envoyées », erreur…).
  String? get message => _message;

  /// Suit les connexions ; un compte déjà connecté est repris aussitôt.
  Future<void> demarrer() async {
    _ecoute = service.changements.listen(_changement);
    await _changement(service.actuel);
  }

  Future<void> _changement(Utilisateur? u) async {
    if (u?.uid == _utilisateur?.uid) return;
    _utilisateur = u;
    if (u == null) {
      _depot = null;
      _etat = EtatSynchro.surAppareil;
      notifyListeners();
      await personnages.utiliser(local);
      return;
    }
    _depot = depotEnLigne(u.uid);
    await envoyerFichesLocales();
    await personnages.utiliser(_depot!);
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
    super.dispose();
  }
}
