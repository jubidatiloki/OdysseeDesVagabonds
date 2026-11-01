import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/type_sort.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/historique_lancers.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';

/// Nécromancien : quatre voies adaptées (28/10/2026) — actifs devenus des
/// sorts, rituels payés en PV, épée sanguine, marque de sang (+2d6 + INT au
/// prochain coup), siphon d'âme selon la taille, invocations à dés seuls.

List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

final _classes = [
  for (final e in _json('classes.json'))
    Classe.depuisJson(e as Map<String, dynamic>),
];
final _necro = _classes.firstWhere((c) => c.id == 'necromancien');
final _humain = [
  for (final e in _json('races.json'))
    Race.depuisJson(e as Map<String, dynamic>),
].firstWhere((r) => r.id == 'humain');

const _tout = {
  'necromancien-mort': 5,
  'necromancien-morts-vivants': 5,
  'necromancien-invocation': 5,
  'necromancien-rituels': 5,
};

Personnage _perso(Map<String, int> rangs,
        {Set<String> etats = const {}, Map<String, String> choix = const {}}) =>
    Personnage(
      id: 'n',
      nom: 'Morvane',
      raceId: 'humain',
      classeId: 'necromancien',
      niveau: 9,
      rangsVoies: Map.of(rangs),
      etats: Set.of(etats),
      choix: Map.of(choix),
      caracBase: {for (final c in Carac.values) c: 14},
    );

FicheCalculee _fiche(Map<String, int> rangs,
        {Set<String> etats = const {}, Map<String, String> choix = const {}}) =>
    FicheCalculee(
      personnage: _perso(rangs, etats: etats, choix: choix),
      race: _humain,
      classe: _necro,
    );

void main() {
  Referentiel.completerReferences([_humain], _classes);
  final base = _fiche({});

  test('sorts, coûts, types, bonus de stats et usage', () {
    final f = _fiche(_tout, choix: {'familier-necromancien': 'corbeau'});
    final sorts = {for (final s in f.sorts) s.competence.nom: s};
    for (final n in [
      'Récits du passé',
      'Afflux mortuaire',
      'Présage de mort',
      'Fidèle serviteur',
      'Fidèle et puissant serviteur',
      'Requiem',
      'Ténèbres',
      'Démon',
      'Rituel du sang',
      'Rituel des os',
      'Rituel sanguinaire',
      'Rituel de la lune',
      'Rituel abominable',
    ]) {
      expect(sorts[n], isNotNull, reason: n);
      expect(sorts[n]!.competence.typesSort, isNotEmpty, reason: n);
    }
    expect(sorts['Présage de mort']!.cout, 15);
    expect(sorts['Rituel du sang']!.cout, 0);
    expect(sorts['Rituel sanguinaire']!.cout, 0);
    expect(
        sorts['Ténèbres']!.competence.typesSort, [TypeSort.controlePhysique]);
    expect(f.carac(Carac.intel), base.carac(Carac.intel) + 2);
    expect(f.carac(Carac.per), base.carac(Carac.per) + 2);
    expect(f.usages.single.nom, 'Présage de mort');
    expect(f.objetsARecevoir.map((o) => o.objet['nom']), contains('Corbeau'));
    // Serviteur permanent : compétence à part (pas lancée avec le sort).
    expect(
        f.jetsCompetences
            .firstWhere((j) => j.libelle == 'Sacrifice : PV max')
            .origine,
        'Serviteur permanent');
  });

  test('afflux, invocations à dés seuls, siphon d\'âme', () {
    final f = _fiche(_tout);
    Competence sort(String n) =>
        f.sorts.firstWhere((s) => s.competence.nom == n).competence;
    final afflux = f.jetsEffetSort(sort('Afflux mortuaire'));
    expect(afflux.map((j) => (j.des, j.bonus)),
        [('3d6', f.degatsMagie), ('3d6', f.degatsMagie)]);
    final diablotin = f.jetsEffetSort(sort('Diablotin'));
    expect(diablotin.map((j) => (j.libelle, j.des, j.bonus)), [
      ('Diablotin · dégâts', '1d6', 0),
      ('Diablotin : durée (tours)', '1d4', f.mod(Carac.intel)),
    ]);
    expect(
        f
            .jetsEffetSort(sort('Molosse des abysses'))
            .firstWhere((j) => j.libelle.contains('dégâts'))
            .bonus,
        0);
    final siphon = [
      for (final j in f.jetsCompetences)
        if (j.origine == "Siphon d'âme") (j.des, j.applique),
    ];
    expect(siphon, [('1d4', '+pv'), ('1d6', '+pv'), ('2d6', '+pv')]);
  });

  test('rituels : PV dépensés, épée sanguine, os, marque de sang', () {
    final f = _fiche({'necromancien-rituels': 3});
    Competence sort(String n) =>
        f.sorts.firstWhere((s) => s.competence.nom == n).competence;
    final sang = f.jetsEffetSort(sort('Rituel du sang'));
    expect(sang.map((j) => (j.des, j.applique)), [('1d4', '-pv')]);
    final epee =
        f.jetsCompetences.firstWhere((j) => j.libelle == 'Épée sanguine');
    final d = degatsAttaque(f, epee, null);
    expect(d.des, '1d6');
    expect(d.bonus, 0);
    expect(d.fixes.single.valeur, f.mod(Carac.intel));
    final os = _fiche({'necromancien-rituels': 2}, etats: {'Rituel des os'});
    expect(os.resistances.single.type, 'physique');
    expect(os.resistances.single.total, 2);
    final marque =
        _fiche({'necromancien-rituels': 3}, etats: {'Marque de sang'});
    final enPlus = marque.desEnPlus(null).map((s) => s.effet.valeur);
    expect(enPlus, containsAll(['2d6', '${marque.mod(Carac.intel)}']));
    expect(marque.detailDegatsCac.bonusMainsNues,
        f.detailDegatsCac.bonusMainsNues + marque.mod(Carac.intel));
  });

  testWidgets('page dé : rituel du sang retire des PV et active l\'épée',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = _perso({'necromancien-rituels': 1});
    final depart =
        FicheCalculee(personnage: p, race: _humain, classe: _necro).pvMax;
    p.pvActuels = depart;
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    final historique = HistoriqueLancers();
    addTearDown(historique.dispose);
    await tester.pumpWidget(MaterialApp(
      home: DeScreen(
        referentiel: Referentiel(races: [_humain], classes: _classes),
        personnages: controller,
        preferences: PreferencesController(personnageActifId: 'n'),
        historique: historique,
        aleatoire: Random(4),
      ),
    ));
    await tester.pumpAndSettle();
    final f = FicheCalculee(personnage: p, race: _humain, classe: _necro);
    final i = f.sorts.indexWhere((s) => s.competence.nom == 'Rituel du sang');
    await tester.ensureVisible(find.byKey(Key('sort-$i')));
    await tester.tap(find.byKey(Key('sort-$i')));
    await tester.pumpAndSettle();
    final apres = controller.personnages.single;
    expect(apres.etats, contains('Épée sanguine'));
    final perte = historique.lancers
        .firstWhere((l) => l.libelle == 'Rituel du sang : PV dépensés')
        .total;
    expect(apres.pvActuels, depart - perte);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
