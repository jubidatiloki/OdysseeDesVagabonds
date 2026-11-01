import 'carac.dart';

/// Un effet détaillé d'un passif ou d'une compétence (champ `effets` des
/// données). Exemples :
/// `{"type": "maitrise", "categorie": "langue", "valeur": "Elfique"}`,
/// `{"type": "bonus", "carac": "SOC", "valeur": 2, "condition": "..."}`,
/// `{"type": "test", "categorie": "MEN", "valeur": 5, "condition": "..."}`.
/// Les champs sont tous facultatifs : un type inconnu est affiché avec ce qui
/// est renseigné (nom, effet, valeur, condition).
class Effet {
  const Effet({
    this.type = '',
    this.categorie = '',
    this.carac,
    this.valeur = '',
    this.condition = '',
    this.nom = '',
    this.texte = '',
    this.typeCompetence = '',
    this.sousEffets = const [],
    this.si = '',
    this.rangMin,
    this.rangMax,
  });

  /// Effet actif seulement à partir de ce rang atteint dans la voie (trait
  /// de l'arme familiale : niveau II au rang 3) ; `null` : toujours.
  final int? rangMin;

  /// Effet actif seulement jusqu'à ce rang (remplacé ensuite par un plus
  /// fort) ; `null` : sans limite.
  final int? rangMax;

  /// Actif au rang [rang] atteint dans la voie ?
  bool actifAuRang(int rang) =>
      (rangMin == null || rang >= rangMin!) &&
      (rangMax == null || rang <= rangMax!);

  /// maitrise, bonus, test, avantage, renforcement, texte…
  final String type;
  final String categorie;

  /// Caractéristique visée (champ `carac`, ou `categorie` si c'est un code
  /// de caractéristique comme « SOC »).
  final Carac? carac;
  final String valeur;
  final String condition;
  final String nom;

  /// Texte libre (champs `texte`, `effet` ou `description`).
  final String texte;

  /// Type de compétence d'un renforcement (« gratuit, 2×/jour »).
  final String typeCompetence;

  /// Effets détaillés d'un renforcement (champ `effets` imbriqué : nouveaux
  /// bonus de la compétence améliorée).
  final List<Effet> sousEffets;

  /// Condition calculée par l'app (`arme-non-metallique`,
  /// `sans-armure-metallique`) ; `condition` reste le texte affiché.
  final String si;

  /// Type sans accents ni majuscules (« maîtrise » → « maitrise »).
  String get typeNormalise => _sansAccents(type);
  String get categorieNormalisee => _sansAccents(categorie);

  factory Effet.depuisJson(Map<String, dynamic> j) {
    String chaine(String cle) => j[cle] == null ? '' : '${j[cle]}'.trim();
    final carac = Carac.depuisCode(chaine('carac')) ??
        Carac.depuisCode(chaine('categorie'));
    return Effet(
      type: chaine('type'),
      categorie: chaine('categorie'),
      carac: carac,
      valeur: chaine('valeur'),
      condition: chaine('condition'),
      nom: chaine('nom'),
      texte: [chaine('texte'), chaine('effet'), chaine('description')]
          .firstWhere((t) => t.isNotEmpty, orElse: () => ''),
      typeCompetence: chaine('typeCompetence'),
      sousEffets: listeDepuisJson(j['effets']),
      si: chaine('si'),
      rangMin: int.tryParse(chaine('rangMin')),
      rangMax: int.tryParse(chaine('rangMax')),
    );
  }

  /// Pour sauvegarder un effet (effets d'un objet de l'inventaire).
  Map<String, dynamic> versJson() => {
        if (type.isNotEmpty) 'type': type,
        if (categorie.isNotEmpty) 'categorie': categorie,
        if (carac != null && categorie.isEmpty) 'carac': carac!.code,
        if (valeur.isNotEmpty) 'valeur': valeur,
        if (condition.isNotEmpty) 'condition': condition,
        if (nom.isNotEmpty) 'nom': nom,
        if (texte.isNotEmpty) 'effet': texte,
        if (typeCompetence.isNotEmpty) 'typeCompetence': typeCompetence,
        if (si.isNotEmpty) 'si': si,
        if (rangMin != null) 'rangMin': rangMin,
        if (rangMax != null) 'rangMax': rangMax,
        if (sousEffets.isNotEmpty)
          'effets': [for (final e in sousEffets) e.versJson()],
      };

  /// Copie avec `{precision}` remplacé dans la valeur, la condition et le
  /// texte (« Maîtrise : {precision} » → « Maîtrise : Luth »).
  Effet avecPrecision(String precision) {
    String r(String s) => s.replaceAll('{precision}', precision);
    return Effet(
      type: type,
      categorie: categorie,
      carac: carac,
      valeur: r(valeur),
      condition: r(condition),
      nom: r(nom),
      texte: r(texte),
      typeCompetence: typeCompetence,
      sousEffets: sousEffets,
      si: si,
      rangMin: rangMin,
      rangMax: rangMax,
    );
  }

  /// Copie avec `{precision:cle}` remplacé par la précision du choix `cle`
  /// (l'arme familiale nommée au rang 2, reprise aux rangs 4 et 5).
  Effet avecPrecisions(Map<String, String> precisions) {
    final motif = RegExp(r'\{precision:([^}]+)\}');
    String r(String s) =>
        s.replaceAllMapped(motif, (m) => precisions[m.group(1)!] ?? '');
    if (!'$valeur$condition$nom$texte'.contains('{precision:')) return this;
    return Effet(
      type: type,
      categorie: categorie,
      carac: carac,
      valeur: r(valeur),
      condition: r(condition),
      nom: r(nom),
      texte: r(texte),
      typeCompetence: typeCompetence,
      sousEffets: sousEffets,
      si: si,
      rangMin: rangMin,
      rangMax: rangMax,
    );
  }

  /// Copie avec une autre valeur (« FOR » → « 3 », « RANG » → « 2 »).
  Effet avecValeur(String v) => Effet(
        type: type,
        categorie: categorie,
        carac: carac,
        valeur: v,
        condition: condition,
        nom: nom,
        texte: texte,
        typeCompetence: typeCompetence,
        sousEffets: sousEffets,
        si: si,
        rangMin: rangMin,
        rangMax: rangMax,
      );

  /// Copie avec « RANG » (rang atteint dans la voie) remplacé dans la valeur
  /// (Légèreté animale : CA + RANG).
  /// « RANG x2 » / « 2×RANG » : le produit (+2 par rang : 6 au rang 3).
  Effet avecRang(int rang) {
    if (!valeur.contains('RANG')) return this;
    final v = valeur.replaceAll('RANG', '$rang');
    final m = RegExp(r'^\s*(\d+)\s*[×xX*]\s*(\d+)\s*$').firstMatch(v);
    return avecValeur(
        m == null ? v : '${int.parse(m.group(1)!) * int.parse(m.group(2)!)}');
  }

  static List<Effet> listeDepuisJson(Object? json) => json is List
      ? [
          for (final e in json)
            if (e is Map<String, dynamic>) Effet.depuisJson(e),
        ]
      : const [];

  /// Valeur numérique (« +2 », « 2 », « -1 », « −1 »), sinon `null`.
  int? get valeurEntiere => int.tryParse(
        valeur.replaceAll('+', '').replaceAll('−', '-').trim(),
      );

  /// Bonus permanent d'une caractéristique : ajouté à sa valeur sur la
  /// fiche (« +2 SOC » sans condition).
  bool get estBonusCarac =>
      (typeNormalise == 'bonus' || typeNormalise == 'malus') &&
      carac != null &&
      condition.isEmpty &&
      valeurEntiere != null;

  /// Bonus au lancer de dés seulement (tests, avantage, bonus
  /// situationnel avec une condition). Un bonus sans condition qui ne vise
  /// pas une caractéristique (« +2 RD phy ») n'en est pas un.
  bool get estBonusTest =>
      typeNormalise == 'test' ||
      typeNormalise == 'avantage' ||
      ((typeNormalise == 'bonus' || typeNormalise == 'malus') &&
          !estBonusCarac &&
          (carac != null || condition.isNotEmpty));

  /// Amélioration d'une compétence existante (« adaptabilité (niveau 2) »).
  bool get estRenforcement => typeNormalise == 'renforcement';

  /// Nom sans le niveau ni les accents : « Adaptabilité (niveau 2) » →
  /// « adaptabilite ». Sert à relier un renforcement à sa compétence.
  static String nomDeBase(String nom) => _sansAccents(
        nom.replaceAll(
            RegExp(r'\(\s*niveau\s*\d+\s*\)', caseSensitive: false), ''),
      );

  /// Valeur signée : « 2 » → « +2 », « -1 » → « −1 ».
  String get _valeurSignee {
    final n = int.tryParse(valeur.replaceAll('+', ''));
    if (n == null) return valeur;
    return n < 0 ? '−${-n}' : '+$n';
  }

  String get _cible => carac?.abrev ?? categorie;

  String get _suffixeCondition => condition.isEmpty ? '' : ' $condition';

  /// Texte lisible de l'effet, avec le rang de voie qui le débloque
  /// (« … (dès le rang 3) »).
  String get libelle {
    final base = _libelleBase;
    if (rangMin != null) return '$base (dès le rang $rangMin)';
    if (rangMax != null) return '$base (jusqu\'au rang $rangMax)';
    return base;
  }

  /// Texte lisible de l'effet.
  String get _libelleBase {
    switch (typeNormalise) {
      case 'maitrise':
        if (categorie.isEmpty) return 'Maîtrise : $valeur';
        return '${_majuscule(categorie.replaceAll('-', ' '))} : $valeur';
      case 'bonus':
      case 'malus':
        return '$_valeurSignee $_cible$_suffixeCondition'.trim();
      case 'test':
        final cond = condition.isEmpty ? '' : ' ($condition)';
        // Initiative (Vie sylvestre : +3 entouré de végétation).
        if (carac == null && categorieNormalisee == 'init') {
          return '$_valeurSignee à l\'initiative$cond';
        }
        // Sans caractéristique : « +1 aux tests (se trouve en forêt) ».
        final tests = _cible.isEmpty ? 'aux tests' : 'aux tests de $_cible';
        return '$_valeurSignee $tests$cond'.trim();
      case 'avantage':
        final cond = condition.isEmpty ? '' : ' ($condition)';
        final tests = _cible.isEmpty ? 'aux tests' : 'aux tests de $_cible';
        return 'Avantage $tests$cond';
      case 'texte':
        return texte.isNotEmpty ? texte : valeur;
      case 'degats':
        // « +1d6 aux dégâts (armes non métalliques) »
        final cond = condition.isEmpty ? '' : ' ($condition)';
        final v = valeur.startsWith('+') || valeur.startsWith('-')
            ? valeur
            : '+$valeur';
        // Catégorie « DIST » : dégâts à distance seulement (Proie favorite).
        final portee = categorieNormalisee == 'dist' ? ' à distance' : '';
        return '$v aux dégâts$portee$cond';
      case 'toucher':
        // « +1 au toucher avec : Épée longue »
        return '$_valeurSignee au toucher'
            '${condition.isEmpty ? '' : ' avec : $condition'}';
      case 'instrument':
        return '$_valeurSignee pour jouer'
            '${condition.isEmpty ? '' : ' : $condition'}';
      case 'ca':
      case 'esquive':
        // « +3 CA au CaC (en 1 contre 1) » : CA contre ce type d'attaque ;
        // « +2 Esquive » : effet `esquive` sans catégorie.
        final cond = condition.isEmpty ? '' : ' ($condition)';
        final contre = switch (categorieNormalisee) {
          'cac' => ' au CaC',
          'dist' => ' à distance',
          'mag' => ' contre les sorts',
          '' => '',
          _ => ' $categorie',
        };
        if (typeNormalise == 'esquive' && categorie.isEmpty) {
          return '$_valeurSignee Esquive$cond';
        }
        return '$_valeurSignee CA$contre$cond';
      case 'chute':
        // « Aucun dégât de chute jusqu'à 12 m » (Bond du chat : RANG × 3).
        return 'Aucun dégât de chute jusqu\'à $valeur m';
      case 'mouvement':
        // Insaisissable : une action de mouvement de plus par tour.
        return '$_valeurSignee action de mouvement par tour';
      case 'titre':
        // « Comte|Comtesse » → « Comte / Comtesse »
        return 'Titre : ${valeur.split('|').map((t) => t.trim()).join(' / ')}';
      case 'aptitude':
        // « Aptitude offerte : Équitation »
        return 'Aptitude offerte : ${nom.isEmpty ? valeur : nom}';
      case 'savoir':
        // « +2 aux tests de : Faune » (Éducation du chevalier) ; à cocher :
        // « +5 aux tests de : Discrétion (en nature) ».
        if (categorie.isNotEmpty) {
          return '$_valeurSignee aux tests de : $categorie'
              '${condition.isEmpty ? '' : ' ($condition)'}';
        }
        return '$_valeurSignee aux tests de : $condition';
      case 'usage':
        // « Faire jouer son titre : 4×/aventure »
        return '${nom.isEmpty ? 'Utilisation' : _majuscule(nom)} : '
            '$valeur×${condition.isEmpty ? '' : ' $condition'}'
            '${texte.isEmpty ? '' : ' — $texte'}';
      case 'echec-critique':
        // Rune de précision : « Échec critique sur 1-2 »
        return 'Échec critique sur 1-$valeur';
      case 'mains-nues':
        // Pugilat : « Mains nues : 1d6 + FOR »
        return 'Mains nues : $valeur + FOR';
      case 'cout-mana':
        // Artéfact magique : « −1 PM sur les sorts de la voie (min. 1) »
        return '$_valeurSignee PM sur les sorts de la voie (min. 1)';
      case 'critique':
        // « Critique sur 19-20 avec : Épée longue »
        return 'Critique sur $valeur-20'
            '${condition.isEmpty ? '' : ' avec : $condition'}';
      case 'deplacement':
        // « +5 m de déplacement par action de mouvement »
        return '$_valeurSignee m de déplacement par action de mouvement';
      case 'passif':
        // « +5 FOR (FOR virtuelle pour le poids porté) », ou le texte.
        if (texte.isNotEmpty) return texte;
        final cond = condition.isEmpty ? '' : ' ($condition)';
        return '$_valeurSignee $_cible$cond'.trim();
      case 'renforcement':
        // Compétence améliorée : « Améliore Adaptabilité (niveau 2) ·
        // gratuit, 2×/jour : Relance un test raté. » (ou ses effets
        // détaillés, séparés par « ; »).
        final type = typeCompetence.isEmpty ? '' : ' · $typeCompetence';
        final details = texte.isNotEmpty
            ? texte
            : sousEffets.map((e) => e.libelle).join(' ; ');
        final effet = details.isEmpty ? '' : ' : $details';
        return 'Améliore ${_majuscule(nom)}$type$effet'.trim();
    }
    // Type inconnu ou renforcement : on assemble ce qui est renseigné.
    final titre = nom.isNotEmpty
        ? _majuscule(nom)
        : (type.isNotEmpty ? _majuscule(type) : '');
    final details = [
      if (typeCompetence.isNotEmpty) '($typeCompetence)',
      if (texte.isNotEmpty) texte,
      if (texte.isEmpty && valeur.isNotEmpty) '$valeur ${_cible.trim()}'.trim(),
      if (condition.isNotEmpty) condition,
    ].join(' ');
    if (titre.isEmpty) return details;
    if (details.isEmpty) return titre;
    return '$titre : $details';
  }
}

String _majuscule(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _sansAccents(String s) {
  const accents = {
    'à': 'a',
    'â': 'a',
    'ç': 'c',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'ô': 'o',
    'ù': 'u',
    'û': 'u',
  };
  final b = StringBuffer();
  for (final ch in s.trim().toLowerCase().split('')) {
    b.write(accents[ch] ?? ch);
  }
  return b.toString();
}
