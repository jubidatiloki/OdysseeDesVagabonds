import 'package:flutter/material.dart';

import '../models/creature.dart';
import '../theme.dart';

/// Couleur et icône d'une famille de créatures. Une famille inconnue reçoit
/// une couleur neutre : il suffit d'ajouter une ligne ici pour la colorer.
({Color couleur, IconData icone}) styleFamille(
  String famille,
  Brightness brightness,
) {
  final sombre = brightness == Brightness.dark;
  final f = famille.toLowerCase();
  if (f.contains('bête') || f.contains('bete') || f.contains('animal')) {
    return (
      couleur: sombre ? OdvCouleurs.lightGreen : OdvCouleurs.darkGreen,
      icone: Icons.pets,
    );
  }
  if (f.contains('mort')) {
    return (
      couleur: sombre ? OdvCouleurs.hybride : OdvCouleurs.hybrideFonce,
      icone: Icons.heart_broken_outlined,
    );
  }
  if (f.contains('dragon')) {
    return (
      couleur: sombre ? OdvCouleurs.lightRed : OdvCouleurs.darkRed,
      icone: Icons.local_fire_department_outlined,
    );
  }
  if (f.contains('élément') || f.contains('element') || f.contains('magi')) {
    return (
      couleur: sombre ? OdvCouleurs.lightBlue : OdvCouleurs.blue,
      icone: Icons.auto_awesome,
    );
  }
  // Autres familles : couleur neutre, icône propre.
  final icone = f.contains('monstre')
      ? Icons.pest_control_outlined
      : f.contains('gobelin')
          ? Icons.groups_2_outlined
          : f.contains('humano')
              ? Icons.person_outline
              : f.contains('fée') || f.contains('fee')
                  ? Icons.spa_outlined
                  : f.contains('artificiel')
                      ? Icons.precision_manufacturing_outlined
                      : f.contains('géant') || f.contains('geant')
                          ? Icons.landscape_outlined
                          : Icons.category_outlined;
  return (
    couleur: sombre ? OdvCouleurs.texteSecondaire : OdvCouleurs.grey,
    icone: icone,
  );
}

/// Icône d'un archétype (meute, puissant, rapide…).
IconData iconeArchetype(String archetype) {
  final a = archetype.toLowerCase();
  if (a.contains('meute')) return Icons.groups_outlined;
  if (a.contains('puissant')) return Icons.fitness_center;
  if (a.contains('rapide')) return Icons.speed;
  if (a.contains('volant')) return Icons.air;
  if (a.contains('berzerk')) return Icons.whatshot_outlined;
  if (a.contains('chef')) return Icons.star_outline;
  if (a.contains('furtif')) return Icons.visibility_off_outlined;
  if (a.contains('tireur')) return Icons.gps_fixed;
  if (a.contains('sorts')) return Icons.auto_awesome_outlined;
  if (a.contains('gardien')) return Icons.shield_outlined;
  if (a.contains('fouisseur')) return Icons.terrain_outlined;
  return Icons.radio_button_unchecked;
}

/// Étiquette colorée d'une famille (« Bêtes », « Morts-vivants »…).
class EtiquetteFamille extends StatelessWidget {
  const EtiquetteFamille(this.famille, {super.key});

  final String famille;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = styleFamille(famille, theme.brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: style.couleur.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.couleur.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icone, size: 14, color: style.couleur),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              famille,
              style: theme.textTheme.labelMedium?.copyWith(
                color: style.couleur,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Archétype : icône + libellé, en couleur discrète.
class InfoArchetype extends StatelessWidget {
  const InfoArchetype(this.archetype, {super.key});

  final String archetype;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couleur = theme.colorScheme.onSurfaceVariant;
    return Tooltip(
      message: 'Archétype',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconeArchetype(archetype),
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              archetype,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: couleur, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Taille : échelle à 7 crans (minuscule → titanesque), le cran de la
/// créature allumé, puis le libellé.
class EchelleTaille extends StatelessWidget {
  const EchelleTaille(this.taille, {super.key, this.avecMesure = false});

  final TailleCreature taille;

  /// Ajoute la mesure (« 1,80 m à 3-4 m »).
  final bool avecMesure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sombre = theme.brightness == Brightness.dark;
    final vide = sombre ? OdvCouleurs.caseHaute : OdvCouleurs.parcheminFonce;
    final n = TailleCreature.values.length;
    return Tooltip(
      message: 'Taille : ${taille.libelle} (${taille.mesure})',
      child: Row(
        key: Key('echelle-taille-${taille.code}'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.straighten, size: 16, color: scheme.primary),
          const SizedBox(width: 4),
          for (var i = 0; i < n; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Container(
              // Les crans grandissent avec la taille.
              width: 6,
              height: 6.0 + i * 1.5,
              decoration: BoxDecoration(
                color: i <= taille.index
                    ? (i == taille.index ? scheme.primary : scheme.outline)
                    : vide,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              avecMesure
                  ? '${taille.libelle} (${taille.mesure})'
                  : taille.libelle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Résumé d'une créature pour la liste : famille, archétype, taille, voies.
class InfosCreature extends StatelessWidget {
  const InfosCreature(this.creature, {super.key, this.avecMesure = false});

  final Creature creature;
  final bool avecMesure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = creature;
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        EtiquetteFamille(c.famille),
        InfoArchetype(c.archetype),
        EchelleTaille(c.taille, avecMesure: avecMesure),
        if (c.voies.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${c.voies.length} voie${c.voies.length > 1 ? 's' : ''}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
