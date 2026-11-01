import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/historique.dart';
import '../../models/personnage.dart';

/// Notes libres du personnage, sauvegardées automatiquement
/// (une demi-seconde après la dernière frappe).
class OngletNotes extends StatefulWidget {
  const OngletNotes({
    super.key,
    required this.personnage,
    required this.onModifie,
  });

  final Personnage personnage;
  final Future<void> Function() onModifie;

  @override
  State<OngletNotes> createState() => _OngletNotesState();
}

class _OngletNotesState extends State<OngletNotes> {
  late final TextEditingController _controleur =
      TextEditingController(text: widget.personnage.notes);
  Timer? _minuterie;

  void _surModification(String texte) {
    widget.personnage.notes = texte;
    _minuterie?.cancel();
    _minuterie = Timer(const Duration(milliseconds: 500), _enregistrer);
  }

  Future<void> _enregistrer() {
    // Une seule ligne « Notes modifiées » par minute d'écriture.
    widget.personnage.journaliser(
      'Notes modifiées',
      categorie: CategorieHistorique.notes,
      fusion: 'notes',
    );
    return widget.onModifie();
  }

  @override
  void dispose() {
    if (_minuterie?.isActive ?? false) {
      _minuterie!.cancel();
      // Sauvegarde après la fin de la construction en cours.
      scheduleMicrotask(_enregistrer);
    }
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        key: const Key('champ-notes'),
        controller: _controleur,
        expands: true,
        maxLines: null,
        minLines: null,
        textAlignVertical: TextAlignVertical.top,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Histoire, objectifs, alliés, rencontres, dettes…',
          border: OutlineInputBorder(),
        ),
        onChanged: _surModification,
      ),
    );
  }
}
