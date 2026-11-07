import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/aptitude.dart';
import 'package:odyssee_vagabonds/models/affliction.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/equipement.dart';
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/screens/creation/etape_caracteristiques.dart';
import 'package:odyssee_vagabonds/screens/afflictions_glossaire_screen.dart';
import 'package:odyssee_vagabonds/screens/creation/etape_competences.dart';
import 'package:odyssee_vagabonds/screens/fiche/formulaire_objet.dart';
import 'package:odyssee_vagabonds/theme.dart';
import 'package:odyssee_vagabonds/widgets/carte_choix.dart';
import 'package:odyssee_vagabonds/widgets/resume_fiche.dart';

/// Aides de la création et de la fiche (07/11/2026) : une phrase par
/// caractéristique, panneau « Déjà acquis », statistiques des armes
/// proposées, fenêtres de survol.

List<dynamic> _json(String f) =>
    jsonDecode(File('assets/data/$f').readAsStringSync()) as List;

void main() {
  final races = [
    for (final e in _json('races.json'))
      Race.depuisJson(e as Map<String, dynamic>),
  ];
  final classes = [
    for (final e in _json('classes.json'))
      Classe.depuisJson(e as Map<String, dynamic>),
  ];
  final aptitudes = [
    for (final e in _json('aptitudes.json'))
      Aptitude.depuisJson(e as Map<String, dynamic>),
  ];
  final equipements = [
    for (final e in _json('equipements.json'))
      Equipement.depuisJson(e as Map<String, dynamic>),
  ];
  final nain = races.firstWhere((r) => r.id == 'nain');
  final guerrier = classes.firstWhere((c) => c.id == 'guerrier');

  Future<void> taille(WidgetTester tester, Size s) async {
    tester.view.physicalSize = s;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  test('chaque caractéristique a sa phrase d\'explication', () {
    for (final c in Carac.values) {
      expect(c.description, endsWith('.'), reason: c.code);
    }
  });

  testWidgets('répartition : une phrase par caractéristique', (tester) async {
    await taille(tester, const Size(900, 3000));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EtapeCaracteristiques(
          base: const {},
          race: nain,
          origine: null,
          onChange: (_) {},
        ),
      ),
    ));
    for (final c in Carac.values) {
      expect(find.byKey(Key('explication-${c.code}')), findsOneWidget);
      expect(find.text(c.description), findsOneWidget);
    }
  });

  Widget competences({required Map<String, int> rangs}) => MaterialApp(
        home: Scaffold(
          body: EtapeCompetences(
            race: nain,
            classe: guerrier,
            niveau: 1,
            rangsVoies: rangs,
            aptitudes: const [AptitudeAcquise(id: 'pistage')],
            catalogueAptitudes: aptitudes,
            intFinale: 10,
            onChange: (_) {},
            onAptitudes: (_) {},
          ),
        ),
      );

  testWidgets('grand écran : tout ce qui est acquis dans le panneau de gauche',
      (tester) async {
    await taille(tester, const Size(1200, 900));
    final voie = guerrier.voies.first;
    await tester.pumpWidget(competences(rangs: {voie.id: 1}));
    await tester.pumpAndSettle();

    final panneau = find.byKey(const Key('panneau-acquis'));
    expect(panneau, findsOneWidget);
    expect(tester.getTopLeft(panneau).dx, lessThan(50));
    Finder dedans(String t) =>
        find.descendant(of: panneau, matching: find.text(t));
    // Voie raciale offerte, rang de classe, aptitude prise.
    expect(dedans('• Rang 1 · Outils de nain'), findsOneWidget);
    expect(dedans('• Rang 1 · ${voie.competences.first.nom}'), findsOneWidget);
    final pistage = aptitudes.firstWhere((a) => a.id == 'pistage');
    expect(dedans('• ${pistage.nom}'), findsOneWidget);

    // Voies raciale et de classe : deux familles bien séparées.
    expect(find.text('Voie de ta race · ${nain.nom}'), findsOneWidget);
    expect(find.text('Voies de ta classe · ${guerrier.nom}'), findsOneWidget);
  });

  testWidgets('très grand écran : aptitudes à droite des voies',
      (tester) async {
    await taille(tester, const Size(1400, 900));
    await tester.pumpWidget(competences(rangs: const {}));
    await tester.pumpAndSettle();
    final voies = tester.getTopLeft(
      find.text('Voie de ta race · ${nain.nom}'),
    );
    final droite = tester.getTopLeft(find.text('Aptitudes et connaissances'));
    expect(droite.dx, greaterThan(voies.dx + 200));
    expect((droite.dy - voies.dy).abs(), lessThan(200));
  });

  testWidgets('choix : {precision} remplacé par la sélection', (tester) async {
    await taille(tester, const Size(800, 800));
    final choix = ChoixCompetence(
      cle: 'arme',
      options: [
        OptionChoix(
          id: 'arme',
          nom: 'Arme',
          effet: 'Maîtrise de {precision}.',
          question: 'Laquelle ?',
        ),
      ],
    );
    Widget carte(String precision) => MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CarteChoix(
                nom: 'Maîtrise',
                choix: choix,
                valeur: 'arme',
                precision: precision,
                onChoisir: (_) {},
                onPrecision: (_) {},
              ),
            ),
          ),
        );
    await tester.pumpWidget(carte('Pioche'));
    expect(find.text('Maîtrise de Pioche.'), findsOneWidget);
    await tester.pumpWidget(carte(''));
    expect(find.text('Maîtrise de la sélection.'), findsOneWidget);
    expect(find.textContaining('{precision}'), findsNothing);
  });

  testWidgets('glossaire : afflictions et types de dégâts', (tester) async {
    await taille(tester, const Size(900, 1200));
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AfflictionsGlossaireScreen()),
    ));
    for (final a in [...kAfflictions, ...kEffetsDegats]) {
      expect(
        find.textContaining(a.effet, findRichText: true),
        findsWidgets,
        reason: a.nom,
      );
    }
  });

  testWidgets('arme personnalisée : élément et affliction', (tester) async {
    await taille(tester, const Size(900, 1600));
    final arme = Objet(
      nom: 'Lame',
      categorie: CategorieObjet.arme,
      degats: '1d6',
      personnalise: true,
    );
    Objet? resultat;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async =>
              resultat = await FormulaireObjet.ouvrir(context, objet: arme),
          child: const Text('ouvrir'),
        ),
      ),
    ));
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    if (find.byKey(const Key('editer-objet')).evaluate().isNotEmpty) {
      await tester.tap(find.byKey(const Key('editer-objet')));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const Key('element-feu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('affliction-Ralenti')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('enregistrer-objet')));
    await tester.pumpAndSettle();
    expect(resultat?.element, 'feu');
    expect(resultat?.affliction, 'Ralenti');
    expect(resultat?.resume, contains('1d6 feu'));
    final lu = Objet.depuisJson(resultat!.versJson());
    expect(lu.element, 'feu');
    expect(lu.affliction, 'Ralenti');
  });

  testWidgets('téléphone : le résumé est un cadre repliable', (tester) async {
    await taille(tester, const Size(400, 800));
    await tester.pumpWidget(competences(rangs: const {}));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('panneau-acquis')), findsNothing);
    expect(find.text('• Rang 1 · Outils de nain'), findsNothing);
    await tester.tap(find.textContaining('Déjà acquis'));
    await tester.pumpAndSettle();
    expect(find.text('• Rang 1 · Outils de nain'), findsOneWidget);
  });

  testWidgets('Outils de nain : statistiques des armes offertes',
      (tester) async {
    await taille(tester, const Size(800, 800));
    final choix = nain.voieRaciale!.competences.first.choix!;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CarteChoix(
            nom: 'Outils de nain',
            choix: choix,
            valeur: null,
            onChoisir: (_) {},
            catalogue: equipements,
          ),
        ),
      ),
    ));
    for (final nom in ['Hache de guerre', 'Marteau de guerre']) {
      final e = equipements.firstWhere((x) => x.nom == nom);
      expect(e.resumeStats, contains('Dégâts'));
      expect(e.resumeStats, isNot(contains('Prix')));
      expect(find.byKey(Key('stats-choix-${e.id}')), findsOneWidget);
    }
  });

  testWidgets('arme choisie dans une liste : ses statistiques en dessous',
      (tester) async {
    await taille(tester, const Size(800, 800));
    final pioche = equipements.firstWhere((x) => x.id == 'pioche');
    final choix = ChoixCompetence(
      cle: 'arme',
      options: [
        OptionChoix(
            id: 'arme', nom: 'Arme', liste: 'armes', question: 'Laquelle ?'),
      ],
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CarteChoix(
            nom: 'Maîtrise',
            choix: choix,
            valeur: 'arme',
            precision: pioche.nom,
            onChoisir: (_) {},
            onPrecision: (_) {},
            catalogue: equipements,
            elements: (_) => [(nom: pioche.nom, maitrise: false)],
          ),
        ),
      ),
    ));
    expect(find.byKey(Key('stats-choix-${pioche.id}')), findsOneWidget);
    expect(
      find.textContaining('Dégâts : 1d6 phy', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('fiche : fenêtre de survol aux couleurs de la charte',
      (tester) async {
    await taille(tester, const Size(1000, 2000));
    final fiche = FicheCalculee(
      personnage: Personnage(
        id: 'b',
        nom: 'Brom',
        raceId: 'nain',
        classeId: 'guerrier',
      ),
      race: nain,
      classe: guerrier,
    );
    await tester.pumpWidget(MaterialApp(
      theme: themeOdv(Brightness.dark),
      home: Scaffold(
        body: SingleChildScrollView(child: ResumeFiche(fiche: fiche)),
      ),
    ));

    String message(String cle) => tester
        .widget<Tooltip>(find.descendant(
          of: find.byKey(Key(cle)),
          matching: find.byType(Tooltip),
        ))
        .richMessage!
        .toPlainText();
    expect(message('carac-FOR'), contains(Carac.force.nom));
    expect(message('carac-FOR'), contains(Carac.force.description));
    expect(message('stat-init'), contains('Vitesse de réaction'));
    expect(message('stat-dv'), contains('montée de niveau'));

    final theme = themeOdv(Brightness.dark).tooltipTheme;
    final cadre = theme.decoration! as BoxDecoration;
    expect(cadre.color, OdvCouleurs.carte);
    expect(cadre.border, Border.all(color: OdvCouleurs.or));
    expect(theme.textStyle?.color, OdvCouleurs.texteParchemin);
  });
}
