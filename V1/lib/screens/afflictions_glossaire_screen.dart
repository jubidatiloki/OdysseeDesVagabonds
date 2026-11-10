import 'package:flutter/material.dart';

import '../models/affliction.dart';
import '../widgets/carte_selection.dart';
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

/// Glossaire : afflictions et types de dégâts (règles §3.2 et §3.4).
class AfflictionsGlossaireScreen extends StatelessWidget {
  const AfflictionsGlossaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rangees = {for (final f in _familles) ...f.noms};
    final autres = [
      for (final a in kAfflictions)
        if (!rangees.contains(a.nom)) a,
    ];
    return LargeurLimitee(
      child: ListView(
        key: const Key('glossaire-afflictions'),
        padding: const EdgeInsets.all(16),
        children: [
          BlocConsultation(
            titre: 'Afflictions',
            icone: Icons.healing_outlined,
            children: [
              for (final f in _familles)
                _Famille(
                  titre: f.titre,
                  icone: f.icone,
                  afflictions: [
                    for (final nom in f.noms)
                      for (final a in kAfflictions)
                        if (a.nom == nom) a,
                  ],
                ),
              if (autres.isNotEmpty)
                _Famille(
                  titre: 'Autres',
                  icone: Icons.more_horiz,
                  afflictions: autres,
                ),
            ],
          ),
          BlocConsultation(
            titre: 'Types de dégâts',
            icone: Icons.local_fire_department_outlined,
            children: [
              for (final e in kEffetsDegats)
                LigneDetail(libelle: e.nom, texte: e.effet),
              const SizedBox(height: 8),
              const Text(
                'Une arme personnalisée peut recevoir un de ces types et une '
                'affliction : Inventaire, puis ajouter ou modifier un objet.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Une famille : titre, puis une carte par affliction (nom en gras, effet
/// dessous), sur plusieurs colonnes quand la place le permet.
class _Famille extends StatelessWidget {
  const _Famille({
    required this.titre,
    required this.icone,
    required this.afflictions,
  });

  final String titre;
  final IconData icone;
  final List<EntreeEffet> afflictions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (afflictions.isEmpty) return const SizedBox.shrink();
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
              final colonnes = contraintes.maxWidth >= 640 ? 2 : 1;
              final largeur =
                  (contraintes.maxWidth - (colonnes - 1) * 8) / colonnes;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in afflictions)
                    SizedBox(
                      width: largeur,
                      child: _CarteAffliction(
                        affliction: a,
                        icone: _icone(a.nom) ?? icone,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CarteAffliction extends StatelessWidget {
  const _CarteAffliction({required this.affliction, required this.icone});

  final EntreeEffet affliction;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      key: Key('affliction-${affliction.nom}'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: scheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  affliction.nom,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(affliction.effet, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
