import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/affliction.dart';
import '../regles/causes_afflictions.dart';
import '../theme.dart';
import '../widgets/consultation.dart';

/// Familles d'afflictions, pour l'affichage (les règles ne les classent pas) :
/// titre, icône et noms des afflictions de la famille.
const List<({String titre, IconData icone, List<String> noms})> _familles = [
  (
    titre: 'Hors de combat',
    icone: Icons.block,
    noms: ['Étourdi', 'Paralysé', 'Endormi'],
  ),
  (
    titre: 'Entravé',
    icone: Icons.link,
    noms: ['Ralenti', 'Immobilisation', 'À terre'],
  ),
  (
    titre: 'Sens et voix',
    icone: Icons.visibility_off_outlined,
    noms: [
      'Aveuglement léger',
      'Aveuglement grave',
      'Assourdi',
      'Réduit au silence',
      'Réduit au silence magique',
    ],
  ),
  (
    titre: 'Dégâts sur la durée',
    icone: Icons.water_drop_outlined,
    noms: ['Empoisonné', 'En feu', 'Saignement'],
  ),
  (
    titre: 'Esprit et force',
    icone: Icons.psychology_alt_outlined,
    noms: ['Effrayé', 'Charmé', 'Affaibli'],
  ),
];

/// Icône propre à une affliction (sinon celle de sa famille).
IconData? _icone(String nom) => switch (nom) {
      'Empoisonné' => Icons.science_outlined,
      'En feu' => Icons.local_fire_department_outlined,
      'Saignement' => Icons.water_drop_outlined,
      'Effrayé' => Icons.sentiment_very_dissatisfied_outlined,
      'Charmé' => Icons.favorite_border,
      'Affaibli' => Icons.trending_down,
      'Endormi' => Icons.bedtime_outlined,
      'Assourdi' => Icons.hearing_disabled_outlined,
      'À terre' => Icons.airline_seat_flat_outlined,
      _ => null,
    };

/// Icône et couleur d'un type de dégâts.
({IconData icone, Color couleur}) _styleDegats(String nom, bool sombre) =>
    switch (nom) {
      'Physique' => (icone: Icons.gavel, couleur: OdvCouleurs.or),
      'Magique' => (
          icone: Icons.auto_awesome,
          couleur: sombre ? OdvCouleurs.lightBlue : OdvCouleurs.blue,
        ),
      'Feu' => (
          icone: Icons.local_fire_department_outlined,
          couleur: sombre ? OdvCouleurs.lightRed : OdvCouleurs.darkRed,
        ),
      'Glace' => (
          icone: Icons.ac_unit,
          couleur: sombre ? OdvCouleurs.lightBlue : OdvCouleurs.blue,
        ),
      'Foudre' => (icone: Icons.bolt, couleur: OdvCouleurs.or),
      'Chaos' => (
          icone: Icons.cyclone,
          couleur: sombre ? OdvCouleurs.lightRed : OdvCouleurs.darkRed,
        ),
      _ => (icone: Icons.flash_on_outlined, couleur: OdvCouleurs.or),
    };

/// Glossaire : afflictions et types de dégâts (règles §3.2 et §3.4).
/// [referentiel] : pour indiquer ce qui cause chaque affliction (classes,
/// races, créatures).
class AfflictionsGlossaireScreen extends StatelessWidget {
  const AfflictionsGlossaireScreen({super.key, this.referentiel});

  final Referentiel? referentiel;

  @override
  Widget build(BuildContext context) {
    final ref = referentiel;
    final causes = ref == null
        ? const <String, List<String>>{}
        : causesAfflictions(
            classes: ref.classes,
            races: ref.races,
            creatures: ref.creatures,
          );
    final rangees = {for (final f in _familles) ...f.noms};
    final autres = [
      for (final a in kAfflictions)
        if (!rangees.contains(a.nom)) a,
    ];
    final scheme = Theme.of(context).colorScheme;
    final sombre = Theme.of(context).brightness == Brightness.dark;
    _Fiche fiche(EntreeEffet a, IconData icone) => (
          nom: a.nom,
          effet: a.effet,
          icone: _icone(a.nom) ?? icone,
          couleur: scheme.error,
          causes: causes[a.nom] ?? const [],
        );
    return LargeurLimitee(
      max: 1200,
      child: ListView(
        key: const Key('glossaire-afflictions'),
        padding: const EdgeInsets.all(16),
        children: [
          BlocConsultation(
            titre: 'Afflictions',
            icone: Icons.healing_outlined,
            children: [
              if (ref != null)
                Text(
                  'Sous chaque affliction : ce qui peut la causer parmi les '
                  'compétences et les créatures (repéré dans leurs textes).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              for (final f in _familles)
                _Famille(
                  titre: f.titre,
                  icone: f.icone,
                  fiches: [
                    for (final nom in f.noms)
                      for (final a in kAfflictions)
                        if (a.nom == nom) fiche(a, f.icone),
                  ],
                ),
              if (autres.isNotEmpty)
                _Famille(
                  titre: 'Autres',
                  icone: Icons.more_horiz,
                  fiches: [for (final a in autres) fiche(a, Icons.more_horiz)],
                ),
            ],
          ),
          BlocConsultation(
            titre: 'Types de dégâts',
            icone: Icons.local_fire_department_outlined,
            children: [
              _Famille(
                titre: 'Physiques, magiques et élémentaires',
                icone: Icons.flash_on_outlined,
                fiches: [
                  for (final e in kEffetsDegats)
                    (
                      nom: e.nom,
                      effet: e.effet,
                      icone: _styleDegats(e.nom, sombre).icone,
                      couleur: _styleDegats(e.nom, sombre).couleur,
                      causes: const <String>[],
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Une arme personnalisée peut recevoir un de ces types et une '
                'affliction : Inventaire, puis ajouter ou modifier un objet.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Une carte : nom, effet, icône et couleur, causes connues.
typedef _Fiche = ({
  String nom,
  String effet,
  IconData icone,
  Color couleur,
  List<String> causes,
});

/// Une famille : titre, puis une carte par entrée, autant de colonnes que la
/// largeur le permet (cartes d'au moins 260 px, 4 au plus).
class _Famille extends StatelessWidget {
  const _Famille({
    required this.titre,
    required this.icone,
    required this.fiches,
  });

  final String titre;
  final IconData icone;
  final List<_Fiche> fiches;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (fiches.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icone, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  titre,
                  key: Key('famille-affliction-$titre'),
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, contraintes) {
              final colonnes = (contraintes.maxWidth / 260).floor().clamp(1, 4);
              final largeur =
                  (contraintes.maxWidth - (colonnes - 1) * 8) / colonnes;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final f in fiches)
                    SizedBox(width: largeur, child: _Carte(fiche: f)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Carte extends StatelessWidget {
  const _Carte({required this.fiche});

  final _Fiche fiche;

  /// Causes affichées au plus (le reste : « et N autres »).
  static const _maxCauses = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final f = fiche;
    final causes = f.causes.take(_maxCauses).join(' ; ');
    final reste = f.causes.length - _maxCauses;
    return Container(
      key: Key('affliction-${f.nom}'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(f.icone, size: 20, color: f.couleur),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.nom,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(f.effet, style: theme.textTheme.bodyMedium),
                if (f.causes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Causée par : $causes'
                    '${reste > 0 ? ' et $reste autre${reste > 1 ? 's' : ''}' : ''}.',
                    key: Key('causes-${f.nom}'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
