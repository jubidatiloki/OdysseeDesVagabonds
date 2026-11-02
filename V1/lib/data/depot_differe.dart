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
class DepotDiffere implements DepotEnLigne {
  DepotDiffere(
    this.distant, {
    required this.envoiImmediat,
    required this.stockage,
    required this.cle,
    this.surEnvoi,
    this.surAttente,
  });

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

  /// Fiches modifiées en attente d'envoi (`null` : fiche supprimée).
  final Map<String, Personnage?> _attente = {};
  final _changements = StreamController<void>.broadcast();

  int get nbEnAttente => _attente.length;

  /// Relit les modifications en attente gardées sur l'appareil.
  Future<void> charger() async {
    _attente.clear();
    final brut = await stockage.lire(cle);
    if (brut == null || brut.isEmpty) return;
    try {
      final m = jsonDecode(brut) as Map<String, dynamic>;
      for (final e in m.entries) {
        _attente[e.key] = e.value == null
            ? null
            : Personnage.depuisJson(e.value as Map<String, dynamic>);
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

  @override
  Future<List<Personnage>> tous() async => _fusion(await distant.tous());

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
    if (envoiImmediat()) {
      await distant.importer([personnage]);
      if (_attente.remove(personnage.id) != null) await _garder();
      surEnvoi?.call();
    } else {
      _attente[personnage.id] = personnage;
      await _garder();
    }
  }

  @override
  Future<void> supprimer(String id) async {
    if (envoiImmediat()) {
      await distant.supprimer(id);
      if (_attente.containsKey(id)) {
        _attente.remove(id);
        await _garder();
      }
      surEnvoi?.call();
    } else {
      _attente[id] = null;
      await _garder();
    }
  }

  /// Envoie les modifications en attente ; renvoie leur nombre. Sans rien
  /// en attente : relit le compte (vérifie la connexion).
  Future<int> envoyer() async {
    final n = _attente.length;
    if (n == 0) {
      await distant.tous();
    } else {
      final fiches = [
        for (final p in _attente.values)
          if (p != null) p,
      ];
      if (fiches.isNotEmpty) await distant.importer(fiches);
      for (final e in _attente.entries) {
        if (e.value == null) await distant.supprimer(e.key);
      }
      _attente.clear();
      await _garder();
    }
    surEnvoi?.call();
    return n;
  }

  @override
  Future<void> importer(List<Personnage> personnages) =>
      distant.importer(personnages);

  @override
  Future<void> toutSupprimer() async {
    _attente.clear();
    await _garder();
    await distant.toutSupprimer();
  }
}
