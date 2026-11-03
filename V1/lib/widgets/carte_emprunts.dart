import 'package:flutter/material.dart';

import '../models/voie.dart';
import 'voie_detail.dart';

/// Choix des rangs pris dans les voies d'autres classes (humain,
/// « Polyvalence » : 2 rangs). Voies regroupées par classe ; pour chacune,
/// une pastille « Rang 1 » et une « Rang 2 ». Le rang 2 demande le rang 1
/// de la même voie : le choisir directement prend les deux (2 rangs).
/// [valeur] : id de voie → rang (1 ou 2), comme `Personnage.emprunts`.
class CarteEmprunts extends StatelessWidget {
  const CarteEmprunts({
    super.key,
    required this.nom,
    required this.voies,
    required this.valeur,
    required this.onChange,
    this.origine,
    this.total = 2,
  });

  final String nom;
  final String? origine;
  final List<({Voie voie, String classe})> voies;
  final Map<String, int> valeur;
  final ValueChanged<Map<String, int>> onChange;

  /// Nombre de rangs à prendre.
  final int total;

  /// Le choix est-il complet (2 rangs) ?
  static bool complet(Map<String, int> v, {int total = 2}) => _pris(v) >= total;

  static int _pris(Map<String, int> v) => v.values.fold(0, (a, b) => a + b);

  int get _restants => total - _pris(valeur);

  /// Pastille « Rang [rang] » de [voie] : cochée, possible ou grisée.
  void _basculer(Voie voie, int rang) {
    final actuel = valeur[voie.id] ?? 0;
    final v = Map.of(valeur);
    if (actuel >= rang) {
      // Décocher : rang 1 → toute la voie, rang 2 → on garde le rang 1.
      if (rang == 1) {
        v.remove(voie.id);
      } else {
        v[voie.id] = 1;
      }
    } else {
      v[voie.id] = rang;
    }
    onChange(v);
  }

  bool _possible(Voie voie, int rang) {
    final actuel = valeur[voie.id] ?? 0;
    if (actuel >= rang) return true;
    return rang - actuel <= _restants;
  }

  void _details(BuildContext context, ({Voie voie, String classe}) v) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${v.classe} · ${v.voie.nom}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final c in v.voie.competences)
                if (c.rang <= 2) LigneCompetence(competence: c),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fait = complet(valeur, total: total);
    // Voies regroupées par classe (dans l'ordre des données).
    final parClasse = <String, List<({Voie voie, String classe})>>{};
    for (final v in voies) {
      parClasse.putIfAbsent(v.classe, () => []).add(v);
    }
    ({Voie voie, String classe})? voie(String id) {
      for (final v in voies) {
        if (v.voie.id == id) return v;
      }
      return null;
    }

    return Card(
      key: const Key('carte-emprunts'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: fait ? scheme.outlineVariant : scheme.tertiary,
          width: fait ? 1 : 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  fait ? Icons.check_circle : Icons.help_outline,
                  size: 20,
                  color: fait ? scheme.primary : scheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$nom · $total rangs d\'autres classes',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${_pris(valeur)} / $total',
                  key: const Key('emprunts-compteur'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: fait ? scheme.primary : scheme.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (origine != null)
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  origine!,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Deux rangs 1 de voies différentes, ou le rang 1 et le rang 2 '
              'd\'une même voie (choisir « Rang 2 » prend aussi le rang 1).',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            // Rangs choisis (retirables).
            if (valeur.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in valeur.entries)
                    if (voie(e.key) case final v?)
                      InputChip(
                        key: Key('emprunt-choisi-${e.key}'),
                        avatar: Icon(Icons.check, color: scheme.primary),
                        label: Text(
                          '${v.classe} · ${v.voie.nom} — '
                          '${e.value == 2 ? 'rangs 1 et 2' : 'rang 1'}',
                          overflow: TextOverflow.ellipsis,
                        ),
                        deleteIcon: Icon(
                          Icons.close,
                          key: Key('retirer-emprunt-${e.key}'),
                        ),
                        deleteButtonTooltipMessage: 'Retirer',
                        onDeleted: () =>
                            onChange(Map.of(valeur)..remove(e.key)),
                      ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            for (final classe in parClasse.entries)
              Theme(
                // Pas de filets autour des volets.
                data: theme.copyWith(dividerColor: Colors.transparent),
                // Sa propre place dans PageStorage : voir « Effets reçus ».
                child: KeyedSubtree(
                  key: PageStorageKey('bloc-emprunts-${classe.key}'),
                  child: ExpansionTile(
                    key: Key('emprunts-classe-${classe.key}'),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    // Ouvert si une de ses voies est choisie.
                    initiallyExpanded:
                        classe.value.any((v) => valeur.containsKey(v.voie.id)),
                    title: Text(
                      classe.key,
                      style: theme.textTheme.titleSmall,
                    ),
                    subtitle: () {
                      final n = classe.value
                          .where((v) => valeur.containsKey(v.voie.id))
                          .length;
                      return n == 0
                          ? null
                          : Text(
                              '$n voie${n > 1 ? 's' : ''} choisie${n > 1 ? 's' : ''}',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(color: scheme.primary),
                            );
                    }(),
                    children: [
                      for (final v in classe.value) _ligneVoie(context, v),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _ligneVoie(BuildContext context, ({Voie voie, String classe}) v) {
    final theme = Theme.of(context);
    final rang = valeur[v.voie.id] ?? 0;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  v.voie.nom,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: rang > 0 ? FontWeight.w700 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                key: Key('emprunt-info-${v.voie.id}'),
                tooltip: 'Voir les rangs 1 et 2',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.info_outline, size: 18),
                onPressed: () => _details(context, v),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final r in [1, 2])
                if (v.voie.competence(r) case final c?)
                  FilterChip(
                    key: Key('emprunt-${v.voie.id}-$r'),
                    label: Text(
                      'Rang $r · ${c.nom}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    selected: rang >= r,
                    onSelected: _possible(v.voie, r)
                        ? (_) => _basculer(v.voie, r)
                        : null,
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
