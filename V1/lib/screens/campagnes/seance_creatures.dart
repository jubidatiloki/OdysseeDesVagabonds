import 'package:flutter/material.dart';

import '../../models/creature.dart';
import '../../state/seance_controller.dart';
import '../../widgets/consultation.dart';

/// Onglet Créatures (MJ) : le bestiaire, pour ajouter une créature à la
/// partie ; elle s'affiche à gauche, sous les PJ.
class OngletCreatures extends StatefulWidget {
  const OngletCreatures({super.key, required this.seance});

  final SeanceController seance;

  @override
  State<OngletCreatures> createState() => _OngletCreaturesState();
}

class _OngletCreaturesState extends State<OngletCreatures> {
  String _recherche = '';

  Future<void> _ajouter(Creature creature) async {
    final choix = await showDialog<({bool cachee, bool nomCache})>(
      context: context,
      builder: (context) => _DialogueAjout(creature: creature),
    );
    if (choix == null || !mounted) return;
    final messager = ScaffoldMessenger.of(context);
    final erreur = await widget.seance.ajouterCreature(
      creature,
      cachee: choix.cachee,
      nomCache: choix.nomCache,
    );
    messager.showSnackBar(SnackBar(
      content: Text(erreur ?? '${creature.nom} ajoutée à la partie.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final liste = [
      for (final c in widget.seance.referentiel.creatures)
        if (correspond(c.texteRecherche, _recherche)) c,
    ];
    return LargeurLimitee(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ChampRecherche(
            indice: 'Rechercher une créature',
            onChanged: (t) => setState(() => _recherche = t),
          ),
          const SizedBox(height: 12),
          if (liste.isEmpty)
            const Center(child: TexteAVenir('Aucune créature ne correspond.')),
          for (final c in liste)
            Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                title: Text(c.nom, overflow: TextOverflow.ellipsis),
                subtitle: Text([
                  c.famille,
                  if (c.pv != null) '${c.pv} PV',
                  if (c.initiative != null) 'init. ${c.initiative}',
                ].join(' · ')),
                trailing: IconButton(
                  key: Key('ajouter-${c.id}'),
                  tooltip: 'Ajouter à la partie',
                  onPressed: () => _ajouter(c),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ajout d'une créature : cacher sa carte aux PJ, ou juste son nom.
class _DialogueAjout extends StatefulWidget {
  const _DialogueAjout({required this.creature});

  final Creature creature;

  @override
  State<_DialogueAjout> createState() => _DialogueAjoutState();
}

class _DialogueAjoutState extends State<_DialogueAjout> {
  var _cachee = false;
  var _nomCache = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter : ${widget.creature.nom}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            key: const Key('ajout-carte-cachee'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Cacher sa carte aux PJ'),
            value: _cachee,
            onChanged: (v) => setState(() => _cachee = v ?? false),
          ),
          CheckboxListTile(
            key: const Key('ajout-nom-cache'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Cacher seulement son nom'),
            subtitle: const Text('Les PJ voient « Créature inconnue ».'),
            value: _nomCache,
            onChanged:
                _cachee ? null : (v) => setState(() => _nomCache = v ?? false),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('confirmer-ajout'),
          onPressed: () => Navigator.pop(
            context,
            (cachee: _cachee, nomCache: _nomCache && !_cachee),
          ),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
