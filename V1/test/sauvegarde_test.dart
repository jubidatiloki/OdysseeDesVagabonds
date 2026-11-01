import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/local_personnage_repository.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('un personnage sauvegardé est relu par un nouveau chargement', () async {
    // Première « session » : création et sauvegarde
    final session1 = PersonnagesController(LocalPersonnageRepository());
    await session1.charger();
    expect(session1.personnages, isEmpty);
    await session1.sauvegarder(
      Personnage(
        id: 'brom',
        nom: 'Brom',
        sexe: Sexe.homme,
        raceId: 'nain',
        classeId: 'guerrier',
        caracBase: {for (final c in Carac.values) c: 10}..[Carac.force] = 16,
        rangsVoies: {'guerrier-bouclier': 1},
        aptitudes: [const AptitudeAcquise(id: 'langue', precision: 'Elfique')],
      ),
    );

    // Deuxième « session » : nouveau contrôleur, nouveau dépôt
    final session2 = PersonnagesController(LocalPersonnageRepository());
    await session2.charger();
    expect(session2.personnages, hasLength(1));
    final p = session2.personnages.single;
    expect(p.nom, 'Brom');
    expect(p.sexe, Sexe.homme);
    expect(p.caracBase[Carac.force], 16);
    expect(p.rangsVoies, {'guerrier-bouclier': 1});
    expect(p.aptitudes.single.precision, 'Elfique');
  });

  test('les données sont bien écrites dans le stockage de l\'appareil',
      () async {
    final repo = LocalPersonnageRepository();
    await repo.sauvegarder(
      Personnage(id: 'a', nom: 'Lia', raceId: 'humain', classeId: 'voleur'),
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('odv.personnages.v1'), contains('"Lia"'));
  });

  test('supprimer retire le personnage du stockage', () async {
    final repo = LocalPersonnageRepository();
    await repo.sauvegarder(
      Personnage(id: 'a', nom: 'Lia', raceId: 'humain', classeId: 'voleur'),
    );
    await repo.supprimer('a');
    expect(await repo.tous(), isEmpty);
  });
}
