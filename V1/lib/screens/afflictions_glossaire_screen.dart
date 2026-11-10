import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/affliction.dart';
import '../regles/causes_afflictions.dart';
import '../theme.dart';
import '../widgets/consultation.dart';
import '../widgets/icones_armes.dart';

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
      'Élémentaire' => (
          icone: Icons.local_fire_department_outlined,
          couleur: sombre ? OdvCouleurs.lightRed : OdvCouleurs.darkRed,
        ),
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
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  kIntroDegats,
                  key: const Key('intro-degats'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              _Famille(
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

/// Une famille : titre, puis une carte par entrée, sur toute la largeur.
class _Famille extends StatelessWidget {
  const _Famille({
    this.titre,
    this.icone,
    required this.fiches,
  });

  /// Sans titre : les cartes seules.
  final String? titre;
  final IconData? icone;
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
          if (titre != null) ...[
            Row(
              children: [
                Icon(icone, size: 18, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    titre!,
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
          ],
          // Une carte par ligne, sur toute la largeur.
          for (final (n, f) in fiches.indexed) ...[
            if (n > 0) const SizedBox(height: 8),
            _Carte(fiche: f),
          ],
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
                _Effet(texte: f.effet),
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

/// Icône d'une ligne à puce des types de dégâts (« • tranchants… »), avec
/// sa couleur ; `null` : puce simple.
Widget? iconeSousType(String ligne, bool sombre, Color neutre) {
  final mot = ligne.replaceFirst('• ', '').toLowerCase();
  const t = 18.0;
  if (mot.startsWith('tranchant')) {
    return IconeEpee(
        key: const Key('icone-tranchant'), taille: t, couleur: neutre);
  }
  if (mot.startsWith('contondant')) {
    return Icon(Icons.hardware,
        key: const Key('icone-contondant'), size: t, color: neutre);
  }
  if (mot.startsWith('perçant')) {
    return IconeFleche(
        key: const Key('icone-perçant'), taille: t, couleur: neutre);
  }
  if (mot.startsWith('feu')) {
    return Icon(
      Icons.local_fire_department,
      key: const Key('icone-feu'),
      size: t,
      color: sombre ? OdvCouleurs.lightRed : OdvCouleurs.darkRed,
    );
  }
  if (mot.startsWith('glace')) {
    return Icon(
      Icons.ac_unit,
      key: const Key('icone-glace'),
      size: t,
      color: sombre ? OdvCouleurs.lightBlue : OdvCouleurs.blue,
    );
  }
  if (mot.startsWith('foudre')) {
    return const Icon(Icons.bolt,
        key: Key('icone-foudre'), size: t, color: OdvCouleurs.or);
  }
  return null;
}

/// Texte d'une carte : les lignes « • … » deviennent une liste, avec une
/// icône pour les sous-types de dégâts connus.
class _Effet extends StatelessWidget {
  const _Effet({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium;
    final lignes = texte.split('\n');
    if (lignes.length == 1) return Text(texte, style: style);
    final sombre = theme.brightness == Brightness.dark;
    final neutre = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final l in lignes)
          if (!l.startsWith('• '))
            Text(l, style: style)
          else
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    child: iconeSousType(l, sombre, neutre) ??
                        Text('•', style: style),
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(l.substring(2), style: style)),
                ],
              ),
            ),
      ],
    );
  }
}
