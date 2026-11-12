import 'package:flutter/material.dart';

import '../../models/creature.dart';
import '../../state/seance_controller.dart';
import '../bestiaire_screen.dart';

/// Onglet Créatures (MJ), au centre : le bestiaire du Glossaire, avec tout le
/// détail ; une créature ajoutée s'affiche à gauche, sous les PJ.
class OngletCreatures extends StatelessWidget {
  const OngletCreatures({super.key, required this.seance});

  final SeanceController seance;

  Future<void> _ajouter(BuildContext context, Creature creature) async {
    final messager = ScaffoldMessenger.of(context);
    final choix = await showDialog<({bool cachee, bool nomCache, bool allie})>(
      context: context,
      builder: (context) => _DialogueAjout(creature: creature),
    );
    if (choix == null) return;
    final erreur = await seance.ajouterCreature(
      creature,
      cachee: choix.cachee,
      nomCache: choix.nomCache,
      allie: choix.allie,
    );
    messager.showSnackBar(SnackBar(
      content: Text(erreur ??
          '${creature.nom} ajoutée à la partie'
              '${choix.allie ? ' (alliée des PJ)' : ''}.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BestiaireScreen(
      referentiel: seance.referentiel,
      dansSeance: true,
      action: (c) => Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          key: Key('ajouter-${c.id}'),
          onPressed: () => _ajouter(context, c),
          icon: const Icon(Icons.add),
          label: const Text('Ajouter à la partie'),
        ),
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
  var _allie = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter : ${widget.creature.nom}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Allié des PJ (escorte d'un marchand…), contrôlé par le MJ.
          CheckboxListTile(
            key: const Key('ajout-allie'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Allié des PJ'),
            subtitle: const Text('Avec les personnages ; c\'est toi qui le '
                'contrôles.'),
            value: _allie,
            onChanged: (v) => setState(() => _allie = v ?? false),
          ),
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
            (
              cachee: _cachee,
              nomCache: _nomCache && !_cachee,
              allie: _allie,
            ),
          ),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
