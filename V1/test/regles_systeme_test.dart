import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/seance.dart';
import 'package:odyssee_vagabonds/widgets/markdown_simple.dart';

/// Règles système (10/11/2026) : écrites pour les novices, avec les parties
/// ajoutées, et des tableaux de dés fidèles aux données du jeu.
List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

void main() {
  final texte = File('assets/data/regles_systeme.md').readAsStringSync();
  final doc = DocumentMarkdown.lire(texte);
  final races = [
    for (final e in _json('races.json'))
      Race.depuisJson(e as Map<String, dynamic>),
  ];
  final classes = [
    for (final e in _json('classes.json'))
      Classe.depuisJson(e as Map<String, dynamic>),
  ];

  /// Lignes d'un tableau dont la première cellule est [nom].
  List<String> ligne(String nom) {
    for (final l in texte.split('\n')) {
      final cellules = l.split('|').map((c) => c.trim()).toList();
      if (cellules.length > 2 && cellules[1] == nom) {
        return cellules.sublist(1, cellules.length - 1);
      }
    }
    fail('Ligne « $nom » absente des règles');
  }

  test('parties pour les novices', () {
    final titres = doc.sections.map((s) => s.titre).toList();
    for (final t in [
      'Le jeu en bref',
      'Vocabulaire et abréviations',
      'Campagne et séance',
      'Créer un personnage',
      'Afflictions',
    ]) {
      expect(titres, contains(t));
    }
    // Les abréviations de la fiche sont expliquées.
    for (final a in ['PJ', 'MJ', 'PV', 'PM', 'PE', 'CA', 'RD', 'PA']) {
      expect(ligne(a), isNotEmpty, reason: a);
    }
    expect(ligne('DV, DM, DE'), isNotEmpty);
  });

  test('dés de vie, de mana et d\'endurance de chaque race', () {
    for (final r in races) {
      final l = ligne(r.nom == 'Elfe-sylvain' ? 'Elfe sylvain' : r.nom);
      expect(
          l.sublist(1, 4), ['d${r.deVie}', 'd${r.deMana}', 'd${r.deEndurance}'],
          reason: r.nom);
    }
  });

  test('esquive réussie : moitié des dégâts par défaut', () {
    expect(
        esquiveDonneMoitie(
            "pas de jet d'attaque ; esquive réussie : moitié des dégâts"),
        isTrue);
    expect(esquiveDonneMoitie("pas de jet d'attaque"), isTrue);
    expect(
        esquiveDonneMoitie("pas de jet d'attaque ; esquive réussie = rien, "
            'sinon dégâts et projeté à 6 m'),
        isFalse);
    expect(texte, contains('### Types de dégâts'));
    expect(texte, contains('par défaut, que **la moitié des dégâts**'));
  });

  test('modificateurs de chaque classe', () {
    String symbole(ModifDe m) => switch (m) {
          ModifDe.plus => '+',
          ModifDe.moins => '−',
          ModifDe.egal => '=',
        };
    for (final c in classes) {
      final l = ligne(c.nom);
      expect(l[2], symbole(c.modifDeVie), reason: '${c.nom} DV');
      expect(
        l[3],
        c.aDuMana ? symbole(c.modifDeMana) : 'pas de mana',
        reason: '${c.nom} DM',
      );
      expect(
        l[4],
        c.aDeLEndurance ? symbole(c.modifDeEndurance) : 'pas d\'endurance',
        reason: '${c.nom} DE',
      );
    }
  });
}
