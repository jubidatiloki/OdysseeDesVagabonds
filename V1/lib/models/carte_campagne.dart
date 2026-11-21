/// Carte (plan, région, donjon…) d'une campagne, importée par le MJ
/// (16/11/2026). L'image (JPEG réduit) est rangée à part, en un ou
/// plusieurs morceaux, et n'est lue qu'à l'ouverture de la carte : la liste
/// des cartes reste légère.
class CarteCampagne {
  const CarteCampagne({
    required this.id,
    required this.nom,
    required this.largeur,
    required this.hauteur,
    required this.octets,
    this.morceaux = 1,
    this.diffusee = false,
    required this.ajouteeLe,
  });

  /// Nombre maximum de cartes par campagne.
  static const int maxParCampagne = 30;

  /// Longueur maximum d'un nom.
  static const int longueurNomMax = 80;

  final String id;
  final String nom;

  /// Taille de l'image, en pixels.
  final int largeur;
  final int hauteur;

  /// Poids de l'image, en octets.
  final int octets;

  /// Nombre de morceaux où l'image est rangée.
  final int morceaux;

  /// Montrée aux PJ pendant la séance.
  final bool diffusee;
  final DateTime ajouteeLe;

  /// « 1600 × 1200 · 420 Ko ».
  String get resume => '$largeur × $hauteur · ${(octets / 1024).round()} Ko';

  CarteCampagne copie({String? nom, bool? diffusee}) => CarteCampagne(
        id: id,
        nom: nom ?? this.nom,
        largeur: largeur,
        hauteur: hauteur,
        octets: octets,
        morceaux: morceaux,
        diffusee: diffusee ?? this.diffusee,
        ajouteeLe: ajouteeLe,
      );

  Map<String, dynamic> versJson() => {
        'nom': nom,
        'largeur': largeur,
        'hauteur': hauteur,
        'octets': octets,
        'morceaux': morceaux,
        'diffusee': diffusee,
        'ajouteeLe': ajouteeLe.toIso8601String(),
      };

  factory CarteCampagne.depuisJson(String id, Map<String, dynamic> j) =>
      CarteCampagne(
        id: id,
        nom: j['nom'] as String? ?? 'Carte',
        largeur: (j['largeur'] as num?)?.toInt() ?? 0,
        hauteur: (j['hauteur'] as num?)?.toInt() ?? 0,
        octets: (j['octets'] as num?)?.toInt() ?? 0,
        morceaux: (j['morceaux'] as num?)?.toInt() ?? 1,
        diffusee: j['diffusee'] as bool? ?? false,
        ajouteeLe: DateTime.tryParse(j['ajouteeLe'] as String? ?? '') ??
            DateTime(2026),
      );

  /// Nom propre : sans espaces en trop, sans extension de fichier, pas
  /// vide, et pas trop long.
  static String nomPropre(String nom) {
    var n = nom.trim().replaceFirst(
          RegExp(r'\.(png|jpe?g)$', caseSensitive: false),
          '',
        );
    if (n.isEmpty) n = 'Carte';
    return n.length > longueurNomMax ? n.substring(0, longueurNomMax) : n;
  }
}

/// Pion posé sur une carte (20/11/2026) : l'icône d'un personnage ou d'une
/// créature, avec son nom au-dessus. Un pion par personnage ou créature et
/// par carte : son id est celui du personnage (uid du joueur) ou de la
/// créature de la partie. Position relative à l'image (0 à 1), pour qu'elle
/// tienne quelle que soit la taille de l'écran.
class PionCarte {
  const PionCarte({
    required this.id,
    required this.nom,
    required this.personnage,
    this.proprietaire = '',
    this.allie = false,
    this.neutre = false,
    this.classeId = '',
    this.raceId = '',
    this.element = '',
    this.famille = '',
    this.x = 0.5,
    this.y = 0.5,
  });

  final String id;
  final String nom;

  /// Personnage d'un joueur ; sinon, créature.
  final bool personnage;

  /// Joueur à qui il appartient (son personnage, ses compagnons et
  /// invocations) ; vide : créature du MJ.
  final String proprietaire;

  /// Du côté des PJ (personnage, compagnon, allié joué par le MJ).
  final bool allie;

  /// Créature neutre (21/11/2026) : contour gris.
  final bool neutre;

  /// Icône d'un personnage : classe, race, élément du draconien.
  final String classeId;
  final String raceId;
  final String element;

  /// Icône d'une créature : sa famille du bestiaire.
  final String famille;

  /// Position, de 0 (gauche, haut) à 1 (droite, bas).
  final double x;
  final double y;

  PionCarte deplace(double x, double y) => PionCarte(
        id: id,
        nom: nom,
        personnage: personnage,
        proprietaire: proprietaire,
        allie: allie,
        neutre: neutre,
        classeId: classeId,
        raceId: raceId,
        element: element,
        famille: famille,
        x: x.clamp(0.0, 1.0),
        y: y.clamp(0.0, 1.0),
      );

  Map<String, dynamic> versJson() => {
        'nom': nom,
        'personnage': personnage,
        'proprietaire': proprietaire,
        'allie': allie,
        if (neutre) 'neutre': true,
        if (classeId.isNotEmpty) 'classeId': classeId,
        if (raceId.isNotEmpty) 'raceId': raceId,
        if (element.isNotEmpty) 'element': element,
        if (famille.isNotEmpty) 'famille': famille,
        'x': x,
        'y': y,
      };

  factory PionCarte.depuisJson(String id, Map<String, dynamic> j) => PionCarte(
        id: id,
        nom: j['nom'] as String? ?? '',
        personnage: j['personnage'] as bool? ?? false,
        proprietaire: j['proprietaire'] as String? ?? '',
        allie: j['allie'] as bool? ?? false,
        neutre: j['neutre'] as bool? ?? false,
        classeId: j['classeId'] as String? ?? '',
        raceId: j['raceId'] as String? ?? '',
        element: j['element'] as String? ?? '',
        famille: j['famille'] as String? ?? '',
        x: ((j['x'] as num?)?.toDouble() ?? 0.5).clamp(0.0, 1.0),
        y: ((j['y'] as num?)?.toDouble() ?? 0.5).clamp(0.0, 1.0),
      );
}
