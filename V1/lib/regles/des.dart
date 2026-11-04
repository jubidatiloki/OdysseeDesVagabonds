import 'dart:math';

final Random _aleatoire = Random();

/// Lance un dé à [faces] faces (résultat entre 1 et [faces]).
int lancerDe(int faces, {Random? aleatoire}) =>
    (aleatoire ?? _aleatoire).nextInt(faces) + 1;

/// Mode d'un jet de d20 : normal (1 dé), avantage ou désavantage (2 dés).
enum ModeLancer {
  normal('Normal'),
  avantage('Avantage'),
  desavantage('Désavantage');

  const ModeLancer(this.libelle);
  final String libelle;
}

/// Résultat d'un lancer de d20 seul (sans bonus).
class LancerD20 {
  LancerD20(this.mode, this.des)
      : garde = switch (mode) {
          ModeLancer.normal => des.first,
          ModeLancer.avantage => des.reduce(max),
          ModeLancer.desavantage => des.reduce(min),
        };

  final ModeLancer mode;
  final List<int> des;
  final int garde;

  bool get reussiteCritique => garde == 20;
  bool get echecCritique => garde == 1;

  /// Ex. « Avantage : 7 et 15 ».
  String get detail => mode == ModeLancer.normal
      ? 'd20 : $garde'
      : '${mode.libelle} : ${des.join(' et ')}';

  static LancerD20 lancer(ModeLancer mode, {Random? aleatoire}) => LancerD20(
        mode,
        [
          for (var i = 0; i < (mode == ModeLancer.normal ? 1 : 2); i++)
            lancerDe(20, aleatoire: aleatoire),
        ],
      );
}

/// « 1d8 », « 2d6 », « d20 », « 1d8+1 » → nombre de dés, faces et bonus
/// éventuel ; `null` si le texte n'est pas une formule de dés.
({int nombre, int faces, int bonus})? lireDes(String texte) {
  final m = RegExp(r'^\s*(\d*)\s*[dD]\s*(\d+)\s*(?:([+−-])\s*(\d+))?')
      .firstMatch(texte);
  if (m == null) return null;
  final nombre = m.group(1)!.isEmpty ? 1 : int.parse(m.group(1)!);
  final faces = int.parse(m.group(2)!);
  if (nombre < 1 || nombre > 100 || faces < 2) return null;
  final valeur = m.group(4) == null ? 0 : int.parse(m.group(4)!);
  return (
    nombre: nombre,
    faces: faces,
    bonus: m.group(3) == '+' ? valeur : -valeur,
  );
}

/// Formule à plusieurs groupes de dés : « 1d8 + 1d6 + 3 », « 2d6 − 1 ».
/// Le texte après la formule (« phy », « feu ») est ignoré. `null` si le
/// texte ne commence pas par des dés.
({List<({int nombre, int faces})> groupes, int bonus})? lireFormule(
  String texte,
) {
  final debut = RegExp(r'^\s*\d*\s*[dD]\s*\d+').firstMatch(texte);
  if (debut == null) return null;
  final groupes = <({int nombre, int faces})>[];
  var bonus = 0;
  // Termes successifs : « 1d8 », « + 1d6 », « + 3 », « − 1 ».
  final terme = RegExp(r'\s*([+−-])?\s*(\d*)\s*([dD])?\s*(\d+)');
  var position = 0;
  var premier = true;
  while (position < texte.length) {
    final m = terme.matchAsPrefix(texte, position);
    if (m == null || (!premier && m.group(1) == null)) break;
    final negatif = m.group(1) == '-' || m.group(1) == '−';
    if (m.group(3) != null) {
      final n = m.group(2)!.isEmpty ? 1 : int.parse(m.group(2)!);
      final f = int.parse(m.group(4)!);
      if (n < 1 || n > 100 || f < 2 || negatif) return null;
      groupes.add((nombre: n, faces: f));
    } else {
      final v = int.parse('${m.group(2)}${m.group(4)}');
      bonus += negatif ? -v : v;
    }
    premier = false;
    position = m.end;
  }
  if (groupes.isEmpty) return null;
  return (groupes: groupes, bonus: bonus);
}

/// Bonus d'une situation cochée : trait d'origine et valeur.
typedef BonusSituation = ({String nom, int valeur});

/// « +3 », « −2 » (signe moins typographique).
String _signe(int v) => v >= 0 ? '+$v' : '−${-v}';

/// Un lancer de l'historique : test de caractéristique, toucher, dégâts,
/// initiative ou d20 libre, avec le personnage qui l'a fait.
class ResultatLancer {
  ResultatLancer({
    required this.libelle,
    required this.formule,
    required this.des,
    required this.garde,
    this.bonus = 0,
    this.modificateur = 0,
    this.situations = const [],
    this.origineBonus = '',
    this.origineMode = '',
    this.difficulte,
    this.mode = ModeLancer.normal,
    this.d20 = false,
    this.personnage,
    this.seuilCritique = 20,
    this.seuilEchec = 1,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  /// Résultat naturel minimal d'une réussite critique (19 : critique sur
  /// 19-20 avec l'arme familiale légendaire).
  final int seuilCritique;

  /// Résultat naturel maximal d'un échec critique (2 : échec sur 1-2 avec la
  /// Rune de précision du moine).
  final int seuilEchec;

  /// « Test de FOR », « Toucher CaC », « Dégâts · Bâton », « d20 ».
  final String libelle;

  /// Formule lancée, sans le modificateur libre : « 1d20 +3 », « 1d8 +3 ».
  final String formule;

  /// Tous les dés lancés (2 pour un d20 avec avantage).
  final List<int> des;

  /// Somme des dés retenus.
  final int garde;

  /// Bonus du personnage (modificateur de stat…).
  final int bonus;

  /// Modificateur libre choisi au moment du lancer (MJ…).
  final int modificateur;

  /// Bonus des situations cochées, avec leur trait (« Vision elfique » +1).
  final List<BonusSituation> situations;

  /// D'où vient [bonus] : la caractéristique (« CON », « AdC »).
  final String origineBonus;

  /// Pourquoi avantage / désavantage (« Harmonie avec la nature », « choisi »).
  final String origineMode;

  /// Total des situations.
  int get situation => situations.fold(0, (n, s) => n + s.valeur);

  /// Difficulté à atteindre (`null` : pas de réussite / échec).
  final int? difficulte;
  final ModeLancer mode;

  /// Jet de d20 : 20 naturel = réussite critique, 1 = échec critique.
  final bool d20;

  /// Nom du personnage (`null` : lancer libre).
  final String? personnage;
  final DateTime date;

  int get total => garde + bonus + modificateur + situation;

  /// Ce lancer avec le total divisé par [diviseur] (arrondi à l'inférieur),
  /// noté « −4 (÷2) » dans le détail (Coup de boucher).
  ResultatLancer divise(int diviseur) {
    if (diviseur <= 1) return this;
    return _ajuste(total ~/ diviseur - total, '÷$diviseur');
  }

  /// Ce lancer avec le total multiplié par [facteur], noté « +6 (×2) »
  /// (Lumière sacrée contre les morts-vivants).
  ResultatLancer multiplie(int facteur) {
    if (facteur <= 1) return this;
    return _ajuste(total * facteur - total, '×$facteur');
  }

  ResultatLancer _ajuste(int ecart, String nom) {
    return ResultatLancer(
      libelle: libelle,
      formule: formule,
      des: des,
      garde: garde,
      bonus: bonus,
      modificateur: modificateur,
      situations: [...situations, (nom: nom, valeur: ecart)],
      origineBonus: origineBonus,
      origineMode: origineMode,
      difficulte: difficulte,
      mode: mode,
      d20: d20,
      personnage: personnage,
      seuilCritique: seuilCritique,
      seuilEchec: seuilEchec,
      date: date,
    );
  }

  bool get reussiteCritique => d20 && garde >= seuilCritique;
  bool get echecCritique => d20 && garde <= seuilEchec;

  /// Réussite contre la [difficulte] : total ≥ difficulté ; un 20 naturel
  /// réussit et un 1 naturel échoue toujours. `null` sans difficulté.
  bool? get reussite {
    final d = difficulte;
    if (d == null) return null;
    if (reussiteCritique) return true;
    if (echecCritique) return false;
    return total >= d;
  }

  /// « 1d20 : 14 +3 = 17 », « Avantage : 7 et 15 → 15 +3 = 18 »,
  /// « 2d6 : 3 + 4 = 7 », « 1d20 : 14 +3 +2 (modif.) = 19 ».
  String get detail {
    final String partieDes;
    if (mode != ModeLancer.normal) {
      final raison = origineMode.isEmpty || origineMode == 'choisi'
          ? ''
          : ' ($origineMode)';
      partieDes = '${mode.libelle}$raison : ${des.join(' et ')} → $garde';
    } else {
      final nom = formule.split(' ').first;
      partieDes = '$nom : ${des.join(' + ')}';
    }
    final ajouts = [
      if (bonus != 0)
        origineBonus.isEmpty
            ? _signe(bonus)
            : '${_signe(bonus)} ($origineBonus)',
      if (modificateur != 0) '${_signe(modificateur)} (modif.)',
      for (final s in situations)
        if (s.valeur != 0) '${_signe(s.valeur)} (${s.nom})',
    ];
    final calcul = ajouts.isEmpty
        ? (des.length > 1 && !d20 ? '$partieDes = $total' : partieDes)
        : '$partieDes ${ajouts.join(' ')} = $total';
    final r = reussite;
    if (r == null) return calcul;
    return '$calcul · ${r ? 'réussite' : 'échec'} (diff. $difficulte)';
  }

  /// Lance [de] (« 1d20 », « 1d8 », « 2d6+1 », « 1d8 + 1d6 ») et ajoute
  /// [bonus], le [modificateur] libre et le bonus de [situation]. Un d20
  /// seul suit le [mode] (avantage / désavantage) ; `null` si [de] n'est
  /// pas une formule de dés. [modeTousDes] : un dé seul de n'importe quel
  /// type (d4 à d100, lancer libre) suit aussi le [mode] ; seul le d20 a
  /// des critiques.
  static ResultatLancer? lancer({
    required String libelle,
    required String de,
    int bonus = 0,
    int modificateur = 0,
    List<BonusSituation> situations = const [],
    String origineBonus = '',
    String origineMode = '',
    int? difficulte,
    ModeLancer mode = ModeLancer.normal,
    String? personnage,
    Random? aleatoire,
    bool modeTousDes = false,
    int seuilCritique = 20,
    int seuilEchec = 1,
  }) {
    final f = lireFormule(de);
    if (f == null) return null;
    final total = bonus + f.bonus;
    final unSeul = f.groupes.length == 1 && f.groupes.single.nombre == 1;
    final estD20 = unSeul && f.groupes.single.faces == 20;
    final des = f.groupes.map((g) => '${g.nombre}d${g.faces}').join('+');
    final formule = '$des${total == 0 ? '' : ' ${_signe(total)}'}';
    if (estD20 || (unSeul && modeTousDes)) {
      final faces = f.groupes.single.faces;
      final lances = [
        for (var i = 0; i < (mode == ModeLancer.normal ? 1 : 2); i++)
          lancerDe(faces, aleatoire: aleatoire),
      ];
      return ResultatLancer(
        libelle: libelle,
        formule: formule,
        des: lances,
        garde: switch (mode) {
          ModeLancer.normal => lances.first,
          ModeLancer.avantage => lances.reduce(max),
          ModeLancer.desavantage => lances.reduce(min),
        },
        bonus: total,
        modificateur: modificateur,
        situations: situations,
        origineBonus: origineBonus,
        origineMode: origineMode,
        difficulte: difficulte,
        mode: mode,
        d20: estD20,
        personnage: personnage,
        seuilCritique: estD20 ? seuilCritique : 20,
        seuilEchec: estD20 ? seuilEchec : 1,
      );
    }
    final resultats = [
      for (final g in f.groupes)
        for (var i = 0; i < g.nombre; i++)
          lancerDe(g.faces, aleatoire: aleatoire),
    ];
    return ResultatLancer(
      libelle: libelle,
      formule: formule,
      des: resultats,
      garde: resultats.fold(0, (a, b) => a + b),
      bonus: total,
      modificateur: modificateur,
      situations: situations,
      origineBonus: origineBonus,
      difficulte: difficulte,
      personnage: personnage,
    );
  }
}

/// Type de dégâts écrit dans un texte (« 3d6 feu », « 1d4 mag ») ; physique
/// par défaut. Types comparés à la réduction de dégâts ; le chaos l'ignore.
String typeDegatsDepuis(String texte) {
  final t = texte.toLowerCase();
  for (final (mot, type) in const [
    ('chaos', 'chaos'),
    ('feu', 'feu'),
    ('glace', 'glace'),
    ('foudre', 'foudre'),
    ('mag', 'magique'),
  ]) {
    if (RegExp('\\b$mot').hasMatch(t)) return type;
  }
  return 'physique';
}
