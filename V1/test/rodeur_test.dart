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
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/savoirs.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/historique_lancers.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';

/// Rôdeur : quatre voies adaptées (28/10/2026) — archer (précision, visée,
/// flèches multiples, points vitaux), chasseur (pistage, proies favorites,
/// dégâts cochés à distance), animaux (compagnon), trappeur (pièges,
/// affût, survivaliste : maîtrise et avantage en Survie).

List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

final _classes = [
  for (final e in _json('classes.json'))
    Classe.depuisJson(e as Map<String, dynamic>),
];
final _rodeur = _classes.firstWhere((c) => c.id == 'rodeur');
final _humain = [
  for (final e in _json('races.json'))
    Race.depuisJson(e as Map<String, dynamic>),
].firstWhere((r) => r.id == 'humain');
final _aptitudes = [
  for (final e in _json('aptitudes.json'))
    Aptitude.depuisJson(e as Map<String, dynamic>),
];

Objet _arc() => Objet(
      nom: 'Arc long',
      categorie: CategorieObjet.arme,
      degats: '1d8',
      distance: true,
      equipe: true,
    );

Objet _epee() => Objet(
      nom: 'Épée longue',
      categorie: CategorieObjet.arme,
      degats: '1d8',
      equipe: true,
    );

Personnage _perso(
  Map<String, int> rangs, {
  Map<String, String> choix = const {},
  Map<String, String> precisions = const {},
  List<Objet> inventaire = const [],
}) =>
    Personnage(
      id: 'r',
      nom: 'Sylas',
      raceId: 'humain',
      classeId: 'rodeur',
      niveau: 9,
      rangsVoies: Map.of(rangs),
      choix: Map.of(choix),
      precisionsChoix: Map.of(precisions),
      inventaire: List.of(inventaire),
      caracBase: {for (final c in Carac.values) c: 14},
    );

FicheCalculee _fiche(
  Map<String, int> rangs, {
  Map<String, String> choix = const {},
  Map<String, String> precisions = const {},
  List<Objet> inventaire = const [],
}) =>
    FicheCalculee(
      personnage: _perso(rangs,
          choix: choix, precisions: precisions, inventaire: inventaire),
      race: _humain,
      classe: _rodeur,
    );

int _perm(FicheCalculee f, Carac c) => f.bonusTestsPermanents
    .where((s) => s.effet.carac == c)
    .fold(0, (n, s) => n + (s.effet.valeurEntiere ?? 0));

void main() {
  Referentiel.completerReferences([_humain], _classes);
  final base = _fiche({});

  test('archer : précision, visée, fuite, flèches multiples, points vitaux',
      () {
    final f = _fiche({'rodeur-archer': 5}, inventaire: [_arc()]);
    expect(_perm(f, Carac.adt), _perm(base, Carac.adt) + 5);
    expect(
      f.bonusTestsSituationnels.any((s) =>
          s.effet.typeNormalise == 'avantage' && s.effet.carac == Carac.adt),
      isTrue,
    );
    expect(f.usages.single.max, 1);
    final multiples =
        f.jetsCompetences.firstWhere((j) => j.libelle == 'Flèches multiples');
    expect(multiples.attaque!.repetable, 0);
    expect(f.carac(Carac.per), base.carac(Carac.per) + 2);
    final vitaux =
        f.jetsCompetences.firstWhere((j) => j.libelle == 'Points vitaux');
    final d = degatsAttaque(f, vitaux, f.armeAttaque(vitaux.attaque!));
    expect(d.des, '1d8 + 1d6');
    expect(d.fixes.single.valeur, f.mod(Carac.per));
  });

  test('chasseur : pistage, proies favorites, armement, gros gibier', () {
    const choix = {'proie-favorite': 'proie', 'proie-favorite-2': 'proie'};
    const precisions = {'proie-favorite': 'orcs', 'proie-favorite-2': 'loups'};
    final r2 =
        _fiche({'rodeur-chasseur': 2}, choix: choix, precisions: precisions);
    final pistage = jetsSavoirs(r2, _aptitudes, FamilleAptitude.savoirFaire)
        .firstWhere((j) => j.aptitude.id == 'pistage');
    expect(pistage.bonus.single.valeur, 4);
    int toucher(FicheCalculee f, String cible) => f.bonusTestsSituationnels
        .where((s) =>
            s.effet.carac == Carac.adc && s.effet.condition == 'contre $cible')
        .fold(0, (n, s) => n + (s.effet.valeurEntiere ?? 0));
    expect(toucher(r2, 'orcs'), 2);
    expect(toucher(r2, 'loups'), 0);
    final r5 =
        _fiche({'rodeur-chasseur': 5}, choix: choix, precisions: precisions);
    expect(toucher(r5, 'orcs'), 4);
    expect(toucher(r5, 'loups'), 4);
    expect(r5.armesMaitrisees, containsAll(['Arbalète', 'Mousquet']));
    final degats = [
      for (final s in r5.situationsHorsTests)
        if (s.effet.typeNormalise == 'degats') s.effet,
    ];
    expect(degats.every((e) => e.categorieNormalisee == 'dist'), isTrue);
    expect(degats.map((e) => e.valeur), containsAll(['1d6', '2d6']));
  });

  test('animaux et trappeur : compagnon, pièges, survivaliste', () {
    final a =
        _fiche({'rodeur-animaux': 4}, choix: {'compagnon-rodeur': 'loup'});
    expect(_perm(a, Carac.per), _perm(base, Carac.per) + 5);
    expect(a.jetsCompetences.map((j) => j.libelle),
        containsAll(['Compagnon : attaque', 'Compagnon : dégâts']));
    expect(a.usages.single.nom, 'Interception');
    String piege(FicheCalculee f) =>
        f.jetsCompetences.firstWhere((j) => j.libelle == 'Piège : dégâts').des;
    expect(piege(_fiche({'rodeur-trappeur': 2})), '1d6 + 2');
    final t5 = _fiche({'rodeur-trappeur': 5});
    expect(piege(t5), '2d6 + 5');
    final survie = jetsSavoirs(t5, _aptitudes, FamilleAptitude.savoirFaire)
        .firstWhere((j) => j.aptitude.id == 'survie');
    expect(survie.maitrise, isTrue);
    expect(survie.avantage, 'Survivaliste');
    expect(avantageSavoir(base, 'Survie'), isNull);
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
        referentiel: Referentiel(races: [_humain], classes: _classes),
        personnages: controller,
        preferences: PreferencesController(personnageActifId: 'r'),
        historique: historique,
        aleatoire: Random(4),
      ),
    ));
    await tester.pumpAndSettle();
    return historique;
  }

  Future<void> toucher(WidgetTester tester, Key k) async {
    await tester.ensureVisible(find.byKey(k));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(k));
    await tester.pumpAndSettle();
  }

  testWidgets('page dé : gros gibier coché, à distance seulement',
      (tester) async {
    final historique = await ouvrir(
      tester,
      _perso({'rodeur-chasseur': 5}, inventaire: [_arc(), _epee()]),
    );
    expect(
        find.byKey(const Key('groupe-situation-degats-dist')), findsOneWidget);
    await toucher(
        tester,
        const Key('situation-Chasseur de gros gibier|+2d6 aux dégâts à '
            'distance (contre une créature de grande taille ou plus)'));
    await toucher(tester, const Key('jet-degats-dist-0'));
    // 2d6 (gros gibier) + 1d8 (arc).
    expect(historique.lancers.first.des, hasLength(3));
    await toucher(tester, const Key('jet-degats-cac-0'));
    expect(historique.lancers.first.des, hasLength(1));
  });
}
