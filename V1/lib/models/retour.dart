/// Nature d'un retour envoyé depuis l'écran « Donner son avis ».
enum TypeRetour {
  bug('Un bug', 'Ce qui ne marche pas, et comment le reproduire'),
  idee('Une idée', 'Une amélioration, une nouveauté souhaitée'),
  autre('Autre chose', 'Une question, une remarque');

  const TypeRetour(this.libelle, this.aide);

  final String libelle;
  final String aide;

  static TypeRetour depuisCode(Object? code) => TypeRetour.values.firstWhere(
        (t) => t.name == code,
        orElse: () => TypeRetour.autre,
      );
}

/// Retour d'un joueur (bug, idée, autre) : rangé en ligne, lu par l'équipe
/// dans la console Firebase (18/11/2026). Aucune donnée n'est relue par
/// l'application.
class Retour {
  const Retour({
    required this.type,
    required this.texte,
    required this.auteur,
    this.nom = '',
    this.email,
    required this.version,
    required this.plateforme,
    required this.date,
  });

  /// Longueur maximum du texte.
  static const int longueurMax = 4000;

  final TypeRetour type;
  final String texte;

  /// uid du compte.
  final String auteur;

  /// Nom affiché du compte (vide si inconnu).
  final String nom;

  /// Adresse e-mail, seulement si le joueur veut une réponse.
  final String? email;

  /// Version de l'application et plateforme (web, android, windows…).
  final String version;
  final String plateforme;
  final DateTime date;

  Map<String, dynamic> versJson() => {
        'type': type.name,
        'texte': texte,
        'auteur': auteur,
        if (nom.isNotEmpty) 'nom': nom,
        if (email case final e? when e.isNotEmpty) 'email': e,
        'version': version,
        'plateforme': plateforme,
        'date': date.toIso8601String(),
      };
}
