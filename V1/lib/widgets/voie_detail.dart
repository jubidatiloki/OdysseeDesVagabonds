import 'package:flutter/material.dart';

import '../models/creature.dart';
import '../models/effet.dart';
import '../models/voie.dart';
import '../regles/fiche_calculee.dart';
import '../regles/invocations.dart';
import '../regles/progression.dart';
import '../screens/bestiaire_screen.dart';
import 'libelles_sort.dart';
import 'types_competence.dart';

/// Ligne d'une compétence : pastille de rang, nom, type, effet.
class LigneCompetence extends StatelessWidget {
  const LigneCompetence({
    super.key,
    required this.competence,
    this.acquise = false,
    this.attenuee = false,
    this.mention,
    this.action,
    this.choixFaits,
  });

  final Competence competence;

  /// Choix du personnage : seules les invocations de l'option choisie
  /// (son animal) ont leur bouton « Statistiques » ; `null` : toutes.
  final Map<String, String>? choixFaits;

  /// Pastille remplie (compétence obtenue).
  final bool acquise;

  /// Texte grisé (rang pas encore accessible).
  final bool attenuee;

  /// Petit texte sous l'effet (ex. « Niveau 2 requis »).
  final String? mention;

  /// Bouton à droite (prendre / retirer).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final couleurTexte = attenuee ? scheme.onSurfaceVariant : null;
    final c = competence;
    final types = analyserTypeCompetence(c.type);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rang : petit cercle à contour, numéro orange (pastille discrète,
          // le nom de la compétence porte l'attention).
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: acquise ? scheme.primary : scheme.outlineVariant,
                width: acquise ? 1.5 : 1,
              ),
            ),
            child: Text(
              '${c.rang}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: acquise ? scheme.primary : scheme.outline,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom, puis le type en étiquettes à icône (passif, sort,
                // action complexe…), texte brut si le type est inconnu.
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      c.nom,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: couleurTexte ?? scheme.onSurface,
                      ),
                    ),
                    if (types.isNotEmpty)
                      for (final t in types) EtiquetteType(t)
                    else if (c.type.isNotEmpty)
                      Text(
                        c.type,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                // Sort : mana, dégâts, effet appliqué ; endurance dépensée.
                if (FicheCalculee.coutSort(c) != null ||
                    c.endurance.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  LibellesSort(c),
                ],
                if (c.effet.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sansChoix(c.effet),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: couleurTexte ?? scheme.onSurfaceVariant,
                      // Avec des effets détaillés, le texte sert d'intro.
                      fontStyle: c.effets.isEmpty ? null : FontStyle.italic,
                    ),
                  ),
                ],
                if (c.effets.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ListeEffets(c.effets, attenue: attenuee),
                ],
                // États au choix (formes animales) : leurs effets.
                for (final e in c.etatsAuChoix)
                  if (e.effets.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      e.recevable ? '${e.nom} (aussi sur un allié)' : e.nom,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: couleurTexte ?? scheme.onSurface),
                    ),
                    ListeEffets(e.effets, attenue: attenuee),
                  ],
                // Créatures invoquées, compagnons : leur fiche.
                if (invocationsDeCompetence(c, choix: choixFaits)
                    case final liste when liste.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  BoutonsStatistiques(liste),
                ],
                if (mention != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    mention!,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Trait (passif racial, héritage…) : icône, nom mis en avant, description.
class LigneTrait extends StatelessWidget {
  const LigneTrait({
    super.key,
    required this.nom,
    required this.description,
    this.effets = const [],
    this.icone = Icons.auto_awesome_outlined,
    this.type = '',
    this.mention,
  });

  final String nom;
  final String description;

  /// Effets détaillés (puces) ; la description devient alors une intro.
  final List<Effet> effets;
  final IconData icone;

  /// Type en étiquettes (« gratuit, 1×/jour »), comme les compétences.
  final String type;

  /// Petit texte en dessous (ex. « Améliorée par … »).
  final String? mention;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Icon(icone, size: 18, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      nom,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    for (final t in analyserTypeCompetence(type))
                      EtiquetteType(t),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontStyle: effets.isEmpty ? null : FontStyle.italic,
                    ),
                  ),
                ],
                if (effets.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ListeEffets(effets),
                ],
                if (mention != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    mention!,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
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

/// Une voie complète (titre + 5 rangs), en lecture seule.
class VoieDetail extends StatelessWidget {
  const VoieDetail({
    super.key,
    required this.voie,
    this.rangAcquis = 0,
    this.raciale = false,
    this.afficherCouts = true,
  });

  final Voie voie;
  final int rangAcquis;

  /// Voie raciale : rangs offerts aux niveaux impairs (pas de coût).
  final bool raciale;

  /// Faux : aucune mention de coût ni de niveau (voies de créatures).
  final bool afficherCouts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          voie.nom,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        for (final c in voie.competences) ...[
          LigneCompetence(
            competence: c,
            acquise: c.rang <= rangAcquis,
            mention: !afficherCouts
                ? null
                : raciale
                    ? 'Offert au niveau ${c.rang * 2 - 1}'
                    : 'Coût : ${Progression.coutRang(c.rang)} pt'
                        '${Progression.coutRang(c.rang) > 1 ? 's' : ''}'
                        ' · niveau ${c.rang} minimum',
          ),
          // Autres compétences du même rang.
          for (final a in c.aussi)
            LigneCompetence(competence: a, acquise: c.rang <= rangAcquis),
        ],
      ],
    );
  }
}

/// Ouvre une fenêtre listant des voies (voies de classe ou voie raciale).
Future<void> afficherVoies(
  BuildContext context, {
  required String titre,
  required List<Voie> voies,
  String? introduction,
  bool afficherCouts = true,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      final hauteur = MediaQuery.sizeOf(context).height;
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 640, maxHeight: hauteur * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(titre, style: theme.textTheme.titleLarge),
                    ),
                    IconButton(
                      tooltip: 'Fermer',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  children: [
                    if (introduction != null && introduction.isNotEmpty) ...[
                      Text(introduction, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 16),
                    ],
                    for (final v in voies) ...[
                      if (afficherCouts)
                        VoieDetail(voie: v)
                      else
                        _VoieSansCout(voie: v),
                      if (v != voies.last) const Divider(height: 32),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Voie raciale : pas de coût, rangs offerts aux niveaux impairs.
class _VoieSansCout extends StatelessWidget {
  const _VoieSansCout({required this.voie});

  final Voie voie;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          voie.nom,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        for (final c in voie.competences) ...[
          LigneCompetence(
            competence: c,
            mention: 'Offert au niveau ${c.rang * 2 - 1}',
          ),
          for (final a in c.aussi) LigneCompetence(competence: a),
        ],
      ],
    );
  }
}

/// Icône d'un effet selon son type (et sa catégorie pour les maîtrises).
IconData iconeEffet(Effet e) {
  switch (e.typeNormalise) {
    case 'maitrise':
      final c = e.categorieNormalisee;
      if (c.contains('langue')) return Icons.translate;
      if (c.contains('arme')) return Icons.gavel;
      if (c.contains('armure')) return Icons.shield_outlined;
      if (c.contains('instrument')) return Icons.music_note_outlined;
      if (c.contains('vision')) return Icons.visibility_outlined;
      if (c.contains('deplacement')) return Icons.directions_walk;
      if (c.contains('connaissance')) return Icons.menu_book_outlined;
      return Icons.school_outlined;
    case 'bonus':
      return Icons.trending_up;
    case 'malus':
      return Icons.trending_down;
    case 'test':
      return Icons.casino_outlined;
    case 'avantage':
      return Icons.keyboard_double_arrow_up;
    case 'renforcement':
      return Icons.add_circle_outline;
  }
  return Icons.chevron_right;
}

/// Effets détaillés d'un passif ou d'une compétence, en puces à icône.
class ListeEffets extends StatelessWidget {
  const ListeEffets(this.effets, {super.key, this.attenue = false});

  final List<Effet> effets;

  /// Texte grisé (rang pas encore accessible).
  final bool attenue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in effets)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    iconeEffet(e),
                    size: 15,
                    color: attenue ? scheme.outline : scheme.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    e.libelle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          attenue ? scheme.onSurfaceVariant : scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Boutons « Statistiques » des créatures invoquées ou des compagnons : la
/// fiche du bestiaire s'ouvre en page entière.
class BoutonsStatistiques extends StatelessWidget {
  const BoutonsStatistiques(this.creatures, {super.key});

  final List<Creature> creatures;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final x in creatures)
          ActionChip(
            key: Key('statistiques-${x.id}'),
            avatar: const Icon(Icons.pets, size: 18),
            label: Text(
              'Statistiques : ${x.nom}',
              overflow: TextOverflow.ellipsis,
            ),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => CreatureDetailScreen(creature: x),
            )),
          ),
      ],
    );
  }
}
