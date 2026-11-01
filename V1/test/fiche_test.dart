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
import 'package:odyssee_vagabonds/state/personnages_controller.dart';

const _referentiel = Referentiel(
  races: [
    Race(
      id: 'nain',
      nom: 'Nain',
      deVie: 8,
      deMana: 4,
      modificateurs: {Carac.con: 2, Carac.dex: -2},
    ),
  ],
  classes: [
    Classe(
      id: 'guerrier',
      nom: 'Guerrier',
      modifDeVie: ModifDe.plus,
      modifDeMana: ModifDe.moins,
    ),
  ],
  equipements: [
    Equipement(
      id: 'baton',
      nom: 'Bâton',
      categorie: CategorieEquipement.arme,
      sousCategorie: 'CaC, bâton, une main, deux mains, contondant',
      proprietes: {
        'Dégâts (une main)': '1D6 phy',
        'Dégâts (deux mains)': '1D8 phy',
        'Prix': '8 pa',
      },
    ),
  ],
);

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

String _texte(WidgetTester tester, String cle) =>
    tester.widget<Text>(find.byKey(Key(cle))).data ?? '';

Future<PersonnagesController> _ouvrirFiche(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);

  final controller = PersonnagesController(
    EnMemoirePersonnageRepository([
      Personnage(
        id: 'brom',
        nom: 'Brom',
        sexe: Sexe.homme,
        raceId: 'nain',
        classeId: 'guerrier',
        // CON 14 + 2 (race) = 16 → mod +3 ; PV max = d10 (10) + 3 = 13
        caracBase: {for (final c in Carac.values) c: 10}..[Carac.con] = 14,
      ),
    ]),
  );
  await controller.charger();
  await tester.pumpWidget(
    OdvApp(referentiel: _referentiel, controller: controller),
  );
  await tester.pumpAndSettle();
  await _tap(tester, find.text('Brom'));
  return controller;
}

void main() {
  testWidgets('PV : −1, dégâts, soins, sauvegarde', (tester) async {
    final controller = await _ouvrirFiche(tester);
    final p = controller.personnages.single;

    expect(_texte(tester, 'pv-actuel'), '13');
    await _tap(tester, find.byKey(const Key('pv-moins')));
    expect(_texte(tester, 'pv-actuel'), '12');

    // Dégâts de 15 : le personnage tombe à −3 (inconscient)
    await _tap(tester, find.byKey(const Key('pv-saisir')));
    await tester.enterText(find.byKey(const Key('champ-montant')), '15');
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('montant-moins')));
    expect(_texte(tester, 'pv-actuel'), '-3');
    expect(find.textContaining('Inconscient'), findsOneWidget);
    expect(p.pvActuels, -3);

    // Soins de 50 : plafonnés au maximum
    await _tap(tester, find.byKey(const Key('pv-saisir')));
    await tester.enterText(find.byKey(const Key('champ-montant')), '50');
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('montant-plus')));
    expect(_texte(tester, 'pv-actuel'), '13');
  });

  testWidgets('PV / PM : icônes, boutons colorés, commentaire', (tester) async {
    final controller = await _ouvrirFiche(tester);
    final p = controller.personnages.single;
    expect(find.byKey(const Key('pv-icone')), findsOneWidget);
    expect(find.byKey(const Key('pm-icone')), findsOneWidget);
    // −1 en rouge, +1 en vert (PV) : couleurs différentes.
    final moins = tester.widget<IconButton>(find.byKey(const Key('pv-moins')));
    final plus = tester.widget<IconButton>(find.byKey(const Key('pv-plus')));
    expect(moins.color, isNotNull);
    expect(plus.color, isNotNull);
    expect(moins.color, isNot(plus.color));

    // Dégâts avec un commentaire : noté dans l'historique.
    await _tap(tester, find.byKey(const Key('pv-saisir')));
    await tester.enterText(find.byKey(const Key('champ-montant')), '4');
    await tester.enterText(
        find.byKey(const Key('champ-commentaire')), 'Morsure de loup');
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('montant-moins')));
    expect(_texte(tester, 'pv-actuel'), '9');
    expect(p.historique.last.message, 'PV : 13 → 9 (−4) — Morsure de loup');

    // Sans commentaire : message habituel.
    await _tap(tester, find.byKey(const Key('pv-saisir')));
    await tester.enterText(find.byKey(const Key('champ-montant')), '1');
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('montant-plus')));
    expect(p.historique.last.message, 'PV : 9 → 10 (+1)');
  });

  testWidgets('inventaire : bourse, ajout, équipement, CA', (tester) async {
    final controller = await _ouvrirFiche(tester);
    final p = controller.personnages.single;

    await _tap(tester, find.text('Inventaire'));
    expect(find.text('Le sac est vide.'), findsOneWidget);

    // Bourse
    await _tap(tester, find.byKey(const Key('bouton-bourse')));
    await tester.enterText(find.byKey(const Key('champ-or')), '5');
    await tester.enterText(find.byKey(const Key('champ-argent')), '12');
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('valider-bourse')));
    expect(_texte(tester, 'bourse-or'), '5');
    expect(p.bourse.argent, 12);

    // Ajout d'une armure (CA +3)
    await _tap(tester, find.byKey(const Key('ajouter-objet')));
    await _tap(tester, find.byKey(const Key('objet-personnalise')));
    await tester.enterText(
      find.byKey(const Key('champ-nom-objet')),
      'Cotte de mailles',
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('categorie-armure')));
    for (var i = 0; i < 3; i++) {
      await _tap(tester, find.byKey(const Key('bonus-ca-plus')));
    }
    expect(_texte(tester, 'bonus-ca-valeur'), '+3');
    // Origine : inconnue par défaut ; « Race » et « Classe » ne se
    // choisissent pas
    expect(find.byKey(const Key('origine-race')), findsNothing);
    await _tap(tester, find.byKey(const Key('origine-achat')));
    await tester.enterText(
      find.byKey(const Key('champ-precision-origine')),
      'forgeron de Kar-Dun',
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('enregistrer-objet')));

    expect(find.text('Cotte de mailles'), findsOneWidget);
    expect(p.inventaire, hasLength(1));
    final cotte = p.inventaire.single;
    expect(cotte.categorie, CategorieObjet.armure);
    expect(cotte.bonusCA, 3);
    expect(cotte.equipe, isFalse);
    expect(cotte.texteOrigine, 'Achat (forgeron de Kar-Dun)');
    expect(find.textContaining('Origine : Achat'), findsOneWidget);

    // Objet donné par la race : origine affichée mais non modifiable
    cotte.origine = OrigineObjet.race;
    await _tap(tester, find.text('Cotte de mailles'));
    await tester.scrollUntilVisible(
      find.byKey(const Key('origine-verrouillee')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byKey(const Key('origine-verrouillee')), findsOneWidget);
    expect(find.byKey(const Key('origine-achat')), findsNothing);
    await _tap(tester, find.byKey(const Key('enregistrer-objet')));
    expect(cotte.origine, OrigineObjet.race);

    // On l'équipe : elle passe dans « Équipement porté »
    await _tap(tester, find.byKey(Key('equiper-${cotte.id}')));
    expect(cotte.equipe, isTrue);
    expect(find.text('Rien n\'est porté.'), findsNothing);

    // Une deuxième armure ne peut pas être portée en même temps
    p.inventaire.add(
      Objet(nom: 'Armure de cuir', categorie: CategorieObjet.armure),
    );
    await controller.sauvegarder(p);
    await tester.pumpAndSettle();
    final cuir = p.inventaire.last;
    await _tap(tester, find.byKey(Key('equiper-${cuir.id}')));
    expect(cuir.equipe, isFalse);
    expect(find.textContaining('déjà porté'), findsOneWidget);

    // Retour à l'onglet Fiche : CA = 10 + 3 + mod DEX (8 → −1) = 12
    await _tap(tester, find.text('Fiche'));
    expect(
      find.descendant(
          of: find.byKey(const Key('stat-ca')), matching: find.text('12')),
      findsOneWidget,
    );
  });

  testWidgets('inventaire : arme à une ou deux mains, changement de prise',
      (tester) async {
    final controller = await _ouvrirFiche(tester);
    final p = controller.personnages.single;

    await _tap(tester, find.text('Inventaire'));
    await _tap(tester, find.byKey(const Key('ajouter-objet')));
    await _tap(tester, find.byKey(const Key('objet-personnalise')));
    await tester.enterText(find.byKey(const Key('champ-nom-objet')), 'Bâton');
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('categorie-arme')));
    expect(find.byKey(const Key('champ-degats-deux-mains')), findsNothing);
    await _tap(tester, find.byKey(const Key('prise-polyvalente')));
    await tester.enterText(find.byKey(const Key('champ-degats')), '1d6');
    await tester.enterText(
      find.byKey(const Key('champ-degats-deux-mains')),
      '1d8',
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('enregistrer-objet')));

    final baton = p.inventaire.single;
    expect(baton.polyvalente, isTrue);
    expect(baton.degatsActuels, '1d6');
    expect(find.textContaining('1d6 · tenu à 1 main'), findsOneWidget);

    await _tap(tester, find.byKey(Key('prise-${baton.id}')));
    expect(baton.tenueDeuxMains, isTrue);
    expect(find.textContaining('1d8 · tenu à 2 mains'), findsOneWidget);
    expect(
      p.historique.map((e) => e.message),
      contains('Bâton : tenu à deux mains (1d8)'),
    );

    await _tap(tester, find.byKey(Key('prise-${baton.id}')));
    expect(baton.degatsActuels, '1d6');

    // Deux mains seulement : bâton (1 main) + dague équipés, le bâton ne
    // peut plus passer à deux mains
    final dague = Objet(nom: 'Dague', categorie: CategorieObjet.arme);
    p.inventaire.add(dague);
    await controller.sauvegarder(p);
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(Key('equiper-${baton.id}')));
    await _tap(tester, find.byKey(Key('equiper-${dague.id}')));
    expect(dague.equipe, isTrue);
    await _tap(tester, find.byKey(Key('prise-${baton.id}')));
    expect(baton.tenueDeuxMains, isFalse);
    expect(find.textContaining('déjà en main Dague'), findsOneWidget);
  });

  testWidgets('inventaire : objet choisi dans le catalogue', (tester) async {
    final controller = await _ouvrirFiche(tester);
    final p = controller.personnages.single;

    await _tap(tester, find.text('Inventaire'));
    await _tap(tester, find.byKey(const Key('ajouter-objet')));
    expect(find.text('Ajouter un objet'), findsWidgets);
    await _tap(tester, find.byKey(const Key('catalogue-baton')));
    // Objet du catalogue : attributs en lecture seule (quantité, origine et
    // précision seulement), bouton « Éditer l'objet »
    expect(find.byKey(const Key('resume-objet-verrouille')), findsOneWidget);
    expect(find.byKey(const Key('champ-nom-objet')), findsNothing);
    expect(find.byKey(const Key('editer-objet')), findsOneWidget);
    expect(find.byKey(const Key('champ-precision-origine')), findsOneWidget);
    await _tap(tester, find.byKey(const Key('quantite-plus')));
    await _tap(tester, find.byKey(const Key('enregistrer-objet')));

    final baton = p.inventaire.single;
    expect(baton.nom, 'Bâton');
    expect(baton.quantite, 2);
    expect(baton.polyvalente, isTrue);
    expect(baton.degatsDeuxMains, '1d8');
    expect(baton.duCatalogue, isTrue);
    expect(baton.personnalise, isFalse);
    expect(find.byKey(Key('personnalise-${baton.id}')), findsNothing);
    expect(find.text('Bâton ×2'), findsOneWidget);

    // Éditer : sans changement, pas personnalisé ; nom changé : personnalisé
    // (clé à molette).
    await _tap(tester, find.text('Bâton ×2'));
    await _tap(tester, find.byKey(const Key('editer-objet')));
    await _tap(tester, find.byKey(const Key('enregistrer-objet')));
    expect(baton.personnalise, isFalse);
    await _tap(tester, find.text('Bâton ×2'));
    await _tap(tester, find.byKey(const Key('editer-objet')));
    await tester.enterText(
        find.byKey(const Key('champ-nom-objet')), 'Bâton de chêne');
    await _tap(tester, find.byKey(const Key('enregistrer-objet')));
    expect(baton.personnalise, isTrue);
    expect(find.byKey(Key('personnalise-${baton.id}')), findsOneWidget);
    // Personnalisé : le formulaire s'ouvre directement modifiable.
    await _tap(tester, find.text('Bâton de chêne ×2'));
    expect(find.byKey(const Key('champ-nom-objet')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('champ-nom-objet')), 'Bâton');
    await _tap(tester, find.byKey(const Key('enregistrer-objet')));

    // Équipé et tenu à deux mains : dégâts CaC = 1d8 + mod FOR (+0)
    await _tap(tester, find.byKey(Key('equiper-${baton.id}')));
    await _tap(tester, find.byKey(Key('prise-${baton.id}')));
    await _tap(tester, find.text('Fiche'));
    final caseCac = find.byKey(const Key('stat-deg-cac'));
    await tester.ensureVisible(caseCac);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: caseCac,
              matching: find.byKey(const Key('valeur')),
            ),
          )
          .data,
      '1d8',
    );
    expect(
      find.descendant(of: caseCac, matching: find.text('Bâton · 2 mains')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Tooltip>(
            find.descendant(of: caseCac, matching: find.byType(Tooltip)),
          )
          .message,
      contains('Bâton (tenu à deux mains) : 1d8'),
    );

    // Une deuxième arme de CaC équipée : une ligne de plus dans la case
    p.inventaire.add(
      Objet(
        nom: 'Dague',
        categorie: CategorieObjet.arme,
        degats: '1d4',
        equipe: true,
      ),
    );
    await controller.sauvegarder(p);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: caseCac,
              matching: find.byKey(const Key('valeur-1')),
            ),
          )
          .data,
      '1d4',
    );
    expect(
      find.descendant(of: caseCac, matching: find.text('Dague')),
      findsOneWidget,
    );
  });

  testWidgets('bourse : +1 / −1, recevoir, payer', (tester) async {
    final controller = await _ouvrirFiche(tester);
    final b = controller.personnages.single.bourse;

    await _tap(tester, find.text('Inventaire'));
    // Payer est désactivé quand la bourse est vide
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('bourse-payer')))
          .onPressed,
      isNull,
    );

    await _tap(tester, find.byKey(const Key('bourse-cuivre-plus')));
    await _tap(tester, find.byKey(const Key('bourse-cuivre-plus')));
    await _tap(tester, find.byKey(const Key('bourse-cuivre-moins')));
    expect(_texte(tester, 'bourse-cuivre'), '1');

    // Recevoir 10 or et 5 argent
    await _tap(tester, find.byKey(const Key('bourse-recevoir')));
    await tester.enterText(find.byKey(const Key('transaction-or')), '10');
    await tester.enterText(find.byKey(const Key('transaction-argent')), '5');
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('valider-transaction')));
    expect(_texte(tester, 'bourse-or'), '10');
    expect(_texte(tester, 'bourse-argent'), '5');

    // Payer plus que ce qu'on a : refusé
    await _tap(tester, find.byKey(const Key('bourse-payer')));
    await tester.enterText(find.byKey(const Key('transaction-argent')), '8');
    await tester.pumpAndSettle();
    expect(find.text('Pas assez de pièces d\'argent.'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('valider-transaction')))
          .onPressed,
      isNull,
    );
    // Payer 3 or, avec un commentaire (noté dans l'historique)
    await tester.enterText(find.byKey(const Key('transaction-argent')), '');
    await tester.enterText(find.byKey(const Key('transaction-or')), '3');
    await tester.enterText(find.byKey(const Key('transaction-commentaire')),
        'auberge du Sanglier');
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('valider-transaction')));
    expect(b.or, 7);
    expect(b.argent, 5);
    expect(b.cuivre, 1);
    final p = controller.personnages.single;
    expect(p.historique.last.message, startsWith('Payé : '));
    expect(p.historique.last.message, endsWith(' — auberge du Sanglier'));

    // Correction de la bourse, avec un commentaire
    await _tap(tester, find.byKey(const Key('bouton-bourse')));
    await tester.enterText(find.byKey(const Key('champ-or')), '8');
    await tester.enterText(
        find.byKey(const Key('bourse-commentaire')), 'oubli de la séance');
    await _tap(tester, find.byKey(const Key('valider-bourse')));
    expect(p.bourse.or, 8);
    expect(p.historique.last.message, startsWith('Bourse corrigée : '));
    expect(p.historique.last.message, endsWith(' — oubli de la séance'));
  });

  testWidgets('le message « objet retiré » disparaît tout seul',
      (tester) async {
    final controller = await _ouvrirFiche(tester);
    final p = controller.personnages.single;
    p.inventaire.add(Objet(nom: 'Corde', categorie: CategorieObjet.divers));
    await controller.sauvegarder(p);

    await _tap(tester, find.text('Inventaire'));
    final corde = p.inventaire.single;
    await _tap(tester, find.byKey(Key('menu-objet-${corde.id}')));
    await _tap(tester, find.text('Supprimer'));
    expect(p.inventaire, isEmpty);
    expect(find.text('Corde retiré de l\'inventaire.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Corde retiré de l\'inventaire.'), findsNothing);
  });

  testWidgets('l\'onglet Historique liste les modifications', (tester) async {
    await _ouvrirFiche(tester);

    await _tap(tester, find.text('Historique'));
    expect(
      find.text('Aucune modification enregistrée pour l\'instant.'),
      findsOneWidget,
    );

    await _tap(tester, find.text('Fiche'));
    await _tap(tester, find.byKey(const Key('pv-moins')));
    await _tap(tester, find.byKey(const Key('pv-moins')));

    await _tap(tester, find.text('Inventaire'));
    await _tap(tester, find.byKey(const Key('bourse-recevoir')));
    await tester.enterText(find.byKey(const Key('transaction-or')), '4');
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('valider-transaction')));

    await _tap(tester, find.text('Historique'));
    expect(find.text('Aujourd\'hui'), findsOneWidget);
    expect(find.text('PV : 13 → 11 (−2)'), findsOneWidget);
    expect(find.text('Reçu : 4 or'), findsOneWidget);

    // Filtre « Bourse » : la ligne des PV disparaît
    await _tap(tester, find.byKey(const Key('filtre-bourse')));
    expect(find.text('PV : 13 → 11 (−2)'), findsNothing);
    expect(find.text('Reçu : 4 or'), findsOneWidget);
  });

  testWidgets('suppression du personnage depuis la fiche', (tester) async {
    final controller = await _ouvrirFiche(tester);

    await _tap(tester, find.byKey(const Key('menu-fiche')));
    await _tap(tester, find.text('Supprimer le personnage'));
    await _tap(tester, find.byKey(const Key('confirmer-suppression')));

    expect(controller.personnages, isEmpty);
    expect(find.text("Aucun personnage pour l'instant"), findsOneWidget);
  });
}
