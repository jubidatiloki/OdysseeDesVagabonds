import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/carac.dart';

/// Charisme (CHA) renommé Mental (MEN) le 29/10/2026 : les anciennes
/// sauvegardes et données « CHA » sont lues comme MEN.
void main() {
  test('MEN remplace CHA, anciennes sauvegardes converties', () {
    expect(Carac.men.code, 'MEN');
    expect(Carac.men.nom, 'Mental');
    expect(Carac.depuisCode('CHA'), Carac.men);
    expect(Carac.depuisCode('cha'), Carac.men);
    expect(Carac.depuisCode('CHAN'), Carac.chan);
    final m = caracMapDepuisJson({'CHA': 12, 'CHAN': 10});
    expect(m[Carac.men], 12);
    expect(m[Carac.chan], 10);
    expect(caracMapVersJson(m), {'MEN': 12, 'CHAN': 10});
  });
}
