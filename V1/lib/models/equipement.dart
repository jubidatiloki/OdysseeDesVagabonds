/// Catégories de l'index des équipements (page Équipements).
enum CategorieEquipement {
  arme('arme', 'Armes'),
  armure('armure', 'Armures'),
  objetMagique('objet-magique', 'Objets magiques'),
  accessoire('accessoire', 'Accessoires'),
  consommable('consommable', 'Consommables'),
  instrument('instrument', 'Instruments'),
  autre('autre', 'Autres');

  const CategorieEquipement(this.code, this.libelle);

  /// Clé utilisée dans `assets/data/equipements.json`.
  final String code;
  final String libelle;

  /// Accepte le code (« arme »), le libellé (« Armes ») ou une variante
  /// (« Arme », « Objet magique »), sans tenir compte des majuscules.
  /// Plusieurs catégories séparées par des virgules (« Outil, arme ») : la
  /// première reconnue est retenue.
  static CategorieEquipement depuisCode(String? code) {
    for (final morceau in (code ?? '').split(',')) {
      final c = _normaliser(morceau);
      for (final v in values) {
        if (c == _normaliser(v.code) || c == _normaliser(v.libelle)) return v;
      }
    }
    return CategorieEquipement.autre;
  }

  /// « Objets magiques » → « objet-magique ».
  static String _normaliser(String texte) => texte
      .trim()
      .toLowerCase()
      .replaceAll('é', 'e')
      .split(RegExp(r'[\s-]+'))
      .map((m) => m.endsWith('s') ? m.substring(0, m.length - 1) : m)
      .join('-');
}

/// Un équipement de référence (arme, armure, potion…), en lecture seule.
/// Ne pas confondre avec `Objet`, qui est une ligne de l'inventaire d'un
/// personnage.
class Equipement {
  const Equipement({
    required this.id,
    required this.nom,
    required this.categorie,
    this.sousCategorie = '',
    this.description = '',
    this.proprietes = const {},
  });

  final String id;
  final String nom;
  final CategorieEquipement categorie;

  /// Ex. « Potion », « CaC, Épée, une main, tranchante » (plusieurs
  /// étiquettes séparées par des virgules).
  final String sousCategorie;

  /// Étiquettes de la sous-catégorie (« CaC », « Épée », « une main »…).
  List<String> get etiquettes => [
        for (final e in sousCategorie.split(','))
          if (e.trim().isNotEmpty) e.trim(),
      ];
  final String description;

  /// Caractéristiques affichées sous forme « libellé : valeur »
  /// (dégâts, type de dégâts, bonus de CA, prix, emplacement…).
  final Map<String, String> proprietes;

  /// Texte utilisé par la recherche.
  String get texteRecherche => [
        nom,
        sousCategorie,
        description,
        ...proprietes.values,
      ].join(' ');

  factory Equipement.depuisJson(Map<String, dynamic> j) {
    final sous = j['sousCategorie'] as String? ?? '';
    var categorie = CategorieEquipement.depuisCode(j['categorie'] as String?);
    // Étiquette « instrument » sans catégorie précise : rangé dans les
    // Instruments (et non dans « Autres »).
    if (categorie == CategorieEquipement.autre &&
        sous.split(',').any((t) => t.trim().toLowerCase() == 'instrument')) {
      categorie = CategorieEquipement.instrument;
    }
    return Equipement(
      id: j['id'] as String,
      nom: j['nom'] as String? ?? '',
      categorie: categorie,
      sousCategorie: sous,
      description: j['description'] as String? ?? '',
      proprietes: {
        for (final e
            in (j['proprietes'] as Map<String, dynamic>? ?? const {}).entries)
          e.key: '${e.value}',
      },
    );
  }
}
