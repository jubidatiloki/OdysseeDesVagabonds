import 'package:flutter/material.dart';

/// Fenêtre de saisie d'un texte court (lieu, nom d'une séance ou d'un butin).
/// Renvoie le texte, ou `null` si on annule.
class DialogueTexte extends StatefulWidget {
  const DialogueTexte({
    super.key,
    required this.titre,
    required this.valeur,
    required this.exemple,
    required this.cleChamp,
    required this.cleValider,
  });

  final String titre;
  final String valeur;
  final String exemple;
  final String cleChamp;
  final String cleValider;

  @override
  State<DialogueTexte> createState() => _DialogueTexteState();
}

class _DialogueTexteState extends State<DialogueTexte> {
  late final _champ = TextEditingController(text: widget.valeur);

  @override
  void dispose() {
    _champ.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titre),
      content: TextField(
        key: Key(widget.cleChamp),
        controller: _champ,
        autofocus: true,
        maxLength: 60,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: widget.exemple),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: Key(widget.cleValider),
          onPressed: () => Navigator.pop(context, _champ.text),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
