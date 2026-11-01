import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/equipement.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/inventaire.dart';
import 'package:odyssee_vagabonds/regles/savoirs.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/screens/fiche/onglet_inventaire.dart';
import 'package:odyssee_vagabonds/state/historique_lancers.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';
import 'package:odyssee_vagabonds/widgets/carte_choix.dart';

/// Ingénieur : quatre voies adaptées (25/10/2026) — armes à feu sans DEX
/// (sauf Expertise de la poudre), potions du jour, attaques à distance,
/// bidouillage, golem.

final _classes =
    (jsonDecode(File('assets/data/classes.json').readAsStringSync()) as List)
        .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
        .toList();
final _ingenieur = _classes.firstWhere((c) => c.id == 'ingenieur');
final _humain =
    (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
        .map((e) => Race.depuisJson(e as Map<String, dynamic>))
        .firstWhere((r) => r.id == 'humain');
final _aptitudes =
    (jsonDecode(File('assets/data/aptitudes.json').readAsStringSync()) as List)
        .map((e) => Aptitude.depuisJson(e as Map<String, dynamic>))
        .toList();

Objet _arme(String nom, String degats, {bool distance = true}) => Objet(
      nom: nom,
      categorie: CategorieObjet.arme,
      degats: degats,
      distance: distance,
      equipe: true,
    );

Personnage _perso({
  Map<String, int> rangs = const {},
  Map<String, String> choix = const {},
  List<Objet>? inventaire,
  int dex = 16,
}) =>
    Personnage(
      id: 'i',
      nom: 'Ada',
      raceId: 'humain',
      classeId: 'ingenieur',
      niveau: 9,
      rangsVoies: Map.of(rangs),
      choix: Map.of(choix),
      caracBase: {
        for (final c in Carac.values) c: c == Carac.dex ? dex : 12,
      },
      inventaire: inventaire ?? [_arme('Pétoire', '1d10')],
    );

FicheCalculee _fiche({
  Map<String, int> rangs = const {},
  Map<String, String> choix = const {},
  List<Objet>? inventaire,
}) =>
    FicheCalculee(
      personnage: _perso(rangs: rangs, choix: choix, inventaire: inventaire),
      race: _humain,
      classe: _ingenieur,
    );

void main() {
  Referentiel.completerReferences([_humain], _classes);

  test('armes à feu : pas de DEX aux dégâts, sauf Expertise de la poudre', () {
    final sans = _fiche(
        inventaire: [_arme('Pétoire', '1d10'), _arme('Arc court', '1d6')]);
    final d = sans.detailDegatsDistance;
    final petoire = sans.personnage.inventaire[0];
    final arc = sans.personnage.inventaire[1];
    expect(FicheCalculee.estArmeAFeu(petoire), isTrue);
    expect(FicheCalculee.estArmeAFeu(arc), isFalse);
    expect(d.bonusAvec(petoire), 0);
    expect(d.bonusAvec(arc), sans.mod(Carac.dex));
    expect(d.explication, contains('Expertise de la poudre requise'));
    final avec = _fiche(rangs: {'ingenieur-chimiste': 2});
    expect(avec.expertisePoudre, isTrue);
    expect(
      avec.detailDegatsDistance.bonusAvec(avec.personnage.inventaire.single),
      avec.mod(Carac.dex),
    );
  });

  test('artillerie : maîtrises, canon à mains, +2 / +5 DMG, vétéran', () {
    final r3 = _fiche(rangs: {
      'ingenieur-artillerie': 3
    }, inventaire: [
      _arme('Pétoire', '1d10'),
      _arme('Mousquet', '2d6'),
    ]);
    expect(r3.armesMaitrisees, containsAll(['Pétoire', 'Mousquet', 'Canon']));
    final canon = r3.objetsARecevoir
        .firstWhere((o) => o.objet['nom'] == 'Canon à mains')
        .objet;
    expect(canon['catalogue'], isTrue);
    // Reçu depuis le catalogue : 3d10, distance, deux mains, 50 m.
    final catalogue = [
      for (final e in jsonDecode(
        File('assets/data/equipements.json').readAsStringSync(),
      ) as List)
        Equipement.depuisJson(e as Map<String, dynamic>),
    ];
    final p = r3.personnage;
    ObjetsDonnes.recevoir(r3, catalogue: catalogue);
    final recu = p.inventaire.firstWhere((o) => o.nom == 'Canon à mains');
    expect(recu.degats.toLowerCase(), startsWith('3d10'));
    expect(recu.distance, isTrue);
    expect(recu.mains, 2);
    expect(FicheCalculee.estArmeAFeu(recu), isTrue);
    expect(recu.description, contains('50'));
    List<String> plus(Objet o) =>
        r3.desEnPlus(o).map((s) => s.effet.valeur).toList();
    expect(plus(r3.personnage.inventaire[0]), contains('2'));
    expect(plus(r3.personnage.inventaire[1]), contains('5'));
    final r5 = _fiche(rangs: {'ingenieur-artillerie': 5});
    expect(
      r5.bonusTestsSituationnels
          .where((s) => s.nom == 'Artilleur vétéran')
          .map((s) => s.effet.valeurEntiere),
      [10, 5, 10],
    );
    expect(
      r5.jetsCompetences
          .firstWhere((j) => j.libelle == 'Médecin de campagne : soin')
          .des,
      '4d4',
    );
  });

  test('chimiste : alchimie, potions du jour, fabrications, explosif', () {
    final r3 = _fiche(rangs: {'ingenieur-chimiste': 3});
    final alchimie = jetsSavoirs(r3, _aptitudes, FamilleAptitude.savoir)
        .firstWhere((j) => j.aptitude.id == 'alchimie');
    expect(alchimie.bonus.single.valeur, 6);
    final potions = r3.usages.single;
    expect(potions.nom, 'Potions du jour');
    expect(potions.max, 6);
    expect(potions.periode, 'par jour');
    expect(r3.fabrications.map((f) => f.objet['nom']), [
      'Potion de santé (niveau 1)',
      'Potion de fer',
      'Projectile explosif',
      'Potion de poison',
    ]);
    String explosif(FicheCalculee f) => f.jetsCompetences
        .firstWhere((j) => j.libelle == 'Projectile explosif : dégâts')
        .des;
    expect(explosif(r3), '2d6');
    expect(explosif(_fiche(rangs: {'ingenieur-chimiste': 5})), '4d6');
  });

  test('tireur : +RANG au toucher des armes à feu, pistoléro à distance', () {
    final r3 = _fiche(rangs: {'ingenieur-tireur': 3});
    expect(
      r3
          .bonusToucher(distance: true)
          .any((b) => b.nom == 'Entraînement au tir' && b.valeur == 3),
      isTrue,
    );
    final deux =
        r3.jetsCompetences.firstWhere((j) => j.libelle == 'Pistoléro : 2 tirs');
    expect(deux.des, '1d12');
    expect(deux.attaque!.distance, isTrue);
    expect(r3.armeAttaque(deux.attaque!)?.nom, 'Pétoire');
    final r5 = _fiche(rangs: {'ingenieur-tireur': 5});
    expect(
        r5.jetsCompetences
            .firstWhere((j) => j.libelle == 'Pistoléro : 2 tirs')
            .des,
        '1d20');
    final unique = r5.jetsCompetences
        .firstWhere((j) => j.libelle == 'Pistoléro : tir unique');
    expect(unique.attaque!.toucher, 2);
    expect(unique.attaque!.degatsEnPlus, '2d10');
  });

  test('mécanismes : mécanicien, physique, automate, bidouillage, golem', () {
    final r5 = _fiche(
      rangs: {'ingenieur-mecanismes': 5},
      choix: {'golem-modules': 'artilleur,mule'},
    );
    final meca = jetsSavoirs(r5, _aptitudes, FamilleAptitude.savoir)
        .firstWhere((j) => j.aptitude.id == 'ingenierie');
    expect(meca.bonus.single.valeur, 10);
    expect(r5.bidouillage, isTrue);
    expect(r5.fabrications.single.objet['nom'], 'Petit automate');
    expect(
      r5.objetsARecevoir.where((o) => o.objet['nom'] == 'Golem'),
      hasLength(1),
    );
    final golem = _ingenieur.voies[3].competence(5)!.choix!;
    expect(golem.nombre, 2);
    expect(golem.options, hasLength(5));
  });

  testWidgets('inventaire : potion fabriquée (−1 du jour), bidouillage',
      (tester) async {
    final p = _perso(rangs: {
      'ingenieur-chimiste': 1,
      'ingenieur-mecanismes': 4,
    })
      ..bourse.argent = 15;
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            final f =
                FicheCalculee(personnage: p, race: _humain, classe: _ingenieur);
            return OngletInventaire(
              personnage: p,
              onModifie: () async => setState(() {}),
              fabrications: f.fabrications,
              usagesRestants: {for (final u in f.usages) u.cle: u.restants},
              bidouillage: f.bidouillage,
            );
          },
        ),
      ),
    ));
    await tester.pumpAndSettle();
    final potion =
        find.byKey(const Key('fabriquer-Potion de santé (niveau 1)'));
    expect(find.text('Fabriquer : Potion de santé (niveau 1) (2)'), findsOne);
    await tester.tap(potion);
    await tester.pump();
    expect(p.utilisations['Potions du jour'], 1);
    expect(
        p.inventaire.any((o) => o.nom == 'Potion de santé (niveau 1)'), isTrue);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Bidouiller la pétoire : crosse modifiée (+3 AdT), −10 pa.
    final petoire = p.inventaire.first;
    await tester.tap(find.byKey(Key('menu-objet-${petoire.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bidouiller (10 pa)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bidouiller-Crosse modifiée')));
    await tester.pumpAndSettle();
    expect(p.bourse.argent, 5);
    final apres =
        FicheCalculee(personnage: p, race: _humain, classe: _ingenieur);
    expect(
      apres.bonusToucher(distance: true).any((b) => b.valeur == 3),
      isTrue,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Une seule amélioration par arme : l'actuelle est grisée, une autre
    // la remplace (et coûte de nouveau 10 pa).
    expect(OngletInventaire.bidouillageDe(petoire), 'Crosse modifiée');
    p.bourse.argent = 12;
    await tester.tap(find.byKey(Key('menu-objet-${petoire.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bidouiller (10 pa)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Amélioration actuelle : Crosse modifiée'),
        findsOneWidget);
    SimpleDialogOption option(String nom) =>
        tester.widget<SimpleDialogOption>(find.byKey(Key('bidouiller-$nom')));
    expect(option('Crosse modifiée').onPressed, isNull);
    expect(option('Canon vissé').onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('bidouiller-Canon vissé')));
    await tester.pumpAndSettle();
    expect(p.bourse.argent, 2);
    expect(OngletInventaire.bidouillageDe(petoire), 'Canon vissé');
    // L'ancienne amélioration est perdue : plus de +3 AdT, mais +1d6.
    final remplacee =
        FicheCalculee(personnage: p, race: _humain, classe: _ingenieur);
    expect(remplacee.bonusToucher(distance: true).any((b) => b.valeur == 3),
        isFalse);
    expect(remplacee.desEnPlus(petoire).map((s) => s.effet.valeur),
        contains('1d6'));
    expect(petoire.effets.where((e) => e.nom == 'Crosse modifiée'), isEmpty);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('page dé : nouveau jour rend les potions', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = _perso(rangs: {'ingenieur-chimiste': 1})
      ..utilisations['Potions du jour'] = 2;
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    final historique = HistoriqueLancers();
    addTearDown(historique.dispose);
    await tester.pumpWidget(MaterialApp(
      home: DeScreen(
        referentiel: Referentiel(races: [_humain], classes: _classes),
        personnages: controller,
        preferences: PreferencesController(personnageActifId: 'i'),
        historique: historique,
        aleatoire: Random(1),
      ),
    ));
    await tester.pumpAndSettle();
    final bouton = find.byKey(const Key('usage-Potions du jour'));
    expect(find.descendant(of: bouton, matching: find.text('0 / 2')), findsOne);
    await tester.tap(find.byKey(const Key('nouveau-jour')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: bouton, matching: find.text('2 / 2')), findsOne);
  });

  testWidgets('golem : les 2 modules choisis restent affichés', (tester) async {
    final c = _ingenieur.voies[3].competence(5)!.choix!;
    var valeur = '';
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: CarteChoix(
              nom: 'Golem',
              choix: c,
              valeur: valeur,
              onChoisir: (v) => setState(() => valeur = v),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.byKey(const Key('option-golem-modules-artilleur')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('effets-golem-modules-artilleur')),
        findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    await tester.tap(find.byKey(const Key('option-golem-modules-combattant')));
    await tester.pumpAndSettle();
    expect(valeur, 'artilleur,combattant');
    // Les deux modules sont affichés, une seule fois chacun.
    expect(find.byKey(const Key('effets-golem-modules-artilleur')),
        findsOneWidget);
    expect(find.byKey(const Key('effets-golem-modules-combattant')),
        findsOneWidget);
    expect(find.text('Golem : canon d\'épaule.'), findsOneWidget);
    // Choix complet : coche verte.
    expect(find.byIcon(Icons.help_outline), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
