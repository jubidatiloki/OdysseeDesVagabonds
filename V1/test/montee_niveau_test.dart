import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/app.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/historique.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/montee_niveau.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';

Voie _voie(String id, String nom) => Voie(
      id: id,
      nom: nom,
      competences: [
        for (var r = 1; r <= 5; r++)
          Competence(rang: r, nom: '$nom $r', effet: 'Effet $r'),
      ],
    );

final _nain = Race(
  id: 'nain',
  nom: 'Nain',
  deVie: 8,
  deMana: 4,
  modificateurs: const {Carac.con: 2, Carac.dex: -2},
  voieRaciale: _voie('race-nain', 'Voie du nain'),
);

final _guerrier = Classe(
  id: 'guerrier',
  nom: 'Guerrier',
  modifDeVie: ModifDe.plus,
  modifDeMana: ModifDe.moins,
  voies: [
    _voie('g-bouclier', 'Voie du bouclier'),
    _voie('g-melee', 'Voie de la mêlée'),
  ],
);

Personnage _brom({int? pv, int? pe}) => Personnage(
      id: 'brom',
      nom: 'Brom',
      raceId: 'nain',
      classeId: 'guerrier',
      rangsVoies: {'g-bouclier': 1},
      aptitudes: [const AptitudeAcquise(id: 'natation')],
      pvActuels: pv,
      peActuels: pe,
    );

void main() {
  group('règles de montée de niveau', () {
    test('PV / PE max et actuels augmentent du gain', () {
      // Nain guerrier : DV d10, DE d6 ; CON 12 → +1 ; PV max 11, PE max 6.
      // Classe physique : pas de mana (règle du 03/11/2026).
      final p = _brom(pv: 5, pe: 1);
      final r = MonteeNiveau.appliquer(
        personnage: p,
        race: _nain,
        classe: _guerrier,
        jetDeVie: 3,
        jetDEndurance: 2,
        rangsVoies: p.rangsVoies,
        aptitudes: p.aptitudes,
      );
      final f = FicheCalculee(personnage: p, race: _nain, classe: _guerrier);
      expect(r.niveauApres, 2);
      expect(r.pvMaxAvant, 11);
      expect(f.pvMax, 14);
      expect(p.pvActuels, 8); // 5/11 → 8/14
      expect(f.peMax, 8);
      expect(p.peActuels, 3); // 1/6 → 3/8
      expect(f.pmMax, 0);
      expect(r.pointsGagnes, 2);
      expect(p.jetsDeVie, [3]);
      expect(p.jetsDEndurance, [2]);
      expect(p.jetsDeMana, isEmpty);
      expect(
          p.historique.first.message, contains('PE max 6 → 8 (+2 : d6 = 2)'));
      expect(p.historique.first.message, isNot(contains('PM')));
    });

    test('un personnage au maximum reste au maximum', () {
      final p = _brom();
      MonteeNiveau.appliquer(
        personnage: p,
        race: _nain,
        classe: _guerrier,
        jetDeVie: 7,
        jetDEndurance: 4,
        rangsVoies: p.rangsVoies,
        aptitudes: p.aptitudes,
      );
      final f = FicheCalculee(personnage: p, race: _nain, classe: _guerrier);
      expect(f.pvActuels, f.pvMax);
      expect(f.peActuels, f.peMax);
    });

    test('nouvelles compétences et rang racial inscrits dans l\'historique',
        () {
      final p = _brom()..niveau = 2;
      MonteeNiveau.appliquer(
        personnage: p,
        race: _nain,
        classe: _guerrier,
        jetDeVie: 5,
        jetDEndurance: 1,
        rangsVoies: {'g-bouclier': 2, 'g-melee': 1},
        aptitudes: [
          const AptitudeAcquise(id: 'natation'),
          const AptitudeAcquise(id: 'langue', precision: 'Elfique'),
        ],
        catalogueAptitudes: const [
          Aptitude(id: 'langue', nom: 'Nouvelle langue'),
        ],
      );
      expect(p.niveau, 3);
      final messages = p.historique.map((e) => e.message).toList();
      expect(messages.first, startsWith('Niveau 2 → 3 : PV max'));
      expect(p.historique.first.categorie, CategorieHistorique.niveau);
      expect(
          messages,
          contains('Compétence raciale : Voie du nain 2 '
              '(Voie du nain, rang 2)'));
      expect(
          messages,
          contains('Compétence acquise : Voie du bouclier 2 '
              '(Voie du bouclier, rang 2)'));
      expect(
          messages,
          contains('Compétence acquise : Voie de la mêlée 1 '
              '(Voie de la mêlée, rang 1)'));
      expect(
          messages, contains('Aptitude acquise : Nouvelle langue (Elfique)'));
      expect(messages.where((m) => m.contains('natation')), isEmpty);
    });

    test('impossible au-delà du niveau 10', () {
      expect(MonteeNiveau.possible(_brom()..niveau = 9), isTrue);
      expect(MonteeNiveau.possible(_brom()..niveau = 10), isFalse);
    });
  });

  testWidgets('assistant de montée de niveau depuis la fiche', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final p = _brom(pv: 5);
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      OdvApp(
        referentiel: Referentiel(races: [_nain], classes: [_guerrier]),
        controller: controller,
      ),
    );
    await tester.pumpAndSettle();

    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    await tap(find.text('Brom'));
    await tap(find.byKey(const Key('bouton-monter-niveau')));
    expect(find.text('Niveau 1 → 2'), findsOneWidget);

    // Étape 1 : jets (saisis) — bloqué tant qu'ils manquent
    final suivant = find.byKey(const Key('niveau-suivant'));
    expect(tester.widget<FilledButton>(suivant).onPressed, isNull);
    await tester.enterText(find.byKey(const Key('jet-dv')), '4');
    await tester.enterText(find.byKey(const Key('jet-de')), '2');
    await tester.pumpAndSettle();
    expect(find.textContaining('PV actuels : 5 → 9'), findsOneWidget);
    await tap(suivant);

    // Étape 2 : le rang 1 acquis ne peut pas être retiré ; rang 2 accessible
    expect(find.byKey(const Key('retirer-g-bouclier')), findsNothing);
    await tap(find.byKey(const Key('prendre-g-bouclier')));
    expect(find.byKey(const Key('retirer-g-bouclier')), findsOneWidget);
    await tap(suivant);

    // Étape 3 : récapitulatif puis validation
    expect(find.textContaining('PV max : 11 → 15'), findsOneWidget);
    await tap(suivant);

    expect(p.niveau, 2);
    expect(p.pvActuels, 9);
    expect(p.rangsVoies, {'g-bouclier': 2});
    // Téléphone : libellé court dans la barre du haut, texte complet au survol
    expect(find.byTooltip('Monter au niveau 3'), findsOneWidget);
    expect(find.text('Niveau 3'), findsOneWidget);
    expect(find.text('Brom passe au niveau 2 !'), findsOneWidget);
  });

  testWidgets('choix d\'une compétence obligatoire pendant la montée',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    // Voie raciale dont le rang 2 (offert au niveau 3) demande un choix
    final race = Race(
      id: 'nain',
      nom: 'Nain',
      deVie: 8,
      deMana: 4,
      voieRaciale: Voie(
        id: 'race-nain',
        nom: 'Voie du nain',
        competences: [
          const Competence(rang: 1, nom: 'Outils', effet: 'Hache.'),
          Competence(
            rang: 2,
            nom: 'Héritage',
            effet: 'Bonus au choix.',
            choix: ChoixCompetence(
              cle: 'heritage',
              titre: 'Bonus',
              options: [
                OptionChoix(id: 'force', nom: '+2 FOR'),
                OptionChoix(id: 'con', nom: '+2 CON'),
              ],
            ),
          ),
        ],
      ),
    );
    final p = Personnage(
      id: 'brom',
      nom: 'Brom',
      raceId: 'nain',
      classeId: 'guerrier',
      niveau: 2,
      jetsDeVie: [3],
      jetsDEndurance: [1],
    );
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      OdvApp(
        referentiel: Referentiel(races: [race], classes: [_guerrier]),
        controller: controller,
      ),
    );
    await tester.pumpAndSettle();

    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    await tap(find.text('Brom'));
    await tap(find.byKey(const Key('bouton-monter-niveau')));
    final suivant = find.byKey(const Key('niveau-suivant'));
    await tester.enterText(find.byKey(const Key('jet-dv')), '4');
    await tester.enterText(find.byKey(const Key('jet-de')), '2');
    await tester.pumpAndSettle();
    await tap(suivant); // → compétences
    await tap(suivant); // → récapitulatif

    // Choix à faire : validation bloquée
    expect(find.byKey(const Key('choix-heritage')), findsOneWidget);
    expect(tester.widget<FilledButton>(suivant).onPressed, isNull);
    expect(find.text('Choix à faire : Héritage'), findsOneWidget);
    await tap(find.byKey(const Key('option-heritage-con')));
    await tap(suivant);

    expect(p.niveau, 3);
    expect(p.choix, {'heritage': 'con'});
    expect(
      p.historique.map((e) => e.message),
      contains('Choix · Bonus : +2 CON'),
    );
  });

  testWidgets('points restants dépensés depuis l\'onglet Compétences',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    // Niveau 1 : 3 points, 2 dépensés (bouclier 1 + natation) → 1 restant
    final p = _brom();
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      OdvApp(
        referentiel: Referentiel(races: [_nain], classes: [_guerrier]),
        controller: controller,
      ),
    );
    await tester.pumpAndSettle();

    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    await tap(find.text('Brom'));
    await tap(find.text('Compétences'));
    expect(
      tester.widget<Text>(find.byKey(const Key('points-disponibles'))).data,
      '1',
    );
    await tap(find.byKey(const Key('depenser-points')));
    // Rien de changé : validation impossible
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('valider-depense-points')))
          .onPressed,
      isNull,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('prendre-g-melee')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tap(find.byKey(const Key('prendre-g-melee')));
    await tap(find.byKey(const Key('valider-depense-points')));

    expect(p.niveau, 1);
    expect(p.rangsVoies, {'g-bouclier': 1, 'g-melee': 1});
    expect(
      p.historique.map((e) => e.message),
      contains('Compétence acquise : Voie de la mêlée 1 (Voie de la mêlée, '
          'rang 1)'),
    );
    // Plus de point : le bouton disparaît
    expect(find.byKey(const Key('depenser-points')), findsNothing);
  });

  testWidgets('montée annulée après les jets : inscrite dans l\'historique',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final p = _brom(pv: 5);
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      OdvApp(
        referentiel: Referentiel(races: [_nain], classes: [_guerrier]),
        controller: controller,
      ),
    );
    await tester.pumpAndSettle();

    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    await tap(find.text('Brom'));
    final avant = p.historique.length;

    // Sans aucun jet : l'annulation n'ajoute rien à l'historique
    await tap(find.byKey(const Key('bouton-monter-niveau')));
    await tap(find.byType(BackButton));
    expect(find.text('Niveau 1 → 2'), findsNothing);
    expect(p.historique.length, avant);

    // Avec des jets : impossible de relancer ; entrée d'historique à
    // l'annulation
    await tap(find.byKey(const Key('bouton-monter-niveau')));
    await tap(find.byKey(const Key('lancer-dv')));
    String champ(String cle) =>
        tester.widget<TextField>(find.byKey(Key(cle))).controller!.text;
    final jetVie = champ('jet-dv');
    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: find.text('Dé lancé'),
              matching: find.byWidgetPredicate((w) => w is FilledButton),
            ),
          )
          .onPressed,
      isNull,
    );
    expect(find.byKey(const Key('jet-definitif-dv')), findsOneWidget);
    await tap(find.byKey(const Key('lancer-de')));
    final jetEndurance = champ('jet-de');
    expect(p.jetsMontee?.niveau, 2);
    await tap(find.byType(BackButton));
    expect(find.text('Annuler la montée de niveau ?'), findsOneWidget);
    await tap(find.text('Annuler la montée'));

    expect(p.niveau, 1);
    expect(p.historique.length, avant + 1);
    final entree = p.historique.last;
    expect(entree.categorie, CategorieHistorique.niveau);
    expect(entree.message,
        startsWith('Montée au niveau 2 annulée après les jets'));
    expect(entree.message, contains('dé de vie d'));
    expect(entree.message, contains("dé d'endurance d"));

    // On recommence : les mêmes jets reviennent, toujours verrouillés
    await tap(find.byKey(const Key('bouton-monter-niveau')));
    expect(champ('jet-dv'), jetVie);
    expect(champ('jet-de'), jetEndurance);
    expect(find.byKey(const Key('jet-definitif-dv')), findsOneWidget);
    expect(find.byKey(const Key('jet-definitif-de')), findsOneWidget);
  });
}
