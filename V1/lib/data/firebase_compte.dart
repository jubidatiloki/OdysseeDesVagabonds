import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'compte.dart';

/// Compte Firebase : e-mail + mot de passe, ou Google.
class FirebaseServiceCompte implements ServiceCompte {
  FirebaseServiceCompte([FirebaseAuth? auth])
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  bool get disponible => true;

  static Utilisateur? _convertir(User? u) => u == null
      ? null
      : Utilisateur(uid: u.uid, email: u.email, nom: u.displayName);

  @override
  Utilisateur? get actuel => _convertir(_auth.currentUser);

  @override
  Stream<Utilisateur?> get changements =>
      _auth.authStateChanges().map(_convertir);

  /// Traduit les erreurs Firebase en messages pour le joueur.
  Future<void> _essayer(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw ErreurCompte(messageErreur(e.code));
    }
  }

  /// Message en français d'un code d'erreur Firebase.
  static String messageErreur(String code) => switch (code) {
        'invalid-email' => 'Adresse e-mail invalide.',
        'user-disabled' => 'Ce compte a été désactivé.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'E-mail ou mot de passe incorrect.',
        'email-already-in-use' =>
          'Un compte existe déjà avec cette adresse : connecte-toi.',
        'weak-password' =>
          'Mot de passe trop faible (6 caractères au minimum).',
        'too-many-requests' =>
          'Trop d\'essais : patiente quelques minutes avant de réessayer.',
        'network-request-failed' =>
          'Pas de connexion internet : réessaie une fois connecté.',
        'popup-closed-by-user' ||
        'cancelled-popup-request' ||
        'web-context-canceled' =>
          'Connexion Google annulée.',
        'requires-recent-login' =>
          'Par sécurité, reconnecte-toi avant de supprimer ton compte.',
        'operation-not-allowed' =>
          'Ce mode de connexion n\'est pas activé dans Firebase.',
        _ => 'Erreur de connexion ($code).',
      };

  @override
  Future<void> connexionEmail(String email, String motDePasse) =>
      _essayer(() => _auth.signInWithEmailAndPassword(
          email: email.trim(), password: motDePasse));

  @override
  Future<void> creerCompte(String email, String motDePasse) =>
      _essayer(() => _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: motDePasse));

  @override
  Future<void> connexionGoogle() => _essayer(() async {
        final google = GoogleAuthProvider()
          ..setCustomParameters({
            'prompt': 'select_account',
          });
        // Web : fenêtre Google ; Android : page Google dans le navigateur.
        if (kIsWeb) {
          await _auth.signInWithPopup(google);
        } else {
          await _auth.signInWithProvider(google);
        }
      });

  @override
  Future<void> motDePasseOublie(String email) =>
      _essayer(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> deconnexion() => _auth.signOut();

  @override
  Future<void> supprimerCompte() => _essayer(() async {
        await _auth.currentUser?.delete();
      });
}
