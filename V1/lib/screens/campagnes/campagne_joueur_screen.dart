import 'package:flutter/material.dart';

import '../../models/campagne.dart';
import '../../widgets/consultation.dart';
import 'campagnes_screen.dart';
import 'creation_campagne_screen.dart';
import 'fiche_partagee_screen.dart';
import 'rejoindre_campagne_screen.dart';

/// Page d'une campagne pour un joueur : présentation, séance en cours, son
/// personnage, les autres membres ; changer de personnage ou quitter.
class CampagneJoueurScreen extends StatelessWidget {
  const CampagneJoueurScreen({
    super.key,
    required this.contexte,
    required this.campagneId,
  });

  final ContexteCampagnes contexte;
  final String campagneId;

  Future<void> _changerPersonnage(
    BuildContext context,
    Campagne c,
    MembreCampagne? moi,
  ) async {
    final personnages = contexte.personnages.personnages;
    final id = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Changer de personnage'),
        children: [
          for (final p in personnages)
            SimpleDialogOption(
              key: Key('changer-${p.id}'),
              onPressed: () => Navigator.pop(context, p.id),
              child: ListTile(
                title: Text(p.nom),
                subtitle: Text(resumePersonnage(contexte, p)),
                selected: p.id == moi?.personnageId,
              ),
            ),
        ],
      ),
    );
    final p = id == null ? null : contexte.personnages.parId(id);
    if (p == null || p.id == moi?.personnageId || !context.mounted) return;
    // Nouvelle demande : le MJ valide le changement.
    final erreur = await contexte.campagnes.agir((s) async {
      if (c.joueurs.contains(s.uid)) await s.quitter(c);
      await s.demander(c, membrePour(contexte, p));
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(erreur ?? 'Demande envoyée : le MJ doit accepter ${p.nom}.'),
      ));
    }
  }

  Future<void> _quitter(BuildContext context, Campagne c, bool membre) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(membre ? 'Quitter « ${c.nom} » ?' : 'Annuler la demande ?'),
        content: Text(membre
            ? 'Il faudra un nouveau code et l\'accord du MJ pour revenir.'
            : 'Le MJ ne verra plus ta demande.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Rester'),
          ),
          FilledButton(
            key: const Key('confirmer-quitter'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(membre ? 'Quitter' : 'Annuler la demande'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final navigator = Navigator.of(context);
    final erreur = await contexte.campagnes.agir((s) => s.quitter(c));
    if (erreur == null) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: contexte.campagnes,
      builder: (context, _) {
        final c = contexte.campagnes.parId(campagneId);
        final uid = contexte.campagnes.uid;
        if (c == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: TexteAVenir('Tu ne fais plus partie de cette campagne.'),
            ),
          );
        }
        final membre = c.joueurs.contains(uid);
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(c.nom, overflow: TextOverflow.ellipsis)),
          body: LargeurLimitee(
            child: StreamBuilder<List<MembreCampagne>>(
              stream: contexte.campagnes.serviceActuel?.ecouterMembres(c.id),
              builder: (context, snap) {
                final membres = snap.data ?? const [];
                MembreCampagne? moi;
                for (final m in membres) {
                  if (m.uid == uid) moi = m;
                }
                final autres = [
                  for (final m in membres)
                    if (m.uid != uid && m.statut == StatutMembre.accepte) m,
                ];
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (membre && c.seanceEnCours)
                      BandeauSeance(campagne: c, contexte: contexte),
                    BlocConsultation(
                      titre: 'La campagne',
                      icone: Icons.menu_book_outlined,
                      children: [
                        Text('MJ : ${c.mjNom}'),
                        Text(
                          membre
                              ? StatutMembre.accepte.libelle
                              : StatutMembre.demande.libelle,
                          key: const Key('statut-joueur'),
                          style: TextStyle(
                            color: membre
                                ? theme.colorScheme.primary
                                : theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (c.seance case final s? when !s.enCours)
                          Text('Dernière séance : n° ${s.numero}'),
                        if (c.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(c.description),
                        ],
                      ],
                    ),
                    BlocConsultation(
                      titre: 'Paramètres de la campagne',
                      icone: Icons.tune,
                      children: [ResumeParametres(c.parametres)],
                    ),
                    BlocConsultation(
                      titre: 'Mon personnage',
                      icone: Icons.person_outline,
                      children: [
                        if (moi != null)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(moi.personnageNom),
                            subtitle: Text(moi.personnageResume),
                          ),
                        Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton.icon(
                              key: const Key('changer-personnage'),
                              onPressed: () =>
                                  _changerPersonnage(context, c, moi),
                              icon: const Icon(Icons.swap_horiz),
                              label: const Text('Changer de personnage'),
                            ),
                            TextButton.icon(
                              key: const Key('quitter-campagne'),
                              onPressed: () => _quitter(context, c, membre),
                              icon: const Icon(Icons.logout),
                              label: Text(membre
                                  ? 'Quitter la campagne'
                                  : 'Annuler la demande'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (membre)
                      BlocConsultation(
                        titre: 'Les autres joueurs',
                        icone: Icons.groups_outlined,
                        children: [
                          if (autres.isEmpty)
                            const TexteAVenir('Personne d\'autre pour '
                                'l\'instant.'),
                          for (final m in autres)
                            ListTile(
                              key: Key('membre-${m.uid}'),
                              contentPadding: EdgeInsets.zero,
                              title: Text('${m.personnageNom} (${m.nom})'),
                              subtitle: Text(m.personnageResume),
                              trailing: c.parametres.fichesVisiblesJoueurs
                                  ? const Icon(Icons.chevron_right)
                                  : null,
                              onTap: c.parametres.fichesVisiblesJoueurs
                                  ? () =>
                                      ouvrirFichePartagee(context, contexte, m)
                                  : null,
                            ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
