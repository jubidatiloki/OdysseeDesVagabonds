import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/screens/creation/etape_competences.dart';

/// Sorts de rang 0 (24/10/2026) : 1 point, 0 PM, une fois par tour, pas de
/// maintien ; classes lanceuses de sorts ou hybrides.

List<Aptitude> _sorts() => Referentiel.enregistrerSortsRang0([
      for (final e in jsonDecode(
        File('assets/data/sorts_rang0.json').readAsStringSync(),
      ) as List)
        Aptitude.depuisJson(e as Map<String, dynamic>),
    ]);

final _classes =
    (jsonDecode(File('assets/data/classes.json').readAsStringSync()) as List)
        .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
        .toList();
Classe _classe(String id) => _classes.firstWhere((c) => c.id == id);

final _humain =
    (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
        .map((e) => Race.depuisJson(e as Map<String, dynamic>))
        .firstWhere((r) => r.id == 'humain');

void main() {
  final sorts = _sorts();
  Aptitude sort(String id) => sorts.firstWhere((a) => a.id == id);

  test('22 sorts de rang 0, réservés aux classes magiques et hybrides', () {
    expect(sorts, hasLength(22));
    expect(sorts.every((a) => a.estSort && a.sort!.rang == 0), isTrue);
    // Étincelle : toutes les classes magiques ou hybrides
    final etincelle = sort('sort-etincelle');
    expect(etincelle.disponiblePour(_classe('magicien')), isTrue);
    expect(etincelle.disponiblePour(_classe('barde')), isTrue);
    expect(etincelle.disponiblePour(_classe('guerrier')), isFalse);
    // Épine : druide seulement
    expect(sort('sort-epine').disponiblePour(_classe('druide')), isTrue);
    expect(sort('sort-epine').disponiblePour(_classe('magicien')), isFalse);
    // Les aptitudes ordinaires restent pour tous
    const natation = Aptitude(id: 'natation', nom: 'Natation');
    expect(natation.disponiblePour(_classe('guerrier')), isTrue);
  });

  test('sort acquis : compétence « Sorts de rang 0 », 0 PM, dégâts sans bonus',
      () {
    final f = FicheCalculee(
      personnage: Personnage(
        id: 'm',
        nom: 'Ysolde',
        raceId: 'humain',
        classeId: 'magicien',
        aptitudes: const [AptitudeAcquise(id: 'sort-etincelle')],
        caracBase: {for (final c in Carac.values) c: 10}..[Carac.intel] = 16,
      ),
      race: _humain,
      classe: _classe('magicien'),
    );
    final acquis = f.competencesAcquises
        .firstWhere((c) => c.competence.nom == 'Étincelle');
    expect(acquis.voie.nom, 'Sorts de rang 0');
    final s = f.sorts.firstWhere((s) => s.competence.nom == 'Étincelle');
    expect(s.cout, 0);
    expect(FicheCalculee.coutSort(s.competence), (rang: 0, cout: 0));
    final degats = f.jetsEffetSort(s.competence).single;
    expect(degats.des, '1d4');
    expect(degats.bonus, 0); // pas de mod INT au rang 0
    expect(f.jetReussite(s.competence)!.carac, Carac.adm);
  });

  testWidgets('création : section Sorts de rang 0 selon la classe',
      (tester) async {
    tester.view.physicalSize = const Size(900, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Future<void> afficher(String classe) => tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EtapeCompetences(
                race: _humain,
                classe: _classe(classe),
                niveau: 1,
                rangsVoies: const {},
                aptitudes: const [],
                catalogueAptitudes: sorts,
                intFinale: 10,
                onChange: (_) {},
                onAptitudes: (_) {},
              ),
            ),
          ),
        );
    await afficher('druide');
    expect(find.byKey(const Key('titre-sorts-rang0')), findsOneWidget);
    expect(find.text('Épine'), findsOneWidget);
    expect(find.text('Main de mage'), findsNothing); // magicien seulement
    expect(find.text('0 PM'), findsWidgets);
    await afficher('guerrier');
    expect(find.byKey(const Key('titre-sorts-rang0')), findsNothing);
  });
}
