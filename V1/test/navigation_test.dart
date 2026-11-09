import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/app.dart';
import 'package:odyssee_vagabonds/data/changelog.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/creature.dart';
import 'package:odyssee_vagabonds/models/equipement.dart';
import 'package:odyssee_vagabonds/models/historique.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/des.dart';
import 'package:odyssee_vagabonds/screens/de_screen.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/preferences_controller.dart';
import 'package:odyssee_vagabonds/version.dart';
import 'package:odyssee_vagabonds/widgets/consultation.dart';
import 'package:odyssee_vagabonds/widgets/markdown_simple.dart';
import 'package:odyssee_vagabonds/widgets/menu_lateral.dart';

const _referentiel = Referentiel(
  races: [
    Race(
      id: 'nain',
      nom: 'Nain',
      deVie: 8,
      deMana: 4,
      passif: Passif(nom: 'Vision naine', description: 'Voit dans le noir.'),
      maitrises: 'Armes civiles, arbalètes.',
      voieRaciale: Voie(
        id: 'race-nain',
        nom: 'Voie du nain',
        competences: [
          Competence(rang: 1, nom: 'Outils de nain', type: 'passif'),
        ],
      ),
    ),
    Race(
      id: 'gnome',
      nom: 'Gnome',
      deVie: 6,
      deMana: 6,
      passif: Passif(
        nom: 'D\'une nature chanceuse',
        description: 'Avantage aux jets de CHAN.',
      ),
    ),
  ],
  classes: [
    Classe(
      id: 'pretre',
      nom: 'Prêtre',
      modifDeVie: ModifDe.egal,
      modifDeMana: ModifDe.plus,
      lanceurDeSorts: true,
      profil: ProfilClasse.lanceur,
      description: 'Origine : divinité et croyance.',
      voies: [
        Voie(
          id: 'p-foi',
          nom: 'Voie de la foi',
          competences: [Competence(rang: 1, nom: 'Prière', type: 'sort')],
        ),
      ],
    ),
  ],
  equipements: [
    Equipement(
      id: 'potion-sante',
      nom: 'Potion de santé',
      categorie: CategorieEquipement.autre,
      sousCategorie: 'Potion',
      description: 'Rend 1D8 PV.',
    ),
    Equipement(
      id: 'parchemin',
      nom: 'Parchemin de magie',
      categorie: CategorieEquipement.objetMagique,
    ),
  ],
  creatures: [
    Creature(
      id: 'loup',
      nom: 'Loup',
      famille: 'Bêtes',
      archetype: 'Meute',
      taille: TailleCreature.standard,
      comportement: 'Chasse en meute.',
    ),
    Creature(
      id: 'zombie',
      nom: 'Zombie',
      famille: 'Morts-vivants',
      archetype: 'Standard',
      taille: TailleCreature.standard,
    ),
    Creature(
      id: 'dragon',
      nom: 'Dragon',
      famille: 'Dragons',
      archetype: 'Puissant',
      taille: TailleCreature.gigantesque,
      voies: [Voie(id: 'v-dragons', nom: 'Voie des dragons')],
    ),
  ],
  reglesSysteme: '# Règles\n\n> Intro.\n\n'
      '## Dés\n\n- Un **20** naturel est une réussite critique.\n\n'
      '## Afflictions\n\n| Affliction | Effet |\n|---|---|\n'
      '| Étourdi | Aucune action |\n',
);

class _StockageFactice implements PreferencesStockage {
  ThemeMode? enregistre;

  @override
  Future<ThemeMode> lireTheme() async => ThemeMode.dark;

  @override
  Future<void> enregistrerTheme(ThemeMode theme) async => enregistre = theme;

  bool? menuEnregistre;

  @override
  Future<bool> lireMenuEpingle() async => false;

  @override
  Future<void> enregistrerMenuEpingle(bool epingle) async =>
      menuEnregistre = epingle;

  String? actifEnregistre;

  @override
  Future<String?> lirePersonnageActif() async => null;

  @override
  Future<void> enregistrerPersonnageActif(String? id) async =>
      actifEnregistre = id;

  @override
  Future<bool> lireAnimations() async => true;

  bool? animationsEnregistrees;

  @override
  Future<void> enregistrerAnimations(bool actives) async =>
      animationsEnregistrees = actives;

  final reglages = <String, String>{};

  @override
  Future<String?> lireReglage(String cle) async => reglages[cle];

  @override
  Future<void> enregistrerReglage(String cle, String? valeur) async {
    if (valeur == null) {
      reglages.remove(cle);
    } else {
      reglages[cle] = valeur;
    }
  }
}

Future<PreferencesController> _ouvrir(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final controller = PersonnagesController(
    EnMemoirePersonnageRepository([
      Personnage(id: 'b', nom: 'Brom', raceId: 'nain', classeId: 'pretre'),
    ]),
  );
  await controller.charger();
  final preferences = PreferencesController(stockage: _StockageFactice());
  await tester.pumpWidget(
    OdvApp(
      referentiel: _referentiel,
      controller: controller,
      preferences: preferences,
    ),
  );
  await tester.pumpAndSettle();
  return preferences;
}

Future<void> _aller(WidgetTester tester, String entree) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await tester.tap(find.text(entree).last);
  await tester.pumpAndSettle();
}

/// Ouvre le Glossaire puis l'onglet [onglet] (classes, races, equipements,
/// bestiaire).
Future<void> _glossaire(WidgetTester tester, String onglet) async {
  await _aller(tester, 'Glossaire');
  await _ongletGlossaire(tester, onglet);
}

/// Touche l'onglet [onglet] du Glossaire (la barre défile : on l'amène
/// d'abord à l'écran).
Future<void> _ongletGlossaire(WidgetTester tester, String onglet) async {
  final o = find.byKey(Key('onglet-glossaire-$onglet'));
  await tester.ensureVisible(o);
  await tester.pumpAndSettle();
  await tester.tap(o);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('menu latéral : bandeau, 6 écrans, Personnages par défaut',
      (tester) async {
    await _ouvrir(tester);
    expect(find.text('Personnages'), findsOneWidget); // titre de la page
    expect(find.text('Brom'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('menu-nb-personnages'))).data,
      '1 personnage',
    );
    for (final entree in [
      'Lancer de dé',
      'Glossaire',
      'Règles système',
      'Préférences',
      'À propos',
    ]) {
      expect(find.text(entree), findsOneWidget, reason: entree);
    }
  });

  testWidgets('menu latéral gardé ouvert sur grand écran', (tester) async {
    final preferences = await _ouvrir(tester);
    final stockage = preferences.stockage! as _StockageFactice;

    // Option dans les Préférences ; pas de bouton dans le menu lui-même
    await _aller(tester, 'Préférences');
    await tester.tap(find.byKey(const Key('pref-menu-epingle')));
    await tester.pumpAndSettle();

    // Menu fixe à gauche : plus de bouton ☰, les entrées restent visibles
    expect(preferences.menuEpingle, isTrue);
    expect(stockage.menuEnregistre, isTrue);
    // Menu fixe : fond plein, angles droits (pas de blanc dans les coins).
    expect(find.byKey(const Key('fond-menu-fixe')), findsOneWidget);
    final tiroir = tester.widget<Drawer>(find.byType(Drawer));
    final forme = Theme.of(tester.element(find.byType(Drawer)))
        .drawerTheme
        .shape as RoundedRectangleBorder;
    expect(tiroir.shape ?? forme, const RoundedRectangleBorder());
    expect(find.byIcon(Icons.menu), findsNothing);
    expect(find.byKey(const Key('menu-nb-personnages')), findsOneWidget);
    await tester.tap(find.text('Lancer de dé').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('menu-nb-personnages')), findsOneWidget);
    expect(find.byKey(const Key('bouton-lancer-de')), findsOneWidget);

    // Option désactivée : retour au menu dépliable
    await tester.tap(find.text('Préférences').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pref-menu-epingle')));
    await tester.pumpAndSettle();
    expect(preferences.menuEpingle, isFalse);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets('Préférences : effets animés des cadres (actifs par défaut)',
      (tester) async {
    final preferences = await _ouvrir(tester);
    final stockage = preferences.stockage! as _StockageFactice;
    expect(preferences.animations, isTrue);
    await _aller(tester, 'Préférences');
    final interrupteur = find.byKey(const Key('pref-animations'));
    await tester.ensureVisible(interrupteur);
    await tester.pumpAndSettle();
    await tester.tap(interrupteur);
    await tester.pumpAndSettle();
    expect(preferences.animations, isFalse);
    expect(stockage.animationsEnregistrees, isFalse);
  });

  testWidgets('écran étroit : pas de menu fixe, même épinglé', (tester) async {
    final preferences = await _ouvrir(tester);
    await preferences.changerMenuEpingle(true);
    tester.view.physicalSize = const Size(600, 1200);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  test('nombre de personnages dans le bandeau', () {
    expect(texteNombrePersonnages(0), 'Aucun personnage');
    expect(texteNombrePersonnages(3), '3 personnages');
  });

  testWidgets('Glossaire : 4 onglets, titre, glisser, onglet retenu',
      (tester) async {
    await _ouvrir(tester);
    await _aller(tester, 'Glossaire');
    for (final o in ['classes', 'races', 'equipements', 'bestiaire']) {
      expect(find.byKey(Key('onglet-glossaire-$o')), findsOneWidget);
    }
    String titre() => tester
        .widget<Text>(find.byKey(const Key('titre-glossaire')))
        .textSpan!
        .toPlainText();
    expect(titre(), 'Glossaire · Classes');
    expect(find.text('Prêtre'), findsOneWidget);
    // Nombre d'entrées sur l'onglet
    expect(
      find.descendant(
        of: find.byKey(const Key('onglet-glossaire-races')),
        matching: find.text('${_referentiel.races.length}'),
      ),
      findsOneWidget,
    );
    // Glisser vers la gauche : onglet suivant
    await tester.fling(find.text('Prêtre'), const Offset(-600, 0), 1500);
    await tester.pumpAndSettle();
    expect(titre(), 'Glossaire · Races');
    expect(find.text('Nain'), findsOneWidget);
    // Onglet retenu en revenant au Glossaire
    await _ongletGlossaire(tester, 'bestiaire');
    await _aller(tester, 'Personnages');
    await _aller(tester, 'Glossaire');
    expect(titre(), 'Glossaire · Bestiaire');
    expect(find.text('Loup'), findsOneWidget);
  });

  testWidgets('page Classes : liste puis détail avec les voies',
      (tester) async {
    await _ouvrir(tester);
    await _glossaire(tester, 'classes');
    expect(find.text('Prêtre'), findsOneWidget);
    // Profil, vie et mana affichés avec icônes dans la liste
    expect(find.byKey(const Key('profil-lanceur')), findsOneWidget);
    // Curseurs à 3 crans : vie inchangée, mana augmenté
    expect(find.byKey(const Key('curseur-vie-egal')), findsOneWidget);
    expect(find.byKey(const Key('curseur-mana-plus')), findsOneWidget);
    await tester.tap(find.text('Prêtre'));
    await tester.pumpAndSettle();
    expect(find.text('Origine : divinité et croyance.'), findsOneWidget);
    expect(find.text('Voie de la foi'), findsOneWidget);
    expect(find.textContaining('Prière'), findsOneWidget);
  });

  testWidgets('page Races : détail avec passif et voie raciale',
      (tester) async {
    await _ouvrir(tester);
    await _glossaire(tester, 'races');
    // Orientation et dés en couleur dans la liste (Nain sans profil : hybride ;
    // DV d8 → cran haut, DM d4 → cran bas)
    expect(find.byKey(const Key('profil-hybride')), findsWidgets);
    expect(find.byKey(const Key('curseur-vie-plus')), findsOneWidget);
    expect(find.byKey(const Key('curseur-mana-moins')), findsOneWidget);
    await tester.tap(find.text('Nain'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Voit dans le noir.'), findsOneWidget);
    expect(find.text('Voie du nain'), findsOneWidget);
    expect(find.textContaining('Offert au niveau 1'), findsOneWidget);
  });

  testWidgets('Races, grand écran : liste à gauche, détail à droite',
      (tester) async {
    await _ouvrir(tester);
    await _glossaire(tester, 'races');
    expect(find.byKey(const Key('titre-detail')), findsNothing);

    await tester.tap(find.text('Nain'));
    await tester.pumpAndSettle();
    final titre = find.byKey(const Key('titre-detail'));
    expect(tester.widget<Text>(titre).data, 'Nain');
    // La liste est à gauche du détail, et reste visible
    expect(
      tester.getTopLeft(find.text('Gnome')).dx,
      lessThan(tester.getTopLeft(titre).dx),
    );
    expect(find.byType(BackButton), findsNothing);

    // Changer de sélection sans revenir en arrière
    await tester.tap(find.text('Gnome'));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(titre).data, 'Gnome');
    expect(find.textContaining('Avantage aux jets de CHAN.'), findsOneWidget);
    expect(find.textContaining('Voit dans le noir.'), findsNothing);

    // La croix referme le détail
    await tester.tap(find.byKey(const Key('fermer-detail')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('titre-detail')), findsNothing);
  });

  testWidgets('Races, téléphone : le détail s\'ouvre dans une page',
      (tester) async {
    await _ouvrir(tester);
    tester.view.physicalSize = const Size(400, 900);
    await tester.pumpAndSettle();
    await _glossaire(tester, 'races');
    await tester.tap(find.text('Nain'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('titre-detail')), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.textContaining('Voit dans le noir.'), findsOneWidget);
  });

  testWidgets('page Équipements : filtre par catégorie et recherche',
      (tester) async {
    await _ouvrir(tester);
    await _glossaire(tester, 'equipements');
    expect(find.text('Potion de santé'), findsOneWidget);
    expect(find.text('Parchemin de magie'), findsOneWidget);

    await tester.tap(find.byKey(const Key('categorie-objet-magique')));
    await tester.pumpAndSettle();
    expect(find.text('Potion de santé'), findsNothing);
    expect(find.text('Parchemin de magie'), findsOneWidget);

    await tester.tap(find.byKey(const Key('categorie-arme')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aucun équipement'), findsOneWidget);

    await tester.tap(find.byKey(const Key('categorie-toutes')));
    await tester.enterText(find.byKey(const Key('champ-recherche')), 'sante');
    await tester.pumpAndSettle();
    expect(find.text('Potion de santé'), findsOneWidget);
    expect(find.text('Parchemin de magie'), findsNothing);
  });

  testWidgets('page Bestiaire : filtre par famille et fiche de créature',
      (tester) async {
    await _ouvrir(tester);
    await _glossaire(tester, 'bestiaire');
    expect(find.text('Loup'), findsOneWidget);
    expect(find.text('Zombie'), findsOneWidget);
    // Échelle de taille dans la liste (loup et zombie : standard)
    expect(find.byKey(const Key('echelle-taille-standard')), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('famille-Morts-vivants')));
    await tester.pumpAndSettle();
    expect(find.text('Loup'), findsNothing);
    expect(find.text('Zombie'), findsOneWidget);

    await tester.tap(find.byKey(const Key('famille-toutes')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dragon'));
    await tester.pumpAndSettle();
    // Détail à droite de la liste (grand écran) : taille avec sa mesure
    expect(find.byKey(const Key('titre-detail')), findsOneWidget);
    expect(find.textContaining('10 m à 25 m'), findsOneWidget);
    expect(find.text('Voie des dragons'), findsOneWidget);
    expect(find.text('Statistiques à définir.'), findsOneWidget);
  });

  testWidgets('page Règles : sections et recherche', (tester) async {
    await _ouvrir(tester);
    await _aller(tester, 'Règles système');
    expect(find.text('Dés'), findsOneWidget);
    expect(find.text('Afflictions'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('champ-recherche')), 'etourdi');
    await tester.pumpAndSettle();
    expect(find.text('Dés'), findsNothing);
    expect(find.text('Afflictions'), findsOneWidget);
    // La section trouvée est ouverte : le tableau est visible.
    expect(find.text('Aucune action'), findsOneWidget);
  });

  testWidgets('page Préférences : sombre par défaut, thème clair sauvegardé',
      (tester) async {
    final preferences = await _ouvrir(tester);
    expect(preferences.theme, ThemeMode.dark);
    await _aller(tester, 'Préférences');
    await tester.tap(find.byKey(const Key('theme-light')));
    await tester.pumpAndSettle();
    expect(preferences.theme, ThemeMode.light);
    expect(
      (preferences.stockage! as _StockageFactice).enregistre,
      ThemeMode.light,
    );
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });

  testWidgets('page Préférences : réglages du lancer de dé sauvegardés',
      (tester) async {
    final preferences = await _ouvrir(tester);
    await _aller(tester, 'Préférences');
    final stockage = preferences.stockage! as _StockageFactice;
    Future<void> toucher(String cle) async {
      final f = find.byKey(Key(cle));
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    // Par défaut : d20, groupes cachés (31/10/2026).
    expect(preferences.deDefaut, 20);
    expect(preferences.groupeOuvert(GroupeJets.connaissances), isFalse);
    expect(preferences.groupeOuvert(GroupeJets.aptitudes), isFalse);
    await toucher('pref-connaissances-visible');
    expect(preferences.groupeOuvert(GroupeJets.connaissances), isTrue);
    await toucher('pref-de-d8');
    expect(preferences.deDefaut, 8);
    expect(stockage.reglages['de.defaut'], '8');
    await toucher('pref-connaissances-cache');
    expect(
        preferences.affichage(GroupeJets.connaissances), AffichageGroupe.cache);
    await toucher('pref-aptitudes-memoriser');
    expect(stockage.reglages['de.affichage.aptitudes'], 'memoriser');

    // Relus au démarrage suivant.
    final relu = await PreferencesController.charger(stockage);
    expect(relu.deDefaut, 8);
    expect(relu.groupeOuvert(GroupeJets.connaissances), isFalse);
    await relu.memoriserGroupe(GroupeJets.aptitudes, false);
    final relu2 = await PreferencesController.charger(stockage);
    expect(relu2.groupeOuvert(GroupeJets.aptitudes), isFalse);
  });

  testWidgets('page À propos', (tester) async {
    await _ouvrir(tester);
    await _aller(tester, 'À propos');
    expect(find.byKey(const Key('version-app')), findsOneWidget);
  });

  testWidgets('menu latéral : numéro de version en bas', (tester) async {
    await _ouvrir(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    final version = find.byKey(const Key('menu-version'));
    await tester.ensureVisible(version);
    expect(
      tester.widget<Text>(version).data,
      'Version $kVersionApp · $kDateVersion',
    );
    // Sous la dernière entrée du menu.
    expect(tester.getTopLeft(version).dy,
        greaterThan(tester.getTopLeft(find.text('À propos').last).dy));
  });

  testWidgets('menu : la version ouvre les Nouveautés', (tester) async {
    await _ouvrir(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    final lien = find.byKey(const Key('menu-version-lien'));
    await tester.ensureVisible(lien);
    await tester.pumpAndSettle();
    await tester.tap(lien);
    await tester.pumpAndSettle();
    expect(find.text('Nouveautés'), findsWidgets);
    expect(find.byKey(const Key('version-$kVersionApp')), findsOneWidget);
    expect(find.byKey(const Key('version-actuelle')), findsOneWidget);
  });

  test('changelog : versions récentes d\'abord, la 1ʳᵉ = version actuelle', () {
    expect(kChangelog.first.version, kVersionApp);
    expect(kChangelog.first.date, kDateVersion);
    expect(kChangelog.last.version, '0.1.0');
    List<int> n(String v) => [for (final x in v.split('.')) int.parse(x)];
    for (var i = 1; i < kChangelog.length; i++) {
      final a = n(kChangelog[i - 1].version);
      final b = n(kChangelog[i].version);
      expect(a[1] * 1000 + a[2] > b[1] * 1000 + b[2], isTrue,
          reason:
              '${kChangelog[i - 1].version} avant ${kChangelog[i].version}');
    }
    for (final v in kChangelog) {
      expect(RegExp(r'^\d\d/\d\d/\d{4}$').hasMatch(v.date), isTrue);
      expect(v.changements, isNotEmpty, reason: v.version);
      for (final c in v.changements) {
        expect(c.texte.trim(), isNotEmpty);
        expect(c.texte.length, lessThan(130), reason: c.texte);
      }
    }
  });

  test('version : identique dans pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final m =
        RegExp(r'^version:\s*([\d.]+)\+', multiLine: true).firstMatch(pubspec);
    expect(m?.group(1), kVersionApp);
  });

  testWidgets('page Lancer de dé : résultat entre 1 et 20, historique',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: DeScreen(aleatoire: Random(42))),
    );
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('bouton-lancer')));
      await tester.pumpAndSettle();
    }
    final resultat = int.parse(
      tester.widget<Text>(find.byKey(const Key('resultat-de'))).data!,
    );
    expect(resultat, inInclusiveRange(1, 20));
    await tester.scrollUntilVisible(find.text('Historique des lancers'), 200,
        scrollable: find.byType(Scrollable).last);
    expect(find.text('Historique des lancers'), findsOneWidget);
    expect(find.byKey(const Key('lancer-2')), findsOneWidget);
    // Sans personnage : pas de choix de personnage actif
    expect(find.byKey(const Key('choix-personnage-actif')), findsNothing);
  });

  testWidgets('personnage actif : étoile à l\'accueil, jets sur la page dé',
      (tester) async {
    final preferences = await _ouvrir(tester);
    final stockage = preferences.stockage! as _StockageFactice;

    // Accueil : l'étoile choisit le personnage actif, mis en évidence
    expect(find.byKey(const Key('badge-actif')), findsNothing);
    await tester.tap(find.byKey(const Key('actif-b')));
    await tester.pumpAndSettle();
    expect(preferences.personnageActifId, 'b');
    expect(stockage.actifEnregistre, 'b');
    expect(find.byKey(const Key('badge-actif')), findsOneWidget);

    // Page dé : rappel des stats et jets du personnage
    await _aller(tester, 'Lancer de dé');
    expect(find.byKey(const Key('panneau-personnage-actif')), findsOneWidget);
    expect(find.textContaining('CA '), findsWidgets);
    await tester.tap(find.byKey(const Key('test-FOR')));
    await tester.pumpAndSettle();
    final total = int.parse(
      tester.widget<Text>(find.byKey(const Key('resultat-de'))).data!,
    );
    expect(total, inInclusiveRange(1, 20)); // FOR 10 → +0
    String commentaire() =>
        tester.widget<Text>(find.byKey(const Key('commentaire-de'))).data!;
    expect(commentaire(), startsWith('Brom · Test de FOR'));
    // Aussi dans l'historique
    expect(find.byKey(const Key('lancer-0')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('lancer-0')),
        matching: find.text('Brom · Test de FOR'),
      ),
      findsOneWidget,
    );
    // Initiative : une valeur depuis le 31/10/2026 ; second jet : esquive.
    expect(find.byKey(const Key('jet-initiative')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('jet-esquive')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('jet-esquive')));
    await tester.pumpAndSettle();
    // Un 20 ou un 1 naturel ajoute « · Réussite critique ! » ou « · Échec… ».
    expect(commentaire(), startsWith("Brom · Jet d'esquive"));
    // Les jets de la page dé ne vont plus dans l'historique du personnage
    // (seulement ceux d'une séance).
    final brom =
        tester.widget<DeScreen>(find.byType(DeScreen)).personnages!.parId('b')!;
    expect(
      brom.historique.where((e) => e.categorie == CategorieHistorique.des),
      isEmpty,
    );
    expect(find.byKey(const Key('lancer-1')), findsOneWidget);

    // Effacer l'historique
    await tester.tap(find.byKey(const Key('effacer-historique-lancers')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lancer-0')), findsNothing);

    // Retirer le personnage actif depuis la liste déroulante
    await tester.tap(find.byKey(const Key('choix-personnage-actif')));
    await tester.pumpAndSettle();
    // Nom, race et classe dans la liste
    expect(
      find.textContaining('Brom · Nain · Prêtre · niveau 1',
          findRichText: true),
      findsWidgets,
    );
    await tester.tap(find.text('Aucun (d20 libre)').last);
    await tester.pumpAndSettle();
    expect(preferences.personnageActifId, isNull);
    expect(find.byKey(const Key('panneau-personnage-actif')), findsNothing);
  });

  testWidgets('page Lancer de dé : choix du dé libre, d20 par défaut',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: DeScreen(aleatoire: Random(3))),
    );
    expect(find.text('Lancer le d20'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('resultat-de'))).data,
      'd20',
    );
    for (final f in [4, 6, 8, 10, 12, 20, 100]) {
      expect(find.byKey(Key('de-libre-d$f')), findsOneWidget);
    }
    await tester.tap(find.byKey(const Key('de-libre-d6')));
    await tester.pumpAndSettle();
    expect(find.text('Lancer le d6'), findsOneWidget);
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byKey(const Key('bouton-lancer')));
      await tester.pumpAndSettle();
      final r = int.parse(
        tester.widget<Text>(find.byKey(const Key('resultat-de'))).data!,
      );
      expect(r, inInclusiveRange(1, 6));
    }
    await tester.tap(find.byKey(const Key('de-libre-d100')));
    await tester.pumpAndSettle();
    expect(find.text('Lancer le d100'), findsOneWidget);
    // Avantage sur un d6 libre : deux d6, on garde le meilleur.
    await tester.tap(find.byKey(const Key('de-libre-d6')));
    await tester.tap(find.byKey(const Key('mode-avantage')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bouton-lancer')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('detail-de'))).data,
      startsWith('Avantage : '),
    );
  });

  test('avantage / désavantage sur un dé libre, dégâts inchangés', () {
    for (var graine = 0; graine < 20; graine++) {
      final a = ResultatLancer.lancer(
        libelle: 'd6',
        de: '1d6',
        mode: ModeLancer.avantage,
        modeTousDes: true,
        aleatoire: Random(graine),
      )!;
      expect(a.des, hasLength(2));
      expect(a.garde, a.des.reduce(max));
      expect(a.garde, inInclusiveRange(1, 6));
      expect(a.reussiteCritique || a.echecCritique, isFalse);
      final d = ResultatLancer.lancer(
        libelle: 'd100',
        de: '1d100',
        mode: ModeLancer.desavantage,
        modeTousDes: true,
        aleatoire: Random(graine),
      )!;
      expect(d.garde, d.des.reduce(min));
    }
    // Jet de dégâts d'un personnage : l'avantage ne s'applique pas.
    final degats = ResultatLancer.lancer(
      libelle: 'Dégâts',
      de: '1d8',
      mode: ModeLancer.avantage,
      aleatoire: Random(1),
    )!;
    expect(degats.des, hasLength(1));
  });

  testWidgets('modificateur libre ajouté au jet, avantage en couleur',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: DeScreen(aleatoire: Random(7))),
    );
    // +2 puis −1 → +1 ; remise à zéro possible
    for (final cle in ['modif-plus', 'modif-plus', 'modif-moins']) {
      await tester.tap(find.byKey(Key(cle)));
      await tester.pumpAndSettle();
    }
    expect(
      tester.widget<Text>(find.byKey(const Key('modif-valeur'))).data,
      '+1',
    );
    await tester.tap(find.byKey(const Key('mode-avantage')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const Key('mode-avantage')))
          .selected,
      isTrue,
    );
    await tester.tap(find.byKey(const Key('bouton-lancer')));
    await tester.pumpAndSettle();
    final detail =
        tester.widget<Text>(find.byKey(const Key('detail-de'))).data!;
    expect(detail, startsWith('Avantage : '));
    expect(detail, contains('+1 (modif.)'));
    final total = int.parse(
      tester.widget<Text>(find.byKey(const Key('resultat-de'))).data!,
    );
    expect(total, inInclusiveRange(2, 21));

    await tester.tap(find.byKey(const Key('modif-zero')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('modif-valeur'))).data,
      '+0',
    );
  });

  testWidgets('page dé sur téléphone avec personnage actif', (tester) async {
    final preferences = await _ouvrir(tester);
    await preferences.changerPersonnageActif('b');
    tester.view.physicalSize = const Size(400, 900);
    await tester.pumpAndSettle();
    await _aller(tester, 'Lancer de dé');
    final test = find.byKey(const Key('test-CON'));
    await tester.scrollUntilVisible(test, 200,
        scrollable: find.byType(Scrollable).last);
    await tester.ensureVisible(test);
    await tester.pumpAndSettle();
    await tester.tap(test);
    await tester.pumpAndSettle();
    // Résultat visible en haut sans faire défiler
    // (suivi éventuellement de « Réussite / Échec critique ! »)
    expect(
      tester.widget<Text>(find.byKey(const Key('commentaire-de'))).data,
      startsWith('Brom · Test de CON'),
    );
    expect(tester.getTopLeft(find.byKey(const Key('resultat-de'))).dy,
        lessThan(300));
  });

  test('formules de dés et détail des lancers', () {
    expect(lireDes('1d8'), (nombre: 1, faces: 8, bonus: 0));
    expect(lireDes('2D6 phy'), (nombre: 2, faces: 6, bonus: 0));
    expect(lireDes('1d8+1'), (nombre: 1, faces: 8, bonus: 1));
    expect(lireDes('d20'), (nombre: 1, faces: 20, bonus: 0));
    expect(lireDes('+3'), isNull);

    final test = ResultatLancer(
      libelle: 'Test de FOR',
      formule: '1d20 +3',
      des: [14],
      garde: 14,
      bonus: 3,
      d20: true,
    );
    expect(test.total, 17);
    expect(test.detail, '1d20 : 14 +3 = 17');
    final avantage = ResultatLancer(
      libelle: 'Toucher CaC',
      formule: '1d20 +2',
      des: [7, 20],
      garde: 20,
      bonus: 2,
      mode: ModeLancer.avantage,
      d20: true,
    );
    expect(avantage.reussiteCritique, isTrue);
    expect(avantage.detail, 'Avantage : 7 et 20 → 20 +2 = 22');
    final degats = ResultatLancer(
      libelle: 'Dégâts',
      formule: '2d6 −1',
      des: [3, 4],
      garde: 7,
      bonus: -1,
    );
    expect(degats.detail, '2d6 : 3 + 4 −1 = 6');
    // Modificateur libre : affiché à part, ajouté au total
    final modifie = ResultatLancer(
      libelle: 'Test de FOR',
      formule: '1d20 +3',
      des: [14],
      garde: 14,
      bonus: 3,
      modificateur: -2,
      d20: true,
    );
    expect(modifie.total, 15);
    expect(modifie.detail, '1d20 : 14 +3 −2 (modif.) = 15');
    // Un 20 sur un dé de dégâts n'est pas un critique
    expect(
      ResultatLancer(libelle: 'x', formule: '1d20', des: [20], garde: 20)
          .reussiteCritique,
      isFalse,
    );

    final aleatoire = Random(3);
    for (var i = 0; i < 100; i++) {
      final r = ResultatLancer.lancer(
        libelle: 'Dégâts',
        de: '2d6',
        bonus: 3,
        mode: ModeLancer.avantage, // ignoré hors d20
        aleatoire: aleatoire,
      )!;
      expect(r.des, hasLength(2));
      expect(r.total, inInclusiveRange(5, 15));
    }
  });

  test('d20 : avantage, désavantage et critiques', () {
    expect(LancerD20(ModeLancer.avantage, [7, 15]).garde, 15);
    expect(LancerD20(ModeLancer.desavantage, [7, 15]).garde, 7);
    expect(LancerD20(ModeLancer.normal, [20]).reussiteCritique, isTrue);
    expect(LancerD20(ModeLancer.avantage, [1, 1]).echecCritique, isTrue);
    final aleatoire = Random(1);
    for (var i = 0; i < 200; i++) {
      final l = LancerD20.lancer(ModeLancer.avantage, aleatoire: aleatoire);
      expect(l.des, hasLength(2));
      expect(l.garde, inInclusiveRange(1, 20));
    }
  });

  test('recherche sans accents ni majuscules', () {
    expect(correspond('Potion de santé', 'SANTE'), isTrue);
    expect(correspond('Étourdi', 'etourdi'), isTrue);
    expect(correspond('Loup', ''), isTrue);
    expect(correspond('Loup', 'ours'), isFalse);
  });

  test('lecteur Markdown : titre, introduction et sections', () {
    final doc = DocumentMarkdown.lire(_referentiel.reglesSysteme);
    expect(doc.titre, 'Règles');
    expect(doc.sections.map((s) => s.titre), ['Dés', 'Afflictions']);
  });

  test('données embarquées : équipements, bestiaire, règles, classes', () {
    final equipements =
        (jsonDecode(File('assets/data/equipements.json').readAsStringSync())
                as List)
            .map((e) => Equipement.depuisJson(e as Map<String, dynamic>))
            .toList();
    expect(equipements.where((e) => e.sousCategorie == 'Potion'), isNotEmpty);
    expect(equipements.map((e) => e.id).toSet(), hasLength(equipements.length));

    final creatures =
        (jsonDecode(File('assets/data/bestiaire.json').readAsStringSync())
                as List)
            .map((e) => Creature.depuisJson(e as Map<String, dynamic>))
            .toList();
    final ours = creatures.firstWhere((c) => c.id == 'ours-brun');
    expect(ours.taille, TailleCreature.grande);
    expect(ours.archetype, 'Puissant');
    // Dragon générique retiré le 31/10/2026 : quatre âges de dragons.
    expect(creatures.any((c) => c.id == 'dragon'), isFalse);
    expect(creatures.where((c) => c.famille == 'Dragons'),
        hasLength(5)); // + wyverne
    expect(creatures.map((c) => c.id).toSet(), hasLength(creatures.length));

    final regles = DocumentMarkdown.lire(
      File('assets/data/regles_systeme.md').readAsStringSync(),
    );
    expect(regles.sections.length, greaterThan(5));
    expect(regles.sections.map((s) => s.titre), contains('Afflictions'));

    final classes =
        (jsonDecode(File('assets/data/classes.json').readAsStringSync())
                as List)
            .map((e) => Classe.depuisJson(e as Map<String, dynamic>))
            .toList();
    expect(
      classes.firstWhere((c) => c.id == 'pretre').description,
      contains('divinité'),
    );
    final races =
        (jsonDecode(File('assets/data/races.json').readAsStringSync()) as List)
            .map((e) => Race.depuisJson(e as Map<String, dynamic>))
            .toList();
    ProfilClasse profilRace(String id) =>
        races.firstWhere((r) => r.id == id).profil;
    expect(profilRace('nain'), ProfilClasse.physique);
    expect(profilRace('haut-elfe'), ProfilClasse.lanceur);
    expect(profilRace('gnome'), ProfilClasse.hybride);
    ProfilClasse profil(String id) =>
        classes.firstWhere((c) => c.id == id).profil;
    expect(profil('barbare'), ProfilClasse.physique);
    expect(profil('barde'), ProfilClasse.hybride);
    expect(profil('druide'), ProfilClasse.lanceur);
    expect(profil('pretre'), ProfilClasse.lanceur); // depuis le 03/11/2026
    expect(profil('rodeur'), ProfilClasse.physique);
  });

  test('catégorie d\'équipement : code, libellé ou majuscules', () {
    expect(CategorieEquipement.depuisCode('arme'), CategorieEquipement.arme);
    expect(CategorieEquipement.depuisCode('Arme'), CategorieEquipement.arme);
    expect(
        CategorieEquipement.depuisCode('Armures'), CategorieEquipement.armure);
    expect(
      CategorieEquipement.depuisCode('Objet magique'),
      CategorieEquipement.objetMagique,
    );
    expect(
        CategorieEquipement.depuisCode('inconnu'), CategorieEquipement.autre);
  });
}
