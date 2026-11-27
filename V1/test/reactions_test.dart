import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/reactions.dart';

/// Réactions proposées après une attaque ratée (27/11/2026).
void main() {
  final classes = [
    for (final e
        in jsonDecode(File('assets/data/classes.json').readAsStringSync())
            as List)
      Classe.depuisJson(e as Map<String, dynamic>),
  ];
  Competence competence(String nom) => classes
      .expand((c) => c.voies)
      .expand((v) => v.competences)
      .firstWhere((c) => c.nom == nom);

  test('Contre-attaque : au contact, ratée d\'au moins 5', () {
    final contre = [competence('Contre-attaque')];
    expect(reactionsDeclenchees(contre, contact: true, ecart: 5),
        ['Contre-attaque']);
    expect(reactionsDeclenchees(contre, contact: true, ecart: 4), isEmpty);
    expect(reactionsDeclenchees(contre, contact: false, ecart: 8), isEmpty);
    // CA inconnue : l'écart ne peut pas être vérifié.
    expect(reactionsDeclenchees(contre, contact: true), isEmpty);
  });

  test('Vétéran : Contre-attaque sur toute attaque ratée au contact', () {
    final avecVeteran = [
      competence('Contre-attaque'),
      competence('Vétéran des champs de bataille'),
    ];
    expect(reactionsDeclenchees(avecVeteran, contact: true, ecart: 1),
        ['Contre-attaque']);
    expect(
        reactionsDeclenchees(avecVeteran, contact: false, ecart: 9), isEmpty);
    // Seul, le Vétéran ne propose rien.
    expect(
        reactionsDeclenchees([competence('Vétéran des champs de bataille')],
            contact: true, ecart: 9),
        isEmpty);
  });

  test('Riposte : toute attaque ratée au contact', () {
    final riposte = [competence('Riposte')];
    expect(reactionsDeclenchees(riposte, contact: true, ecart: 0), ['Riposte']);
    expect(reactionsDeclenchees(riposte, contact: true), ['Riposte']);
    expect(reactionsDeclenchees(riposte, contact: false, ecart: 6), isEmpty);
  });
}
