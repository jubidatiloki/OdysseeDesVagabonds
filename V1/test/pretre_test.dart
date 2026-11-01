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
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/type_sort.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/des.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/savoirs.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/historique_lancers.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';

/// Prêtre : quatre voies adaptées (28/10/2026) — Bénédiction (3 états au
/// choix, +2 avec Lien vital), Foi, Lumière sacrée ×2, Courroux céleste ÷2,
/// Justice divine (arme invoquée, 5 PM par attaque), inquisiteur.

List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

final _classes = [
  for (final e in _json('classes.json'))
    Classe.depuisJson(e as Map<String, dynamic>),
];
final _pretre = _classes.firstWhere((c) => c.id == 'pretre');
final _humain = [
  for (final e in _json('races.json'))
    Race.depuisJson(e as Map<String, dynamic>),
].firstWhere((r) => r.id == 'humain');
final _aptitudes = [
  for (final e in _json('aptitudes.json'))
    Aptitude.depuisJson(e as Map<String, dynamic>),
];

Personnage _perso(Map<String, int> rangs, {Set<String> etats = const {}}) =>
    Personnage(
      id: 'p',
      nom: 'Aldric',
      raceId: 'humain',
      classeId: 'pretre',
      niveau: 9,
      rangsVoies: Map.of(rangs),
      etats: Set.of(etats),
      caracBase: {for (final c in Carac.values) c: 14},
    );

FicheCalculee _fiche(Map<String, int> rangs, {Set<String> etats = const {}}) =>
    FicheCalculee(
      personnage: _perso(rangs, etats: etats),
      race: _humain,
      classe: _pretre,
    );

int _tests(FicheCalculee f, Carac c) => f.bonusTestsPermanents
    .where((s) => s.effet.carac == c)
    .fold(0, (n, s) => n + (s.effet.valeurEntiere ?? 0));

void main() {
  Referentiel.completerReferences([_humain], _classes);
  final base = _fiche({});

  test('tous les actifs du prêtre sont des sorts typés', () {
    final f = _fiche({
      'pretre-soins': 5,
      'pretre-paladin': 5,
      'pretre-divin': 5,
      'pretre-inquisiteur': 5,
    });
    final noms = {for (final s in f.sorts) s.competence.nom: s};
    for (final n in [
      'Résurrection',
      'Bénédiction',
      'Délivrance',
      'Lien vital',
      'Glas de soutien',
      'Courroux céleste',
      'Justice divine',
      'Paroles impies',
      'Consumation',
    ]) {
      expect(noms[n], isNotNull, reason: n);
      expect(noms[n]!.competence.typesSort, isNotEmpty, reason: n);
    }
    expect(noms['Résurrection']!.cout, 15);
    expect(noms['Bénédiction']!.cout, 1);
    expect(noms['Justice divine']!.cout, 0);
    expect(noms['Paroles impies']!.competence.typesSort,
        [TypeSort.controleMental]);
    // Martyr +2 CON, Inquisition +2 INT.
    expect(f.carac(Carac.con), base.carac(Carac.con) + 2);
    expect(f.carac(Carac.intel), base.carac(Carac.intel) + 2);
  });

  test('bénédiction : trois états exclusifs, +2 avec Lien vital', () {
    final f = _fiche({'pretre-paladin': 1});
    final etats = f.etatsPossibles
        .where((e) => e.competence.nom == 'Bénédiction')
        .map((e) => e.etat)
        .toList();
    expect(etats.map((e) => e.nom), [
      'Bénédiction (arme)',
      'Bénédiction (armure)',
      'Bénédiction (personne)',
    ]);
    expect(etats.every((e) => e.groupe == 'benediction'), isTrue);
    final arme = _fiche({'pretre-paladin': 1}, etats: {'Bénédiction (arme)'});
    expect(_tests(arme, Carac.adc), _tests(f, Carac.adc) + 1);
    expect(arme.detailDegatsCac.bonusMainsNues,
        f.detailDegatsCac.bonusMainsNues + 1);
    final armure =
        _fiche({'pretre-paladin': 3}, etats: {'Bénédiction (armure)'});
    expect(armure.classeArmure, _fiche({'pretre-paladin': 3}).classeArmure + 2);
  });

  test("foi, sanctuaire, prémices de l'inquisition", () {
    final foi = _fiche({'pretre-divin': 3});
    expect(foi.caMagie, base.caMagie + 3);
    final religions = jetsSavoirs(foi, _aptitudes, FamilleAptitude.savoir)
        .firstWhere((j) => j.aptitude.id == 'religions');
    expect(religions.bonus.single.valeur, 3);
    final sanctuaire = _fiche({'pretre-divin': 3}, etats: {'Sanctuaire'});
    expect(sanctuaire.caMagie, foi.caMagie + 2);
    final inq = _fiche({'pretre-inquisiteur': 1});
    expect(
      inq.bonusTestsSituationnels
          .where((s) => s.effet.condition == 'contre morts-vivants et démons')
          .length,
      2,
    );
  });

  test('lumière ×2, courroux ÷2, consumation, arme divine', () {
    final f = _fiche({'pretre-divin': 5, 'pretre-inquisiteur': 4});
    Competence sort(String n) =>
        f.sorts.firstWhere((s) => s.competence.nom == n).competence;
    expect(sort('Lumière sacrée').variantesDegats.single.multiplie, 2);
    final courroux = sort('Courroux céleste');
    expect(courroux.variantesDegats.single.divise, 2);
    expect(f.jetsEffetSort(courroux).single.des, '4d6');
    expect(f.jetsEffetSort(courroux).single.bonus, f.degatsMagie);
    final conso = f.jetsEffetSort(sort('Consumation')).single;
    expect((conso.des, conso.bonus), ('3d6', 0));
    // Justice divine : l'attaque n'est pas lancée avec le sort.
    expect(f.jetsEffetSort(sort('Justice divine')), isEmpty);
    final j = f.jetsCompetences.firstWhere((j) => j.libelle == 'Arme divine');
    expect(j.coutPm, 5);
    final d = degatsAttaque(f, j, null);
    expect(d.des, '2d6');
    expect(d.fixes.single.valeur, f.mod(Carac.intel));
    final r = ResultatLancer(
      libelle: 'x',
      formule: '1d8',
      des: const [3],
      garde: 3,
      bonus: 2,
    );
    expect(r.multiplie(2).total, 10);
    expect(r.divise(2).total, 2);
  });

  Future<(PersonnagesController, HistoriqueLancers)> ouvrir(
    WidgetTester tester,
    Personnage p,
  ) async {
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
        referentiel: Referentiel(races: [_humain], classes: _classes),
        personnages: controller,
        preferences: PreferencesController(personnageActifId: 'p'),
        historique: historique,
        aleatoire: Random(4),
      ),
    ));
    await tester.pumpAndSettle();
    return (controller, historique);
  }

  Future<void> toucher(WidgetTester tester, Key k) async {
    await tester.ensureVisible(find.byKey(k));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(k));
    await tester.pumpAndSettle();
  }

  testWidgets('page dé : lumière sacrée ×2, arme divine à 5 PM',
      (tester) async {
    final p = _perso({'pretre-divin': 5})..pmActuels = 7;
    final (controller, historique) = await ouvrir(tester, p);
    final f = FicheCalculee(personnage: p, race: _humain, classe: _pretre);
    final s = f.sorts.indexWhere((s) => s.competence.nom == 'Lumière sacrée');
    await toucher(tester, Key('effet-sort-$s-0'));
    expect(
        historique.lancers.first.situations.any((x) => x.nom == '×2'), isTrue);
    // Arme divine : avec les attaques, 5 PM par attaque.
    final noms = {for (final s in f.sorts) s.competence.nom};
    final horsSorts = [
      for (final j in f.jetsCompetences)
        if (!noms.contains(j.origine) || j.attaque != null) j,
    ];
    final i = horsSorts.indexWhere((j) => j.libelle == 'Arme divine');
    await toucher(tester, Key('jet-competence-$i'));
    expect(controller.personnages.single.pmActuels, 2);
    // Plus assez de PM : bouton grisé.
    final bouton = tester.widget<OutlinedButton>(find.descendant(
        of: find.byKey(Key('jet-competence-$i')),
        matching: find.byType(OutlinedButton)));
    expect(bouton.onPressed, isNull);
  });
}
