import 'package:flutter/material.dart';

import '../data/changelog.dart';
import '../theme.dart';
import '../version.dart';
import '../widgets/consultation.dart';

/// Icône et couleur d'un type de modification : ajout (vert), amélioration
/// (or), correction (rouge).
(IconData, Color) apparenceChangement(TypeChangement t, BuildContext context) {
  final theme = Theme.of(context);
  return switch (t) {
    TypeChangement.ajout => (
        Icons.add_circle_outline,
        couleurModificateur(1, theme.brightness)
      ),
    TypeChangement.amelioration => (
        Icons.auto_fix_high,
        theme.colorScheme.primary
      ),
    TypeChangement.correction => (
        Icons.build_outlined,
        couleurModificateur(-1, theme.brightness)
      ),
  };
}

/// Page « Nouveautés » : les versions de l'application, la plus récente
/// d'abord, avec une ligne par modification (ajout, amélioration,
/// correction).
class NouveautesScreen extends StatelessWidget {
  const NouveautesScreen({
    super.key,
    this.menu,
    this.versions = kChangelog,
  });

  final Widget? menu;
  final List<VersionChangelog> versions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      drawer: menu,
      appBar: AppBar(title: const Text('Nouveautés')),
      body: LargeurLimitee(
        child: ListView(
          key: const Key('liste-versions'),
          padding: const EdgeInsets.all(16),
          children: [
            // Légende des types.
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                for (final t in TypeChangement.values)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(apparenceChangement(t, context).$1,
                          size: 16, color: apparenceChangement(t, context).$2),
                      const SizedBox(width: 4),
                      Text(t.libelle, style: theme.textTheme.labelMedium),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            for (final v in versions) ...[
              Card(
                key: Key('version-${v.version}'),
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                color: scheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: v.version == kVersionApp
                        ? scheme.primary
                        : scheme.outlineVariant,
                    width: v.version == kVersionApp ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.new_releases_outlined,
                              color: scheme.primary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Version ${v.version}',
                              style: styleAmbiance(theme.textTheme.titleMedium)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            v.date,
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          if (v.version == kVersionApp) ...[
                            const SizedBox(width: 8),
                            const Etiquette('Actuelle',
                                key: Key('version-actuelle')),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final c in v.changements)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Tooltip(
                                message: c.type.libelle,
                                child: Icon(
                                  apparenceChangement(c.type, context).$1,
                                  size: 18,
                                  color:
                                      apparenceChangement(c.type, context).$2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(c.texte)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
