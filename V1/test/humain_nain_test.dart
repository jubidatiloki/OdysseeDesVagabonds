import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/app.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/equipement.dart';
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/inventaire.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/widgets/carte_emprunts.dart';

/// Langues, humain (origines marquées, polyvalence, perfectionnement) et
/// nain (outils, tête de fer, bouquetin, ténacité).

const _guerrier = Classe(
  id: 'g',
  nom: 'Guerrier',
  modifDeVie: ModifDe.egal,
  modifDeMana: ModifDe.egal,
);

/// Autre classe, pour la Polyvalence.
const _mage = Classe(
  id: 'm',
  nom: 'Mage',
  modifDeVie: ModifDe.egal,
  modifDeMana: ModifDe.egal,
  voies: [
    Voie(
      id: 'mage-feu',
      nom: 'Voie du feu',
      competences: [
        Competence(rang: 1, nom: 'Étincelle'),
        Competence(rang: 2, nom: 'Boule de feu'),
      ],
    ),
    Voie(
      id: 'mage-glace',
      nom: 'Voie de la glace',
      competences: [Competence(rang: 1, nom: 'Givre')],
    ),
  ],
);

List<Race> _races() {
  final races =
      (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
          .map((e) => Race.depuisJson(e as Map<String, dynamic>))
          .toList();
  Referentiel.completerReferences(races, const [_guerrier, _mage]);
  return races;
}

List<Equipement> _catalogue() => [
      for (final e in jsonDecode(
        File('assets/data/equipements.json').readAsStringSync(),
      ) as List)
        Equipement.depuisJson(e as Map<String, dynamic>),
    ];

FicheCalculee _fiche(
  Race r, {
  required int niveau,
  String? origine,
  Map<Carac, int> carac = const {},
  Map<String, String> choix = const {},
  Map<String, String> precisions = const {},
}) =>
    FicheCalculee(
      personnage: Personnage(
        id: 'p',
        nom: 'Test',
        raceId: r.id,
        classeId: 'g',
        niveau: niveau,
        origineId: origine,
        caracBase: {for (final c in Carac.values) c: 12, ...carac},
        choix: Map.of(choix),
        precisionsChoix: Map.of(precisions),
      ),
      race: r,
      classe: _guerrier,
    );

void main() {
  final races = _races();
  Race race(String id) => races.firstWhere((r) => r.id == id);

  test('langues : commun pour tous, langue de la race, choix de langue', () {
    expect(_fiche(race('humain'), niveau: 1).langues, ['Commun']);
    final nain = _fiche(race('nain'), niveau: 1);
    expect(nain.langues, ['Commun', 'Nain']);
    // Liste du monde, celles déjà parlées repérées
    final liste = nain.elementsChoix('langues');
    expect(liste.length, 7);
    expect(liste.firstWhere((l) => l.nom == 'Nain').maitrise, isTrue);
    expect(liste.firstWhere((l) => l.nom == 'Elfique').maitrise, isFalse);
    // Polyglotte (rang 1 humain) : la langue choisie est parlée
    final h = _fiche(race('humain'), niveau: 1);
    expect(h.choixEnAttente.single.choix.cle, 'langue-polyglotte');
    h.personnage
      ..choix['langue-polyglotte'] = 'langue'
      ..precisionsChoix['langue-polyglotte'] = 'Elfique';
    expect(h.langues, ['Commun', 'Elfique']);
    expect(h.choixEnAttente, isEmpty);
  });

  test('nouvelles armes : hache et marteau de guerre à une ou deux mains', () {
    final cat = _catalogue();
    for (final nom in ['Hache de guerre', 'Marteau de guerre']) {
      final e = cat.firstWhere((e) => e.nom == nom);
      final o = ObjetDuCatalogue.depuis(e);
      expect(o.polyvalente, isTrue, reason: nom);
      expect(o.degats, '1d6');
      expect(o.degatsDeuxMains, '1d8');
    }
  });

  group('humain : Origines marquées', () {
    test('marin : maîtrises et +5 navigation', () {
      final f = _fiche(race('humain'), niveau: 3, origine: 'marin');
      final bonus = f.bonusTestsSituationnels.map((s) => s.effet.condition);
      expect(bonus, contains('navigation'));
      expect(
        f.competencesAcquises.map((c) => c.competence.nom),
        contains('Bonus d\'origine'),
      );
      // Langue du rang 2 à choisir (celle du rang 1 aussi)
      expect(
        f.choixEnAttente.map((c) => c.choix.cle),
        containsAll(['langue-polyglotte', 'langue-origines']),
      );
    });

    test('campagnard : +5 SOC dans les campagnes', () {
      final f = _fiche(race('humain'), niveau: 3, origine: 'campagnard');
      final s = f.bonusTestsSituationnels
          .firstWhere((s) => s.effet.condition.contains('campagnes'));
      expect(s.effet.carac, Carac.soc);
      expect(s.effet.valeurEntiere, 5);
    });

    test('érudit : domaine de connaissance à choisir', () {
      final f = _fiche(race('humain'), niveau: 3, origine: 'erudit');
      expect(
        f.choixEnAttente.map((c) => c.choix.cle),
        contains('domaine-erudit'),
      );
      f.personnage
        ..choix['domaine-erudit'] = 'domaine'
        ..precisionsChoix['domaine-erudit'] = 'Histoire';
      final s = f.bonusTestsSituationnels
          .firstWhere((s) => s.effet.condition == 'connaissance : Histoire');
      expect(s.effet.carac, Carac.intel);
    });

    test('troubadour : instrument maîtrisé et reçu', () {
      final f = _fiche(
        race('humain'),
        niveau: 3,
        origine: 'troubadour',
        choix: {'instrument-troubadour': 'instrument'},
        precisions: {'instrument-troubadour': 'Luth'},
      );
      expect(f.instrumentsMaitrises.map((i) => i.nom), contains('Luth'));
      expect(f.objetsARecevoir.map((o) => o.objet['nom']), contains('Luth'));
    });
  });

  group('humain : Perfectionnement', () {
    test('stat la plus faible (hors CHAN) puis une autre', () {
      final f = _fiche(
        race('humain'),
        niveau: 9,
        carac: {Carac.intel: 8, Carac.chan: 3},
      );
      final faible = f.choixEnAttente
          .firstWhere((c) => c.choix.cle == 'perfectionnement-faible')
          .choix;
      expect(f.optionsPermises(faible), {'INT'});
      final autre = f.choixEnAttente
          .firstWhere((c) => c.choix.cle == 'perfectionnement-autre')
          .choix;
      f.personnage.choix['perfectionnement-faible'] = 'INT';
      final permises = f.optionsPermises(autre)!;
      expect(permises, isNot(contains('INT')));
      expect(permises.length, 9);
      f.personnage.choix['perfectionnement-autre'] = 'DEX';
      expect(f.carac(Carac.intel), 10);
      expect(f.carac(Carac.dex), 14);
      // Le +2 ne change pas la stat la plus faible retenue
      expect(f.optionsPermises(faible), {'INT'});
    });

    test('égalité : le joueur choisit parmi les plus faibles', () {
      final f = _fiche(
        race('humain'),
        niveau: 9,
        carac: {Carac.intel: 8, Carac.per: 8},
      );
      final faible = f.choixConnus['perfectionnement-faible']!;
      expect(f.optionsPermises(faible), {'INT', 'PER'});
    });
  });

  group('humain : Polyvalence', () {
    test('2 rangs d\'une autre classe, sans coût', () {
      final f = _fiche(race('humain'), niveau: 7);
      expect(f.empruntsAFaire, 2);
      expect(
        f.voiesEmpruntables.map((v) => v.voie.id),
        ['mage-feu', 'mage-glace'],
      );
      f.personnage.emprunts = {'mage-feu': 2};
      expect(f.empruntsAFaire, 0);
      final noms = f.competencesAcquises.map((c) => c.competence.nom);
      expect(noms, containsAll(['Étincelle', 'Boule de feu']));
      final c = f.competencesAcquises
          .firstWhere((c) => c.competence.nom == 'Boule de feu');
      expect(f.estEmprunt(c.voie), isTrue);
      // Aller-retour JSON
      expect(
        Personnage.depuisJson(f.personnage.versJson()).emprunts,
        {'mage-feu': 2},
      );
    });

    testWidgets('carte : rang 1 puis rang 2 de la même voie ou autre voie',
        (tester) async {
      Map<String, int> valeur = {};
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: CarteEmprunts(
                  nom: 'Polyvalence',
                  voies: FicheCalculee.voiesDesClasses,
                  valeur: valeur,
                  onChange: (v) => setState(() => valeur = v),
                ),
              ),
            ),
          ),
        ),
      );
      Future<void> tap(String cle) async {
        await tester.ensureVisible(find.byKey(Key(cle)));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key(cle)));
        await tester.pumpAndSettle();
      }

      bool actif(String cle) =>
          tester.widget<FilterChip>(find.byKey(Key(cle))).onSelected != null;

      // Voies regroupées par classe (volet à ouvrir)
      await tap('emprunts-classe-Mage');
      // Rang 2 directement : prend aussi le rang 1 (2 rangs)
      await tap('emprunt-mage-feu-2');
      expect(valeur, {'mage-feu': 2});
      expect(CarteEmprunts.complet(valeur), isTrue);
      expect(find.text('2 / 2'), findsOneWidget);
      // Plus de place : une autre voie est grisée
      expect(actif('emprunt-mage-glace-1'), isFalse);
      // Décocher le rang 2 garde le rang 1, puis une autre voie
      await tap('emprunt-mage-feu-2');
      expect(valeur, {'mage-feu': 1});
      await tap('emprunt-mage-glace-1');
      expect(valeur, {'mage-feu': 1, 'mage-glace': 1});
      expect(actif('emprunt-mage-feu-2'), isFalse);
      // Retirer un rang choisi depuis sa pastille
      await tap('retirer-emprunt-mage-glace');
      expect(valeur, {'mage-feu': 1});
      // Détails des rangs d'une voie
      await tap('emprunt-info-mage-feu');
      expect(find.text('Boule de feu'), findsWidgets);
    });
  });

  group('nain', () {
    test('Outils de nain : maîtrise, +1 toucher et +1 DM, arme offerte', () {
      final f = _fiche(
        race('nain'),
        niveau: 1,
        choix: {'arme-nain': 'marteau'},
      );
      expect(f.armesMaitrisees, containsAll(['Hache', 'Marteau']));
      expect(
        f.objetsARecevoir.map((o) => o.objet['nom']),
        ['Marteau de guerre'],
      );
      ObjetsDonnes.recevoir(f, catalogue: _catalogue());
      final marteau = f.objetNomme('Marteau de guerre')!;
      expect(marteau.origine, OrigineObjet.race);
      final sansArme = f.toucherCac;
      marteau.equipe = true;
      expect(f.toucherCac, sansArme + 1);
      final d = f.detailDegatsCac;
      expect(d.bonusAvec(marteau), d.bonus + 1);
      expect(d.des(marteau), '1d6');
      expect(d.explication, contains('+1 (Outils de nain'));
      // Autre arme : pas de bonus
      final epee = Objet(
        nom: 'Épée longue',
        categorie: CategorieObjet.arme,
        degats: '1d6',
      );
      f.personnage.inventaire.add(epee);
      expect(f.detailDegatsCac.bonusAvec(epee), d.bonus);
    });

    test('Tête de fer : coup de tête 1d6 + CON sur la page dé', () {
      final f = _fiche(race('nain'), niveau: 5, carac: {Carac.con: 14});
      final j = f.jetsCompetences
          .firstWhere((j) => j.libelle == 'Tête de fer (coup de tête)');
      expect(j.des, '1d6');
      expect(j.carac, Carac.con);
    });

    test('bouquetin : monture, +10 escalade seulement quand monté', () {
      final f = _fiche(race('nain'), niveau: 7);
      expect(
        f.objetsARecevoir.map((o) => o.objet['nom']),
        contains('Bouquetin'),
      );
      ObjetsDonnes.recevoir(f, catalogue: _catalogue());
      final b = f.objetNomme('Bouquetin')!;
      expect(b.categorie, CategorieObjet.monture);
      expect(b.mains, 0);
      bool escalade() => f.bonusTestsSituationnels
          .any((s) => s.effet.condition.contains('escalade'));
      expect(escalade(), isFalse);
      b.equipe = true;
      expect(escalade(), isTrue);
      // Une seule monture à la fois
      final cheval = Objet(nom: 'Cheval', categorie: CategorieObjet.monture);
      f.personnage.inventaire.add(cheval);
      expect(
        ReglesInventaire.refusEquipement(f.personnage.inventaire, cheval),
        isNotNull,
      );
    });

    test('Ténacité : RD élémentaire au choix', () {
      final f = _fiche(race('nain'), niveau: 9);
      final c = f.choixEnAttente
          .firstWhere((c) => c.choix.cle == 'rd-element-nain')
          .choix;
      expect(c.options.map((o) => o.nom), ['RD feu', 'RD glace', 'RD foudre']);
      f.personnage.choix['rd-element-nain'] = 'glace';
      expect(
        f.effetsActifs.map((s) => s.effet.categorie),
        contains('RD glace'),
      );
    });

    testWidgets('fiche : langues parlées affichées', (tester) async {
      tester.view.physicalSize = const Size(1400, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final p = Personnage(
        id: 'n',
        nom: 'Brok',
        raceId: 'nain',
        classeId: 'g',
        choix: {'arme-nain': 'hache'},
        objetsRecus: {'race-nain/1/arme-nain/hache/Hache de guerre'},
      );
      final controller =
          PersonnagesController(EnMemoirePersonnageRepository([p]));
      await controller.charger();
      await tester.pumpWidget(
        OdvApp(
          referentiel: Referentiel(races: races, classes: const [_guerrier]),
          controller: controller,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Brok'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final langues = find.byKey(const Key('langues-parlees'));
      await tester.ensureVisible(langues);
      expect(
        find.descendant(
            of: langues,
            matching: find.textContaining('Commun, Nain', findRichText: true)),
        findsOneWidget,
      );
    });
  });
}
