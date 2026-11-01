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
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/savoirs.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/screens/glossaire_screen.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';

final _catalogue = [
  for (final e in jsonDecode(
    File('assets/data/aptitudes.json').readAsStringSync(),
  ) as List)
    Aptitude.depuisJson(e as Map<String, dynamic>),
];
final _classes =
    (jsonDecode(File('assets/data/classes.json').readAsStringSync()) as List)
        .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
        .toList();
final _races =
    (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
        .map((e) => Race.depuisJson(e as Map<String, dynamic>))
        .toList();

Personnage _personnage({int intel = 12}) => Personnage(
      id: 'b',
      nom: 'Bardo',
      raceId: 'humain',
      classeId: 'barde',
      niveau: 5,
      // Légendes et rumeurs : bonus à cocher (situation).
      rangsVoies: {'barde-vagabond': 3},
      caracBase: {
        for (final c in Carac.values) c: c == Carac.intel ? intel : 12,
      },
      aptitudes: [
        const AptitudeAcquise(id: 'faune'),
        const AptitudeAcquise(id: 'connaissance-nain'),
        const AptitudeAcquise(id: 'connaissance', precision: 'Géologie'),
        const AptitudeAcquise(id: 'escalade'),
      ],
    );

FicheCalculee _fiche({int intel = 12}) => FicheCalculee(
      personnage: _personnage(intel: intel),
      race: _races.firstWhere((r) => r.id == 'humain'),
      classe: _classes.firstWhere((c) => c.id == 'barde'),
    );

void main() {
  Aptitude apt(String id) => _catalogue.firstWhere((a) => a.id == id);

  test('savoirs et savoir-faire : famille, complexité, caractéristique', () {
    // Identifiants uniques.
    expect(_catalogue.map((a) => a.id).toSet(), hasLength(_catalogue.length));
    expect(apt('faune').famille, FamilleAptitude.savoir);
    expect(apt('faune').complexe, isFalse);
    expect(apt('geologie').complexe, isTrue);
    expect(apt('escalade').famille, FamilleAptitude.savoirFaire);
    expect(apt('escalade').carac, 'FOR');
    expect(apt('natation').complexe, isTrue);
    expect(apt('langue').famille, FamilleAptitude.autre);
    // Pas de SAG : Perception pour le pistage et la météorologie.
    expect(apt('pistage').carac, 'PER');
    expect(apt('meteorologie').carac, 'PER');
    expect(apt('survie').carac, 'INT');
    // Toutes les entrées des deux familles ont une caractéristique valide.
    for (final a in _catalogue) {
      if (a.famille == FamilleAptitude.autre) continue;
      expect(Carac.depuisCode(a.carac), isNotNull, reason: a.id);
    }
    expect(_catalogue.where((a) => a.famille == FamilleAptitude.savoir),
        hasLength(29));
    expect(_catalogue.where((a) => a.famille == FamilleAptitude.savoirFaire),
        hasLength(30));
    // Une connaissance par race, un savoir-faire par artisanat.
    for (final r in _races) {
      final a = apt('connaissance-${r.id}');
      expect(a.race, r.id);
      expect(a.question, isNull);
      expect(a.estInnee(raceId: r.id, intel: 8), isTrue);
    }
    expect(
        apt('connaissance-nain').estInnee(raceId: 'gnome', intel: 8), isFalse);
    for (final id in [
      'couture',
      'menuiserie',
      'joaillerie',
      'maroquinerie',
      'poterie',
      'tissage',
    ]) {
      expect(apt(id).famille, FamilleAptitude.savoirFaire, reason: id);
      expect(apt(id).description, startsWith('Artisanat'), reason: id);
    }
    expect(_catalogue.where((a) => a.id == 'artisanat'), isEmpty);
    expect(_catalogue.where((a) => a.id == 'connaissance-race'), isEmpty);
  });

  test('anciennes sauvegardes : « Une race » et « Artisanat » convertis', () {
    AptitudeAcquise lire(String id, String precision) =>
        AptitudeAcquise.depuisJson({'id': id, 'precision': precision});
    expect(lire('connaissance-race', 'Nain'),
        const AptitudeAcquise(id: 'connaissance-nain'));
    expect(lire('connaissance-race', 'Haut-elfe'),
        const AptitudeAcquise(id: 'connaissance-haut-elfe'));
    expect(lire('artisanat', 'Travail du cuir'),
        const AptitudeAcquise(id: 'maroquinerie'));
    expect(lire('artisanat', 'couture'), const AptitudeAcquise(id: 'couture'));
    // Le reste ne change pas.
    expect(lire('langue', 'Elfique'),
        const AptitudeAcquise(id: 'langue', precision: 'Elfique'));
  });

  test('résumé et règle affichés', () {
    expect(apt('geologie').resume, 'Savoir complexe · INT');
    expect(apt('geologie').regle, contains('−5 sans la maîtrise'));
    expect(apt('escalade').resume, 'Savoir-faire basique · FOR');
    expect(apt('langue').resume, '');
  });

  test('jets de savoirs : maîtrise +5, complexe non maîtrisé −5', () {
    final jets = jetsSavoirs(_fiche(), _catalogue, FamilleAptitude.savoir);
    JetSavoir jet(String libelle) =>
        jets.firstWhere((j) => j.libelle == libelle);
    // Maîtrisés d'abord.
    expect(jets.first.maitrise, isTrue);
    expect(jet('Faune').modificateur, 5);
    expect(jet('Faune').mention, 'maîtrisé · +5');
    expect(jet('Faune').bonusFixes.single, (nom: 'Maîtrise', valeur: 5));
    expect(jet('Flore').modificateur, 0);
    expect(jet('Flore').bonusFixes, isEmpty);
    expect(jet('Géologie').modificateur, -5);
    expect(jet('Géologie').mention, 'non maîtrisé · −5');
    // Peuples : acheté (nain) ou sa propre race (humain) → maîtrisé.
    expect(jet('Peuple nain').maitrise, isTrue);
    expect(jet('Peuple humain').maitrise, isTrue);
    expect(jet('Peuple gnome').maitrise, isFalse);
    expect(jet('Peuple gnome').modificateur, 0);
    // Connaissance d'un domaine achetée : jet d'INT maîtrisé.
    expect(jet('Domaine : Géologie').carac, Carac.intel);
    expect(jet('Domaine : Géologie').maitrise, isTrue);
    expect(jet('Météorologie').carac, Carac.per);

    final faire =
        jetsSavoirs(_fiche(), _catalogue, FamilleAptitude.savoirFaire);
    expect(faire.first.libelle, 'Escalade');
    expect(faire.first.maitrise, isTrue);
    expect(faire.any((j) => j.aptitude.famille != FamilleAptitude.savoirFaire),
        isFalse);
    // Lire et écrire : inné avec INT ≥ 10, à −5 sinon.
    expect(faire.firstWhere((j) => j.libelle == 'Lire et écrire').maitrise,
        isTrue);
    final illettre =
        jetsSavoirs(_fiche(intel: 8), _catalogue, FamilleAptitude.savoirFaire);
    expect(
      illettre.firstWhere((j) => j.libelle == 'Lire et écrire').modificateur,
      -5,
    );
  });

  Future<void> ouvrir(
    WidgetTester tester,
    Size taille, {
    PreferencesController? preferences,
  }) async {
    tester.view.physicalSize = taille;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([_personnage()]));
    await controller.charger();
    await tester.pumpWidget(
      MaterialApp(
        home: DeScreen(
          referentiel: Referentiel(
            races: _races,
            classes: _classes,
            aptitudes: _catalogue,
          ),
          personnages: controller,
          preferences: preferences ??
              PreferencesController(
                personnageActifId: 'b',
                // Groupes de la page dé ouverts (cachés par défaut).
                affichages: {
                  for (final g in GroupeJets.values) g: AffichageGroupe.visible,
                },
              ),
          aleatoire: Random(4),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('page dé : catégories Combat, Connaissances, Aptitudes',
      (tester) async {
    await ouvrir(tester, const Size(1200, 4000));
    for (final c in ['combat', 'connaissances', 'aptitudes']) {
      expect(find.byKey(Key('categorie-jets-$c')), findsOneWidget);
    }
    // Ordre : Combat, puis Connaissances, puis Aptitudes.
    double y(String c) =>
        tester.getTopLeft(find.byKey(Key('categorie-jets-$c'))).dy;
    expect(y('combat'), lessThan(y('connaissances')));
    expect(y('connaissances'), lessThan(y('aptitudes')));
    // L'initiative (valeur) est en haut, les savoirs dans Connaissances.
    expect(tester.getTopLeft(find.byKey(const Key('initiative-actuelle'))).dy,
        lessThan(y('connaissances')));
    final faune = find.byKey(const Key('jet-savoir-faune'));
    expect(tester.getTopLeft(faune).dy, greaterThan(y('connaissances')));
    expect(find.byKey(const Key('jet-savoir-escalade')), findsOneWidget);
    // Lancer un savoir maîtrisé : +5 de maîtrise dans le détail.
    await tester.tap(faune);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('detail-de'))).data,
      contains('+5 (Maîtrise)'),
    );
    // Écran moyen : les situations restent dans le panneau.
    expect(find.byKey(const Key('bloc-situations')), findsOneWidget);

    // Groupes repliables : toucher le titre réduit puis rouvre.
    await tester.tap(find.byKey(const Key('replier-connaissances')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('jet-savoir-faune')), findsNothing);
    expect(find.byKey(const Key('jet-savoir-escalade')), findsOneWidget);
    await tester.tap(find.byKey(const Key('replier-aptitudes')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('jet-savoir-escalade')), findsNothing);
    // Le combat reste visible.
    expect(find.byKey(const Key('initiative-actuelle')), findsOneWidget);
    await tester.tap(find.byKey(const Key('replier-connaissances')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('jet-savoir-faune')), findsOneWidget);
  });

  testWidgets('préférences : dé par défaut, groupes cachés ou mémorisés',
      (tester) async {
    final prefs = PreferencesController(
      personnageActifId: 'b',
      deDefaut: 6,
      affichages: {
        GroupeJets.connaissances: AffichageGroupe.cache,
        GroupeJets.aptitudes: AffichageGroupe.memoriser,
      },
      derniersOuverts: {GroupeJets.aptitudes: false},
    );
    await ouvrir(tester, const Size(1200, 4000), preferences: prefs);
    // Dé par défaut : d6.
    expect(find.text('d6 libre'), findsOneWidget);
    // Connaissances cachées, aptitudes repliées la dernière fois.
    expect(find.byKey(const Key('jet-savoir-faune')), findsNothing);
    expect(find.byKey(const Key('jet-savoir-escalade')), findsNothing);
    // On rouvre les aptitudes : retenu pour la prochaine visite.
    await tester.tap(find.byKey(const Key('replier-aptitudes')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('jet-savoir-escalade')), findsOneWidget);
    expect(prefs.groupeOuvert(GroupeJets.aptitudes), isTrue);
    // « Caché » : toujours replié à l'arrivée, même après l'avoir ouvert.
    await tester.tap(find.byKey(const Key('replier-connaissances')));
    await tester.pumpAndSettle();
    expect(prefs.groupeOuvert(GroupeJets.connaissances), isFalse);
  });

  testWidgets('situations : texte long sur plusieurs lignes', (tester) async {
    await ouvrir(tester, const Size(700, 4000));
    final pastilles = find.descendant(
      of: find.byKey(const Key('bloc-situations')),
      matching: find.byType(RichText),
    );
    expect(pastilles, findsWidgets);
    // Aucun texte de situation n'est coupé par des points de suspension.
    for (final e in pastilles.evaluate()) {
      final t = e.widget as RichText;
      expect(t.overflow, isNot(TextOverflow.ellipsis));
      expect(t.maxLines, isNull);
    }
  });

  testWidgets('Glossaire : onglet Connaissances & Aptitudes', (tester) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ref = Referentiel(
      races: _races,
      classes: _classes,
      aptitudes: _catalogue,
    );
    await tester.pumpWidget(MaterialApp(
      home: GlossaireScreen(
        referentiel: ref,
        onglet: OngletGlossaire.aptitudes,
      ),
    ));
    await tester.pumpAndSettle();
    // Pastille : nombre d'entrées (sans les sorts de rang 0).
    expect(OngletGlossaire.aptitudes.nombre(ref),
        _catalogue.where((a) => !a.estSort).length);
    expect(find.byKey(const Key('groupe-aptitudes-savoir')), findsOneWidget);
    expect(find.byKey(const Key('carte-aptitude-faune')), findsOneWidget);
    // Filtre Savoir-faire : plus de savoirs.
    await tester.tap(find.byKey(const Key('famille-savoirFaire')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('groupe-aptitudes-savoir')), findsNothing);
    expect(find.byKey(const Key('carte-aptitude-escalade')), findsOneWidget);
    // Complexes seulement : l'escalade (basique) disparaît.
    await tester.tap(find.byKey(const Key('filtre-complexe')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('carte-aptitude-escalade')), findsNothing);
    expect(find.byKey(const Key('carte-aptitude-forge')), findsOneWidget);
    // Recherche sans accents.
    await tester.tap(find.byKey(const Key('famille-toutes')));
    await tester.tap(find.byKey(const Key('filtre-complexe')));
    await tester.enterText(find.byKey(const Key('champ-recherche')), 'meteo');
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('carte-aptitude-meteorologie')), findsOneWidget);
    expect(find.byKey(const Key('carte-aptitude-faune')), findsNothing);
    expect(find.text('Test : PER'), findsOneWidget);

    // Filtre par caractéristique du test : FOR → escalade, forge…
    await tester.enterText(find.byKey(const Key('champ-recherche')), '');
    await tester.tap(find.byKey(const Key('filtre-carac-FOR')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('carte-aptitude-escalade')), findsOneWidget);
    expect(find.byKey(const Key('carte-aptitude-forge')), findsOneWidget);
    expect(find.byKey(const Key('carte-aptitude-faune')), findsNothing);
    expect(find.byKey(const Key('carte-aptitude-meteorologie')), findsNothing);
    // Pas de pastille pour une caractéristique jamais utilisée (AdC).
    expect(find.byKey(const Key('filtre-carac-ADC')), findsNothing);
  });

  testWidgets('très grand écran : situations dans une colonne à gauche',
      (tester) async {
    await ouvrir(tester, const Size(1800, 4000));
    final bloc = find.byKey(const Key('bloc-situations'));
    expect(bloc, findsOneWidget);
    expect(
      tester.getTopLeft(bloc).dx,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('panneau-personnage-actif'))).dx,
      ),
    );
  });
}
