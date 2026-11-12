import 'package:flutter/material.dart';

import '../../models/seance.dart';
import '../../regles/des.dart';

/// Attaque sans jet d'attaque (souffle, bond…) qui vise le joueur : une
/// fenêtre lui demande d'esquiver ou de subir (12/11/2026, à la place du
/// bandeau). Renvoie `true` (esquiver) ou `false` (subir).
class FenetreEsquive extends StatelessWidget {
  const FenetreEsquive({
    super.key,
    required this.degats,
    required this.dejaUtilisee,
  });

  final DegatsSeance degats;

  /// Une seule esquive par tour de combat (règles §3.3).
  final bool dejaUtilisee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final d = degats;
    return AlertDialog(
      key: const Key('fenetre-esquive'),
      icon: Icon(Icons.warning_amber, color: scheme.error, size: 36),
      title: const Text('Tu es attaqué !'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              d.source,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${d.montant} dégâts'
              '${d.type == 'physique' ? '' : ' (${d.type})'}',
              key: const Key('esquive-montant'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              dejaUtilisee
                  ? 'Tu as déjà esquivé pendant ce tour : tu subis les '
                      'dégâts.'
                  : 'Jet d\'esquive contre ${d.difficulteEsquive}. Réussi : '
                      '${d.moitieSiEsquive ? 'moitié des dégâts' : 'aucun dégât'}'
                      ' ; raté : tous les dégâts.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          key: Key('subir-${d.id}'),
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Subir'),
        ),
        FilledButton.icon(
          key: Key('esquiver-${d.id}'),
          onPressed: dejaUtilisee ? null : () => Navigator.pop(context, true),
          icon: const Icon(Icons.directions_run),
          label: const Text('Esquiver'),
        ),
      ],
    );
  }
}

/// Résultat de l'esquive, une fois le dé arrêté : le jet contre la
/// difficulté, puis le calcul des dégâts jusqu'aux PV réellement perdus.
class FenetreResultatEsquive extends StatelessWidget {
  const FenetreResultatEsquive({
    super.key,
    required this.degats,
    required this.jet,
    required this.subis,
    required this.rd,
    required this.perdus,
  });

  final DegatsSeance degats;
  final ResultatLancer? jet;
  final int subis;
  final int rd;
  final int perdus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final d = degats;
    final j = jet;
    final reussi = j?.reussite ?? false;
    final vert = Colors.green.shade600;
    Widget ligne(String libelle, String valeur,
            {Key? cle, bool fort = false}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(child: Text(libelle)),
              Text(
                valeur,
                key: cle,
                style: fort
                    ? theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)
                    : null,
              ),
            ],
          ),
        );
    return AlertDialog(
      key: const Key('resultat-esquive'),
      icon: Icon(
        j == null
            ? Icons.healing_outlined
            : reussi
                ? Icons.directions_run
                : Icons.close,
        color: j == null
            ? scheme.error
            : reussi
                ? vert
                : scheme.error,
        size: 36,
      ),
      title: Text(
        j == null
            ? 'Dégâts subis'
            : reussi
                ? 'Esquive réussie'
                : 'Esquive ratée',
        key: const Key('titre-resultat-esquive'),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (j != null) ...[
              Text(
                '${j.total} contre ${d.difficulteEsquive}',
                key: const Key('jet-esquive'),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: reussi ? vert : scheme.error,
                ),
              ),
              Text(
                j.detail,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const Divider(height: 24),
            ],
            ligne(
              'Dégâts de l\'attaque',
              '${d.montant}${d.type == 'physique' ? '' : ' (${d.type})'}',
            ),
            if (j != null && reussi)
              ligne(
                d.moitieSiEsquive ? 'Esquive : moitié' : 'Esquive : aucun',
                '$subis',
              ),
            if (rd > 0) ligne('Réduction (RD)', '−$rd'),
            const Divider(height: 16),
            ligne(
              'PV perdus',
              '$perdus',
              cle: const Key('pv-perdus'),
              fort: true,
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          key: const Key('fermer-resultat-esquive'),
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
