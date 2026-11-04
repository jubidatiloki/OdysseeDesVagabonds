import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/campagne.dart';
import '../../widgets/consultation.dart';
import 'campagnes_screen.dart';
import 'creation_campagne_screen.dart';
import 'fiche_partagee_screen.dart';
import 'seance_recaps.dart';

/// Page d'une campagne pour son MJ : joueurs et invitations, script, notes,
/// paramètres ; démarrer ou reprendre une séance.
class CampagneMjScreen extends StatelessWidget {
  const CampagneMjScreen({
    super.key,
    required this.contexte,
    required this.campagneId,
  });

  final ContexteCampagnes contexte;
  final String campagneId;

  Future<void> _seance(BuildContext context, Campagne c) async {
    if (c.seanceEnCours) {
      ouvrirSeance(context, contexte, c);
      return;
    }
    final numero = (c.seance?.numero ?? 0) + 1;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Démarrer la séance $numero ?'),
        content: Text(c.joueurs.isEmpty
            ? 'Aucun joueur n\'a encore rejoint la campagne : invite-les '
                'avec le code ${c.code}.'
            : 'Les ${c.joueurs.length} joueur${c.joueurs.length > 1 ? 's' : ''}'
                ' de la campagne seront avertis.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('confirmer-seance'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Démarrer'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final erreur = await contexte.campagnes.agir((s) => s.demarrerSeance(c));
    if (!context.mounted) return;
    if (erreur != null) {
      _message(context, erreur);
    } else {
      ouvrirSeance(context, contexte, c);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: contexte.campagnes,
      builder: (context, _) {
        final c = contexte.campagnes.parId(campagneId);
        if (c == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: TexteAVenir('Campagne supprimée.')),
          );
        }
        return DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              title: Text(c.nom, overflow: TextOverflow.ellipsis),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilledButton.icon(
                    key: const Key('bouton-seance'),
                    onPressed: () => _seance(context, c),
                    icon: Icon(c.seanceEnCours
                        ? Icons.play_circle_outline
                        : Icons.play_arrow),
                    label: Text(c.seanceEnCours
                        ? 'Reprendre la séance ${c.seance!.numero}'
                        : 'Démarrer une séance'),
                  ),
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(
                    key: const Key('onglet-joueurs'),
                    icon: Badge(
                      isLabelVisible: c.demandes.isNotEmpty,
                      label: Text('${c.demandes.length}'),
                      child: const Icon(Icons.groups_outlined),
                    ),
                    text: 'Joueurs',
                  ),
                  const Tab(
                    key: Key('onglet-script'),
                    icon: Icon(Icons.history_edu_outlined),
                    text: 'Script',
                  ),
                  const Tab(
                    key: Key('onglet-notes'),
                    icon: Icon(Icons.sticky_note_2_outlined),
                    text: 'Notes',
                  ),
                  const Tab(
                    key: Key('onglet-seances'),
                    icon: Icon(Icons.event_note_outlined),
                    text: 'Séances',
                  ),
                  const Tab(
                    key: Key('onglet-parametres'),
                    icon: Icon(Icons.tune),
                    text: 'Paramètres',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _OngletJoueurs(contexte: contexte, campagne: c),
                _OngletPrive(
                  contexte: contexte,
                  campagne: c,
                  script: true,
                ),
                _OngletPrive(
                  contexte: contexte,
                  campagne: c,
                  script: false,
                ),
                OngletRecaps(contexte: contexte, campagne: c),
                _OngletParametres(contexte: contexte, campagne: c),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _message(BuildContext context, String texte) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));

/// Code d'invitation, demandes en attente, joueurs.
class _OngletJoueurs extends StatelessWidget {
  const _OngletJoueurs({required this.contexte, required this.campagne});

  final ContexteCampagnes contexte;
  final Campagne campagne;

  @override
  Widget build(BuildContext context) {
    final c = campagne;
    final service = contexte.campagnes.serviceActuel;
    final theme = Theme.of(context);
    return LargeurLimitee(
      child: StreamBuilder<List<MembreCampagne>>(
        stream: service?.ecouterMembres(c.id),
        builder: (context, snap) {
          final membres = snap.data ?? const [];
          final demandes = [
            for (final m in membres)
              if (m.statut == StatutMembre.demande) m,
          ];
          final joueurs = [
            for (final m in membres)
              if (m.statut == StatutMembre.accepte) m,
          ];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              BlocConsultation(
                titre: 'Inviter des joueurs',
                icone: Icons.vpn_key_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          c.code,
                          key: const Key('code-campagne'),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        key: const Key('copier-code'),
                        tooltip: 'Copier le code',
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: c.code));
                          if (context.mounted) {
                            _message(context, 'Code copié : ${c.code}');
                          }
                        },
                        icon: const Icon(Icons.copy),
                      ),
                      IconButton(
                        key: const Key('nouveau-code'),
                        tooltip: 'Nouveau code (l\'ancien ne marchera plus)',
                        onPressed: () async {
                          final erreur = await contexte.campagnes
                              .agir((s) => s.nouveauCode(c));
                          if (context.mounted) {
                            _message(context, erreur ?? 'Nouveau code créé.');
                          }
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  Text(
                    '${c.joueurs.length}/${c.parametres.joueursMax} '
                    'place${c.parametres.joueursMax > 1 ? 's' : ''} occupée'
                    '${c.joueurs.length > 1 ? 's' : ''}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              if (demandes.isNotEmpty)
                BlocConsultation(
                  titre: 'Demandes en attente',
                  icone: Icons.mark_email_unread_outlined,
                  children: [
                    for (final m in demandes)
                      ListTile(
                        key: Key('demande-${m.uid}'),
                        contentPadding: EdgeInsets.zero,
                        title: Text('${m.nom} — ${m.personnageNom}'),
                        subtitle: Text(m.personnageResume),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              key: Key('refuser-${m.uid}'),
                              tooltip: 'Refuser',
                              onPressed: () => contexte.campagnes
                                  .agir((s) => s.retirer(c, m.uid))
                                  .then((e) {
                                if (e != null && context.mounted) {
                                  _message(context, e);
                                }
                              }),
                              icon: const Icon(Icons.close),
                            ),
                            FilledButton(
                              key: Key('accepter-${m.uid}'),
                              onPressed: () => contexte.campagnes
                                  .agir((s) => s.accepter(c, m.uid))
                                  .then((e) {
                                if (e != null && context.mounted) {
                                  _message(context, e);
                                }
                              }),
                              child: const Text('Accepter'),
                            ),
                          ],
                        ),
                        onTap: c.parametres.fichesVisiblesMj
                            ? () => ouvrirFichePartagee(context, contexte, m)
                            : null,
                      ),
                  ],
                ),
              BlocConsultation(
                titre: 'Joueurs',
                icone: Icons.groups_outlined,
                children: [
                  if (joueurs.isEmpty)
                    const TexteAVenir('Aucun joueur pour l\'instant.'),
                  for (final m in joueurs)
                    ListTile(
                      key: Key('joueur-${m.uid}'),
                      contentPadding: EdgeInsets.zero,
                      title: Text('${m.personnageNom} (${m.nom})'),
                      subtitle: Text(m.personnageResume),
                      onTap: c.parametres.fichesVisiblesMj
                          ? () => ouvrirFichePartagee(context, contexte, m)
                          : null,
                      trailing: PopupMenuButton<String>(
                        key: Key('menu-joueur-${m.uid}'),
                        onSelected: (choix) async {
                          if (choix == 'fiche') {
                            ouvrirFichePartagee(context, contexte, m);
                          } else {
                            final ok = await _confirmer(
                              context,
                              'Retirer ${m.nom} ?',
                              '${m.personnageNom} quittera la campagne.',
                              'Retirer',
                            );
                            if (ok) {
                              await contexte.campagnes
                                  .agir((s) => s.retirer(c, m.uid));
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          if (c.parametres.fichesVisiblesMj)
                            const PopupMenuItem(
                              value: 'fiche',
                              child: Text('Voir la fiche'),
                            ),
                          const PopupMenuItem(
                            value: 'retirer',
                            child: Text('Retirer de la campagne'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<bool> _confirmer(
  BuildContext context,
  String titre,
  String texte,
  String action,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titre),
        content: Text(texte),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('confirmer'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ==
    true;

/// Script ou notes du MJ : chargés à l'ouverture, enregistrés au bouton.
class _OngletPrive extends StatefulWidget {
  const _OngletPrive({
    required this.contexte,
    required this.campagne,
    required this.script,
  });

  final ContexteCampagnes contexte;
  final Campagne campagne;

  /// Script (sinon : notes générales).
  final bool script;

  @override
  State<_OngletPrive> createState() => _OngletPriveState();
}

class _OngletPriveState extends State<_OngletPrive>
    with AutomaticKeepAliveClientMixin {
  final _texte = TextEditingController();
  PriveCampagne? _prive;
  String _enregistre = '';
  var _envoi = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _texte.addListener(() => setState(() {}));
    _charger();
  }

  Future<void> _charger() async {
    PriveCampagne? p;
    await widget.contexte.campagnes.agir((s) async {
      p = await s.lirePrive(widget.campagne.id);
    });
    if (!mounted) return;
    final prive = p ?? const PriveCampagne();
    setState(() {
      _prive = prive;
      _enregistre = widget.script ? prive.script : prive.notes;
      _texte.text = _enregistre;
    });
  }

  Future<void> _enregistrer() async {
    setState(() => _envoi = true);
    // Relit l'autre partie (script ou notes) pour ne pas l'écraser.
    final erreur = await widget.contexte.campagnes.agir((s) async {
      final actuel = await s.lirePrive(widget.campagne.id);
      final p = widget.script
          ? PriveCampagne(script: _texte.text, notes: actuel.notes)
          : PriveCampagne(script: actuel.script, notes: _texte.text);
      await s.ecrirePrive(widget.campagne.id, p);
      _prive = p;
    });
    if (!mounted) return;
    setState(() {
      _envoi = false;
      if (erreur == null) _enregistre = _texte.text;
    });
    _message(context, erreur ?? 'Enregistré.');
  }

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_prive == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final modifie = _texte.text != _enregistre;
    return LargeurLimitee(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EditeurTexteCampagne(
            cle: widget.script ? 'mj-script' : 'mj-notes',
            controleur: _texte,
            indication: widget.script
                ? 'Trame, scènes, PNJ, rebondissements…'
                : 'Idées, règles maison, rappels…',
            importable: widget.script,
            lignes: 14,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                key: Key(
                    widget.script ? 'enregistrer-script' : 'enregistrer-notes'),
                onPressed: modifie && !_envoi ? _enregistrer : null,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Enregistrer'),
              ),
              const SizedBox(width: 12),
              Text(
                modifie ? 'Modifications non enregistrées' : 'À jour',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Visible du MJ seulement.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Nom, présentation et paramètres ; suppression de la campagne.
class _OngletParametres extends StatefulWidget {
  const _OngletParametres({required this.contexte, required this.campagne});

  final ContexteCampagnes contexte;
  final Campagne campagne;

  @override
  State<_OngletParametres> createState() => _OngletParametresState();
}

class _OngletParametresState extends State<_OngletParametres> {
  late final _nom = TextEditingController(text: widget.campagne.nom);
  late final _description =
      TextEditingController(text: widget.campagne.description);
  late var _parametres = widget.campagne.parametres;

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final c = widget.campagne;
    if (_parametres.joueursMax < c.joueurs.length) {
      _message(context,
          'Il y a déjà ${c.joueurs.length} joueurs : retire-en d\'abord.');
      return;
    }
    final erreur = await widget.contexte.campagnes.agir((s) => s.modifier(
          c.copie(
            nom: _nom.text,
            description: _description.text,
            parametres: _parametres,
          ),
        ));
    if (mounted) _message(context, erreur ?? 'Paramètres enregistrés.');
  }

  Future<void> _supprimer() async {
    final c = widget.campagne;
    final ok = await _confirmer(
      context,
      'Supprimer « ${c.nom} » ?',
      'Le script, les notes et la liste des joueurs seront perdus. Les '
          'personnages des joueurs ne sont pas touchés.',
      'Supprimer',
    );
    if (!ok || !mounted) return;
    final navigator = Navigator.of(context);
    final erreur = await widget.contexte.campagnes.agir((s) => s.supprimer(c));
    if (!mounted) return;
    if (erreur != null) {
      _message(context, erreur);
    } else {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LargeurLimitee(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('parametres-nom'),
            controller: _nom,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('parametres-description'),
            controller: _description,
            minLines: 2,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Présentation (visible des joueurs)',
            ),
          ),
          const SizedBox(height: 12),
          FormulaireParametres(
            valeur: _parametres,
            onChange: (p) => setState(() => _parametres = p),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              key: const Key('enregistrer-parametres'),
              onPressed: _enregistrer,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Enregistrer'),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('supprimer-campagne'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: _supprimer,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Supprimer la campagne'),
            ),
          ),
        ],
      ),
    );
  }
}
