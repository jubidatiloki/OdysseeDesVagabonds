import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/historique.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/screens/fiche/onglet_historique.dart';

/// Historique du personnage : les événements d'une séance sont regroupés
/// (10/11/2026).
void main() {
  tearDown(Personnage.seancesEnCours.clear);

  test('pendant une séance, les événements y sont rattachés', () {
    final p = Personnage(id: 'p', nom: 'Pip', raceId: 'r', classeId: 'c');
    p.journaliser('Avant la séance');
    Personnage.seancesEnCours['p'] = 'Les Brumes · Séance 3';
    p.journaliser('Test de FOR : 15', categorie: CategorieHistorique.des);
    p.journaliserValeur(
      cle: 'pv',
      libelle: 'PV',
      avant: 10,
      apres: 7,
      categorie: CategorieHistorique.vie,
    );
    Personnage.seancesEnCours.remove('p');
    p.journaliser('Après la séance');
    expect(
      [for (final e in p.historique) e.seance],
      [null, 'Les Brumes · Séance 3', 'Les Brumes · Séance 3', null],
    );
    // Gardé à l'enregistrement.
    final relu = Personnage.depuisJson(p.versJson());
    expect(relu.historique[1].seance, 'Les Brumes · Séance 3');
    // Anciens jets « Séance 2 · … » : séance retrouvée par leur préfixe.
    expect(
      seanceDe(EvenementHistorique(
        date: DateTime(2026, 11, 8),
        categorie: CategorieHistorique.des,
        message: 'Séance 2 · Test de CON : 9',
      )),
      'Séance 2',
    );
  });

  testWidgets('un cadre repliable par séance', (tester) async {
    final p = Personnage(id: 'p', nom: 'Pip', raceId: 'r', classeId: 'c');
    final jour = DateTime(2026, 11, 10, 20);
    p.journaliser('Hors séance', maintenant: jour);
    Personnage.seancesEnCours['p'] = 'Les Brumes · Séance 3';
    p.journaliser('Test de FOR : 15',
        categorie: CategorieHistorique.des,
        maintenant: jour.add(const Duration(minutes: 5)));
    p.journaliser('Test de DEX : 12',
        categorie: CategorieHistorique.des,
        maintenant: jour.add(const Duration(minutes: 9)));
    Personnage.seancesEnCours.clear();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: OngletHistorique(personnage: p)),
    ));
    expect(find.text('Les Brumes · Séance 3'), findsOneWidget);
    expect(find.textContaining('2 événements'), findsOneWidget);
    expect(find.text('Hors séance'), findsOneWidget);
    // Replié au départ : on l'ouvre pour voir les jets.
    expect(find.text('Test de FOR : 15'), findsNothing);
    await tester.tap(find.text('Les Brumes · Séance 3'));
    await tester.pumpAndSettle();
    expect(find.text('Test de FOR : 15'), findsOneWidget);
    expect(find.text('Test de DEX : 12'), findsOneWidget);
  });
}
