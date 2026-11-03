import 'package:flutter/material.dart';

import '../../data/referentiel.dart';
import '../../models/campagne.dart';
import '../../state/campagnes_controller.dart';
import '../../state/personnages_controller.dart';
import '../../theme.dart';
import '../../widgets/consultation.dart';
import 'campagne_joueur_screen.dart';
import 'campagne_mj_screen.dart';
import 'creation_campagne_screen.dart';
import 'rejoindre_campagne_screen.dart';
import 'seance_screen.dart';

/// Tout ce dont les écrans de campagne ont besoin.
class ContexteCampagnes {
  const ContexteCampagnes({
    required this.campagnes,
    required this.personnages,
    required this.referentiel,
  });

  final CampagnesController campagnes;
  final PersonnagesController personnages;
  final Referentiel referentiel;
}

/// Page « Campagnes » (menu latéral) : parties à plusieurs. Deux entrées :
/// « En tant que maître du jeu » et « En tant que joueur ». Il faut être
/// connecté à un compte.
class CampagnesScreen extends StatelessWidget {
  const CampagnesScreen({
    super.key,
    required this.contexte,
    this.menu,
    this.onCompte,
  });

  final ContexteCampagnes contexte;
  final Widget? menu;

  /// Ouvre la page Compte (se connecter).
  final VoidCallback? onCompte;

  @override
  Widget build(BuildContext context) {
    final c = contexte.campagnes;
    return Scaffold(
      drawer: menu,
      appBar: AppBar(title: const Text('Campagnes')),
      body: LargeurLimitee(
        child: ListenableBuilder(
          listenable: c,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!c.compte.service.disponible)
                const BlocConsultation(
                  titre: 'Campagnes indisponibles',
                  icone: Icons.cloud_off_outlined,
                  children: [
                    Text('Les campagnes se jouent en ligne : elles existent '
                        'sur le téléphone (Android) et la version web.'),
                  ],
                )
              else if (!c.connecte)
                BlocConsultation(
                  titre: 'Connecte-toi pour jouer à plusieurs',
                  icone: Icons.groups_2_outlined,
                  children: [
                    const Text('Une campagne est une partie à plusieurs menée '
                        'par un maître du jeu (MJ). Il faut un compte pour '
                        'créer une campagne ou en rejoindre une.'),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        key: const Key('campagnes-connexion'),
                        onPressed: onCompte,
                        icon: const Icon(Icons.login),
                        label: const Text('Se connecter'),
                      ),
                    ),
                  ],
                )
              else ...[
                // Séances en cours (joueur) : rejoindre en un geste.
                for (final s in c.seancesEnCours)
                  BandeauSeance(campagne: s, contexte: contexte),
                if (c.erreur != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      c.erreur!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                _Entree(
                  cle: 'campagnes-mj',
                  icone: Icons.menu_book_outlined,
                  titre: 'En tant que maître du jeu',
                  detail: _detailMj(c),
                  alerte: c.commeMj.any((x) => x.demandes.isNotEmpty),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CampagnesMjScreen(contexte: contexte),
                  )),
                ),
                const SizedBox(height: 12),
                _Entree(
                  cle: 'campagnes-joueur',
                  icone: Icons.shield_outlined,
                  titre: 'En tant que joueur',
                  detail: _detailJoueur(c),
                  alerte: c.seancesEnCours.isNotEmpty,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CampagnesJoueurScreen(contexte: contexte),
                  )),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _detailMj(CampagnesController c) {
    final n = c.commeMj.length;
    final demandes = c.commeMj.fold<int>(0, (s, x) => s + x.demandes.length);
    return [
      n == 0
          ? 'Crée une campagne, écris son script, invite tes joueurs.'
          : '$n campagne${n > 1 ? 's' : ''} menée${n > 1 ? 's' : ''}',
      if (demandes > 0) '$demandes demande${demandes > 1 ? 's' : ''} à traiter',
    ].join(' · ');
  }

  static String _detailJoueur(CampagnesController c) {
    final membre = c.commeJoueur.where((x) => x.joueurs.contains(c.uid));
    final attente = c.commeJoueur.length - membre.length;
    return [
      membre.isEmpty && attente == 0
          ? 'Rejoins la campagne d\'un MJ avec son code d\'invitation.'
          : '${membre.length} campagne${membre.length > 1 ? 's' : ''}',
      if (attente > 0) '$attente demande${attente > 1 ? 's' : ''} en attente',
    ].join(' · ');
  }
}

/// Grande carte d'entrée (MJ ou joueur).
class _Entree extends StatelessWidget {
  const _Entree({
    required this.cle,
    required this.icone,
    required this.titre,
    required this.detail,
    required this.onTap,
    this.alerte = false,
  });

  final String cle;
  final IconData icone;
  final String titre;
  final String detail;
  final VoidCallback onTap;

  /// Pastille : demande à traiter, séance en cours.
  final bool alerte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CarteOdv(
      child: InkWell(
        key: Key(cle),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Badge(
                isLabelVisible: alerte,
                child: Icon(icone, size: 40, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: styleAmbiance(theme.textTheme.titleMedium)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// « Séance en cours » d'une campagne de joueur : bouton pour la rejoindre.
class BandeauSeance extends StatelessWidget {
  const BandeauSeance({
    super.key,
    required this.campagne,
    required this.contexte,
  });

  final Campagne campagne;
  final ContexteCampagnes contexte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = campagne.seance!;
    return Card(
      key: Key('bandeau-seance-${campagne.id}'),
      color: theme.colorScheme.primaryContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.campaign_outlined),
        title: Text('Séance ${s.numero} en cours'),
        subtitle: Text('${campagne.nom} · MJ : ${campagne.mjNom}'),
        trailing: FilledButton(
          onPressed: () => ouvrirSeance(context, contexte, campagne),
          child: const Text('Rejoindre'),
        ),
      ),
    );
  }
}

/// Ouvre l'écran de séance d'une campagne.
void ouvrirSeance(
  BuildContext context,
  ContexteCampagnes contexte,
  Campagne campagne,
) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => SeanceScreen(contexte: contexte, campagneId: campagne.id),
  ));
}

/// Liste des campagnes menées par le compte.
class CampagnesMjScreen extends StatelessWidget {
  const CampagnesMjScreen({super.key, required this.contexte});

  final ContexteCampagnes contexte;

  @override
  Widget build(BuildContext context) {
    final c = contexte.campagnes;
    return Scaffold(
      appBar: AppBar(title: const Text('Maître du jeu')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('nouvelle-campagne'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CreationCampagneScreen(contexte: contexte),
        )),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle campagne'),
      ),
      body: LargeurLimitee(
        child: ListenableBuilder(
          listenable: c,
          builder: (context, _) {
            final liste = c.commeMj;
            if (liste.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: TexteAVenir('Aucune campagne pour l\'instant : '
                      'crée la première avec « Nouvelle campagne ».'),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final x in liste)
                  _TuileCampagne(
                    campagne: x,
                    detail: [
                      '${x.joueurs.length}/${x.parametres.joueursMax} '
                          'joueur${x.parametres.joueursMax > 1 ? 's' : ''}',
                      if (x.demandes.isNotEmpty)
                        '${x.demandes.length} demande'
                            '${x.demandes.length > 1 ? 's' : ''}',
                      'code ${x.code}',
                    ].join(' · '),
                    alerte: x.demandes.isNotEmpty,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CampagneMjScreen(
                          contexte: contexte, campagneId: x.id),
                    )),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Liste des campagnes rejointes ou demandées.
class CampagnesJoueurScreen extends StatelessWidget {
  const CampagnesJoueurScreen({super.key, required this.contexte});

  final ContexteCampagnes contexte;

  @override
  Widget build(BuildContext context) {
    final c = contexte.campagnes;
    return Scaffold(
      appBar: AppBar(title: const Text('Joueur')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('rejoindre-campagne'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => RejoindreCampagneScreen(contexte: contexte),
        )),
        icon: const Icon(Icons.vpn_key_outlined),
        label: const Text('Rejoindre une campagne'),
      ),
      body: LargeurLimitee(
        child: ListenableBuilder(
          listenable: c,
          builder: (context, _) {
            final liste = c.commeJoueur;
            if (liste.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: TexteAVenir('Tu n\'as rejoint aucune campagne : '
                      'demande son code d\'invitation à ton MJ, puis '
                      '« Rejoindre une campagne ».'),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final x in liste)
                  _TuileCampagne(
                    campagne: x,
                    detail: [
                      'MJ : ${x.mjNom}',
                      x.joueurs.contains(c.uid)
                          ? StatutMembre.accepte.libelle
                          : StatutMembre.demande.libelle,
                    ].join(' · '),
                    alerte: x.seanceEnCours && x.joueurs.contains(c.uid),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CampagneJoueurScreen(
                          contexte: contexte, campagneId: x.id),
                    )),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TuileCampagne extends StatelessWidget {
  const _TuileCampagne({
    required this.campagne,
    required this.detail,
    required this.onTap,
    this.alerte = false,
  });

  final Campagne campagne;
  final String detail;
  final VoidCallback onTap;
  final bool alerte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        key: Key('campagne-${campagne.id}'),
        leading: Badge(
          isLabelVisible: alerte,
          child: AvatarPersonnage(nom: campagne.nom, rayon: 20),
        ),
        title: Text(campagne.nom, overflow: TextOverflow.ellipsis),
        subtitle: Text(detail),
        trailing: campagne.seanceEnCours
            ? Chip(
                avatar: Icon(Icons.circle,
                    size: 10, color: theme.colorScheme.primary),
                label: Text('Séance ${campagne.seance!.numero}'),
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
