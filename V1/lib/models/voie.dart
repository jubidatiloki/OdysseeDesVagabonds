import 'effet.dart';
import 'type_sort.dart';
import 'univers.dart';

/// Un jet de dés proposé par une compétence ou un passif sur la page
/// Lancer de dé (« Griffes et crocs : 1d6 + FOR »). JSON :
/// `{"libelle": "Griffes et crocs", "des": "1d6", "carac": "FOR",
///   "recharge": "1d4"}` — `carac` (modificateur ajouté) et `recharge`
/// (délai en tours, lancé après chaque utilisation) sont facultatifs.
/// Le libellé peut contenir `{cle}` : remplacé par le choix du personnage
/// (« Souffle élémentaire ({element-draconien}) » → « … (Feu) »).
///
/// Autres champs facultatifs :
/// - `difficulte` : 10 → réussite si total ≥ 10 (20 naturel réussi, 1 raté) ;
/// - `paliers` : `[{"jusqua": 5, "des": "1d6", "libelle": "…"}, …]` → selon
///   le d20 **naturel**, un second jet est lancé (dégâts des animaux) ;
/// - `avantage` : `true` → jet de d20 toujours avec avantage ;
/// - `applique` : `-pv`, `+pv`, `-pm`, `+pm` → le total est retiré / ajouté
///   aux PV ou PM actuels du personnage (PM plafonnés au maximum) ;
/// - `suite` : un autre jet lancé juste après (Puits d'arcane : perte de PV
///   puis mana regagné) ;
/// - `RANG` dans `des` (« RANGd6 ») : rang atteint dans la voie.
/// Un jet sans `des` portant le libellé d'un jet déjà obtenu le **modifie**
/// (ex. rang 5 : `{"libelle": "Amis de la forêt", "avantage": true}`).
class JetCompetence {
  const JetCompetence({
    required this.libelle,
    required this.des,
    this.carac = '',
    this.recharge = '',
    this.difficulte,
    this.paliers = const [],
    this.avantage = false,
    this.applique = '',
    this.suite,
    this.requiert = '',
    this.detruit = '',
    this.attaque,
    this.finEtat = '',
    this.instrument = false,
    this.gain,
    this.recuperePm = false,
    this.coutPm = 0,
  });

  /// PM dépensés à chaque utilisation (Justice divine : 5 PM par attaque) ;
  /// jet impossible sans assez de PM.
  final int coutPm;

  final String libelle;
  final String des;

  /// Code de la caractéristique dont le modificateur s'ajoute (« FOR »).
  final String carac;

  /// Délai avant de pouvoir recommencer (« 1d4 » tours), lancé à chaque
  /// utilisation.
  final String recharge;
  final int? difficulte;
  final List<PalierJet> paliers;
  final bool avantage;
  final String applique;
  final JetCompetence? suite;

  /// Objet nécessaire (nom) : jet impossible sans lui dans l'inventaire.
  final String requiert;

  /// Objet détruit (retiré de l'inventaire) après le jet.
  final String detruit;

  /// Attaque de compétence (Brutalité, Moulinet, Frénésie).
  final AttaqueJet? attaque;

  /// État annulé si le jet réussit (« Sortir de la rage »).
  final String finEtat;

  /// Test de prestation musicale : instrument maîtrisé requis ; bonus et
  /// avantage des instruments (Début artistique, Musicien renommé).
  final bool instrument;

  /// Argent gagné si le jet réussit (Musicien en herbe).
  final GainJet? gain;

  /// Le total du jet est ajouté aux PM (Méditation : 1 dé de mana).
  final bool recuperePm;

  /// Ce jet modifié par [autre] (même libellé, sans dés) : seuls les champs
  /// renseignés dans [autre] changent.
  JetCompetence modifiePar(JetCompetence autre) => JetCompetence(
        libelle: libelle,
        des: des,
        carac: autre.carac.isEmpty ? carac : autre.carac,
        recharge: autre.recharge.isEmpty ? recharge : autre.recharge,
        difficulte: autre.difficulte ?? difficulte,
        paliers: autre.paliers.isEmpty ? paliers : autre.paliers,
        avantage: avantage || autre.avantage,
        applique: autre.applique.isEmpty ? applique : autre.applique,
        suite: autre.suite ?? suite,
        requiert: autre.requiert.isEmpty ? requiert : autre.requiert,
        detruit: autre.detruit.isEmpty ? detruit : autre.detruit,
        attaque: autre.attaque == null
            ? attaque
            : (attaque?.modifiePar(autre.attaque!) ?? autre.attaque),
        finEtat: autre.finEtat.isEmpty ? finEtat : autre.finEtat,
        instrument: instrument || autre.instrument,
        gain: autre.gain == null
            ? gain
            : (gain?.modifiePar(autre.gain!) ?? autre.gain),
        recuperePm: recuperePm || autre.recuperePm,
        coutPm: autre.coutPm == 0 ? coutPm : autre.coutPm,
      );

  factory JetCompetence.depuisJson(Map<String, dynamic> j) => JetCompetence(
        libelle: '${j['libelle'] ?? ''}'.trim(),
        des: '${j['des'] ?? ''}'.trim(),
        carac: '${j['carac'] ?? ''}'.trim(),
        recharge: '${j['recharge'] ?? ''}'.trim(),
        difficulte: (j['difficulte'] as num?)?.toInt(),
        paliers: [
          for (final p in j['paliers'] as List<dynamic>? ?? const [])
            if (p is Map<String, dynamic>) PalierJet.depuisJson(p),
        ]..sort((a, b) => a.jusqua.compareTo(b.jusqua)),
        avantage: j['avantage'] == true,
        applique: '${j['applique'] ?? ''}'.trim(),
        suite: j['suite'] is Map<String, dynamic>
            ? JetCompetence.depuisJson(j['suite'] as Map<String, dynamic>)
            : null,
        requiert: '${j['requiert'] ?? ''}'.trim(),
        detruit: '${j['detruit'] ?? ''}'.trim(),
        attaque: AttaqueJet.depuisJson(j['attaque']),
        finEtat: '${j['finEtat'] ?? ''}'.trim(),
        instrument: j['instrument'] == true,
        gain: GainJet.depuisJson(j['gain']),
        recuperePm: j['recuperePm'] == true,
        coutPm: (j['coutPm'] as num?)?.toInt() ?? 0,
      );

  static List<JetCompetence> listeDepuisJson(Object? json) => json is List
      ? [
          for (final e in json)
            if (e is Map<String, dynamic>) JetCompetence.depuisJson(e),
        ]
      : const [];
}

/// Attaque de compétence (Brutalité, Moulinet, Frénésie) : jet d'attaque au
/// corps à corps (1d20 + toucher CaC) puis dégâts de l'arme équipée,
/// modifiés. JSON : `"attaque": {"deuxMains": true, "degatsEnPlus":
/// "2×RANG", "explosion": 1, "degatsArme": "1d6", "repetable": -1,
/// "etat": "Moulinet (défense réduite)", "toucher": 3}`. Un jet sans dés de
/// même libellé (renforcement) modifie les champs qu'il renseigne.
class AttaqueJet {
  const AttaqueJet({
    this.deuxMains,
    this.degatsEnPlus,
    this.explosion,
    this.degatsArme,
    this.repetable,
    this.etat,
    this.toucher,
    this.arme,
    this.diviseDegats,
    this.distance,
    this.mainsNues,
    this.sansCarac,
    this.armeInvoquee,
  });

  /// Arme invoquée par la compétence (« Arme divine » : Justice divine) :
  /// pas d'arme équipée requise, dés de [degatsArme].
  final String? armeInvoquee;

  /// Attaque sans arme équipée : à mains nues ou avec une arme invoquée.
  bool get sansArme => mainsNues == true || armeInvoquee != null;

  /// Attaque à mains nues (moine) : pas d'arme requise, dés à mains nues
  /// (ou [degatsArme]).
  final bool? mainsNues;

  /// Dégâts sans le modificateur de FOR (Déferlement de coups).
  final bool? sansCarac;

  /// Attaque à distance : arme à distance équipée, AdT, dégâts à distance
  /// (Tenir en joue, Pistoléro).
  final bool? distance;

  /// Dégâts divisés par ce nombre, arrondis à l'inférieur (Coup de
  /// boucher : 2).
  final int? diviseDegats;

  /// Arme équipée dont le nom contient ce texte, obligatoire (« Lance » :
  /// charge à la lance).
  final String? arme;

  /// Arme à deux mains équipée obligatoire.
  final bool? deuxMains;

  /// Dégâts ajoutés : nombre (« 2×RANG ») ou dé lancé à part (« 1d6 »).
  final String? degatsEnPlus;

  /// Dés bonus relancés quand le dé ajouté fait son maximum (1 : une fois ;
  /// 99 : tant qu'il fait le maximum).
  final int? explosion;

  /// Dés à la place de ceux de l'arme (Déchaînement).
  final String? degatsArme;

  /// Attaque répétable sur une cible suivante, avec ce malus de dégâts
  /// cumulé (−1 : −1, −2…) ; 0 : sans malus ; `null` : non répétable.
  final int? repetable;

  /// État activé à la première attaque, annulé en terminant (Moulinet :
  /// défense réduite).
  final String? etat;

  /// Bonus au toucher (Charge bestiale).
  final int? toucher;

  /// Cette attaque modifiée par [autre] (champs renseignés seulement).
  AttaqueJet modifiePar(AttaqueJet autre) => AttaqueJet(
        deuxMains: autre.deuxMains ?? deuxMains,
        degatsEnPlus: autre.degatsEnPlus ?? degatsEnPlus,
        explosion: autre.explosion ?? explosion,
        degatsArme: autre.degatsArme ?? degatsArme,
        repetable: autre.repetable ?? repetable,
        etat: autre.etat ?? etat,
        toucher: autre.toucher ?? toucher,
        arme: autre.arme ?? arme,
        diviseDegats: autre.diviseDegats ?? diviseDegats,
        distance: autre.distance ?? distance,
        mainsNues: autre.mainsNues ?? mainsNues,
        sansCarac: autre.sansCarac ?? sansCarac,
        armeInvoquee: autre.armeInvoquee ?? armeInvoquee,
      );

  static AttaqueJet? depuisJson(Object? j) {
    if (j is! Map<String, dynamic>) return null;
    String? texte(String cle) => j[cle] == null ? null : '${j[cle]}'.trim();
    return AttaqueJet(
      deuxMains: j['deuxMains'] as bool?,
      degatsEnPlus: texte('degatsEnPlus'),
      explosion: (j['explosion'] as num?)?.toInt(),
      degatsArme: texte('degatsArme'),
      repetable: (j['repetable'] as num?)?.toInt(),
      etat: texte('etat'),
      toucher: (j['toucher'] as num?)?.toInt(),
      arme: texte('arme'),
      diviseDegats: (j['diviseDegats'] as num?)?.toInt(),
      distance: j['distance'] as bool?,
      mainsNues: j['mainsNues'] as bool?,
      sansCarac: j['sansCarac'] as bool?,
      armeInvoquee: texte('armeInvoquee'),
    );
  }
}

/// Gain d'argent d'un jet réussi (Musicien en herbe : 1d20 + CHAN pièces de
/// cuivre, d'argent au niveau 2), ajouté à la bourse. JSON :
/// `"gain": {"des": "1d20", "carac": "CHAN", "piece": "cuivre"}`.
class GainJet {
  const GainJet({this.des, this.carac, this.piece});

  final String? des;
  final String? carac;

  /// `or`, `argent` ou `cuivre`.
  final String? piece;

  GainJet modifiePar(GainJet autre) => GainJet(
        des: autre.des ?? des,
        carac: autre.carac ?? carac,
        piece: autre.piece ?? piece,
      );

  static GainJet? depuisJson(Object? j) {
    if (j is! Map<String, dynamic>) return null;
    String? t(String cle) => j[cle] == null ? null : '${j[cle]}'.trim();
    return GainJet(des: t('des'), carac: t('carac'), piece: t('piece'));
  }
}

/// Compétence d'une autre classe prise sans les rangs précédents (barde,
/// « Diversité culturelle » : un rang 3, sauf les renforcements). JSON :
/// `"emprunt": {"cle": "diversite-culturelle", "rang": 3, "exclure":
/// "renforcement", "rangCalcul": 2}` ; « RANG » vaut [rangCalcul] pour la
/// compétence choisie.
class EmpruntRang {
  const EmpruntRang({
    required this.cle,
    this.rang = 3,
    this.exclure = '',
    this.rangCalcul = 2,
  });

  /// Clé du choix gardé sur le personnage (id de la voie choisie).
  final String cle;
  final int rang;

  /// Type exclu (« renforcement »).
  final String exclure;
  final int rangCalcul;

  static EmpruntRang? depuisJson(Object? j) {
    if (j is! Map<String, dynamic> || j['cle'] == null) return null;
    return EmpruntRang(
      cle: '${j['cle']}',
      rang: (j['rang'] as num?)?.toInt() ?? 3,
      exclure: '${j['exclure'] ?? ''}'.trim(),
      rangCalcul: (j['rangCalcul'] as num?)?.toInt() ?? 2,
    );
  }
}

/// Palier d'un jet : si le d20 naturel est ≤ [jusqua], on lance [des]
/// (« 3d6 », un dé par animal) sous le [libelle] donné.
class PalierJet {
  const PalierJet({required this.jusqua, required this.des, this.libelle = ''});

  final int jusqua;
  final String des;
  final String libelle;

  factory PalierJet.depuisJson(Map<String, dynamic> j) => PalierJet(
        jusqua: (j['jusqua'] as num?)?.toInt() ?? 20,
        des: '${j['des'] ?? ''}'.trim(),
        libelle: '${j['libelle'] ?? ''}'.trim(),
      );
}

/// État activable par une compétence (Visage impensable : apparence
/// monstrueuse). Ses [effets] ne comptent que tant qu'il est actif ;
/// réutiliser la compétence l'annule. JSON :
/// `"etat": {"nom": "Apparence monstrueuse", "effets": […]}`.
class EtatCompetence {
  const EtatCompetence({
    required this.nom,
    this.effets = const [],
    this.finApresDegats = false,
    this.groupe = '',
    this.jets = const [],
    this.recevable = false,
  });

  /// États d'un même groupe exclusifs : en activer un annule les autres
  /// (postures du guerrier).
  final String groupe;

  /// Jets proposés tant que l'état est actif (forme de loup : morsure).
  final List<JetCompetence> jets;

  /// Peut être reçu d'un autre personnage (Agrandissement lancé sur un
  /// allié) : activable sur toutes les fiches, section « Effets reçus ».
  final bool recevable;

  final String nom;
  final List<Effet> effets;

  /// Annulé tout seul après le jet de dégâts suivant (Feinte préparée).
  final bool finApresDegats;

  static EtatCompetence? depuisJson(Object? j) {
    if (j is! Map<String, dynamic>) return null;
    return EtatCompetence(
      nom: j['nom'] as String? ?? 'État',
      effets: Effet.listeDepuisJson(j['effets']),
      finApresDegats: j['finApresDegats'] == true,
      groupe: j['groupe'] as String? ?? '',
      jets: JetCompetence.listeDepuisJson(j['jets']),
      recevable: j['recevable'] == true,
    );
  }
}

/// Autre façon de lancer les dégâts d'un sort : total multiplié (Lumière
/// sacrée contre les morts-vivants : ×2) ou divisé (Courroux céleste
/// esquivé : ÷2). JSON : `{"libelle": "esquivé", "divise": 2}`.
class VarianteDegats {
  const VarianteDegats({
    required this.libelle,
    this.multiplie = 1,
    this.divise = 1,
  });

  final String libelle;
  final int multiplie;
  final int divise;

  factory VarianteDegats.depuisJson(Map<String, dynamic> j) => VarianteDegats(
        libelle: '${j['libelle'] ?? ''}'.trim(),
        multiplie: (j['multiplie'] as num?)?.toInt() ?? 1,
        divise: (j['divise'] as num?)?.toInt() ?? 1,
      );
}

/// Une option d'un choix (« Feu », « +2 INT », « Polyglotte (voie
/// humaine) »). Avec `reference` (« race-humain/1 »), la compétence de
/// cette voie et de ce rang est reprise (nom, type, effet, effets) au
/// chargement des données, sauf ce qui est déjà renseigné.
class OptionChoix {
  OptionChoix({
    required this.id,
    this.nom = '',
    this.type = '',
    this.effet = '',
    this.effets = const [],
    this.jets = const [],
    this.reference = '',
    this.question = '',
    this.objets = const [],
    this.liste = '',
    this.siDejaMaitrise = '',
    this.cache = false,
  });

  /// Précision choisie dans une liste déroulante : `armes` ou `instruments`.
  String liste;

  /// Option retenue à la place si l'élément choisi est déjà maîtrisé
  /// (« arme » → « arme-maitrisee » : +1 au toucher).
  final String siDejaMaitrise;

  /// Option interne (pas de pastille) : atteinte via [siDejaMaitrise].
  final bool cache;

  /// Objets donnés quand cette option est choisie (`{precision}` remplacé :
  /// l'arme ou l'instrument choisi).
  List<Map<String, dynamic>> objets;

  final String id;
  String nom;
  String type;
  String effet;
  List<Effet> effets;
  List<JetCompetence> jets;

  /// Précision à saisir avec cette option (« Quelle arme ? ») ; remplace
  /// `{precision}` dans les effets.
  String question;

  /// « idVoie/rang » d'une compétence à reprendre.
  final String reference;

  factory OptionChoix.depuisJson(Map<String, dynamic> j) => OptionChoix(
        id: '${j['id']}',
        nom: j['nom'] as String? ?? '',
        type: j['type'] as String? ?? '',
        effet: j['effet'] as String? ?? j['description'] as String? ?? '',
        effets: Effet.listeDepuisJson(j['effets']),
        jets: JetCompetence.listeDepuisJson(j['jets']),
        reference: j['reference'] as String? ?? '',
        question: j['question'] as String? ?? '',
        liste: j['liste'] as String? ?? '',
        siDejaMaitrise: j['siDejaMaitrise'] as String? ?? '',
        cache: j['cache'] == true,
        objets: [
          for (final o in j['objets'] as List<dynamic>? ?? const [])
            if (o is Map<String, dynamic>) o,
        ],
      );
}

/// Choix à faire en obtenant une compétence (ou un passif). La valeur est
/// gardée sur le personnage sous [cle] : si elle existe déjà (ex. l'élément
/// du souffle draconien choisi à la création), le choix est automatique.
/// JSON : `{"cle": "element-draconien", "titre": "Élément",
///   "options": [{"id": "feu", "nom": "Feu"}, …]}`.
class ChoixCompetence {
  const ChoixCompetence({
    required this.cle,
    this.titre = '',
    this.options = const [],
    this.filtre = '',
    this.nombre = 1,
  });

  final String cle;
  final String titre;
  final List<OptionChoix> options;

  /// Nombre d'options à choisir (Vagabond : 6 stats différentes) ; au-delà
  /// de 1, les ids choisis sont gardés ensemble, séparés par des virgules.
  final int nombre;

  /// Options choisies d'après la valeur gardée (« FOR,DEX,CON »).
  List<OptionChoix> choisies(String? valeur) => [
        for (final id in (valeur ?? '').split(','))
          if (option(id.trim()) case final o?) o,
      ];

  /// Options permises calculées d'après le personnage :
  /// - `plus-faible` : caractéristique(s) la ou les plus faibles (id des
  ///   options = code de la caractéristique) ;
  /// - `autre:<cle>` : toutes sauf l'option choisie pour le choix `<cle>`.
  final String filtre;

  OptionChoix? option(String? id) {
    for (final o in options) {
      if (o.id == id) return o;
    }
    return null;
  }

  static ChoixCompetence? depuisJson(Object? j) {
    if (j is! Map<String, dynamic> || j['cle'] == null) return null;
    return ChoixCompetence(
      cle: '${j['cle']}',
      titre: j['titre'] as String? ?? '',
      filtre: j['filtre'] as String? ?? '',
      nombre: (j['nombre'] as num?)?.toInt() ?? 1,
      options: [
        for (final o in j['options'] as List<dynamic>? ?? const [])
          if (o is Map<String, dynamic>) OptionChoix.depuisJson(o),
      ],
    );
  }
}

/// Variante d'une compétence selon le passif choisi à la création ou selon
/// l'origine (`selonOrigine` : humain, « Origines marquées »)
/// (`selonPassif` : `{"souffle": {"effet": …, "jets": […]}, "ailes": …}`).
/// Ce qui est renseigné remplace la compétence de base.
class VarianteCompetence {
  const VarianteCompetence({
    this.type,
    this.effet,
    this.effets,
    this.jets,
    this.choix,
  });

  final String? type;
  final String? effet;
  final List<Effet>? effets;
  final List<JetCompetence>? jets;

  /// Choix propre à la variante (érudit : domaine de connaissance).
  final ChoixCompetence? choix;

  factory VarianteCompetence.depuisJson(Map<String, dynamic> j) =>
      VarianteCompetence(
        type: j['type'] as String?,
        effet: j['effet'] as String? ?? j['description'] as String?,
        effets: j['effets'] == null ? null : Effet.listeDepuisJson(j['effets']),
        jets:
            j['jets'] == null ? null : JetCompetence.listeDepuisJson(j['jets']),
        choix: ChoixCompetence.depuisJson(j['choix']),
      );
}

/// Une compétence d'une voie (rang 1 à 5).
class Competence {
  const Competence({
    required this.rang,
    required this.nom,
    this.type = '',
    this.effet = '',
    this.effets = const [],
    this.jets = const [],
    this.choix,
    this.selonPassif = const {},
    this.selonOrigine = const {},
    this.etat,
    this.objets = const [],
    this.aussi = const [],
    this.emprunts = 0,
    this.degats = '',
    this.effetApplique = '',
    this.soin = '',
    this.reussite,
    this.fabrication = const [],
    this.emprunt,
    this.mana = '',
    this.typesSort = const [],
    this.modulable = false,
    this.etatsAuChoix = const [],
    this.variantesDegats = const [],
    this.invocations = const [],
    this.endurance = const [],
    this.selonProfil = const {},
    this.typeDegats = '',
  });

  /// Type de dégâts d'un sort ou d'une attaque (feu, glace, foudre, magique,
  /// chaos, physique) ; vide : physique.
  final String typeDegats;

  /// Coûts en points d'endurance (PE) : un seul (« Moulinet : 2 PE ») ou
  /// plusieurs actions (chimiste : potion 1 PE, explosif 2 PE). JSON :
  /// `"endurance": 2` ou `"endurance": [{"libelle": "Fabriquer une potion",
  /// "cout": 1}]`.
  final List<CoutEndurance> endurance;

  /// Variantes selon le profil de la classe (`lanceur`, `physique`,
  /// `hybride`) : Puits d'arcane du haut-elfe. Moins prioritaires que
  /// [selonPassif] et [selonOrigine].
  final Map<String, VarianteCompetence> selonProfil;

  /// Fiches du bestiaire (ids) des créatures invoquées ou des compagnons
  /// donnés (diablotin, animal de compagnie) : bouton « Statistiques ».
  final List<String> invocations;

  /// États activables au choix, en plus de [etat] (Bénédiction : arme,
  /// armure ou personne) ; lancer le sort n'en active aucun.
  final List<EtatCompetence> etatsAuChoix;

  /// Tous les états que la compétence peut activer.
  List<EtatCompetence> get etats =>
      [if (etat case final e?) e, ...etatsAuChoix];

  /// Sorts : autres façons de lancer les dégâts (×2 contre les
  /// morts-vivants, ÷2 si esquivé).
  final List<VarianteDegats> variantesDegats;

  /// Sort modulable (Boule de feu) : se lance à la puissance voulue, de 1 au
  /// rang atteint dans la voie ; dés de dégâts et coût de ce rang.
  final bool modulable;

  /// Copie avec un autre nom, d'autres dégâts ou un autre coût affiché.
  Competence copie({String? nom, String? degats, String? mana}) => Competence(
        rang: rang,
        nom: nom ?? this.nom,
        type: type,
        effet: effet,
        effets: effets,
        jets: jets,
        choix: choix,
        selonPassif: selonPassif,
        selonOrigine: selonOrigine,
        etat: etat,
        objets: objets,
        aussi: aussi,
        emprunts: emprunts,
        degats: degats ?? this.degats,
        effetApplique: effetApplique,
        soin: soin,
        reussite: reussite,
        fabrication: fabrication,
        emprunt: emprunt,
        mana: mana ?? this.mana,
        typesSort: typesSort,
        modulable: modulable,
        etatsAuChoix: etatsAuChoix,
        variantesDegats: variantesDegats,
        invocations: invocations,
        endurance: endurance,
        selonProfil: selonProfil,
        typeDegats: typeDegats,
      );

  /// Types du sort (offensif, support…), 1 ou 2 ; vide si ce n'est pas un
  /// sort.
  final List<TypeSort> typesSort;

  final int rang;
  final String nom;

  /// Ex. « passif », « actif complexe, compétence », « sort »…
  final String type;
  final String effet;

  /// Effets détaillés (facultatif), affichés en puces sous [effet].
  final List<Effet> effets;

  /// Jets proposés sur la page Lancer de dé.
  final List<JetCompetence> jets;

  /// Choix à faire en obtenant la compétence.
  final ChoixCompetence? choix;

  /// Variantes selon le passif choisi à la création (id du passif →
  /// variante).
  final Map<String, VarianteCompetence> selonPassif;

  /// Variantes selon l'origine choisie à la création (id de l'origine →
  /// variante) ; prioritaires sur [selonPassif].
  final Map<String, VarianteCompetence> selonOrigine;

  /// État activable (apparence…), effets comptés seulement quand actif.
  final EtatCompetence? etat;

  /// Objets donnés à l'obtention (JSON d'objet d'inventaire : porte-bonheur,
  /// sacoche), ajoutés une seule fois à l'inventaire.
  final List<Map<String, dynamic>> objets;

  /// Autres compétences données au même rang (deux compétences distinctes :
  /// « Discussion insensée » en combat / hors combat).
  final List<Competence> aussi;

  /// Rangs à prendre dans les voies d'autres classes (humain,
  /// « Polyvalence » : 2) ; rang 2 seulement avec le rang 1 de la même voie.
  final int emprunts;

  /// Sorts : dégâts infligés (« 1d6 », « 1d8 chaos ») ; vide s'il n'y en a pas.
  final String degats;

  /// Sorts : effet appliqué (« Soigne 1D6 PV », « Cible amicale ») ; vide
  /// s'il n'y en a pas.
  final String effetApplique;

  /// Sorts : soin prodigué (« 1D6 PV ») ; vide s'il n'y en a pas.
  final String soin;

  /// Sorts : jet nécessaire pour réussir (attaque magique, test…) ; `null` :
  /// le sort réussit d'office.
  final ReussiteSort? reussite;

  /// Objets que la compétence permet de fabriquer (JSON d'objet
  /// d'inventaire) : bouton « Fabriquer » dans l'inventaire.
  final List<Map<String, dynamic>> fabrication;

  /// Compétence d'une autre classe à choisir (Diversité culturelle).
  final EmpruntRang? emprunt;

  /// Sorts : texte du coût en mana à la place du calcul selon le rang
  /// (« coût du sort dissipé »).
  final String mana;

  /// La compétence telle que l'a un personnage : variante de son passif,
  /// option choisie (effets et jets ajoutés), `{cle}` remplacés par les
  /// noms des choix.
  Competence pour({
    String? optionPassifId,
    String? origineId,
    String? profil,
    Map<String, String> choixFaits = const {},
    Map<String, ChoixCompetence> autresChoix = const {},
    Map<String, String> precisions = const {},
  }) {
    final v = selonOrigine[origineId] ??
        selonPassif[optionPassifId] ??
        selonProfil[profil];
    var t = v?.type ?? type;
    var e = v?.effet ?? effet;
    var ef = <Effet>[...(v?.effets ?? effets)];
    var js = <JetCompetence>[...(v?.jets ?? jets)];
    final c = v?.choix ?? choix;
    final o = c?.option(choixFaits[c.cle]);
    // Choix multiple (Vagabond : +1 dans 6 stats) : effets de chaque option.
    if (c != null && c.nombre > 1) {
      final liste = c.choisies(choixFaits[c.cle]);
      if (liste.isNotEmpty) {
        e = [
          if (e.isNotEmpty) e,
          '${c.titre.isEmpty ? 'Choix' : c.titre} : '
              '${liste.map((o) => o.nom).join(', ')}',
        ].join('\n');
        ef = [...ef, for (final o in liste) ...o.effets];
      }
    } else if (c != null && o != null) {
      // Précision saisie (« Luth », « Épée longue ») : remplace {precision}.
      final p = precisions[c.cle] ?? '';
      e = [
        if (e.isNotEmpty) e,
        '${c.titre.isEmpty ? 'Choix' : c.titre} : ${o.nom}'
            '${p.isEmpty ? '' : ' ($p)'}'
            '${o.effet.isEmpty ? '' : ' — ${o.effet.replaceAll('{precision}', p)}'}',
      ].join('\n');
      ef = [...ef, for (final x in o.effets) x.avecPrecision(p)];
      js = [...js, ...o.jets];
      if (t.isEmpty) t = o.type;
    }
    return Competence(
      rang: rang,
      nom: nom,
      type: t,
      effet: remplacerChoix(
        e,
        choixFaits,
        {...autresChoix, if (c != null) c.cle: c},
      ),
      // `{precision:cle}` : précision d'un autre choix (arme familiale).
      effets: [for (final x in ef) x.avecPrecisions(precisions)],
      jets: js,
      choix: c,
      selonPassif: selonPassif,
      selonOrigine: selonOrigine,
      etat: etat,
      objets: objets,
      aussi: aussi,
      emprunts: emprunts,
      degats: remplacerChoix(
          degats, choixFaits, {...autresChoix, if (c != null) c.cle: c}),
      effetApplique: remplacerChoix(
          effetApplique, choixFaits, {...autresChoix, if (c != null) c.cle: c}),
      soin: soin,
      mana: mana,
      reussite: reussite,
      fabrication: fabrication,
      emprunt: emprunt,
      typesSort: typesSort,
      modulable: modulable,
      etatsAuChoix: etatsAuChoix,
      variantesDegats: variantesDegats,
      invocations: invocations,
      endurance: endurance,
      selonProfil: selonProfil,
      typeDegats: typeDegats,
    );
  }

  factory Competence.depuisJson(Map<String, dynamic> j) => Competence(
        rang: (j['rang'] as num).toInt(),
        nom: j['nom'] as String? ?? '',
        type: j['type'] as String? ?? '',
        // « description » accepté à la place de « effet ».
        effet: j['effet'] as String? ?? j['description'] as String? ?? '',
        effets: Effet.listeDepuisJson(j['effets']),
        jets: JetCompetence.listeDepuisJson(j['jets']),
        choix: ChoixCompetence.depuisJson(j['choix']),
        selonPassif: _variantes(j['selonPassif']),
        selonOrigine: _variantes(j['selonOrigine']),
        selonProfil: _variantes(j['selonProfil']),
        typeDegats: j['typeDegats'] as String? ?? '',
        endurance: CoutEndurance.listeDepuisJson(j['endurance']),
        etat: EtatCompetence.depuisJson(j['etat']),
        etatsAuChoix: [
          for (final e in j['etats'] as List<dynamic>? ?? const [])
            if (EtatCompetence.depuisJson(e) case final x?) x,
        ],
        variantesDegats: [
          for (final v in j['variantesDegats'] as List<dynamic>? ?? const [])
            if (v is Map<String, dynamic>) VarianteDegats.depuisJson(v),
        ],
        objets: [
          for (final o in j['objets'] as List<dynamic>? ?? const [])
            if (o is Map<String, dynamic>) o,
        ],
        aussi: [
          for (final c in j['aussi'] as List<dynamic>? ?? const [])
            if (c is Map<String, dynamic>)
              Competence.depuisJson({'rang': j['rang'], ...c}),
        ],
        emprunts: (j['emprunts'] as num?)?.toInt() ?? 0,
        degats: '${j['degats'] ?? ''}'.trim(),
        effetApplique: '${j['effetApplique'] ?? ''}'.trim(),
        mana: '${j['mana'] ?? ''}'.trim(),
        soin: '${j['soin'] ?? ''}'.trim(),
        reussite: ReussiteSort.depuisJson(j['reussite']),
        fabrication: [
          for (final o in j['fabrication'] as List<dynamic>? ?? const [])
            if (o is Map<String, dynamic>) o,
        ],
        emprunt: EmpruntRang.depuisJson(j['emprunt']),
        typesSort: [
          for (final t in j['typesSort'] as List<dynamic>? ?? const [])
            if (TypeSort.depuisCode('$t') case final x?) x,
        ],
        modulable: j['modulable'] == true,
        invocations: [
          for (final i in j['invocations'] as List<dynamic>? ?? const []) '$i',
        ],
      );

  static Map<String, VarianteCompetence> _variantes(Object? j) => {
        if (j is Map<String, dynamic>)
          for (final e in j.entries)
            if (e.value is Map<String, dynamic>)
              e.key: VarianteCompetence.depuisJson(
                e.value as Map<String, dynamic>,
              ),
      };
}

/// Remplace `{cle}` par le nom de l'option choisie (`{element-draconien}` →
/// « Feu »), d'après les [choixConnus] (clé → choix) ; une clé sans choix
/// fait devient « à choisir ».
String remplacerChoix(
  String texte,
  Map<String, String> choixFaits,
  Map<String, ChoixCompetence> choixConnus,
) {
  if (!texte.contains('{')) return texte;
  return texte.replaceAllMapped(RegExp(r'\{([^{}]+)\}'), (m) {
    final cle = m.group(1)!;
    final id = choixFaits[cle];
    if (id == null) return 'à choisir';
    final nom = choixConnus[cle]?.option(id)?.nom;
    return nom == null || nom.isEmpty ? id : nom;
  });
}

/// Texte hors personnage (pages Races, Classes, fenêtres des voies) :
/// `{cle}` → « au choix ».
String sansChoix(String texte) =>
    texte.replaceAll(RegExp(r'\{[^{}]+\}'), 'au choix');

/// Une voie : suite de 5 compétences à débloquer dans l'ordre.
/// Voies de classe (achetées avec les points de compétence) ou voie raciale
/// (rangs offerts aux niveaux impairs).
class Voie {
  const Voie({
    required this.id,
    required this.nom,
    this.competences = const [],
    this.univers = kUniversParDefaut,
    this.description = '',
  });

  final String id;
  final String nom;

  /// Présentation de la voie (facultative).
  final String description;
  final List<Competence> competences;

  /// Univers de la voie (id, voir `Univers`).
  final String univers;

  /// Nom court : « Voie de la brute » → « Brute ».
  String get nomCourt {
    final court = nom.replaceFirst(
      RegExp(r"^Voie (de la |de l'|du |des |de |d')?"),
      '',
    );
    if (court.isEmpty) return nom;
    return court[0].toUpperCase() + court.substring(1);
  }

  Competence? competence(int rang) {
    for (final c in competences) {
      if (c.rang == rang) return c;
    }
    return null;
  }

  factory Voie.depuisJson(Map<String, dynamic> j) => Voie(
        id: j['id'] as String,
        nom: j['nom'] as String? ?? '',
        competences: (j['competences'] as List<dynamic>? ?? const [])
            .map((e) => Competence.depuisJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.rang.compareTo(b.rang)),
        univers: universDepuisJson(j['univers']),
        description: j['description'] as String? ?? '',
      );
}

/// Jet de réussite d'un sort : 1d20 + modificateur de [carac] + [bonus],
/// contre une [difficulte] fixe ou ce qu'indique [contre] (« CA de la
/// cible »). JSON : `"reussite": {"carac": "ADM",
/// "contre": "CA de la cible"}` ou `{"carac": "INT",
/// "difficulte": 12}`.
class ReussiteSort {
  const ReussiteSort({
    this.carac = '',
    this.bonus = 0,
    this.difficulte,
    this.contre = '',
    this.libelle = '',
  });

  /// Code de la caractéristique (« ADM » : toucher magique).
  final String carac;

  /// Bonus fixe ajouté au jet.
  final int bonus;
  final int? difficulte;

  /// Ce que le jet doit battre quand ce n'est pas un nombre fixe.
  final String contre;

  /// Nom du jet (« Attaque magique ») ; « Réussite » par défaut.
  final String libelle;

  static ReussiteSort? depuisJson(Object? j) {
    if (j is! Map<String, dynamic>) return null;
    return ReussiteSort(
      carac: '${j['carac'] ?? ''}'.trim().toUpperCase(),
      bonus: (j['bonus'] as num?)?.toInt() ?? 0,
      difficulte: (j['difficulte'] as num?)?.toInt(),
      contre: '${j['contre'] ?? ''}'.trim(),
      libelle: '${j['libelle'] ?? ''}'.trim(),
    );
  }
}

/// Coût en points d'endurance (PE) d'une compétence ou d'une de ses actions
/// (règle du 03/11/2026 : les classes physiques et hybrides dépensent de
/// l'endurance). [libelle] vide : le nom de la compétence.
class CoutEndurance {
  const CoutEndurance({this.libelle = '', required this.cout});

  final String libelle;
  final int cout;

  /// `2` → un coût ; `[{"libelle": …, "cout": 1}, …]` → plusieurs.
  static List<CoutEndurance> listeDepuisJson(Object? j) {
    if (j is num) return [CoutEndurance(cout: j.toInt())];
    if (j is! List) return const [];
    return [
      for (final e in j)
        if (e is Map && e['cout'] is num)
          CoutEndurance(
            libelle: '${e['libelle'] ?? ''}'.trim(),
            cout: (e['cout'] as num).toInt(),
          )
        else if (e is num)
          CoutEndurance(cout: e.toInt()),
    ];
  }
}
