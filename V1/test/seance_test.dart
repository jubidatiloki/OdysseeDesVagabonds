import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/campagnes.dart';
import 'package:odyssee_vagabonds/data/compte.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/data/seance.dart';
import 'package:odyssee_vagabonds/models/campagne.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/creature.dart';
import 'package:odyssee_vagabonds/models/effet.dart';
import 'package:odyssee_vagabonds/models/equipement.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/models/seance.dart';
import 'package:odyssee_vagabonds/regles/des.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/objet_aleatoire.dart';
import 'package:odyssee_vagabonds/screens/campagnes/campagnes_screen.dart';
import 'package:odyssee_vagabonds/screens/campagnes/seance_screen.dart';
import 'package:odyssee_vagabonds/screens/fiche_screen.dart';
import 'package:odyssee_vagabonds/state/campagnes_controller.dart';
import 'package:odyssee_vagabonds/state/compte_controller.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/state/seance_controller.dart';

/// Interface de jeu d'une séance (03/11/2026) : tours par initiative en
/// combat, créatures cachées, jets et leur visibilité, ressources selon les
/// paramètres, notes personnelles.

class _Compte implements ServiceCompte {
  _Compte(this._actuel);

  final Utilisateur? _actuel;

  @override
  bool get disponible => true;
  @override
  Utilisateur? get actuel => _actuel;
  @override
  Stream<Utilisateur?> get changements => const Stream.empty();
  @override
  Future<void> connexionEmail(String email, String motDePasse) async {}
  @override
  Future<void> creerCompte(String email, String motDePasse) async {}
  @override
  Future<void> connexionGoogle() async {}
  @override
  Future<void> motDePasseOublie(String email) async {}
  @override
  Future<void> deconnexion() async {}
  @override
  Future<void> supprimerCompte() async {}
}

const _nain = Race(id: 'nain', nom: 'Nain', deVie: 8, deMana: 4);
const _guerrier = Classe(
  id: 'guerrier',
  nom: 'Guerrier',
  modifDeVie: ModifDe.plus,
  modifDeMana: ModifDe.moins,
);
const _loup = Creature(
  id: 'loup',
  nom: 'Loup',
  famille: 'Bêtes',
  archetype: 'Meute',
  taille: TailleCreature.standard,
  description: 'Un grand loup gris.',
  initiative: 14,
  pv: 12,
  attaques: [
    AttaqueCreature(nom: 'Morsure', toucher: '1d20 +2', degats: '1d6 +1'),
  ],
);

const _referentiel = Referentiel(
  races: [_nain],
  classes: [_guerrier],
  creatures: [_loup],
  equipements: [
    Equipement(
      id: 'epee',
      nom: 'Épée',
      categorie: CategorieEquipement.arme,
      sousCategorie: 'CaC, une main',
      proprietes: {'Dégâts': '1d8 phy'},
    ),
  ],
);

Personnage _brom() =>
    Personnage(id: 'brom', nom: 'Brom', raceId: 'nain', classeId: 'guerrier');

MembreCampagne _membre(String uid, String perso, {int initiative = 10}) =>
    MembreCampagne(
      uid: uid,
      nom: uid,
      personnageId: perso,
      personnageNom: perso,
      personnageResume: 'Nain · Guerrier · niveau 1',
      statut: StatutMembre.accepte,
      date: DateTime(2026, 11, 3),
      initiative: initiative,
    );

CreatureSeance _creature(String id, int init) =>
    CreatureSeance(id: id, nom: id, initiative: init);

/// Campagne avec un MJ et deux joueurs acceptés, séance démarrée.
Future<({BaseCampagnesMemoire base, Campagne campagne})> _partie({
  ParametresCampagne parametres = const ParametresCampagne(),
}) async {
  final base = BaseCampagnesMemoire(Random(2));
  final mj = ServiceCampagnesMemoire(base, 'mj');
  final c = await mj.creer(
    nom: 'Valfroid',
    mjNom: 'Ben',
    prive: const PriveCampagne(script: 'Acte I'),
    parametres: parametres,
  );
  for (final (uid, perso) in [('j1', 'brom'), ('j2', 'aria')]) {
    await ServiceCampagnesMemoire(base, uid)
        .demander(base.campagnes[c.id]!, _membre(uid, perso));
    await mj.accepter(base.campagnes[c.id]!, uid);
  }
  await mj.demarrerSeance(base.campagnes[c.id]!);
  return (base: base, campagne: base.campagnes[c.id]!);
}

void main() {
  group('logs', () {
    JetSeance jet(String detail) => JetSeance(
          auteur: 'a',
          auteurNom: 'A',
          libelle: 'Jet',
          detail: detail,
          total: 0,
          date: DateTime(2026),
          seance: 1,
          lecteurs: const [],
          genre: GenreJet.sort,
        );

    test('dés et bonus ou malus séparés', () {
      expect(jet('3 + 5 +2').decomposition, (des: '3 + 5', modificateur: '+2'));
      expect(jet('7 −1').decomposition, (des: '7', modificateur: '−1'));
      expect(jet('3 + 5').decomposition, (des: '3 + 5', modificateur: ''));
    });

    test('la nature du jet est enregistrée ; ancien jet : jet de dés', () {
      expect(
        JetSeance.depuisJson('1', jet('1').versJson()).genre,
        GenreJet.sort,
      );
      expect(JetSeance.depuisJson('1', const {}).genre, GenreJet.libre);
    });

    test('la famille d\'une créature au nom caché reste cachée', () {
      const p = ParametresCampagne();
      const loup = CreatureSeance(id: 'l', nom: 'Loup', famille: 'Bêtes');
      const cachee = CreatureSeance(
        id: 'l',
        nom: 'Loup',
        famille: 'Bêtes',
        nomCache: true,
      );
      expect(loup.versPublic(p)['famille'], 'Bêtes');
      expect(loup.pourJoueur(p).famille, 'Bêtes');
      expect(cachee.versPublic(p).containsKey('famille'), isFalse);
      expect(cachee.pourJoueur(p).famille, '');
      // Le MJ la garde.
      expect(
        CreatureSeance.depuisDocuments(
          'l',
          cachee.versPublic(p),
          cachee.versMj(),
        ).famille,
        'Bêtes',
      );
    });
  });

  group('combat et infos', () {
    test('le lieu et les montées survivent aux tours et aux modes', () {
      const e = EtatJeu(lieu: 'Taverne', montees: {'j1': 2});
      final combat = e.commencerCombat(['j1', 'l']);
      expect(combat.enCombat, isTrue);
      expect(combat.suivant().lieu, 'Taverne');
      expect(combat.suivant().precedent().montees, {'j1': 2});
      expect(combat.avecOrdre(['l']).lieu, 'Taverne');
      final fin = combat.enExploration();
      expect(fin.enCombat, isFalse);
      expect(fin.lieu, 'Taverne');
      final lu = EtatJeu.depuisJson(e.versJson());
      expect(lu.lieu, 'Taverne');
      expect(lu.peutMonter('j1', 1), isTrue);
      expect(lu.peutMonter('j1', 2), isFalse);
      expect(lu.peutMonter('j2', 1), isFalse);
    });

    test('attaque contre la CA : total ≥ CA, 20 et 1 naturels', () {
      expect(attaqueTouche(naturel: 10, total: 14, ca: 14), isTrue);
      expect(attaqueTouche(naturel: 10, total: 13, ca: 14), isFalse);
      expect(attaqueTouche(naturel: 20, total: 20, ca: 30), isTrue);
      expect(attaqueTouche(naturel: 1, total: 25, ca: 14), isFalse);
    });

    test('objet aléatoire : arme ou protection avec un bonus de +1 à +3', () {
      const catalogue = [
        Equipement(
          id: 'epee',
          nom: 'Épée',
          categorie: CategorieEquipement.arme,
          sousCategorie: 'CaC, une main',
          proprietes: {'Dégâts': '1d8 phy'},
        ),
        Equipement(
          id: 'cuir',
          nom: 'Cuir',
          categorie: CategorieEquipement.armure,
          proprietes: {'CA': '+2'},
        ),
        Equipement(
          id: 'potion',
          nom: 'Potion',
          categorie: CategorieEquipement.consommable,
        ),
      ];
      final r = Random(3);
      final vus = <String>{};
      for (var i = 0; i < 200; i++) {
        final o = tirerObjetAleatoire(catalogue, r)!;
        expect(o.nom, isNot('Potion'));
        expect(o.personnalise, isTrue);
        if (o.categorie.protection) {
          expect(o.bonusCA, inInclusiveRange(3, 5));
          vus.add('ca');
        } else if (o.element.isNotEmpty) {
          expect(['feu', 'glace', 'foudre'], contains(o.element));
          vus.add('element');
        } else if (o.affliction.isNotEmpty) {
          vus.add('affliction');
        } else {
          final e = o.effets.single;
          expect(int.parse(e.valeur), inInclusiveRange(1, 3));
          vus.add(e.type);
        }
      }
      expect(vus, {'ca', 'element', 'affliction', 'toucher', 'degats'});
      expect(tirerObjetAleatoire(const [], r), isNull);
    });

    test('les joueurs lisent les récaps, seul le MJ les écrit', () async {
      final p = await _partie();
      final mj = ServiceCampagnesMemoire(p.base, 'mj');
      final j1 = ServiceCampagnesMemoire(p.base, 'j1');
      await mj.ecrireRecap(p.campagne.id, 1, 'Le pont est tombé.');
      expect(await j1.lireRecaps(p.campagne.id), {1: 'Le pont est tombé.'});
      await expectLater(
        j1.ecrireRecap(p.campagne.id, 1, 'Non'),
        throwsA(isA<ErreurCampagne>()),
      );
    });
  });

  group('tours', () {
    test('initiative décroissante ; à égalité, les PJ d\'abord', () {
      expect(
        ordreCombat(
          [_membre('j1', 'Brom', initiative: 12), _membre('j2', 'Aria')],
          [_creature('loup', 12), _creature('rat', 3)],
        ),
        ['j1', 'loup', 'j2', 'rat'],
      );
    });

    test('suivant, précédent, manches', () {
      var e = const EtatJeu(mode: ModeJeu.combat, ordre: ['a', 'b']);
      expect(e.actif, 'a');
      expect(e.precedent().index, 0); // rien avant le premier tour
      e = e.suivant().suivant();
      expect((e.actif, e.manche), ('a', 2));
      e = e.precedent();
      expect((e.actif, e.manche), ('b', 1));
      expect(const EtatJeu(ordre: ['a']).actif, isNull); // pas en exploration
    });

    test('ordre recalculé : le tour reste à celui qui joue', () {
      const e = EtatJeu(mode: ModeJeu.combat, ordre: ['a', 'b', 'c'], index: 1);
      expect(e.avecOrdre(['z', 'a', 'b', 'c']).actif, 'b');
      expect(e.avecOrdre(['a', 'c']).actif, 'c'); // b retiré : au suivant
    });

    test('un PJ ne passe que son tour, le MJ tous ; retour MJ seul', () async {
      final p = await _partie();
      final c = p.campagne;
      final mj = ServiceCampagnesMemoire(p.base, 'mj').seance;
      final j1 = ServiceCampagnesMemoire(p.base, 'j1').seance;
      final j2 = ServiceCampagnesMemoire(p.base, 'j2').seance;
      await expectLater(
          j1.demarrerCombat(c, const []), throwsA(isA<ErreurCampagne>()));
      await mj.demarrerCombat(c, ['j1', 'j2']);
      await expectLater(j2.passerTour(c), throwsA(isA<ErreurCampagne>()));
      await j1.passerTour(c);
      expect(p.base.parties[c.id]!.etat.actif, 'j2');
      await expectLater(j2.tourPrecedent(c), throwsA(isA<ErreurCampagne>()));
      await mj.tourPrecedent(c);
      expect(p.base.parties[c.id]!.etat.actif, 'j1');
      await mj.passerEnExploration(c);
      expect(p.base.parties[c.id]!.etat.enCombat, isFalse);
    });
  });

  group('créatures', () {
    test('état approximatif selon les PV ; noms numérotés', () {
      expect(EtatCreature.depuisPv(12, 12), EtatCreature.indemne);
      expect(EtatCreature.depuisPv(4, 12), EtatCreature.blessee);
      expect(EtatCreature.depuisPv(3, 12), EtatCreature.gravement);
      expect(EtatCreature.depuisPv(0, 12), EtatCreature.vaincue);
      expect(nomNumerote('Loup', ['Rat']), 'Loup');
      expect(nomNumerote('Loup', ['Loup', 'Loup 2']), 'Loup 3');
    });

    test('un PJ ne reçoit ni carte cachée, ni vrai nom, ni PV', () async {
      final p = await _partie();
      final c = p.campagne;
      final mj = ServiceCampagnesMemoire(p.base, 'mj').seance;
      final j1 = ServiceCampagnesMemoire(p.base, 'j1').seance;
      await mj.ajouterCreature(
          c, const CreatureSeance(id: 'a', nom: 'Ombre', cachee: true));
      await mj.ajouterCreature(
        c,
        const CreatureSeance(
            id: 'b', nom: 'Liche', nomCache: true, pv: 40, pvMax: 40),
      );
      expect(await mj.ecouterCreatures(c).first, hasLength(2));
      final vues = await j1.ecouterCreatures(c).first;
      expect(vues.single.nom, CreatureSeance.nomInconnu);
      expect(vues.single.pv, isNull);
      expect(vues.single.creatureId, isEmpty);
      // Partie publique en ligne : ni vrai nom, ni PV.
      const liche = CreatureSeance(
          id: 'b', nom: 'Liche', nomCache: true, pv: 40, pvMax: 40);
      expect(liche.versPublic(const ParametresCampagne())['nom'],
          CreatureSeance.nomInconnu);
      expect(liche.versPublic(const ParametresCampagne()).containsKey('pv'),
          isFalse);
      await expectLater(
          j1.retirerCreature(c, 'a'), throwsA(isA<ErreurCampagne>()));
    });
  });

  test('jets : chacun ne lit que ceux dont il est lecteur', () async {
    final p = await _partie();
    final c = p.campagne;
    final mj = ServiceCampagnesMemoire(p.base, 'mj').seance;
    final j1 = ServiceCampagnesMemoire(p.base, 'j1').seance;
    final j2 = ServiceCampagnesMemoire(p.base, 'j2').seance;
    JetSeance jet(String auteur, VisibiliteJet v, {String? cible}) => JetSeance(
          auteur: auteur,
          auteurNom: auteur,
          libelle: '1d20',
          detail: '12',
          total: 12,
          date: DateTime(2026, 11, 3),
          seance: 1,
          visibilite: v,
          lecteurs: lecteursDuJet(c, v, auteur: auteur, cible: cible),
        );
    Future<List<int>> vus() async => [
          for (final s in <ServiceSeance>[mj, j1, j2])
            (await s.ecouterJets(c, 1).first).length,
        ];

    await j1.lancer(c, jet('j1', VisibiliteJet.tous));
    expect(await vus(), [1, 1, 1]);
    // PJ : caché aux autres joueurs.
    await j1.lancer(c, jet('j1', VisibiliteJet.mjEtAuteur));
    expect(await vus(), [2, 2, 1]);
    // PJ : caché pour lui aussi, le MJ seul le voit.
    await j1.lancer(c, jet('j1', VisibiliteJet.mjSeul));
    expect(await vus(), [3, 2, 1]);
    // MJ : visible d'un seul PJ.
    await mj.lancer(c, jet('mj', VisibiliteJet.unJoueur, cible: 'j2'));
    expect(await vus(), [4, 2, 2]);
  });

  group('ressources', () {
    const r = RessourcesPj(pv: 9, pvMax: 13, pe: 3, peMax: 6);

    Future<void> publier(BaseCampagnesMemoire b, Campagne c) =>
        ServiceCampagnesMemoire(b, 'j1')
            .seance
            .publierPersonnage(c, r, resume: 'x', initiative: 11);

    test('fiches non partagées entre joueurs : PV, PM, PE cachés', () async {
      final p = await _partie();
      await publier(p.base, p.campagne);
      Future<Map<String, RessourcesPj>> vues(String uid) =>
          ServiceCampagnesMemoire(p.base, uid)
              .seance
              .ecouterRessources(p.campagne)
              .first;
      expect((await vues('mj'))['j1'], r);
      expect((await vues('j1'))['j1'], r);
      expect(await vues('j2'), isEmpty);
      expect(p.base.membres[p.campagne.id]!['j1']!.initiative, 11);
    });

    test('fiches partagées entre joueurs : visibles ; MJ selon le paramètre',
        () async {
      final p = await _partie(
        parametres: const ParametresCampagne(
          fichesVisiblesMj: false,
          pjVoientRessources: true,
        ),
      );
      await publier(p.base, p.campagne);
      Future<Map<String, RessourcesPj>> vues(String uid) =>
          ServiceCampagnesMemoire(p.base, uid)
              .seance
              .ecouterRessources(p.campagne)
              .first;
      expect((await vues('j2'))['j1'], r);
      expect(await vues('mj'), isEmpty);
    });
  });

  test('notes de séance : propres au joueur et à la séance', () async {
    final p = await _partie();
    final c = p.campagne;
    final j1 = ServiceCampagnesMemoire(p.base, 'j1').seance;
    final j2 = ServiceCampagnesMemoire(p.base, 'j2').seance;
    await j1.ecrireNote(c, 1, 'Se méfier du maire');
    expect(await j1.lireNote(c, 1), 'Se méfier du maire');
    expect(await j1.lireNote(c, 2), isEmpty);
    expect(await j2.lireNote(c, 1), isEmpty);
  });

  test('contrôleur : ressources et résumé publiés par le joueur', () async {
    final p = await _partie();
    final personnages = PersonnagesController(
      EnMemoirePersonnageRepository([_brom()]),
    );
    await personnages.charger();
    final compte = CompteController(
      service: _Compte(const Utilisateur(uid: 'j1')),
      personnages: personnages,
      local: personnages.repository,
      depotEnLigne: (_) => EnMemoireDepotEnLigne([_brom()]),
    );
    await compte.demarrer();
    final campagnes = CampagnesController(
      compte: compte,
      service: (u) => ServiceCampagnesMemoire(p.base, u.uid),
    );
    await pumpEventQueue();
    final s = SeanceController(
      campagnes: campagnes,
      personnages: personnages,
      referentiel: _referentiel,
      campagneId: p.campagne.id,
    );
    await pumpEventQueue();
    final r = p.base.parties[p.campagne.id]!.ressources['j1'];
    expect(r?.peMax, 6);
    expect(r?.pmMax, 0);
    expect(p.base.membres[p.campagne.id]!['j1']!.personnageResume,
        'Nain · Guerrier · niveau 1');
    // Sort d'une classe sans mana : payé en PE sur la fiche du joueur.
    await s.depenserSort(s.maFiche!, 'Cri sauvage', 3);
    expect(s.maFiche!.peActuels, 3);
    // Cibles : pas soi-même ; une carte cachée ne figure pas dans le jet.
    expect(s.cibles.map((c) => c.id), ['j2']);
    expect(s.nomCible('j2', VisibiliteJet.tous), 'aria');
    // Une créature arrive : cible par défaut d'un PJ.
    await ServiceCampagnesMemoire(p.base, 'mj')
        .seance
        .ajouterCreature(p.campagne, _creature('rat', 3));
    await pumpEventQueue();
    expect(s.cibles.first.id, 'rat');
    s.dispose();
    campagnes.dispose();
    compte.dispose();
    personnages.dispose();
  });
  test('messages : conversation privée entre le MJ et un joueur', () async {
    final p = await _partie();
    final c = p.campagne;
    final mj = ServiceCampagnesMemoire(p.base, 'mj').seance;
    final j1 = ServiceCampagnesMemoire(p.base, 'j1').seance;
    final j2 = ServiceCampagnesMemoire(p.base, 'j2').seance;
    await j1.envoyerMessage(
      c,
      MessageSeance(
        de: 'j1',
        joueur: 'j1',
        mj: 'mj',
        texte: 'Je trahis le groupe',
        date: DateTime(2026, 11, 4),
      ),
    );
    expect(await mj.ecouterMessages(c).first, hasLength(1));
    expect(await j1.ecouterMessages(c).first, hasLength(1));
    expect(await j2.ecouterMessages(c).first, isEmpty);
    expect(
      MessageSeance.depuisJson(
              'x', (await j1.ecouterMessages(c).first).single.versJson())
          .texte,
      'Je trahis le groupe',
    );
  });

  group('types de dégâts', () {
    test('physique par défaut, sinon le type écrit', () {
      expect(typeDegatsDepuis('1d6 +2'), 'physique');
      expect(typeDegatsDepuis('3d6 feu (à qui le traverse)'), 'feu');
      expect(typeDegatsDepuis('5d6 mag'), 'magique');
      expect(typeDegatsDepuis('1d8 chaos (×2 contre morts-vivants)'), 'chaos');
    });

    test('tous les sorts à dégâts ont un type', () {
      final classes = jsonDecode(
        File('assets/data/classes.json').readAsStringSync(),
      ) as List;
      var n = 0;
      for (final c in classes.map((e) => Classe.depuisJson(e))) {
        for (final k in c.voies.expand((v) => v.competences)) {
          if (k.degats.isEmpty) continue;
          n++;
          expect(k.typeDegats, isNotEmpty, reason: k.nom);
        }
      }
      expect(n, 17);
    });

    test('RD selon le type, le chaos l\'ignore', () {
      final race = Race(
        id: 'r',
        nom: 'R',
        deVie: 8,
        deMana: 4,
        passif: Passif(
          nom: 'Écailles',
          description: '',
          effets: Effet.listeDepuisJson([
            {'type': 'bonus', 'categorie': 'RD feu', 'valeur': '2'},
          ]),
        ),
      );
      final f = FicheCalculee(
        personnage: _brom(),
        race: race,
        classe: _guerrier,
      );
      expect(f.rdContre('feu'), 2);
      expect(f.rdContre('physique'), 0);
      expect(f.rdContre('chaos'), 0);
    });
  });

  group('permissions', () {
    test('créatures : PV et fiche selon les permissions, nom caché prioritaire',
        () {
      const loup = CreatureSeance(
        id: 'a',
        nom: 'Loup',
        creatureId: 'loup',
        pv: 8,
        pvMax: 12,
      );
      const rien = ParametresCampagne();
      const tout = ParametresCampagne(
        pjVoientPvCreatures: true,
        pjVoientFichesCreatures: true,
      );
      expect(loup.pourJoueur(rien).pv, isNull);
      expect(loup.pourJoueur(rien).creatureId, isEmpty);
      expect(loup.pourJoueur(tout).pv, 8);
      expect(loup.pourJoueur(tout).creatureId, 'loup');
      expect(loup.versPublic(rien).containsKey('pv'), isFalse);
      expect(loup.versPublic(tout)['pv'], 8);
      // Nom caché : la fiche le révélerait.
      final cache = loup.copie(nomCache: true);
      expect(cache.pourJoueur(tout).creatureId, isEmpty);
      expect(cache.versPublic(tout).containsKey('creatureId'), isFalse);
    });

    test('inventaire et compétences verrouillés hors séance seulement',
        () async {
      final p = await _partie(
        parametres: const ParametresCampagne(
          pjInventaireHorsSeance: false,
          pjCompetencesHorsSeance: false,
        ),
      );
      final personnages = PersonnagesController(
        EnMemoirePersonnageRepository([_brom()]),
      );
      await personnages.charger();
      final compte = CompteController(
        service: _Compte(const Utilisateur(uid: 'j1')),
        personnages: personnages,
        local: personnages.repository,
        depotEnLigne: (_) => EnMemoireDepotEnLigne([_brom()]),
      );
      await compte.demarrer();
      final campagnes = CampagnesController(
        compte: compte,
        service: (u) => ServiceCampagnesMemoire(p.base, u.uid),
      );
      await pumpEventQueue();
      // Séance en cours : rien de verrouillé.
      expect(personnages.restrictionsDe('brom').inventaire, isFalse);
      await ServiceCampagnesMemoire(p.base, 'mj')
          .terminerSeance(p.base.campagnes[p.campagne.id]!);
      await pumpEventQueue();
      expect(personnages.restrictionsDe('brom').inventaire, isTrue);
      expect(personnages.restrictionsDe('brom').competences, isTrue);
      expect(personnages.restrictionsDe('autre').inventaire, isFalse);
      campagnes.dispose();
      compte.dispose();
      personnages.dispose();
    });

    test('le MJ modifie une fiche que le joueur lui a ouverte', () async {
      final p = await _partie();
      final brom = _brom();
      p.base.fiches['brom'] = (
        fiche: brom,
        proprietaire: 'j1',
        partage: ['mj'],
        editeurs: <String>[],
      );
      final mj = ServiceCampagnesMemoire(p.base, 'mj');
      await expectLater(mj.ecrireFiche(brom), throwsA(isA<ErreurCampagne>()));
      await ServiceCampagnesMemoire(p.base, 'j1')
          .partagerFiche('brom', ['mj'], editeurs: ['mj']);
      await mj.ecrireFiche(brom..pvActuels = 3);
      expect(p.base.fiches['brom']!.fiche.pvActuels, 3);
      expect(p.base.fiches['brom']!.proprietaire, 'j1');
    });
  });

  test('présence : absent sans nouvelle depuis 2 minutes', () {
    final t = DateTime(2026, 11, 4, 12);
    final p = PresenceSeance(vu: t);
    expect(p.estLa(t.add(const Duration(seconds: 100))), isTrue);
    expect(p.estLa(t.add(const Duration(minutes: 3))), isFalse);
    expect(PresenceSeance(vu: t, present: false).estLa(t), isFalse);
  });

  group('écran', () {
    Future<({BaseCampagnesMemoire base, Campagne campagne})> ouvrir(
      WidgetTester tester,
      String uid, {
      Size taille = const Size(1400, 1000),
      List<Personnage> fiches = const [],
      Future<void> Function(BaseCampagnesMemoire, Campagne)? avant,
    }) async {
      tester.view.physicalSize = taille;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final p = await _partie();
      await avant?.call(p.base, p.campagne);
      final personnages = PersonnagesController(
        EnMemoirePersonnageRepository(),
      );
      await personnages.charger();
      final compte = CompteController(
        service: _Compte(Utilisateur(uid: uid, nom: uid)),
        personnages: personnages,
        local: personnages.repository,
        depotEnLigne: (_) => EnMemoireDepotEnLigne(fiches),
      );
      await compte.demarrer();
      final campagnes = CampagnesController(
        compte: compte,
        service: (u) => ServiceCampagnesMemoire(p.base, u.uid),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(MaterialApp(
        home: SeanceScreen(
          contexte: ContexteCampagnes(
            campagnes: campagnes,
            personnages: personnages,
            referentiel: _referentiel,
          ),
          campagneId: p.campagne.id,
          aleatoire: Random(1),
        ),
      ));
      await tester.pumpAndSettle();
      return p;
    }

    // Pas de ensureVisible ici : il ferait défiler les onglets de la séance.
    Future<void> tap(WidgetTester tester, Finder f) async {
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    testWidgets('MJ : navigation, créature ajoutée, combat', (tester) async {
      final x = await ouvrir(tester, 'mj');
      expect(find.byKey(const Key('seance-creatures')), findsOneWidget);
      expect(find.byKey(const Key('carte-script')), findsOneWidget);
      expect(find.byKey(const Key('carte-notes')), findsNothing);
      expect(find.byKey(const Key('carte-j1')), findsOneWidget);
      expect(find.byKey(const Key('passer-tour')), findsNothing);

      // Onglet Créatures : ajout avec le nom caché.
      await tap(tester, find.byKey(const Key('seance-creatures')));
      // Le bestiaire s'ouvre au centre : cartes et dés restent visibles.
      expect(find.byKey(const Key('liste-cartes')), findsOneWidget);
      expect(find.byKey(const Key('lancer-seance')), findsOneWidget);
      await tap(tester, find.text('Loup'));
      expect(find.text('Un grand loup gris.'), findsOneWidget);
      await tap(tester, find.byKey(const Key('ajouter-loup')));
      await tap(tester, find.byKey(const Key('ajout-nom-cache')));
      await tap(tester, find.byKey(const Key('confirmer-ajout')));
      final partie = x.base.parties[x.campagne.id]!;
      final loup = partie.creatures.values.single;
      expect((loup.nom, loup.nomCache, loup.pv), ('Loup', true, 12));
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // La carte s'affiche sous les PJ, avec sa croix rouge.
      await tap(tester, find.byKey(const Key('seance-tableau')));
      final carte = find.byKey(Key('carte-${loup.id}'));
      expect(carte, findsOneWidget);
      expect(tester.getTopLeft(carte).dy,
          greaterThan(tester.getTopLeft(find.byKey(const Key('carte-j2'))).dy));
      await tap(tester, carte);
      await tap(tester, find.byKey(const Key('creature-pv-moins')));
      expect(partie.creatures[loup.id]!.pv, 11);

      // Créature sélectionnée : ses attaques dans le lancer de dés.
      await tap(tester, find.byKey(const Key('attaque-0')));
      expect(partie.jets.single.libelle, 'Morsure · toucher');
      // Jet visible des PJ et nom caché : le vrai nom n'y figure pas.
      expect(partie.jets.single.auteurNom, CreatureSeance.nomInconnu);
      await tap(tester, find.byKey(const Key('attaque-1')));
      expect(partie.jets.last.libelle, 'Morsure · dégâts');
      // Nom montré aux PJ : la créature dans l'historique, pas « MJ ».
      await tap(tester, find.byKey(const Key('creature-nom-cache')));
      await tap(tester, find.byKey(const Key('attaque-0')));
      expect(partie.jets.last.auteurNom, 'Loup');
      await tap(tester, find.byKey(const Key('creature-nom-cache')));

      // Combat : le loup (14) passe avant les PJ (0), retour possible.
      await tap(tester, find.byKey(const Key('basculer-mode')));
      // En combat, l'initiative s'affiche sur les cartes.
      expect(find.byKey(Key('carte-${loup.id}-initiative')), findsOneWidget);
      expect(find.byKey(const Key('carte-j1-initiative')), findsOneWidget);
      expect(partie.etat.enCombat, isTrue);
      expect(partie.etat.actif, loup.id);
      // La carte de celui qui joue ressort en couleur.
      expect(find.byKey(Key('carte-${loup.id}-tour')), findsOneWidget);
      expect(find.byKey(const Key('carte-j1-tour')), findsNothing);
      await tap(tester, find.byKey(const Key('passer-tour')));
      expect(partie.etat.index, 1);
      await tap(tester, find.byKey(const Key('tour-precedent')));
      expect(partie.etat.index, 0);

      // Croix rouge : retirée de la partie et de l'ordre.
      await tap(tester, find.byKey(Key('retirer-${loup.id}')));
      expect(partie.creatures, isEmpty);
      expect(partie.etat.ordre, isNot(contains(loup.id)));
    });

    testWidgets('MJ : jet visible par un seul PJ', (tester) async {
      final x = await ouvrir(tester, 'mj');
      await tap(tester, find.byKey(const Key('visibilite-jet')));
      await tap(tester, find.text('Visible par un seul joueur').last);
      // Sans joueur choisi : pas de lancer.
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('lancer-seance')))
            .onPressed,
        isNull,
      );
      await tap(tester, find.byKey(const Key('cible-jet')));
      await tap(tester, find.text('aria').last);
      await tap(tester, find.byKey(const Key('lancer-seance')));
      final j = x.base.parties[x.campagne.id]!.jets.single;
      expect(j.lecteurs, unorderedEquals(['mj', 'j2']));
      await tap(tester, find.byKey(const Key('onglet-historique')));
      expect(find.byKey(const Key('historique-seance')), findsOneWidget);
    });

    testWidgets('PJ : pas de Créatures, notes, carte cachée invisible, tour',
        (tester) async {
      final x = await ouvrir(
        tester,
        'j1',
        fiches: [_brom()],
        avant: (b, c) async {
          final mj = ServiceCampagnesMemoire(b, 'mj').seance;
          await mj.ajouterCreature(
              c, const CreatureSeance(id: 'a', nom: 'Ombre', cachee: true));
          await mj.ajouterCreature(
            c,
            const CreatureSeance(
              id: 'b',
              nom: 'Liche',
              nomCache: true,
              description: 'Une silhouette décharnée.',
              pv: 3,
              pvMax: 40,
              etat: EtatCreature.gravement,
            ),
          );
          await mj.demarrerCombat(c, ['j1', 'a', 'b']);
        },
      );
      expect(find.byKey(const Key('seance-creatures')), findsNothing);
      expect(find.byKey(const Key('carte-script')), findsNothing);
      expect(find.byKey(const Key('basculer-mode')), findsNothing);
      expect(find.byKey(const Key('tour-precedent')), findsNothing);
      expect(find.byKey(const Key('carte-a')), findsNothing);

      // Nom caché : « Créature inconnue », état sans PV.
      await tap(tester, find.byKey(const Key('carte-b')));
      // Carte, détail et liste des cibles.
      expect(find.text(CreatureSeance.nomInconnu), findsNWidgets(3));
      expect(find.text('Liche'), findsNothing);
      expect(find.textContaining('PV 3'), findsNothing);
      expect(find.byKey(const Key('creature-etat')), findsOneWidget);
      expect(find.byKey(const Key('retirer-b')), findsNothing);

      // Notes personnelles de la séance.
      await tap(tester, find.byKey(const Key('carte-notes')));
      await tester.enterText(
          find.byKey(const Key('texte-seance')), 'Se méfier du maire');
      await tap(tester, find.byKey(const Key('enregistrer-texte-seance')));
      final partie = x.base.parties[x.campagne.id]!;
      expect(partie.notes['j1/1'], 'Se méfier du maire');
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Jet caché pour le joueur aussi : le résultat ne s'affiche pas.
      await tap(tester, find.byKey(const Key('visibilite-jet')));
      await tap(tester, find.text('Caché pour moi aussi (MJ seul)').last);
      await tap(tester, find.byKey(const Key('test-seance-FOR')));
      expect(partie.jets.single.lecteurs, ['mj']);
      expect(find.text('Jet envoyé au MJ : résultat caché.'), findsOneWidget);

      // C'est son tour : il le passe ; la carte cachée joue → « MJ ».
      expect(find.text('Manche 1 · À toi de jouer'), findsOneWidget);
      await tap(tester, find.byKey(const Key('passer-tour')));
      expect(partie.etat.actif, 'a');
      expect(find.text('Manche 1 · Tour : MJ'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('passer-tour')))
            .onPressed,
        isNull,
      );
    });
    testWidgets('dégâts : retirés des PV de la créature ciblée',
        (tester) async {
      final x = await ouvrir(
        tester,
        'mj',
        avant: (b, c) =>
            ServiceCampagnesMemoire(b, 'mj').seance.ajouterCreature(
                  c,
                  const CreatureSeance(
                    id: 'l',
                    nom: 'Loup',
                    creatureId: 'loup',
                    pv: 12,
                    pvMax: 12,
                  ),
                ),
      );
      final partie = x.base.parties[x.campagne.id]!;
      // Créature sélectionnée : sa cible par défaut est le premier PJ.
      await tap(tester, find.byKey(const Key('carte-l')));
      await tap(tester, find.byKey(const Key('attaque-0')));
      expect(partie.jets.last.cible, 'brom');
      // Un joueur frappe le loup : le MJ applique les dégâts.
      await ServiceCampagnesMemoire(x.base, 'j1').seance.envoyerDegats(
            x.campagne,
            const DegatsSeance(
              cible: 'l',
              destinataire: 'mj',
              auteur: 'j1',
              montant: 5,
              source: 'Brom · Dégâts',
            ),
          );
      await tester.pumpAndSettle();
      expect(partie.creatures['l']!.pv, 7);
      expect(partie.degats, isEmpty);
      expect(find.text('7/12'), findsOneWidget);
    });

    testWidgets('MJ : Glossaire, Séances précédentes, cadre de mode',
        (tester) async {
      final x = await ouvrir(tester, 'mj');
      expect(find.byKey(const Key('cadre-exploration')), findsOneWidget);
      await tap(tester, find.byKey(const Key('basculer-mode')));
      expect(find.byKey(const Key('cadre-combat')), findsOneWidget);
      await tap(tester, find.byKey(const Key('seance-glossaire')));
      expect(find.byKey(const Key('onglet-glossaire-classes')), findsOneWidget);
      // Cartes et dés restent visibles.
      expect(find.byKey(const Key('liste-cartes')), findsOneWidget);
      await tap(tester, find.byKey(const Key('seance-recaps')));
      await tester.enterText(
          find.byKey(const Key('recap-1')), 'La brume est tombée.');
      await tap(tester, find.byKey(const Key('enregistrer-recap-1')));
      expect(x.base.recaps[x.campagne.id]![1], 'La brume est tombée.');
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('messagerie : le PJ écrit au MJ, paramètres en consultation',
        (tester) async {
      final x = await ouvrir(tester, 'j1', fiches: [_brom()]);
      await tap(tester, find.byKey(const Key('onglet-messages')));
      await tester.enterText(
          find.byKey(const Key('message-texte')), 'Bonjour MJ');
      await tap(tester, find.byKey(const Key('message-envoyer')));
      final m = x.base.parties[x.campagne.id]!.messages.single;
      expect((m.de, m.joueur, m.mj), ('j1', 'j1', 'mj'));
      expect(find.text('Bonjour MJ'), findsOneWidget);
      await tap(tester, find.byKey(const Key('seance-parametres')));
      expect(find.byKey(const Key('resume-parametres')), findsOneWidget);
      expect(find.byKey(const Key('pj-voient-ressources')), findsNothing);
    });

    testWidgets('dégâts reçus : retirés de la fiche du joueur, carte à jour',
        (tester) async {
      final x = await ouvrir(tester, 'j1', fiches: [_brom()]);
      expect(find.text('6/6'), findsOneWidget); // PE
      await ServiceCampagnesMemoire(x.base, 'mj').seance.envoyerDegats(
            x.campagne,
            const DegatsSeance(
              cible: 'j1',
              destinataire: 'j1',
              auteur: 'mj',
              montant: 3,
              source: 'Loup · Morsure · dégâts',
            ),
          );
      await tester.pumpAndSettle();
      expect(x.base.parties[x.campagne.id]!.degats, isEmpty);
      // Nain guerrier : 10 PV − 3, sur la carte comme pour les autres.
      expect(find.text('7/10'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(x.base.parties[x.campagne.id]!.ressources['j1']!.pv, 7);
    });

    testWidgets('présence : icône sur la carte du joueur absent',
        (tester) async {
      final x = await ouvrir(tester, 'mj');
      expect(find.byKey(const Key('carte-j1-absent')), findsOneWidget);
      await ServiceCampagnesMemoire(x.base, 'j1')
          .seance
          .signalerPresence(x.campagne, present: true);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('carte-j1-absent')), findsNothing);
      expect(find.byKey(const Key('carte-j2-absent')), findsOneWidget);
      await ServiceCampagnesMemoire(x.base, 'j1')
          .seance
          .signalerPresence(x.campagne, present: false);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('carte-j1-absent')), findsOneWidget);
    });

    testWidgets('présence : le joueur se signale, et part en quittant',
        (tester) async {
      final x = await ouvrir(tester, 'j1', fiches: [_brom()]);
      final presences = x.base.parties[x.campagne.id]!.presences;
      expect(presences['j1']?.present, isTrue);
      expect(find.byKey(const Key('carte-j1-absent')), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(presences['j1']?.present, isFalse);
    });

    testWidgets('PJ : sa fiche complète au centre et ses attaques',
        (tester) async {
      final partie = await ouvrir(tester, 'j1', fiches: [_brom()]);
      JetSeance dernierJet() =>
          partie.base.parties[partie.campagne.id]!.jets.last;
      await tap(tester, find.byKey(const Key('carte-j1')));
      expect(find.byKey(const Key('vue-fiche')), findsOneWidget);
      await tap(tester, find.byKey(const Key('vue-competences')));
      expect(find.byKey(const Key('points-disponibles')), findsOneWidget);
      await tap(tester, find.byKey(const Key('vue-inventaire')));
      expect(find.byKey(const Key('attaque-0')), findsOneWidget);
      expect(find.textContaining('Toucher CaC'), findsOneWidget);
      // Bouton pour quitter en haut à droite.
      expect(find.byKey(const Key('quitter-seance')), findsOneWidget);
      // Attaque : cible par défaut, un autre que soi, notée dans l'historique.
      await tap(tester, find.byKey(const Key('attaque-0')));
      final x = dernierJet();
      expect(x.cible, 'aria');
      expect(x.auteurNom, 'Brom');
      await tap(tester, find.byKey(const Key('onglet-historique')));
      expect(find.textContaining('→ aria'), findsOneWidget);
      // Logs : nature du jet en icône, résultat final mis en avant.
      expect(find.text('Logs'), findsOneWidget);
      expect(x.genre, GenreJet.attaque);
      expect(find.byKey(const Key('genre-attaque')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(Key('total-jet-${x.id}')),
          matching: find.text('${x.total}'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('en-tête : le MJ définit le lieu, le mode ressort',
        (tester) async {
      final x = await ouvrir(tester, 'mj');
      expect(find.text('Lieu à définir'), findsOneWidget);
      await tap(tester, find.byKey(const Key('modifier-lieu')));
      await tester.enterText(find.byKey(const Key('champ-lieu')), 'Taverne');
      await tap(tester, find.byKey(const Key('valider-lieu')));
      expect(x.base.parties[x.campagne.id]!.etat.lieu, 'Taverne');
      expect(find.text('Taverne'), findsOneWidget);
      expect(find.byKey(const Key('menu-droite')), findsOneWidget);
      await tap(tester, find.byKey(const Key('basculer-mode')));
      expect(tester.widget<Text>(find.byKey(const Key('mode-jeu'))).data,
          'Combat');
      expect(find.text('Taverne'), findsOneWidget);
    });

    testWidgets('PJ : boutons de dés regroupés, sans jet libre',
        (tester) async {
      await ouvrir(tester, 'j1', fiches: [_brom()]);
      for (final k in ['lancer-seance', 'nombre-des', 'de-20']) {
        expect(find.byKey(Key(k)), findsNothing);
      }
      expect(find.byKey(const PageStorageKey('groupe-combat')), findsOneWidget);
      expect(find.byKey(const Key('test-seance-FOR')), findsOneWidget);
      await tester.drag(
        find.byKey(const PageStorageKey('groupe-stats')),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const PageStorageKey('groupe-aptitudes')),
        findsOneWidget,
      );
    });

    testWidgets('attaque : comparée à la CA, alerte à la deuxième, logs',
        (tester) async {
      final x = await ouvrir(
        tester,
        'j1',
        fiches: [_brom()],
        avant: (b, c) async {
          final mj = ServiceCampagnesMemoire(b, 'mj').seance;
          await mj.ajouterCreature(
            c,
            const CreatureSeance(id: 'l', nom: 'Loup', ca: 14),
          );
          await mj.demarrerCombat(c, ['j1', 'l']);
        },
      );
      final partie = x.base.parties[x.campagne.id]!;
      await tap(tester, find.byKey(const Key('attaque-0')));
      final j = partie.jets.last;
      expect(j.caCible, 14);
      expect(j.touche, isNotNull);
      expect(j.attaquant, 'j1');
      expect(j.mode, ModeJeu.combat);
      expect(find.byKey(const Key('alerte-attaque')), findsNothing);
      await tap(tester, find.byKey(const Key('attaque-0')));
      // Simple alerte : le jet est quand même lancé.
      expect(find.byKey(const Key('alerte-attaque')), findsOneWidget);
      expect(partie.jets.length, 2);

      await tap(tester, find.byKey(const Key('onglet-historique')));
      expect(find.byKey(const Key('logs-combat')), findsOneWidget);
      expect(find.byKey(Key('touche-jet-${j.id}')), findsNWidgets(2));
      expect(find.text(j.resultatCible), findsWidgets);
      final h = j.date.hour.toString().padLeft(2, '0');
      expect(find.textContaining('$h:', findRichText: true), findsWidgets);
    });

    testWidgets('montée de niveau : possible après l\'accord du MJ',
        (tester) async {
      await ouvrir(
        tester,
        'j1',
        fiches: [_brom()],
        avant: (b, c) => ServiceCampagnesMemoire(b, 'mj')
            .seance
            .changerInfos(c, montees: {'j1': 2}),
      );
      await tap(tester, find.byKey(const Key('carte-j1')));
      expect(find.byKey(const Key('monter-niveau-seance')), findsOneWidget);
    });

    testWidgets('sans accord du MJ : pas de montée de niveau', (tester) async {
      await ouvrir(tester, 'j1', fiches: [_brom()]);
      await tap(tester, find.byKey(const Key('carte-j1')));
      expect(find.byKey(const Key('monter-niveau-seance')), findsNothing);
    });

    testWidgets('MJ : autorise la montée et donne un objet aléatoire',
        (tester) async {
      final brom = _brom();
      final x = await ouvrir(
        tester,
        'mj',
        avant: (b, c) async => b.fiches['brom'] = (
          fiche: brom,
          proprietaire: 'j1',
          partage: ['mj'],
          editeurs: ['mj'],
        ),
      );
      await tap(tester, find.byKey(const Key('carte-j1')));
      await tap(tester, find.byKey(const Key('autoriser-montee-j1')));
      final partie = x.base.parties[x.campagne.id]!;
      expect(partie.etat.montees, {'j1': 2});
      await tap(tester, find.byKey(const Key('autoriser-montee-j1')));
      expect(partie.etat.montees, isEmpty);

      await tap(tester, find.byKey(const Key('objet-aleatoire-j1')));
      final nom = tester
          .widget<Text>(find.byKey(const Key('nom-objet-aleatoire')))
          .data!;
      await tap(tester, find.byKey(const Key('donner-objet')));
      expect(
        x.base.fiches['brom']!.fiche.inventaire.map((o) => o.nom),
        contains(nom),
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('carte de créature : icône de sa famille, comme le bestiaire',
        (tester) async {
      await ouvrir(
        tester,
        'mj',
        avant: (b, c) =>
            ServiceCampagnesMemoire(b, 'mj').seance.ajouterCreature(
                  c,
                  const CreatureSeance(id: '', nom: 'Loup', famille: 'Bêtes'),
                ),
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('liste-cartes')),
          matching: find.byIcon(Icons.pets),
        ),
        findsOneWidget,
      );
    });

    testWidgets('fiche hors séance : inventaire et compétences verrouillés',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final personnages = PersonnagesController(
        EnMemoirePersonnageRepository([_brom()]),
      )..restrictions = (_) => (inventaire: true, competences: true);
      await personnages.charger();
      await tester.pumpWidget(MaterialApp(
        home: FicheScreen(
          personnageId: 'brom',
          referentiel: _referentiel,
          controller: personnages,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bouton-monter-niveau')), findsNothing);
      await tap(tester, find.text('Compétences').first);
      expect(find.byKey(const Key('competences-verrouillees')), findsOneWidget);
      expect(find.byKey(const Key('depenser-points')), findsNothing);
      await tap(tester, find.text('Inventaire').first);
      expect(find.byKey(const Key('inventaire-verrouille')), findsOneWidget);
      expect(find.textContaining('Plastron 0/1'), findsOneWidget);
      expect(find.byKey(const Key('ajouter-objet')), findsNothing);
    });

    testWidgets('MJ : permissions et taille des portions', (tester) async {
      final x = await ouvrir(tester, 'mj');
      await tap(tester, find.byKey(const Key('seance-parametres')));
      expect(find.byKey(const Key('portion-gauche')), findsOneWidget);
      await tap(tester, find.byKey(const Key('pj-voient-pv-creatures')));
      expect(
        x.base.campagnes[x.campagne.id]!.parametres.pjVoientPvCreatures,
        isTrue,
      );
    });

    testWidgets('téléphone : trois vues, une carte ouvre le détail',
        (tester) async {
      await ouvrir(tester, 'mj', taille: const Size(420, 900));
      expect(find.byKey(const Key('vue-cartes')), findsOneWidget);
      await tap(tester, find.byKey(const Key('carte-script')));
      expect(find.byKey(const Key('texte-seance')), findsOneWidget);
      await tap(tester, find.byKey(const Key('vue-des')));
      expect(find.byKey(const Key('lancer-seance')), findsOneWidget);
    });
  });
}
