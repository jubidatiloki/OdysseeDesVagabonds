import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/des.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/historique_lancers.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';

/// Guerrier : quatre voies adaptées (25/10/2026) — à couvert, rempart,
/// attaques au d12, coup de boucher (÷2), arme de prédilection,
/// ambidextrie, postures exclusives.

final _classes =
    (jsonDecode(File('assets/data/classes.json').readAsStringSync()) as List)
        .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
        .toList();
final _guerrier = _classes.firstWhere((c) => c.id == 'guerrier');
final _humain =
    (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
        .map((e) => Race.depuisJson(e as Map<String, dynamic>))
        .firstWhere((r) => r.id == 'humain');

Objet _epee({String nom = 'Épée longue'}) => Objet(
      nom: nom,
      categorie: CategorieObjet.arme,
      degats: '1d6',
      equipe: true,
    );

Personnage _perso({
  Map<String, int> rangs = const {},
  Map<String, String> choix = const {},
  Map<String, String> precisions = const {},
  List<Objet>? inventaire,
  Set<String> etats = const {},
}) =>
    Personnage(
      id: 'g',
      nom: 'Gauvain',
      raceId: 'humain',
      classeId: 'guerrier',
      niveau: 9,
      rangsVoies: Map.of(rangs),
      choix: Map.of(choix),
      precisionsChoix: Map.of(precisions),
      etats: Set.of(etats),
      caracBase: {for (final c in Carac.values) c: 12},
      inventaire: inventaire ?? [_epee()],
    );

FicheCalculee _fiche({
  Map<String, int> rangs = const {},
  Map<String, String> choix = const {},
  Map<String, String> precisions = const {},
  List<Objet>? inventaire,
  Set<String> etats = const {},
}) =>
    FicheCalculee(
      personnage: _perso(
        rangs: rangs,
        choix: choix,
        precisions: precisions,
        inventaire: inventaire,
        etats: etats,
      ),
      race: _humain,
      classe: _guerrier,
    );

void main() {
  Referentiel.completerReferences([_humain], _classes);
  final base = _fiche();

  test('bouclier : À couvert +3 (+5 avec Égide), rempart avec bouclier', () {
    final couvert =
        _fiche(rangs: {'guerrier-bouclier': 2}, etats: {'À couvert'});
    expect(couvert.caCac, base.caCac + 3);
    expect(couvert.caDistance, base.caDistance + 3);
    expect(couvert.caMagie, base.caMagie + 3);
    // +3 CA (toutes attaques, équilibrage du 03/11/2026).
    expect(couvert.classeArmure, base.classeArmure + 3);
    final egide = _fiche(rangs: {'guerrier-bouclier': 5}, etats: {'À couvert'});
    // L'état du rang 5 remplace celui du rang 2 (pas de cumul).
    expect(egide.caCac, base.caCac + 5);
    expect(egide.carac(Carac.con), base.carac(Carac.con) + 2);
    expect(egide.etatsPossibles.where((e) => e.etat.nom == 'À couvert'),
        hasLength(1));
    // Rempart : +2 CA MAG seulement avec un bouclier équipé.
    final sansBouclier = _fiche(rangs: {'guerrier-bouclier': 4});
    final avecBouclier = _fiche(rangs: {
      'guerrier-bouclier': 4
    }, inventaire: [
      _epee(),
      Objet(nom: 'Bouclier', categorie: CategorieObjet.bouclier, equipe: true),
    ]);
    expect(sansBouclier.caMagie, base.caMagie);
    expect(avecBouclier.caMagie, base.caMagie + 2);
    expect(sansBouclier.usages.single.nom, 'Rempart arcanique');
    expect(sansBouclier.usages.single.periode, 'par combat');
  });

  test('mêlée : entraînement martial, frappe au d12, coup de boucher', () {
    final r3 = _fiche(rangs: {'guerrier-melee': 3});
    // « Formation » renommée : un seul nom par compétence.
    expect(_guerrier.voies[1].competence(1)!.nom, 'Entraînement martial');
    expect(
      r3.bonusTestsPermanents
          .where((s) => s.effet.carac == Carac.adc)
          .single
          .effet
          .valeurEntiere,
      3,
    );
    // Toucher seulement : l'esquive ne bouge pas.
    expect(r3.caCac, base.caCac);
    final frappe = r3.jetsCompetences
        .firstWhere((j) => j.libelle == 'Frappe de précision');
    expect(frappe.des, '1d12');
    expect(frappe.attaque!.degatsEnPlus, '2d6');
    final boucher =
        r3.jetsCompetences.firstWhere((j) => j.libelle == 'Coup de boucher');
    expect(boucher.attaque!.diviseDegats, 2);
    JetDisponible membre(FicheCalculee f) => f.jetsCompetences
        .firstWhere((j) => j.libelle == 'Coup de boucher : membre tranché');
    expect(membre(r3).difficulte, 5);
    expect(membre(_fiche(rangs: {'guerrier-melee': 5})).difficulte, 4);
  });

  test('arme de prédilection : +2 au toucher et +1d4 avec elle', () {
    final f = _fiche(
      rangs: {'guerrier-melee': 4},
      choix: {'arme-predilection': 'arme'},
      precisions: {'arme-predilection': 'Épée'},
    );
    final arme = f.personnage.inventaire.single;
    expect(
      f
          .bonusToucher(distance: false)
          .any((b) => b.nom == 'Arme de prédilection' && b.valeur == 2),
      isTrue,
    );
    expect(f.desEnPlus(arme).map((s) => s.effet.valeur), contains('1d4'));
    final autre = _fiche(
      rangs: {'guerrier-melee': 4},
      choix: {'arme-predilection': 'arme'},
      precisions: {'arme-predilection': 'Hache'},
    );
    expect(autre.desEnPlus(autre.personnage.inventaire.single), isEmpty);
  });

  test('ambidextrie : deux armes à une main, 2ᵉ arme au d20', () {
    final f = _fiche(
      rangs: {'guerrier-melee': 5},
      inventaire: [_epee(), _epee(nom: 'Dague')],
    );
    expect(f.ambidextre, isTrue);
    expect(f.armesDoubles, isNotNull);
    expect(_fiche(inventaire: [_epee(), _epee(nom: 'Dague')]).armesDoubles,
        isNull);
  });

  test('guerre : contre-attaque d12 puis d20, position, vétéran', () {
    String de(FicheCalculee f) =>
        f.jetsCompetences.firstWhere((j) => j.libelle == 'Contre-attaque').des;
    expect(de(_fiche(rangs: {'guerrier-guerre': 2})), '1d12');
    expect(de(_fiche(rangs: {'guerrier-guerre': 3})), '1d20');
    final position =
        _fiche(rangs: {'guerrier-guerre': 4}, etats: {'Tenir une position'});
    expect(position.caCac, base.caCac + 3);
    final veteran =
        _fiche(rangs: {'guerrier-guerre': 5}, choix: {'veteran': 'CON'});
    expect(veteran.carac(Carac.con), base.carac(Carac.con) + 2);
    expect(veteran.carac(Carac.force), base.carac(Carac.force));
    // Rangs serrés : CA à cocher, jamais comptée seule.
    expect(
      veteran.situationsHorsTests.any((s) => s.nom == 'Rangs serrés'),
      isTrue,
    );
  });

  test('polyvalence : archerie, postures, imprévisible', () {
    final f = _fiche(rangs: {'guerrier-polyvalence': 5});
    expect(f.armesMaitrisees, containsAll(['Arc', 'Arbalète', 'Mousquet']));
    final def = _fiche(
        rangs: {'guerrier-polyvalence': 4}, etats: {'Posture défensive'});
    final off = _fiche(
        rangs: {'guerrier-polyvalence': 4}, etats: {'Posture offensive'});
    expect(def.classeArmure, base.classeArmure + 3);
    expect(off.classeArmure, base.classeArmure - 3);
    expect(
      off
          .desEnPlus(off.personnage.inventaire.single)
          .map((s) => s.effet.valeur),
      contains('1d6'),
    );
    expect(
      f.bonusTestsSituationnels.where((s) => s.nom == 'Imprévisible'),
      hasLength(2),
    );
  });

  test('dégâts divisés : arrondi à l\'inférieur, noté « ÷2 »', () {
    final r = ResultatLancer(
      libelle: 'Coup de boucher · dégâts',
      formule: '1d6 +2',
      des: const [5],
      garde: 5,
      bonus: 2,
    ).divise(2);
    expect(r.total, 3); // 7 ÷ 2
    expect(r.detail, contains('(÷2)'));
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
        preferences: PreferencesController(personnageActifId: 'g'),
        historique: historique,
        aleatoire: Random(9),
      ),
    ));
    await tester.pumpAndSettle();
    return (controller, historique);
  }

  testWidgets('page dé : postures exclusives, frappe au d12, boucher ÷2',
      (tester) async {
    final (controller, historique) = await ouvrir(
      tester,
      _perso(rangs: {'guerrier-polyvalence': 4, 'guerrier-melee': 3}),
    );
    Future<void> toucher(Key k) async {
      await tester.ensureVisible(find.byKey(k));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(k));
      await tester.pumpAndSettle();
    }

    await toucher(const Key('etat-Posture défensive'));
    expect(controller.personnages.single.etats, {'Posture défensive'});
    await toucher(const Key('etat-Posture offensive'));
    expect(controller.personnages.single.etats, {'Posture offensive'});

    final frappe = controller.personnages.single;
    final f =
        FicheCalculee(personnage: frappe, race: _humain, classe: _guerrier);
    final i =
        f.jetsCompetences.indexWhere((j) => j.libelle == 'Frappe de précision');
    await toucher(Key('jet-competence-$i'));
    expect(historique.lancers.first.formule, startsWith('1d12'));

    final b =
        f.jetsCompetences.indexWhere((j) => j.libelle == 'Coup de boucher');
    await toucher(Key('degats-competence-$b'));
    expect(historique.lancers.first.situations.last.nom, '÷2');
  });
}
