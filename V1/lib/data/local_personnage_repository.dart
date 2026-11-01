import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/personnage.dart';
import 'personnage_repository.dart';

/// Sauvegarde locale : la liste des personnages est stockée en JSON via
/// shared_preferences (SharedPreferences sur Android, NSUserDefaults sur iOS,
/// localStorage sur le web). Suffisant pour quelques dizaines de fiches.
/// Si le volume grossit (inventaires détaillés…), basculer vers une vraie
/// base locale (Drift/SQLite) en gardant la même interface.
class LocalPersonnageRepository implements PersonnageRepository {
  static const String _cle = 'odv.personnages.v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<List<Personnage>> tous() async {
    final prefs = await _prefs;
    final brut = prefs.getString(_cle);
    if (brut == null || brut.isEmpty) return [];
    final liste = jsonDecode(brut) as List;
    return liste
        .map((e) => Personnage.depuisJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> sauvegarder(Personnage personnage) async {
    final liste = await tous();
    personnage.modifieLe = DateTime.now();
    final i = liste.indexWhere((p) => p.id == personnage.id);
    if (i >= 0) {
      liste[i] = personnage;
    } else {
      liste.add(personnage);
    }
    await _ecrire(liste);
  }

  @override
  Future<void> supprimer(String id) async {
    final liste = await tous();
    liste.removeWhere((p) => p.id == id);
    await _ecrire(liste);
  }

  Future<void> _ecrire(List<Personnage> liste) async {
    final prefs = await _prefs;
    await prefs.setString(
      _cle,
      jsonEncode(liste.map((p) => p.versJson()).toList()),
    );
  }
}
