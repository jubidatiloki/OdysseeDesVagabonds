import 'package:flutter/material.dart';

import '../../models/historique.dart';
import '../../models/personnage.dart';

/// Modification du nom, du sexe et de la description d'un personnage.
/// Renvoie `true` si quelque chose a changé (le personnage est alors
/// modifié et le changement inscrit dans l'historique).
class FormulaireIdentite extends StatefulWidget {
  const FormulaireIdentite({super.key, required this.personnage});

  final Personnage personnage;

  static Future<bool> ouvrir(BuildContext context, Personnage p) async {
    final modifie = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FormulaireIdentite(personnage: p),
      ),
    );
    return modifie ?? false;
  }

  @override
  State<FormulaireIdentite> createState() => _FormulaireIdentiteState();
}

class _FormulaireIdentiteState extends State<FormulaireIdentite> {
  late final TextEditingController _nom =
      TextEditingController(text: widget.personnage.nom);
  late final TextEditingController _description =
      TextEditingController(text: widget.personnage.description);
  late Sexe? _sexe = widget.personnage.sexe;

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _valide => _nom.text.trim().isNotEmpty && _sexe != null;

  void _enregistrer() {
    if (!_valide) return;
    final p = widget.personnage;
    final nom = _nom.text.trim();
    final description = _description.text.trim();
    final changements = <String>[
      if (nom != p.nom) 'nom « ${p.nom} » → « $nom »',
      if (_sexe != p.sexe)
        'sexe ${p.sexe?.libelle ?? 'non précisé'} → ${_sexe!.libelle}',
      if (description != p.description) 'description',
    ];
    if (changements.isEmpty) {
      Navigator.of(context).pop(false);
      return;
    }
    p
      ..nom = nom
      ..sexe = _sexe
      ..description = description
      ..journaliser(
        'Identité modifiée : ${changements.join(', ')}',
        categorie: CategorieHistorique.identite,
      );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'identité'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              key: const Key('enregistrer-identite'),
              onPressed: _valide ? _enregistrer : null,
              child: const Text('Enregistrer'),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                key: const Key('champ-nom-identite'),
                controller: _nom,
                maxLength: 40,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nom du personnage',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Text('Sexe', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in Sexe.values)
                    ChoiceChip(
                      key: Key('identite-sexe-${s.name}'),
                      label: Text(s.libelle),
                      selected: s == _sexe,
                      onSelected: (_) => setState(() => _sexe = s),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                key: const Key('champ-description'),
                controller: _description,
                minLines: 4,
                maxLines: 10,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description, histoire',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
