import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'data/firebase_compte.dart';
import 'data/firestore_campagnes.dart';
import 'data/firestore_personnage_repository.dart';
import 'data/local_personnage_repository.dart';
import 'data/referentiel.dart';
import 'firebase_options.dart';
import 'state/campagnes_controller.dart';
import 'state/compte_controller.dart';
import 'state/personnages_controller.dart';
import 'state/preferences_controller.dart';

/// Compte en ligne possible : téléphone Android et version web (Firebase
/// n'est pas prévu pour une application Windows distribuée).
bool get compteEnLignePossible =>
    kIsWeb || defaultTargetPlatform == TargetPlatform.android;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Données de référence (races, classes) embarquées dans l'app.
  final referentiel = await Referentiel.charger();

  // Personnages du joueur : sur l'appareil sans compte, en ligne avec un
  // compte (voir CompteController).
  final local = LocalPersonnageRepository();
  final controller = PersonnagesController(local);
  await controller.charger();

  // Compte (Firebase). Sans réseau ou en cas d'erreur : l'app reste
  // utilisable avec les personnages de l'appareil.
  CompteController? compte;
  CampagnesController? campagnes;
  if (compteEnLignePossible) {
    try {
      // Sans internet sur le web, Firebase ne se charge pas : on n'attend pas.
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 8));
      // Fiches lisibles et modifiables hors connexion.
      FirebaseFirestore.instance.settings =
          const Settings(persistenceEnabled: true);
      compte = CompteController(
        service: FirebaseServiceCompte(),
        personnages: controller,
        local: local,
        depotEnLigne: FirestorePersonnageRepository.new,
        stockage: StockageCompteLocal(),
      );
      await compte.demarrer();
      campagnes = CampagnesController(
        compte: compte,
        service: (u) => FirestoreServiceCampagnes(u.uid),
      );
    } catch (e) {
      debugPrint('Firebase indisponible : $e');
      compte = await CompteController.horsConnexion(
        controller,
        StockageCompteLocal(),
      );
      campagnes = null;
    }
  }

  // Préférences (thème clair / sombre).
  final preferences = await PreferencesController.charger(PreferencesLocales());

  runApp(
    OdvApp(
      referentiel: referentiel,
      controller: controller,
      preferences: preferences,
      compte: compte,
      campagnes: campagnes,
    ),
  );
}
