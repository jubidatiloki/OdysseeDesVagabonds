import '../models/personnage.dart';

/// Contrat de stockage des personnages.
///
/// V1 : [LocalPersonnageRepository] (sur l'appareil).
/// Phase 2 : une implémentation Firestore viendra s'ajouter derrière cette
/// même interface, sans toucher aux écrans.
abstract class PersonnageRepository {
  Future<List<Personnage>> tous();
  Future<void> sauvegarder(Personnage personnage);
  Future<void> supprimer(String id);
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
