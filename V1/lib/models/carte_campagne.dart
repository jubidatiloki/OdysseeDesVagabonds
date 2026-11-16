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
