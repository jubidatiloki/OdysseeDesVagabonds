import 'package:flutter/material.dart';

import '../../models/carac.dart';
import '../../models/race.dart';
import '../../regles/fiche_calculee.dart';

/// Répartition des 12 points (règles : AVANCEMENT.md §7, n°1 et 13).
class EtapeCaracteristiques extends StatelessWidget {
  const EtapeCaracteristiques({
    super.key,
    required this.base,
    required this.race,
    required this.origine,
    required this.onChange,
  });

  final Map<Carac, int> base;
  final Race? race;
  final OrigineRace? origine;
  final ValueChanged<Map<Carac, int>> onChange;

  int _modRacial(Carac c) =>
      (race?.modificateurs[c] ?? 0) + (origine?.modificateurs[c] ?? 0);

  void _modifier(Carac c, int delta) {
    final copie = Map<Carac, int>.of(base);
    copie[c] = (copie[c] ?? RepartitionCreation.valeurDepart) + delta;
    onChange(copie);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final restants = RepartitionCreation.pointsRestants(base);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Répartis tes points', style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        const Text(
          'Toutes les caractéristiques partent de 10. '
          'Maximum 16 avant les bonus de race, qui s\'ajoutent à la fin. '
          'La chance ne se modifie pas.',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: restants == 0
                ? scheme.primaryContainer
                : scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                restants == 0 ? Icons.check_circle : Icons.casino_outlined,
                color: restants == 0
                    ? scheme.onPrimaryContainer
                    : scheme.onSecondaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  restants == 0
                      ? 'Tous les points sont répartis'
                      : 'Points restants',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                '$restants / ${RepartitionCreation.pointsTotal}',
                key: const Key('points-restants'),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const _EnTete(),
        for (final c in Carac.values) _ligne(context, c),
      ],
    );
  }

  Widget _ligne(BuildContext context, Carac c) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final valeur = base[c] ?? RepartitionCreation.valeurDepart;
    final race = _modRacial(c);
    final total = valeur + race;
    final modifiable = RepartitionCreation.estModifiable(c);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.abrev,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  modifiable ? c.nom : '${c.nom} (fixe)',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            key: Key('moins-${c.code}'),
            tooltip: 'Retirer un point',
            onPressed: RepartitionCreation.peutDiminuer(base, c)
                ? () => _modifier(c, -1)
                : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$valeur',
              key: Key('valeur-${c.code}'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton(
            key: Key('plus-${c.code}'),
            tooltip: 'Ajouter un point',
            onPressed: RepartitionCreation.peutAugmenter(base, c)
                ? () => _modifier(c, 1)
                : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
          SizedBox(
            width: 40,
            child: Text(
              race == 0 ? '' : formaterModificateur(race),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: race > 0
                    ? scheme.primary
                    : (race < 0 ? scheme.error : null),
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$total',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              formaterModificateur(modificateur(total)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnTete extends StatelessWidget {
  const _EnTete();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    Widget col(String t, double w) => SizedBox(
        width: w, child: Text(t, textAlign: TextAlign.center, style: style));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Expanded(child: SizedBox()),
          col('Points', 124),
          col('Race', 40),
          col('Total', 36),
          col('Mod.', 36),
        ],
      ),
    );
  }
}
