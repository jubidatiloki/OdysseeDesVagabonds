import 'package:flutter/material.dart';

import '../models/personnage.dart';
import '../regles/fiche_calculee.dart';
import '../theme.dart';
import 'cadre_classe.dart';
import 'consultation.dart';

IconData iconeSexe(Sexe? sexe) => switch (sexe) {
      Sexe.homme => Icons.male,
      Sexe.femme => Icons.female,
      _ => Icons.transgender,
    };

/// En-tête d'identité d'un personnage : avatar, nom (police d'ambiance),
/// sexe, race, classe, héritage et niveau mis en avant.
/// Utilisé par la fiche et par le récapitulatif de création.
class CarteIdentite extends StatelessWidget {
  const CarteIdentite({super.key, required this.fiche, this.onModifier});

  final FicheCalculee fiche;

  /// Crayon « modifier l'identité » (absent si `null`).
  final VoidCallback? onModifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = fiche.personnage;
    final race = fiche.origine == null
        ? fiche.race.nom
        : '${fiche.race.nom} (${fiche.origine!.nom.toLowerCase()})';

    return CadreClasse(
      classeId: fiche.classe.id,
      tailleMotifs: 84,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarClasse(
            nom: p.nom,
            classeId: fiche.classe.id,
            raceId: fiche.race.id,
            element: p.choix['element-draconien'],
            rayon: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nom,
                  key: const Key('nom-personnage'),
                  style: styleAmbiance(theme.textTheme.headlineSmall)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (p.sexe != null)
                      Etiquette(p.sexe!.libelle, icone: iconeSexe(p.sexe)),
                    Etiquette(race, icone: Icons.diversity_3),
                    Etiquette(fiche.classe.nom, icone: Icons.shield_outlined),
                    // Titres gagnés (« Musicien de renom »).
                    for (final t in fiche.titres)
                      Etiquette(t, icone: Icons.military_tech_outlined),
                    if (fiche.optionPassif != null)
                      Etiquette(
                        'Héritage : ${fiche.optionPassif!.nom}',
                        icone: Icons.local_fire_department_outlined,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              _BadgeNiveau(niveau: p.niveau),
              if (onModifier != null)
                IconButton(
                  key: const Key('bouton-identite'),
                  tooltip: 'Modifier le nom, le sexe, la description',
                  onPressed: onModifier,
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pastille or « NIVEAU 3 » (l'or marque la progression).
class _BadgeNiveau extends StatelessWidget {
  const _BadgeNiveau({required this.niveau});

  final int niveau;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('niveau-personnage'),
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: OdvCouleurs.or,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FittedBox(
            child: Text(
              'NIVEAU',
              style: theme.textTheme.labelSmall?.copyWith(
                color: OdvCouleurs.surOr,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          Text(
            '$niveau',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: OdvCouleurs.surOr,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
