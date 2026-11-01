import 'package:flutter/foundation.dart';

import '../regles/des.dart';

/// Historique des lancers de la page Lancer de dé, conservé pendant que
/// l'application est ouverte (on peut changer de page sans le perdre).
class HistoriqueLancers extends ChangeNotifier {
  static const int taille = 50;

  final List<ResultatLancer> _lancers = [];

  /// Du plus récent au plus ancien.
  List<ResultatLancer> get lancers => List.unmodifiable(_lancers);

  void ajouter(ResultatLancer lancer) {
    _lancers.insert(0, lancer);
    if (_lancers.length > taille) _lancers.removeLast();
    notifyListeners();
  }

  void effacer() {
    _lancers.clear();
    notifyListeners();
  }
}
