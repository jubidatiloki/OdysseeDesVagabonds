import '../models/creature.dart';
import '../models/voie.dart';
import 'fiche_calculee.dart';

/// Bestiaire par id (rempli au chargement des données) : fiches des
/// invocations et des compagnons.
Map<String, Creature> catalogueCreatures = {};

/// Rend les fiches de [creatures] connues des compétences ; renvoie la
/// liste telle quelle.
List<Creature> enregistrerCreatures(List<Creature> creatures) {
  catalogueCreatures = {for (final c in creatures) c.id: c};
  return creatures;
}

/// Fiches du bestiaire liées à une compétence (`invocations`) : toutes, ou
/// seulement celles de l'option choisie quand [choix] est donné
/// (`siChoix` : « animal-druide:loup »).
List<Creature> invocationsDeCompetence(
  Competence c, {
  Map<String, Creature>? catalogue,
  Map<String, String>? choix,
}) =>
    [
      for (final id in c.invocations)
        if ((catalogue ?? catalogueCreatures)[id] case final x?)
          if (choix == null || _choixRespecte(x, choix)) x,
    ];

bool _choixRespecte(Creature c, Map<String, String> choix) {
  if (c.siChoix.isEmpty) return true;
  final i = c.siChoix.indexOf(':');
  if (i < 0) return true;
  final cle = c.siChoix.substring(0, i);
  final option = c.siChoix.substring(i + 1);
  // Choix multiple : options séparées par des virgules.
  return (choix[cle] ?? '').split(',').map((s) => s.trim()).contains(option);
}

/// Invocations et compagnons du personnage, d'après ses compétences
/// acquises et ses choix ; un stade plus avancé remplace le précédent
/// (animal de combat au rang 3 à la place de l'animal de compagnie).
List<({Creature creature, String competence})> invocationsDe(
  FicheCalculee f, [
  Map<String, Creature>? catalogue,
]) {
  final res = <({Creature creature, String competence})>[];
  for (final c in f.competencesAcquises) {
    for (final x in invocationsDeCompetence(c.competence,
        catalogue: catalogue, choix: f.personnage.choix)) {
      if (!res.any((r) => r.creature.id == x.id)) {
        res.add((creature: x, competence: c.competence.nom));
      }
    }
  }
  final remplacees = {for (final r in res) r.creature.remplace};
  return [
    for (final r in res)
      if (!remplacees.contains(r.creature.id)) r,
  ];
}
