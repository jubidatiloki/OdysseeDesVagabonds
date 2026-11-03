import 'dart:math';

/// Campagnes (03/11/2026) : parties à plusieurs menées par un maître du jeu
/// (MJ). Le MJ crée la campagne (nom, script, notes, paramètres) et invite
/// les joueurs avec un code ; chaque joueur demande à la rejoindre avec un
/// de ses personnages, le MJ accepte ou refuse. Le MJ démarre les séances.

/// Paramètres d'une campagne, choisis par le MJ.
class ParametresCampagne {
  const ParametresCampagne({
    this.joueursMax = 5,
    this.niveauDepart = 1,
    this.fichesVisiblesMj = true,
    this.fichesVisiblesJoueurs = false,
    this.pjInventaireHorsSeance = true,
    this.pjCompetencesHorsSeance = true,
    this.pjVoientRessources = false,
    this.pjVoientPvCreatures = false,
    this.pjVoientFichesCreatures = false,
  });

  /// Nombre maximum de joueurs (1 à 8), MJ non compris.
  final int joueursMax;

  /// Niveau de départ conseillé des personnages (1 à 10).
  final int niveauDepart;

  /// Le MJ peut consulter la fiche du personnage de chaque joueur.
  final bool fichesVisiblesMj;

  /// Les joueurs voient aussi les fiches des autres membres.
  final bool fichesVisiblesJoueurs;

  /// Les PJ peuvent modifier leur inventaire en dehors d'une séance.
  final bool pjInventaireHorsSeance;

  /// Les PJ peuvent modifier leurs compétences en dehors d'une séance
  /// (dépenser leurs points, monter de niveau).
  final bool pjCompetencesHorsSeance;

  /// Les PJ voient les PV, PM et PE des autres PJ.
  final bool pjVoientRessources;

  /// Les PJ voient les PV des créatures.
  final bool pjVoientPvCreatures;

  /// Les PJ voient les fiches des créatures (sauf nom caché).
  final bool pjVoientFichesCreatures;

  static const int joueursMaxLimite = 8;

  ParametresCampagne copie({
    int? joueursMax,
    int? niveauDepart,
    bool? fichesVisiblesMj,
    bool? fichesVisiblesJoueurs,
    bool? pjInventaireHorsSeance,
    bool? pjCompetencesHorsSeance,
    bool? pjVoientRessources,
    bool? pjVoientPvCreatures,
    bool? pjVoientFichesCreatures,
  }) =>
      ParametresCampagne(
        joueursMax: joueursMax ?? this.joueursMax,
        niveauDepart: niveauDepart ?? this.niveauDepart,
        fichesVisiblesMj: fichesVisiblesMj ?? this.fichesVisiblesMj,
        fichesVisiblesJoueurs:
            fichesVisiblesJoueurs ?? this.fichesVisiblesJoueurs,
        pjInventaireHorsSeance:
            pjInventaireHorsSeance ?? this.pjInventaireHorsSeance,
        pjCompetencesHorsSeance:
            pjCompetencesHorsSeance ?? this.pjCompetencesHorsSeance,
        pjVoientRessources: pjVoientRessources ?? this.pjVoientRessources,
        pjVoientPvCreatures: pjVoientPvCreatures ?? this.pjVoientPvCreatures,
        pjVoientFichesCreatures:
            pjVoientFichesCreatures ?? this.pjVoientFichesCreatures,
      );

  Map<String, dynamic> versJson() => {
        'joueursMax': joueursMax,
        'niveauDepart': niveauDepart,
        'fichesVisiblesMj': fichesVisiblesMj,
        'fichesVisiblesJoueurs': fichesVisiblesJoueurs,
        'pjInventaireHorsSeance': pjInventaireHorsSeance,
        'pjCompetencesHorsSeance': pjCompetencesHorsSeance,
        'pjVoientRessources': pjVoientRessources,
        'pjVoientPvCreatures': pjVoientPvCreatures,
        'pjVoientFichesCreatures': pjVoientFichesCreatures,
      };

  factory ParametresCampagne.depuisJson(Object? j) {
    if (j is! Map) return const ParametresCampagne();
    return ParametresCampagne(
      joueursMax:
          ((j['joueursMax'] as num?)?.toInt() ?? 5).clamp(1, joueursMaxLimite),
      niveauDepart: ((j['niveauDepart'] as num?)?.toInt() ?? 1).clamp(1, 10),
      fichesVisiblesMj: j['fichesVisiblesMj'] as bool? ?? true,
      fichesVisiblesJoueurs: j['fichesVisiblesJoueurs'] as bool? ?? false,
      pjInventaireHorsSeance: j['pjInventaireHorsSeance'] as bool? ?? true,
      pjCompetencesHorsSeance: j['pjCompetencesHorsSeance'] as bool? ?? true,
      pjVoientRessources: j['pjVoientRessources'] as bool? ?? false,
      pjVoientPvCreatures: j['pjVoientPvCreatures'] as bool? ?? false,
      pjVoientFichesCreatures: j['pjVoientFichesCreatures'] as bool? ?? false,
    );
  }
}

/// Séance de jeu : numéro, début ; en cours tant que le MJ ne l'a pas
/// terminée.
class Seance {
  const Seance(
      {required this.numero, required this.debut, this.enCours = true});

  final int numero;
  final DateTime debut;
  final bool enCours;

  Map<String, dynamic> versJson() => {
        'numero': numero,
        'debut': debut.toIso8601String(),
        'enCours': enCours,
      };

  static Seance? depuisJson(Object? j) {
    if (j is! Map || j['numero'] is! num) return null;
    return Seance(
      numero: (j['numero'] as num).toInt(),
      debut: DateTime.tryParse('${j['debut']}') ?? DateTime(2026),
      enCours: j['enCours'] as bool? ?? false,
    );
  }
}

/// Une campagne. Le script et les notes du MJ sont à part
/// ([PriveCampagne]) : les joueurs ne les voient pas.
class Campagne {
  const Campagne({
    required this.id,
    required this.nom,
    required this.mj,
    this.mjNom = '',
    this.description = '',
    this.code = '',
    this.joueurs = const [],
    this.demandes = const [],
    this.parametres = const ParametresCampagne(),
    this.seance,
    required this.creeLe,
    required this.modifieLe,
  });

  final String id;
  final String nom;

  /// uid du maître du jeu.
  final String mj;

  /// Nom affiché du MJ (pour les joueurs).
  final String mjNom;

  /// Présentation visible des joueurs (accroche, ambiance).
  final String description;

  /// Code d'invitation en cours (« LOUP-4827 »).
  final String code;

  /// uids des joueurs acceptés.
  final List<String> joueurs;

  /// uids des joueurs qui ont demandé à rejoindre (en attente du MJ).
  final List<String> demandes;
  final ParametresCampagne parametres;

  /// Dernière séance (en cours ou terminée), `null` : jamais jouée.
  final Seance? seance;
  final DateTime creeLe;
  final DateTime modifieLe;

  bool get seanceEnCours => seance?.enCours ?? false;
  bool get complete => joueurs.length >= parametres.joueursMax;
  bool estMj(String uid) => mj == uid;

  Campagne copie({
    String? nom,
    String? description,
    String? code,
    List<String>? joueurs,
    List<String>? demandes,
    ParametresCampagne? parametres,
    Seance? seance,
    DateTime? modifieLe,
  }) =>
      Campagne(
        id: id,
        nom: nom ?? this.nom,
        mj: mj,
        mjNom: mjNom,
        description: description ?? this.description,
        code: code ?? this.code,
        joueurs: joueurs ?? this.joueurs,
        demandes: demandes ?? this.demandes,
        parametres: parametres ?? this.parametres,
        seance: seance ?? this.seance,
        creeLe: creeLe,
        modifieLe: modifieLe ?? this.modifieLe,
      );

  Map<String, dynamic> versJson() => {
        'nom': nom,
        'mj': mj,
        'mjNom': mjNom,
        'description': description,
        'code': code,
        'joueurs': joueurs,
        'demandes': demandes,
        'joueursMax': parametres.joueursMax,
        'parametres': parametres.versJson(),
        if (seance != null) 'seance': seance!.versJson(),
        'creeLe': creeLe.toIso8601String(),
        'modifieLe': modifieLe.toIso8601String(),
      };

  factory Campagne.depuisJson(String id, Map<String, dynamic> j) => Campagne(
        id: id,
        nom: j['nom'] as String? ?? 'Campagne',
        mj: j['mj'] as String? ?? '',
        mjNom: j['mjNom'] as String? ?? '',
        description: j['description'] as String? ?? '',
        code: j['code'] as String? ?? '',
        joueurs: [for (final u in j['joueurs'] as List? ?? const []) '$u'],
        demandes: [for (final u in j['demandes'] as List? ?? const []) '$u'],
        parametres: ParametresCampagne.depuisJson(j['parametres']),
        seance: Seance.depuisJson(j['seance']),
        creeLe: DateTime.tryParse('${j['creeLe']}') ?? DateTime(2026),
        modifieLe: DateTime.tryParse('${j['modifieLe']}') ?? DateTime(2026),
      );
}

/// Partie réservée au MJ : script de la campagne et notes générales.
class PriveCampagne {
  const PriveCampagne({this.script = '', this.notes = ''});

  final String script;
  final String notes;

  Map<String, dynamic> versJson() => {'script': script, 'notes': notes};

  factory PriveCampagne.depuisJson(Object? j) => j is Map
      ? PriveCampagne(
          script: j['script'] as String? ?? '',
          notes: j['notes'] as String? ?? '',
        )
      : const PriveCampagne();
}

/// Demande en attente ou joueur accepté.
enum StatutMembre {
  demande('En attente du MJ'),
  accepte('Membre');

  const StatutMembre(this.libelle);
  final String libelle;

  static StatutMembre depuisCode(Object? c) =>
      c == 'accepte' ? StatutMembre.accepte : StatutMembre.demande;
}

/// Un joueur d'une campagne et le personnage qu'il y joue.
class MembreCampagne {
  const MembreCampagne({
    required this.uid,
    required this.nom,
    required this.personnageId,
    required this.personnageNom,
    this.personnageResume = '',
    this.statut = StatutMembre.demande,
    required this.date,
    this.initiative = 0,
  });

  final String uid;

  /// Nom affiché du joueur.
  final String nom;
  final String personnageId;
  final String personnageNom;

  /// « Nain · Guerrier · niveau 3 ».
  final String personnageResume;
  final StatutMembre statut;

  /// Date de la demande.
  final DateTime date;

  /// Initiative du personnage (ordre des tours en combat).
  final int initiative;

  MembreCampagne copie({StatutMembre? statut}) => MembreCampagne(
        uid: uid,
        nom: nom,
        personnageId: personnageId,
        personnageNom: personnageNom,
        personnageResume: personnageResume,
        statut: statut ?? this.statut,
        date: date,
        initiative: initiative,
      );

  Map<String, dynamic> versJson() => {
        'uid': uid,
        'nom': nom,
        'personnageId': personnageId,
        'personnageNom': personnageNom,
        'personnageResume': personnageResume,
        'statut': statut.name,
        'date': date.toIso8601String(),
        'initiative': initiative,
      };

  factory MembreCampagne.depuisJson(Map<String, dynamic> j) => MembreCampagne(
        uid: j['uid'] as String? ?? '',
        nom: j['nom'] as String? ?? 'Joueur',
        personnageId: j['personnageId'] as String? ?? '',
        personnageNom: j['personnageNom'] as String? ?? '',
        personnageResume: j['personnageResume'] as String? ?? '',
        statut: StatutMembre.depuisCode(j['statut']),
        date: DateTime.tryParse('${j['date']}') ?? DateTime(2026),
        initiative: (j['initiative'] as num?)?.toInt() ?? 0,
      );
}

/// Codes d'invitation : un mot facile à dicter et 4 chiffres
/// (« LOUP-4827 »), sans lettres accentuées ni caractères ambigus.
abstract final class CodeInvitation {
  static const List<String> mots = [
    'LOUP',
    'OURS',
    'CERF',
    'AIGLE',
    'CORBEAU',
    'DRAGON',
    'GRIFFON',
    'LICORNE',
    'HIBOU',
    'RENARD',
    'FAUCON',
    'SANGLIER',
    'LYNX',
    'CHOUETTE',
    'TAVERNE',
    'DONJON',
    'RUNE',
    'GEMME',
    'LAME',
    'BOUCLIER',
    'TORCHE',
    'GRIMOIRE',
    'COURONNE',
    'BALADE',
    'FORGE',
    'ECHO',
    'BRUME',
    'ORAGE',
  ];

  static String generer([Random? aleatoire]) {
    final r = aleatoire ?? Random.secure();
    final mot = mots[r.nextInt(mots.length)];
    final nombre = 1000 + r.nextInt(9000);
    return '$mot-$nombre';
  }

  /// Saisie du joueur : majuscules, sans espaces ; « loup 4827 » ou
  /// « loup4827 » → « LOUP-4827 ».
  static String normaliser(String saisie) {
    final s = saisie.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final m = RegExp(r'^([A-Z]+)(\d{4})$').firstMatch(s);
    return m == null ? s : '${m.group(1)}-${m.group(2)}';
  }

  static bool valide(String code) => RegExp(r'^[A-Z]+-\d{4}$').hasMatch(code);
}

/// Erreur d'une action de campagne, avec un message en français.
class ErreurCampagne implements Exception {
  const ErreurCampagne(this.message);

  final String message;

  @override
  String toString() => message;
}
