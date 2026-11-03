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
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';
import 'package:odyssee_vagabonds/widgets/carte_choix.dart';

/// Barde (classes_2, 24/10/2026) : +2 par rang, Vagabond (6 stats),
/// Diversité culturelle, musicien, acrobate, courtisan.

final _classes =
    (jsonDecode(File('assets/data/classes.json').readAsStringSync()) as List)
        .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
        .toList();
final _barde = _classes.firstWhere((c) => c.id == 'barde');

final _humain =
    (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
        .map((e) => Race.depuisJson(e as Map<String, dynamic>))
        .firstWhere((r) => r.id == 'humain');

FicheCalculee _fiche({
  int niveau = 9,
  Map<String, int> rangs = const {},
  Map<String, String> choix = const {},
  Map<String, String> precisions = const {},
  List<AptitudeAcquise> aptitudes = const [],
  Set<String> etats = const {},
}) =>
    FicheCalculee(
      personnage: Personnage(
        id: 'b',
        nom: 'Bob',
        raceId: 'humain',
        classeId: 'barde',
        niveau: niveau,
        rangsVoies: Map.of(rangs),
        choix: Map.of(choix),
        precisionsChoix: Map.of(precisions),
        aptitudes: List.of(aptitudes),
        etats: Set.of(etats),
        caracBase: {for (final c in Carac.values) c: 12},
      ),
      race: _humain,
      classe: _barde,
    );

void main() {
  testsAttaqueSautee();
  // Voies de toutes les classes (Diversité culturelle).
  Referentiel.completerReferences([_humain], _classes);

  test('+2 par rang (« RANG x2 ») : Légendes et rumeurs, Bonnes manières', () {
    final f = _fiche(rangs: {'barde-vagabond': 3, 'barde-courtisan': 2});
    int bonus(String condition) => f.bonusTestsSituationnels
        .firstWhere((s) => s.effet.condition == condition)
        .effet
        .valeurEntiere!;
    expect(bonus('Connaissance rumeurs'), 6);
    expect(bonus("s'adresser à un noble"), 4);
  });

  test('Vagabond : 6 stats différentes à +1', () {
    final f = _fiche(rangs: {'barde-vagabond': 5});
    final c = f.choixEnAttente
        .firstWhere((x) => x.choix.cle == 'vagabond-stats')
        .choix;
    expect(c.nombre, 6);
    f.personnage.choix['vagabond-stats'] = 'FOR,DEX,CON';
    expect(FicheCalculee.choixAFaire(c, f.personnage.choix, const {}), isTrue);
    f.personnage.choix['vagabond-stats'] = 'FOR,DEX,CON,INT,PER,SOC';
    expect(FicheCalculee.choixAFaire(c, f.personnage.choix, const {}), isFalse);
    expect(f.carac(Carac.force), 13);
    expect(f.carac(Carac.soc), 13);
    expect(f.carac(Carac.men), 12);
  });

  testWidgets('carte de choix multiple : 6 au plus', (tester) async {
    final c = _barde.voies.first.competence(5)!.choix!;
    var valeur = 'FOR,DEX,CON,INT,PER';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: CarteChoix(
                nom: 'Vagabond',
                choix: c,
                valeur: valeur,
                onChoisir: (v) => setState(() => valeur = v),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('5 / 6 choisies'), findsOneWidget);
    await tester.tap(find.byKey(const Key('option-vagabond-stats-SOC')));
    await tester.pumpAndSettle();
    expect(valeur, 'FOR,DEX,CON,INT,PER,SOC');
    // Plein : les autres sont grisées
    expect(
      tester
          .widget<FilterChip>(
              find.byKey(const Key('option-vagabond-stats-CHA')))
          .onSelected,
      isNull,
    );
    await tester.tap(find.byKey(const Key('option-vagabond-stats-FOR')));
    await tester.pumpAndSettle();
    expect(valeur, 'DEX,CON,INT,PER,SOC');
  });

  test('Diversité culturelle : un rang 3 d\'une autre classe, RANG = 2', () {
    final f = _fiche(rangs: {'barde-vagabond': 4});
    final c = f.choixEnAttente
        .firstWhere((x) => x.choix.cle == 'diversite-culturelle')
        .choix;
    final ids = c.options.map((o) => o.id).toSet();
    // Pas les voies du barde ni les renforcements (Style barbaresque)
    expect(ids.any((id) => id.startsWith('barde-')), isFalse);
    expect(ids, isNot(contains('barbare-brute')));
    expect(ids, contains('pretre-soins'));
    f.personnage.choix['diversite-culturelle'] = 'pretre-soins';
    final soin = f.competencesAcquises
        .firstWhere((x) => x.competence.nom == 'Soin de groupe');
    expect(f.empruntDe(soin.voie)!.rangCalcul, 2);
    expect(f.nomEmprunt(soin.voie), 'Diversité culturelle');
    expect(f.choixEnAttente.map((x) => x.choix.cle),
        isNot(contains('diversite-culturelle')));
    // Les rangs 1 et 2 de la voie ne sont pas donnés
    expect(f.competencesAcquises.map((x) => x.competence.nom),
        isNot(contains('Soin léger')));
  });

  test('musicien : instrument choisi, +2/rang à tous, avantage, titre, gain',
      () {
    final n3 = _fiche(
      rangs: {'barde-musicien': 3},
      choix: {'instrument-barde': 'instrument'},
      precisions: {'instrument-barde': 'Lyre'},
      aptitudes: const [AptitudeAcquise(id: 'instrument', precision: 'Flûte')],
    );
    final instruments = {for (final i in n3.instrumentsMaitrises) i.nom: i};
    expect(instruments.keys, containsAll(['Lyre', 'Flûte']));
    expect(instruments['Flûte']!.bonus, 6); // +2 × rang 3
    expect(n3.objetsARecevoir.map((o) => o.objet['nom']), contains('Lyre'));
    final musique =
        n3.jetsCompetences.firstWhere((j) => j.libelle == 'Musique vivifiante');
    expect(musique.instrument, isTrue);
    expect(musique.difficulte, 10);
    expect(musique.bonus, n3.mod(Carac.dex) + 6);
    expect(musique.avantage, isFalse);
    final herbe =
        n3.jetsCompetences.firstWhere((j) => j.libelle == 'Musicien en herbe');
    expect(herbe.gain!.piece, 'cuivre');
    expect(n3.titres, isEmpty);

    final n5 = _fiche(rangs: {'barde-musicien': 5});
    expect(n5.titres, ['Musicien de renom']);
    expect(n5.avantageInstrument, 'Musicien renommé');
    final herbe5 =
        n5.jetsCompetences.firstWhere((j) => j.libelle == 'Musicien en herbe');
    expect(herbe5.gain!.piece, 'argent');
    expect(herbe5.gain!.carac, 'CHAN');
    expect(herbe5.avantage, isTrue);
    // Artiste : sort au coût du rang 1
    final artiste = n5.sorts.firstWhere((s) => s.competence.nom == 'Artiste');
    expect(artiste.cout, 1);
  });

  test('acrobate : chute, actions de mouvement, Voltige, attaque sautée', () {
    final n4 = _fiche(rangs: {'barde-acrobate': 4});
    expect(n4.chuteSansDegats, 12);
    expect(n4.actionsMouvement, 1);
    final n5 = _fiche(
      rangs: {'barde-acrobate': 5},
      etats: {'Voltige (déplacé ce tour)'},
    );
    expect(n5.chuteSansDegats, 15);
    expect(n5.actionsMouvement, 2);
    expect(n5.bonusCACompetences, 2);
    final saut =
        n5.jetsCompetences.firstWhere((j) => j.libelle == 'Attaque sautée');
    expect(saut.attaque!.toucher, 3);
    expect(saut.attaque!.degatsEnPlus, '1d6');
    final chute = n5.jetsCompetences
        .firstWhere((j) => j.libelle.startsWith('Attaque sautée ratée'));
    expect(chute.difficulte, 10);
    expect(chute.carac, Carac.dex);
  });

  test('courtisan : Charme mineur au coût d\'un rang 2, jet de SOC', () {
    final f = _fiche(rangs: {'barde-courtisan': 4});
    final charme = f.sorts
        .firstWhere((s) => s.competence.nom == 'Charme mineur (niveau 1)');
    expect(charme.cout, 3);
    expect(f.jetReussite(charme.competence)!.carac, Carac.soc);
    expect(
      f.jetsCompetences.firstWhere((j) => j.libelle == "Mot d'esprit").carac,
      Carac.soc,
    );
  });

  testWidgets('page dé : Musicien en herbe réussi → pièces dans la bourse',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Plusieurs graines : au moins une réussite (diff. 10, +6 au jet).
    for (var graine = 0; graine < 10; graine++) {
      final p = Personnage(
        id: 'b',
        nom: 'Bob',
        raceId: 'humain',
        classeId: 'barde',
        niveau: 5,
        rangsVoies: {'barde-musicien': 3},
        choix: {'instrument-barde': 'instrument'},
        precisionsChoix: {'instrument-barde': 'Lyre'},
      );
      final controller =
          PersonnagesController(EnMemoirePersonnageRepository([p]));
      await controller.charger();
      await tester.pumpWidget(
        MaterialApp(
          home: DeScreen(
            referentiel: Referentiel(races: [_humain], classes: _classes),
            personnages: controller,
            preferences: PreferencesController(personnageActifId: 'b'),
            aleatoire: Random(graine),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final bouton = find.ancestor(
        of: find.text('Musicien en herbe'),
        matching: find.byType(OutlinedButton),
      );
      await tester.ensureVisible(bouton);
      await tester.tap(bouton);
      await tester.pumpAndSettle();
      if (p.bourse.cuivre > 0) {
        expect(
          p.historique.map((e) => e.message),
          contains(startsWith('Gain : +${p.bourse.cuivre} cuivre')),
        );
        return;
      }
    }
    fail('aucune réussite en 10 essais');
  });
}

void testsAttaqueSautee() {
  testWidgets('Attaque sautée : attaque, puis dégâts regroupés (arme + 1d6)',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = Personnage(
      id: 'b',
      nom: 'Bardo',
      raceId: 'humain',
      classeId: 'barde',
      niveau: 3,
      rangsVoies: {'barde-acrobate': 2},
      inventaire: [
        Objet(
          nom: 'Rapière',
          categorie: CategorieObjet.arme,
          degats: '1d6',
          equipe: true,
        ),
      ],
    );
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      MaterialApp(
        home: DeScreen(
          referentiel: Referentiel(races: [_humain], classes: _classes),
          personnages: controller,
          preferences: PreferencesController(personnageActifId: 'b'),
          aleatoire: Random(2),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Finder bouton(String libelle) => find
        .ancestor(
          of: find.text(libelle),
          matching: find.byType(OutlinedButton),
        )
        // Le 2ᵉ « Attaque sautée » est le bouton d'endurance (2 PE).
        .first;
    expect(
      find.descendant(
        of: bouton('Dégâts · Attaque sautée'),
        matching: find.textContaining('1d6 + 1d6'),
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(bouton('Attaque sautée'));
    await tester.tap(bouton('Attaque sautée'));
    await tester.pumpAndSettle();
    var messages = p.historique.map((e) => e.message).toList();
    expect(messages.where((m) => m.contains('Attaque sautée · attaque')),
        hasLength(1));
    expect(messages.where((m) => m.contains('dégâts')), isEmpty);
    await tester.tap(bouton('Dégâts · Attaque sautée'));
    await tester.pumpAndSettle();
    messages = p.historique.map((e) => e.message).toList();
    // Un seul jet de dégâts, sans « dé bonus » à part
    expect(messages.where((m) => m.contains('Attaque sautée · dégâts')),
        hasLength(1));
    expect(messages.where((m) => m.contains('dé bonus')), isEmpty);
    expect(
      messages.firstWhere((m) => m.contains('Attaque sautée · dégâts')),
      contains('1d6+1d6'),
    );
  });
}
