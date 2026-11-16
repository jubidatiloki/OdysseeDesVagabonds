import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/personnage.dart';
import 'compte.dart';
import 'personnage_repository.dart';

/// Échec d'écriture sur l'appareil (espace plein, stockage refusé).
class ErreurStockage implements Exception {
  const ErreurStockage(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Sauvegarde locale via shared_preferences (SharedPreferences sur Android,
/// localStorage sur le web) : **une case par fiche** (16/11/2026), plus la
/// liste de leurs identifiants. Enregistrer une fiche ne réécrit qu'elle ;
/// une fiche abîmée n'empêche pas de lire les autres ; un échec d'écriture
/// (espace plein) est signalé au lieu de passer inaperçu.
class LocalPersonnageRepository implements PersonnageRepository {
  /// Ancien format : toutes les fiches dans une seule case (migré).
  static const String cleAncienne = 'odv.personnages.v1';

  /// Liste des identifiants des fiches.
  static const String cleListe = 'odv.personnages.v2';

  /// Case d'une fiche.
  static String cleFiche(String id) => 'odv.personnage.$id';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<List<Personnage>> tous() async {
    final prefs = await _prefs;
    final ids = await _ids(prefs);
    final res = <Personnage>[];
    for (final id in ids) {
      final brut = prefs.getString(cleFiche(id));
      if (brut == null || brut.isEmpty) continue;
      try {
        res.add(
            Personnage.depuisJson(jsonDecode(brut) as Map<String, dynamic>));
      } catch (e) {
        // Fiche abîmée : les autres restent lisibles ; sa case est gardée
        // telle quelle (elle n'est jamais effacée ici).
        debugPrint('Fiche $id illisible : $e');
      }
    }
    return res;
  }

  /// Identifiants des fiches ; migre l'ancien format au premier passage.
  Future<List<String>> _ids(SharedPreferences prefs) async {
    final liste = prefs.getString(cleListe);
    if (liste != null) {
      try {
        return [for (final id in jsonDecode(liste) as List) '$id'];
      } catch (_) {
        // Liste abîmée : retrouvée à partir des cases des fiches.
        return [
          for (final k in prefs.getKeys())
            if (k.startsWith('odv.personnage.')) k.substring(15),
        ];
      }
    }
    final ancien = prefs.getString(cleAncienne);
    if (ancien == null || ancien.isEmpty) return const [];
    final fiches = jsonDecode(ancien) as List;
    final ids = <String>[];
    for (final f in fiches) {
      final j = f as Map<String, dynamic>;
      final id = '${j['id']}';
      await _ecrireCase(prefs, cleFiche(id), jsonEncode(j));
      ids.add(id);
    }
    await _ecrireCase(prefs, cleListe, jsonEncode(ids));
    // Tout est recopié : l'ancienne case libère sa place.
    await prefs.remove(cleAncienne);
    return ids;
  }

  @override
  Future<void> sauvegarder(Personnage personnage) async {
    final prefs = await _prefs;
    final ids = await _ids(prefs);
    personnage.modifieLe = DateTime.now();
    // La fiche d'abord, puis la liste : jamais d'identifiant sans fiche.
    await _ecrireCase(
      prefs,
      cleFiche(personnage.id),
      jsonEncode(personnage.versJson()),
    );
    if (!ids.contains(personnage.id)) {
      await _ecrireCase(prefs, cleListe, jsonEncode([...ids, personnage.id]));
    }
  }

  @override
  Future<void> supprimer(String id) async {
    final prefs = await _prefs;
    final ids = await _ids(prefs);
    await _ecrireCase(
      prefs,
      cleListe,
      jsonEncode([
        for (final x in ids)
          if (x != id) x,
      ]),
    );
    await prefs.remove(cleFiche(id));
  }

  static Future<void> _ecrireCase(
    SharedPreferences prefs,
    String cle,
    String valeur,
  ) async {
    bool ok;
    try {
      ok = await prefs.setString(cle, valeur);
    } catch (e) {
      ok = false;
    }
    if (!ok) {
      throw const ErreurStockage(
        'Enregistrement impossible sur cet appareil (espace plein ?). '
        'Exporte tes fiches (page Personnages) ou connecte-toi à un compte.',
      );
    }
  }
}

/// Réglages du compte sur l'appareil (localStorage sur le web).
class StockageCompteLocal implements StockageCompte {
  @override
  Future<String?> lire(String cle) async =>
      (await SharedPreferences.getInstance()).getString('odv.compte.$cle');

  @override
  Future<void> ecrire(String cle, String? valeur) async {
    final prefs = await SharedPreferences.getInstance();
    if (valeur == null) {
      await prefs.remove('odv.compte.$cle');
    } else {
      await prefs.setString('odv.compte.$cle', valeur);
    }
  }
}
