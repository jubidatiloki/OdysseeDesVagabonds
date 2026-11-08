import 'dart:convert';
import 'dart:math' as math;

import 'objet.dart';

/// Butin d'une partie : créé et rempli par le MJ, visible dans le menu de
/// gauche ; les PJ y prennent l'argent et les objets.
class ButinSeance {
  const ButinSeance({
    this.id = '',
    required this.nom,
    this.or = 0,
    this.argent = 0,
    this.cuivre = 0,
    this.objets = const [],
    this.cache = false,
  });

  final String id;
  final String nom;

  /// Le MJ cache la carte aux PJ (préparée à l'avance, révélée plus tard).
  final bool cache;
  final int or;
  final int argent;
  final int cuivre;
  final List<Objet> objets;

  Bourse get bourse => Bourse(or: or, argent: argent, cuivre: cuivre);

  /// « 2 objets · 10 or », « Vide ».
  String get resume {
    final n = objets.length;
    final parties = [
      if (n > 0) '$n objet${n > 1 ? 's' : ''}',
      if (!bourse.vide) bourse.texte,
    ];
    return parties.isEmpty ? 'Vide' : parties.join(' · ');
  }

  ButinSeance copie({
    String? id,
    Bourse? bourse,
    List<Objet>? objets,
    bool? cache,
  }) =>
      ButinSeance(
        id: id ?? this.id,
        nom: nom,
        cache: cache ?? this.cache,
        or: bourse?.or ?? or,
        argent: bourse?.argent ?? argent,
        cuivre: bourse?.cuivre ?? cuivre,
        objets: objets ?? this.objets,
      );

  /// Ce qu'il reste après avoir pris [demande] et [quantite] exemplaires de
  /// l'objet [objetId] (tous si `null`), et ce qui a vraiment été pris : on ne
  /// prend pas plus que ce qu'il reste.
  ({ButinSeance reste, Bourse argent, Objet? objet}) prendre({
    Bourse? demande,
    String? objetId,
    int? quantite,
  }) {
    int pris(int voulu, int dispo) => math.max(0, math.min(voulu, dispo));
    final argentPris = Bourse(
      or: pris(demande?.or ?? 0, or),
      argent: pris(demande?.argent ?? 0, argent),
      cuivre: pris(demande?.cuivre ?? 0, cuivre),
    );
    Objet? objet;
    final restants = <Objet>[];
    for (final o in objets) {
      if (o.id != objetId) {
        restants.add(o);
        continue;
      }
      final n = (quantite ?? o.quantite).clamp(1, o.quantite);
      if (n == o.quantite) {
        objet = o;
      } else {
        // Une partie de la pile : l'objet pris est un nouvel exemplaire.
        objet = Objet.depuisJson(o.versJson()..remove('id'))..quantite = n;
        restants.add(Objet.depuisJson(o.versJson())..quantite = o.quantite - n);
      }
    }
    return (
      reste: copie(
        bourse: Bourse(
          or: or - argentPris.or,
          argent: argent - argentPris.argent,
          cuivre: cuivre - argentPris.cuivre,
        ),
        objets: restants,
      ),
      argent: argentPris,
      objet: objet,
    );
  }

  /// Les objets sont gardés en texte (Firestore refuse les listes de listes).
  Map<String, dynamic> versJson() => {
        'nom': nom,
        'or': or,
        'argent': argent,
        'cuivre': cuivre,
        'objets': jsonEncode([for (final o in objets) o.versJson()]),
        'cache': cache,
      };

  factory ButinSeance.depuisJson(String id, Map<String, dynamic> j) {
    int v(String c) => (j[c] as num?)?.toInt() ?? 0;
    return ButinSeance(
      id: id,
      nom: j['nom'] as String? ?? 'Butin',
      or: v('or'),
      argent: v('argent'),
      cuivre: v('cuivre'),
      objets: _objets(j['objets']),
      cache: j['cache'] as bool? ?? false,
    );
  }

  static List<Objet> _objets(Object? texte) {
    if (texte is! String || texte.isEmpty) return const [];
    return [
      for (final o in jsonDecode(texte) as List)
        Objet.depuisJson(o as Map<String, dynamic>),
    ];
  }
}

/// Objet envoyé par un PJ à un autre : il attend son destinataire, qui
/// l'ajoute à sa fiche (lui seul peut l'écrire). [discret] : il n'est pas
/// prévenu.
class EnvoiObjet {
  const EnvoiObjet({
    this.id = '',
    required this.destinataire,
    required this.auteur,
    required this.auteurNom,
    required this.objet,
    this.discret = false,
  });

  final String id;
  final String destinataire;
  final String auteur;

  /// Nom du personnage qui envoie.
  final String auteurNom;
  final Objet objet;
  final bool discret;

  EnvoiObjet avecId(String id) => EnvoiObjet(
        id: id,
        destinataire: destinataire,
        auteur: auteur,
        auteurNom: auteurNom,
        objet: objet,
        discret: discret,
      );

  Map<String, dynamic> versJson() => {
        'destinataire': destinataire,
        'auteur': auteur,
        'auteurNom': auteurNom,
        'objet': jsonEncode(objet.versJson()),
        'discret': discret,
      };

  factory EnvoiObjet.depuisJson(String id, Map<String, dynamic> j) =>
      EnvoiObjet(
        id: id,
        destinataire: j['destinataire'] as String? ?? '',
        auteur: j['auteur'] as String? ?? '',
        auteurNom: j['auteurNom'] as String? ?? '',
        objet: Objet.depuisJson(
          jsonDecode(j['objet'] as String) as Map<String, dynamic>,
        ),
        discret: j['discret'] as bool? ?? false,
      );
}
