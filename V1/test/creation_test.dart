import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/app.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';

Voie _voie(String id, String nom) => Voie(
      id: id,
      nom: nom,
      competences: [
        for (var r = 1; r <= 5; r++)
          Competence(
              rang: r, nom: '$nom $r', type: 'passif', effet: 'Effet $r'),
      ],
    );

final _referentiel = Referentiel(
  races: [
    Race(
      id: 'nain',
      nom: 'Nain',
      deVie: 8,
      deMana: 4,
      modificateurs: const {Carac.con: 2, Carac.dex: -2},
      voieRaciale: _voie('race-nain', 'Voie du nain'),
    ),
    const Race(
      id: 'draconien',
      nom: 'Draconien',
      deVie: 8,
      deMana: 4,
      optionsPassif: [
        OptionPassif(
            id: 'souffle', nom: 'Souffle élémentaire', description: ''),
        OptionPassif(id: 'ailes', nom: 'Ailes vestigiales', description: ''),
      ],
    ),
  ],
  classes: [
    Classe(
      id: 'guerrier',
      nom: 'Guerrier',
      modifDeVie: ModifDe.plus,
      modifDeMana: ModifDe.moins,
      voies: [
        _voie('guerrier-bouclier', 'Voie du bouclier'),
        _voie('guerrier-melee', 'Voie de la mêlée'),
        _voie('guerrier-guerre', 'Voie de la guerre'),
        _voie('guerrier-polyvalence', 'Voie de la polyvalence'),
      ],
    ),
  ],
  aptitudes: const [
    Aptitude(id: 'natation', nom: 'Natation'),
    Aptitude(
      id: 'langue',
      nom: 'Nouvelle langue',
      question: 'Quelle langue ?',
      multiple: true,
    ),
    Aptitude(id: 'lire-ecrire', nom: 'Lire et écrire', inneeSiIntAuMoins: 10),
  ],
);

/// Fait défiler la liste de l'étape jusqu'à ce que [f] soit construit
/// (une ListView ne construit que ce qui est proche de l'écran).
/// [delta] > 0 fait défiler vers le bas, < 0 vers le haut.
Future<void> _voir(WidgetTester tester, Finder f, {double delta = 200}) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      delta,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await _voir(tester, f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

String _resume(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('resume-entete'))).data ?? '';

void main() {
  testWidgets('parcours complet de création d\'un personnage', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final controller = PersonnagesController(EnMemoirePersonnageRepository());
    await controller.charger();
    await tester.pumpWidget(
      OdvApp(referentiel: _referentiel, controller: controller),
    );
    await tester.pumpAndSettle();

    // Accueil → création
    await _tap(tester, find.text('Nouveau personnage'));
    expect(find.text('Étape 1 sur 6 · Identité'), findsOneWidget);

    final suivant = find.byKey(const Key('bouton-suivant'));
    FilledButton bouton() => tester.widget<FilledButton>(suivant);

    // 1. Identité : nom et sexe obligatoires
    expect(bouton().onPressed, isNull);
    await tester.enterText(find.byKey(const Key('champ-nom')), 'Brom');
    await tester.pumpAndSettle();
    expect(find.text('Choisis le sexe de ton personnage'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('sexe-homme')));
    expect(_resume(tester), 'Brom');
    await _tap(tester, suivant);

    // 2. Race : le draconien exige un héritage
    await _tap(tester, find.text('Draconien'));
    expect(find.text('Choisis un héritage'), findsOneWidget);
    await _tap(tester, find.text('Souffle élémentaire'));
    expect(_resume(tester), 'Brom · Draconien (souffle élémentaire)');
    // On préfère finalement le nain ; on consulte sa voie raciale
    await _tap(tester, find.text('Nain'));
    await _tap(tester, find.byKey(const Key('voie-raciale-nain')));
    expect(find.text('Voie raciale — Nain'), findsOneWidget);
    await _tap(tester, find.byTooltip('Fermer'));
    expect(bouton().onPressed, isNotNull);
    await _tap(tester, suivant);

    // 3. Classe : dés finaux nain + guerrier = d10 / DE d6 ; fenêtre des voies
    expect(find.text("Dé de vie d10 · Dé d'endurance d6"), findsOneWidget);
    await _tap(tester, find.text('Guerrier'));
    await _tap(tester, find.byKey(const Key('voies-guerrier')));
    expect(find.text('Voies — Guerrier'), findsOneWidget);
    await _tap(tester, find.byTooltip('Fermer'));
    expect(_resume(tester), 'Brom · Nain · Guerrier');
    await _tap(tester, suivant);

    // 4. Caractéristiques : 12 points, max 16
    expect(find.text('12 / 12'), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      await _tap(tester, find.byKey(const Key('plus-FOR')));
    }
    final plusFor =
        tester.widget<IconButton>(find.byKey(const Key('plus-FOR')));
    expect(plusFor.onPressed, isNull);
    await tester.scrollUntilVisible(
      find.byKey(const Key('plus-CHAN')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    final plusChan =
        tester.widget<IconButton>(find.byKey(const Key('plus-CHAN')));
    expect(plusChan.onPressed, isNull);
    await tester.scrollUntilVisible(
      find.byKey(const Key('plus-CON')),
      -200,
      scrollable: find.byType(Scrollable).last,
    );
    for (var i = 0; i < 6; i++) {
      await _tap(tester, find.byKey(const Key('plus-CON')));
    }
    await tester.scrollUntilVisible(
      find.text('0 / 12'),
      -200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('0 / 12'), findsOneWidget);
    await _tap(tester, suivant);

    // 5. Compétences : 3 points au niveau 1, rang 1 uniquement
    expect(find.text('Étape 5 sur 6 · Compétences'), findsOneWidget);
    expect(find.text('3 / 3'), findsOneWidget);
    // Rang 1 de la voie raciale offert
    expect(find.textContaining('Voie du nain 1'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('prendre-guerrier-bouclier')));
    // Le rang 2 n'est pas accessible au niveau 1
    final prendreBouclier = tester
        .widget<IconButton>(find.byKey(const Key('prendre-guerrier-bouclier')));
    expect(prendreBouclier.onPressed, isNull);
    await _tap(tester, find.byKey(const Key('prendre-guerrier-melee')));
    // On change d'avis : retirer la mêlée
    await _tap(tester, find.byKey(const Key('retirer-guerrier-melee')));
    // Lire et écrire est inné (INT 10) : pas besoin de l'acheter
    await _voir(tester, find.byKey(const Key('aptitude-lire-ecrire')));
    final lire = tester
        .widget<IconButton>(find.byKey(const Key('aptitude-lire-ecrire')));
    expect(lire.onPressed, isNull);
    // Apprendre une langue (1 point) : la fenêtre demande laquelle
    await _tap(tester, find.byKey(const Key('aptitude-langue')));
    await tester.enterText(find.byKey(const Key('champ-precision')), 'Elfique');
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('valider-precision')));
    expect(find.text('Elfique'), findsOneWidget);
    await _voir(tester, find.text('1 / 3'), delta: -200);
    expect(find.text('1 / 3'), findsOneWidget);
    // Pas obligé de tout dépenser : on peut continuer avec 1 point en réserve
    expect(bouton().onPressed, isNotNull);
    await _tap(tester, suivant);

    // 6. Récapitulatif : PV = d10 max (10) + mod CON (18 → +4) = 14
    expect(find.text('Étape 6 sur 6 · Récapitulatif'), findsOneWidget);
    expect(find.text('14'), findsWidgets);
    await _voir(tester, find.byKey(const Key('points-conserves')));
    expect(find.byKey(const Key('points-conserves')), findsOneWidget);
    await _tap(tester, find.text('Créer le personnage'));

    // Retour à l'accueil avec le personnage sauvegardé
    expect(controller.personnages, hasLength(1));
    final p = controller.personnages.first;
    expect(p.nom, 'Brom');
    expect(p.historique.single.message, startsWith('Personnage créé : Brom'));
    expect(p.sexe, Sexe.homme);
    expect(p.raceId, 'nain');
    expect(p.optionPassifId, isNull);
    expect(p.caracBase[Carac.force], 16);
    expect(p.caracBase[Carac.con], 16);
    expect(p.rangsVoies, {'guerrier-bouclier': 1});
    expect(p.aptitudes, [
      const AptitudeAcquise(id: 'langue', precision: 'Elfique'),
    ]);
    expect(find.text('Brom'), findsOneWidget);
  });

  testWidgets('grand écran : races à gauche, classes à droite, en 5 étapes',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = PersonnagesController(EnMemoirePersonnageRepository());
    await controller.charger();
    await tester.pumpWidget(
      OdvApp(referentiel: _referentiel, controller: controller),
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Nouveau personnage'));
    expect(find.text('Étape 1 sur 5 · Identité'), findsOneWidget);

    final suivant = find.byKey(const Key('bouton-suivant'));
    await tester.enterText(find.byKey(const Key('champ-nom')), 'Brom');
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('sexe-homme')));
    await _tap(tester, suivant);

    // Race et classe sur la même étape, côte à côte
    expect(find.text('Étape 2 sur 5 · Race et classe'), findsOneWidget);
    // (titre de la liste + message en bas tant que rien n'est choisi)
    expect(find.text('Choisis une race'), findsWidgets);
    expect(find.text('Choisis une classe'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Guerrier')).dx,
      greaterThan(tester.getTopRight(find.text('Nain')).dx),
    );
    await _tap(tester, find.text('Nain'));
    // La classe manque encore
    expect(
      tester.widget<Text>(find.byKey(const Key('message-blocage'))).data,
      'Choisis une classe',
    );
    await _tap(tester, find.text('Guerrier'));
    expect(_resume(tester), 'Brom · Nain · Guerrier');
    await _tap(tester, suivant);

    // L'étape « Classe » est sautée
    expect(find.text('Étape 3 sur 5 · Caractéristiques'), findsOneWidget);
    await _tap(tester, find.text('Précédent'));
    expect(find.text('Étape 2 sur 5 · Race et classe'), findsOneWidget);
  });

  testWidgets('quitter en cours de route demande confirmation', (tester) async {
    final controller = PersonnagesController(EnMemoirePersonnageRepository());
    await controller.charger();
    await tester.pumpWidget(
      OdvApp(referentiel: _referentiel, controller: controller),
    );
    await tester.pumpAndSettle();

    await _tap(tester, find.text('Nouveau personnage'));
    await tester.enterText(find.byKey(const Key('champ-nom')), 'Lia');
    await tester.pumpAndSettle();

    await _tap(tester, find.byType(BackButton));
    expect(find.text('Abandonner la création ?'), findsOneWidget);
    await _tap(tester, find.text('Abandonner'));
    expect(find.text("Aucun personnage pour l'instant"), findsOneWidget);
    expect(controller.personnages, isEmpty);
  });
}
