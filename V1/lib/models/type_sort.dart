import 'package:flutter/material.dart';

/// Type d'un sort (1 ou 2 par sort ; champ `typesSort` des données :
/// `["offensif", "controle-physique"]`). Validé le 26/10/2026.
enum TypeSort {
  offensif('offensif', 'Offensif', Icons.local_fire_department,
      'Inflige des dégâts ou affaiblit un ennemi'),
  support('support', 'Support', Icons.volunteer_activism,
      'Soigne, protège ou renforce les alliés'),
  transformation('transformation', 'Transformation', Icons.transform,
      'Change la forme ou le corps (de soi ou d\'une cible)'),
  invocation('invocation', 'Invocation', Icons.pets,
      'Fait apparaître une créature, une plante ou un objet'),
  illusion('illusion', 'Illusion', Icons.blur_on,
      'Trompe les sens (images, sons, apparences)'),
  controlePhysique('controle-physique', 'Contrôle physique', Icons.link,
      'Immobilise, repousse, ralentit ou gêne les mouvements'),
  controleMental('controle-mental', 'Contrôle mental', Icons.psychology,
      'Charme, effraie, domine ou manipule l\'esprit'),
  utilitaire('utilitaire', 'Utilitaire', Icons.handyman,
      'Petit effet pratique (lumière, détection, ouverture…)');

  const TypeSort(this.code, this.libelle, this.icone, this.definition);

  final String code;
  final String libelle;
  final IconData icone;
  final String definition;

  /// « controle-physique », « Contrôle physique »… ; `null` si inconnu.
  static TypeSort? depuisCode(String? code) {
    final c = (code ?? '').trim().toLowerCase();
    for (final t in values) {
      if (t.code == c || t.libelle.toLowerCase() == c) return t;
    }
    return null;
  }

  /// Couleur de l'étiquette (thème sombre / clair).
  Color couleur(Brightness b) {
    final sombre = b == Brightness.dark;
    return switch (this) {
      offensif => sombre ? const Color(0xFFE57373) : const Color(0xFFB23B3B),
      support => sombre ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
      transformation =>
        sombre ? const Color(0xFFFFB74D) : const Color(0xFFB26A00),
      invocation => sombre ? const Color(0xFFBA9AE6) : const Color(0xFF6A3FA0),
      illusion => sombre ? const Color(0xFF80DEEA) : const Color(0xFF00838F),
      controlePhysique =>
        sombre ? const Color(0xFFBCAAA4) : const Color(0xFF6D4C41),
      controleMental =>
        sombre ? const Color(0xFFF48FB1) : const Color(0xFFAD1457),
      utilitaire => sombre ? const Color(0xFFB0BEC5) : const Color(0xFF546E7A),
    };
  }
}
