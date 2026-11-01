import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/effet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/historique_lancers.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';

/// Druide : quatre voies adaptées (25/10/2026) — animal de compagnie,
/// sorts, peau d'écorce, situations d'initiative et de savoirs.

final _classes =
    (jsonDecode(File('assets/data/classes.json').readAsStringSync()) as List)
        .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
        .toList();
final _druide = _classes.firstWhere((c) => c.id == 'druide');
final _humain =
    (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
        .map((e) => Race.depuisJson(e as Map<String, dynamic>))
        .firstWhere((r) => r.id == 'humain');
final _aptitudes =
    (jsonDecode(File('assets/data/aptitudes.json').readAsStringSync()) as List)
        .map((e) => Aptitude.depuisJson(e as Map<String, dynamic>))
        .toList();

Personnage _perso({
  Map<String, int> rangs = const {},
  Map<String, String> choix = const {},
}) =>
    Personnage(
      id: 'd',
      nom: 'Sylvain',
      raceId: 'humain',
      classeId: 'druide',
      niveau: 9,
      rangsVoies: Map.of(rangs),
      choix: Map.of(choix),
      caracBase: {for (final c in Carac.values) c: 12},
    );

FicheCalculee _fiche({
  Map<String, int> rangs = const {},
  Map<String, String> choix = const {},
}) =>
    FicheCalculee(
      personnage: _perso(rangs: rangs, choix: choix),
      race: _humain,
      classe: _druide,
    );

void main() {
  Referentiel.completerReferences([_humain], _classes);

  test('animal de compagnie : +2 à la stat, +4 dès le rang 3, compagnon', () {
    final base = _fiche();
    final r1 = _fiche(
        rangs: {'druide-bestiale': 1}, choix: {'animal-druide': 'panthere'});
    final r3 = _fiche(
        rangs: {'druide-bestiale': 3}, choix: {'animal-druide': 'panthere'});
    // Bonus aux tests seulement : la caractéristique ne change pas.
    int tests(FicheCalculee f, Carac c) => f.bonusTestsPermanents
        .where((s) => s.effet.carac == c)
        .fold(0, (n, s) => n + (s.effet.valeurEntiere ?? 0));
    expect(r1.carac(Carac.dex), base.carac(Carac.dex));
    expect(r3.carac(Carac.dex), base.carac(Carac.dex));
    expect(tests(r1, Carac.dex), 2);
    expect(tests(r3, Carac.dex), 4);
    expect(
      r1.objetsARecevoir.any((o) =>
          o.objet['nom'] == 'Panthère' && o.objet['categorie'] == 'compagnon'),
      isTrue,
    );
    // Les 8 animaux, une caractéristique chacun.
    final options = _druide.voies.first.competence(1)!.choix!.options;
    expect(options.map((o) => o.id), [
      'jeune-ours',
      'panthere',
      'sanglier',
      'chouette',
      'aigle',
      'chien',
      'loup',
      'lievre',
    ]);
    expect(options.first.nom, 'Jeune ours (+2 aux tests de FOR)');
    final ours = _fiche(
        rangs: {'druide-bestiale': 1}, choix: {'animal-druide': 'jeune-ours'});
    expect(tests(ours, Carac.force), 2);
    // Pas de dégâts en plus au corps à corps.
    expect(ours.degatsCac, base.degatsCac);
    // Animal de combat : 1d20 + RANG + AdC, 1d8.
    final attaque =
        r3.jetsCompetences.firstWhere((j) => j.libelle == 'Animal : attaque');
    expect(attaque.des, '1d20 + 3');
    expect(attaque.carac, Carac.adc);
    expect(
        r3.jetsCompetences.any((j) => j.libelle == 'Animal : dégâts'), isTrue);
  });

  test('sorts : coût selon le rang, soin + INT, tempête 4d6 + INT', () {
    final f = _fiche(rangs: {
      'druide-bestiale': 5,
      'druide-protecteur': 5,
      'druide-nature': 5,
      'druide-vegetaux': 5,
    });
    final sorts = {for (final s in f.sorts) s.competence.nom: s};
    expect(
        sorts.keys,
        containsAll([
          'Transformation minime',
          'Mutation partielle',
          'Transformation majeure',
          'Écorces partagées',
          'Brume',
          'Pissenlit protecteur',
          'Fruit de la vie',
          'Invocation animal',
          'Tempête menaçante',
          'Se fondre dans la nature',
          'Lianes immobilisantes',
          'Arbrification',
          'Plante carnivore',
        ]));
    expect(sorts['Brume']!.rangSort, 3);
    expect(sorts['Plante carnivore']!.cout, FicheCalculee.coutsSorts[4]);
    // Passifs : pas des sorts.
    expect(sorts.containsKey('Peau d\'écorce'), isFalse);
    final fruit = f
        .jetsEffetSort(sorts['Fruit de la vie']!.competence)
        .firstWhere((j) => j.libelle.endsWith('soin'));
    expect(fruit.des, '1d6');
    expect(fruit.carac, Carac.intel);
    expect(fruit.bonus, f.mod(Carac.intel));
    final tempete = f
        .jetsEffetSort(sorts['Tempête menaçante']!.competence)
        .firstWhere((j) => j.libelle.endsWith('dégâts'));
    expect(tempete.des, '4d6');
    expect(tempete.bonus, f.degatsMagie);
    // Arbrification : soin aux dés seuls (pas de « + INT » écrit).
    final arbre = f
        .jetsEffetSort(sorts['Arbrification']!.competence)
        .firstWhere((j) => j.libelle.endsWith('soin'));
    expect(arbre.bonus, 0);
    // +2 CON (tempête).
    expect(f.carac(Carac.con), _fiche().carac(Carac.con) + 2);
  });

  test('peau d\'écorce : +1 CA CaC et DIST, +2 dès le rang 3', () {
    final base = _fiche();
    final r1 = _fiche(rangs: {'druide-protecteur': 1});
    final r3 = _fiche(rangs: {'druide-protecteur': 3});
    expect(r1.caCac, base.caCac + 1);
    expect(r1.caDistance, base.caDistance + 1);
    expect(r3.caCac, base.caCac + 2);
    expect(r3.caDistance, base.caDistance + 2);
    expect(r3.caMagie, base.caMagie);
    // Instinct de survie : PER diff. 18.
    final instinct = _fiche(rangs: {'druide-protecteur': 4})
        .jetsCompetences
        .firstWhere((j) => j.libelle == 'Instinct de survie');
    expect(instinct.carac, Carac.per);
    expect(instinct.difficulte, 18);
  });

  test('situations : initiative, savoirs ciblés, calme animal', () {
    final f = _fiche(rangs: {'druide-nature': 2, 'druide-vegetaux': 2});
    final hors = f.situationsHorsTests;
    final enfant = hors.firstWhere((s) => s.nom == 'Enfant de la nature');
    expect(enfant.effet.valeurEntiere, 4); // 2 × rang 2
    expect(enfant.effet.categorie, contains('Survie'));
    expect(
      hors.any((s) =>
          s.nom == 'Se fondre dans la nature' &&
          s.effet.categorie == 'Discrétion'),
      isTrue,
    );
    final sylvestre = f.bonusTestsSituationnels
        .where((s) => s.nom == 'Vie sylvestre')
        .toList();
    expect(sylvestre.map((s) => s.effet.libelle), [
      '+3 à l\'initiative (entouré de végétation)',
      '+2 aux tests de PER (entouré de végétation)',
    ]);
    expect(
      f.bonusTestsSituationnels
          .firstWhere((s) => s.nom == 'Calme animal')
          .effet
          .valeurEntiere,
      4,
    );
    // Les bonus de savoir à cocher ne s'ajoutent pas d'office.
    expect(
      const Effet(
        type: 'savoir',
        categorie: 'Discrétion',
        valeur: '5',
        condition: 'en nature',
      ).libelle,
      '+5 aux tests de : Discrétion (en nature)',
    );
  });

  Future<HistoriqueLancers> ouvrir(WidgetTester tester, Personnage p) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    final historique = HistoriqueLancers();
    addTearDown(historique.dispose);
    await tester.pumpWidget(MaterialApp(
      home: DeScreen(
        referentiel: Referentiel(
          races: [_humain],
          classes: _classes,
          aptitudes: _aptitudes,
        ),
        personnages: controller,
        preferences: PreferencesController(
          personnageActifId: 'd',
          // Groupes de la page dé ouverts (cachés par défaut).
          affichages: {
            for (final g in GroupeJets.values) g: AffichageGroupe.visible,
          },
        ),
        historique: historique,
        aleatoire: Random(2),
      ),
    ));
    await tester.pumpAndSettle();
    return historique;
  }

  testWidgets('page dé : +3 initiative et +5 Discrétion seulement cochés',
      (tester) async {
    final historique =
        await ouvrir(tester, _perso(rangs: {'druide-vegetaux': 2}));
    expect(find.byKey(const Key('groupe-situation-init')), findsOneWidget);
    expect(find.byKey(const Key('groupe-situation-savoirs')), findsOneWidget);
    Future<void> toucher(Key k) async {
      await tester.ensureVisible(find.byKey(k));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(k));
      await tester.pumpAndSettle();
    }

    // Initiative : une valeur (DEX + bonus), +3 quand la situation est cochée.
    String initiative() => tester
        .widget<Text>(find.descendant(
            of: find.byKey(const Key('initiative-actuelle')),
            matching: find.byType(Text)))
        .data!;
    final avant = int.parse(initiative().split(' ').last);
    await toucher(const Key(
        'situation-Vie sylvestre|+3 à l\'initiative (entouré de végétation)'));
    expect(initiative(), 'Initiative ${avant + 3}');
    await toucher(const Key('situation-Se fondre dans la nature|'
        '+5 aux tests de : Discrétion (en nature)'));
    // Un test de DEX ne prend pas le +3 d'initiative.
    await toucher(const Key('test-DEX'));
    expect(historique.lancers.first.situations, isEmpty);
    // Discrétion : +5 ; Escalade non.
    await toucher(const Key('jet-savoir-discretion'));
    expect(historique.lancers.first.situations,
        contains((nom: 'Se fondre dans la nature', valeur: 5)));
    await toucher(const Key('jet-savoir-escalade'));
    expect(
        historique.lancers.first.situations
            .any((s) => s.nom == 'Se fondre dans la nature'),
        isFalse);
  });
}
