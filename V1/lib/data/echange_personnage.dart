import 'dart:convert';

import '../models/historique.dart';
import '../models/personnage.dart';
import 'referentiel.dart';

/// Erreur d'import, avec un message lisible par le joueur.
class ErreurImport implements Exception {
  const ErreurImport(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Format d'échange d'un personnage (fichier .json) :
/// ```json
/// { "format": "odyssee-vagabonds/personnage", "version": 1,
///   "exporteLe": "2026-10-20T14:00:00.000", "personnage": { … } }
/// ```
/// Le contenu de « personnage » est le même JSON que la sauvegarde locale
/// (et que la future synchronisation cloud).
class EchangePersonnage {
  static const String format = 'odyssee-vagabonds/personnage';
  static const int version = 1;

  /// Texte JSON (indenté, lisible) à enregistrer ou à copier.
  static String exporter(Personnage p, {DateTime? maintenant}) =>
      const JsonEncoder.withIndent('  ').convert({
        'format': format,
        'version': version,
        'exporteLe': (maintenant ?? DateTime.now()).toIso8601String(),
        'personnage': p.versJson(),
      });

  /// Nom de fichier proposé : « odv_brom_barbe_de_fer.json ».
  static String nomFichier(Personnage p) {
    const accents = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'ç': 'c',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'ô': 'o',
      'ö': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ÿ': 'y',
      'œ': 'oe',
      'æ': 'ae',
    };
    final buffer = StringBuffer();
    for (final ch in p.nom.toLowerCase().split('')) {
      buffer.write(accents[ch] ?? ch);
    }
    final slug = buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return 'odv_${slug.isEmpty ? 'personnage' : slug}.json';
  }

  /// Lit un personnage exporté. Accepte aussi le JSON « brut » d'un
  /// personnage. Vérifie que sa race et sa classe existent.
  static Personnage lire(String texte, Referentiel referentiel) {
    Object? json;
    try {
      json = jsonDecode(texte.trim());
    } catch (_) {
      throw const ErreurImport(
        'Ce contenu n\'est pas un fichier de personnage valide '
        '(texte JSON illisible).',
      );
    }
    Map<String, dynamic>? donnees;
    if (json is Map<String, dynamic>) {
      if (json['format'] == format && json['personnage'] is Map) {
        final v = (json['version'] as num?)?.toInt() ?? 1;
        if (v > version) {
          throw const ErreurImport(
            'Ce fichier vient d\'une version plus récente de l\'application. '
            'Mets l\'application à jour pour l\'importer.',
          );
        }
        donnees = Map<String, dynamic>.from(json['personnage'] as Map);
      } else if (json.containsKey('raceId') && json.containsKey('classeId')) {
        donnees = json;
      }
    }
    if (donnees == null) {
      throw const ErreurImport(
        'Ce fichier ne contient pas de personnage de L\'odyssée des vagabonds.',
      );
    }
    final Personnage p;
    try {
      p = Personnage.depuisJson(donnees);
    } catch (_) {
      throw const ErreurImport('Le personnage est incomplet ou abîmé.');
    }
    if (referentiel.race(p.raceId) == null) {
      throw ErreurImport('Race inconnue dans ce fichier : « ${p.raceId} ».');
    }
    if (referentiel.classe(p.classeId) == null) {
      throw ErreurImport(
        'Classe inconnue dans ce fichier : « ${p.classeId} ».',
      );
    }
    return p;
  }

  /// Sauvegarde de toutes les fiches en un seul fichier (16/11/2026) :
  /// `{ "format": "odyssee-vagabonds/sauvegarde", "version": 1,
  /// "exporteLe": …, "personnages": [ … ] }`.
  static const String formatSauvegarde = 'odyssee-vagabonds/sauvegarde';

  static String exporterTout(
    List<Personnage> personnages, {
    DateTime? maintenant,
  }) =>
      const JsonEncoder.withIndent('  ').convert({
        'format': formatSauvegarde,
        'version': version,
        'exporteLe': (maintenant ?? DateTime.now()).toIso8601String(),
        'personnages': [for (final p in personnages) p.versJson()],
      });

  /// Nom de fichier proposé : « odv_sauvegarde_2026-11-16.json ».
  static String nomSauvegarde(DateTime date) {
    String n(int v) => v.toString().padLeft(2, '0');
    return 'odv_sauvegarde_${date.year}-${n(date.month)}-${n(date.day)}.json';
  }

  /// Le texte est-il une sauvegarde complète (plusieurs fiches) ?
  static bool estSauvegarde(String texte) {
    try {
      final j = jsonDecode(texte.trim());
      return j is Map && j['format'] == formatSauvegarde;
    } catch (_) {
      return false;
    }
  }

  /// Lit une sauvegarde complète ; les fiches à la race ou à la classe
  /// inconnue sont écartées (renvoyées à part, par nom).
  static ({List<Personnage> personnages, List<String> ecartes}) lireTout(
    String texte,
    Referentiel referentiel,
  ) {
    final Object? json;
    try {
      json = jsonDecode(texte.trim());
    } catch (_) {
      throw const ErreurImport('Cette sauvegarde est illisible.');
    }
    if (json is! Map || json['format'] != formatSauvegarde) {
      throw const ErreurImport('Ce fichier n\'est pas une sauvegarde.');
    }
    final v = (json['version'] as num?)?.toInt() ?? 1;
    if (v > version) {
      throw const ErreurImport(
        'Cette sauvegarde vient d\'une version plus récente de '
        'l\'application. Mets l\'application à jour pour l\'importer.',
      );
    }
    final res = <Personnage>[];
    final ecartes = <String>[];
    for (final brut in json['personnages'] as List? ?? const []) {
      try {
        final p = Personnage.depuisJson(Map<String, dynamic>.from(brut as Map));
        if (referentiel.race(p.raceId) == null ||
            referentiel.classe(p.classeId) == null) {
          ecartes.add(p.nom);
        } else {
          res.add(p);
        }
      } catch (_) {
        ecartes.add('fiche abîmée');
      }
    }
    return (personnages: res, ecartes: ecartes);
  }

  /// Copie indépendante (nouvel identifiant, nom « … (copie) »), pour
  /// importer un personnage qui existe déjà sans l'écraser.
  static Personnage copie(Personnage p) => Personnage.depuisJson({
        ...p.versJson(),
        'id': Personnage.nouvelId(),
        'nom': '${p.nom} (copie)',
      });

  /// Inscrit l'import dans l'historique du personnage.
  static void journaliserImport(Personnage p, {String? source}) =>
      p.journaliser(
        'Personnage importé${source == null ? '' : ' ($source)'}',
        categorie: CategorieHistorique.autre,
      );
}
