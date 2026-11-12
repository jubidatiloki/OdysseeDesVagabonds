import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/seance.dart';

void main() {
  test('adversaires identiques regroupés, dans l\'ordre d\'arrivée', () {
    expect(resumeAdversaires(['Aigle', 'Loup', 'Aigle 2', 'Aigle 3']),
        '3 Aigles, Loup');
    expect(resumeAdversaires(['Loup géant', 'Loup géant 2']), '2 Loups géants');
    expect(resumeAdversaires(<String>[]), '');
  });

  test('pluriel des noms de créatures', () {
    expect(pluriel('Ours'), 'Ours');
    expect(pluriel('Cheval'), 'Chevaux');
    expect(pluriel('Corbeau'), 'Corbeaux');
    expect(pluriel('Serviteur des ombres'), 'Serviteurs des ombres');
    expect(pluriel("Loup d'argent"), "Loups d'argent");
  });
}
