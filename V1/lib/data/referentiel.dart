import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/aptitude.dart';
import '../models/classe.dart';
import '../models/creature.dart';
import '../models/equipement.dart';
import '../models/race.dart';
import '../models/voie.dart';
import '../regles/fiche_calculee.dart';
import '../regles/invocations.dart';

/// Données de référence du jeu (races, classes, équipements, bestiaire,
/// règles), embarquées dans `assets/data/`. Elles changent rarement : pas besoin du cloud.
class Referentiel {
  const Referentiel({
    required this.races,
    required this.classes,
    this.aptitudes = const [],
    this.equipements = const [],
    this.creatures = const [],
    this.reglesSysteme = '',
  });

  final List<Race> races;
  final List<Classe> classes;

  /// Aptitudes et connaissances achetables (1 point).
  final List<Aptitude> aptitudes;

  /// Index des équipements (page Équipements).
  final List<Equipement> equipements;

  /// Bestiaire.
  final List<Creature> creatures;

  /// Texte Markdown des règles du système (page Règles système).
  final String reglesSysteme;

  /// Rend les sorts de rang 0 de [aptitudes] connus des fiches
  /// ([FicheCalculee.sortsRang0]) ; renvoie la liste telle quelle.
  static List<Aptitude> enregistrerSortsRang0(List<Aptitude> aptitudes) {
    FicheCalculee.sortsRang0 = {
      for (final a in aptitudes)
        if (a.sort case final s?) a.id: s,
    };
    // Savoirs (liste « Quelle connaissance ? » de l'Éducation du chevalier).
    FicheCalculee.savoirs = {
      for (final a in aptitudes)
        if (a.famille == FamilleAptitude.savoir) a.id: a.nom,
    };
    return aptitudes;
  }

  /// Sorts de rang 0 (Glossaire, achat à la création).
  List<Aptitude> get sortsRang0 => [
        for (final a in aptitudes)
          if (a.estSort) a,
      ];

  Aptitude? aptitude(String id) {
    for (final a in aptitudes) {
      if (a.id == id) return a;
    }
    return null;
  }

  Race? race(String id) {
    for (final r in races) {
      if (r.id == id) return r;
    }
    return null;
  }

  Classe? classe(String id) {
    for (final c in classes) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Races d'un univers (id, voir `Univers`) : servira au choix de
  /// l'univers à la création ; pour l'instant tout est médiéval fantastique.
  List<Race> racesDe(String univers) =>
      [for (final r in races) if (r.univers == univers) r];

  /// Classes d'un univers (id, voir `Univers`).
  List<Classe> classesDe(String univers) =>
      [for (final c in classes) if (c.univers == univers) c];

  /// Options de choix avec `reference` (« race-humain/1 ») : reprend le nom,
  /// le type, l'effet, les effets et les jets de la compétence visée (sauf
  /// ce qui est déjà renseigné dans l'option).
  static void completerReferences(List<Race> races, List<Classe> classes) {
    // Voies de toutes les classes (« Polyvalence » de l'humain).
    FicheCalculee.voiesDesClasses = [
      for (final c in classes)
        for (final v in c.voies) (voie: v, classe: c.nom),
    ];
    final voies = <String, Voie>{
      for (final r in races)
        if (r.voieRaciale != null) r.voieRaciale!.id: r.voieRaciale!,
      for (final c in classes)
        for (final v in c.voies) v.id: v,
    };
    for (final v in voies.values) {
      for (final c in v.competences) {
        for (final o in c.choix?.options ?? const <OptionChoix>[]) {
          final morceaux = o.reference.split('/');
          if (morceaux.length != 2) continue;
          final cible =
              voies[morceaux[0]]?.competence(int.tryParse(morceaux[1]) ?? 0);
          if (cible == null) continue;
          if (o.nom.isEmpty) o.nom = cible.nom;
          if (o.type.isEmpty) o.type = cible.type;
          if (o.effet.isEmpty) o.effet = cible.effet;
          if (o.effets.isEmpty) o.effets = cible.effets;
          if (o.jets.isEmpty) o.jets = cible.jets;
          // La compétence visée demande un choix à une seule option
          // (Polyglotte : « Quelle langue ? ») : l'option le reprend.
          final sous = cible.choix?.options ?? const <OptionChoix>[];
          if (sous.length == 1 && o.question.isEmpty) {
            final s = sous.single;
            o.question = s.question;
            o.liste = s.liste;
            if (o.objets.isEmpty) o.objets = s.objets;
            o.effets = [...o.effets, ...s.effets];
            if (o.jets.isEmpty) o.jets = s.jets;
          }
        }
      }
    }
  }

  static Future<Referentiel> charger({AssetBundle? bundle}) async {
    final b = bundle ?? rootBundle;
    final racesJson =
        jsonDecode(await b.loadString('assets/data/races.json')) as List;
    final classesJson =
        jsonDecode(await b.loadString('assets/data/classes.json')) as List;
    final aptitudesJson =
        jsonDecode(await b.loadString('assets/data/aptitudes.json')) as List;
    final equipementsJson =
        jsonDecode(await b.loadString('assets/data/equipements.json')) as List;
    final bestiaireJson =
        jsonDecode(await b.loadString('assets/data/bestiaire.json')) as List;
    final regles = await b.loadString('assets/data/regles_systeme.md');
    // Sorts de rang 0 : des aptitudes à 1 point qui donnent un sort.
    final sortsJson =
        jsonDecode(await b.loadString('assets/data/sorts_rang0.json')) as List;
    final races = racesJson
        .map((e) => Race.depuisJson(e as Map<String, dynamic>))
        .toList();
    final classes = classesJson
        .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
        .toList();
    completerReferences(races, classes);
    return Referentiel(
      races: races,
      classes: classes,
      aptitudes: enregistrerSortsRang0([
        for (final e in [...aptitudesJson, ...sortsJson])
          Aptitude.depuisJson(e as Map<String, dynamic>),
      ]),
      equipements: equipementsJson
          .map((e) => Equipement.depuisJson(e as Map<String, dynamic>))
          .toList(),
      creatures: enregistrerCreatures(bestiaireJson
          .map((e) => Creature.depuisJson(e as Map<String, dynamic>))
          .toList()),
      reglesSysteme: regles,
    );
  }
}
