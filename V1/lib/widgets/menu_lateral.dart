import 'package:flutter/material.dart';

import '../state/personnages_controller.dart';
import '../theme.dart';
import '../version.dart';

/// Les écrans accessibles depuis le menu latéral, dans l'ordre du menu.
enum Section {
  personnages('Personnages', Icons.groups_outlined, Icons.groups),
  de('Lancer de dé', Icons.casino_outlined, Icons.casino),
  // Classes, races, équipements et bestiaire, en onglets.
  glossaire('Glossaire', Icons.auto_stories_outlined, Icons.auto_stories),
  regles('Règles système', Icons.menu_book_outlined, Icons.menu_book),
  preferences('Préférences', Icons.settings_outlined, Icons.settings),
  // Journal des versions (changelog).
  nouveautes('Nouveautés', Icons.new_releases_outlined, Icons.new_releases),
  aPropos('À propos', Icons.info_outline, Icons.info);

  const Section(this.libelle, this.icone, this.iconeSelectionnee);

  final String libelle;
  final IconData icone;
  final IconData iconeSelectionnee;
}

/// Menu latéral : bandeau (logo + nombre de personnages) puis les écrans de
/// l'application. Dépliable (tiroir) ou fixe à gauche ([fixe] : option
/// « Garder le menu ouvert » des Préférences, sur grand écran).
class MenuLateral extends StatelessWidget {
  const MenuLateral({
    super.key,
    required this.courante,
    required this.controller,
    required this.onChoisir,
    this.fixe = false,
  });

  final Section courante;
  final PersonnagesController controller;
  final ValueChanged<Section> onChoisir;

  /// Menu toujours visible à gauche (pas de tiroir à refermer).
  final bool fixe;

  /// Largeur du menu quand il est fixe.
  static const double largeurFixe = 300;

  /// Un séparateur est inséré avant ces sections (groupes du menu).
  static const _debutsDeGroupe = {Section.glossaire, Section.preferences};

  @override
  Widget build(BuildContext context) {
    final menu = _menu(context);
    if (!fixe) return menu;
    // Menu fixe : angles droits et même fond derrière (sinon les coins
    // arrondis du tiroir laissent voir le blanc de la fenêtre).
    final theme = Theme.of(context);
    return ColoredBox(
      key: const Key('fond-menu-fixe'),
      color: theme.navigationDrawerTheme.backgroundColor ??
          theme.colorScheme.surface,
      child: Theme(
        data: theme.copyWith(
          drawerTheme: theme.drawerTheme.copyWith(
            shape: const RoundedRectangleBorder(),
          ),
        ),
        child: menu,
      ),
    );
  }

  Widget _menu(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: courante.index,
      // Menu fixe : collé au contenu, sans ombre ni coins arrondis.
      elevation: fixe ? 0 : null,
      onDestinationSelected: (i) {
        if (!fixe) Scaffold.of(context).closeDrawer();
        onChoisir(Section.values[i]);
      },
      children: [
        _Bandeau(controller: controller),
        const SizedBox(height: 8),
        for (final s in Section.values) ...[
          if (_debutsDeGroupe.contains(s))
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              child: Divider(height: 1),
            ),
          NavigationDrawerDestination(
            icon: Icon(s.icone),
            selectedIcon: Icon(s.iconeSelectionnee),
            label: Text(s.libelle),
          ),
        ],
        const SizedBox(height: 16),
        // Numéro de version (suivi des évolutions) : ouvre les nouveautés.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: InkWell(
            key: const Key('menu-version-lien'),
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (!fixe) Scaffold.of(context).closeDrawer();
              onChoisir(Section.nouveautes);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                'Version $kVersionApp · $kDateVersion',
                key: const Key('menu-version'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bandeau du menu : logo, nom de l'app, nombre de personnages
/// (carte « compteur » de la charte graphique).
class _Bandeau extends StatelessWidget {
  const _Bandeau({required this.controller});

  final PersonnagesController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: CarteOdv(
        child: Row(
          children: [
            Image.asset(
              kLogo,
              width: 64,
              height: 64,
              // Si l'image manque, l'app reste utilisable.
              errorBuilder: (context, error, stack) => const SizedBox(
                width: 64,
                height: 64,
                child: Icon(Icons.hiking, size: 40),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "L'odyssée des vagabonds",
                    style: styleAmbiance(theme.textTheme.titleMedium)
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) => Text(
                      texteNombrePersonnages(controller.personnages.length),
                      key: const Key('menu-nb-personnages'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String texteNombrePersonnages(int n) => switch (n) {
      0 => 'Aucun personnage',
      1 => '1 personnage',
      _ => '$n personnages',
    };
