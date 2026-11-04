import 'dart:async';
import 'dart:convert';

import '../models/personnage.dart';
import 'compte.dart';
import 'personnage_repository.dart';

/// Stockage en ligne dont l'envoi peut attendre (méthode de sauvegarde du
/// compte) : quand [envoiImmediat] est faux, les modifications sont gardées
/// sur l'appareil (elles survivent à la fermeture de l'app) et ne partent
/// qu'à [envoyer] (prochain lancer de dé, bouton « Synchroniser
/// maintenant »). En attendant, la liste montre la version de l'appareil.
///
/// Envois automatiques espacés d'au moins [delai] (5 s) pour limiter les
/// écritures Firestore : le premier part tout de suite, les modifications
/// suivantes sont regroupées (dernière version de chaque fiche) et partent
/// à la fin du délai.
class DepotDiffere implements DepotEnLigne {
  DepotDiffere(
    this.distant, {
    required this.envoiImmediat,
    required this.stockage,
    required this.cle,
    this.surEnvoi,
    this.surAttente,
    this.surErreur,
    this.delai = const Duration(seconds: 5),
    this.attenteReseau = const Duration(seconds: 3),
    this.cleMiroir,
    DateTime Function()? horloge,
  }) : _horloge = horloge ?? DateTime.now;

  final DepotEnLigne distant;

  /// Envoi tout de suite (sauvegarde automatique à chaque modification).
  final bool Function() envoiImmediat;
  final StockageCompte stockage;

  /// Clé des modifications en attente (une par compte).
  final String cle;

  /// Appelé après chaque envoi réussi (date de synchronisation).
  final void Function()? surEnvoi;

  /// Appelé quand le nombre de modifications en attente change.
  final void Function()? surAttente;

  /// Appelé quand un envoi différé (fin du délai) échoue.
  final void Function(Object erreur)? surErreur;

  /// Délai minimum entre deux envois automatiques.
  final Duration delai;

  /// Sans réponse du réseau passé ce délai, on n'attend plus : l'application
  /// reste utilisable, l'envoi continue dès que la connexion revient.
  final Duration attenteReseau;

  /// Clé de la copie des fiches gardée sur l'appareil (hors connexion).
  final String? cleMiroir;
  Future<int>? _envoiEnCours;
  final DateTime Function() _horloge;
  DateTime? _dernierEnvoi;
  Timer? _minuterie;

  /// Un envoi attend-il la fin du délai ?
  bool get envoiPlanifie => _minuterie != null;

  /// Fiches modifiées en attente d'envoi (`null` : fiche supprimée).
  final Map<String, Personnage?> _attente = {};
  final _changements = StreamController<void>.broadcast();

  int get nbEnAttente => _attente.length;

  /// Relit les modifications en attente gardées sur l'appareil.
  Future<void> charger() async {
    _attente.clear();
    _versions.clear();
    final brut = await stockage.lire(cle);
    if (brut == null || brut.isEmpty) return;
    try {
      final m = jsonDecode(brut) as Map<String, dynamic>;
      for (final e in m.entries) {
        _attente[e.key] = e.value == null
            ? null
            : Personnage.depuisJson(e.value as Map<String, dynamic>);
        _versions[e.key] = 1;
      }
    } catch (_) {
      // Illisible : ignoré (la version en ligne reste).
    }
  }

  Future<void> _garder() async {
    await stockage.ecrire(
      cle,
      _attente.isEmpty
          ? null
          : jsonEncode({
              for (final e in _attente.entries) e.key: e.value?.versJson(),
            }),
    );
    _changements.add(null);
    surAttente?.call();
  }

  /// Liste en ligne corrigée par les modifications en attente.
  List<Personnage> _fusion(List<Personnage> enLigne) => [
        for (final p in enLigne)
          if (!_attente.containsKey(p.id)) p,
        for (final p in _attente.values)
          if (p != null) p,
      ];

  /// Garde une copie des fiches du compte, pour démarrer sans internet.
  Future<void> _garderMiroir(List<Personnage> liste) async {
    final cle = cleMiroir;
    if (cle == null) return;
    try {
      await stockage.ecrire(
        cle,
        jsonEncode([for (final p in liste) p.versJson()]),
      );
    } catch (_) {
      // Plus de place sur l'appareil : la copie précédente reste.
    }
  }

  /// Fiches en ligne ; sans réponse du réseau, la copie de l'appareil.
  @override
  Future<List<Personnage>> tous() async {
    try {
      final liste = await distant.tous().timeout(attenteReseau);
      await _garderMiroir(liste);
      return _fusion(liste);
    } catch (_) {
      final cle = cleMiroir;
      if (cle == null) rethrow;
      return _fusion(await lireMiroir(stockage, cle));
    }
  }

  /// Copie des fiches gardée sur l'appareil.
  static Future<List<Personnage>> lireMiroir(
    StockageCompte stockage,
    String cle,
  ) async {
    final brut = await stockage.lire(cle);
    if (brut == null) return const [];
    try {
      return [
        for (final j in jsonDecode(brut) as List)
          Personnage.depuisJson(j as Map<String, dynamic>),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Stream<List<Personnage>> ecouter() {
    late StreamController<List<Personnage>> sortie;
    StreamSubscription<List<Personnage>>? enLigne;
    StreamSubscription<void>? attente;
    List<Personnage>? dernier;
    sortie = StreamController<List<Personnage>>(
      onListen: () {
        enLigne = distant.ecouter().listen((l) {
          dernier = l;
          unawaited(_garderMiroir(l));
          sortie.add(_fusion(l));
        }, onError: sortie.addError);
        attente = _changements.stream.listen((_) {
          if (dernier case final l?) sortie.add(_fusion(l));
        });
      },
      onCancel: () async {
        await enLigne?.cancel();
        await attente?.cancel();
      },
    );
    return sortie.stream;
  }

  @override
  Future<void> sauvegarder(Personnage personnage) async {
    personnage.modifieLe = DateTime.now();
    _mettreEnAttente(personnage.id, personnage);
    await _garder();
    if (envoiImmediat()) await planifierEnvoi();
  }

  @override
  Future<void> supprimer(String id) async {
    _mettreEnAttente(id, null);
    await _garder();
    if (envoiImmediat()) await planifierEnvoi();
  }

  /// Numéro de version de chaque modification en attente : une fiche
  /// modifiée pendant un envoi reste en attente pour l'envoi suivant.
  final Map<String, int> _versions = {};

  void _mettreEnAttente(String id, Personnage? p) {
    _attente[id] = p;
    _versions[id] = (_versions[id] ?? 0) + 1;
  }

  /// Envoi automatique au plus tôt : tout de suite si le dernier envoi date
  /// d'au moins [delai], sinon à la fin du délai (les modifications d'ici
  /// là partent ensemble). Un envoi immédiat qui échoue lève l'erreur ; un
  /// envoi différé la signale à [surErreur].
  Future<void> planifierEnvoi() async {
    if (_minuterie != null || _envoiEnCours != null || _attente.isEmpty) {
      return;
    }
    final dernier = _dernierEnvoi;
    final reste = dernier == null
        ? Duration.zero
        : delai - _horloge().difference(dernier);
    if (reste <= Duration.zero) {
      // Hors connexion, l'envoi attend le réseau : pas l'application.
      final envoi = envoyer().whenComplete(() {
        _envoiEnCours = null;
        // Modifié pendant l'envoi : repart au prochain créneau.
        if (_attente.isNotEmpty && envoiImmediat()) unawaited(planifierEnvoi());
      });
      _envoiEnCours = envoi;
      await envoi.timeout(attenteReseau, onTimeout: () => 0);
      return;
    }
    _minuterie = Timer(reste, () async {
      _minuterie = null;
      try {
        await envoyer();
      } catch (e) {
        surErreur?.call(e);
      }
    });
  }

  /// Arrête l'envoi différé (déconnexion) ; les modifications restent
  /// gardées sur l'appareil.
  void fermer() {
    _minuterie?.cancel();
    _minuterie = null;
  }

  /// Envoie les modifications en attente ; renvoie leur nombre. Sans rien
  /// en attente : relit le compte (vérifie la connexion).
  Future<int> envoyer() async {
    _minuterie?.cancel();
    _minuterie = null;
    _dernierEnvoi = _horloge();
    final envoi = Map<String, Personnage?>.of(_attente);
    final versions = Map<String, int>.of(_versions);
    final n = envoi.length;
    if (n == 0) {
      await distant.tous();
    } else {
      final fiches = [
        for (final p in envoi.values)
          if (p != null) p,
      ];
      if (fiches.isNotEmpty) await distant.importer(fiches);
      for (final e in envoi.entries) {
        if (e.value == null) await distant.supprimer(e.key);
      }
      // Ce qui a été modifié pendant l'envoi reste en attente.
      for (final id in envoi.keys) {
        if (_versions[id] == versions[id]) {
          _attente.remove(id);
          _versions.remove(id);
        }
      }
      await _garder();
    }
    surEnvoi?.call();
    if (_attente.isNotEmpty && envoiImmediat()) await planifierEnvoi();
    return n;
  }

  @override
  Future<void> importer(List<Personnage> personnages) =>
      distant.importer(personnages);

  @override
  Future<void> toutSupprimer() async {
    _attente.clear();
    _versions.clear();
    fermer();
    await _garder();
    await distant.toutSupprimer();
  }
}

/// Fiches du compte quand Firebase ne répond pas du tout (web sans internet) :
/// la copie gardée sur l'appareil. Rien ne part en ligne ; les modifications
/// attendent dans [DepotDiffere] le prochain démarrage connecté.
class MiroirLocal implements DepotEnLigne {
  MiroirLocal(this.stockage, this.cle);

  final StockageCompte stockage;
  final String cle;

  @override
  Future<List<Personnage>> tous() => DepotDiffere.lireMiroir(stockage, cle);

  @override
  Stream<List<Personnage>> ecouter() => Stream.fromFuture(tous());

  @override
  Future<void> sauvegarder(Personnage personnage) async {}

  @override
  Future<void> supprimer(String id) async {}

  @override
  Future<void> importer(List<Personnage> personnages) async {}

  @override
  Future<void> toutSupprimer() async {}
}
