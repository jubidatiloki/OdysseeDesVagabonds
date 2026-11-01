import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/progression.dart';

Voie _voie(String id) => Voie(
      id: id,
      nom: 'Voie $id',
      competences: [
        for (var r = 1; r <= 5; r++) Competence(rang: r, nom: '$id $r'),
      ],
    );

void main() {
  const nain = Race(id: 'nain', nom: 'Nain', deVie: 8, deMana: 4);
  const humain = Race(
    id: 'humain',
    nom: 'Humain',
    deVie: 6,
    deMana: 6,
    pointsCompetenceBonus: 1,
  );
  final guerrier = Classe(
    id: 'guerrier',
    nom: 'Guerrier',
    modifDeVie: ModifDe.plus,
    modifDeMana: ModifDe.moins,
    voies: [_voie('a'), _voie('b'), _voie('c'), _voie('d')],
  );

  test('points de compétence par niveau (+1 pour l\'humain)', () {
    expect(Progression.pointsTotaux(1, nain), 3);
    expect(Progression.pointsTotaux(1, humain), 4);
    expect(Progression.pointsTotaux(10, nain), 24);
    expect(Progression.pointsTotaux(10, humain), 25);
  });

  test('coût des rangs : 1/1/2/2/3, voie complète = 9', () {
    expect(Progression.coutCumule(1), 1);
    expect(Progression.coutCumule(3), 4);
    expect(Progression.coutCumule(5), 9);
    expect(Progression.pointsDepenses({'a': 2, 'b': 1}), 3);
  });

  test('les aptitudes coûtent 1 point ; le reste est conservé', () {
    expect(Progression.pointsDepenses({'a': 1}, aptitudes: 2), 3);
    expect(
      Progression.pointsRestants(
        niveau: 1,
        race: nain,
        rangsVoies: const {'a': 1},
        aptitudes: 1,
      ),
      1,
    );
    expect(
      Progression.peutMonter(
        voie: guerrier.voies[1],
        niveau: 1,
        race: nain,
        rangsVoies: const {'a': 1},
        aptitudes: 2,
      ),
      isFalse, // 1 (voie) + 2 (aptitudes) = 3 points dépensés
    );
  });

  test('rang racial offert aux niveaux impairs', () {
    expect(Progression.rangRacial(1), 1);
    expect(Progression.rangRacial(2), 1);
    expect(Progression.rangRacial(3), 2);
    expect(Progression.rangRacial(9), 5);
    expect(Progression.rangRacial(10), 5);
  });

  test('au niveau 1 : rang 1 seulement, dans la limite des points', () {
    final v = guerrier.voies.first;
    expect(
      Progression.peutMonter(
          voie: v, niveau: 1, race: nain, rangsVoies: const {}),
      isTrue,
    );
    expect(
      Progression.peutMonter(
          voie: v, niveau: 1, race: nain, rangsVoies: const {'a': 1}),
      isFalse, // rang 2 > niveau 1
    );
    expect(
      Progression.peutMonter(
        voie: guerrier.voies[3],
        niveau: 1,
        race: nain,
        rangsVoies: const {'a': 1, 'b': 1, 'c': 1},
      ),
      isFalse, // plus de points
    );
    expect(
      Progression.peutMonter(
        voie: guerrier.voies[3],
        niveau: 1,
        race: humain,
        rangsVoies: const {'a': 1, 'b': 1, 'c': 1},
      ),
      isTrue, // l'humain a un point de plus
    );
  });

  test('compétences acquises : voie raciale puis voies de classe', () {
    final race = Race(
      id: 'nain',
      nom: 'Nain',
      deVie: 8,
      deMana: 4,
      voieRaciale: _voie('race'),
    );
    final liste = Progression.competencesAcquises(
      niveau: 1,
      race: race,
      classe: guerrier,
      rangsVoies: const {'b': 1},
    );
    expect(liste.map((e) => e.competence.nom), ['race 1', 'b 1']);
    expect(liste.first.raciale, isTrue);
  });

  test('sexe et rangs de voies survivent à un aller-retour JSON', () {
    final p = Personnage(
      id: 'x',
      nom: 'Lia',
      sexe: Sexe.femme,
      raceId: 'humain',
      classeId: 'voleur',
      rangsVoies: {'voleur-assassin': 1},
      aptitudes: [
        const AptitudeAcquise(id: 'natation'),
        const AptitudeAcquise(id: 'langue', precision: 'Naine'),
      ],
    );
    final copie = Personnage.depuisJson(p.versJson());
    expect(copie.sexe, Sexe.femme);
    expect(copie.rangsVoies, {'voleur-assassin': 1});
    expect(copie.aptitudes, [
      const AptitudeAcquise(id: 'natation'),
      const AptitudeAcquise(id: 'langue', precision: 'Naine'),
    ]);
  });

  test('les données du jeu sont complètes (races.json, classes.json)', () {
    final races =
        (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
            .map((e) => Race.depuisJson(e as Map<String, dynamic>))
            .toList();
    final classes =
        (jsonDecode(File('assets/data/classes.json').readAsStringSync())
                as List)
            .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
            .toList();
    final aptitudes =
        (jsonDecode(File('assets/data/aptitudes.json').readAsStringSync())
                as List)
            .map((e) => Aptitude.depuisJson(e as Map<String, dynamic>))
            .toList();
    expect(aptitudes.map((a) => a.id), contains('natation'));
    expect(races, hasLength(8));
    expect(classes, hasLength(12));
    for (final r in races) {
      expect(r.voieRaciale?.competences, hasLength(5), reason: r.nom);
    }
    final ids = <String>{};
    for (final c in classes) {
      expect(c.voies.length, greaterThanOrEqualTo(4), reason: c.nom);
      for (final v in c.voies) {
        expect(ids.add(v.id), isTrue, reason: 'id en double : ${v.id}');
        expect(v.competences, hasLength(5), reason: v.nom);
      }
    }
  });
}
