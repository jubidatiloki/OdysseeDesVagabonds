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
  });

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
    );
  }

  Map<String, dynamic> versJson() => {
        'mode': mode.name,
        'ordre': ordre,
        'index': index,
        'manche': manche,
      };

  factory EtatJeu.depuisJson(Object? j) {
    if (j is! Map) return const EtatJeu();
    return EtatJeu(
      mode: ModeJeu.depuisCode(j['mode']),
      ordre: [for (final o in j['ordre'] as List? ?? const []) '$o'],
      index: (j['index'] as num?)?.toInt() ?? 0,
      manche: (j['manche'] as num?)?.toInt() ?? 1,
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
    this.description = '',
    this.initiative = 0,
    this.pv,
    this.pvMax,
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
  final String description;
  final int initiative;
  final int? pv;
  final int? pvMax;
  final EtatCreature etat;

  /// Carte invisible des PJ.
  final bool cachee;

  /// Carte visible, mais sous le nom « Créature inconnue ».
  final bool nomCache;

  String get nomPublic => nomCache ? nomInconnu : nom;

  CreatureSeance copie({int? pv, bool? cachee, bool? nomCache}) {
    final v = pv ?? this.pv;
    return CreatureSeance(
      id: id,
      nom: nom,
      creatureId: creatureId,
      description: description,
      initiative: initiative,
      pv: v,
      pvMax: pvMax,
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
        description: description,
        initiative: initiative,
        pv: p.pjVoientPvCreatures ? pv : null,
        pvMax: p.pjVoientPvCreatures ? pvMax : null,
        etat: etat,
        nomCache: nomCache,
      );

  /// Partie lisible par les PJ (si la carte n'est pas cachée).
  Map<String, dynamic> versPublic(ParametresCampagne p) => {
        'nom': nomPublic,
        if (p.pjVoientFichesCreatures && !nomCache) 'creatureId': creatureId,
        if (p.pjVoientPvCreatures && pv != null) 'pv': pv,
        if (p.pjVoientPvCreatures && pvMax != null) 'pvMax': pvMax,
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
        description: public['description'] as String? ?? '',
        initiative: (public['initiative'] as num?)?.toInt() ?? 0,
        pv: ((mj ?? public)['pv'] as num?)?.toInt(),
        pvMax: ((mj ?? public)['pvMax'] as num?)?.toInt(),
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
      );
}

/// Taille des trois portions de la séance (fractions de la largeur) : chaque
/// portion garde au moins [kPortionMin]. La portion [changee] (0 gauche,
/// 1 centre, 2 droite) prend la valeur voulue, les deux autres se partagent
/// le reste en gardant leur proportion.
const double kPortionMin = 0.15;

({double gauche, double droite}) ajusterPortions(
  double gauche,
  double droite, {
  required int changee,
  required double valeur,
}) {
  final parts = [gauche, 1 - gauche - droite, droite];
  final v = valeur.clamp(kPortionMin, 1 - 2 * kPortionMin);
  final autres = [0, 1, 2].where((i) => i != changee).toList();
  final somme = parts[autres[0]] + parts[autres[1]];
  final reste = 1 - v;
  var a = somme <= 0 ? reste / 2 : reste * parts[autres[0]] / somme;
  a = a.clamp(kPortionMin, reste - kPortionMin);
  parts[changee] = v;
  parts[autres[0]] = a;
  parts[autres[1]] = reste - a;
  return (gauche: parts[0], droite: parts[2]);
}
