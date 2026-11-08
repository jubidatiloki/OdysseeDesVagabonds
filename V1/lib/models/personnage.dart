import 'dart:math';

import 'aptitude.dart';
import 'carac.dart';
import 'historique.dart';
import 'objet.dart';
import 'univers.dart';

enum Sexe {
  homme('Homme'),
  femme('Femme'),
  autre('Autre');

  const Sexe(this.libelle);
  final String libelle;

  static Sexe? depuisCode(String? code) {
    for (final s in values) {
      if (s.name == code) return s;
    }
    return null;
  }
}

/// Un personnage joueur. Ne stocke que ce que le joueur choisit ou lance ;
/// tout ce qui se calcule (dés finaux, modificateurs, PV max, esquive…) est
/// dans `regles/fiche_calculee.dart`.
class Personnage {
  Personnage({
    required this.id,
    required this.nom,
    this.sexe,
    required this.raceId,
    this.origineId,
    this.optionPassifId,
    required this.classeId,
    this.univers = kUniversParDefaut,
    this.niveau = 1,
    Map<Carac, int>? caracBase,
    List<int>? jetsDeVie,
    List<int>? jetsDeMana,
    List<int>? jetsDEndurance,
    List<int>? bonusDeVie,
    Map<String, int>? rangsVoies,
    Map<String, int>? emprunts,
    List<AptitudeAcquise>? aptitudes,
    List<Objet>? inventaire,
    Bourse? bourse,
    List<EvenementHistorique>? historique,
    this.pvActuels,
    this.pmActuels,
    this.peActuels,
    this.jetsMontee,
    Map<String, String>? choix,
    Set<String>? etats,
    Set<String>? favoris,
    Map<String, int>? utilisations,
    Set<String>? objetsRecus,
    Map<String, String>? precisionsChoix,
    this.description = '',
    this.notes = '',
    DateTime? creeLe,
    DateTime? modifieLe,
  })  : caracBase = caracBase ??
            {for (final c in Carac.values) c: kValeurCaracParDefaut},
        jetsDeVie = jetsDeVie ?? [],
        jetsDeMana = jetsDeMana ?? [],
        jetsDEndurance = jetsDEndurance ?? [],
        bonusDeVie = bonusDeVie ?? [],
        rangsVoies = rangsVoies ?? {},
        emprunts = emprunts ?? {},
        aptitudes = aptitudes ?? [],
        inventaire = inventaire ?? [],
        bourse = bourse ?? Bourse(),
        historique = historique ?? [],
        choix = choix ?? {},
        etats = etats ?? {},
        favoris = favoris ?? {},
        utilisations = utilisations ?? {},
        objetsRecus = objetsRecus ?? {},
        precisionsChoix = precisionsChoix ?? {},
        creeLe = creeLe ?? DateTime.now(),
        modifieLe = modifieLe ?? DateTime.now();

  /// Version du format de sauvegarde (pour migrer les anciennes données).
  static const int versionSchema = 10;

  final String id;
  String nom;
  Sexe? sexe;
  String raceId;

  /// Origine choisie (demi-elfe, humain), sinon `null`.
  String? origineId;

  /// Option de passif racial choisie à la création (draconien : `souffle`
  /// ou `ailes`), sinon `null`.
  String? optionPassifId;

  String classeId;

  /// Univers du personnage (id, voir `Univers`) : fixé à la création,
  /// comme sa race et sa classe. Schéma 9 ; avant : univers par défaut.
  final String univers;
  int niveau;

  /// Valeurs après répartition des points de création, AVANT les
  /// modificateurs de race et d'origine (appliqués à la fin).
  Map<Carac, int> caracBase;

  /// Jets de dé de vie obtenus aux montées de niveau (niveau 2, 3…).
  /// Le niveau 1 utilise le DV maximum : il n'y a pas de jet.
  List<int> jetsDeVie;

  /// Jets de dé de mana obtenus aux montées de niveau (niveau 2, 3…).
  List<int> jetsDeMana;

  /// Jets de dé d'endurance obtenus aux montées de niveau (niveau 2, 3…) :
  /// classes physiques et hybrides (schéma 10).
  List<int> jetsDEndurance;

  /// Bonus de PV ajoutés à chaque montée de niveau par des règles
  /// particulières (Force de la nature, Style barbaresque…), dans le même
  /// ordre que [jetsDeVie].
  List<int> bonusDeVie;

  /// Rang atteint dans chaque voie de classe (id de voie → rang 1 à 5).
  /// La voie raciale n'y figure pas : ses rangs dépendent du niveau.
  Map<String, int> rangsVoies;

  /// Rangs offerts dans les voies d'autres classes (humain, « Polyvalence ») :
  /// id de voie → rang atteint (1 ou 2), sans coût en points.
  Map<String, int> emprunts;

  /// Aptitudes et connaissances achetées (1 point chacune).
  List<AptitudeAcquise> aptitudes;

  /// Objets portés ou transportés.
  List<Objet> inventaire;

  /// Pièces d'or, d'argent et de cuivre.
  Bourse bourse;

  /// Journal des modifications, du plus ancien au plus récent.
  List<EvenementHistorique> historique;

  /// Nombre maximum de lignes gardées (les plus anciennes sont effacées).
  static const int tailleMaxHistorique = 1000;

  /// Nombre maximum de lancers de dés gardés (les plus anciens sont
  /// effacés ; les autres lignes ne sont pas touchées).
  static const int maxLancersHistorique = 100;

  /// Délai pendant lequel des actions identiques sont regroupées.
  static const Duration delaiFusion = Duration(minutes: 1);

  /// Ajoute une ligne à l'historique. Si [fusion] est donné et que la
  /// dernière ligne a la même clé et date de moins de [delaiFusion], elle est
  /// remplacée (message et date mis à jour) au lieu d'en ajouter une.
  void journaliser(
    String message, {
    CategorieHistorique categorie = CategorieHistorique.autre,
    String? fusion,
    DateTime? maintenant,
  }) {
    final date = maintenant ?? DateTime.now();
    if (fusion != null && historique.isNotEmpty) {
      final dernier = historique.last;
      if (dernier.fusion == fusion &&
          date.difference(dernier.date) < delaiFusion) {
        historique.removeLast();
      }
    }
    _ajouter(
      EvenementHistorique(
        date: date,
        categorie: categorie,
        message: message,
        fusion: fusion,
      ),
    );
  }

  /// Journalise le changement d'une valeur (PV, PM, pièces…) :
  /// « PV : 13 → 10 (−3) ». Avec [regrouper], des changements rapprochés
  /// (clics successifs sur −1 / +1) donnent une seule ligne, depuis la
  /// valeur de départ ; si on revient à la valeur de départ, la ligne
  /// disparaît.
  void journaliserValeur({
    required String cle,
    required String libelle,
    required int avant,
    required int apres,
    required CategorieHistorique categorie,
    bool regrouper = false,
    DateTime? maintenant,
    String commentaire = '',
  }) {
    final date = maintenant ?? DateTime.now();
    final note = commentaire.trim();
    var depart = avant;
    if (regrouper && historique.isNotEmpty) {
      final dernier = historique.last;
      if (dernier.fusion == cle &&
          dernier.avant != null &&
          date.difference(dernier.date) < delaiFusion) {
        depart = dernier.avant!;
        historique.removeLast();
      }
    }
    if (depart == apres) return;
    _ajouter(
      EvenementHistorique(
        date: date,
        categorie: categorie,
        // Commentaire (« morsure de loup », « boule de feu ») après le calcul.
        message: '$libelle : $depart → $apres (${avecSigne(apres - depart)})'
            '${note.isEmpty ? '' : ' — $note'}',
        fusion: regrouper ? cle : null,
        avant: regrouper ? depart : null,
      ),
    );
  }

  void _ajouter(EvenementHistorique e) {
    historique.add(e);
    if (e.categorie == CategorieHistorique.des) {
      var lancers = historique
          .where((x) => x.categorie == CategorieHistorique.des)
          .length;
      for (var i = 0;
          lancers > maxLancersHistorique && i < historique.length;) {
        if (historique[i].categorie == CategorieHistorique.des) {
          historique.removeAt(i);
          lancers--;
        } else {
          i++;
        }
      }
    }
    final surplus = historique.length - tailleMaxHistorique;
    if (surplus > 0) historique.removeRange(0, surplus);
  }

  /// `null` = au maximum.
  int? pvActuels;
  int? pmActuels;

  /// Points d'endurance actuels (`null` = au maximum).
  int? peActuels;

  /// Jets de vie / mana déjà lancés pour une montée de niveau pas encore
  /// validée : réutilisés si on la recommence (pas de relance possible).
  JetsMontee? jetsMontee;

  /// Choix faits pour les compétences et passifs (clé du choix → option) :
  /// `{"element-draconien": "feu", "sang-mele": "humain"}`.
  Map<String, String> choix;

  /// États actifs (noms) donnés par une compétence : « Apparence
  /// monstrueuse » (Visage impensable).
  Set<String> etats;

  /// Compétences et sorts favoris (noms) : en tête pendant une séance.
  Set<String> favoris;

  /// Utilisations déjà faites des capacités limitées (« Faire jouer son
  /// titre » : RANG fois par aventure) : clé → nombre.
  Map<String, int> utilisations;

  /// Objets déjà donnés par une compétence (clés « voie/rang/nom ») :
  /// jamais redonnés, même s'ils sont perdus ou détruits.
  Set<String> objetsRecus;

  /// Précision saisie pour un choix (clé du choix → « Luth », « Épée »).
  Map<String, String> precisionsChoix;

  /// Description, histoire (saisie à la création, modifiable).
  String description;

  /// Notes de jeu libres (onglet Notes).
  String notes;
  final DateTime creeLe;
  DateTime modifieLe;

  static String nouvelId() {
    final t = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final r = Random().nextInt(1000000000).toRadixString(36);
    return '$t-$r';
  }

  Map<String, dynamic> versJson() => {
        'schema': versionSchema,
        'id': id,
        'nom': nom,
        'sexe': sexe?.name,
        'raceId': raceId,
        'origineId': origineId,
        'optionPassifId': optionPassifId,
        'classeId': classeId,
        'univers': univers,
        'niveau': niveau,
        'caracBase': caracMapVersJson(caracBase),
        'jetsDeVie': jetsDeVie,
        'jetsDeMana': jetsDeMana,
        if (jetsDEndurance.isNotEmpty) 'jetsDEndurance': jetsDEndurance,
        'bonusDeVie': bonusDeVie,
        'rangsVoies': rangsVoies,
        if (emprunts.isNotEmpty) 'emprunts': emprunts,
        'aptitudes': [for (final a in aptitudes) a.versJson()],
        'inventaire': [for (final o in inventaire) o.versJson()],
        'bourse': bourse.versJson(),
        'historique': [for (final e in historique) e.versJson()],
        'pvActuels': pvActuels,
        'pmActuels': pmActuels,
        if (peActuels != null) 'peActuels': peActuels,
        if (jetsMontee != null) 'jetsMontee': jetsMontee!.versJson(),
        if (choix.isNotEmpty) 'choix': choix,
        if (etats.isNotEmpty) 'etats': etats.toList(),
        if (favoris.isNotEmpty) 'favoris': favoris.toList(),
        if (utilisations.isNotEmpty) 'utilisations': utilisations,
        if (objetsRecus.isNotEmpty) 'objetsRecus': objetsRecus.toList(),
        if (precisionsChoix.isNotEmpty) 'precisionsChoix': precisionsChoix,
        'description': description,
        'notes': notes,
        'creeLe': creeLe.toIso8601String(),
        'modifieLe': modifieLe.toIso8601String(),
      };

  factory Personnage.depuisJson(Map<String, dynamic> j) {
    final base = caracMapDepuisJson(j['caracBase']);
    for (final c in Carac.values) {
      base.putIfAbsent(c, () => kValeurCaracParDefaut);
    }
    return Personnage(
      id: j['id'] as String,
      nom: j['nom'] as String? ?? 'Sans nom',
      sexe: Sexe.depuisCode(j['sexe'] as String?),
      raceId: j['raceId'] as String,
      origineId: j['origineId'] as String?,
      optionPassifId: j['optionPassifId'] as String?,
      classeId: j['classeId'] as String,
      univers: universDepuisJson(j['univers']),
      niveau: (j['niveau'] as num?)?.toInt() ?? 1,
      caracBase: base,
      jetsDeVie: (j['jetsDeVie'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      jetsDeMana: (j['jetsDeMana'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      jetsDEndurance: (j['jetsDEndurance'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      bonusDeVie: (j['bonusDeVie'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      rangsVoies: {
        for (final e
            in (j['rangsVoies'] as Map<String, dynamic>? ?? const {}).entries)
          e.key: (e.value as num).toInt(),
      },
      emprunts: {
        for (final e
            in (j['emprunts'] as Map<String, dynamic>? ?? const {}).entries)
          e.key: (e.value as num).toInt(),
      },
      aptitudes: (j['aptitudes'] as List<dynamic>? ?? const [])
          .map((e) => AptitudeAcquise.depuisJson(e as Map<String, dynamic>))
          .toList(),
      inventaire: (j['inventaire'] as List<dynamic>? ?? const [])
          .map((e) => Objet.depuisJson(e as Map<String, dynamic>))
          .toList(),
      bourse: Bourse.depuisJson(j['bourse']),
      historique: (j['historique'] as List<dynamic>? ?? const [])
          .map((e) => EvenementHistorique.depuisJson(e as Map<String, dynamic>))
          .toList(),
      pvActuels: (j['pvActuels'] as num?)?.toInt(),
      jetsMontee: JetsMontee.depuisJson(j['jetsMontee']),
      choix: {
        for (final e
            in (j['choix'] as Map<String, dynamic>? ?? const {}).entries)
          e.key: '${e.value}',
      },
      etats: {
        for (final e in j['etats'] as List<dynamic>? ?? const []) '$e',
      },
      favoris: {
        for (final e in j['favoris'] as List<dynamic>? ?? const []) '$e',
      },
      utilisations: {
        for (final e
            in (j['utilisations'] as Map<String, dynamic>? ?? const {}).entries)
          if (e.value is num) e.key: (e.value as num).toInt(),
      },
      objetsRecus: {
        for (final e in j['objetsRecus'] as List<dynamic>? ?? const []) '$e',
      },
      precisionsChoix: {
        for (final e
            in (j['precisionsChoix'] as Map<String, dynamic>? ?? const {})
                .entries)
          e.key: '${e.value}',
      },
      pmActuels: (j['pmActuels'] as num?)?.toInt(),
      peActuels: (j['peActuels'] as num?)?.toInt(),
      description: j['description'] as String? ?? '',
      notes: j['notes'] as String? ?? '',
      creeLe: DateTime.tryParse(j['creeLe'] as String? ?? ''),
      modifieLe: DateTime.tryParse(j['modifieLe'] as String? ?? ''),
    );
  }
}

/// Jets d'une montée de niveau en cours (niveau visé, dé de vie, dé de mana, dé
/// d'endurance).
class JetsMontee {
  JetsMontee({required this.niveau, this.vie, this.mana, this.endurance});

  /// Niveau visé par ces jets.
  final int niveau;
  int? vie;
  int? mana;
  int? endurance;

  Map<String, dynamic> versJson() => {
        'niveau': niveau,
        if (vie != null) 'vie': vie,
        if (mana != null) 'mana': mana,
        if (endurance != null) 'endurance': endurance,
      };

  static JetsMontee? depuisJson(Object? j) {
    if (j is! Map || j['niveau'] is! num) return null;
    return JetsMontee(
      niveau: (j['niveau'] as num).toInt(),
      vie: (j['vie'] as num?)?.toInt(),
      mana: (j['mana'] as num?)?.toInt(),
      endurance: (j['endurance'] as num?)?.toInt(),
    );
  }
}
