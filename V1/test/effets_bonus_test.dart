import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/bonus_seance.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/seance.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/state/seance_controller.dart';

Competence _depuis(String fichier, String nom) {
  final json = jsonDecode(File('assets/data/$fichier').readAsStringSync());
  if (fichier == 'sorts_rang0.json') {
    final s = (json as List).firstWhere((x) => x['nom'] == nom);
    return Competence.depuisJson(
        {'rang': 0, 'nom': nom, ...s['sort'] as Map<String, dynamic>});
  }
  for (final classe in json as List) {
    for (final v in classe['voies'] as List) {
      for (final c in v['competences'] as List) {
        if (c['nom'] == nom) {
          return Competence.depuisJson(c as Map<String, dynamic>);
        }
      }
    }
  }
  throw StateError(nom);
}

void main() {
  test('plusieurs bonus par compétence, options au lancement', () {
    final c = Competence.depuisJson({
      'rang': 1,
      'nom': 'X',
      'bonusDonne': [
        {'option': 'Arme', 'valeur': 1, 'portee': 'attaque'},
        {'option': 'Arme', 'valeur': 1, 'portee': 'degats'},
        {'option': 'Armure', 'valeur': 2, 'portee': 'tous'},
      ],
    });
    expect(c.bonusDonnes, hasLength(3));
    expect(c.optionsBonus, ['Arme', 'Armure']);
    // Un seul objet : une liste d'un bonus, sans option.
    final s = Competence.depuisJson({
      'rang': 1,
      'nom': 'Y',
      'bonusDonne': {'valeur': 2, 'portee': 'attaque'},
    });
    expect(s.bonusDonnes.single.valeur, 2);
    expect(s.optionsBonus, isEmpty);
  });

  test('portée « tests » : pas les attaques', () {
    final b = BonusSeance(
      nom: 'Bénédiction mineure',
      valeur: 1,
      portee: PorteeBonus.tests,
      cibles: const ['j1'],
      auteur: 'j2',
      auteurNom: 'Pria',
      duree: DureeBonus.actions,
      toursRestants: 1,
      seance: 1,
      date: DateTime(2026),
    );
    expect(b.compte(genre: GenreJet.test, d20: true, degats: false), isTrue);
    expect(
        b.compte(genre: GenreJet.attaque, d20: true, degats: false), isFalse);
    expect(b.effet, '+1 aux tests');
  });

  test('données : effets des compétences et sorts qui aident', () {
    final ben = _depuis('classes.json', 'Bénédiction');
    expect(ben.optionsBonus, ['Arme', 'Armure']);
    expect(ben.bonusDonnes.map((b) => b.portee), ['attaque', 'degats', 'ca']);
    final brume = _depuis('classes.json', 'Brume');
    expect(
        (brume.bonusDonnes.single.valeur, brume.bonusDonnes.single.siReussite),
        (-5, false));
    expect(
        _depuis('sorts_rang0.json', 'Bénédiction mineure')
            .bonusDonnes
            .single
            .portee,
        'tests');
    final charme = _depuis('sorts_rang0.json', 'Charme fugace');
    expect((charme.bonusDonnes.single.carac, charme.cible),
        ('SOC', CibleCompetence.soi));
    expect(_depuis('sorts_rang0.json', 'Souffle de ki').optionsBonus,
        ['CON', 'DEX']);
  });

  test('durée chiffrée : formule avec caractéristiques', () {
    final f = FicheCalculee(
      personnage: Personnage(
        id: 'p',
        nom: 'P',
        raceId: 'r',
        classeId: 'c',
        caracBase: {for (final c in Carac.values) c: 10}..[Carac.intel] = 16,
      ),
      race: const Race(id: 'r', nom: 'R', deVie: 6, deMana: 6),
      classe: const Classe(
        id: 'c',
        nom: 'C',
        modifDeVie: ModifDe.plus,
        modifDeMana: ModifDe.plus,
      ),
    );
    const c = Competence(rang: 1, nom: 'Z');
    int n(String v) => SeanceController.nombreDuree(f, c, v, Random(3));
    expect(n('3'), 3);
    expect(n('INT'), 3); // modificateur de 16
    expect(n('INT × 10'), 30);
    expect(n('2 + INT'), 5);
    final de = n('1d6 + INT');
    expect(de, inInclusiveRange(4, 9));
    expect(n('1d6/2'), inInclusiveRange(1, 3));
    expect(n('INT + 1d4'), inInclusiveRange(4, 7));
    expect(n('INT + 1'), 4);
    expect(n('RANG + AdM'), 1); // RANG 0, AdM +0 : 1 au moins
    expect(n(''), 1);
  });
  test('bonus de CA : selon l\'attaque, le plus fort par nom', () {
    BonusSeance ca(String nom, int v, String contre) => BonusSeance(
          nom: nom,
          valeur: v,
          portee: PorteeBonus.ca,
          contre: contre,
          cibles: const ['j1'],
          auteur: 'x',
          auteurNom: 'X',
          duree: DureeBonus.finCombat,
          seance: 1,
          date: DateTime(2026),
        );
    final tous = [
      ca('Cercle de protection', 3, 'MAG'),
      ca('Bouclier', 1, ''),
      ca('Bouclier', 2, ''),
      ca("Mur d'air", 10, 'DIST'),
    ];
    expect(BonusSeance.totalCa(tous, 'j1', contre: 'MAG'), 5);
    expect(BonusSeance.totalCa(tous, 'j1', contre: 'DIST'), 12);
    expect(BonusSeance.totalCa(tous, 'j1', contre: 'CaC'), 2);
    expect(BonusSeance.totalCa(tous, 'j1'), 2);
    expect(BonusSeance.totalCa(tous, 'j2'), 0);
    expect(tous.first.effet, '+3 à la CA contre les sorts');
    expect(tous[1].effet, '+1 à la CA');
    // La CA ne s'ajoute pas aux jets.
    expect(tous[1].compte(genre: GenreJet.attaque, d20: true, degats: false),
        isFalse);
  });

  test('données : compétences qui donnent de la CA', () {
    final ecorces = _depuis('classes.json', 'Écorces partagées');
    expect(ecorces.bonusDonnes, hasLength(4));
    expect(
      ecorces.bonusDonnes
          .where((b) => (b.rangMax ?? 99) <= 2)
          .map((b) => (b.valeur, b.contre)),
      [(1, 'CaC'), (1, 'DIST')],
    );
    expect(
      ecorces.bonusDonnes
          .where((b) => (b.rangMin ?? 0) >= 3)
          .map((b) => b.valeur),
      [2, 2],
    );
    for (final (nom, valeur, contre) in [
      ('Cercle de protection', 3, 'MAG'),
      ('Sanctuaire', 2, 'MAG'),
      ("Mur d'air", 10, 'DIST'),
      ('Cri de ralliement', 2, ''),
    ]) {
      final b = _depuis('classes.json', nom).bonusDonnes.single;
      expect((b.portee, b.valeur, b.contre), ('ca', valeur, contre),
          reason: nom);
    }
    expect(_depuis('classes.json', 'Bénédiction').optionsBonus,
        ['Arme', 'Armure']);
    expect(
        _depuis('sorts_rang0.json', 'Bouclier mineur')
            .bonusDonnes
            .single
            .portee,
        'ca');
  });
  test('données : Soutien marin (INT cibles), Paroles impies (immobilisation)',
      () {
    final marin = _depuis('classes.json', 'Soutien marin');
    expect((marin.cible, marin.ciblesMax), (CibleCompetence.selection, 'INT'));
    final paroles = _depuis('classes.json', 'Paroles impies');
    expect(paroles.ciblesMax, 'INT');
    final b = paroles.bonusDonnes.single;
    expect((b.portee, b.etat, b.siReussite), ('etat', 'Immobilisation', false));
    expect(paroles.duree!.texte, '1 tour');
    // Une affliction : pas un bonus chiffré, mais un texte.
    final etat = BonusSeance(
      nom: 'Paroles impies',
      valeur: 0,
      portee: PorteeBonus.etat,
      etat: 'Immobilisation',
      cibles: const ['loup'],
      auteur: 'j1',
      auteurNom: 'Pria',
      duree: DureeBonus.tours,
      toursRestants: 1,
      seance: 1,
      date: DateTime(2026),
    );
    expect((etat.estEtat, etat.effet), (true, 'Immobilisation'));
    expect(etat.compte(genre: GenreJet.attaque, d20: true, degats: false),
        isFalse);
  });
  test('données : nombre de cibles au plus (19/11/2026)', () {
    for (final (nom, max) in [
      ('Pissenlit protecteur', 'INT'),
      ('Pistoléro', '2'),
      ('Cercle de protection', 'INT'),
      ('Bourrasque', 'RANG + AdM'),
      ("Chaîne d'éclairs", '4'),
      ('Soin de groupe', 'INT + 1'),
      ('Glas de soutien', 'INT + 1'),
      ('Flèches multiples', '3'),
    ]) {
      final c = _depuis('classes.json', nom);
      expect((c.cible, c.ciblesMax), (CibleCompetence.selection, max),
          reason: nom);
    }
  });
}
