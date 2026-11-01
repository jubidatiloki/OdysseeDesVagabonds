import 'package:flutter/material.dart';

import '../theme.dart';

/// Carte cliquable avec un état « sélectionné » bien visible.
/// Utilisée pour choisir une race, une classe, une origine…
class CarteSelection extends StatelessWidget {
  const CarteSelection({
    super.key,
    required this.titre,
    required this.selectionne,
    required this.onTap,
    this.sousTitre,
    this.badge,
    this.contenu,
  });

  final String titre;
  final String? sousTitre;
  final String? badge;
  final bool selectionne;
  final VoidCallback onTap;

  /// Détails affichés sous le titre.
  final Widget? contenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Charte graphique : carte en dégradé, sélection = bordure blanche
    // (orange en thème clair), bouton radio orange.
    return CarteOdv(
      selectionnee: selectionne,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                selectionne
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selectionne ? OdvCouleurs.accent : scheme.outline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titre,
                  style: styleAmbiance(theme.textTheme.titleMedium)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (badge != null) _Badge(texte: badge!),
            ],
          ),
          if (sousTitre != null) ...[
            const SizedBox(height: 4),
            Text(
              sousTitre!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (contenu != null) ...[
            const SizedBox(height: 8),
            DefaultTextStyle.merge(
              style: TextStyle(color: scheme.onSurfaceVariant),
              child: contenu!,
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texte,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onTertiaryContainer,
            ),
      ),
    );
  }
}

/// Ligne « libellé : texte » compacte pour les détails d'une carte.
class LigneDetail extends StatelessWidget {
  const LigneDetail({super.key, required this.libelle, required this.texte});

  final String libelle;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$libelle : ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: texte),
          ],
        ),
      ),
    );
  }
}
