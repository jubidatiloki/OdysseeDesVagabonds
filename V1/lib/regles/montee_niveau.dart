import '../models/aptitude.dart';
import '../models/carac.dart';
import '../models/classe.dart';
import '../models/equipement.dart';
import '../models/historique.dart';
import '../models/personnage.dart';
import '../models/race.dart';
import 'fiche_calculee.dart';
import 'inventaire.dart';
import 'progression.dart';
import 'regles_particulieres.dart';

/// Ce qu'a donné une montée de niveau (pour l'affichage et les tests).
class ResultatMonteeNiveau {
  const ResultatMonteeNiveau({
    required this.niveauAvant,
    required this.niveauApres,
    required this.pvMaxAvant,
    required this.pvMaxApres,
    required this.pmMaxAvant,
    required this.pmMaxApres,
    required this.pointsGagnes,
    this.bonusRegle = 0,
    this.regle,
    this.nouvellesRegles = const [],
  });

  final int niveauAvant;
  final int niveauApres;
  final int pvMaxAvant;
  final int pvMaxApres;
  final int pmMaxAvant;
  final int pmMaxApres;
  final int pointsGagnes;

  /// Bonus ajouté au jet de DV par une règle particulière, et laquelle.
  final int bonusRegle;
  final RegleParticuliere? regle;

  /// Règles particulières devenues actives à ce niveau.
  final List<RegleParticuliere> nouvellesRegles;
}

/// Règles de montée de niveau (AVANCEMENT.md §7) :
/// - +1 niveau (max 10) ;
/// - PV max + 1 jet de DV (sans CON), PM max + 1 jet de DM ;
/// - les PV / PM actuels augmentent du même gain (5/10 PV, +3 → 8/13) ;
/// - points de compétence du nouveau niveau ; rang de voie raciale offert
///   aux niveaux impairs ;
/// - nouvelles compétences / aptitudes choisies (les anciennes sont gardées).
class MonteeNiveau {
  static bool possible(Personnage p) => p.niveau < Progression.niveauMax;

  /// Points de compétence reçus en passant au niveau [nouveauNiveau].
  static int pointsGagnes(int nouveauNiveau) =>
      nouveauNiveau >= 1 && nouveauNiveau <= Progression.pointsParNiveau.length
          ? Progression.pointsParNiveau[nouveauNiveau - 1]
          : 0;

  /// Applique la montée de niveau au personnage et l'inscrit dans son
  /// historique.
  static ResultatMonteeNiveau appliquer({
    required Personnage personnage,
    required Race race,
    required Classe classe,
    required int jetDeVie,
    required int jetDeMana,
    required Map<String, int> rangsVoies,
    required List<AptitudeAcquise> aptitudes,
    List<Aptitude> catalogueAptitudes = const [],
    int? facesDeVie,
    int? facesDeMana,
    Map<String, String> choix = const {},
    List<Equipement> catalogueEquipements = const [],
    DateTime? maintenant,
  }) {
    final p = personnage;
    final avant = FicheCalculee(personnage: p, race: race, classe: classe);
    final niveauAvant = p.niveau;
    final pvMaxAvant = avant.pvMax;
    final pmMaxAvant = avant.pmMax;
    final rangsAvant = Map<String, int>.of(p.rangsVoies);
    final aptitudesAvant = List<AptitudeAcquise>.of(p.aptitudes);
    final reglesAvant = {
      for (final r in avant.reglesParticulieres) r.reference
    };
    // Bonus de PV par niveau, d'après les compétences AVANT ce niveau.
    final bonus = bonusPvMonteeNiveau(avant);
    while (p.bonusDeVie.length < p.jetsDeVie.length) {
      p.bonusDeVie.add(0);
    }

    p
      ..niveau = niveauAvant + 1
      ..jetsDeVie.add(jetDeVie)
      ..jetsDeMana.add(jetDeMana)
      ..bonusDeVie.add(bonus.bonus)
      ..rangsVoies = Map.of(rangsVoies)
      ..aptitudes = List.of(aptitudes)
      // Montée validée : les jets en attente sont consommés.
      ..jetsMontee = null
      // Choix des nouvelles compétences (avant le calcul : « +2 INT »…).
      ..choix.addAll(choix);

    final apres = FicheCalculee(personnage: p, race: race, classe: classe);
    final gainPv = apres.pvMax - pvMaxAvant;
    final gainPm = apres.pmMax - pmMaxAvant;
    // `null` = au maximum : reste au maximum. Sinon on ajoute le gain.
    if (p.pvActuels != null) {
      final pv = p.pvActuels! + gainPv;
      p.pvActuels = pv > apres.pvMax ? apres.pvMax : pv;
    }
    if (p.pmActuels != null) {
      final pm = p.pmActuels! + gainPm;
      p.pmActuels = pm > apres.pmMax ? apres.pmMax : pm;
    }

    final points = pointsGagnes(p.niveau);
    final nouvellesRegles = [
      for (final r in apres.reglesParticulieres)
        if (!reglesAvant.contains(r.reference)) r,
    ];
    // Détail du gain de PV : jet + règle par niveau + effets « à la prise »
    // ou rétroactifs des nouvelles règles.
    final detailPv = <String>[
      'd${facesDeVie ?? apres.deVie} = $jetDeVie',
      if (bonus.regle != null && bonus.bonus != 0)
        '${avecSigne(bonus.bonus)} ${bonus.regle!.reference}',
    ];
    final autres = gainPv - jetDeVie - bonus.bonus;
    if (autres != 0) {
      detailPv.add(
        '${avecSigne(autres)} '
        '${nouvellesRegles.isEmpty ? 'règles particulières' : nouvellesRegles.map((r) => r.nom).join(', ')}',
      );
    }
    p.journaliser(
      'Niveau $niveauAvant → ${p.niveau} : '
      'PV max $pvMaxAvant → ${apres.pvMax} '
      '(${avecSigne(gainPv)} : ${detailPv.join(' ; ')}), '
      'PM max $pmMaxAvant → ${apres.pmMax} '
      '(${avecSigne(gainPm)} : d${facesDeMana ?? apres.deMana} = $jetDeMana), '
      '+$points point${points > 1 ? 's' : ''} de compétence',
      categorie: CategorieHistorique.niveau,
      maintenant: maintenant,
    );
    for (final r in nouvellesRegles) {
      p.journaliser(
        'Règle particulière active : ${r.reference} — ${r.description}',
        categorie: CategorieHistorique.niveau,
        maintenant: maintenant,
      );
    }

    // Rang de voie raciale offert (niveaux impairs)
    final vr = race.voieRaciale;
    final rangRacialAvant = Progression.rangRacial(niveauAvant);
    final rangRacialApres = Progression.rangRacial(p.niveau);
    if (vr != null) {
      for (var r = rangRacialAvant + 1; r <= rangRacialApres; r++) {
        final c = vr.competence(r);
        if (c == null) continue;
        p.journaliser(
          'Compétence raciale : ${c.nom} (${vr.nom}, rang $r)',
          categorie: CategorieHistorique.competences,
          maintenant: maintenant,
        );
      }
    }

    _journaliserAcquisitions(
      p,
      classe: classe,
      rangsAvant: rangsAvant,
      aptitudesAvant: aptitudesAvant,
      catalogueAptitudes: catalogueAptitudes,
      maintenant: maintenant,
    );
    journaliserChoix(p, apres, choix, maintenant: maintenant);
    // Objets donnés par les nouvelles compétences (sacoche du gnome…).
    ObjetsDonnes.recevoir(
      apres,
      catalogue: catalogueEquipements,
      maintenant: maintenant,
    );

    return ResultatMonteeNiveau(
      niveauAvant: niveauAvant,
      niveauApres: p.niveau,
      pvMaxAvant: pvMaxAvant,
      pvMaxApres: apres.pvMax,
      pmMaxAvant: pmMaxAvant,
      pmMaxApres: apres.pmMax,
      pointsGagnes: points,
      bonusRegle: bonus.bonus,
      regle: bonus.regle,
      nouvellesRegles: nouvellesRegles,
    );
  }

  /// Bonus de PV de la montée de niveau donné par les règles particulières
  /// (Force de la nature, Style barbaresque), d'après la fiche actuelle.
  static ({int bonus, RegleParticuliere? regle}) bonusPvMonteeNiveau(
    FicheCalculee fiche,
  ) =>
      ReglesParticulieres.bonusPvMonteeNiveau(
        fiche.personnage,
        modFor: fiche.mod(Carac.force),
        modCon: fiche.mod(Carac.con),
      );

  /// Dépense des points de compétence restants, en dehors d'une montée de
  /// niveau (rangs ≤ niveau actuel, compétences déjà acquises gardées).
  /// Inscrit les nouvelles compétences, aptitudes et règles particulières
  /// dans l'historique.
  static void depenserPoints({
    required Personnage personnage,
    required Race race,
    required Classe classe,
    required Map<String, int> rangsVoies,
    required List<AptitudeAcquise> aptitudes,
    List<Aptitude> catalogueAptitudes = const [],
    List<Equipement> catalogueEquipements = const [],
    DateTime? maintenant,
  }) {
    final p = personnage;
    final reglesAvant = {
      for (final r in FicheCalculee(personnage: p, race: race, classe: classe)
          .reglesParticulieres)
        r.reference,
    };
    final rangsAvant = Map<String, int>.of(p.rangsVoies);
    final aptitudesAvant = List<AptitudeAcquise>.of(p.aptitudes);
    p
      ..rangsVoies = Map.of(rangsVoies)
      ..aptitudes = List.of(aptitudes);
    _journaliserAcquisitions(
      p,
      classe: classe,
      rangsAvant: rangsAvant,
      aptitudesAvant: aptitudesAvant,
      catalogueAptitudes: catalogueAptitudes,
      maintenant: maintenant,
    );
    for (final r in FicheCalculee(personnage: p, race: race, classe: classe)
        .reglesParticulieres) {
      if (reglesAvant.contains(r.reference)) continue;
      p.journaliser(
        'Règle particulière active : ${r.reference} — ${r.description}',
        categorie: CategorieHistorique.competences,
        maintenant: maintenant,
      );
    }
    ObjetsDonnes.recevoir(
      FicheCalculee(personnage: p, race: race, classe: classe),
      catalogue: catalogueEquipements,
      maintenant: maintenant,
    );
  }

  /// « Choix · Élément : Feu » pour chaque choix fait.
  static void journaliserChoix(
    Personnage p,
    FicheCalculee fiche,
    Map<String, String> choix, {
    DateTime? maintenant,
  }) {
    final connus = fiche.choixConnus;
    for (final e in choix.entries) {
      final c = connus[e.key];
      final option = c?.option(e.value);
      final precision = p.precisionsChoix[e.key] ?? '';
      // Choix multiple : « FOR, DEX, CON… ».
      final multiple = c != null && c.nombre > 1
          ? c.choisies(e.value).map((o) => o.nom).join(', ')
          : null;
      p.journaliser(
        'Choix · ${c == null || c.titre.isEmpty ? e.key : c.titre} : '
        '${multiple ?? (option == null || option.nom.isEmpty ? e.value : option.nom)}'
        '${precision.isEmpty ? '' : ' ($precision)'}',
        categorie: CategorieHistorique.competences,
        maintenant: maintenant,
      );
    }
  }

  /// Une ligne d'historique par nouveau rang de voie de classe et par
  /// nouvelle aptitude.
  static void _journaliserAcquisitions(
    Personnage p, {
    required Classe classe,
    required Map<String, int> rangsAvant,
    required List<AptitudeAcquise> aptitudesAvant,
    required List<Aptitude> catalogueAptitudes,
    DateTime? maintenant,
  }) {
    for (final v in classe.voies) {
      final de = rangsAvant[v.id] ?? 0;
      final a = p.rangsVoies[v.id] ?? 0;
      for (var r = de + 1; r <= a; r++) {
        final c = v.competence(r);
        if (c == null) continue;
        p.journaliser(
          'Compétence acquise : ${c.nom} (${v.nom}, rang $r)',
          categorie: CategorieHistorique.competences,
          maintenant: maintenant,
        );
      }
    }
    final restantes = List<AptitudeAcquise>.of(aptitudesAvant);
    for (final a in p.aptitudes) {
      if (restantes.remove(a)) continue;
      var nom = a.id;
      for (final x in catalogueAptitudes) {
        if (x.id == a.id) nom = x.nom;
      }
      p.journaliser(
        'Aptitude acquise : $nom'
        '${a.precision == null ? '' : ' (${a.precision})'}',
        categorie: CategorieHistorique.competences,
        maintenant: maintenant,
      );
    }
  }

  /// Dés à lancer pour passer au niveau suivant : ceux du nouveau niveau
  /// (ex. Vitalité elfique, obtenue au niveau 9, s'applique au jet du
  /// niveau 9).
  static ({int deVie, int deMana}) desDuNiveauSuivant(FicheCalculee fiche) {
    final copie = Personnage.depuisJson(fiche.personnage.versJson())
      ..niveau = fiche.personnage.niveau + 1;
    final f = FicheCalculee(
      personnage: copie,
      race: fiche.race,
      classe: fiche.classe,
    );
    return (deVie: f.deVie, deMana: f.deMana);
  }
}
