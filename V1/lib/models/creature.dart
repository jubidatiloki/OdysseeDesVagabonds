import 'carac.dart';
import 'voie.dart';

/// Tailles de créatures (règles §3.5). « Standard » correspond à la taille
/// « moyenne » des règles.
enum TailleCreature {
  minuscule('minuscule', 'Minuscule', 'moins de 30 cm'),
  petite('petite', 'Petite', '30 cm à 1,20 m'),
  standard('standard', 'Standard', '1,20 m à 1,80 m'),
  grande('grande', 'Grande', '1,80 m à 3-4 m'),
  tresGrande('tres-grande', 'Très grande', '3-4 m à 10 m'),
  gigantesque('gigantesque', 'Gigantesque', '10 m à 25 m'),
  titanesque('titanesque', 'Titanesque', 'plus de 25 m');

  const TailleCreature(this.code, this.libelle, this.mesure);

  final String code;
  final String libelle;
  final String mesure;

  static TailleCreature depuisCode(String? code) {
    for (final t in values) {
      if (t.code == code) return t;
    }
    // « moyenne » (vocabulaire des règles) et valeur inconnue → standard.
    return TailleCreature.standard;
  }
}

/// Une attaque de créature (« Morsure : 1d20 +2, 1d6 +1 perçant »).
class AttaqueCreature {
  const AttaqueCreature({
    required this.nom,
    this.toucher = '',
    this.degats = '',
    this.portee = '',
    this.note = '',
  });

  /// Précision (« action gratuite », « pas de jet d'attaque ; esquive
  /// réussie : moitié des dégâts »).
  final String note;

  final String nom;

  /// « CaC » (corps à corps) ou « distance » ; vide si non précisé.
  final String portee;
  final String toucher;
  final String degats;

  factory AttaqueCreature.depuisJson(Map<String, dynamic> j) => AttaqueCreature(
        nom: j['nom'] as String? ?? '',
        toucher: j['toucher'] as String? ?? '',
        degats: j['degats'] as String? ?? '',
        portee: j['portee'] as String? ?? '',
        note: j['note'] as String? ?? '',
      );
}

/// Une créature du bestiaire.
class Creature {
  const Creature({
    required this.id,
    required this.nom,
    required this.famille,
    required this.archetype,
    required this.taille,
    this.description = '',
    this.comportement = '',
    this.caracs = const {},
    this.mods = const {},
    this.initiative,
    this.pv,
    this.ca,
    this.attaques = const [],
    this.voies = const [],
    this.note = '',
  });

  final String id;
  final String nom;

  /// Ex. « Bêtes », « Morts-vivants », « Dragons ».
  final String famille;

  /// Ex. « Standard », « Puissant », « Rapide », « Meute ».
  final String archetype;
  final TailleCreature taille;

  /// Description physique.
  final String description;
  final String comportement;

  /// Valeurs des caractéristiques (vide = statistiques à définir).
  final Map<Carac, int> caracs;

  /// Modificateurs des caractéristiques (« +1 FOR », « −4 INT ») ; les
  /// caractéristiques absentes valent +0.
  final Map<Carac, int> mods;

  /// Initiative (valeur fixe).
  final int? initiative;
  final int? pv;
  final int? ca;
  final List<AttaqueCreature> attaques;

  /// Voies de compétence propres (créatures puissantes, intelligentes ou
  /// anciennes : voie des dragons, voie des créatures volantes…).
  final List<Voie> voies;
  final String note;

  bool get aDesStatistiques =>
      caracs.isNotEmpty ||
      mods.isNotEmpty ||
      pv != null ||
      ca != null ||
      initiative != null ||
      attaques.isNotEmpty;

  String get texteRecherche => [
        nom,
        famille,
        archetype,
        taille.libelle,
        description,
        comportement,
        for (final v in voies) v.nom,
      ].join(' ');

  factory Creature.depuisJson(Map<String, dynamic> j) => Creature(
        id: j['id'] as String,
        nom: j['nom'] as String? ?? '',
        famille: j['famille'] as String? ?? '',
        archetype: j['archetype'] as String? ?? 'Standard',
        taille: TailleCreature.depuisCode(j['taille'] as String?),
        description: j['description'] as String? ?? '',
        comportement: j['comportement'] as String? ?? '',
        caracs: caracMapDepuisJson(j['caracs']),
        mods: caracMapDepuisJson(j['mods']),
        initiative: (j['initiative'] as num?)?.toInt(),
        pv: (j['pv'] as num?)?.toInt(),
        ca: (j['ca'] as num?)?.toInt(),
        attaques: (j['attaques'] as List<dynamic>? ?? const [])
            .map((e) => AttaqueCreature.depuisJson(e as Map<String, dynamic>))
            .toList(),
        voies: (j['voies'] as List<dynamic>? ?? const [])
            .map((e) => Voie.depuisJson(e as Map<String, dynamic>))
            .toList(),
        note: j['note'] as String? ?? '',
      );
}
