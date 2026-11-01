import '../models/classe.dart';
import '../models/race.dart';
import '../models/voie.dart';

/// Règles de progression des compétences.
/// Source : ressources/01_REGLES_GENERALES.md §5 et AVANCEMENT.md §7.
class Progression {
  /// Points de compétence gagnés à chaque niveau (index 0 = niveau 1).
  static const List<int> pointsParNiveau = [3, 2, 2, 2, 3, 2, 2, 2, 2, 4];

  /// Coût de chaque rang d'une voie (index 0 = rang 1).
  static const List<int> coutParRang = [1, 1, 2, 2, 3];

  /// Coût d'une aptitude ou connaissance (natation, langue…).
  static const int coutAptitude = 1;

  static const int rangMax = 5;
  static const int niveauMax = 10;

  /// Total des points de compétence reçus jusqu'au niveau donné inclus
  /// (+ bonus de race, ex. « Richesse culturelle » de l'humain).
  static int pointsTotaux(int niveau, Race race) {
    var total = race.pointsCompetenceBonus;
    for (var n = 1; n <= niveau && n <= pointsParNiveau.length; n++) {
      total += pointsParNiveau[n - 1];
    }
    return total;
  }

  /// Coût d'un rang donné (1 à 5).
  static int coutRang(int rang) => coutParRang[rang - 1];

  /// Coût cumulé pour atteindre un rang dans une voie (rang 5 = 9 points).
  static int coutCumule(int rang) {
    var total = 0;
    for (var r = 1; r <= rang && r <= rangMax; r++) {
      total += coutRang(r);
    }
    return total;
  }

  /// Points dépensés dans les voies de classe et les aptitudes.
  /// Les points non dépensés sont conservés pour les niveaux suivants.
  static int pointsDepenses(Map<String, int> rangsVoies, {int aptitudes = 0}) {
    var total = aptitudes * coutAptitude;
    for (final rang in rangsVoies.values) {
      total += coutCumule(rang);
    }
    return total;
  }

  static int pointsRestants({
    required int niveau,
    required Race race,
    required Map<String, int> rangsVoies,
    int aptitudes = 0,
  }) =>
      pointsTotaux(niveau, race) -
      pointsDepenses(rangsVoies, aptitudes: aptitudes);

  /// Rang de la voie raciale, offert aux niveaux impairs :
  /// niveau 1 → rang 1, niveau 3 → rang 2… niveau 9 → rang 5.
  static int rangRacial(int niveau) {
    final rang = (niveau + 1) ~/ 2;
    return rang > rangMax ? rangMax : rang;
  }

  /// Peut-on prendre le rang suivant de cette voie ?
  /// Règles : rangs pris dans l'ordre, rang ≤ niveau, assez de points.
  static bool peutMonter({
    required Voie voie,
    required int niveau,
    required Race race,
    required Map<String, int> rangsVoies,
    int aptitudes = 0,
  }) {
    final suivant = (rangsVoies[voie.id] ?? 0) + 1;
    if (suivant > rangMax || suivant > niveau) return false;
    if (voie.competence(suivant) == null) return false;
    return coutRang(suivant) <=
        pointsRestants(
          niveau: niveau,
          race: race,
          rangsVoies: rangsVoies,
          aptitudes: aptitudes,
        );
  }

  /// Compétences acquises : voie raciale (selon le niveau) puis voies de
  /// classe (selon les rangs achetés), dans l'ordre des voies.
  static List<({Voie voie, Competence competence, bool raciale})>
      competencesAcquises({
    required int niveau,
    required Race race,
    required Classe classe,
    required Map<String, int> rangsVoies,
  }) {
    final res = <({Voie voie, Competence competence, bool raciale})>[];
    final vr = race.voieRaciale;
    if (vr != null) {
      for (var r = 1; r <= rangRacial(niveau); r++) {
        final c = vr.competence(r);
        if (c != null) res.add((voie: vr, competence: c, raciale: true));
      }
    }
    for (final v in classe.voies) {
      final rang = rangsVoies[v.id] ?? 0;
      for (var r = 1; r <= rang; r++) {
        final c = v.competence(r);
        if (c != null) res.add((voie: v, competence: c, raciale: false));
      }
    }
    return res;
  }
}
