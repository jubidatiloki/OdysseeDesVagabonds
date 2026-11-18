import 'package:flutter/material.dart';

import '../../models/bonus_seance.dart';
import '../../models/carac.dart';
import '../../state/seance_controller.dart';

/// Bonus et malus de séance dans le panneau de dés (18/11/2026) : ceux que
/// reçoit le personnage (verrouillés : il ne peut pas les retirer), ceux que
/// ce compte a donnés (retirables), et le bouton pour en donner.
class BlocBonus extends StatelessWidget {
  const BlocBonus({super.key, required this.seance, required this.cible});

  final SeanceController seance;

  /// uid du personnage dont on lance les dés ; `null` : aucun (créature).
  final String? cible;

  @override
  Widget build(BuildContext context) {
    final s = seance;
    final theme = Theme.of(context);
    final c = cible;
    final recus = c == null ? const <BonusSeance>[] : s.bonusRecus(c);
    final donnes = s.bonusRetirables;
    String pour(BonusSeance b) => [
          for (final m in s.joueurs)
            if (b.cibles.contains(m.uid)) m.personnageNom,
        ].join(', ');
    return Column(
      key: const Key('bloc-bonus'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (recus.isNotEmpty) ...[
          Text('Reçus · ajoutés à tes jets', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final b in recus)
                Chip(
                  key: Key('bonus-recu-${b.id}'),
                  avatar: Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: b.valeur >= 0
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  label: Text(
                    '${b.nom} ${b.effet} · ${b.auteurNom} · ${b.dureeTexte}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (donnes.isNotEmpty) ...[
          Text(
            s.estMj ? 'En cours' : 'Donnés',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          for (final b in donnes)
            ListTile(
              key: Key('bonus-donne-${b.id}'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                b.valeur >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                color: b.valeur >= 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
              title:
                  Text('${b.nom} ${b.effet}', overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${pour(b)} · ${b.dureeTexte}'
                '${s.estMj && b.auteur != s.uid ? ' · par ${b.auteurNom}' : ''}',
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                key: Key('retirer-bonus-${b.id}'),
                tooltip: 'Retirer',
                icon: const Icon(Icons.close),
                onPressed: () async {
                  final messager = ScaffoldMessenger.of(context);
                  final erreur = await s.retirerBonus(b);
                  if (erreur != null) {
                    messager.showSnackBar(SnackBar(content: Text(erreur)));
                  }
                },
              ),
            ),
          const SizedBox(height: 6),
        ],
        if (recus.isEmpty && donnes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Une compétence ou un sort qui aide (ou gêne) d\'autres '
              'personnages ? Donne-leur un bonus ou un malus : il s\'ajoute '
              'tout seul à leurs jets.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            key: const Key('donner-bonus'),
            onPressed: s.joueurs.isEmpty
                ? null
                : () => showDialog<void>(
                      context: context,
                      builder: (_) => DialogueBonus(seance: s),
                    ),
            icon: const Icon(Icons.add_reaction_outlined),
            label: const Text('Donner un bonus ou un malus'),
          ),
        ),
      ],
    );
  }
}

/// Donner un bonus ou un malus : nom, valeur, jets visés, personnages,
/// durée (selon la compétence ou le sort).
class DialogueBonus extends StatefulWidget {
  const DialogueBonus({super.key, required this.seance});

  final SeanceController seance;

  @override
  State<DialogueBonus> createState() => _DialogueBonusState();
}

class _DialogueBonusState extends State<DialogueBonus> {
  final _nom = TextEditingController();
  var _valeur = 2;
  var _portee = PorteeBonus.attaque;
  var _carac = Carac.force;
  var _contre = '';
  final Set<String> _cibles = {};
  var _duree = DureeBonus.finCombat;
  var _tours = 3;

  @override
  void initState() {
    super.initState();
    _nom.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nom.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    final navigator = Navigator.of(context);
    final messager = ScaffoldMessenger.of(context);
    final erreur = await widget.seance.poserBonus(
      nom: _nom.text,
      valeur: _valeur,
      portee: _portee,
      carac: _carac,
      cibles: _cibles.toList(),
      contre: _contre,
      duree: _duree,
      tours: _tours,
    );
    navigator.pop();
    messager.showSnackBar(SnackBar(
      content: Text(erreur ?? '${_nom.text.trim()} : donné.'),
    ));
  }

  Widget _compteur(
    String cle,
    int valeur,
    ValueChanged<int> changer, {
    required int min,
    required int max,
    String Function(int)? texte,
  }) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: Key('$cle-moins'),
            onPressed: valeur > min ? () => changer(valeur - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 44,
            child: Text(
              texte?.call(valeur) ?? '$valeur',
              key: Key('$cle-valeur'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            key: Key('$cle-plus'),
            onPressed: valeur < max ? () => changer(valeur + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = widget.seance;
    final pret = _nom.text.trim().isNotEmpty && _cibles.isNotEmpty;
    Widget titre(String t) => Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(t, style: theme.textTheme.labelLarge),
        );
    return AlertDialog(
      key: const Key('fenetre-bonus'),
      title: const Text('Donner un bonus ou un malus'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('bonus-nom'),
                controller: _nom,
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nom (compétence, sort…)',
                  hintText: 'Musique vivifiante',
                ),
              ),
              titre('Valeur (négative : malus)'),
              _compteur(
                'bonus',
                _valeur,
                (v) => setState(
                    () => _valeur = v == 0 ? (v > _valeur ? 1 : -1) : v),
                min: -10,
                max: 10,
                texte: (v) => v > 0 ? '+$v' : '−${-v}',
              ),
              titre('Sur quels jets ?'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final p in PorteeBonus.values)
                    ChoiceChip(
                      key: Key('portee-${p.name}'),
                      label: Text(p.libelle),
                      selected: _portee == p,
                      onSelected: (_) => setState(() => _portee = p),
                    ),
                ],
              ),
              if (_portee == PorteeBonus.ca) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: const Key('bonus-contre'),
                  initialValue: _contre,
                  decoration: const InputDecoration(labelText: 'Quelle CA ?'),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('Toutes')),
                    for (final x in ['CaC', 'DIST', 'MAG'])
                      DropdownMenuItem(
                        value: x,
                        child: Text(BonusSeance.libelleContre(x)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _contre = v ?? ''),
                ),
              ],
              if (_portee == PorteeBonus.carac) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<Carac>(
                  key: const Key('bonus-carac'),
                  initialValue: _carac,
                  decoration:
                      const InputDecoration(labelText: 'Caractéristique'),
                  items: [
                    for (final c in Carac.values)
                      DropdownMenuItem(value: c, child: Text(c.nom)),
                  ],
                  onChanged: (c) => setState(() => _carac = c ?? _carac),
                ),
              ],
              titre('Pour qui ?'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final m in s.joueurs)
                    FilterChip(
                      key: Key('cible-bonus-${m.uid}'),
                      label: Text(m.personnageNom),
                      selected: _cibles.contains(m.uid),
                      onSelected: (oui) => setState(() =>
                          oui ? _cibles.add(m.uid) : _cibles.remove(m.uid)),
                    ),
                ],
              ),
              titre('Jusqu\'à quand ?'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final d in DureeBonus.values)
                    ChoiceChip(
                      key: Key('duree-${d.name}'),
                      label: Text(d.libelle),
                      selected: _duree == d,
                      onSelected: (_) => setState(() => _duree = d),
                    ),
                ],
              ),
              // Durée chiffrée : tours, actions, minutes, heures, jours.
              if (const {
                DureeBonus.tours,
                DureeBonus.actions,
                DureeBonus.minutes,
                DureeBonus.heures,
                DureeBonus.jours,
              }.contains(_duree))
                Row(
                  children: [
                    Text('Nombre de ${_duree.court} :'),
                    _compteur(
                      'bonus-tours',
                      _tours,
                      (v) => setState(() => _tours = v),
                      min: 1,
                      max: 60,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('valider-bonus'),
          onPressed: pret ? _valider : null,
          child: const Text('Donner'),
        ),
      ],
    );
  }
}

/// Cibles d'une compétence ou d'un sort qui donne un bonus : un personnage
/// ([unique]) ou plusieurs. Renvoie leurs uid.
class DialogueCiblesBonus extends StatefulWidget {
  const DialogueCiblesBonus({
    super.key,
    required this.seance,
    required this.titre,
    required this.unique,
  });

  final SeanceController seance;
  final String titre;
  final bool unique;

  @override
  State<DialogueCiblesBonus> createState() => _DialogueCiblesBonusState();
}

class _DialogueCiblesBonusState extends State<DialogueCiblesBonus> {
  final Set<String> _choisis = {};

  @override
  Widget build(BuildContext context) => AlertDialog(
        key: const Key('fenetre-cibles-bonus'),
        title: Text(widget.titre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.unique ? 'Sur qui ?' : 'Sur qui ? (un ou plusieurs)'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final m in widget.seance.joueurs)
                  FilterChip(
                    key: Key('cible-competence-${m.uid}'),
                    label: Text(m.personnageNom),
                    selected: _choisis.contains(m.uid),
                    onSelected: (oui) => setState(() {
                      if (widget.unique) _choisis.clear();
                      oui ? _choisis.add(m.uid) : _choisis.remove(m.uid);
                    }),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('valider-cibles-bonus'),
            onPressed: _choisis.isEmpty
                ? null
                : () => Navigator.pop(context, _choisis.toList()),
            child: const Text('Valider'),
          ),
        ],
      );
}

/// Option d'une compétence qui donne un bonus (bénédiction : « Arme ») ;
/// « Autre choix » : rien d'automatique (à noter à la main). Renvoie
/// l'option choisie, vide pour « autre choix ».
class DialogueOptionBonus extends StatelessWidget {
  const DialogueOptionBonus({
    super.key,
    required this.titre,
    required this.options,
  });

  final String titre;
  final List<String> options;

  @override
  Widget build(BuildContext context) => SimpleDialog(
        key: const Key('fenetre-option-bonus'),
        title: Text(titre),
        children: [
          for (final o in options)
            SimpleDialogOption(
              key: Key('option-bonus-$o'),
              onPressed: () => Navigator.pop(context, o),
              child: Text(o),
            ),
          SimpleDialogOption(
            key: const Key('option-bonus-autre'),
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Autre choix (rien d\'automatique)'),
          ),
        ],
      );
}
