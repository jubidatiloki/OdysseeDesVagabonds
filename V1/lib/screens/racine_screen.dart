import 'dart:async';

import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/campagne.dart';
import '../state/campagnes_controller.dart';
import '../state/compte_controller.dart';
import '../state/personnages_controller.dart';
import '../state/historique_lancers.dart';
import '../state/preferences_controller.dart';
import '../widgets/menu_lateral.dart';
import 'a_propos_screen.dart';
import 'accueil_screen.dart';
import 'campagnes/campagnes_screen.dart';
import 'compte_screen.dart';
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
    this.compte,
    this.campagnes,
  });

  final Referentiel referentiel;
  final PersonnagesController controller;
  final PreferencesController preferences;

  /// Compte (sauvegarde en ligne) ; `null` : personnages sur l'appareil.
  final CompteController? compte;

  /// Campagnes (parties à plusieurs) ; `null` : « hors ligne ».
  final CampagnesController? campagnes;

  @override
  State<RacineScreen> createState() => _RacineScreenState();
}

class _RacineScreenState extends State<RacineScreen> {
  Section _section = Section.personnages;

  /// Pages de la section Campagnes.
  final _navCampagnes = GlobalKey<NavigatorState>();

  /// Onglet du Glossaire retenu quand on change de page.
  OngletGlossaire _ongletGlossaire = OngletGlossaire.classes;

  /// Historique des lancers de dés, gardé quand on change de page.
  final HistoriqueLancers _lancers = HistoriqueLancers();

  /// Compte : celui reçu, ou « sans compte » (tests, Windows).
  late final CompteController _compte =
      widget.compte ?? CompteController.horsLigne(widget.controller);

  /// Campagnes : celles reçues, ou « hors ligne » (tests, Windows).
  late final CampagnesController _campagnes =
      widget.campagnes ?? CampagnesController.horsLigne(_compte);
  StreamSubscription<Campagne>? _seances;

  late final ContexteCampagnes _contexteCampagnes = ContexteCampagnes(
    campagnes: _campagnes,
    personnages: widget.controller,
    referentiel: widget.referentiel,
    preferences: widget.preferences,
  );

  @override
  void initState() {
    super.initState();
    // Séance démarrée par un MJ : le joueur est averti où qu'il soit.
    _seances = _campagnes.nouvellesSeances.listen((c) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 10),
        content: Text('Séance ${c.seance?.numero ?? ''} de « ${c.nom} » : '
            '${c.mjNom} a démarré la partie.'),
        action: SnackBarAction(
          label: 'Rejoindre',
          onPressed: () => ouvrirSeance(context, _contexteCampagnes, c),
        ),
      ));
    });
  }

  @override
  void dispose() {
    _seances?.cancel();
    if (widget.campagnes == null) _campagnes.dispose();
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
      compte: _compte,
      campagnes: _campagnes,
    );
    // Menu fixe : les pages n'ont plus de tiroir (ni de bouton ☰).
    final MenuLateral? menu = fixe
        ? null
        : MenuLateral(
            courante: _section,
            controller: widget.controller,
            onChoisir: (s) => setState(() => _section = s),
            compte: _compte,
            campagnes: _campagnes,
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
      // Navigateur interne : les pages de campagne gardent le menu latéral.
      Section.campagnes => Navigator(
          key: _navCampagnes,
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => CampagnesScreen(
              contexte: _contexteCampagnes,
              menu: menu,
              onCompte: () => setState(() => _section = Section.compte),
            ),
          ),
        ),
      Section.glossaire => GlossaireScreen(
          referentiel: ref,
          menu: menu,
          onglet: _ongletGlossaire,
          onOnglet: (o) => _ongletGlossaire = o,
        ),
      Section.regles => ReglesScreen(referentiel: ref, menu: menu),
      Section.compte => CompteScreen(compte: _compte, menu: menu),
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
        if (didPop) return;
        final nav = _navCampagnes.currentState;
        if (_section == Section.campagnes && (nav?.canPop() ?? false)) {
          nav!.pop();
        } else {
          setState(() => _section = Section.personnages);
        }
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
