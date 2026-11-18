import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/objet.dart';
import '../../regles/objet_aleatoire.dart';
import '../../state/seance_controller.dart';
import '../fiche/formulaire_objet.dart';

/// MJ : tire un objet du catalogue avec un bonus, le relance ou le modifie,
/// puis le donne à un joueur ou le met dans un butin ([valider]).
class DialogueObjetAleatoire extends StatefulWidget {
  const DialogueObjetAleatoire({
    super.key,
    required this.seance,
    required this.action,
    required this.valider,
    required this.confirmation,
  });

  final SeanceController seance;

  /// Bouton de validation : « Donner à Brom », « Mettre dans le butin ».
  final String action;

  /// Ce qu'on fait de l'objet ; renvoie l'erreur, ou `null`.
  final Future<String?> Function(Objet objet) valider;

  /// Message de réussite : « Épée +1 : donnée à Brom. ».
  final String Function(Objet objet) confirmation;

  @override
  State<DialogueObjetAleatoire> createState() => _DialogueObjetAleatoireState();
}

class _DialogueObjetAleatoireState extends State<DialogueObjetAleatoire> {
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
    final erreur = await widget.valider(o);
    navigator.pop();
    messager.showSnackBar(
      SnackBar(content: Text(erreur ?? widget.confirmation(o))),
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
            child: Text(widget.action),
          ),
        ],
      ],
    );
  }
}
