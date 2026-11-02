import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/referentiel.dart';
import 'screens/racine_screen.dart';
import 'state/compte_controller.dart';
import 'state/personnages_controller.dart';
import 'state/preferences_controller.dart';
import 'theme.dart';
import 'widgets/cadre_classe.dart';

class OdvApp extends StatelessWidget {
  OdvApp({
    super.key,
    required this.referentiel,
    required this.controller,
    PreferencesController? preferences,
    this.compte,
  }) : preferences = preferences ?? PreferencesController();

  /// Compte (sauvegarde en ligne) ; `null` : personnages sur l'appareil.
  final CompteController? compte;

  final Referentiel referentiel;
  final PersonnagesController controller;
  final PreferencesController preferences;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: preferences,
      builder: (context, _) => MaterialApp(
        title: "L'odyssée des vagabonds",
        debugShowCheckedModeBanner: false,
        theme: themeOdv(Brightness.light),
        darkTheme: themeOdv(Brightness.dark),
        themeMode: preferences.theme,
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Effets animés des cadres de classe (page Préférences).
        builder: (context, child) => AnimationsCadres(
          actives: preferences.animations,
          child: child!,
        ),
        home: RacineScreen(
          referentiel: referentiel,
          controller: controller,
          preferences: preferences,
          compte: compte,
        ),
      ),
    );
  }
}
