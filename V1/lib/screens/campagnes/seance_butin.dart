import 'package:flutter/material.dart';

import '../../models/butin.dart';
import '../../models/objet.dart';
import '../../state/seance_controller.dart';
import '../../widgets/consultation.dart';
import '../fiche/choix_objet.dart';

void _erreur(BuildContext context, String? erreur) {
  if (erreur == null || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erreur)));
}

/// Centre : contenu d'un butin. Le MJ le remplit, les PJ s'y servent.
class DetailButin extends StatelessWidget {
  const DetailButin({super.key, required this.seance, required this.butin});

  final SeanceController seance;
  final ButinSeance butin;

  Future<void> _argent(BuildContext context) async {
    final s = seance;
    final b = butin;
    final montant = await showDialog<Bourse>(
      context: context,
      builder: (_) => s.estMj
          ? _DialogueArgent(valeur: b.bourse)
          : _DialoguePrendreArgent(disponible: b.bourse),
    );
    if (montant == null || !context.mounted) return;
    final erreur = await (s.estMj
        ? s.modifierButin(b.copie(bourse: montant))
        : s.prendreDuButin(b, argent: montant));
    if (context.mounted) _erreur(context, erreur);
  }

  /// Plusieurs exemplaires : le joueur choisit combien il en prend.
  Future<void> _prendreObjet(BuildContext context, Objet o) async {
    final quantite = o.quantite == 1
        ? 1
        : await showDialog<int>(
            context: context,
            builder: (_) => _DialogueQuantite(objet: o),
          );
    if (quantite == null || !context.mounted) return;
    final erreur =
        await seance.prendreDuButin(butin, objet: o, quantite: quantite);
    if (context.mounted) _erreur(context, erreur);
  }

  Future<void> _ajouterObjet(BuildContext context) async {
    final o = await ChoixObjet.ouvrir(context, seance.referentiel.equipements);
    if (o == null || !context.mounted) return;
    final erreur =
        await seance.modifierButin(butin.copie(objets: [...butin.objets, o]));
    if (context.mounted) _erreur(context, erreur);
  }

  Future<void> _retirerObjet(BuildContext context, Objet o) async {
    final erreur = await seance.modifierButin(
      butin.copie(objets: [
        for (final x in butin.objets)
          if (x.id != o.id) x,
      ]),
    );
    if (context.mounted) _erreur(context, erreur);
  }

  @override
  Widget build(BuildContext context) {
    final s = seance;
    final b = butin;
    final theme = Theme.of(context);
    return LargeurLimitee(
      child: ListView(
        key: Key('detail-butin-${b.id}'),
        padding: const EdgeInsets.all(16),
        children: [
          Text(b.nom, style: theme.textTheme.headlineSmall),
          if (s.estMj)
            SwitchListTile(
              key: const Key('butin-visible'),
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                b.cache ? Icons.visibility_off_outlined : Icons.visibility,
              ),
              title: const Text('Visible des PJ'),
              subtitle: Text(
                b.cache
                    ? 'Les PJ ne voient pas cette carte.'
                    : 'Les PJ voient la carte et peuvent se servir.',
              ),
              value: !b.cache,
              onChanged: (v) async {
                final erreur = await s.montrerButin(b, visible: v);
                if (context.mounted) _erreur(context, erreur);
              },
            ),
          const SizedBox(height: 12),
          BlocConsultation(
            titre: 'Argent',
            icone: Icons.savings_outlined,
            children: [
              Text(
                b.bourse.vide ? 'Pas d\'argent.' : b.bourse.texte,
                key: const Key('argent-butin'),
              ),
              if (s.estMj || !b.bourse.vide) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    key: const Key('argent-du-butin'),
                    onPressed: () => _argent(context),
                    icon: Icon(s.estMj ? Icons.edit_outlined : Icons.back_hand),
                    label: Text(
                      s.estMj ? 'Modifier l\'argent' : 'Prendre de l\'argent',
                    ),
                  ),
                ),
              ],
            ],
          ),
          BlocConsultation(
            titre: 'Objets',
            icone: Icons.inventory_2_outlined,
            children: [
              if (b.objets.isEmpty) const Text('Aucun objet.'),
              for (final o in b.objets)
                ListTile(
                  key: Key('objet-butin-${o.id}'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${o.quantite > 1 ? '${o.quantite} × ' : ''}${o.nom}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: o.resume.isEmpty ? null : Text(o.resume),
                  trailing: s.estMj
                      ? IconButton(
                          key: Key('retirer-objet-butin-${o.id}'),
                          tooltip: 'Retirer du butin',
                          onPressed: () => _retirerObjet(context, o),
                          icon: const Icon(Icons.delete_outline),
                        )
                      : FilledButton.tonal(
                          key: Key('prendre-objet-${o.id}'),
                          onPressed: () => _prendreObjet(context, o),
                          child: const Text('Prendre'),
                        ),
                ),
              if (s.estMj) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    key: const Key('ajouter-objet-butin'),
                    onPressed: () => _ajouterObjet(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un objet'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Curseur d'une quantité, de [min] à [max], avec sa valeur.
class _Curseur extends StatelessWidget {
  const _Curseur({
    required this.cle,
    required this.libelle,
    required this.valeur,
    required this.min,
    required this.max,
    required this.onChange,
  });

  final String cle;
  final String libelle;
  final int valeur;
  final int min;
  final int max;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(libelle, overflow: TextOverflow.ellipsis)),
            Text('$valeur / $max', key: Key('valeur-$cle')),
          ],
        ),
        Slider(
          key: Key(cle),
          value: valeur.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          label: '$valeur',
          onChanged: (v) => onChange(v.round()),
        ),
      ],
    );
  }
}

/// PJ : combien d'or, d'argent et de cuivre il prend.
class _DialoguePrendreArgent extends StatefulWidget {
  const _DialoguePrendreArgent({required this.disponible});

  final Bourse disponible;

  @override
  State<_DialoguePrendreArgent> createState() => _DialoguePrendreArgentState();
}

class _DialoguePrendreArgentState extends State<_DialoguePrendreArgent> {
  late int _or = widget.disponible.or;
  late int _argent = widget.disponible.argent;
  late int _cuivre = widget.disponible.cuivre;

  @override
  Widget build(BuildContext context) {
    final d = widget.disponible;
    return AlertDialog(
      title: const Text('Prendre de l\'argent'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (d.or > 0)
              _Curseur(
                cle: 'butin-or',
                libelle: 'Or',
                valeur: _or,
                min: 0,
                max: d.or,
                onChange: (v) => setState(() => _or = v),
              ),
            if (d.argent > 0)
              _Curseur(
                cle: 'butin-argent',
                libelle: 'Argent',
                valeur: _argent,
                min: 0,
                max: d.argent,
                onChange: (v) => setState(() => _argent = v),
              ),
            if (d.cuivre > 0)
              _Curseur(
                cle: 'butin-cuivre',
                libelle: 'Cuivre',
                valeur: _cuivre,
                min: 0,
                max: d.cuivre,
                onChange: (v) => setState(() => _cuivre = v),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('valider-argent-butin'),
          onPressed: () => Navigator.pop(
            context,
            Bourse(or: _or, argent: _argent, cuivre: _cuivre),
          ),
          child: const Text('Prendre'),
        ),
      ],
    );
  }
}

/// PJ : combien d'exemplaires d'un objet il prend.
class _DialogueQuantite extends StatefulWidget {
  const _DialogueQuantite({required this.objet});

  final Objet objet;

  @override
  State<_DialogueQuantite> createState() => _DialogueQuantiteState();
}

class _DialogueQuantiteState extends State<_DialogueQuantite> {
  late int _quantite = widget.objet.quantite;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Prendre : ${widget.objet.nom}'),
      content: SizedBox(
        width: 360,
        child: _Curseur(
          cle: 'butin-quantite',
          libelle: 'Quantité',
          valeur: _quantite,
          min: 1,
          max: widget.objet.quantite,
          onChange: (v) => setState(() => _quantite = v),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('valider-quantite-butin'),
          onPressed: () => Navigator.pop(context, _quantite),
          child: const Text('Prendre'),
        ),
      ],
    );
  }
}

/// MJ : montant en or, argent et cuivre du butin, sans limite.
class _DialogueArgent extends StatefulWidget {
  const _DialogueArgent({required this.valeur});

  final Bourse valeur;

  @override
  State<_DialogueArgent> createState() => _DialogueArgentState();
}

class _DialogueArgentState extends State<_DialogueArgent> {
  late final _or = TextEditingController(text: '${widget.valeur.or}');
  late final _argent = TextEditingController(text: '${widget.valeur.argent}');
  late final _cuivre = TextEditingController(text: '${widget.valeur.cuivre}');

  @override
  void dispose() {
    _or.dispose();
    _argent.dispose();
    _cuivre.dispose();
    super.dispose();
  }

  int _lire(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  Widget _champ(String cle, String libelle, TextEditingController c) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          key: Key('butin-$cle'),
          controller: c,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: libelle),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Argent du butin'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _champ('or', 'Or', _or),
          _champ('argent', 'Argent', _argent),
          _champ('cuivre', 'Cuivre', _cuivre),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('valider-argent-butin'),
          onPressed: () => Navigator.pop(
            context,
            Bourse(
              or: _lire(_or),
              argent: _lire(_argent),
              cuivre: _lire(_cuivre),
            ),
          ),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// PJ : envoie un objet non équipé à un autre PJ, discrètement ou non.
class DialogueEnvoiObjet extends StatefulWidget {
  const DialogueEnvoiObjet({
    super.key,
    required this.seance,
    required this.objet,
  });

  final SeanceController seance;
  final Objet objet;

  @override
  State<DialogueEnvoiObjet> createState() => _DialogueEnvoiObjetState();
}

class _DialogueEnvoiObjetState extends State<DialogueEnvoiObjet> {
  late final _joueurs = [
    for (final m in widget.seance.joueurs)
      if (m.uid != widget.seance.uid) m,
  ];
  late String? _cible = _joueurs.isEmpty ? null : _joueurs.first.uid;
  var _quantite = 1;
  var _discret = false;

  Future<void> _envoyer() async {
    final cible = _cible;
    if (cible == null) return;
    final navigator = Navigator.of(context);
    final messager = ScaffoldMessenger.of(context);
    final erreur = await widget.seance.envoyerObjet(
      widget.objet,
      cible,
      quantite: _quantite,
      discret: _discret,
    );
    navigator.pop();
    messager.showSnackBar(
      SnackBar(content: Text(erreur ?? '${widget.objet.nom} : envoyé.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.objet;
    return AlertDialog(
      title: Text('Envoyer : ${o.nom}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            key: const Key('envoi-destinataire'),
            initialValue: _cible,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'À qui ?'),
            items: [
              for (final m in _joueurs)
                DropdownMenuItem(
                  value: m.uid,
                  child: Text(m.personnageNom, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => _cible = v),
          ),
          if (o.quantite > 1)
            Row(
              children: [
                const Expanded(child: Text('Quantité')),
                IconButton(
                  key: const Key('envoi-moins'),
                  onPressed:
                      _quantite > 1 ? () => setState(() => _quantite--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_quantite', key: const Key('envoi-quantite')),
                IconButton(
                  key: const Key('envoi-plus'),
                  onPressed: _quantite < o.quantite
                      ? () => setState(() => _quantite++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          CheckboxListTile(
            key: const Key('envoi-discret'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _discret,
            onChanged: (v) => setState(() => _discret = v ?? false),
            title: const Text('Discrètement'),
            subtitle: const Text('Le destinataire n\'est pas prévenu.'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('valider-envoi'),
          onPressed: _cible == null ? null : _envoyer,
          child: const Text('Envoyer'),
        ),
      ],
    );
  }
}
