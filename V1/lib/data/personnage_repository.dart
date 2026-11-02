import 'dart:async';

import '../models/personnage.dart';

/// Contrat de stockage des personnages.
///
/// Sans compte : [LocalPersonnageRepository] (sur l'appareil).
/// Avec un compte : [FirestorePersonnageRepository] (en ligne, phase 2),
/// derrière cette même interface, sans toucher aux écrans.
abstract class PersonnageRepository {
  Future<List<Personnage>> tous();
  Future<void> sauvegarder(Personnage personnage);
  Future<void> supprimer(String id);
}

/// Stockage en ligne : changements reçus en direct (autre appareil),
/// envoi des fiches de l'appareil, suppression de tout (compte supprimé).
abstract class DepotEnLigne implements PersonnageRepository {
  /// Liste à jour à chaque changement, d'où qu'il vienne.
  Stream<List<Personnage>> ecouter();

  /// Envoie des fiches telles quelles (date de modification gardée).
  Future<void> importer(List<Personnage> personnages);

  /// Supprime toutes les fiches du compte.
  Future<void> toutSupprimer();
}

/// Implémentation en mémoire (tests, démos).
class EnMemoirePersonnageRepository implements PersonnageRepository {
  EnMemoirePersonnageRepository([List<Personnage>? initiaux])
      : _donnees = {for (final p in initiaux ?? <Personnage>[]) p.id: p};

  final Map<String, Personnage> _donnees;

  @override
  Future<List<Personnage>> tous() async => _donnees.values.toList();

  @override
  Future<void> sauvegarder(Personnage personnage) async {
    personnage.modifieLe = DateTime.now();
    _donnees[personnage.id] = personnage;
  }

  @override
  Future<void> supprimer(String id) async {
    _donnees.remove(id);
  }
}

/// Faux stockage en ligne, en mémoire (tests) : prévient ses auditeurs à
/// chaque changement, comme Firestore.
class EnMemoireDepotEnLigne extends EnMemoirePersonnageRepository
    implements DepotEnLigne {
  EnMemoireDepotEnLigne([super.initiaux]);

  final _flux = StreamController<List<Personnage>>.broadcast();

  /// `true` : les envois échouent (réseau coupé).
  bool enPanne = false;

  Future<void> _prevenir() async => _flux.add(await tous());

  @override
  Stream<List<Personnage>> ecouter() async* {
    yield await tous();
    yield* _flux.stream;
  }

  @override
  Future<void> sauvegarder(Personnage personnage) async {
    if (enPanne) throw StateError('réseau coupé');
    await super.sauvegarder(personnage);
    await _prevenir();
  }

  @override
  Future<void> supprimer(String id) async {
    await super.supprimer(id);
    await _prevenir();
  }

  @override
  Future<void> importer(List<Personnage> personnages) async {
    if (enPanne) throw StateError('réseau coupé');
    for (final p in personnages) {
      _donnees[p.id] = p;
    }
    await _prevenir();
  }

  @override
  Future<void> toutSupprimer() async {
    _donnees.clear();
    await _prevenir();
  }
}
