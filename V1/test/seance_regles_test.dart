import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/butin.dart';
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/seance.dart';
import 'package:odyssee_vagabonds/regles/des.dart';
import 'package:odyssee_vagabonds/screens/fiche/onglet_inventaire.dart';

/// Règles de séance du 20/11/2026 : critique, objets séparés, butin groupé,
/// état de santé, objets de quête, conversations, heure du serveur.
void main() {
  test('critique : dés au maximum, puis le total doublé', () {
    final r = degatsCritiques(libelle: 'Épée', de: '1d8', bonus: 3)!;
    expect(r.total, (8 + 3) * 2);
    expect(degatsCritiques(libelle: 'Hache', de: '2d6')!.total, 24);
  });

  test('deux épées : une ligne par exemplaire, potions groupées', () {
    final epees = Objet(nom: 'Épée', categorie: CategorieObjet.arme)
      ..quantite = 2;
    final l = epees.separe();
    expect(l, hasLength(2));
    expect(l.map((o) => o.quantite), [1, 1]);
    expect(l.first.id, isNot(l.last.id));
    final potions = Objet(nom: 'Potion', categorie: CategorieObjet.consommable)
      ..quantite = 3;
    expect(potions.separe().single.quantite, 3);
  });

  test('butin : un objet identique augmente la quantité', () {
    Objet courte() => Objet(nom: 'Épée courte', categorie: CategorieObjet.arme);
    final b = const ButinSeance(nom: 'Coffre')
        .avecObjet(courte())
        .avecObjet(courte())
        .avecObjet(Objet(nom: 'Corde', categorie: CategorieObjet.divers));
    expect(b.objets.map((o) => (o.nom, o.quantite)),
        [('Épée courte', 2), ('Corde', 1)]);
  });

  test('état de santé : indemne, blessé, gravement blessé, inconscient', () {
    expect(SantePj.depuisPv(10, 10), SantePj.indemne);
    expect(SantePj.depuisPv(6, 10), SantePj.blesse);
    expect(SantePj.depuisPv(2, 10), SantePj.grave);
    expect(SantePj.depuisPv(0, 10), SantePj.inconscient);
    expect(SantePj.depuisCode('grave')!.libelle, 'Gravement blessé');
  });

  test('conversations : toute la table, entre deux joueurs, avec le MJ', () {
    MessageSeance m(String conversation, {String joueur = 'j1'}) =>
        MessageSeance(
          de: 'j1',
          joueur: joueur,
          mj: 'mj',
          texte: 'Salut',
          date: DateTime(2026, 11, 20),
          conversation: conversation,
        );
    expect(
        MessageSeance.entrePj('j2', 'j1'), MessageSeance.entrePj('j1', 'j2'));
    final pj = m(MessageSeance.entrePj('j2', 'j1'));
    expect(pj.participants, ['j1', 'j2']);
    expect(pj.versJson()['participants'], isNot(contains('mj')));
    expect(m(MessageSeance.general).participants, isEmpty);
    expect(m('').participants, ['mj', 'j1']);
    expect(m('').cle, 'j1');
    final lu = MessageSeance.depuisJson('x', pj.versJson());
    expect(lu.cle, pj.cle);
  });

  test('logs : l\'heure du serveur passe avant celle de l\'appareil', () {
    final j = JetSeance.depuisJson('a', {
      'auteur': 'j1',
      'libelle': 'Test',
      'date': '2026-11-20T10:00:05',
      'serveur': '2026-11-20T10:00:01',
    });
    expect(j.heure, DateTime(2026, 11, 20, 10, 0, 1));
    expect(JetSeance.depuisJson('b', {'date': '2026-11-20T10:00:05'}).heure,
        DateTime(2026, 11, 20, 10, 0, 5));
  });

  testWidgets(
      'objet de quête : seul le MJ le modifie ; PJ en séance : pas '
      'd\'ajout', (tester) async {
    final quete = Objet(nom: 'Sceau royal', categorie: CategorieObjet.quete);
    final p =
        Personnage(id: 'p', nom: 'Brom', raceId: 'nain', classeId: 'guerrier')
          ..inventaire.add(quete);
    Future<void> ouvrir({required bool mj, bool seance = false}) =>
        tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: OngletInventaire(
              personnage: p,
              onModifie: () async {},
              mj: mj,
              ajoutInterdit: seance,
            ),
          ),
        ));
    await ouvrir(mj: false, seance: true);
    expect(find.byKey(Key('quete-${quete.id}')), findsOneWidget);
    expect(find.byKey(Key('menu-objet-${quete.id}')), findsNothing);
    expect(find.byKey(const Key('ajouter-objet')), findsNothing);
    expect(find.byKey(const Key('inventaire-ajout-mj')), findsOneWidget);
    expect(find.byKey(const Key('bourse-recevoir')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('bourse-recevoir')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('bourse-or-plus')))
          .onPressed,
      isNull,
    );
    await ouvrir(mj: true);
    expect(find.byKey(Key('menu-objet-${quete.id}')), findsOneWidget);
    expect(find.byKey(const Key('ajouter-objet')), findsOneWidget);
  });
}
