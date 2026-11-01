import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/widgets/types_competence.dart';

List<String> _libelles(String type) =>
    analyserTypeCompetence(type).map((t) => t.libelle).toList();

void main() {
  test('types de compétence reconnus avec leur icône', () {
    expect(_libelles('passif'), ['Passif']);
    expect(_libelles('actif complexe, compétence'),
        ['Actif', 'Compétence', 'Complexe']);
    expect(_libelles('actif, sort, maintenu'), ['Actif', 'Sort', 'Maintenu']);
    expect(_libelles('passif + renforcement'), ['Passif', 'Renforcement']);
    expect(_libelles('gratuit, 1×/combat'), ['Gratuite', '1×/combat']);
    expect(_libelles('sort, coût rang 2'), ['Sort', 'Coût rang 2']);
    expect(_libelles('action de mouvement'), ['Mouvement']);
    expect(_libelles(''), isEmpty);
  });
}
