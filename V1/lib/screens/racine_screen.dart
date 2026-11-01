import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../state/personnages_controller.dart';
import '../state/historique_lancers.dart';
import '../state/preferences_controller.dart';
import '../widgets/menu_lateral.dart';
import 'a_propos_screen.dart';
import 'accueil_screen.dart';
import 'de_screen.dart';
import 'glossaire_screen.dart';
import 'nouveautes_screen.dart';
import 'preferences_screen.dart';
import 'regles_screen.dart';

/// Écran racine : affiche la section choisie dans le menu latéral.
/// Au démarrage : la liste des personnages.
class RacineScreen extends StatefulWidget {
  const RacineScreen({
    super.key,
    required this.referentiel,
    required this.controller,
    required this.preferences,
  });

  final Referentiel referentiel;
  final PersonnagesController controller;
  final PreferencesController preferences;

  @override
  State<RacineScreen> createState() => _RacineScreenState();
}

class _RacineScreenState extends State<RacineScreen> {
  Section _section = Section.personnages;

  /// Onglet du Glossaire retenu quand on change de page.
  OngletGlossaire _ongletGlossaire = OngletGlossaire.classes;

  /// Historique des lancers de dés, gardé quand on change de page.
  final HistoriqueLancers _lancers = HistoriqueLancers();

  @override
  void dispose() {
    _lancers.dispose();
    super.dispose();
  }

  /// Largeur d'écran à partir de laquelle le menu peut rester ouvert.
  static const double _largeurMenuFixe = 1000;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.preferences,
      builder: (context, _) => _construire(context),
    );
  }

  Widget _construire(BuildContext context) {
    final prefs = widget.preferences;
    final possible = MediaQuery.sizeOf(context).width >= _largeurMenuFixe;
    final fixe = possible && prefs.menuEpingle;
    final menuFixe = MenuLateral(
      courante: _section,
      controller: widget.controller,
      onChoisir: (s) => setState(() => _section = s),
      fixe: true,
    );
    // Menu fixe : les pages n'ont plus de tiroir (ni de bouton ☰).
    final MenuLateral? menu = fixe
        ? null
        : MenuLateral(
            courante: _section,
            controller: widget.controller,
            onChoisir: (s) => setState(() => _section = s),
          );
    final ref = widget.referentiel;
    final Widget page = switch (_section) {
      Section.personnages => AccueilScreen(
          referentiel: ref,
          controller: widget.controller,
          preferences: prefs,
          menu: menu,
        ),
      Section.de => DeScreen(
          menu: menu,
          referentiel: ref,
          personnages: widget.controller,
          preferences: prefs,
          historique: _lancers,
        ),
      Section.glossaire => GlossaireScreen(
          referentiel: ref,
          menu: menu,
          onglet: _ongletGlossaire,
          onOnglet: (o) => _ongletGlossaire = o,
        ),
      Section.regles => ReglesScreen(referentiel: ref, menu: menu),
      Section.preferences =>
        PreferencesScreen(preferences: widget.preferences, menu: menu),
      Section.nouveautes => NouveautesScreen(menu: menu),
      Section.aPropos => AProposScreen(menu: menu),
    };
    // Bouton « retour » (Android, navigateur) : revient à la liste des
    // personnages avant de quitter l'application.
    return PopScope(
      canPop: _section == Section.personnages,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _section = Section.personnages);
      },
      child: fixe
          ? Row(
              children: [
                SizedBox(width: MenuLateral.largeurFixe, child: menuFixe),
                const VerticalDivider(width: 1),
                Expanded(
                  child: KeyedSubtree(key: ValueKey(_section), child: page),
                ),
              ],
            )
          : KeyedSubtree(key: ValueKey(_section), child: page),
    );
  }
}
