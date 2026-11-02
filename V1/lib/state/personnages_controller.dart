import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/personnage_repository.dart';
import '../models/personnage.dart';

/// État de la liste des personnages, partagé par les écrans.
/// Les écrans l'écoutent avec un `ListenableBuilder`.
class PersonnagesController extends ChangeNotifier {
  PersonnagesController(this._repository);

  PersonnageRepository _repository;

  /// Changements reçus en direct (stockage en ligne : autre appareil).
  StreamSubscription<List<Personnage>>? _ecoute;

  /// Appelé après la sauvegarde d'un lancer de dé (compte : envoi au
  /// lancer si la méthode de sauvegarde le prévoit).
  Future<void> Function()? apresLancer;

  /// Stockage utilisé (sur l'appareil, ou en ligne avec un compte).
  PersonnageRepository get repository => _repository;

  /// Change de stockage (connexion, déconnexion) et recharge la liste ;
  /// en ligne, la liste suit ensuite les changements des autres appareils.
  Future<void> utiliser(PersonnageRepository repository) async {
    await _ecoute?.cancel();
    _ecoute = null;
    _repository = repository;
    await charger();
    if (repository is DepotEnLigne) {
      _ecoute = repository.ecouter().listen((liste) {
        _personnages = liste;
        _trier();
        _erreur = null;
        notifyListeners();
      }, onError: (Object e) {
        _erreur = e;
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _ecoute?.cancel();
    super.dispose();
  }

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

  /// [lancer] : sauvegarde après un lancer de dé du personnage actif.
  Future<void> sauvegarder(Personnage personnage, {bool lancer = false}) async {
    await _repository.sauvegarder(personnage);
    if (lancer) await apresLancer?.call();
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
