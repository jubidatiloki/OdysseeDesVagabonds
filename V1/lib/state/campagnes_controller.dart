import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/campagnes.dart';
import '../data/compte.dart';
import '../models/campagne.dart';
import 'compte_controller.dart';

/// Campagnes du compte connecté (MJ et joueur), suivies en direct. Sans
/// compte : aucune campagne (il faut être connecté pour jouer à plusieurs).
///
/// Partage des fiches : pour chaque campagne où le joueur a un personnage,
/// sa fiche est lisible par le MJ (paramètre « fiches visibles par le MJ »)
/// et par les autres joueurs (« fiches visibles entre joueurs »).
class CampagnesController extends ChangeNotifier {
  CampagnesController({required this.compte, required this.service}) {
    compte.addListener(_suivreCompte);
    _suivreCompte();
  }

  /// Sans compte possible (Windows, tests) : écran d'explication.
  factory CampagnesController.horsLigne(CompteController compte) =>
      CampagnesController(
        compte: compte,
        service: (_) => throw UnsupportedError('pas de compte'),
      );

  final CompteController compte;

  /// Service des campagnes d'un compte (Firestore, ou mémoire en test).
  final ServiceCampagnes Function(Utilisateur u) service;

  ServiceCampagnes? _service;
  StreamSubscription<List<Campagne>>? _ecoute;
  List<Campagne> _campagnes = const [];
  String? _erreur;
  bool _charge = false;

  /// Séances en cours déjà signalées (id de campagne → numéro).
  final Map<String, int> _seancesVues = {};
  final _nouvellesSeances = StreamController<Campagne>.broadcast();

  /// Fiches partagées pour les campagnes (id de fiche → uids), pour ne
  /// réécrire que ce qui change.
  final Map<String, List<String>> _partages = {};

  ServiceCampagnes? get serviceActuel => _service;
  String? get uid => _service?.uid;
  bool get connecte => _service != null;
  bool get charge => _charge;
  String? get erreur => _erreur;
  List<Campagne> get campagnes => _campagnes;

  /// Campagnes que le compte mène.
  List<Campagne> get commeMj => [
        for (final c in _campagnes)
          if (c.estMj(uid ?? '')) c,
      ];

  /// Campagnes rejointes ou demandées par le compte.
  List<Campagne> get commeJoueur => [
        for (final c in _campagnes)
          if (!c.estMj(uid ?? '')) c,
      ];

  /// Campagnes de joueur dont une séance est en cours.
  List<Campagne> get seancesEnCours => [
        for (final c in commeJoueur)
          if (c.seanceEnCours && c.joueurs.contains(uid)) c,
      ];

  /// Une séance vient de démarrer dans une campagne du joueur (pour
  /// l'avertir, où qu'il soit dans l'app).
  Stream<Campagne> get nouvellesSeances => _nouvellesSeances.stream;

  Campagne? parId(String id) {
    for (final c in _campagnes) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _suivreCompte() {
    final u = compte.utilisateur;
    if (u?.uid == _service?.uid) return;
    _ecoute?.cancel();
    _ecoute = null;
    _campagnes = const [];
    _seancesVues.clear();
    _partages.clear();
    _charge = false;
    _service = u == null ? null : service(u);
    final s = _service;
    if (s != null) {
      _ecoute = s.ecouter().listen(_recevoir, onError: (Object e) {
        _erreur = 'Campagnes indisponibles (connexion internet ?).';
        _charge = true;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void _recevoir(List<Campagne> liste) {
    final premiere = !_charge;
    _campagnes = liste;
    _erreur = null;
    _charge = true;
    // Séances qui démarrent (pas celles déjà en cours à l'ouverture).
    for (final c in seancesEnCours) {
      final n = c.seance!.numero;
      if (_seancesVues[c.id] != n && !premiere) _nouvellesSeances.add(c);
      _seancesVues[c.id] = n;
    }
    notifyListeners();
    unawaited(_mettreAJourPartages());
  }

  /// Joueur : MJ (et autres joueurs selon les paramètres) peuvent lire la
  /// fiche engagée dans chaque campagne.
  Future<void> _mettreAJourPartages() async {
    final s = _service;
    if (s == null) return;
    final voulu = <String, Set<String>>{};
    for (final c in commeJoueur) {
      final membres = await s.ecouterMembres(c.id).first;
      MembreCampagne? moi;
      for (final m in membres) {
        if (m.uid == s.uid) moi = m;
      }
      if (moi == null || moi.personnageId.isEmpty) continue;
      final lecteurs = voulu.putIfAbsent(moi.personnageId, () => {});
      if (c.parametres.fichesVisiblesMj) lecteurs.add(c.mj);
      if (c.parametres.fichesVisiblesJoueurs &&
          moi.statut == StatutMembre.accepte) {
        lecteurs.addAll(c.joueurs.where((u) => u != s.uid));
      }
    }
    // Fiches qui ne sont plus engagées : plus partagées.
    for (final id in _partages.keys) {
      voulu.putIfAbsent(id, () => {});
    }
    for (final e in voulu.entries) {
      final liste = e.value.toList()..sort();
      if (listEquals(_partages[e.key], liste)) continue;
      try {
        await s.partagerFiche(e.key, liste);
        _partages[e.key] = liste;
      } catch (_) {
        // Réessayé au prochain changement.
      }
    }
  }

  /// Exécute une action ; renvoie le message d'erreur en français, ou
  /// `null` si elle a réussi.
  Future<String?> agir(Future<void> Function(ServiceCampagnes s) action) async {
    final s = _service;
    if (s == null) return 'Connecte-toi pour jouer en campagne.';
    try {
      await action(s);
      return null;
    } on ErreurCampagne catch (e) {
      return e.message;
    } catch (e) {
      return 'Action impossible (connexion internet ?).';
    }
  }

  @override
  void dispose() {
    compte.removeListener(_suivreCompte);
    _ecoute?.cancel();
    _nouvellesSeances.close();
    super.dispose();
  }
}
