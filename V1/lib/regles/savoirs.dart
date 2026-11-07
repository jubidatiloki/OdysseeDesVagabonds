import '../models/aptitude.dart';
import '../models/carac.dart';
import 'des.dart';
import 'fiche_calculee.dart';
import 'inventaire.dart';

/// Un jet de savoir ou de savoir-faire proposé sur la page dé.
class JetSavoir {
  const JetSavoir({
    required this.aptitude,
    required this.libelle,
    required this.carac,
    required this.maitrise,
    this.precision,
    this.bonus = const [],
    this.avantage,
  });

  /// Compétence qui donne l'avantage à ce jet (Survivaliste) ; `null` sinon.
  final String? avantage;

  /// Bonus des compétences pour ce savoir (Éducation du chevalier : +1 par
  /// rang).
  final List<BonusSituation> bonus;

  JetSavoir avecBonus(List<BonusSituation> b, {String? avantage}) => JetSavoir(
        aptitude: aptitude,
        libelle: libelle,
        carac: carac,
        maitrise: maitrise,
        precision: precision,
        bonus: b,
        avantage: avantage,
      );

  /// Total ajouté au jet en plus de la caractéristique.
  int get total => modificateur + bonus.fold(0, (n, b) => n + b.valeur);

  final Aptitude aptitude;

  /// « Faune », « Une race : Elfe », « Domaine : Géologie ».
  final String libelle;
  final Carac carac;

  /// Acquis (acheté ou inné) : +5 ; sinon −5 si complexe, rien si basique.
  final bool maitrise;
  final String? precision;

  /// Bonus de maîtrise (+5) ou malus du complexe non maîtrisé (−5).
  int get modificateur => maitrise ? 5 : (aptitude.complexe ? -5 : 0);

  /// Bonus fixe ajouté au jet, avec son origine.
  List<BonusSituation> get bonusFixes => [
        if (modificateur != 0)
          (nom: maitrise ? 'Maîtrise' : 'Non maîtrisé', valeur: modificateur),
        ...bonus,
      ];

  /// « maîtrisé · +5 », « complexe · −5 sans la maîtrise », « basique ».
  String get mention => [
        maitrise
            ? 'maîtrisé · +5'
            : aptitude.complexe
                ? 'non maîtrisé · −5'
                : 'non maîtrisé',
        for (final b in bonus)
          '${b.valeur >= 0 ? '+' : '−'}${b.valeur.abs()} ${b.nom}',
        if (avantage != null) 'avantage ($avantage)',
      ].join(' · ');
}

/// Jets de la [famille] (savoirs ou savoir-faire) pour la fiche [f] :
/// toutes les entrées du [catalogue] qui ont une caractéristique, les
/// maîtrisées d'abord. Une entrée à précision (« Une race ») donne un jet
/// par précision acquise, plus un jet « non maîtrisé » pour les autres.
/// Savoirs : les « Connaissance d'un domaine » achetées s'y ajoutent (INT).
List<JetSavoir> jetsSavoirs(
  FicheCalculee f,
  List<Aptitude> catalogue,
  FamilleAptitude famille,
) {
  final p = f.personnage;
  final maitrises = <JetSavoir>[];
  final autres = <JetSavoir>[];
  for (final a in catalogue) {
    if (a.famille != famille || a.estSort) continue;
    final carac = Carac.depuisCode(a.carac);
    if (carac == null) continue;
    final acquises = [
      for (final x in p.aptitudes)
        if (x.id == a.id) x,
    ];
    // Innée (sa race, INT) ou offerte par une compétence (équitation).
    final innee = a.estInnee(raceId: p.raceId, intel: f.carac(Carac.intel)) ||
        f.aptitudesOffertes.contains(a.id) ||
        f.savoirsMaitrises.contains(ObjetDuCatalogue.normaliser(a.nom));
    var general = innee;
    for (final x in acquises) {
      final prec = x.precision;
      if (prec == null || prec.isEmpty) {
        general = true;
      } else {
        maitrises.add(JetSavoir(
          aptitude: a,
          libelle: '${a.nom} : $prec',
          carac: carac,
          maitrise: true,
          precision: prec,
        ));
      }
    }
    (general ? maitrises : autres).add(JetSavoir(
      aptitude: a,
      libelle: a.nom,
      carac: carac,
      maitrise: general,
    ));
  }
  if (famille == FamilleAptitude.savoir) {
    for (final a in catalogue) {
      if (a.id != 'connaissance') continue;
      for (final x in p.aptitudes) {
        if (x.id != a.id || (x.precision ?? '').isEmpty) continue;
        maitrises.add(JetSavoir(
          aptitude: a,
          libelle: 'Domaine : ${x.precision}',
          carac: Carac.intel,
          maitrise: true,
          precision: x.precision,
        ));
      }
    }
  }
  // Avantage permanent d'une compétence (Survivaliste : Survie).
  final avantages = {
    for (final a in catalogue)
      if (avantageSavoir(f, a.nom) case final s?) a.id: s,
  };
  // Bonus des compétences pour un savoir nommé (Éducation : +1 par rang).
  String norm(String s) => s.trim().toLowerCase();
  List<BonusSituation> bonusPour(Aptitude a) => [
        for (final s in f.effetsActifs)
          if (s.effet.typeNormalise == 'savoir' &&
              s.effet.si != 'situation' &&
              norm(s.effet.condition) == norm(a.nom) &&
              (s.effet.valeurEntiere ?? 0) != 0)
            (nom: s.nom, valeur: s.effet.valeurEntiere!),
      ];
  return [
    for (final j in [...maitrises, ...autres])
      j.avecBonus(bonusPour(j.aptitude), avantage: avantages[j.aptitude.id]),
  ];
}

/// Compétence qui donne l'avantage aux jets du savoir [nom] (effet
/// `{"type": "savoir", "valeur": "avantage", "condition": "Survie"}`) ;
/// `null` sinon.
String? avantageSavoir(FicheCalculee f, String nom) {
  String norm(String s) => s.trim().toLowerCase();
  for (final s in f.effetsActifs) {
    final e = s.effet;
    if (e.typeNormalise == 'savoir' &&
        e.si != 'situation' &&
        norm(e.valeur) == 'avantage' &&
        norm(e.condition) == norm(nom)) {
      return s.nom;
    }
  }
  return null;
}
