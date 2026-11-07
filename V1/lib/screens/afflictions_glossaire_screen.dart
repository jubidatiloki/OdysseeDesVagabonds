import 'package:flutter/material.dart';

import '../models/affliction.dart';
import '../widgets/carte_selection.dart';
import '../widgets/consultation.dart';

/// Glossaire : afflictions et types de dégâts (règles §3.2 et §3.4).
class AfflictionsGlossaireScreen extends StatelessWidget {
  const AfflictionsGlossaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LargeurLimitee(
      child: ListView(
        key: const Key('glossaire-afflictions'),
        padding: const EdgeInsets.all(16),
        children: [
          BlocConsultation(
            titre: 'Afflictions',
            icone: Icons.healing_outlined,
            children: [
              for (final a in kAfflictions)
                LigneDetail(libelle: a.nom, texte: a.effet),
            ],
          ),
          BlocConsultation(
            titre: 'Types de dégâts',
            icone: Icons.local_fire_department_outlined,
            children: [
              for (final e in kEffetsDegats)
                LigneDetail(libelle: e.nom, texte: e.effet),
              const SizedBox(height: 8),
              const Text(
                'Une arme personnalisée peut recevoir un de ces types et une '
                'affliction : Inventaire, puis ajouter ou modifier un objet.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
