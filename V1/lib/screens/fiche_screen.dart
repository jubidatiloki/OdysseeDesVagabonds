import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/personnage.dart';
import '../regles/fiche_calculee.dart';
import '../regles/montee_niveau.dart';
import '../state/personnages_controller.dart';
import '../theme.dart';
import 'fiche/formulaire_identite.dart';
import 'fiche/vues_fiche.dart';
import 'import_export.dart';
import 'montee_niveau_screen.dart';

/// Consultation d'un personnage, en 5 onglets :
/// Fiche (PV/PM, statistiques) · Compétences · Inventaire · Notes ·
/// Historique.
/// Toute modification est sauvegardée immédiatement.
class FicheScreen extends StatelessWidget {
  const FicheScreen({
    super.key,
    required this.personnageId,
    required this.referentiel,
    required this.controller,
  });

  final String personnageId;
  final Referentiel referentiel;
  final PersonnagesController controller;

  Future<void> _supprimer(BuildContext context, Personnage p) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ${p.nom} ?'),
        content: const Text(
          'Le personnage et tout son inventaire seront définitivement '
          'supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('confirmer-suppression'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await controller.supprimer(p.id);
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text('${p.nom} a été supprimé.')));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.parId(personnageId);
        if (p == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Personnage introuvable.')),
          );
        }
        final race = referentiel.race(p.raceId);
        final classe = referentiel.classe(p.classeId);
        if (race == null || classe == null) {
          return Scaffold(
            appBar: AppBar(title: Text(p.nom)),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'La race ou la classe de ce personnage n\'existe plus '
                  'dans les données du jeu.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        final fiche = FicheCalculee(personnage: p, race: race, classe: classe);
        Future<void> enregistrer() => controller.sauvegarder(p);
        // Permissions de la campagne, en dehors d'une séance.
        final verrous = controller.restrictionsDe(p.id);
        final monterNiveau = MonteeNiveau.possible(p) && !verrous.competences
            ? () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MonteeNiveauScreen(
                      personnage: p,
                      race: race,
                      classe: classe,
                      referentiel: referentiel,
                      controller: controller,
                    ),
                  ),
                )
            : null;
        // Écran étroit : libellé court (« Niveau 4 »), texte complet au survol.
        final etroit = MediaQuery.sizeOf(context).width < 600;
        const styleOnglet =
            TextStyle(fontSize: 15, fontWeight: FontWeight.w600);

        return DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              // Le nom est mis en avant dans la carte d'identité.
              title: const Text('Fiche du personnage'),
              actions: [
                if (monterNiveau != null)
                  Tooltip(
                    message: 'Monter au niveau ${p.niveau + 1}',
                    child: FilledButton.icon(
                      key: const Key('bouton-monter-niveau'),
                      style: styleBoutonProgression(),
                      onPressed: monterNiveau,
                      icon: const Icon(Icons.trending_up),
                      label: Text(
                        etroit
                            ? 'Niveau ${p.niveau + 1}'
                            : 'Monter au niveau ${p.niveau + 1}',
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  key: const Key('menu-fiche'),
                  tooltip: 'Plus d\'actions',
                  onSelected: (action) async {
                    switch (action) {
                      case 'identite':
                        if (await FormulaireIdentite.ouvrir(context, p)) {
                          await enregistrer();
                        }
                      case 'exporter':
                        await exporterPersonnage(context, p);
                      case 'supprimer':
                        await _supprimer(context, p);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'identite',
                      child: ListTile(
                        leading: Icon(Icons.badge_outlined),
                        title: Text('Modifier l\'identité'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'exporter',
                      child: ListTile(
                        leading: Icon(Icons.ios_share),
                        title: Text('Exporter'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'supprimer',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('Supprimer le personnage'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
              bottom: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: styleOnglet,
                unselectedLabelStyle: styleOnglet,
                labelPadding: EdgeInsets.symmetric(horizontal: 20),
                tabs: [
                  Tab(
                    height: 76,
                    icon: Icon(Icons.person_outline, size: 28),
                    text: 'Fiche',
                  ),
                  Tab(
                    height: 76,
                    icon: Icon(Icons.auto_stories_outlined, size: 28),
                    text: 'Compétences',
                  ),
                  Tab(
                    height: 76,
                    icon: Icon(Icons.backpack_outlined, size: 28),
                    text: 'Inventaire',
                  ),
                  Tab(
                    height: 76,
                    icon: Icon(Icons.edit_note, size: 28),
                    text: 'Notes',
                  ),
                  Tab(
                    height: 76,
                    icon: Icon(Icons.history, size: 28),
                    text: 'Historique',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: vuesFiche(
                context,
                fiche: fiche,
                referentiel: referentiel,
                onModifie: enregistrer,
                controller: controller,
                verrous: verrous,
              ),
            ),
          ),
        );
      },
    );
  }
}
