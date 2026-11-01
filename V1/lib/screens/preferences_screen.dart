import 'package:flutter/material.dart';

import '../state/preferences_controller.dart';
import '../widgets/consultation.dart';

/// Titre et explication d'un réglage (bloc « Lancer de dé »).
class _SousTitre extends StatelessWidget {
  const _SousTitre(this.titre, this.aide);

  final String titre;
  final String aide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: theme.textTheme.titleSmall),
          Text(
            aide,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Page « Préférences » : thème, menu, animations, page Lancer de dé.
/// Les choix sont sauvegardés sur l'appareil.
class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key, required this.preferences, this.menu});

  final PreferencesController preferences;
  final Widget? menu;

  static const _themes = [
    (ThemeMode.dark, 'Sombre (par défaut)', Icons.dark_mode_outlined),
    (ThemeMode.light, 'Clair « parchemin »', Icons.light_mode_outlined),
    (ThemeMode.system, 'Comme l\'appareil', Icons.brightness_auto_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: menu,
      appBar: AppBar(title: const Text('Préférences')),
      body: LargeurLimitee(
        child: ListenableBuilder(
          listenable: preferences,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              BlocConsultation(
                titre: 'Thème',
                icone: Icons.palette_outlined,
                children: [
                  for (final (mode, libelle, icone) in _themes)
                    ListTile(
                      key: Key('theme-${mode.name}'),
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(icone),
                      title: Text(libelle),
                      selected: preferences.theme == mode,
                      trailing: preferences.theme == mode
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () => preferences.changerTheme(mode),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              BlocConsultation(
                titre: 'Menu latéral',
                icone: Icons.view_sidebar_outlined,
                children: [
                  SwitchListTile(
                    key: const Key('pref-menu-epingle'),
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.push_pin_outlined),
                    title: const Text('Garder le menu ouvert'),
                    subtitle: const Text(
                      'Sur grand écran, le menu reste visible à gauche.',
                    ),
                    value: preferences.menuEpingle,
                    onChanged: preferences.changerMenuEpingle,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BlocConsultation(
                titre: 'Cadres des personnages',
                icone: Icons.auto_awesome_outlined,
                children: [
                  SwitchListTile(
                    key: const Key('pref-animations'),
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.animation),
                    title: const Text('Effets animés'),
                    subtitle: const Text(
                      'Sang qui coule, feuilles qui tombent, étoiles qui '
                      'scintillent… selon la classe.',
                    ),
                    value: preferences.animations,
                    onChanged: preferences.changerAnimations,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BlocConsultation(
                titre: 'Page Lancer de dé',
                icone: Icons.casino_outlined,
                children: [
                  const _SousTitre(
                    'Dé sélectionné par défaut',
                    'Dé du lancer libre à l\'ouverture de la page.',
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final f in facesDesLibres)
                        ChoiceChip(
                          key: Key('pref-de-d$f'),
                          visualDensity: VisualDensity.compact,
                          label: Text('D$f'),
                          selected: preferences.deDefaut == f,
                          onSelected: (_) => preferences.changerDeDefaut(f),
                        ),
                    ],
                  ),
                  for (final g in GroupeJets.values) ...[
                    const SizedBox(height: 16),
                    _SousTitre(
                      'Affichage des ${g.libelle.toLowerCase()}',
                      'Groupe ouvert ou replié à l\'arrivée sur la page '
                          '(« Comme la dernière fois » : garde ton dernier '
                          'choix).',
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final a in AffichageGroupe.values)
                          ChoiceChip(
                            key: Key('pref-${g.name}-${a.name}'),
                            visualDensity: VisualDensity.compact,
                            avatar: Icon(
                              switch (a) {
                                AffichageGroupe.visible =>
                                  Icons.visibility_outlined,
                                AffichageGroupe.cache =>
                                  Icons.visibility_off_outlined,
                                AffichageGroupe.memoriser =>
                                  Icons.history_outlined,
                              },
                              size: 18,
                            ),
                            label: Text(a.libelle),
                            selected: preferences.affichage(g) == a,
                            onSelected: (_) =>
                                preferences.changerAffichage(g, a),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
