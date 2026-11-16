import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/echange_personnage.dart';
import 'package:odyssee_vagabonds/data/local_personnage_repository.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/race.dart';
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
    // Une case par fiche, plus la liste des identifiants (16/11/2026).
    expect(prefs.getString('odv.personnage.a'), contains('"Lia"'));
    expect(prefs.getString('odv.personnages.v2'), '["a"]');
  });

  test('supprimer retire le personnage du stockage', () async {
    final repo = LocalPersonnageRepository();
    await repo.sauvegarder(
      Personnage(id: 'a', nom: 'Lia', raceId: 'humain', classeId: 'voleur'),
    );
    await repo.supprimer('a');
    expect(await repo.tous(), isEmpty);
  });

  test('ancien format (une seule case) : migré, rien n\'est perdu', () async {
    final a = Personnage(id: 'a', nom: 'Lia', raceId: 'humain', classeId: 'v');
    final b = Personnage(id: 'b', nom: 'Brom', raceId: 'nain', classeId: 'g');
    SharedPreferences.setMockInitialValues({
      'odv.personnages.v1': jsonEncode([a.versJson(), b.versJson()]),
    });
    final repo = LocalPersonnageRepository();
    expect((await repo.tous()).map((p) => p.nom), ['Lia', 'Brom']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('odv.personnages.v1'), isNull);
    expect(prefs.getString('odv.personnage.b'), contains('"Brom"'));
    // Relu au chargement suivant, au nouveau format.
    expect(await LocalPersonnageRepository().tous(), hasLength(2));
  });

  test('une fiche abîmée n\'empêche pas de lire les autres', () async {
    final a = Personnage(id: 'a', nom: 'Lia', raceId: 'humain', classeId: 'v');
    SharedPreferences.setMockInitialValues({
      'odv.personnages.v2': '["a","b"]',
      'odv.personnage.a': jsonEncode(a.versJson()),
      'odv.personnage.b': '{abîmé',
    });
    final repo = LocalPersonnageRepository();
    expect((await repo.tous()).map((p) => p.nom), ['Lia']);
    // Sa case n'est pas effacée (récupérable).
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('odv.personnage.b'), '{abîmé');
  });

  test('espace plein : l\'échec est signalé, la fiche reste à l\'écran',
      () async {
    final controller = PersonnagesController(_RepoPlein());
    final p = Personnage(id: 'a', nom: 'Lia', raceId: 'humain', classeId: 'v');
    await controller.sauvegarder(p);
    expect(controller.erreurSauvegarde.value, contains('espace plein'));
    expect(controller.parId('a')?.nom, 'Lia');
  });

  test('sauvegarde complète : toutes les fiches, relues ensemble', () {
    const ref = Referentiel(
      races: [Race(id: 'nain', nom: 'Nain', deVie: 8, deMana: 4)],
      classes: [
        Classe(
          id: 'g',
          nom: 'Guerrier',
          modifDeVie: ModifDe.plus,
          modifDeMana: ModifDe.moins,
        ),
      ],
    );
    final texte = EchangePersonnage.exporterTout([
      Personnage(id: 'a', nom: 'Brom', raceId: 'nain', classeId: 'g'),
      Personnage(id: 'b', nom: 'Inconnu', raceId: 'troll', classeId: 'g'),
    ]);
    expect(EchangePersonnage.estSauvegarde(texte), isTrue);
    expect(EchangePersonnage.estSauvegarde('{"format":"autre"}'), isFalse);
    final lu = EchangePersonnage.lireTout(texte, ref);
    expect(lu.personnages.map((p) => p.nom), ['Brom']);
    expect(lu.ecartes, ['Inconnu']);
    expect(EchangePersonnage.nomSauvegarde(DateTime(2026, 11, 6)),
        'odv_sauvegarde_2026-11-06.json');
  });
}

/// Stockage qui refuse toute écriture (espace plein).
class _RepoPlein extends EnMemoirePersonnageRepository {
  @override
  Future<void> sauvegarder(Personnage personnage) async =>
      throw const ErreurStockage('Enregistrement impossible (espace plein ?).');
}
