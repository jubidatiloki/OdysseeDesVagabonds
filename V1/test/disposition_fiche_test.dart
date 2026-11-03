import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/app.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';

const _referentiel = Referentiel(
  races: [
    Race(
      id: 'nain',
      nom: 'Nain',
      deVie: 8,
      deMana: 4,
      passif: Passif(nom: 'Vision naine', description: 'Voit dans le noir.'),
      voieRaciale: Voie(
        id: 'race-nain',
        nom: 'Voie du nain',
        competences: [
          Competence(
            rang: 1,
            nom: 'Outils de nain',
            type: 'passif',
            effet: 'Maîtrise de la hache.',
          ),
        ],
      ),
    ),
  ],
  classes: [
    Classe(
      id: 'guerrier',
      nom: 'Guerrier',
      modifDeVie: ModifDe.plus,
      modifDeMana: ModifDe.moins,
      voies: [
        Voie(
          id: 'g-melee',
          nom: 'Voie de la mêlée',
          competences: [
            Competence(
              rang: 1,
              nom: 'Coup puissant',
              type: 'actif, compétence',
              effet: '+1d6 DMG.',
            ),
          ],
        ),
      ],
    ),
  ],
);

Future<void> _ouvrir(WidgetTester tester, Size taille) async {
  tester.view.physicalSize = taille;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final controller = PersonnagesController(
    EnMemoirePersonnageRepository([
      Personnage(
        id: 'b',
        nom: 'Brom',
        raceId: 'nain',
        classeId: 'guerrier',
        description: 'Forgeron exilé des montagnes.',
        rangsVoies: {'g-melee': 1},
      ),
    ]),
  );
  await controller.charger();
  await tester.pumpWidget(
    OdvApp(referentiel: _referentiel, controller: controller),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Brom'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'grand écran : description en haut, stats et résumés à gauche, '
      'traits et compétences à droite', (tester) async {
    await _ouvrir(tester, const Size(1100, 2000));

    final description =
        tester.getTopLeft(find.text('Forgeron exilé des montagnes.'));
    final stats = tester.getTopLeft(find.text('Statistiques'));
    final traits = tester.getTopLeft(find.text('Traits passifs'));
    final actives = tester.getTopLeft(find.text('Compétences actives'));
    final maitrises = tester.getTopLeft(find.text('Maîtrises et restrictions'));

    expect(description.dy, lessThan(stats.dy)); // description au-dessus
    expect(stats.dx, lessThan(traits.dx)); // stats à gauche
    expect(traits.dy, closeTo(stats.dy, 1)); // colonnes côte à côte
    expect(actives.dx, closeTo(traits.dx, 1)); // même colonne de droite
    expect(actives.dy, greaterThan(traits.dy));
    // Maîtrises sous les statistiques, à gauche
    expect(maitrises.dx, closeTo(stats.dx, 1));
    expect(maitrises.dy, greaterThan(stats.dy));
  });

  testWidgets('très grand écran : trois colonnes (stats, traits, actives)',
      (tester) async {
    await _ouvrir(tester, const Size(1800, 2000));

    final stats = tester.getTopLeft(find.text('Statistiques'));
    final traits = tester.getTopLeft(find.text('Traits passifs'));
    final actives = tester.getTopLeft(find.text('Compétences actives'));
    final maitrises = tester.getTopLeft(find.text('Maîtrises et restrictions'));

    expect(traits.dx, greaterThan(stats.dx));
    expect(actives.dx, greaterThan(traits.dx));
    expect(traits.dy, closeTo(stats.dy, 1));
    expect(actives.dy, closeTo(stats.dy, 1));
    expect(maitrises.dx, closeTo(stats.dx, 1));
  });

  testWidgets('compétences classées en traits passifs ou actives',
      (tester) async {
    await _ouvrir(tester, const Size(1100, 2000));

    final traits = tester.getTopLeft(find.text('Traits passifs')).dy;
    final actives = tester.getTopLeft(find.text('Compétences actives')).dy;
    final vision = tester.getTopLeft(find.textContaining('Vision naine')).dy;
    final outils = tester.getTopLeft(find.textContaining('Outils de nain')).dy;
    final coup = tester.getTopLeft(find.textContaining('Coup puissant')).dy;

    // Passif racial et compétence passive sous « Traits passifs »
    expect(vision, inExclusiveRange(traits, actives));
    expect(outils, inExclusiveRange(traits, actives));
    // Compétence active sous « Compétences actives »
    expect(coup, greaterThan(actives));
  });

  testWidgets(
      'traits et compétences groupés par voie, montée de niveau en '
      'haut à droite', (tester) async {
    await _ouvrir(tester, const Size(1100, 2000));

    double y(String texte) => tester.getTopLeft(find.text(texte)).dy;
    // En-têtes de groupe au-dessus de leurs traits / compétences
    expect(y('Passif racial · Nain'), lessThan(y('Vision naine')));
    expect(y('Voie raciale · Voie du nain'), lessThan(y('Outils de nain')));
    expect(y('Voie raciale · Voie du nain'), greaterThan(y('Vision naine')));
    expect(y('Voie de la mêlée'), lessThan(y('Coup puissant')));
    // Un filet entre le passif racial et la voie raciale
    expect(find.byType(Divider), findsWidgets);

    // Bouton de montée de niveau dans la barre du haut, à droite
    final bouton = find.byKey(const Key('bouton-monter-niveau'));
    expect(find.descendant(of: find.byType(AppBar), matching: bouton),
        findsOneWidget);
    expect(find.text('Monter au niveau 2'), findsOneWidget);
    // Collé à droite (seul le menu ⋮ est après lui)
    expect(tester.getTopRight(bouton).dx, greaterThan(1000));
  });

  testWidgets('téléphone : une seule colonne, stats puis traits',
      (tester) async {
    await _ouvrir(tester, const Size(400, 3000));

    final stats = tester.getTopLeft(find.text('Statistiques'));
    final traits = tester.getTopLeft(find.text('Traits passifs'));
    final actives = tester.getTopLeft(find.text('Compétences actives'));
    final maitrises = tester.getTopLeft(find.text('Maîtrises et restrictions'));
    expect(traits.dy, greaterThan(stats.dy));
    expect(traits.dx, closeTo(stats.dx, 1));
    expect(actives.dy, greaterThan(traits.dy));
    expect(maitrises.dy, greaterThan(actives.dy));
  });

  testWidgets('identité mise en avant : nom, race, classe, niveau',
      (tester) async {
    await _ouvrir(tester, const Size(1400, 2000));
    expect(find.text('Fiche du personnage'), findsOneWidget);
    expect(find.byKey(const Key('nom-personnage')), findsOneWidget);
    expect(find.text('Nain'), findsOneWidget);
    expect(find.text('Guerrier'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('niveau-personnage')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('statistiques : en-tête DV / DE / CHAN, combat, personnage',
      (tester) async {
    await _ouvrir(tester, const Size(1400, 2000));
    Offset pos(String cle) => tester.getTopLeft(find.byKey(Key(cle)));

    // En-tête : dé de vie, dé d'endurance, chance sur une ligne ; trèfle à
    // quatre feuilles en filigrane de la chance
    expect(
      find.descendant(
        of: find.byKey(const Key('carac-CHAN')),
        matching: find.byKey(const Key('trefle-chan')),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('stat-dm')),
        findsNothing); // guerrier : pas de mana
    expect(pos('stat-de').dy, closeTo(pos('stat-dv').dy, 1));
    expect(pos('carac-CHAN').dy, closeTo(pos('stat-dv').dy, 1));
    // Défensif : CA (l'esquive est un jet), RD physique, RD magique sur une ligne,
    // puis RD feu, glace, foudre (refonte du 29/10/2026)
    expect(find.text('CA'), findsOneWidget);
    expect(pos('stat-rd-physique').dy, closeTo(pos('stat-ca').dy, 1));
    expect(pos('stat-rd-magique').dx, greaterThan(pos('stat-rd-physique').dx));
    expect(pos('stat-rd-feu').dy, greaterThan(pos('stat-ca').dy));
    expect(pos('stat-rd-feu').dx, closeTo(pos('stat-ca').dx, 1));
    expect(pos('stat-rd-foudre').dy, closeTo(pos('stat-rd-feu').dy, 1));
    // Offensif sous défensif : initiative à gauche, toucher puis dégâts
    expect(pos('stat-init').dy, greaterThan(pos('stat-ca').dy));
    expect(pos('stat-tou-mag').dy, closeTo(pos('stat-tou-cac').dy, 1));
    expect(pos('stat-deg-cac').dy, greaterThan(pos('stat-tou-cac').dy));
    expect(pos('stat-deg-mag').dy, closeTo(pos('stat-deg-cac').dy, 1));
    // Personnage sous combat ; aptitude à côté de sa statistique
    expect(pos('carac-ADC').dy, greaterThan(pos('stat-deg-cac').dy));
    expect(pos('carac-FOR').dy, closeTo(pos('carac-ADC').dy, 1));
    expect(pos('carac-FOR').dx, greaterThan(pos('carac-ADC').dx));
    expect(pos('carac-INT').dy, closeTo(pos('carac-ADM').dy, 1));
    expect(pos('carac-MEN').dy, closeTo(pos('carac-SOC').dy, 1));
    expect(pos('carac-CON').dy, greaterThan(pos('carac-ADM').dy));
    // CON en face de PER (pas de trou dans la grille)
    expect(pos('carac-PER').dy, closeTo(pos('carac-CON').dy, 1));
    expect(pos('carac-PER').dx, greaterThan(pos('carac-CON').dx));
  });

  testWidgets('caractéristique : modificateur en avant, valeur à part',
      (tester) async {
    await _ouvrir(tester, const Size(1400, 2000));
    final con = find.byKey(const Key('carac-CON'));
    final mod = find.descendant(
      of: con,
      matching: find.byKey(const Key('modificateur')),
    );
    final valeur =
        find.descendant(of: con, matching: find.byKey(const Key('valeur')));
    // Valeurs par défaut : CON 10 → +0
    expect(tester.widget<Text>(mod).data, '+0');
    expect(tester.widget<Text>(valeur).data, '10');
    // Bien séparés : la valeur est à droite, à distance du modificateur
    expect(
      tester.getTopLeft(valeur).dx - tester.getTopRight(mod).dx,
      greaterThan(12),
    );
  });
}
