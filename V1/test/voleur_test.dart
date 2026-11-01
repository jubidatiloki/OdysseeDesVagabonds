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

/// Voleur : quatre voies adaptées (28/10/2026) — assassin (dans le dos,
/// embuscade, coupe-jarret, dague de verre), bretteur (escrime, riposte
/// d12 → d20, désarmement, botte secrète), roublard (pickpocket,
/// crochetage, sprint, avantage), séducteur (SOC, déguisement, réseau).

List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

final _classes = [
  for (final e in _json('classes.json'))
    Classe.depuisJson(e as Map<String, dynamic>),
];
final _voleur = _classes.firstWhere((c) => c.id == 'voleur');
final _humain = [
  for (final e in _json('races.json'))
    Race.depuisJson(e as Map<String, dynamic>),
].firstWhere((r) => r.id == 'humain');
final _aptitudes = [
  for (final e in _json('aptitudes.json'))
    Aptitude.depuisJson(e as Map<String, dynamic>),
];

Objet _arme(String nom) => Objet(
      nom: nom,
      categorie: CategorieObjet.arme,
      degats: '1d6',
      equipe: true,
    );

Personnage _perso(Map<String, int> rangs,
        {List<Objet> inventaire = const []}) =>
    Personnage(
      id: 'v',
      nom: 'Lisandre',
      raceId: 'humain',
      classeId: 'voleur',
      niveau: 9,
      rangsVoies: Map.of(rangs),
      inventaire: List.of(inventaire),
      caracBase: {for (final c in Carac.values) c: 14},
    );

FicheCalculee _fiche(Map<String, int> rangs,
        {List<Objet> inventaire = const []}) =>
    FicheCalculee(
      personnage: _perso(rangs, inventaire: inventaire),
      race: _humain,
      classe: _voleur,
    );

JetDisponible _jet(FicheCalculee f, String libelle) =>
    f.jetsCompetences.firstWhere((j) => j.libelle == libelle);

JetSavoir _savoir(FicheCalculee f, String id) =>
    jetsSavoirs(f, _aptitudes, FamilleAptitude.savoirFaire)
        .firstWhere((j) => j.aptitude.id == id);

void main() {
  Referentiel.completerReferences([_humain], _classes);
  final base = _fiche({});

  test('assassin : dans le dos, embuscade, coupe-jarret, dague de verre', () {
    final f = _fiche({'voleur-assassin': 5});
    final degats = {
      for (final s in f.situationsHorsTests)
        if (s.effet.typeNormalise == 'degats')
          s.effet.condition: s.effet.valeur,
    };
    expect(degats['attaque dans le dos'], '5d4');
    expect(degats['1er tour, non repéré'], '2d6');
    expect(
      f.bonusTestsSituationnels.any((s) =>
          s.effet.carac == Carac.adc &&
          s.effet.valeurEntiere == 5 &&
          s.effet.condition == '1er tour, non repéré'),
      isTrue,
    );
    expect(_jet(f, 'Coupe-jarret').des, '1d12');
    final dague = _jet(f, 'Dague de verre pourpre');
    expect(dague.attaque!.toucher, 5);
    expect(f.armeAttaque(dague.attaque!), isNull);
    final avec = _fiche({'voleur-assassin': 5}, inventaire: [_arme('Dague')]);
    expect(avec.armeAttaque(dague.attaque!), isNotNull);
  });

  test('bretteur : escrime, riposte d12 → d20, désarmement, botte', () {
    final r2 = _fiche({'voleur-bretteur': 2}, inventaire: [_arme('Rapière')]);
    expect(
      r2
          .bonusToucher(distance: false)
          .any((b) => b.nom == 'Escrime' && b.valeur == 2),
      isTrue,
    );
    final hache = _fiche({'voleur-bretteur': 2}, inventaire: [_arme('Hache')]);
    expect(hache.bonusToucher(distance: false).any((b) => b.nom == 'Escrime'),
        isFalse);
    expect(_jet(r2, 'Riposte').des, '1d12');
    final r5 = _fiche({'voleur-bretteur': 5}, inventaire: [_arme('Rapière')]);
    expect(_jet(r5, 'Riposte').des, '1d20');
    expect(_jet(r5, 'Riposte').origine, 'Riposte');
    expect(r5.jetsCompetences.map((j) => j.libelle),
        containsAll(['Désarmement : attaque', 'Désarmement : test de DEX']));
    expect(r5.carac(Carac.dex), base.carac(Carac.dex) + 2);
    expect(r5.usages.single.nom, 'Botte secrète');
    final botte = _jet(r5, 'Botte secrète');
    expect(degatsAttaque(r5, botte, r5.armeAttaque(botte.attaque!)).des,
        '1d6 + 3d6');
  });

  test('roublard et séducteur : savoirs, kits, avantage, bonus de stats', () {
    final r = _fiche({'voleur-roublard': 5});
    expect(_savoir(r, 'pickpocket').bonus.single.valeur, 5);
    expect(_savoir(r, 'pickpocket').avantage, 'Le roi des roublards');
    expect(_savoir(r, 'crochetage').bonus.single.valeur, 5);
    expect(r.objetsARecevoir.map((o) => o.objet['nom']),
        contains('Outils de crochetage'));
    expect(r.usages.single.nom, 'Sprint');
    expect(
      r.bonusTestsSituationnels
          .where((s) => s.effet.condition.startsWith('entrer / sortir'))
          .map((s) => s.effet.carac),
      containsAll([Carac.dex, Carac.force]),
    );
    final s = _fiche({'voleur-seducteur': 5});
    expect(_savoir(s, 'deguisement').bonus.single.valeur, 10);
    expect(s.objetsARecevoir.map((o) => o.objet['nom']),
        contains('Kit de déguisement'));
    expect(s.carac(Carac.soc), base.carac(Carac.soc) + 4);
    expect(s.usages.single.nom, 'Allié dévoué');
  });

  testWidgets('page dé : attaque dans le dos cochée (+1d4 au contact)',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = _perso({'voleur-assassin': 1}, inventaire: [_arme('Dague')]);
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    final historique = HistoriqueLancers();
    addTearDown(historique.dispose);
    await tester.pumpWidget(MaterialApp(
      home: DeScreen(
        referentiel: Referentiel(races: [_humain], classes: _classes),
        personnages: controller,
        preferences: PreferencesController(personnageActifId: 'v'),
        historique: historique,
        aleatoire: Random(4),
      ),
    ));
    await tester.pumpAndSettle();
    const situation = Key(
        'situation-Attaque dans le dos|+1d4 aux dégâts (attaque dans le dos)');
    await tester.ensureVisible(find.byKey(situation));
    await tester.tap(find.byKey(situation));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('jet-degats-cac-0')));
    await tester.tap(find.byKey(const Key('jet-degats-cac-0')));
    await tester.pumpAndSettle();
    // 1d4 (dans le dos) + 1d6 (dague).
    expect(historique.lancers.first.des, hasLength(2));
  });
}
