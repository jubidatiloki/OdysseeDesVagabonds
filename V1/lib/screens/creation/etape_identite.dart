import 'package:flutter/material.dart';

import '../../models/personnage.dart';

class EtapeIdentite extends StatelessWidget {
  const EtapeIdentite({
    super.key,
    required this.nom,
    required this.notes,
    required this.sexe,
    required this.onSexe,
    required this.onChange,
  });

  final TextEditingController nom;
  final TextEditingController notes;
  final Sexe? sexe;
  final ValueChanged<Sexe> onSexe;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Comment s\'appelle ton vagabond ?',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('champ-nom'),
          controller: nom,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          maxLength: 40,
          decoration: const InputDecoration(
            labelText: 'Nom du personnage',
            hintText: 'Ex. : Brom Barbe-de-Fer',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => onChange(),
        ),
        const SizedBox(height: 8),
        Text('Sexe', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in Sexe.values)
              ChoiceChip(
                key: Key('sexe-${s.name}'),
                label: Text(s.libelle),
                selected: s == sexe,
                onSelected: (_) => onSexe(s),
              ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: notes,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Description, histoire (facultatif)',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => onChange(),
        ),
      ],
    );
  }
}
