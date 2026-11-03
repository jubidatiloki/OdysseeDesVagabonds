import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/personnage.dart';
import '../regles/fiche_calculee.dart';
import '../state/personnages_controller.dart';
import '../state/preferences_controller.dart';
import '../theme.dart';
import '../widgets/cadre_classe.dart';
import 'creation_screen.dart';
import 'fiche_screen.dart';
import 'import_export.dart';

/// Écran Personnages (accueil) : liste des personnages + bouton de création.
class AccueilScreen extends StatelessWidget {
  const AccueilScreen({
    super.key,
    required this.referentiel,
    required this.controller,
    this.preferences,
    this.menu,
  });

  final Referentiel referentiel;
  final PersonnagesController controller;

  /// Personnage actif (étoile, mis en évidence) ; `null` : option masquée.
  final PreferencesController? preferences;

  /// Menu latéral (fourni par l'écran racine).
  final Widget? menu;

  void _ouvrirCreation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreationScreen(
          referentiel: referentiel,
          controller: controller,
        ),
      ),
    );
  }

  void _ouvrirFiche(BuildContext context, Personnage p) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FicheScreen(
          personnageId: p.id,
          referentiel: referentiel,
          controller: controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: menu,
      appBar: AppBar(
        title: const Text('Personnages'),
        actions: [
          IconButton(
            key: const Key('bouton-importer'),
            tooltip: 'Importer un personnage',
            onPressed: () => importerPersonnage(
              context,
              referentiel: referentiel,
              controller: controller,
            ),
            icon: const Icon(Icons.file_open_outlined),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([controller, preferences]),
        builder: (context, _) {
          if (controller.chargement && controller.personnages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.erreur != null) {
            return _Message(
              icone: Icons.error_outline,
              titre: 'Impossible de charger les personnages',
              texte: '${controller.erreur}',
            );
          }
          final personnages = controller.personnages;
          if (personnages.isEmpty) {
            return _Message(
              icone: Icons.auto_stories_outlined,
              titre: "Aucun personnage pour l'instant",
              texte: 'Crée ton premier vagabond pour commencer l\'aventure.',
              action: FilledButton.icon(
                onPressed: () => _ouvrirCreation(context),
                icon: const Icon(Icons.add),
                label: const Text('Créer un personnage'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: personnages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final p = personnages[i];
              final race = referentiel.race(p.raceId);
              final classe = referentiel.classe(p.classeId);
              final fiche = race == null || classe == null
                  ? null
                  : FicheCalculee(personnage: p, race: race, classe: classe);
              final theme = Theme.of(context);
              final prefs = preferences;
              final actif = prefs != null && prefs.personnageActifId == p.id;
              return CadreClasse(
                key: Key('carte-${p.id}'),
                classeId: p.classeId,
                onTap: () => _ouvrirFiche(context, p),
                selectionnee: actif,
                child: Row(
                  children: [
                    AvatarClasse(
                      nom: p.nom,
                      classeId: p.classeId,
                      raceId: p.raceId,
                      element: p.choix['element-draconien'],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  p.nom,
                                  style:
                                      styleAmbiance(theme.textTheme.titleLarge)
                                          .copyWith(
                                              fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (actif) ...[
                                const SizedBox(width: 8),
                                const _BadgeActif(),
                              ],
                              // Étoile près du nom, à l'écart des décors
                              // du fond (à droite de la carte).
                              if (prefs != null)
                                IconButton(
                                  key: Key('actif-${p.id}'),
                                  tooltip: actif
                                      ? 'Personnage actif (toucher pour retirer)'
                                      : 'Choisir comme personnage actif',
                                  isSelected: actif,
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => prefs.changerPersonnageActif(
                                      actif ? null : p.id),
                                  icon: const Icon(Icons.star_border),
                                  selectedIcon: const Icon(Icons.star,
                                      color: OdvCouleurs.or),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${race?.nom ?? 'Race inconnue'} · '
                            '${classe?.nom ?? 'Classe inconnue'} · '
                            'niveau ${p.niveau}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          // Titres gagnés (« Musicien de renom »).
                          if (fiche != null && fiche.titres.isNotEmpty)
                            Row(
                              key: Key('titres-${p.id}'),
                              children: [
                                Icon(Icons.military_tech_outlined,
                                    size: 16,
                                    color: theme.colorScheme.tertiary),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    fiche.titres.join(' · '),
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.tertiary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (fiche != null) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 16,
                              children: [
                                _Ressource(
                                  icone: Icons.favorite,
                                  texte: 'PV ${fiche.pvActuels}/${fiche.pvMax}',
                                  couleur: OdvCouleurs.pv,
                                ),
                                if (fiche.classe.aDuMana)
                                  _Ressource(
                                    icone: Icons.water_drop,
                                    texte:
                                        'PM ${fiche.pmActuels}/${fiche.pmMax}',
                                    couleur: OdvCouleurs.pm,
                                  ),
                                if (fiche.classe.aDeLEndurance)
                                  _Ressource(
                                    icone: kIconeEndurance,
                                    texte:
                                        'PE ${fiche.peActuels}/${fiche.peMax}',
                                    couleur: OdvCouleurs.pe,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ouvrirCreation(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau personnage'),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icone,
    required this.titre,
    required this.texte,
    this.action,
  });

  final IconData icone;
  final String titre;
  final String texte;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              titre,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(texte, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Pastille or « ACTIF » à côté du nom du personnage actif.
class _BadgeActif extends StatelessWidget {
  const _BadgeActif();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('badge-actif'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: OdvCouleurs.or,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'ACTIF',
        style: TextStyle(
          color: OdvCouleurs.surOr,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// « ♥ PV 15/71 » dans la couleur de la ressource.
class _Ressource extends StatelessWidget {
  const _Ressource({
    required this.icone,
    required this.texte,
    required this.couleur,
  });

  final IconData icone;
  final String texte;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    // Sur le parchemin, les teintes claires manquent de contraste.
    final c = sombre
        ? couleur
        : (couleur == OdvCouleurs.pv
            ? OdvCouleurs.darkGreen
            : OdvCouleurs.blue);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 16, color: c),
        const SizedBox(width: 4),
        Text(texte, style: TextStyle(color: c, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
