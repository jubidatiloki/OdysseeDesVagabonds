import 'campagne.dart';

/// Interface de jeu d'une séance : mode (exploration ou combat), tours,
/// créatures ajoutées par le MJ, jets de dés et leur visibilité, ressources
/// des personnages.

/// Mode de jeu, choisi par le MJ.
enum ModeJeu {
  exploration('Exploration'),
  combat('Combat');

  const ModeJeu(this.libelle);
  final String libelle;

  static ModeJeu depuisCode(Object? c) =>
      c == 'combat' ? ModeJeu.combat : ModeJeu.exploration;
}

/// État partagé de la partie. En combat, [ordre] liste les participants par
/// initiative (uid d'un joueur ou id d'une créature). Pas de tours en
/// exploration (règle du 03/11/2026).
class EtatJeu {
  const EtatJeu({
    this.mode = ModeJeu.exploration,
    this.ordre = const [],
    this.index = 0,
    this.manche = 1,
    this.lieu = '',
    this.montees = const {},
  });

  /// Lieu de la scène, choisi par le MJ.
  final String lieu;

  /// Montées de niveau autorisées par le MJ : uid → niveau atteignable.
  final Map<String, int> montees;

  /// Le MJ autorise ce joueur à quitter le [niveau] actuel.
  bool peutMonter(String joueur, int niveau) => (montees[joueur] ?? 0) > niveau;

  /// Début d'un combat : le lieu et les autorisations restent.
  EtatJeu commencerCombat(List<String> ordre) => EtatJeu(
        mode: ModeJeu.combat,
        ordre: ordre,
        lieu: lieu,
        montees: montees,
      );

  /// Retour à l'exploration : le lieu et les autorisations restent.
  EtatJeu enExploration() => EtatJeu(lieu: lieu, montees: montees);

  EtatJeu avecInfos({String? lieu, Map<String, int>? montees}) => EtatJeu(
        mode: mode,
        ordre: ordre,
        index: index,
        manche: manche,
        lieu: lieu ?? this.lieu,
        montees: montees ?? this.montees,
      );

  final ModeJeu mode;
  final List<String> ordre;

  /// Position du participant dont c'est le tour.
  final int index;

  /// Numéro du tour de table (1 au début du combat).
  final int manche;

  bool get enCombat => mode == ModeJeu.combat;

  /// Participant dont c'est le tour, `null` hors combat.
  String? get actif =>
      enCombat && index >= 0 && index < ordre.length ? ordre[index] : null;

  /// Tour suivant : après le dernier, nouvelle manche.
  EtatJeu suivant() {
    if (ordre.isEmpty) return this;
    final fin = index + 1 >= ordre.length;
    return EtatJeu(
      mode: mode,
      ordre: ordre,
      index: fin ? 0 : index + 1,
      manche: fin ? manche + 1 : manche,
      lieu: lieu,
      montees: montees,
    );
  }

  /// Tour précédent (rien avant le tout premier tour du combat).
  EtatJeu precedent() {
    if (ordre.isEmpty || (index == 0 && manche == 1)) return this;
    final debut = index == 0;
    return EtatJeu(
      mode: mode,
      ordre: ordre,
      index: debut ? ordre.length - 1 : index - 1,
      manche: debut ? manche - 1 : manche,
      lieu: lieu,
      montees: montees,
    );
  }

  /// Ordre recalculé (créature ajoutée ou retirée) : le tour reste à celui
  /// qui jouait ; s'il a disparu, au suivant à la même place.
  EtatJeu avecOrdre(List<String> nouveau) {
    final i = nouveau.indexOf(actif ?? '');
    return EtatJeu(
      mode: mode,
      ordre: nouveau,
      index: i >= 0
          ? i
          : nouveau.isEmpty
              ? 0
              : index.clamp(0, nouveau.length - 1),
      manche: manche,
      lieu: lieu,
      montees: montees,
    );
  }

  Map<String, dynamic> versJson() => {
        'mode': mode.name,
        'ordre': ordre,
        'index': index,
        'manche': manche,
        if (lieu.isNotEmpty) 'lieu': lieu,
        if (montees.isNotEmpty) 'montees': montees,
      };

  factory EtatJeu.depuisJson(Object? j) {
    if (j is! Map) return const EtatJeu();
    return EtatJeu(
      mode: ModeJeu.depuisCode(j['mode']),
      ordre: [for (final o in j['ordre'] as List? ?? const []) '$o'],
      index: (j['index'] as num?)?.toInt() ?? 0,
      manche: (j['manche'] as num?)?.toInt() ?? 1,
      lieu: j['lieu'] as String? ?? '',
      montees: {
        if (j['montees'] case final Map m)
          for (final e in m.entries)
            if (e.value is num) '${e.key}': (e.value as num).toInt(),
      },
    );
  }
}

/// Ordre de combat : initiative décroissante ; à égalité, les PJ avant les
/// créatures (règle du 03/11/2026), puis par nom.
List<String> ordreCombat(
  List<MembreCampagne> joueurs,
  List<CreatureSeance> creatures,
) {
  final liste = [
    for (final m in joueurs) (id: m.uid, init: m.initiative, pj: 0, nom: m.nom),
    for (final c in creatures)
      (id: c.id, init: c.initiative, pj: 1, nom: c.nom),
  ]..sort((a, b) {
      final i = b.init.compareTo(a.init);
      if (i != 0) return i;
      final p = a.pj.compareTo(b.pj);
      return p != 0 ? p : a.nom.compareTo(b.nom);
    });
  return [for (final e in liste) e.id];
}

/// État approximatif d'une créature, seule indication donnée aux PJ.
enum EtatCreature {
  indemne('Indemne'),
  blessee('Blessée'),
  gravement('Gravement blessée'),
  vaincue('Vaincue');

  const EtatCreature(this.libelle);
  final String libelle;

  static EtatCreature depuisCode(Object? c) {
    for (final e in values) {
      if (e.name == c) return e;
    }
    return indemne;
  }

  /// Gravement blessée : 25 % des PV ou moins ; vaincue : 0 PV ou moins.
  static EtatCreature depuisPv(int? pv, int? pvMax) {
    if (pv == null || pvMax == null || pvMax <= 0) return indemne;
    if (pv <= 0) return vaincue;
    if (pv >= pvMax) return indemne;
    return pv * 4 <= pvMax ? gravement : blessee;
  }
}

/// Créature ajoutée à la partie. Côté PJ, [nom] est le nom affiché et ni
/// [creatureId], ni [pv], ni [pvMax] ne sont connus.
class CreatureSeance {
  const CreatureSeance({
    required this.id,
    required this.nom,
    this.creatureId = '',
    this.famille = '',
    this.description = '',
    this.initiative = 0,
    this.pv,
    this.pvMax,
    this.ca,
    this.etat = EtatCreature.indemne,
    this.cachee = false,
    this.nomCache = false,
  });

  /// Nom montré aux PJ quand le MJ cache le vrai nom.
  static const String nomInconnu = 'Créature inconnue';

  final String id;
  final String nom;

  /// Fiche du bestiaire.
  final String creatureId;

  /// Famille du bestiaire : donne l'icône de la carte.
  final String famille;
  final String description;
  final int initiative;
  final int? pv;
  final int? pvMax;

  /// Classe d'armure, comparée aux attaques (visible de tous).
  final int? ca;
  final EtatCreature etat;

  /// Carte invisible des PJ.
  final bool cachee;

  /// Carte visible, mais sous le nom « Créature inconnue ».
  final bool nomCache;

  String get nomPublic => nomCache ? nomInconnu : nom;

  CreatureSeance copie({int? pv, int? ca, bool? cachee, bool? nomCache}) {
    final v = pv ?? this.pv;
    return CreatureSeance(
      id: id,
      nom: nom,
      creatureId: creatureId,
      famille: famille,
      description: description,
      initiative: initiative,
      pv: v,
      pvMax: pvMax,
      ca: ca ?? this.ca,
      etat: EtatCreature.depuisPv(v, pvMax),
      cachee: cachee ?? this.cachee,
      nomCache: nomCache ?? this.nomCache,
    );
  }

  /// Ce qu'un PJ a le droit de savoir, selon les permissions : la fiche
  /// révélerait le nom, elle reste cachée avec lui.
  CreatureSeance pourJoueur(ParametresCampagne p) => CreatureSeance(
        id: id,
        nom: nomPublic,
        creatureId: p.pjVoientFichesCreatures && !nomCache ? creatureId : '',
        famille: nomCache ? '' : famille,
        description: description,
        initiative: initiative,
        pv: p.pjVoientPvCreatures ? pv : null,
        pvMax: p.pjVoientPvCreatures ? pvMax : null,
        ca: ca,
        etat: etat,
        nomCache: nomCache,
      );

  /// Partie lisible par les PJ (si la carte n'est pas cachée).
  Map<String, dynamic> versPublic(ParametresCampagne p) => {
        'nom': nomPublic,
        if (p.pjVoientFichesCreatures && !nomCache) 'creatureId': creatureId,
        if (!nomCache && famille.isNotEmpty) 'famille': famille,
        if (p.pjVoientPvCreatures && pv != null) 'pv': pv,
        if (p.pjVoientPvCreatures && pvMax != null) 'pvMax': pvMax,
        if (ca != null) 'ca': ca,
        'description': description,
        'initiative': initiative,
        'etat': etat.name,
        'cachee': cachee,
        'nomCache': nomCache,
      };

  /// Partie réservée au MJ.
  Map<String, dynamic> versMj() => {
        'nom': nom,
        'creatureId': creatureId,
        if (famille.isNotEmpty) 'famille': famille,
        if (pv != null) 'pv': pv,
        if (pvMax != null) 'pvMax': pvMax,
      };

  /// Créature lue en ligne ; [mj] : partie du MJ, absente côté PJ.
  factory CreatureSeance.depuisDocuments(
    String id,
    Map<String, dynamic> public, [
    Map<String, dynamic>? mj,
  ]) =>
      CreatureSeance(
        id: id,
        nom: (mj?['nom'] ?? public['nom']) as String? ?? nomInconnu,
        creatureId: (mj ?? public)['creatureId'] as String? ?? '',
        famille: (mj ?? public)['famille'] as String? ?? '',
        description: public['description'] as String? ?? '',
        initiative: (public['initiative'] as num?)?.toInt() ?? 0,
        pv: ((mj ?? public)['pv'] as num?)?.toInt(),
        pvMax: ((mj ?? public)['pvMax'] as num?)?.toInt(),
        ca: (public['ca'] as num?)?.toInt(),
        etat: EtatCreature.depuisCode(public['etat']),
        cachee: public['cachee'] as bool? ?? false,
        nomCache: public['nomCache'] as bool? ?? false,
      );
}

/// Nom d'une nouvelle créature : numérotée si elle est déjà dans la partie
/// (Loup, Loup 2, Loup 3).
String nomNumerote(String nom, Iterable<String> existants) {
  final noms = existants.toSet();
  if (!noms.contains(nom)) return nom;
  var n = 2;
  while (noms.contains('$nom $n')) {
    n++;
  }
  return '$nom $n';
}

/// PV, PM et PE d'un personnage, publiés par son joueur pendant la séance.
class RessourcesPj {
  const RessourcesPj({
    required this.pv,
    required this.pvMax,
    this.pm = 0,
    this.pmMax = 0,
    this.pe = 0,
    this.peMax = 0,
  });

  final int pv;
  final int pvMax;
  final int pm;
  final int pmMax;
  final int pe;
  final int peMax;

  @override
  bool operator ==(Object other) =>
      other is RessourcesPj &&
      pv == other.pv &&
      pvMax == other.pvMax &&
      pm == other.pm &&
      pmMax == other.pmMax &&
      pe == other.pe &&
      peMax == other.peMax;

  @override
  int get hashCode => Object.hash(pv, pvMax, pm, pmMax, pe, peMax);

  Map<String, dynamic> versJson() => {
        'pv': pv,
        'pvMax': pvMax,
        'pm': pm,
        'pmMax': pmMax,
        'pe': pe,
        'peMax': peMax,
      };

  factory RessourcesPj.depuisJson(Map<String, dynamic> j) {
    int v(String c) => (j[c] as num?)?.toInt() ?? 0;
    return RessourcesPj(
      pv: v('pv'),
      pvMax: v('pvMax'),
      pm: v('pm'),
      pmMax: v('pmMax'),
      pe: v('pe'),
      peMax: v('peMax'),
    );
  }
}

/// Qui voit le résultat d'un jet.
enum VisibiliteJet {
  tous('Visible de tous'),

  /// PJ : le MJ et lui. Caché aux autres joueurs.
  mjEtAuteur('Caché aux autres joueurs'),

  /// PJ : le MJ seul, le joueur ne voit pas son propre résultat. MJ : secret.
  mjSeul('Visible du MJ seulement'),

  /// MJ : un seul PJ (et le MJ).
  unJoueur('Visible par un seul joueur');

  const VisibiliteJet(this.libelle);
  final String libelle;

  static VisibiliteJet depuisCode(Object? c) {
    for (final v in values) {
      if (v.name == c) return v;
    }
    return tous;
  }
}

/// Comptes qui peuvent lire un jet ; le MJ en fait toujours partie.
List<String> lecteursDuJet(
  Campagne c,
  VisibiliteJet visibilite, {
  required String auteur,
  String? cible,
}) =>
    switch (visibilite) {
      VisibiliteJet.tous => [c.mj, ...c.joueurs],
      VisibiliteJet.mjEtAuteur => {c.mj, auteur}.toList(),
      VisibiliteJet.mjSeul => [c.mj],
      VisibiliteJet.unJoueur => {c.mj, if (cible != null) cible}.toList(),
    };

/// Un jet de dés d'une séance.
/// Nature d'un jet : donne son icône dans les logs de la séance.
enum GenreJet {
  libre('Jet de dés'),
  attaque('Attaque'),
  degats('Dégâts'),
  sort('Sort'),
  test('Test de caractéristique');

  const GenreJet(this.libelle);

  final String libelle;

  static GenreJet depuisCode(Object? code) {
    for (final g in values) {
      if (g.name == code) return g;
    }
    return libre;
  }
}

class JetSeance {
  const JetSeance({
    this.id = '',
    required this.auteur,
    required this.auteurNom,
    required this.libelle,
    required this.detail,
    required this.total,
    required this.date,
    required this.seance,
    required this.lecteurs,
    this.visibilite = VisibiliteJet.tous,
    this.cible = '',
    this.genre = GenreJet.libre,
    this.mode = ModeJeu.exploration,
    this.manche = 1,
    this.attaquant = '',
    this.caCible,
    this.touche,
    this.sansComparaison = '',
  });

  final String id;
  final String auteur;
  final String auteurNom;

  /// « 2d6 », « Test de FOR ».
  final String libelle;

  /// « 3 + 5 + 2 ».
  final String detail;
  final int total;
  final DateTime date;

  /// Numéro de la séance.
  final int seance;
  final List<String> lecteurs;
  final VisibiliteJet visibilite;

  /// Cible d'une attaque ou d'un sort (nom affiché) ; vide : aucune.
  final String cible;
  final GenreJet genre;

  /// Mode de jeu et manche au moment du jet : sections des logs.
  final ModeJeu mode;
  final int manche;

  /// Qui attaque (uid ou id de créature) ; vide : jet sans attaquant.
  final String attaquant;

  /// Attaque comparée à la CA de la cible ; `null` : pas de comparaison.
  final int? caCible;
  final bool? touche;

  /// Attaque qui n'a pas pu être comparée : la raison (« CA inconnue »).
  final String sansComparaison;

  /// « Touché (CA 14) », « Raté (CA 14) », ou pourquoi l'attaque n'a pas été
  /// comparée ; vide : ce jet n'est pas une attaque.
  String get resultatCible => touche == null
      ? sansComparaison
      : '${touche! ? 'Touché' : 'Raté'} (CA $caCible)';

  /// Dés et bonus ou malus séparés : « 3 + 5 +2 » → (« 3 + 5 », « +2 »).
  /// Le modificateur est vide quand il n'y en a pas.
  ({String des, String modificateur}) get decomposition {
    final m = RegExp(r'^(.*\S)\s([+−-]\d+)$').firstMatch(detail);
    return m == null
        ? (des: detail, modificateur: '')
        : (des: m[1]!, modificateur: m[2]!);
  }

  Map<String, dynamic> versJson() => {
        'auteur': auteur,
        'auteurNom': auteurNom,
        'libelle': libelle,
        'detail': detail,
        'total': total,
        'date': date.toIso8601String(),
        'seance': seance,
        'lecteurs': lecteurs,
        'visibilite': visibilite.name,
        if (cible.isNotEmpty) 'cible': cible,
        'genre': genre.name,
        'mode': mode.name,
        'manche': manche,
        if (attaquant.isNotEmpty) 'attaquant': attaquant,
        if (caCible != null) 'caCible': caCible,
        if (touche != null) 'touche': touche,
        if (sansComparaison.isNotEmpty) 'sansComparaison': sansComparaison,
      };

  factory JetSeance.depuisJson(String id, Map<String, dynamic> j) => JetSeance(
        id: id,
        auteur: j['auteur'] as String? ?? '',
        auteurNom: j['auteurNom'] as String? ?? '',
        libelle: j['libelle'] as String? ?? '',
        detail: j['detail'] as String? ?? '',
        total: (j['total'] as num?)?.toInt() ?? 0,
        date: DateTime.tryParse('${j['date']}') ?? DateTime(2026),
        seance: (j['seance'] as num?)?.toInt() ?? 0,
        lecteurs: [for (final u in j['lecteurs'] as List? ?? const []) '$u'],
        visibilite: VisibiliteJet.depuisCode(j['visibilite']),
        cible: j['cible'] as String? ?? '',
        genre: GenreJet.depuisCode(j['genre']),
        mode: ModeJeu.depuisCode(j['mode']),
        manche: (j['manche'] as num?)?.toInt() ?? 1,
        attaquant: j['attaquant'] as String? ?? '',
        caCible: (j['caCible'] as num?)?.toInt(),
        touche: j['touche'] as bool?,
        sansComparaison: j['sansComparaison'] as String? ?? '',
      );
}

/// Attaque contre la CA (règle du 07/11/2026) : total ≥ CA ; un 20 naturel
/// touche toujours, un 1 naturel rate toujours.
bool attaqueTouche({
  required int naturel,
  required int total,
  required int ca,
}) =>
    naturel == 20 || (naturel != 1 && total >= ca);

/// Dégâts à appliquer, en attente chez celui qui peut les écrire : le joueur
/// pour sa propre fiche, le MJ pour une créature.
class DegatsSeance {
  const DegatsSeance({
    this.id = '',
    required this.cible,
    required this.destinataire,
    required this.auteur,
    required this.montant,
    required this.source,
    this.type = 'physique',
  });

  final String id;

  /// uid du joueur, ou id de la créature.
  final String cible;

  /// Compte qui applique les dégâts.
  final String destinataire;
  final String auteur;
  final int montant;

  /// « Loup · Morsure · dégâts ».
  final String source;

  /// Type de dégâts, comparé à la RD de la cible.
  final String type;

  Map<String, dynamic> versJson() => {
        'cible': cible,
        'destinataire': destinataire,
        'auteur': auteur,
        'montant': montant,
        'source': source,
        'type': type,
      };

  factory DegatsSeance.depuisJson(String id, Map<String, dynamic> j) =>
      DegatsSeance(
        id: id,
        cible: j['cible'] as String? ?? '',
        destinataire: j['destinataire'] as String? ?? '',
        auteur: j['auteur'] as String? ?? '',
        montant: (j['montant'] as num?)?.toInt() ?? 0,
        source: j['source'] as String? ?? '',
        type: j['type'] as String? ?? 'physique',
      );
}

/// Présence d'un joueur dans la séance : son application le signale à
/// intervalles réguliers tant que la séance est ouverte. Sans nouvelle
/// depuis [delaiAbsence] (app fermée, plus de connexion) : absent.
class PresenceSeance {
  const PresenceSeance({required this.vu, this.present = true});

  /// Intervalle entre deux signaux.
  static const Duration intervalle = Duration(seconds: 45);
  static const Duration delaiAbsence = Duration(minutes: 2);

  final DateTime vu;

  /// `false` : le joueur a quitté la séance.
  final bool present;

  bool estLa(DateTime maintenant) =>
      present && maintenant.difference(vu) < delaiAbsence;

  Map<String, dynamic> versJson() => {
        'vu': vu.toIso8601String(),
        'present': present,
      };

  factory PresenceSeance.depuisJson(Map<String, dynamic> j) => PresenceSeance(
        vu: DateTime.tryParse('${j['vu']}') ?? DateTime(2026),
        present: j['present'] as bool? ?? false,
      );
}

/// Message privé entre le MJ et un joueur.
class MessageSeance {
  const MessageSeance({
    this.id = '',
    required this.de,
    required this.joueur,
    required this.mj,
    required this.texte,
    required this.date,
  });

  final String id;

  /// Compte qui écrit.
  final String de;

  /// Joueur de la conversation.
  final String joueur;

  /// MJ de la campagne.
  final String mj;
  final String texte;
  final DateTime date;

  Map<String, dynamic> versJson() => {
        'de': de,
        'joueur': joueur,
        'mj': mj,
        'participants': [mj, joueur],
        'texte': texte,
        'date': date.toIso8601String(),
      };

  factory MessageSeance.depuisJson(String id, Map<String, dynamic> j) =>
      MessageSeance(
        id: id,
        de: j['de'] as String? ?? '',
        joueur: j['joueur'] as String? ?? '',
        mj: j['mj'] as String? ?? '',
        texte: j['texte'] as String? ?? '',
        date: DateTime.tryParse('${j['date']}') ?? DateTime(2026),
      );
}
