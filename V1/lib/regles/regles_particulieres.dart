import '../models/carac.dart';
import '../models/classe.dart';
import '../models/personnage.dart';
import '../models/race.dart';
import 'progression.dart';

/// Une règle particulière active, issue d'une compétence, avec son origine.
class RegleParticuliere {
  const RegleParticuliere({
    required this.nom,
    required this.origine,
    required this.description,
  });

  /// Nom de la compétence (« Force de la nature »).
  final String nom;

  /// D'où vient la règle (« Barbare · Voie de la brute, rang 1 »).
  final String origine;

  /// Effet appliqué automatiquement par l'application.
  final String description;

  /// « Force de la nature (Barbare · Voie de la brute, rang 1) »
  String get reference => '$nom ($origine)';
}

/// Compétences qui modifient automatiquement les PV, les dés ou la montée
/// de niveau. Source : `assets/data/classes.json` / `races.json`.
/// Les interprétations sont notées dans AVANCEMENT.md §7.
///
/// Toutes les fonctions sont « pures » : elles ne dépendent que du
/// personnage, de sa race et de sa classe, et ne le modifient pas.
class ReglesParticulieres {
  // --- Identifiants des compétences concernées -----------------------------

  static const String voieBrute = 'barbare-brute';
  static const String voieKi = 'moine-ki';
  static const String raceHautElfe = 'haut-elfe';

  /// Niveau auquel le rang 5 de la voie raciale est offert.
  static const int niveauRangRacial5 = 9;

  static int _rang(Personnage p, String voie) => p.rangsVoies[voie] ?? 0;

  /// Barbare, voie de la brute, rang 1 : « Force de la nature ».
  static bool forceDeLaNature(Personnage p) => _rang(p, voieBrute) >= 1;

  /// Barbare, voie de la brute, rang 3 : « Style barbaresque ».
  static bool styleBarbaresque(Personnage p) => _rang(p, voieBrute) >= 3;

  /// Moine, voie du ki, rang 5 : « Mental d'acier ».
  static bool mentalDAcier(Personnage p) => _rang(p, voieKi) >= 5;

  /// Haut-elfe, voie raciale, rang 5 : « Vitalité elfique ».
  static bool vitaliteElfique(Personnage p, Race race) =>
      race.id == raceHautElfe && Progression.rangRacial(p.niveau) >= 5;

  // --- Effets sur les dés ----------------------------------------------------

  /// Dé de vie de la race, éventuellement modifié (Vitalité elfique : d6).
  static int deVieRace(Personnage p, Race race) =>
      vitaliteElfique(p, race) && race.deVie < 6 ? 6 : race.deVie;

  /// Crans supplémentaires sur le dé de mana (Mental d'acier : +1).
  static int cransDeManaBonus(Personnage p) => mentalDAcier(p) ? 1 : 0;

  // --- Effets sur les PV max ---------------------------------------------------

  /// PV max gagnés à la prise de Vitalité elfique (décision du 23/10/2026,
  /// remplace l'ancien calcul rétroactif).
  static const int pvVitaliteElfique = 10;

  /// Bonus uniques « à la prise » : Force de la nature ajoute la FOR (son
  /// modificateur) aux PV max ; Vitalité elfique ajoute +10 PV max.
  static int bonusPvALaPrise(Personnage p, Race race, int modFor) =>
      (forceDeLaNature(p) ? modFor : 0) +
      (vitaliteElfique(p, race) ? pvVitaliteElfique : 0);

  /// Bonus ajouté au jet de DV lors d'une montée de niveau, d'après les
  /// compétences possédées AVANT ce niveau.
  /// - Style barbaresque : + mod FOR + mod CON ;
  /// - sinon Force de la nature : + CON ou FOR, la meilleure des deux
  ///   (jamais négatif : la compétence est facultative).
  static ({int bonus, RegleParticuliere? regle}) bonusPvMonteeNiveau(
    Personnage p, {
    required int modFor,
    required int modCon,
  }) {
    if (styleBarbaresque(p)) {
      return (
        bonus: modFor + modCon,
        regle: RegleParticuliere(
          nom: 'Style barbaresque',
          origine: 'Barbare · Voie de la brute, rang 3',
          description: 'FOR et CON ajoutés aux PV gagnés par niveau '
              '(${_signe(modFor)} FOR, ${_signe(modCon)} CON).',
        ),
      );
    }
    if (forceDeLaNature(p)) {
      final meilleur = modFor >= modCon ? modFor : modCon;
      final bonus = meilleur < 0 ? 0 : meilleur;
      return (
        bonus: bonus,
        regle: RegleParticuliere(
          nom: 'Force de la nature',
          origine: 'Barbare · Voie de la brute, rang 1',
          description: 'CON ou FOR ajouté aux PV gagnés par niveau '
              '(la meilleure : ${modFor >= modCon ? 'FOR' : 'CON'} '
              '${_signe(bonus)}).',
        ),
      );
    }
    return (bonus: 0, regle: null);
  }

  // --- Liste pour l'affichage ----------------------------------------------

  /// Règles particulières actives, avec leur origine et leur effet chiffré.
  static List<RegleParticuliere> actives({
    required Personnage personnage,
    required Race race,
    required Classe classe,
    required int Function(Carac) mod,
    required int deVieAncien,
    required int deVieNouveau,
    required int deManaAncien,
    required int deManaNouveau,
  }) {
    final p = personnage;
    final res = <RegleParticuliere>[];
    if (forceDeLaNature(p) && !styleBarbaresque(p)) {
      res.add(
        RegleParticuliere(
          nom: 'Force de la nature',
          origine: 'Barbare · Voie de la brute, rang 1',
          description: 'À la prise : ${_signe(mod(Carac.force))} PV max '
              '(FOR). À chaque niveau : + CON ou FOR (la meilleure) aux PV '
              'gagnés.',
        ),
      );
    }
    // Seul le niveau le plus élevé d'une règle est affiché : Style
    // barbaresque reprend ce qui reste de Force de la nature (PV à la prise).
    if (styleBarbaresque(p)) {
      res.add(
        RegleParticuliere(
          nom: 'Style barbaresque',
          origine: 'Barbare · Voie de la brute, rang 3',
          description: 'À chaque niveau : + FOR et + CON aux PV gagnés '
              '(${_signe(mod(Carac.force) + mod(Carac.con))}) — remplace '
              'le bonus de Force de la nature. Toujours acquis de Force de '
              'la nature : ${_signe(mod(Carac.force))} PV max à la prise '
              '(FOR).',
        ),
      );
    }
    if (vitaliteElfique(p, race)) {
      res.add(
        RegleParticuliere(
          nom: 'Vitalité elfique',
          origine: 'Haut-elfe · Voie raciale, rang 5',
          description: 'À la prise : +$pvVitaliteElfique PV max. Dé de vie '
              'd$deVieAncien → d$deVieNouveau pour les jets suivants '
              '(niveau 9 compris, repos).',
        ),
      );
    }
    if (mentalDAcier(p)) {
      res.add(
        RegleParticuliere(
          nom: 'Mental d\'acier',
          origine: 'Moine · Voie du ki, rang 5',
          description: 'Dé de mana d$deManaAncien → d$deManaNouveau '
              '(PM max du niveau 1 recalculés).',
        ),
      );
    }
    return res;
  }

  static String _signe(int v) => v < 0 ? '−${-v}' : '+$v';
}
