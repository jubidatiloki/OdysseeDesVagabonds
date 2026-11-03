import 'carac.dart';

/// Univers de jeu (cadre) : le système à d20 pourra servir à d'autres
/// univers que le médiéval fantastique. Un personnage, une classe, une race
/// et une voie appartiennent à un univers ; l'univers fixe le groupe de
/// statistiques (caractéristiques) utilisé.
///
/// Pour l'instant un seul univers existe et rien ne s'affiche : la notion
/// est posée pour plus tard. Dans les fichiers JSON, la clé `"univers"` est
/// facultative : absente, c'est l'univers par défaut.
class Univers {
  const Univers({required this.id, required this.nom, required this.caracs});

  final String id;
  final String nom;

  /// Groupe de statistiques de l'univers, dans l'ordre d'affichage.
  final List<Carac> caracs;

  /// Univers actuel (et par défaut) : médiéval fantastique.
  static const Univers medievalFantastique = Univers(
    id: kUniversParDefaut,
    nom: 'Médiéval fantastique',
    caracs: Carac.values,
  );

  /// Univers connus.
  static const List<Univers> tous = [medievalFantastique];

  /// Univers d'après son id ; id inconnu ou absent → univers par défaut.
  static Univers parId(String? id) {
    for (final u in tous) {
      if (u.id == id) return u;
    }
    return medievalFantastique;
  }
}

/// Id de l'univers par défaut (données et sauvegardes sans clé `univers`).
const String kUniversParDefaut = 'medieval-fantastique';

/// Lecture de la clé `"univers"` d'un objet JSON (absente → par défaut).
String universDepuisJson(Object? valeur) =>
    valeur is String && valeur.isNotEmpty ? valeur : kUniversParDefaut;
