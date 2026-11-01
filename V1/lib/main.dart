import 'package:flutter/material.dart';

import 'app.dart';
import 'data/local_personnage_repository.dart';
import 'data/referentiel.dart';
import 'state/personnages_controller.dart';
import 'state/preferences_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Données de référence (races, classes) embarquées dans l'app.
  final referentiel = await Referentiel.charger();

  // Personnages du joueur, sauvegardés localement sur l'appareil.
  final controller = PersonnagesController(LocalPersonnageRepository());
  await controller.charger();

  // Préférences (thème clair / sombre).
  final preferences = await PreferencesController.charger(PreferencesLocales());

  runApp(
    OdvApp(
      referentiel: referentiel,
      controller: controller,
      preferences: preferences,
    ),
  );
}
