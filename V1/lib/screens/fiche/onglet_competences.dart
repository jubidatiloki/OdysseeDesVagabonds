import 'package:flutter/material.dart';

import '../../data/referentiel.dart';
import '../../regles/fiche_calculee.dart';
import '../../regles/progression.dart';
import '../../state/personnages_controller.dart';
import '../../widgets/voie_detail.dart';
import 'depenser_points_screen.dart';

/// Compétences acquises (voie raciale + voies de classe), aptitudes et
/// points de compétence disponibles.
class OngletCompetences extends StatelessWidget {
  const OngletCompetences({
    super.key,
    required this.fiche,
    required this.referentiel,
    this.controller,
  });

  final FicheCalculee fiche;
  final Referentiel referentiel;

  /// Pour enregistrer les points dépensés (`null` : bouton masqué).
  final PersonnagesController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final p = fiche.personnage;
    // Telles que les a le personnage (variante, option choisie).
    final competences = fiche.competencesAcquises;
    final disponibles = Progression.pointsRestants(
      niveau: p.niveau,
      race: fiche.race,
      rangsVoies: p.rangsVoies,
      aptitudes: p.aptitudes.length,
    );

    return ListView(
      key: const PageStorageKey('onglet-competences'),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: scheme.onSecondaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Points de compétence disponibles',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(
                '$disponibles',
                key: const Key('points-disponibles'),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        if (disponibles > 0 && controller != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                key: const Key('depenser-points'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DepenserPointsScreen(
                      fiche: fiche,
                      referentiel: referentiel,
                      controller: controller!,
                    ),
                  ),
                ),
                icon: const Icon(Icons.add_task),
                label: Text(
                  'Dépenser ${disponibles > 1 ? 'ces points' : 'ce point'}',
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text('Compétences', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        if (competences.isEmpty)
          const Text('Aucune compétence.')
        else
          for (final c in competences)
            LigneCompetence(
              competence: c.competence,
              acquise: true,
              mention: c.raciale ? 'Voie raciale · ${c.voie.nom}' : c.voie.nom,
            ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => afficherVoies(
                context,
                titre: 'Voies — ${fiche.classe.nom}',
                introduction:
                    fiche.classe.note.isEmpty ? null : fiche.classe.note,
                voies: fiche.classe.voies,
              ),
              icon: const Icon(Icons.auto_stories_outlined),
              label: const Text('Voies de la classe'),
            ),
            if (fiche.race.voieRaciale != null)
              OutlinedButton.icon(
                onPressed: () => afficherVoies(
                  context,
                  titre: 'Voie raciale — ${fiche.race.nom}',
                  voies: [fiche.race.voieRaciale!],
                  afficherCouts: false,
                ),
                icon: const Icon(Icons.auto_stories_outlined),
                label: const Text('Voie raciale'),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Aptitudes et connaissances', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        // Les sorts de rang 0 sont avec les compétences (« Sorts de rang 0 »).
        if (!p.aptitudes
            .any((a) => !(referentiel.aptitude(a.id)?.estSort ?? false)))
          const Text('Aucune aptitude achetée.')
        else
          for (final a in p.aptitudes)
            if (!(referentiel.aptitude(a.id)?.estSort ?? false))
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.check_circle_outline),
                title: Text(
                  referentiel.aptitude(a.id)?.nom ?? a.id,
                ),
                subtitle: a.precision == null ? null : Text(a.precision!),
              ),
      ],
    );
  }
}
