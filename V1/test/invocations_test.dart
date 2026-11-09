import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/creature.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/etats.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/invocations.dart';
import 'package:odyssee_vagabonds/widgets/voie_detail.dart';

/// Invocations et transformations (01/11/2026) : fiches des invocations et
/// des compagnons (bouton « Statistiques »), formes à bonus temporaires,
/// Agrandissement reçu d'un allié.

List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

final _classes = _json('classes.json')
    .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
    .toList();
final _races = _json('races.json')
    .map((e) => Race.depuisJson(e as Map<String, dynamic>))
    .toList();
final _humain = _races.firstWhere((r) => r.id == 'humain');
final _creatures = _json('bestiaire.json')
    .map((e) => Creature.depuisJson(e as Map<String, dynamic>))
    .toList();

FicheCalculee _fiche(
  String classe, {
  Map<String, int> rangs = const {},
  Map<String, String> choix = const {},
  Set<String> etats = const {},
}) =>
    FicheCalculee(
      personnage: Personnage(
        id: 'i',
        nom: 'Test',
        raceId: 'humain',
        classeId: classe,
        niveau: 10,
        rangsVoies: Map.of(rangs),
        choix: Map.of(choix),
        etats: Set.of(etats),
        caracBase: {for (final c in Carac.values) c: 12},
      ),
      race: _humain,
      classe: _classes.firstWhere((c) => c.id == classe),
    );

void main() {
  Referentiel.completerReferences(_races, _classes);
  enregistrerCreatures(_creatures);

  test('chaque lien mène à une fiche, chaque invocation est liée', () {
    final competences = [
      for (final c in _classes)
        for (final v in c.voies) ...v.competences,
      for (final r in _races)
        if (r.voieRaciale != null) ...r.voieRaciale!.competences,
    ];
    final liees = {for (final c in competences) ...c.invocations};
    for (final id in liees) {
      expect(catalogueCreatures, contains(id), reason: id);
    }
    // Plus de famille « Invocations » (09/11/2026) : chaque créature a sa
    // vraie famille ; le lien à la classe ou à la race vient des compétences.
    expect(_creatures.where((c) => c.famille == 'Invocations'), isEmpty);
    for (final c in _creatures.where((c) => liees.contains(c.id))) {
      if (c.remplace.isNotEmpty) {
        expect(catalogueCreatures, contains(c.remplace), reason: c.id);
      }
    }
    // Non combattants : PV seulement.
    final bouquetin = catalogueCreatures['bouquetin-nain']!;
    expect((bouquetin.pv, bouquetin.ca), (15, null));
    expect(bouquetin.attaques, isEmpty);
    expect(catalogueCreatures['familier-corbeau']!.pv, 3);
    // Le diablotin combat (1d6 feu infernal).
    expect(catalogueCreatures['diablotin']!.attaques.single.degats, '1d6 feu');
  });

  test('animal du druide : compagnon, puis animal de combat au rang 3', () {
    List<String> ids(int rang) => [
          for (final r in invocationsDe(_fiche('druide',
              rangs: {'druide-bestiale': rang},
              choix: {'animal-druide': 'loup'})))
            r.creature.id,
        ];
    expect(ids(1), ['druide-loup']);
    expect(ids(3), ['druide-loup-combat']);
    final combat = catalogueCreatures['druide-loup-combat']!;
    expect((combat.ca, combat.pv, combat.initiative), (14, 18, 14));
    expect(combat.attaques.single.degats, '1d8');
  });

  test('compagnon du rôdeur : adulte au rang 3, géant (1d8) au rang 5', () {
    FicheCalculee f(int rang) => _fiche('rodeur',
        rangs: {'rodeur-animaux': rang}, choix: {'compagnon-rodeur': 'lynx'});
    expect(
        invocationsDe(f(3)).map((r) => r.creature.id), ['rodeur-lynx-adulte']);
    expect(
        invocationsDe(f(5)).map((r) => r.creature.id), ['rodeur-lynx-geant']);
    String degats(FicheCalculee x) => x.jetsCompetences
        .firstWhere((j) => j.libelle == 'Compagnon : dégâts')
        .des;
    expect(degats(f(3)), '1d6');
    expect(degats(f(5)), '1d8');
    expect(
        catalogueCreatures['rodeur-lynx-geant']!.taille, TailleCreature.grande);
  });

  test('invocations sans durée écrite : INT + 1d6 tours ; requiem', () {
    final f = _fiche('necromancien', rangs: {
      'necromancien-invocation': 5,
      'necromancien-morts-vivants': 5,
    });
    final jets = {for (final j in f.jetsCompetences) j.libelle: j};
    expect(jets['Démon : durée (tours)']!.des, '1d6');
    expect(jets['Démon : durée (tours)']!.carac, Carac.intel);
    expect(jets['Requiem : nombre de morts-vivants']!.des, '1d4');
    expect(invocationsDe(f).map((r) => r.creature.id),
        containsAll(['diablotin', 'demon-invoque', 'serviteur-permanent']));
  });

  test('transformation majeure : forme de gorille, une forme à la fois', () {
    final base = _fiche('druide', rangs: {'druide-bestiale': 5});
    final f = _fiche('druide', rangs: {'druide-bestiale': 5});
    // Lancer le sort n'active aucune forme : elles sont au choix.
    final formes = {
      for (final e in f.etatsPossibles) e.etat.nom: e,
    };
    expect(
        formes.keys,
        containsAll([
          'Forme de souris',
          'Mutation : bras de gorille',
          'Forme de gorille',
          'Forme d\'aigle royal',
        ]));
    basculerEtat(f, formes['Forme de gorille']!.etat, 'Transformation majeure');
    expect(f.carac(Carac.force), base.carac(Carac.force) + 4);
    expect(f.carac(Carac.con), base.carac(Carac.con) + 2);
    final poings =
        f.jetsCompetences.firstWhere((j) => j.libelle == 'Gorille : poings');
    expect(poings.attaque?.armeInvoquee, 'Poings de gorille');
    expect(poings.attaque?.degatsArme, '2d6');
    expect(base.jetsCompetences.any((j) => j.libelle == 'Gorille : poings'),
        isFalse);
    // Une autre forme du druide remplace la première.
    basculerEtat(f, formes['Forme de loup']!.etat, 'Transformation majeure');
    expect(f.personnage.etats, {'Forme de loup'});
    expect(f.carac(Carac.force), base.carac(Carac.force));
    expect(f.initiative, base.initiative + 4 + 5);
  });

  test('forme d\'élémentaire de pierre : RD physique, FOR, DEX', () {
    final base = _fiche('magicien', rangs: {'magicien-terre': 5});
    final f = _fiche('magicien',
        rangs: {'magicien-terre': 5},
        etats: {'Forme d\'élémentaire de pierre'});
    int rd(FicheCalculee x, String t) =>
        x.resistances.where((r) => r.type == t).fold(0, (n, r) => n + r.total);
    expect(rd(f, 'physique'), rd(base, 'physique') + 5);
    expect(f.carac(Carac.force), base.carac(Carac.force) + 4);
    expect(f.carac(Carac.dex), base.carac(Carac.dex) - 2);
    expect(f.jetsCompetences.any((j) => j.libelle == 'Forme de pierre : coup'),
        isTrue);
  });

  test('agrandissement : sur soi, ou reçu par un allié', () {
    // Le magicien l'active lui-même : pas dans ses effets reçus.
    final mage = _fiche('magicien', rangs: {'magicien-arcanes': 3});
    expect(mage.etatsPossibles.map((e) => e.etat.nom), contains('Agrandi'));
    expect(mage.etatsRecus.map((e) => e.etat.nom), isNot(contains('Agrandi')));
    // Un guerrier le reçoit : +4 FOR, +4 CON, −2 DEX.
    final base = _fiche('guerrier');
    final g = _fiche('guerrier');
    expect(g.etatsRecus.map((e) => e.etat.nom),
        containsAll(['Agrandi', 'Forme de gorille']));
    final agrandi = g.etatsRecus.firstWhere((e) => e.etat.nom == 'Agrandi');
    basculerEtat(g, agrandi.etat, agrandi.competence.nom, actif: true);
    expect(g.carac(Carac.force), base.carac(Carac.force) + 4);
    expect(g.carac(Carac.con), base.carac(Carac.con) + 4);
    expect(g.carac(Carac.dex), base.carac(Carac.dex) - 2);
    expect(g.pvMax, base.pvMax + 2);
    expect(g.personnage.historique.last.message, contains('Agrandi activée'));
  });

  testWidgets('bouton « Statistiques » : la fiche de l\'invocation',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final diablotin = _classes
        .firstWhere((c) => c.id == 'necromancien')
        .voies
        .expand((v) => v.competences)
        .firstWhere((c) => c.nom == 'Diablotin');
    final animal =
        _classes.firstWhere((c) => c.id == 'druide').voies.first.competence(1)!;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListView(children: [
          LigneCompetence(competence: diablotin),
          // Sur la fiche : seulement l'animal choisi.
          LigneCompetence(
              competence: animal, choixFaits: const {'animal-druide': 'aigle'}),
        ]),
      ),
    ));
    expect(find.byKey(const Key('statistiques-druide-aigle')), findsOneWidget);
    expect(find.byKey(const Key('statistiques-druide-loup')), findsNothing);
    await tester.tap(find.byKey(const Key('statistiques-diablotin')));
    await tester.pumpAndSettle();
    expect(find.text('CA 14 · PV 8 · Initiative 16'), findsOneWidget);
  });

  test('glossaire : effets des formes affichés', () {
    final Competence majeure =
        _classes.firstWhere((c) => c.id == 'druide').voies.first.competence(5)!;
    expect(majeure.etatsAuChoix, hasLength(5));
    expect(majeure.etatsAuChoix.every((e) => e.recevable), isTrue);
  });
}
