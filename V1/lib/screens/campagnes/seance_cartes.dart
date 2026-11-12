import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/campagne.dart';
import '../../models/creature.dart';
import '../../models/objet.dart';
import '../../models/seance.dart';
import '../../regles/invocations.dart';
import '../../regles/montee_niveau.dart';
import '../../regles/objet_aleatoire.dart';
import '../../state/seance_controller.dart';
import '../../theme.dart';
import '../../widgets/consultation.dart';
import '../../widgets/dialogue_texte.dart';
import '../../widgets/infos_creature.dart';
import '../../widgets/profil_classe.dart';
import '../bestiaire_screen.dart';
import '../fiche/formulaire_objet.dart';
import '../fiche/vues_fiche.dart';
import '../montee_niveau_screen.dart';
import 'campagnes_screen.dart';
import 'fiche_partagee_screen.dart';
import 'seance_butin.dart';

/// Portion de gauche : script (MJ) ou notes de séance (PJ), personnages,
/// créatures. [onChoisie] : téléphone, passe à la vue Détail.
class ListeCartes extends StatelessWidget {
  const ListeCartes({super.key, required this.seance, this.onChoisie});

  final SeanceController seance;
  final VoidCallback? onChoisie;

  void _choisir(String id) {
    seance.choisirCarte(id);
    onChoisie?.call();
  }

  /// Icône et couleur de la famille, comme dans le bestiaire. Une créature
  /// ajoutée avant la version 0.29 retrouve sa famille par sa fiche.
  ({Color couleur, IconData icone})? _styleCreature(
    BuildContext context,
    CreatureSeance c,
  ) {
    final famille =
        c.famille.isNotEmpty ? c.famille : seance.ficheCreature(c)?.famille;
    if (famille == null || famille.isEmpty) return null;
    return styleFamille(famille, Theme.of(context).brightness);
  }

  @override
  Widget build(BuildContext context) {
    final s = seance;
    return ListView(
      key: const Key('liste-cartes'),
      padding: const EdgeInsets.all(8),
      children: [
        if (s.estMj)
          _Carte(
            cle: 'carte-script',
            selectionnee: s.carte == kCarteScript,
            icone: Icons.history_edu_outlined,
            titre: 'Script',
            onTap: () => _choisir(kCarteScript),
          )
        else
          _Carte(
            cle: 'carte-notes',
            selectionnee: s.carte == kCarteNotes,
            icone: Icons.edit_note,
            titre: 'Mes notes de séance',
            onTap: () => _choisir(kCarteNotes),
          ),
        // Deux parties bien séparées : les personnages des joueurs (et
        // leurs compagnons), puis les créatures rencontrées.
        if (s.joueurs.isNotEmpty || s.creatures.any((c) => c.allie))
          const _TitrePartie(
            cle: 'partie-personnages',
            icone: Icons.groups_outlined,
            titre: 'Personnages',
          ),
        for (final m in s.joueurs) ...[
          _Carte(
            cle: 'carte-${m.uid}',
            selectionnee: s.carte == m.uid,
            actif: s.etat.actif == m.uid,
            icone: Icons.person_outline,
            titre: m.personnageNom,
            lignes: [m.personnageResume],
            absent: !s.estPresent(m.uid),
            initiative: s.etat.enCombat ? m.initiative : null,
            ressources: [
              if (s.ressourcesDe(m.uid) case final r?) ...[
                _Ressource.vie(context, r.pv, r.pvMax),
                if (r.pmMax > 0) _Ressource.mana(context, r.pm, r.pmMax),
                if (r.peMax > 0) _Ressource.endurance(context, r.pe, r.peMax),
              ],
            ],
            onTap: () => _choisir(m.uid),
          ),
          // Compagnons et familiers qui se battent : sous leur propriétaire,
          // en retrait, avec sa mention. Entrés dans la partie (ajoutés par
          // le MJ) : PV suivis, initiative, tour, détail au centre.
          for (final c in s.compagnonsEnJeu(m.uid))
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: _Carte(
                cle: 'carte-${c.id}',
                selectionnee: s.carte == c.id,
                // Compagnon : il agit au tour de son maître.
                actif: s.etat.actif == (c.estCompagnon ? m.uid : c.id),
                icone: c.toursRestants != null
                    ? Icons.hourglass_bottom
                    : typeCompagnon(s.ficheCreature(c)) == 'Familier'
                        ? Icons.auto_awesome_outlined
                        : Icons.pets_outlined,
                couleurIcone: OdvCouleurs.or,
                titre: c.nom,
                initiative:
                    s.etat.enCombat && !c.estCompagnon ? c.initiative : null,
                ressources: [
                  if (c.pv != null && s.voitPvDe(c))
                    _Ressource.vie(context, c.pv!, c.pvMax ?? c.pv!),
                  // Invocation temporaire : tours restants.
                  if (c.toursRestants case final t?)
                    Tooltip(
                      message: 'Tours d\'invocation restants',
                      child: Row(
                        key: Key('tours-${c.id}'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.hourglass_bottom,
                            size: 14,
                            color: OdvCouleurs.or,
                          ),
                          Text(
                            '$t tour${t > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                ],
                lignes: [
                  '${libelleCreatureJoueur(c, s.ficheCreature(c))} de '
                      '${m.personnageNom}',
                ],
                onTap: () => _choisir(c.id),
                // Invocation temporaire : son lanceur ou le MJ peut la
                // renvoyer avant la fin (après confirmation).
                onRetirer: c.toursRestants != null &&
                        (s.estMj || c.proprietaire == s.uid)
                    ? () => _renvoyer(context, c)
                    : null,
                cleRetirer: 'retirer-${c.id}',
              ),
            ),
          // Pas encore dans la partie (fiche que le MJ ne lit pas) : fiche
          // du bestiaire seule.
          if (s.compagnonsEnJeu(m.uid).where((c) => c.estCompagnon).isEmpty)
            for (final x in s.compagnonsDe(m.uid))
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: _Carte(
                  cle: 'carte-compagnon-${m.uid}-${x.creature.id}',
                  selectionnee: false,
                  icone: x.type == 'Familier'
                      ? Icons.auto_awesome_outlined
                      : Icons.pets_outlined,
                  couleurIcone: OdvCouleurs.or,
                  titre: x.creature.nom,
                  lignes: [
                    '${x.type} de ${m.personnageNom}',
                    if (x.creature.ca != null || x.creature.pv != null)
                      [
                        if (x.creature.ca != null) 'CA ${x.creature.ca}',
                        if (x.creature.pv != null) 'PV ${x.creature.pv}',
                      ].join(' · '),
                  ],
                  onTap: () => afficherCreature(context, x.creature),
                ),
              ),
        ],
        // Alliés des PJ contrôlés par le MJ (escorte…), avec les personnages.
        for (final c in s.creatures)
          if (c.allie && !c.estAUnJoueur)
            _Carte(
              cle: 'carte-${c.id}',
              selectionnee: s.carte == c.id,
              actif: s.etat.actif == c.id,
              cleIcone: 'icone-${c.id}',
              icone: Icons.shield_outlined,
              couleurIcone: OdvCouleurs.green,
              titre: c.nom,
              initiative: s.etat.enCombat ? c.initiative : null,
              ressources: [
                if (c.pv != null)
                  _Ressource.vie(context, c.pv!, c.pvMax ?? c.pv!),
              ],
              lignes: [
                'Allié · joué par le MJ',
                if (s.estMj && c.cachee) 'Carte cachée aux PJ',
              ],
              onTap: () => _choisir(c.id),
              onRetirer: s.estMj
                  ? () async {
                      final erreur = await s.retirerCreature(c);
                      if (erreur != null && context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(erreur)));
                      }
                    }
                  : null,
              cleRetirer: 'retirer-${c.id}',
            ),
        if (s.creatures.any((c) => !c.duCotePj))
          const _TitrePartie(
            cle: 'partie-creatures',
            icone: Icons.pets_outlined,
            titre: 'Créatures rencontrées',
            separe: true,
          ),
        for (final c in s.creatures)
          if (!c.duCotePj)
            _Carte(
              cle: 'carte-${c.id}',
              selectionnee: s.carte == c.id,
              actif: s.etat.actif == c.id,
              cleIcone: 'icone-${c.id}',
              icone: _styleCreature(context, c)?.icone ?? Icons.pets_outlined,
              couleurIcone: _styleCreature(context, c)?.couleur,
              titre: c.nom,
              initiative: s.etat.enCombat ? c.initiative : null,
              ressources: [
                if (c.pv != null)
                  _Ressource.vie(context, c.pv!, c.pvMax ?? c.pv!),
              ],
              lignes: [
                if (c.pv == null) c.etat.libelle,
                if (s.estMj && c.cachee)
                  'Carte cachée aux PJ'
                else if (s.estMj && c.nomCache)
                  'Nom caché aux PJ',
              ],
              onTap: () => _choisir(c.id),
              // Petite croix rouge : retirer la créature de la partie.
              onRetirer: s.estMj
                  ? () async {
                      final erreur = await s.retirerCreature(c);
                      if (erreur != null && context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(erreur)));
                      }
                    }
                  : null,
              cleRetirer: 'retirer-${c.id}',
            ),
        for (final b in s.butins)
          _Carte(
            cle: 'carte-${b.id}',
            selectionnee: s.carte == b.id,
            icone: Icons.redeem_outlined,
            couleurIcone: OdvCouleurs.or,
            titre: b.nom,
            lignes: [
              b.resume,
              if (s.estMj && b.cache) 'Caché aux PJ',
            ],
            onTap: () => _choisir(b.id),
            onRetirer: s.estMj
                ? () async {
                    final erreur = await s.retirerButin(b);
                    if (erreur != null && context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(erreur)));
                    }
                  }
                : null,
            cleRetirer: 'retirer-${b.id}',
          ),
        if (s.estMj)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              key: const Key('creer-butin'),
              onPressed: () => _creerButin(context),
              icon: const Icon(Icons.redeem_outlined),
              label: const Text('Créer un butin'),
            ),
          ),
      ],
    );
  }

  /// Renvoie une invocation avant la fin, après confirmation.
  Future<void> _renvoyer(BuildContext context, CreatureSeance c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Renvoyer « ${c.nom} » ?'),
        content: const Text(
            'L\'invocation disparaît tout de suite, avant la fin de sa durée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Garder'),
          ),
          FilledButton(
            key: const Key('confirmer-renvoi'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Renvoyer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final erreur = await seance.renvoyerInvocation(c);
    if (erreur != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(erreur)));
    }
  }

  Future<void> _creerButin(BuildContext context) async {
    final nom = await showDialog<String>(
      context: context,
      builder: (_) => const DialogueTexte(
        titre: 'Nouveau butin',
        valeur: 'Butin',
        exemple: 'Ex. : Coffre du gobelin',
        cleChamp: 'champ-nom-butin',
        cleValider: 'valider-nom-butin',
      ),
    );
    if (nom == null) return;
    final erreur = await seance.creerButin(nom);
    if (erreur != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(erreur)));
    }
  }
}

/// MJ : tire un objet du catalogue avec un bonus, le relance ou le modifie,
/// puis le donne au joueur.
class _DialogueObjetAleatoire extends StatefulWidget {
  const _DialogueObjetAleatoire({
    required this.seance,
    required this.joueur,
    required this.nomJoueur,
  });

  final SeanceController seance;
  final String joueur;
  final String nomJoueur;

  @override
  State<_DialogueObjetAleatoire> createState() =>
      _DialogueObjetAleatoireState();
}

class _DialogueObjetAleatoireState extends State<_DialogueObjetAleatoire> {
  final _aleatoire = Random();
  var _puissance = PuissanceObjet.hasard;
  late Objet? _objet = _tirer();

  Objet? _tirer() => tirerObjetAleatoire(
        widget.seance.referentiel.equipements,
        _aleatoire,
        puissance: _puissance,
      );

  Future<void> _modifier() async {
    final o = _objet;
    if (o == null) return;
    final modifie = await FormulaireObjet.ouvrir(context, objet: o);
    if (modifie != null && mounted) setState(() => _objet = modifie);
  }

  Future<void> _donner() async {
    final o = _objet;
    if (o == null) return;
    final navigator = Navigator.of(context);
    final messager = ScaffoldMessenger.of(context);
    final erreur = await widget.seance.donnerObjet(widget.joueur, o);
    navigator.pop();
    messager.showSnackBar(
      SnackBar(
          content: Text(erreur ?? '${o.nom} : donné à ${widget.nomJoueur}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = _objet;
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Objet aléatoire'),
      content: o == null
          ? const Text('Aucune arme ni armure dans le catalogue.')
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Puissance', style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final p in PuissanceObjet.values)
                      ChoiceChip(
                        key: Key('puissance-${p.name}'),
                        label: Text(p.libelle),
                        selected: _puissance == p,
                        onSelected: (_) => setState(() {
                          _puissance = p;
                          _objet = _tirer();
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  o.nom,
                  key: const Key('nom-objet-aleatoire'),
                  style: theme.textTheme.titleMedium,
                ),
                if (o.resume.isNotEmpty) Text(o.resume),
                if (o.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(o.description, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        if (o != null) ...[
          TextButton(
            key: const Key('relancer-objet'),
            onPressed: () => setState(() => _objet = _tirer()),
            child: const Text('Relancer'),
          ),
          TextButton(
            key: const Key('modifier-objet-aleatoire'),
            onPressed: _modifier,
            child: const Text('Modifier'),
          ),
          FilledButton(
            key: const Key('donner-objet'),
            onPressed: _donner,
            child: Text('Donner à ${widget.nomJoueur}'),
          ),
        ],
      ],
    );
  }
}

class _Carte extends StatelessWidget {
  const _Carte({
    required this.cle,
    required this.selectionnee,
    required this.icone,
    required this.titre,
    required this.onTap,
    this.cleIcone,
    this.couleurIcone,
    this.lignes = const [],
    this.ressources = const [],
    this.initiative,
    this.absent = false,
    this.actif = false,
    this.onRetirer,
    this.cleRetirer,
  });

  final String cle;
  final bool selectionnee;
  final IconData icone;
  final String? cleIcone;

  /// Couleur de l'icône ; par défaut, celle du thème.
  final Color? couleurIcone;
  final String titre;
  final List<String> lignes;

  /// PV, PM, PE avec leurs icônes et couleurs.
  final List<Widget> ressources;

  /// Initiative, affichée en combat.
  final int? initiative;

  /// Joueur pas connecté ou pas dans la séance.
  final bool absent;
  final VoidCallback onTap;

  /// C'est son tour.
  final bool actif;
  final VoidCallback? onRetirer;
  final String? cleRetirer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      key: actif ? Key('$cle-tour') : null,
      // C'est son tour : carte teintée d'or, elle ressort des autres.
      color: actif ? OdvCouleurs.or.withValues(alpha: 0.3) : null,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selectionnee
              ? scheme.primary
              : actif
                  ? OdvCouleurs.or
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        key: Key(cle),
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
          child: Row(
            children: [
              Icon(
                icone,
                key: cleIcone == null ? null : Key(cleIcone!),
                size: 20,
                color: couleurIcone ?? scheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    for (final l in lignes)
                      Text(
                        l,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    if (ressources.isNotEmpty || initiative != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            ...ressources,
                            if (initiative != null)
                              Tooltip(
                                message: 'Initiative',
                                child: Row(
                                  key: Key('$cle-initiative'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.bolt,
                                      size: 14,
                                      color: scheme.primary,
                                    ),
                                    Text(
                                      '$initiative',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (absent)
                Tooltip(
                  message: 'Pas connecté ou pas dans la séance',
                  child: Icon(
                    key: Key('$cle-absent'),
                    Icons.person_off_outlined,
                    size: 18,
                    color: scheme.error,
                  ),
                ),
              if (actif) const Icon(Icons.play_arrow, color: OdvCouleurs.or),
              if (onRetirer != null)
                IconButton(
                  key: Key(cleRetirer ?? ''),
                  tooltip: 'Retirer de la partie',
                  visualDensity: VisualDensity.compact,
                  onPressed: onRetirer,
                  icon: Icon(Icons.close, size: 18, color: scheme.error),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Centre : infos de la carte sélectionnée.
class DetailCarte extends StatelessWidget {
  const DetailCarte({super.key, required this.seance, required this.contexte});

  final SeanceController seance;
  final ContexteCampagnes contexte;

  @override
  Widget build(BuildContext context) {
    final s = seance;
    final id = s.carte;
    if (id == kCarteScript || id == kCarteNotes) {
      return _EditeurSeance(key: ValueKey(id), seance: s);
    }
    for (final b in s.butins) {
      if (b.id == id) return DetailButin(seance: s, butin: b);
    }
    for (final m in s.joueurs) {
      if (m.uid == id) return _detailPj(context, m);
    }
    for (final c in s.creatures) {
      if (c.id == id) {
        // Compagnon : à qui il appartient.
        String? mention;
        for (final m in s.joueurs) {
          if (m.uid == c.proprietaire) {
            final t = c.toursRestants;
            final s2 = (t ?? 0) > 1 ? 's' : '';
            mention = '${libelleCreatureJoueur(c, s.ficheCreature(c))} de '
                '${m.personnageNom}'
                '${t == null ? '' : ' · $t tour$s2 restant$s2'}';
          }
        }
        return s.estMj
            ? _CreatureMj(
                key: ValueKey(c.id),
                seance: s,
                creature: c,
                mention: mention,
              )
            : _CreaturePj(
                creature: s.voitPvDe(c) ? c : c.sansPv(),
                fiche: s.voitFicheDe(c) ? s.ficheCreature(c) : null,
                mention: mention,
              );
      }
    }
    return const Center(child: TexteAVenir('Choisis une carte.'));
  }

  Widget _detailPj(BuildContext context, MembreCampagne m) {
    final s = seance;
    final ref = contexte.referentiel;
    final f = s.ficheDe(m.uid);
    if (f != null) {
      // Sa propre fiche, ou le MJ : fiche complète et modifiable.
      if (m.uid == s.uid) {
        final fiche = FicheComplete(
          key: ValueKey(m.uid),
          fiche: f,
          referentiel: ref,
          controller: contexte.personnages,
          onModifie: () => contexte.personnages.sauvegarder(f.personnage),
          onEnvoyerObjet: s.joueurs.length < 2
              ? null
              : (o) => showDialog<void>(
                    context: context,
                    builder: (_) => DialogueEnvoiObjet(seance: s, objet: o),
                  ),
        );
        final p = f.personnage;
        if (!s.etat.peutMonter(m.uid, p.niveau, personnage: m.personnageId) ||
            !MonteeNiveau.possible(p)) {
          return fiche;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: FilledButton.icon(
                key: const Key('monter-niveau-seance'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MonteeNiveauScreen(
                      personnage: p,
                      race: f.race,
                      classe: f.classe,
                      referentiel: ref,
                      controller: contexte.personnages,
                    ),
                  ),
                ),
                icon: const Icon(Icons.keyboard_double_arrow_up),
                label:
                    Text('Le MJ autorise : passer au niveau ${p.niveau + 1}'),
              ),
            ),
            Expanded(child: fiche),
          ],
        );
      }
      if (s.estMj) {
        final p = f.personnage;
        final autorisee =
            s.etat.peutMonter(m.uid, p.niveau, personnage: m.personnageId);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (MonteeNiveau.possible(p))
                    OutlinedButton.icon(
                      key: Key('autoriser-montee-${m.uid}'),
                      onPressed: () => s.basculerMontee(m.uid, p.niveau,
                          personnage: m.personnageId),
                      icon: Icon(
                        autorisee
                            ? Icons.check_circle
                            : Icons.keyboard_double_arrow_up,
                      ),
                      label: Text(
                        autorisee
                            ? 'Montée de niveau autorisée'
                            : 'Autoriser la montée de niveau',
                      ),
                    ),
                  OutlinedButton.icon(
                    key: Key('objet-aleatoire-${m.uid}'),
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _DialogueObjetAleatoire(
                        seance: s,
                        joueur: m.uid,
                        nomJoueur: m.personnageNom,
                      ),
                    ),
                    icon: const Icon(Icons.casino_outlined),
                    label: const Text('Objet aléatoire'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FicheComplete(
                key: ValueKey(m.uid),
                fiche: f,
                referentiel: ref,
                onModifie: () => s.enregistrerFiche(f.personnage),
              ),
            ),
          ],
        );
      }
      return FicheLecture(
        key: ValueKey(m.uid),
        fiche: f,
        referentiel: ref,
        joueur: m.nom,
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(m.personnageNom, style: const TextStyle(fontSize: 20)),
            Text(m.personnageResume),
            const SizedBox(height: 8),
            const TexteAVenir('Fiche non partagée dans cette campagne.'),
          ],
        ),
      ),
    );
  }
}

/// PV, PM ou PE sur une carte : icône et valeur de la couleur de la ressource.
class _Ressource extends StatelessWidget {
  const _Ressource(this.icone, this.texte, this.couleur);

  factory _Ressource.vie(BuildContext context, int v, int max) => _Ressource(
        Icons.favorite,
        '$v/$max',
        couleurVie(Theme.of(context).brightness),
      );

  factory _Ressource.mana(BuildContext context, int v, int max) => _Ressource(
        Icons.water_drop,
        '$v/$max',
        couleurMana(Theme.of(context).brightness),
      );

  factory _Ressource.endurance(BuildContext context, int v, int max) =>
      _Ressource(
        kIconeEndurance,
        '$v/$max',
        couleurEndurance(Theme.of(context).brightness),
      );

  final IconData icone;
  final String texte;
  final Color couleur;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: couleur),
          const SizedBox(width: 2),
          Text(
            texte,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: couleur,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      );
}

/// Script (MJ) ou notes de séance (PJ), enregistrés au bouton.
class _EditeurSeance extends StatefulWidget {
  const _EditeurSeance({super.key, required this.seance});

  final SeanceController seance;

  @override
  State<_EditeurSeance> createState() => _EditeurSeanceState();
}

class _EditeurSeanceState extends State<_EditeurSeance> {
  late final _texte = TextEditingController(text: widget.seance.texte);
  late String _enregistre = widget.seance.texte;

  @override
  void didUpdateWidget(_EditeurSeance ancien) {
    super.didUpdateWidget(ancien);
    // Texte chargé après l'ouverture : repris s'il n'a pas été modifié.
    final t = widget.seance.texte;
    if (t != _enregistre && _texte.text == _enregistre) {
      _enregistre = t;
      _texte.text = t;
    }
  }

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mj = widget.seance.estMj;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          mj ? 'Script' : 'Mes notes de séance',
          style: styleAmbiance(Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 4),
        Text(mj
            ? 'Visible du MJ seulement.'
            : 'Visibles par toi seul, pour cette séance.'),
        const SizedBox(height: 12),
        TextField(
          key: const Key('texte-seance'),
          controller: _texte,
          minLines: 12,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const Key('enregistrer-texte-seance'),
            onPressed: () async {
              final messager = ScaffoldMessenger.of(context);
              final texte = _texte.text;
              final erreur = await widget.seance.enregistrerTexte(texte);
              if (erreur == null) _enregistre = texte;
              messager.showSnackBar(
                SnackBar(content: Text(erreur ?? 'Enregistré.')),
              );
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Enregistrer'),
          ),
        ),
      ],
    );
  }
}

/// Créature côté MJ : PV, ce que voient les PJ, fiche du bestiaire.
class _CreatureMj extends StatelessWidget {
  const _CreatureMj({
    super.key,
    required this.seance,
    required this.creature,
    this.mention,
  });

  final SeanceController seance;
  final CreatureSeance creature;

  /// Compagnon : « Compagnon de Brom ».
  final String? mention;

  @override
  Widget build(BuildContext context) {
    final c = creature;
    final s = seance;
    final fiche = s.ficheCreature(c);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.nom, style: styleAmbiance(theme.textTheme.titleLarge)),
              if (mention != null)
                Text(
                  mention!,
                  key: const Key('mention-compagnon'),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: OdvCouleurs.or),
                ),
              if (c.pv != null)
                Row(
                  children: [
                    IconButton(
                      key: const Key('creature-pv-moins'),
                      onPressed: () =>
                          s.modifierCreature(c.copie(pv: c.pv! - 1)),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      'PV ${c.pv}/${c.pvMax}',
                      key: const Key('creature-pv'),
                      style: theme.textTheme.titleMedium,
                    ),
                    IconButton(
                      key: const Key('creature-pv-plus'),
                      onPressed: c.pv! >= c.pvMax!
                          ? null
                          : () => s.modifierCreature(c.copie(pv: c.pv! + 1)),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        c.etat.libelle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (!c.estAUnJoueur) ...[
                SwitchListTile(
                  key: const Key('creature-allie'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Allié des PJ'),
                  subtitle: const Text('Avec les personnages, joué par le MJ'),
                  value: c.allie,
                  onChanged: (v) => s.modifierCreature(c.copie(allie: v)),
                ),
                SwitchListTile(
                  key: const Key('creature-cachee'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Cacher la carte aux PJ'),
                  value: c.cachee,
                  onChanged: (v) => s.modifierCreature(c.copie(cachee: v)),
                ),
                SwitchListTile(
                  key: const Key('creature-nom-cache'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Cacher son nom aux PJ'),
                  value: c.nomCache,
                  onChanged: c.cachee
                      ? null
                      : (v) => s.modifierCreature(c.copie(nomCache: v)),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: fiche == null
              ? const Center(child: TexteAVenir('Fiche introuvable.'))
              : CreatureDetail(creature: fiche),
        ),
      ],
    );
  }
}

/// Créature côté PJ : nom affiché, description et état approximatif.
class _CreaturePj extends StatelessWidget {
  const _CreaturePj({required this.creature, this.fiche, this.mention});

  final CreatureSeance creature;

  /// Compagnon : « Compagnon de Brom ».
  final String? mention;

  /// Fiche du bestiaire, si le MJ la montre aux PJ.
  final Creature? fiche;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final f = fiche;
    if (f != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              [
                creature.nom,
                creature.pv != null
                    ? 'PV ${creature.pv}/${creature.pvMax}'
                    : creature.etat.libelle,
              ].join(' · '),
              style: styleAmbiance(theme.textTheme.titleLarge),
            ),
          ),
          if (mention != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: Text(
                mention!,
                key: const Key('mention-compagnon'),
                style:
                    theme.textTheme.titleSmall?.copyWith(color: OdvCouleurs.or),
              ),
            ),
          Expanded(child: CreatureDetail(creature: f)),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(creature.nom, style: styleAmbiance(theme.textTheme.titleLarge)),
        const SizedBox(height: 4),
        Text(
          creature.etat.libelle,
          key: const Key('creature-etat'),
          style: theme.textTheme.titleSmall,
        ),
        if (creature.pv != null)
          Text('PV ${creature.pv}/${creature.pvMax}',
              key: const Key('creature-pv')),
        const SizedBox(height: 12),
        if (creature.description.isNotEmpty) Text(creature.description),
      ],
    );
  }
}

/// Titre d'une partie de la liste de gauche (« Personnages », « Créatures
/// rencontrées ») ; [separe] : un trait la sépare de la partie d'avant.
class _TitrePartie extends StatelessWidget {
  const _TitrePartie({
    required this.cle,
    required this.icone,
    required this.titre,
    this.separe = false,
  });

  final String cle;
  final IconData icone;
  final String titre;
  final bool separe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      key: Key(cle),
      padding: EdgeInsets.only(top: separe ? 6 : 4, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (separe) ...[
            Divider(height: 1, thickness: 1.5, color: scheme.outlineVariant),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Icon(icone, size: 16, color: scheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  titre.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
