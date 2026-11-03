import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/personnage.dart';
import 'personnage_repository.dart';

/// Personnages en ligne (Firestore). Un document par fiche, dans la
/// collection `personnages` (pas sous l'utilisateur : prépare le partage et
/// les parties à plusieurs) :
/// - `proprietaire` : uid du compte qui l'a créée ;
/// - `partageAvec` : uids qui peuvent la lire (vide pour l'instant) ;
/// - `nom`, `modifieLe` (texte ISO) : pour lister et trier ;
/// - `univers` : id de l'univers de la fiche (filtrage futur) ;
/// - `fiche` : la fiche complète, même JSON que l'export (`versJson()`),
///   en texte (Firestore refuse les listes de listes).
/// Les règles de sécurité (`firestore.rules`) limitent l'accès au
/// propriétaire (et, plus tard, à `partageAvec`).
class FirestorePersonnageRepository implements DepotEnLigne {
  FirestorePersonnageRepository(this.uid, [FirebaseFirestore? base])
      : _base = base ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _base;

  static const collection = 'personnages';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _base.collection(collection);

  Query<Map<String, dynamic>> get _miens =>
      _collection.where('proprietaire', isEqualTo: uid);

  /// Document Firestore d'une fiche.
  static Map<String, dynamic> versDocument(Personnage p, String uid) => {
        'proprietaire': uid,
        'partageAvec': <String>[],
        'nom': p.nom,
        'univers': p.univers,
        'modifieLe': p.modifieLe.toIso8601String(),
        'schema': Personnage.versionSchema,
        'fiche': jsonEncode(p.versJson()),
      };

  /// Fiche d'un document ; `null` si illisible (on l'ignore).
  static Personnage? depuisDocument(Map<String, dynamic> d) {
    try {
      return Personnage.depuisJson(
          jsonDecode(d['fiche'] as String) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  List<Personnage> _lire(QuerySnapshot<Map<String, dynamic>> s) => [
        for (final d in s.docs)
          if (depuisDocument(d.data()) case final p?) p,
      ];

  @override
  Future<List<Personnage>> tous() async => _lire(await _miens.get());

  @override
  Stream<List<Personnage>> ecouter() => _miens.snapshots().map(_lire);

  @override
  Future<void> sauvegarder(Personnage personnage) {
    personnage.modifieLe = DateTime.now();
    return _collection.doc(personnage.id).set(versDocument(personnage, uid));
  }

  @override
  Future<void> supprimer(String id) => _collection.doc(id).delete();

  @override
  Future<void> importer(List<Personnage> personnages) async {
    // Lots de 400 écritures (limite Firestore : 500).
    for (var i = 0; i < personnages.length; i += 400) {
      final lot = _base.batch();
      for (final p in personnages.skip(i).take(400)) {
        lot.set(_collection.doc(p.id), versDocument(p, uid));
      }
      await lot.commit();
    }
  }

  @override
  Future<void> toutSupprimer() async {
    final docs = (await _miens.get()).docs;
    for (var i = 0; i < docs.length; i += 400) {
      final lot = _base.batch();
      for (final d in docs.skip(i).take(400)) {
        lot.delete(d.reference);
      }
      await lot.commit();
    }
  }
}
