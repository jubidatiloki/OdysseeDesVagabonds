import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/effet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';

/// Renforcements qui changent le nombre de cibles d'une autre compétence
/// (19/11/2026) : Rechargement rapide, Martyr, Irrésistible.

List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

final _classes = [
  for (final e in _json('classes.json'))
    Classe.depuisJson(e as Map<String, dynamic>),
];
final _humain = [
  for (final e in _json('races.json'))
    Race.depuisJson(e as Map<String, dynamic>),
].firstWhere((r) => r.id == 'humain');

Competence _competence(String classeId, String voie, int rang, String nom) {
  final f = FicheCalculee(
    personnage: Personnage(
      id: 'p',
      nom: 'Test',
      raceId: 'humain',
      classeId: classeId,
      niveau: 9,
      rangsVoies: {voie: rang},
      caracBase: {for (final c in Carac.values) c: 12},
    ),
    race: _humain,
    classe: _classes.firstWhere((c) => c.id == classeId),
  );
  return f.competencesAcquises
      .firstWhere((c) => c.competence.nom == nom)
      .competence;
}

void main() {
  Referentiel.completerReferences([_humain], _classes);

  test('effet de renforcement : nombre de cibles lu et sauvegardé', () {
    final e = Effet.depuisJson(
        {'type': 'renforcement', 'nom': 'Tenir en joue', 'ciblesMax': 3});
    expect(e.ciblesMax, '3');
    expect(e.versJson()['ciblesMax'], '3');
    expect(e.avecValeur('1').ciblesMax, '3');
  });

  test('sans le renforcement : une seule cible', () {
    final c = _competence('ingenieur', 'ingenieur-tireur', 3, 'Tenir en joue');
    expect((c.cible, c.ciblesMax), (CibleCompetence.unique, ''));
  });

  test('avec le renforcement : sélection, au plus N cibles', () {
    final tenir =
        _competence('ingenieur', 'ingenieur-tireur', 4, 'Tenir en joue');
    expect((tenir.cible, tenir.ciblesMax), (CibleCompetence.selection, '3'));
    final benediction =
        _competence('pretre', 'pretre-paladin', 5, 'Bénédiction');
    expect((benediction.cible, benediction.ciblesMax),
        (CibleCompetence.selection, '2'));
    // Le reste de la compétence est gardé (options arme / armure).
    expect(benediction.optionsBonus, isNotEmpty);
    final distraction =
        _competence('voleur', 'voleur-seducteur', 5, 'Distraction charnelle');
    expect((distraction.cible, distraction.ciblesMax),
        (CibleCompetence.selection, '2'));
    // La compétence qui porte le renforcement n'est pas touchée.
    expect(
        _competence('voleur', 'voleur-seducteur', 5, 'Irrésistible').ciblesMax,
        '');
  });
}
