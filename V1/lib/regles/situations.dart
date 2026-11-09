import '../models/carac.dart';
import 'des.dart';
import 'fiche_calculee.dart';
import 'savoirs.dart';

/// Repère d'une situation à cocher (bonus de tests des traits : « +1 en
/// forêt »…), partagé par la page dé et la séance.
String cleSituation(SourceEffet s) => '${s.nom}|${s.effet.libelle}';

/// Bonus et avantage des situations pour un jet : les bonus sans condition
/// toujours, les autres seulement s'ils sont dans [cochees]. Un bonus sans
/// caractéristique vaut pour **tous** les jets du personnage ; un bonus lié à
/// une caractéristique, seulement pour les tests de celle-ci ([caracTest]).
({List<BonusSituation> bonus, List<String> avantage}) effetsSituations(
  FicheCalculee fiche,
  Set<String> cochees,
  Carac? caracTest, {
  bool initiative = false,
  String? savoir,
}) {
  final bonus = <BonusSituation>[];
  final avantage = <String>[];
  for (final s in fiche.bonusTests) {
    // Sans condition : toujours appliqué ; sinon, seulement si coché.
    final permanent = s.effet.condition.isEmpty;
    if (!permanent && !cochees.contains(cleSituation(s))) continue;
    final e = s.effet;
    if (e.carac != null && e.carac != caracTest) continue;
    // « INIT » : seulement le jet d'initiative (Vie sylvestre).
    if (e.carac == null && (e.categorieNormalisee == 'init') != initiative) {
      continue;
    }
    if (e.typeNormalise == 'avantage' || e.valeur.toLowerCase() == 'avantage') {
      avantage.add(s.nom);
    } else if ((e.valeurEntiere ?? 0) != 0) {
      bonus.add((nom: s.nom, valeur: e.valeurEntiere!));
    }
  }
  // Bonus cochés pour un savoir précis (« +5 Discrétion en nature ») ;
  // avantage permanent (Survivaliste : Survie).
  if (savoir != null) {
    if (avantageSavoir(fiche, savoir) case final s?) avantage.add(s);
    String n(String t) => t.trim().toLowerCase();
    for (final s in fiche.situationsHorsTests) {
      final e = s.effet;
      if (e.typeNormalise != 'savoir' ||
          !cochees.contains(cleSituation(s)) ||
          !e.categorie.split(',').any((c) => n(c) == n(savoir)) ||
          (e.valeurEntiere ?? 0) == 0) {
        continue;
      }
      bonus.add((nom: s.nom, valeur: e.valeurEntiere!));
    }
  }
  return (bonus: bonus, avantage: avantage);
}

/// Caractéristiques avec un avantage permanent (passif du gnome : CHAN), et
/// le trait qui le donne.
Map<Carac, String> avantagesPermanents(FicheCalculee f) => {
      for (final s in f.bonusTestsPermanents)
        if (s.effet.carac != null &&
            (s.effet.typeNormalise == 'avantage' ||
                s.effet.valeur.toLowerCase() == 'avantage'))
          s.effet.carac!: s.nom,
    };
