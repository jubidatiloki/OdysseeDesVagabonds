import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Préférences par défaut (31/10/2026) : menu latéral gardé ouvert (sur
/// grand écran), connaissances et aptitudes cachées sur la page dé.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sans réglage enregistré : menu ouvert, groupes du dé cachés', () async {
    SharedPreferences.setMockInitialValues({});
    final p = await PreferencesController.charger(PreferencesLocales());
    expect(p.menuEpingle, isTrue);
    for (final g in GroupeJets.values) {
      expect(p.affichage(g), AffichageGroupe.cache, reason: g.name);
      expect(p.groupeOuvert(g), isFalse, reason: g.name);
    }
  });

  test('un choix enregistré l\'emporte sur la valeur par défaut', () async {
    SharedPreferences.setMockInitialValues({
      'odv.preferences.menuEpingle': false,
    });
    final stockage = PreferencesLocales();
    await stockage.enregistrerReglage('de.affichage.connaissances', 'visible');
    final p = await PreferencesController.charger(stockage);
    expect(p.menuEpingle, isFalse);
    expect(p.groupeOuvert(GroupeJets.connaissances), isTrue);
    expect(p.groupeOuvert(GroupeJets.aptitudes), isFalse);
  });
}
