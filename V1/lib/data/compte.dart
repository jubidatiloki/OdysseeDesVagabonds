import 'dart:async';

/// Compte du joueur (phase 2 : sauvegarde en ligne). L'interface permet de
/// remplacer Firebase par un faux compte dans les tests.

/// Utilisateur connecté.
class Utilisateur {
  const Utilisateur({required this.uid, this.email, this.nom});

  /// Identifiant unique du compte (Firebase).
  final String uid;
  final String? email;

  /// Nom affiché (compte Google).
  final String? nom;
}

/// Erreur de connexion, avec un message en français pour le joueur.
class ErreurCompte implements Exception {
  const ErreurCompte(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Connexion, création de compte et déconnexion.
abstract class ServiceCompte {
  /// `false` : pas de compte possible sur cette plateforme (Windows) ; les
  /// personnages restent sur l'appareil.
  bool get disponible;

  /// Utilisateur connecté, ou `null` (personnages sur l'appareil).
  Utilisateur? get actuel;

  /// Connexions et déconnexions (y compris au démarrage).
  Stream<Utilisateur?> get changements;

  Future<void> connexionEmail(String email, String motDePasse);
  Future<void> creerCompte(String email, String motDePasse);
  Future<void> connexionGoogle();

  /// Envoie un e-mail pour choisir un nouveau mot de passe.
  Future<void> motDePasseOublie(String email);
  Future<void> deconnexion();

  /// Supprime le compte (les personnages en ligne sont supprimés avant).
  Future<void> supprimerCompte();
}

/// Plateforme sans compte (Windows, tests) : tout reste sur l'appareil.
class AucunCompte implements ServiceCompte {
  const AucunCompte();

  static const _message =
      ErreurCompte('Le compte n\'est pas disponible sur cet appareil.');

  @override
  bool get disponible => false;
  @override
  Utilisateur? get actuel => null;
  @override
  Stream<Utilisateur?> get changements => const Stream.empty();
  @override
  Future<void> connexionEmail(String email, String motDePasse) =>
      Future.error(_message);
  @override
  Future<void> creerCompte(String email, String motDePasse) =>
      Future.error(_message);
  @override
  Future<void> connexionGoogle() => Future.error(_message);
  @override
  Future<void> motDePasseOublie(String email) => Future.error(_message);
  @override
  Future<void> deconnexion() async {}
  @override
  Future<void> supprimerCompte() async {}
}
