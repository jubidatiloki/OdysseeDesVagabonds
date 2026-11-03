import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/univers.dart';
import 'package:odyssee_vagabonds/models/voie.dart';

/// Notion d'univers (anticipée, sans affichage) : personnage, classe, race,
/// voie et groupe de statistiques appartiennent à un univers ; absent des
/// données → médiéval fantastique.
void main() {
  List<Map<String, dynamic>> lire(String fichier) => [
        for (final e
            in jsonDecode(File('assets/data/$fichier').readAsStringSync())
                as List)
          e as Map<String, dynamic>,
      ];

  test('univers par défaut : médiéval fantastique, toutes les caracs', () {
    expect(kUniversParDefaut, 'medieval-fantastique');
    final u = Univers.parId(null);
    expect(u.nom, 'Médiéval fantastique');
    expect(u.caracs, Carac.values);
    expect(Univers.parId('inconnu'), same(Univers.medievalFantastique));
    expect(universDepuisJson(''), kUniversParDefaut);
    expect(universDepuisJson('space-opera'), 'space-opera');
  });

  test('classes, voies, races et voies raciales : univers par défaut', () {
    final classes = lire('classes.json').map(Classe.depuisJson).toList();
    final races = lire('races.json').map(Race.depuisJson).toList();
    expect(classes, isNotEmpty);
    for (final c in classes) {
      expect(c.univers, kUniversParDefaut, reason: c.id);
      for (final v in c.voies) {
        expect(v.univers, kUniversParDefaut, reason: v.id);
      }
    }
    for (final r in races) {
      expect(r.univers, kUniversParDefaut, reason: r.id);
      expect(r.voieRaciale?.univers ?? kUniversParDefaut, kUniversParDefaut);
    }
    final ref = Referentiel(races: races, classes: classes);
    expect(ref.classesDe(kUniversParDefaut), hasLength(classes.length));
    expect(ref.racesDe(kUniversParDefaut), hasLength(races.length));
    expect(ref.classesDe('space-opera'), isEmpty);
  });

  test('clé « univers » lue dans les données', () {
    final c = Classe.depuisJson(
        {'id': 'pilote', 'nom': 'Pilote', 'univers': 'space-opera'});
    final r = Race.depuisJson({
      'id': 'androide',
      'nom': 'Androïde',
      'deVie': 8,
      'deMana': 4,
      'univers': 'space-opera',
    });
    final v = Voie.depuisJson({'id': 'v', 'univers': 'space-opera'});
    expect([c.univers, r.univers, v.univers], everyElement('space-opera'));
    expect(Referentiel(races: [r], classes: [c]).classesDe('space-opera'),
        [c]);
  });

  test('personnage : univers sauvegardé, anciennes fiches par défaut', () {
    final p = Personnage(
        id: 'p', nom: 'Brom', raceId: 'nain', classeId: 'guerrier');
    expect(p.univers, kUniversParDefaut);
    final json = p.versJson();
    expect(json['schema'], 9);
    expect(json['univers'], kUniversParDefaut);
    expect(Personnage.depuisJson({...json, 'univers': 'space-opera'}).univers,
        'space-opera');
    final ancienne = Map<String, dynamic>.of(json)
      ..remove('univers')
      ..['schema'] = 8;
    expect(Personnage.depuisJson(ancienne).univers, kUniversParDefaut);
  });
}
