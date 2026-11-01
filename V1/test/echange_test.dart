import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/app.dart';
import 'package:odyssee_vagabonds/data/echange_personnage.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/historique.dart';
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';

const _referentiel = Referentiel(
  races: [Race(id: 'nain', nom: 'Nain', deVie: 8, deMana: 4)],
  classes: [
    Classe(
      id: 'guerrier',
      nom: 'Guerrier',
      modifDeVie: ModifDe.plus,
      modifDeMana: ModifDe.moins,
    ),
  ],
);

Personnage _brom() => Personnage(
      id: 'brom',
      nom: 'Brom Barbe-de-Fer',
      sexe: Sexe.homme,
      raceId: 'nain',
      classeId: 'guerrier',
      niveau: 3,
      description: 'Forgeron exilé.',
      notes: 'Doit 10 po à Lia.',
      inventaire: [Objet(nom: 'Marteau', categorie: CategorieObjet.arme)],
      bourse: Bourse(or: 4),
    );

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  group('format d\'échange', () {
    test('export puis import : personnage identique', () {
      final texte = EchangePersonnage.exporter(_brom());
      final json = jsonDecode(texte) as Map<String, dynamic>;
      expect(json['format'], EchangePersonnage.format);
      expect(json['version'], 1);

      final p = EchangePersonnage.lire(texte, _referentiel);
      expect(p.id, 'brom');
      expect(p.nom, 'Brom Barbe-de-Fer');
      expect(p.sexe, Sexe.homme);
      expect(p.niveau, 3);
      expect(p.description, 'Forgeron exilé.');
      expect(p.notes, 'Doit 10 po à Lia.');
      expect(p.inventaire.single.nom, 'Marteau');
      expect(p.bourse.or, 4);
    });

    test('nom de fichier sans accents ni espaces', () {
      final p = _brom()..nom = 'Élise d\'Œil-Vif';
      expect(EchangePersonnage.nomFichier(p), 'odv_elise_d_oeil_vif.json');
    });

    test('le JSON brut d\'un personnage est aussi accepté', () {
      final texte = jsonEncode(_brom().versJson());
      expect(
          EchangePersonnage.lire(texte, _referentiel).nom, 'Brom Barbe-de-Fer');
    });

    test('erreurs explicites', () {
      expect(
        () => EchangePersonnage.lire('pas du json', _referentiel),
        throwsA(isA<ErreurImport>()),
      );
      expect(
        () => EchangePersonnage.lire('{"autre": 1}', _referentiel),
        throwsA(isA<ErreurImport>()),
      );
      final elfe = _brom()..raceId = 'elfe-noir';
      expect(
        () => EchangePersonnage.lire(
          EchangePersonnage.exporter(elfe),
          _referentiel,
        ),
        throwsA(
          isA<ErreurImport>()
              .having((e) => e.message, 'message', contains('elfe-noir')),
        ),
      );
      final futur = jsonEncode({
        'format': EchangePersonnage.format,
        'version': 99,
        'personnage': _brom().versJson(),
      });
      expect(
        () => EchangePersonnage.lire(futur, _referentiel),
        throwsA(isA<ErreurImport>()),
      );
    });

    test('copie : nouvel identifiant et nom « (copie) »', () {
      final c = EchangePersonnage.copie(_brom());
      expect(c.id, isNot('brom'));
      expect(c.nom, 'Brom Barbe-de-Fer (copie)');
      expect(c.inventaire.single.nom, 'Marteau');
    });
  });

  testWidgets('modifier le nom, le sexe et la description', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final p = _brom();
    final controller =
        PersonnagesController(EnMemoirePersonnageRepository([p]));
    await controller.charger();
    await tester.pumpWidget(
      OdvApp(referentiel: _referentiel, controller: controller),
    );
    await tester.pumpAndSettle();

    await _tap(tester, find.text('Brom Barbe-de-Fer'));
    expect(find.text('Forgeron exilé.'), findsOneWidget);

    await _tap(tester, find.byKey(const Key('bouton-identite')));
    await tester.enterText(
      find.byKey(const Key('champ-nom-identite')),
      'Bromia',
    );
    await _tap(tester, find.byKey(const Key('identite-sexe-femme')));
    await tester.enterText(
      find.byKey(const Key('champ-description')),
      'Forgeronne exilée.',
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('enregistrer-identite')));

    expect(p.nom, 'Bromia');
    expect(p.sexe, Sexe.femme);
    expect(p.description, 'Forgeronne exilée.');
    expect(find.text('Bromia'), findsOneWidget); // carte d'identité
    expect(find.text('Forgeronne exilée.'), findsOneWidget);
    final derniere = p.historique.last;
    expect(derniere.categorie, CategorieHistorique.identite);
    expect(
        derniere.message, contains('nom « Brom Barbe-de-Fer » → « Bromia »'));
    expect(derniere.message, contains('sexe Homme → Femme'));
  });

  testWidgets('importer en collant le texte, puis garder les deux',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final controller = PersonnagesController(EnMemoirePersonnageRepository());
    await controller.charger();
    await tester.pumpWidget(
      OdvApp(referentiel: _referentiel, controller: controller),
    );
    await tester.pumpAndSettle();
    final texte = EchangePersonnage.exporter(_brom());

    Future<void> importer() async {
      await _tap(tester, find.byKey(const Key('bouton-importer')));
      await _tap(tester, find.byKey(const Key('import-texte')));
      await tester.enterText(
        find.byKey(const Key('champ-import-texte')),
        texte,
      );
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(const Key('valider-import')));
    }

    await importer();
    expect(controller.personnages, hasLength(1));
    expect(find.text('Brom Barbe-de-Fer'), findsOneWidget);
    expect(
      controller.personnages.single.historique.last.message,
      'Personnage importé',
    );

    // Deuxième import du même personnage : conflit → garder les deux
    await importer();
    expect(find.text('Brom Barbe-de-Fer existe déjà'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('import-copie')));
    expect(controller.personnages, hasLength(2));
    expect(find.text('Brom Barbe-de-Fer (copie)'), findsOneWidget);
  });

  testWidgets('un texte invalide affiche une erreur', (tester) async {
    final controller = PersonnagesController(EnMemoirePersonnageRepository());
    await controller.charger();
    await tester.pumpWidget(
      OdvApp(referentiel: _referentiel, controller: controller),
    );
    await tester.pumpAndSettle();

    await _tap(tester, find.byKey(const Key('bouton-importer')));
    await _tap(tester, find.byKey(const Key('import-texte')));
    await tester.enterText(
      find.byKey(const Key('champ-import-texte')),
      'bonjour',
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('valider-import')));
    expect(find.textContaining('pas un fichier de personnage valide'),
        findsOneWidget);
    expect(controller.personnages, isEmpty);
  });
}
