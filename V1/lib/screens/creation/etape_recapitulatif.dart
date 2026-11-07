import 'package:flutter/material.dart';

import '../../models/aptitude.dart';
import '../../models/objet.dart';
import '../../models/voie.dart';
import '../../regles/fiche_calculee.dart';
import '../../widgets/carte_identite.dart';
import '../../widgets/resume_fiche.dart';
import '../../widgets/voie_detail.dart';

class EtapeRecapitulatif extends StatelessWidget {
  const EtapeRecapitulatif({
    super.key,
    required this.fiche,
    required this.competences,
    this.aptitudes = const [],
    this.pointsConserves = 0,
    this.entete = const [],
    this.inventaireBase = const [],
    this.recevoirInventaire = true,
    this.onInventaire,
  });

  /// Inventaire de base de la classe, que le joueur peut refuser.
  final List<Objet> inventaireBase;
  final bool recevoirInventaire;
  final ValueChanged<bool>? onInventaire;

  final FicheCalculee fiche;
  final List<({Voie voie, Competence competence, bool raciale})> competences;
  final List<({Aptitude? aptitude, AptitudeAcquise acquise})> aptitudes;

  /// Points de compétence non dépensés, gardés pour les niveaux suivants.
  final int pointsConserves;

  /// Placé tout en haut (choix à faire, objets à personnaliser).
  final List<Widget> entete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = fiche.personnage;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...entete,
        if (inventaireBase.isNotEmpty)
          CheckboxListTile(
            key: const Key('inventaire-base'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: recevoirInventaire,
            onChanged: (v) => onInventaire?.call(v ?? false),
            title: const Text('Recevoir l\'inventaire de base'),
            subtitle: Text(
              inventaireBase
                  .map((o) => o.quantite > 1 ? '${o.nom} ×${o.quantite}' : o.nom)
                  .join(', '),
            ),
          ),
        CarteIdentite(fiche: fiche),
        const SizedBox(height: 20),
        ResumeFiche(fiche: fiche, avecPvPm: true),
        const SizedBox(height: 16),
        Text('Compétences', style: theme.textTheme.titleSmall),
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
        if (fiche.reglesParticulieres.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Règles particulières', style: theme.textTheme.titleSmall),
          for (final r in fiche.reglesParticulieres)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('• ${r.reference} : ${r.description}'),
            ),
        ],
        if (aptitudes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Aptitudes et connaissances', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final a in aptitudes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• ${a.aptitude?.nom ?? a.acquise.id}'
                '${a.acquise.precision != null ? ' : ${a.acquise.precision}' : ''}',
              ),
            ),
        ],
        if (pointsConserves > 0) ...[
          const SizedBox(height: 12),
          Text(
            '$pointsConserves point${pointsConserves > 1 ? 's' : ''} de '
            'compétence conservé${pointsConserves > 1 ? 's' : ''} pour les '
            'niveaux suivants.',
            key: const Key('points-conserves'),
          ),
        ],
        if (p.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Description', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(p.description),
        ],
        const SizedBox(height: 16),
        Text(
          'Vérifie ton personnage avant de le créer. Tu peux revenir aux '
          'étapes précédentes avec le bouton « Précédent ».',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
