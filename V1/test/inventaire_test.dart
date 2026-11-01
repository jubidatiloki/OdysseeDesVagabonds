import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/carac.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/equipement.dart';
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/models/race.dart';
import 'package:odyssee_vagabonds/regles/fiche_calculee.dart';
import 'package:odyssee_vagabonds/regles/inventaire.dart';

void main() {
  const nain = Race(
    id: 'nain',
    nom: 'Nain',
    deVie: 8,
    deMana: 4,
    modificateurs: {Carac.dex: -2},
  );
  const guerrier = Classe(
    id: 'guerrier',
    nom: 'Guerrier',
    modifDeVie: ModifDe.plus,
    modifDeMana: ModifDe.moins,
  );

  group('emplacements d\'équipement', () {
    test('une seule armure portée à la fois', () {
      final cotte = Objet(nom: 'Cotte', categorie: CategorieObjet.armure);
      final cuir = Objet(nom: 'Cuir', categorie: CategorieObjet.armure);
      final inventaire = [cotte, cuir];
      expect(ReglesInventaire.refusEquipement(inventaire, cotte), isNull);
      cotte.equipe = true;
      expect(ReglesInventaire.refusEquipement(inventaire, cuir), isNotNull);
      // Retirer l'armure portée est toujours possible
      expect(ReglesInventaire.refusEquipement(inventaire, cotte), isNull);
    });

    test('deux bijoux maximum, potions non équipables', () {
      final bagues = [
        for (var i = 0; i < 3; i++)
          Objet(nom: 'Bague $i', categorie: CategorieObjet.accessoire),
      ];
      bagues[0].equipe = true;
      bagues[1].equipe = true;
      expect(ReglesInventaire.refusEquipement(bagues, bagues[2]), isNotNull);

      final potion = Objet(nom: 'Santé', categorie: CategorieObjet.consommable);
      expect(ReglesInventaire.refusEquipement([potion], potion), isNotNull);
    });

    test('deux mains : armes et boucliers à une main ou une seule à deux mains',
        () {
      final dague = Objet(nom: 'Dague', categorie: CategorieObjet.arme);
      final epee = Objet(nom: 'Épée', categorie: CategorieObjet.arme);
      final bouclier = Objet(nom: 'Écu', categorie: CategorieObjet.bouclier);
      final hache = Objet(
        nom: 'Hache',
        categorie: CategorieObjet.arme,
        deuxMains: true,
      );
      final inventaire = [dague, epee, bouclier, hache];

      // 1H + 1H : possible ; une troisième arme non
      dague.equipe = true;
      expect(ReglesInventaire.refusEquipement(inventaire, bouclier), isNull);
      bouclier.equipe = true;
      expect(ReglesInventaire.mainsOccupees(inventaire), 2);
      expect(ReglesInventaire.refusEquipement(inventaire, epee),
          contains('déjà en main Dague et Écu'));
      // Arme à deux mains avec une main prise : refusée
      bouclier.equipe = false;
      expect(ReglesInventaire.refusEquipement(inventaire, hache), isNotNull);
      // Mains libres : possible ; plus rien d'autre ensuite
      dague.equipe = false;
      expect(ReglesInventaire.refusEquipement(inventaire, hache), isNull);
      hache.equipe = true;
      expect(ReglesInventaire.refusEquipement(inventaire, dague), isNotNull);
      expect(ReglesInventaire.refusEquipement(inventaire, bouclier), isNotNull);

      // Bouclier à deux mains : occupe les deux mains
      final pavois = Objet(
        nom: 'Pavois',
        categorie: CategorieObjet.bouclier,
        deuxMains: true,
      );
      expect(pavois.mains, 2);
      expect(pavois.resume, '2 mains');

      // Deux boucliers à une main : autorisés (une main chacun)
      final ecu2 = Objet(nom: 'Rondache', categorie: CategorieObjet.bouclier);
      final boucliers = [bouclier, ecu2];
      hache.equipe = false;
      bouclier.equipe = true;
      expect(ReglesInventaire.refusEquipement(boucliers, ecu2), isNull);
    });

    test(
        'arme à une ou deux mains : changement de prise selon les mains libres',
        () {
      final baton = Objet(
        nom: 'Bâton',
        categorie: CategorieObjet.arme,
        polyvalente: true,
        equipe: true,
      );
      final dague =
          Objet(nom: 'Dague', categorie: CategorieObjet.arme, equipe: true);
      final inventaire = [baton, dague];
      expect(baton.mains, 1);
      expect(
        ReglesInventaire.refusPrise(inventaire, baton, deuxMains: true),
        isNotNull,
      );
      dague.equipe = false;
      expect(
        ReglesInventaire.refusPrise(inventaire, baton, deuxMains: true),
        isNull,
      );
      baton.tenueDeuxMains = true;
      expect(baton.mains, 2);
      expect(ReglesInventaire.refusEquipement(inventaire, dague), isNotNull);
    });
  });

  test('la CA inclut le bonus des protections portées uniquement', () {
    final perso = Personnage(
      id: 'p',
      nom: 'Brom',
      raceId: 'nain',
      classeId: 'guerrier',
      inventaire: [
        Objet(
          nom: 'Cotte de mailles',
          categorie: CategorieObjet.armure,
          bonusCA: 3,
          equipe: true,
        ),
        Objet(nom: 'Bouclier', categorie: CategorieObjet.bouclier, bonusCA: 2),
      ],
    );
    final fiche =
        FicheCalculee(personnage: perso, race: nain, classe: guerrier);
    // 10 + 3 (cotte portée) + mod DEX (8 → −1) ; bouclier au sac
    expect(fiche.bonusCAEquipement, 3);
    expect(fiche.classeArmure, 12);
    perso.inventaire[1].equipe = true;
    expect(fiche.classeArmure, 14);
  });

  test('armure : limite du bonus de DEX à la CA et à l\x27esquive', () {
    final perso = Personnage(
      id: 'p',
      nom: 'Ysolde',
      raceId: 'nain',
      classeId: 'guerrier',
      caracBase: {for (final c in Carac.values) c: 10, Carac.dex: 18},
    );
    final fiche =
        FicheCalculee(personnage: perso, race: nain, classe: guerrier);
    final dex = fiche.mod(Carac.dex);
    expect(dex, greaterThan(1));
    expect(fiche.limiteDex, isNull);
    expect(fiche.classeArmure, 10 + dex);
    expect(fiche.bonusJetEsquive, dex);
    // Plaques : +6 CA, DEX max +1 ; casque : +1, sans limite.
    perso.inventaire
      ..add(Objet(
          nom: 'Armure de plaques',
          categorie: CategorieObjet.armure,
          bonusCA: 6,
          dexMax: 1,
          equipe: true))
      ..add(Objet(
          nom: 'Casque',
          categorie: CategorieObjet.casque,
          bonusCA: 1,
          equipe: true));
    expect(fiche.limiteDex, 1);
    expect(fiche.classeArmure, 10 + 6 + 1 + 1);
    expect(fiche.bonusJetEsquive, 1);
    expect(perso.inventaire.first.resume, contains('DEX max +1'));
    // Catalogue : « DEX max » lu sur l'armure.
    final cuir = Objet.depuisJson(perso.inventaire.first.versJson());
    expect(cuir.dexMax, 1);
  });

  test('dégâts : dé de l\'arme équipée + modificateur, selon la portée', () {
    final baton = Objet(
      nom: 'Bâton',
      categorie: CategorieObjet.arme,
      degats: '1d6',
      typeDegats: 'contondant',
      polyvalente: true,
      degatsDeuxMains: '1d8',
      tenueDeuxMains: true,
    );
    final arc = Objet(
      nom: 'Arc long',
      categorie: CategorieObjet.arme,
      degats: '1d8',
      distance: true,
      deuxMains: true,
    );
    final perso = Personnage(
      id: 'p',
      nom: 'Brom',
      raceId: 'nain',
      classeId: 'guerrier',
      // FOR 16 → +3 ; DEX 10 − 2 (race) = 8 → −1
      caracBase: {for (final c in Carac.values) c: 10}..[Carac.force] = 16,
      inventaire: [baton, arc],
    );
    final fiche =
        FicheCalculee(personnage: perso, race: nain, classe: guerrier);

    // Rien d'équipé : attaque à mains nues, 1d4 + FOR (règle système)
    expect(fiche.detailDegatsCac.texte, '1d4 +3');
    expect(fiche.detailDegatsCac.entrees.single.$2, 'Mains nues');
    expect(fiche.detailDegatsCac.explication, contains('Mains nues'));
    // À distance sans arme : le bonus seul
    expect(fiche.detailDegatsDistance.texte, '−1');

    baton.equipe = true;
    arc.equipe = true;
    final cac = fiche.detailDegatsCac;
    expect(cac.entrees, [('1d8 +3', 'Bâton · 2 mains')]);
    expect(cac.explication,
        contains('Bâton (tenu à deux mains) : 1d8 contondant'));
    expect(cac.explication, contains('Modificateur FOR : +3'));
    expect(fiche.detailDegatsDistance.entrees, [('1d8 −1', 'Arc long')]);

    baton.tenueDeuxMains = false;
    expect(fiche.detailDegatsCac.texte, '1d6 +3');
    expect(fiche.detailDegatsMagie.texte, '+0');

    // Deux armes de CaC équipées : une ligne de dégâts chacune
    perso.inventaire.add(
      Objet(
        nom: 'Dague',
        categorie: CategorieObjet.arme,
        degats: '1d4',
        equipe: true,
      ),
    );
    final deux = fiche.detailDegatsCac;
    expect(deux.entrees, [
      ('1d6 +3', 'Bâton · 1 main'),
      ('1d4 +3', 'Dague'),
    ]);
    expect(deux.explication, contains('Total Dague : 1d4 +3'));
  });

  test('résumé d\'un objet', () {
    expect(
      Objet(
        nom: 'Hache',
        categorie: CategorieObjet.arme,
        degats: '1d10',
        typeDegats: 'tranchant',
        deuxMains: true,
      ).resume,
      '1d10 tranchant · 2 mains',
    );
    expect(
      Objet(nom: 'Casque', categorie: CategorieObjet.casque, bonusCA: 1).resume,
      'CA +1',
    );
  });

  test('arme à une ou deux mains : dégâts selon la prise', () {
    final baton = Objet(
      nom: 'Bâton',
      categorie: CategorieObjet.arme,
      degats: '1d6',
      typeDegats: 'contondant',
      polyvalente: true,
      degatsDeuxMains: '1d8',
    );
    expect(baton.degatsActuels, '1d6');
    expect(baton.resume, '1d6 contondant · tenu à 1 main');
    baton.tenueDeuxMains = true;
    expect(baton.degatsActuels, '1d8');
    expect(baton.resume, '1d8 contondant · tenu à 2 mains');

    final copie = Objet.depuisJson(baton.versJson());
    expect(copie.polyvalente, isTrue);
    expect(copie.degatsDeuxMains, '1d8');
    expect(copie.tenueDeuxMains, isTrue);
    expect(copie.degatsActuels, '1d8');
  });

  test('objet choisi dans le catalogue des équipements', () {
    final catalogue = {
      for (final e in jsonDecode(
        File('assets/data/equipements.json').readAsStringSync(),
      ) as List)
        (e as Map<String, dynamic>)['id']: Equipement.depuisJson(e),
    };

    // Armures : CA et limite de DEX (refonte du 29/10/2026).
    for (final (id, ca, dex) in const [
      ('armure-cuir', 1, 3),
      ('cotte-de-mailles', 3, 2),
      ('armure-plaques', 6, 1),
      ('bikini-de-plaque', 5, 1),
    ]) {
      final a = ObjetDuCatalogue.depuis(catalogue[id]!);
      expect(
          (a.categorie, a.bonusCA, a.dexMax), (CategorieObjet.armure, ca, dex),
          reason: id);
      expect(a.description, isNot(contains('DEX max')));
    }
    expect(ObjetDuCatalogue.depuis(catalogue['casque-cuir']!).dexMax, isNull);

    final baton = ObjetDuCatalogue.depuis(catalogue['baton']!);
    expect(baton.categorie, CategorieObjet.arme);
    expect(baton.polyvalente, isTrue);
    expect(baton.degats, '1d6');
    expect(baton.degatsDeuxMains, '1d8');
    expect(baton.typeDegats, 'contondant');
    expect(baton.description, isNot(contains('Prix')));

    final arc = ObjetDuCatalogue.depuis(catalogue['arc-long']!);
    expect(arc.deuxMains, isTrue);
    expect(arc.distance, isTrue);
    expect(baton.distance, isFalse);
    expect(arc.typeDegats, 'perçant');
    expect(arc.description, contains('Portée : 40m'));

    final epee = ObjetDuCatalogue.depuis(catalogue['epee-longue']!);
    expect(epee.typeDegats, 'tranchant');
    expect(epee.deuxMains, isFalse);

    final casque = ObjetDuCatalogue.depuis(catalogue['casque-cuir']!);
    expect(casque.categorie, CategorieObjet.casque);
    expect(casque.bonusCA, 1);

    final plaque = ObjetDuCatalogue.depuis(catalogue['bikini-de-plaque']!);
    expect(plaque.categorie, CategorieObjet.armure);
    expect(plaque.bonusCA, 5);

    final potion = ObjetDuCatalogue.depuis(catalogue['potion-sante-1']!);
    expect(potion.categorie, CategorieObjet.consommable);
    expect(potion.description, contains('Soin : 1D8 PV'));
    expect(potion.description, isNot(contains('Déblocage')));

    // « Outil, arme » + « deux main » : arme de CaC à deux mains
    final pioche = ObjetDuCatalogue.depuis(catalogue['pioche']!);
    expect(pioche.categorie, CategorieObjet.arme);
    expect(pioche.deuxMains, isTrue);
    expect(pioche.distance, isFalse);
    expect(pioche.degats, '1d6');
    final mousquet = ObjetDuCatalogue.depuis(catalogue['mousquet']!);
    expect(mousquet.distance, isTrue);
    expect(mousquet.deuxMains, isTrue);
    expect(mousquet.degats, '2d6');
    // Bouclier à une main ; simple outil rangé dans les objets divers
    final bouclier = ObjetDuCatalogue.depuis(catalogue['bouclier-en-bois']!);
    expect(bouclier.categorie, CategorieObjet.bouclier);
    expect(bouclier.bonusCA, 1);
    expect(bouclier.mains, 1);
    expect(
      ObjetDuCatalogue.depuis(catalogue['corde-20m']!).categorie,
      CategorieObjet.divers,
    );

    // Tous les équipements se convertissent sans erreur.
    for (final e in catalogue.values) {
      expect(ObjetDuCatalogue.depuis(e).nom, e.nom);
    }
  });

  test('origine d\'un objet : inconnue par défaut, sauvegardée', () {
    final dague = Objet(nom: 'Dague', categorie: CategorieObjet.arme);
    expect(dague.origine, OrigineObjet.inconnue);
    expect(dague.versJson().containsKey('origine'), isFalse);
    dague
      ..origine = OrigineObjet.butin
      ..precisionOrigine = 'gobelin du col';
    final copie = Objet.depuisJson(dague.versJson());
    expect(copie.origine, OrigineObjet.butin);
    expect(copie.texteOrigine, 'Butin (gobelin du col)');
    expect(OrigineObjet.race.verrouillee, isTrue);
    expect(OrigineObjet.achat.verrouillee, isFalse);
  });

  test('inventaire et bourse survivent à un aller-retour JSON', () {
    final p = Personnage(
      id: 'p',
      nom: 'Brom',
      raceId: 'nain',
      classeId: 'guerrier',
      inventaire: [
        Objet(
          nom: 'Marteau',
          categorie: CategorieObjet.arme,
          degats: '1d8',
          typeDegats: 'contondant',
          equipe: true,
        ),
        Objet(
          nom: 'Potion de santé',
          categorie: CategorieObjet.consommable,
          quantite: 3,
          description: 'Rend 1D8 PV',
        ),
      ],
      bourse: Bourse(or: 2, argent: 15, cuivre: 40),
    );
    final copie = Personnage.depuisJson(p.versJson());
    expect(copie.inventaire, hasLength(2));
    final marteau = copie.inventaire[0];
    expect(marteau.id, p.inventaire[0].id);
    expect(marteau.categorie, CategorieObjet.arme);
    expect(marteau.equipe, isTrue);
    expect(marteau.resume, '1d8 contondant');
    expect(copie.inventaire[1].quantite, 3);
    expect(copie.inventaire[1].description, 'Rend 1D8 PV');
    expect(copie.bourse.or, 2);
    expect(copie.bourse.argent, 15);
    expect(copie.bourse.cuivre, 40);
  });

  test('un ancien personnage sans inventaire se charge (bourse vide)', () {
    final p = Personnage.depuisJson({
      'id': 'ancien',
      'nom': 'Lia',
      'raceId': 'humain',
      'classeId': 'voleur',
    });
    expect(p.inventaire, isEmpty);
    expect(p.bourse.vide, isTrue);
  });
}
