import 'carac.dart';
import 'classe.dart';
import 'effet.dart';
import 'univers.dart';
import 'voie.dart';

class Passif {
  const Passif({
    required this.nom,
    required this.description,
    this.effets = const [],
    this.type = '',
  });

  final String nom;
  final String description;

  /// Effets détaillés (facultatif), affichés en puces.
  final List<Effet> effets;

  /// Type, comme pour une compétence (« gratuit, 1×/jour ») ; facultatif.
  final String type;

  static Passif? depuisJson(Object? json) {
    if (json is! Map) return null;
    return Passif(
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String? ?? '',
      effets: Effet.listeDepuisJson(json['effets']),
      type: json['type'] as String? ?? '',
    );
  }
}

/// Variante de passif racial à choisir à la création
/// (draconien : souffle élémentaire ou ailes vestigiales). Comme une
/// compétence, elle peut avoir un type (« actif », « mouvement »), des
/// effets, des jets (page Lancer de dé) et un choix à faire à la création
/// (élément du souffle).
class OptionPassif {
  const OptionPassif({
    required this.id,
    required this.nom,
    required this.description,
    this.type = '',
    this.effets = const [],
    this.jets = const [],
    this.choix,
  });

  final String id;
  final String nom;
  final String description;
  final String type;
  final List<Effet> effets;
  final List<JetCompetence> jets;
  final ChoixCompetence? choix;

  factory OptionPassif.depuisJson(Map<String, dynamic> j) => OptionPassif(
        id: j['id'] as String,
        nom: j['nom'] as String? ?? '',
        description: j['description'] as String? ?? '',
        type: j['type'] as String? ?? '',
        effets: Effet.listeDepuisJson(j['effets']),
        jets: JetCompetence.listeDepuisJson(j['jets']),
        choix: ChoixCompetence.depuisJson(j['choix']),
      );
}

/// Origine d'une race (demi-elfe : humaine/sylvaine/haut-elfe ;
/// humain : campagnard, orfèvre…). Ajoute ses propres modificateurs.
class OrigineRace {
  const OrigineRace({
    required this.id,
    required this.nom,
    required this.modificateurs,
    this.passif,
    this.bonus,
    this.maitrisesArmes = const [],
  });

  final String id;
  final String nom;
  final Map<Carac, int> modificateurs;
  final Passif? passif;

  /// Texte libre (ex. bonus du rang 2 « Origines marquées » de l'humain).
  final String? bonus;

  /// Armes maîtrisées en plus de la race (origines elfiques : arc).
  final List<String> maitrisesArmes;

  factory OrigineRace.depuisJson(Map<String, dynamic> j) => OrigineRace(
        id: j['id'] as String,
        nom: j['nom'] as String,
        modificateurs: caracMapDepuisJson(j['modificateurs']),
        passif: Passif.depuisJson(j['passif']),
        bonus: j['bonus'] as String?,
        maitrisesArmes: [
          for (final m in j['maitrisesArmes'] as List? ?? const []) '$m',
        ],
      );
}

class Race {
  const Race({
    required this.id,
    required this.nom,
    required this.deVie,
    required this.deMana,
    this.deEndurance = 6,
    this.modificateurs = const {},
    Passif? passif,
    List<Passif> passifs = const [],
    this.origines = const [],
    this.optionsPassif = const [],
    this.voieRaciale,
    this.pointsCompetenceBonus = 0,
    this.maitrises = '',
    this.langues = const [],
    this.restrictions = '',
    this.maitrisesArmes = const [],
    this.armureMax = '',
    this.armuresPermises = const [],
    this.armesInterdites = const [],
    this.malusArmes = const {},
    this.desArmeMax,
    this.description = '',
    this.profil = ProfilClasse.hybride,
    this.univers = kUniversParDefaut,
  })  : _passif = passif,
        _passifs = passifs;

  final String id;
  final String nom;

  /// Taille du dé de vie (4, 6, 8…), avant modification par la classe.
  final int deVie;

  /// Taille du dé de mana, avant modification par la classe.
  final int deMana;

  /// Taille du dé d'endurance, avant modification par la classe.
  final int deEndurance;

  final Map<Carac, int> modificateurs;
  final Passif? _passif;
  final List<Passif> _passifs;

  /// Passifs raciaux (nain, haut-elfe : deux, chacun son nom, 13/11/2026).
  List<Passif> get passifs => [if (_passif case final p?) p, ..._passifs];

  /// Premier passif racial (`null` : aucun).
  Passif? get passif => passifs.firstOrNull;
  final List<OrigineRace> origines;

  /// Variantes du passif à choisir à la création (vide si aucun choix).
  final List<OptionPassif> optionsPassif;

  /// Voie raciale : rangs offerts gratuitement aux niveaux impairs.
  final Voie? voieRaciale;

  /// Points de compétence supplémentaires au départ (humain : 1).
  final int pointsCompetenceBonus;

  final String maitrises;

  /// Langues parlées d'office par la race (en plus du commun).
  final List<String> langues;
  final String restrictions;

  /// Groupes d'armes ou mots d'un nom maîtrisés (voir `Classe`).
  final List<String> maitrisesArmes;

  /// Armure la plus lourde permise : tissu, cuir, mailles ; vide : toutes.
  final String armureMax;

  /// Mots d'un nom d'armure permise malgré tout (plaques ajustées du gnome).
  final List<String> armuresPermises;

  /// Mots d'un nom d'arme interdite (nain : arc long, hast).
  final List<String> armesInterdites;

  /// Malus au toucher par groupe d'armes (haut-elfe : poudre −2).
  final Map<String, int> malusArmes;

  /// Plus grand dé d'arme permis (gnome : d8, 2d6 autorisé).
  final int? desArmeMax;

  /// Présentation de la race (page Races).
  final String description;

  /// Orientation : physique, magique ou hybride (affichage).
  final ProfilClasse profil;

  /// Univers de la race (id, voir `Univers`).
  final String univers;

  bool get aDesOrigines => origines.isNotEmpty;
  bool get aUnChoixDePassif => optionsPassif.isNotEmpty;

  OptionPassif? optionPassif(String? id) {
    if (id == null) return null;
    for (final o in optionsPassif) {
      if (o.id == id) return o;
    }
    return null;
  }

  OrigineRace? origine(String? id) {
    if (id == null) return null;
    for (final o in origines) {
      if (o.id == id) return o;
    }
    return null;
  }

  factory Race.depuisJson(Map<String, dynamic> j) => Race(
        id: j['id'] as String,
        nom: j['nom'] as String,
        deVie: (j['deVie'] as num).toInt(),
        deMana: (j['deMana'] as num).toInt(),
        deEndurance: (j['deEndurance'] as num?)?.toInt() ?? 6,
        modificateurs: caracMapDepuisJson(j['modificateurs']),
        // Un passif (objet) ou plusieurs (liste).
        passifs: [
          for (final p
              in j['passif'] is List ? j['passif'] as List : [j['passif']])
            if (Passif.depuisJson(p) case final x?) x,
        ],
        origines: (j['origines'] as List<dynamic>? ?? const [])
            .map((e) => OrigineRace.depuisJson(e as Map<String, dynamic>))
            .toList(),
        optionsPassif: (j['optionsPassif'] as List<dynamic>? ?? const [])
            .map((e) => OptionPassif.depuisJson(e as Map<String, dynamic>))
            .toList(),
        voieRaciale: j['voieRaciale'] is Map<String, dynamic>
            ? Voie.depuisJson(j['voieRaciale'] as Map<String, dynamic>)
            : null,
        pointsCompetenceBonus:
            (j['pointsCompetenceBonus'] as num?)?.toInt() ?? 0,
        maitrises: j['maitrises'] as String? ?? '',
        langues: [
          for (final l in j['langues'] as List<dynamic>? ?? const []) '$l',
        ],
        restrictions: j['restrictions'] as String? ?? '',
        maitrisesArmes: [
          for (final m in j['maitrisesArmes'] as List? ?? const []) '$m',
        ],
        armureMax: j['armureMax'] as String? ?? '',
        armuresPermises: [
          for (final m in j['armuresPermises'] as List? ?? const []) '$m',
        ],
        armesInterdites: [
          for (final m in j['armesInterdites'] as List? ?? const []) '$m',
        ],
        malusArmes: {
          if (j['malusArmes'] case final Map<dynamic, dynamic> m)
            for (final e in m.entries) '${e.key}': (e.value as num).toInt(),
        },
        desArmeMax: (j['desArmeMax'] as num?)?.toInt(),
        description: j['description'] as String? ?? '',
        profil: ProfilClasse.depuisCode(
          j['profil'] as String? ?? 'hybride',
        ),
        univers: universDepuisJson(j['univers']),
      );
}
