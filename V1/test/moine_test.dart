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
import 'package:odyssee_vagabonds/regles/des.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/savoirs.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/historique_lancers.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';

/// Moine : quatre voies adaptées (28/10/2026) — dé de mana (Frappe de ki,
/// Méditation, Kenn-do-ha), runes (critique 18-20, échec 1-2), ninja,
/// attaques à mains nues (Pugilat, Déferlement, Uppercut, Lutte).

List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

final _classes = [
  for (final e in _json('classes.json'))
    Classe.depuisJson(e as Map<String, dynamic>),
];
final _moine = _classes.firstWhere((c) => c.id == 'moine');
final _humain = [
  for (final e in _json('races.json'))
    Race.depuisJson(e as Map<String, dynamic>),
].firstWhere((r) => r.id == 'humain');
final _aptitudes = [
  for (final e in _json('aptitudes.json'))
    Aptitude.depuisJson(e as Map<String, dynamic>),
];

Personnage _perso(Map<String, int> rangs,
        {Map<String, String> choix = const {},
        Set<String> etats = const {},
        List<Objet> inventaire = const []}) =>
    Personnage(
      id: 'k',
      nom: 'Kenji',
      raceId: 'humain',
      classeId: 'moine',
      niveau: 9,
      rangsVoies: Map.of(rangs),
      choix: Map.of(choix),
      etats: Set.of(etats),
      inventaire: List.of(inventaire),
      caracBase: {for (final c in Carac.values) c: 14},
    );

FicheCalculee _fiche(Map<String, int> rangs,
        {Map<String, String> choix = const {},
        Set<String> etats = const {},
        List<Objet> inventaire = const []}) =>
    FicheCalculee(
      personnage:
          _perso(rangs, choix: choix, etats: etats, inventaire: inventaire),
      race: _humain,
      classe: _moine,
    );

JetDisponible _jet(FicheCalculee f, String libelle) =>
    f.jetsCompetences.firstWhere((j) => j.libelle == libelle);

void main() {
  Referentiel.completerReferences([_humain], _classes);
  final base = _fiche({});

  test('ki : frappe de ki (sort, état d\'un coup), méditation, kenn-do-ha', () {
    final f = _fiche({'moine-ki': 4});
    final dm = 'd${f.deMana}';
    final frappe =
        f.sorts.firstWhere((s) => s.competence.nom == 'Frappe de ki');
    expect(frappe.cout, 1);
    expect(frappe.competence.etat!.finApresDegats, isTrue);
    final active = _fiche({'moine-ki': 4}, etats: {'Frappe de ki'});
    expect(active.desEnPlus(null).map((s) => s.effet.valeur), contains('1$dm'));
    final meditation = _jet(f, 'Méditation : mana regagné');
    expect(meditation.des, '1$dm');
    expect(meditation.recuperePm, isTrue);
    final kenn = f.sorts.firstWhere((s) => s.competence.nom == 'Kenn-do-ha');
    final degats = f.jetsEffetSort(kenn.competence).first;
    expect(degats.des, '4$dm');
    expect(degats.bonus, f.degatsMagie);
    expect(f.jetReussite(kenn.competence)!.attaqueMagique, isTrue);
  });

  test('runes : aptitude, défense, précision, vitesse, berzerker', () {
    final apt = _fiche({'moine-runes': 3}, choix: {'rune-aptitude': 'adt'});
    expect(
      apt.bonusTestsPermanents
          .any((s) => s.effet.carac == Carac.adt && s.effet.valeurEntiere == 3),
      isTrue,
    );
    expect(apt.caDistance, base.caDistance + 3);
    expect(apt.classeArmure, base.classeArmure + 3);
    expect(apt.seuilsAttaques, (critique: 18, echec: 2));
    final r4 = _fiche({'moine-runes': 4});
    int perm(FicheCalculee f, Carac? c, {bool init = false}) =>
        f.bonusTestsPermanents
            .where((s) =>
                s.effet.carac == c &&
                (!init || s.effet.categorieNormalisee == 'init'))
            .fold(0, (n, s) => n + (s.effet.valeurEntiere ?? 0));
    expect(perm(r4, null, init: true), 5);
    // Initiative = valeur de DEX + bonus permanents (règle du 31/10/2026).
    expect(r4.initiative, r4.carac(Carac.dex) + 5);
    expect(r4.bonusInitiative.single.valeur, 5);
    expect(perm(r4, Carac.con), -3);
    final berz = _fiche({'moine-runes': 5}, etats: {'Rune du berzerker'});
    expect(berz.classeArmure, _fiche({'moine-runes': 5}).classeArmure - 1);
    // Échec critique sur un 2 naturel.
    final r = ResultatLancer(
      libelle: 'Toucher',
      formule: '1d20',
      des: const [2],
      garde: 2,
      d20: true,
      seuilEchec: 2,
    );
    expect(r.echecCritique, isTrue);
  });

  test('ninja : initiative, camouflage, shuriken, 15 m, assaillant', () {
    int init(FicheCalculee f) => f.bonusTestsPermanents
        .where((s) => s.effet.categorieNormalisee == 'init')
        .fold(0, (n, s) => n + (s.effet.valeurEntiere ?? 0));
    expect(init(_fiche({'moine-ninja': 2})), 3);
    expect(init(_fiche({'moine-ninja': 3})), 5);
    final r5 = _fiche({'moine-ninja': 5});
    final discretion = jetsSavoirs(r5, _aptitudes, FamilleAptitude.savoirFaire)
        .firstWhere((j) => j.aptitude.id == 'discretion');
    expect(discretion.bonus.single.valeur, 5);
    expect(_jet(r5, 'Shuriken : dégâts').carac, Carac.dex);
    expect(r5.deplacement, base.deplacement + 5);
    expect(r5.usages.single.max, 2);
    expect(r5.situationsHorsTests.any((s) => s.nom == 'Mouvement de shinobi'),
        isTrue);
  });

  test('poing : mains nues 1d6 → 1d8, uppercut, déferlement sans FOR', () {
    final r3 = _fiche({'moine-poing': 3});
    expect(r3.desMainsNues, '1d6');
    expect(r3.detailDegatsCac.desMainsNuesAvec, '1d6');
    expect(
      r3
          .bonusToucher(distance: false)
          .any((b) => b.nom == 'Pugilat' && b.valeur == 3),
      isTrue,
    );
    // Avec une arme de CaC : pas de bonus à mains nues.
    final arme = _fiche({
      'moine-poing': 3
    }, inventaire: [
      Objet(
          nom: 'Bâton',
          categorie: CategorieObjet.arme,
          degats: '1d6',
          equipe: true),
    ]);
    expect(arme.bonusToucher(distance: false).any((b) => b.nom == 'Pugilat'),
        isFalse);
    final up = degatsAttaque(r3, _jet(r3, 'Uppercut'), null);
    expect(up.des, '2d6');
    expect(up.bonus, r3.mod(Carac.force));
    expect(up.fixes.single.valeur, r3.mod(Carac.force));
    final def = degatsAttaque(r3, _jet(r3, 'Déferlement de coups'), null);
    expect(def.des, '1d6');
    expect(def.bonus, 0);
    final r5 = _fiche({'moine-poing': 5});
    expect(r5.desMainsNues, '1d8');
    expect(degatsAttaque(r5, _jet(r5, 'Uppercut'), null).des, '3d6');
    expect(
        degatsAttaque(r5, _jet(r5, 'Déferlement de coups'), null).des, '1d8');
    expect(_jet(r5, 'Lutte').attaque!.toucher, 5);
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
        preferences: PreferencesController(personnageActifId: 'k'),
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

  testWidgets('page dé : uppercut à mains nues, frappe de ki, méditation',
      (tester) async {
    final p = _perso({'moine-poing': 3, 'moine-ki': 2})..pmActuels = 1;
    final (controller, historique) = await ouvrir(tester, p);
    final f = FicheCalculee(personnage: p, race: _humain, classe: _moine);
    // Uppercut : utilisable sans arme.
    final i = f.jetsCompetences.indexWhere((j) => j.libelle == 'Uppercut');
    final bouton = tester.widget<OutlinedButton>(find.descendant(
        of: find.byKey(Key('jet-competence-$i')),
        matching: find.byType(OutlinedButton)));
    expect(bouton.onPressed, isNotNull);
    await toucher(tester, Key('degats-competence-$i'));
    expect(historique.lancers.first.formule, startsWith('2d6'));
    // Frappe de ki : lancer le sort active l'état (−1 PM).
    final s = f.sorts.indexWhere((s) => s.competence.nom == 'Frappe de ki');
    await toucher(tester, Key('sort-$s'));
    final apres = controller.personnages.single;
    expect(apres.etats, contains('Frappe de ki'));
    expect(apres.pmActuels, 0);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    // Méditation : le résultat s'ajoute aux PM.
    final m = f.jetsCompetences
        .indexWhere((j) => j.libelle == 'Méditation : mana regagné');
    await toucher(tester, Key('jet-competence-$m'));
    final gain = historique.lancers.first.total;
    expect(
        controller.personnages.single.pmActuels,
        gain.clamp(
            0,
            FicheCalculee(personnage: apres, race: _humain, classe: _moine)
                .pmMax));
  });
}
