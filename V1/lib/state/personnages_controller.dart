import 'package:flutter/foundation.dart';

import '../data/personnage_repository.dart';
import '../models/personnage.dart';

/// État de la liste des personnages, partagé par les écrans.
/// Les écrans l'écoutent avec un `ListenableBuilder`.
class PersonnagesController extends ChangeNotifier {
  PersonnagesController(this._repository);

  final PersonnageRepository _repository;

  List<Personnage> _personnages = [];
  bool _chargement = false;
  Object? _erreur;

  List<Personnage> get personnages => List.unmodifiable(_personnages);
  bool get chargement => _chargement;
  Object? get erreur => _erreur;

  Personnage? parId(String id) {
    for (final p in _personnages) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> charger() async {
    _chargement = true;
    notifyListeners();
    try {
      _personnages = await _repository.tous();
      _trier();
      _erreur = null;
    } catch (e) {
      _erreur = e;
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  Future<void> sauvegarder(Personnage personnage) async {
    await _repository.sauvegarder(personnage);
    final i = _personnages.indexWhere((p) => p.id == personnage.id);
    if (i >= 0) {
      _personnages[i] = personnage;
    } else {
      _personnages.add(personnage);
    }
    _trier();
    notifyListeners();
  }

  Future<void> supprimer(String id) async {
    await _repository.supprimer(id);
    _personnages.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Le plus récemment modifié en premier.
  void _trier() =>
      _personnages.sort((a, b) => b.modifieLe.compareTo(a.modifieLe));
}
