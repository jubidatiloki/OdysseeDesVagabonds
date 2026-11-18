import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/campagnes.dart';
import 'package:odyssee_vagabonds/models/bonus_seance.dart';
import 'package:odyssee_vagabonds/models/campagne.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/seance.dart';

BonusSeance _bonus(
  String nom,
  int valeur,
  PorteeBonus portee, {
  List<String> cibles = const ['j1'],
  Carac? carac,
  String auteur = 'j2',
}) =>
    BonusSeance(
      nom: nom,
      valeur: valeur,
      portee: portee,
      carac: carac,
      cibles: cibles,
      auteur: auteur,
      auteurNom: 'Bardin',
      duree: DureeBonus.finCombat,
      seance: 1,
      date: DateTime(2026, 11, 18),
    );

void main() {
  test('chaque bonus compte pour ses jets seulement', () {
    final tous = [
      _bonus('Musique vivifiante', 2, PorteeBonus.attaque),
      _bonus('Embuscade', 5, PorteeBonus.initiative),
      _bonus('Force du taureau', 2, PorteeBonus.carac, carac: Carac.force),
      _bonus('Arme bénie', 1, PorteeBonus.degats),
      _bonus('Malédiction', -1, PorteeBonus.tous),
      _bonus('Pour un autre', 3, PorteeBonus.tous, cibles: ['j3']),
    ];
    List<String> noms({
      GenreJet genre = GenreJet.test,
      bool d20 = true,
      bool degats = false,
      Carac? carac,
      bool initiative = false,
    }) =>
        [
          for (final b in BonusSeance.applicables(
            tous,
            'j1',
            genre: genre,
            d20: d20,
            degats: degats,
            carac: carac,
            initiative: initiative,
          ))
            b.nom,
        ]..sort();
    expect(
        noms(genre: GenreJet.attaque), ['Malédiction', 'Musique vivifiante']);
    expect(noms(carac: Carac.force), ['Force du taureau', 'Malédiction']);
    expect(noms(carac: Carac.dex), ['Malédiction']);
    expect(noms(initiative: true), ['Embuscade', 'Malédiction']);
    expect(
        noms(genre: GenreJet.degats, d20: false, degats: true), ['Arme bénie']);
  });

  test('même nom : pas de cumul, le plus fort compte', () {
    final r = BonusSeance.applicables(
      [
        _bonus('Musique vivifiante', 2, PorteeBonus.attaque),
        _bonus('musique vivifiante', 3, PorteeBonus.attaque),
        _bonus('Chant de guerre', 1, PorteeBonus.attaque),
      ],
      'j1',
      genre: GenreJet.attaque,
      d20: true,
      degats: false,
    );
    expect(r.map((b) => b.valeur).toList()..sort(), [1, 3]);
  });

  test('textes, lecture et ordre d\'initiative', () {
    final b = _bonus('Force', 2, PorteeBonus.carac, carac: Carac.force);
    expect(b.effet, '+2 aux tests de FOR');
    expect(_bonus('Gêne', -1, PorteeBonus.attaque).effet, '−1 aux attaques');
    final t = b.copie(toursRestants: 3);
    final relu = BonusSeance.depuisJson(
        'x',
        BonusSeance(
          nom: 'Lien',
          valeur: 1,
          portee: PorteeBonus.tous,
          cibles: const ['j1', 'j2'],
          auteur: 'j3',
          auteurNom: 'Pria',
          duree: DureeBonus.tours,
          toursRestants: 3,
          seance: 2,
          date: DateTime(2026),
        ).versJson());
    expect(relu.cibles, ['j1', 'j2']);
    expect((relu.duree, relu.dureeTexte, relu.seance),
        (DureeBonus.tours, '3 tours', 2));
    expect(t.toursRestants, 3);
    // Embuscade : +5 d'initiative, Brom passe devant le loup.
    MembreCampagne m(String uid, int init) => MembreCampagne(
          uid: uid,
          nom: uid,
          personnageId: uid,
          personnageNom: uid,
          personnageResume: '',
          date: DateTime(2026),
          initiative: init,
        );
    final loup = const CreatureSeance(id: 'loup', nom: 'Loup', initiative: 12);
    expect(ordreCombat([m('brom', 10)], [loup]), ['loup', 'brom']);
    expect(
      ordreCombat([m('brom', 10)], [loup], bonusInitiative: {'brom': 5}),
      ['brom', 'loup'],
    );
  });

  test('service : à son nom ; retiré par son auteur ou le MJ seulement',
      () async {
    final base = BaseCampagnesMemoire(Random(4));
    final mj = ServiceCampagnesMemoire(base, 'mj');
    var c = await mj.creer(nom: 'Valfroid', mjNom: 'Ben');
    for (final j in ['j1', 'j2']) {
      await ServiceCampagnesMemoire(base, j).demander(
        c,
        MembreCampagne(
          uid: j,
          nom: j,
          personnageId: j,
          personnageNom: j,
          personnageResume: '',
          date: DateTime(2026),
        ),
      );
      await mj.accepter(base.campagnes[c.id]!, j);
    }
    c = base.campagnes[c.id]!;
    final j1 = ServiceCampagnesMemoire(base, 'j1').seance;
    final j2 = ServiceCampagnesMemoire(base, 'j2').seance;
    final intrus = ServiceCampagnesMemoire(base, 'x').seance;
    final b = _bonus('Musique', 2, PorteeBonus.attaque, auteur: 'j2');
    // Au nom d'un autre : refusé ; hors campagne : refusé.
    await expectLater(j1.poserBonus(c, b), throwsA(isA<ErreurCampagne>()));
    await expectLater(
        intrus.poserBonus(c, b.copie()), throwsA(isA<ErreurCampagne>()));
    await j2.poserBonus(c, b);
    final pose = (await j1.ecouterBonus(c).first).single;
    // Celui qui le reçoit ne peut pas le retirer.
    await expectLater(j1.retirerBonus(c, pose), throwsA(isA<ErreurCampagne>()));
    await j2.retirerBonus(c, pose);
    expect(await j1.ecouterBonus(c).first, isEmpty);
    await j2.poserBonus(c, b);
    await mj.seance
        .retirerBonus(c, (await mj.seance.ecouterBonus(c).first).single);
    expect(await mj.seance.ecouterBonus(c).first, isEmpty);
  });
}
