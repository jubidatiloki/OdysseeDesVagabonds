import 'package:flutter/material.dart';

import '../../models/carac.dart';
import '../../models/race.dart';
import '../../regles/fiche_calculee.dart';

/// Familles de caractéristiques, pour l'affichage seulement (11/11/2026).
const List<({String titre, IconData icone, List<Carac> caracs})> _familles = [
  (
    titre: 'Combat',
    icone: Icons.sports_martial_arts,
    caracs: [Carac.adc, Carac.adt, Carac.adm],
  ),
  (
    titre: 'Corps',
    icone: Icons.fitness_center,
    caracs: [Carac.force, Carac.dex, Carac.con],
  ),
  (
    titre: 'Esprit',
    icone: Icons.psychology_outlined,
    caracs: [Carac.intel, Carac.per, Carac.soc, Carac.men],
  ),
  (
    titre: 'Hasard',
    icone: Icons.casino_outlined,
    caracs: [Carac.chan],
  ),
];

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
    const total = RepartitionCreation.pointsTotal;
    final fini = restants == 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Répartis tes points', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        // Comment ça marche, en trois points.
        Container(
          key: const Key('aide-repartition'),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (icone, texte) in [
                (
                  Icons.flag_outlined,
                  'Chaque caractéristique part de 10. Tu as $total points : '
                      '1 point = +1.'
                ),
                (
                  Icons.vertical_align_top,
                  'Maximum 16 avant les bonus de ta race, qui s\'ajoutent '
                      'ensuite (pastille « Race »).'
                ),
                (
                  Icons.calculate_outlined,
                  'Les jets utilisent le modificateur : 10 = +0, puis +1 tous '
                      'les 2 points (12 = +1, 14 = +2, 16 = +3). En dessous de 10, il '
                      'devient négatif : 9 et 8 = −1, 7 et 6 = −2.'
                ),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icone, size: 18, color: scheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(texte, style: theme.textTheme.bodySmall),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Points restants, avec une barre.
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: fini ? scheme.primaryContainer : scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    fini ? Icons.check_circle : Icons.casino_outlined,
                    color: fini
                        ? scheme.onPrimaryContainer
                        : scheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fini
                          ? 'Tous les points sont répartis'
                          : 'Points restants',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '$restants / $total',
                    key: const Key('points-restants'),
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (total - restants) / total,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        for (final f in _familles) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 18, 4, 6),
            child: Row(
              children: [
                Icon(f.icone, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  f.titre.toUpperCase(),
                  key: Key('famille-carac-${f.titre}'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          for (final c in f.caracs) _ligne(context, c),
        ],
      ],
    );
  }

  /// Largeurs fixes des colonnes de droite : les valeurs de toutes les
  /// caractéristiques sont alignées verticalement (12/11/2026).
  static const double _largeurSelection = 112;
  static const double _largeurRace = 64;
  static const double _largeurTotal = 72;
  static const double _largeurValeurs =
      _largeurSelection + _largeurRace + _largeurTotal + 8;

  /// En dessous, les valeurs passent sous la description (toujours à
  /// droite et alignées).
  static const double _largeurUneLigne = 520;

  Widget _ligne(BuildContext context, Carac c) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final modifiable = RepartitionCreation.estModifiable(c);

    final identite = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Abréviation dans une pastille.
        Container(
          width: 48,
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FittedBox(
            child: Text(
              c.abrev,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                modifiable ? c.nom : '${c.nom} (fixe)',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              // À quoi sert cette caractéristique.
              Text(
                c.description,
                key: Key('explication-${c.code}'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );

    return Card(
      key: Key('ligne-carac-${c.code}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: LayoutBuilder(
          builder: (context, contraintes) =>
              contraintes.maxWidth >= _largeurUneLigne
                  ? Row(
                      children: [
                        Expanded(child: identite),
                        const SizedBox(width: 8),
                        _valeurs(context, c),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        identite,
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _valeurs(context, c),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  /// Sélection (− valeur +), bonus de race, total et modificateur, chacun
  /// dans une colonne de largeur fixe.
  Widget _valeurs(BuildContext context, Carac c) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final valeur = base[c] ?? RepartitionCreation.valeurDepart;
    final race = _modRacial(c);
    final total = valeur + race;
    final modifiable = RepartitionCreation.estModifiable(c);
    final mod = modificateur(total);

    return SizedBox(
      width: _largeurValeurs,
      child: Row(
        children: [
          SizedBox(
            width: _largeurSelection,
            child: modifiable
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        key: Key('moins-${c.code}'),
                        tooltip: 'Retirer un point',
                        visualDensity: VisualDensity.compact,
                        onPressed: RepartitionCreation.peutDiminuer(base, c)
                            ? () => _modifier(c, -1)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      SizedBox(
                        width: 24,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$valeur',
                            key: Key('valeur-${c.code}'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ),
                      IconButton(
                        key: Key('plus-${c.code}'),
                        tooltip: 'Ajouter un point',
                        visualDensity: VisualDensity.compact,
                        onPressed: RepartitionCreation.peutAugmenter(base, c)
                            ? () => _modifier(c, 1)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  )
                // Chance : ne se répartit pas, pas de boutons (12/11/2026).
                : Text(
                    'Ne se répartit pas',
                    key: Key('fixe-${c.code}'),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: _largeurRace,
            child: race == 0
                ? null
                : Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: race > 0 ? scheme.primary : scheme.error,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Race ${formaterModificateur(race)}',
                        key: Key('race-${c.code}'),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: race > 0 ? scheme.primary : scheme.error,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 4),
          // Résultat : valeur totale et modificateur des jets.
          Container(
            key: Key('total-${c.code}'),
            width: _largeurTotal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formaterModificateur(mod),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: mod > 0
                          ? scheme.primary
                          : mod < 0
                              ? scheme.error
                              : scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
