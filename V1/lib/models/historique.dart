/// Catégorie d'un événement de l'historique (sert au filtre et à l'icône).
enum CategorieHistorique {
  creation('Création'),
  niveau('Niveau'),
  identite('Identité'),
  vie('Vie et mana'),
  inventaire('Inventaire'),
  bourse('Bourse'),
  competences('Compétences'),
  notes('Notes'),
  des('Lancers de dés'),
  autre('Autre');

  const CategorieHistorique(this.libelle);
  final String libelle;

  static CategorieHistorique depuisCode(String? code) {
    for (final c in values) {
      if (c.name == code) return c;
    }
    return autre;
  }
}

/// Une ligne de l'historique d'un personnage (un « log »).
class EvenementHistorique {
  EvenementHistorique({
    required this.date,
    required this.categorie,
    required this.message,
    this.fusion,
    this.avant,
    this.seance,
  });

  /// Séance pendant laquelle l'événement a eu lieu (« Les Brumes · Séance
  /// 3 ») : l'historique les regroupe.
  final String? seance;

  final DateTime date;
  final CategorieHistorique categorie;
  final String message;

  /// Clé permettant de regrouper des actions rapprochées identiques
  /// (ex. plusieurs clics « PV −1 » → une seule ligne « PV : 13 → 10 »).
  final String? fusion;

  /// Valeur de départ d'une suite d'actions regroupées.
  final int? avant;

  Map<String, dynamic> versJson() => {
        'date': date.toIso8601String(),
        'categorie': categorie.name,
        'message': message,
        if (fusion != null) 'fusion': fusion,
        if (avant != null) 'avant': avant,
        if (seance != null) 'seance': seance,
      };

  factory EvenementHistorique.depuisJson(Map<String, dynamic> j) =>
      EvenementHistorique(
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime(2000),
        categorie: CategorieHistorique.depuisCode(j['categorie'] as String?),
        message: j['message'] as String? ?? '',
        fusion: j['fusion'] as String?,
        avant: (j['avant'] as num?)?.toInt(),
        seance: j['seance'] as String?,
      );
}

/// Écrit un nombre avec son signe : +3, −2.
String avecSigne(int v) => v < 0 ? '−${-v}' : '+$v';
