import 'dart:async';

import '../models/campagne.dart';
import '../models/seance.dart';
import 'campagnes.dart';

/// Partie en cours d'une campagne, vue par un compte (MJ ou joueur). Ce que
/// le compte n'a pas le droit de voir n'arrive jamais jusqu'à lui : créatures
/// cachées, PV des créatures, ressources des autres (selon les paramètres),
/// jets dont il n'est pas lecteur.
abstract class ServiceSeance {
  String get uid;

  /// Mode et tours, en direct.
  Stream<EtatJeu> ecouterEtat(Campagne c);

  /// Créatures de la partie (MJ : toutes ; PJ : ce qu'il peut en savoir).
  Stream<List<CreatureSeance>> ecouterCreatures(Campagne c);

  /// Ressources lisibles par ce compte (uid du joueur → PV, PM, PE).
  Stream<Map<String, RessourcesPj>> ecouterRessources(Campagne c);

  /// Jets de la séance [numero] lisibles par ce compte.
  Stream<List<JetSeance>> ecouterJets(Campagne c, int numero);

  /// MJ : passe en combat avec cet ordre, ou revient en exploration.
  Future<void> demarrerCombat(Campagne c, List<String> ordre);
  Future<void> passerEnExploration(Campagne c);

  /// MJ : ordre recalculé pendant le combat.
  Future<void> changerOrdre(Campagne c, List<String> ordre);

  /// Tour suivant : le MJ, ou le joueur dont c'est le tour.
  Future<void> passerTour(Campagne c);

  /// MJ : revient au tour précédent.
  Future<void> tourPrecedent(Campagne c);

  /// MJ : ajoute, modifie (PV, carte cachée, nom caché) ou retire.
  Future<void> ajouterCreature(Campagne c, CreatureSeance creature);
  Future<void> modifierCreature(Campagne c, CreatureSeance creature);
  Future<void> retirerCreature(Campagne c, String creatureId);

  /// Enregistre un jet (lisible par ses seuls lecteurs).
  Future<void> lancer(Campagne c, JetSeance jet);

  /// Dégâts à appliquer : envoyés à leur destinataire, qui les suit et les
  /// prend une seule fois (`false` : déjà pris).
  Future<void> envoyerDegats(Campagne c, DegatsSeance degats);
  Stream<List<DegatsSeance>> ecouterDegats(Campagne c);
  Future<bool> prendreDegats(Campagne c, String id);

  /// Joueur : publie ses PV, PM, PE, le résumé et l'initiative du personnage.
  Future<void> publierPersonnage(
    Campagne c,
    RessourcesPj ressources, {
    required String resume,
    required int initiative,
  });

  /// Joueur : notes personnelles d'une séance (lui seul peut les lire).
  Future<String> lireNote(Campagne c, int numero);
  Future<void> ecrireNote(Campagne c, int numero, String texte);
}

/// Partie en mémoire (tests), pour une campagne.
class PartieMemoire {
  EtatJeu etat = const EtatJeu();
  final Map<String, CreatureSeance> creatures = {};
  final Map<String, RessourcesPj> ressources = {};
  final List<JetSeance> jets = [];
  final List<DegatsSeance> degats = [];

  /// « uid/numéro » → texte.
  final Map<String, String> notes = {};
}

/// Séance en mémoire pour un compte (tests) : applique les mêmes limites
/// que les règles de sécurité en ligne.
class ServiceSeanceMemoire implements ServiceSeance {
  ServiceSeanceMemoire(this.base, this.uid);

  final BaseCampagnesMemoire base;
  @override
  final String uid;

  PartieMemoire _partie(Campagne c) =>
      base.parties.putIfAbsent(c.id, PartieMemoire.new);

  void _exigerMj(Campagne c) {
    if (!c.estMj(uid)) {
      throw const ErreurCampagne('Seul le MJ peut faire cela.');
    }
  }

  Stream<T> _suivre<T>(T Function() lire) async* {
    yield lire();
    await for (final _ in base.changements) {
      yield lire();
    }
  }

  @override
  Stream<EtatJeu> ecouterEtat(Campagne c) => _suivre(() => _partie(c).etat);

  @override
  Stream<List<CreatureSeance>> ecouterCreatures(Campagne c) => _suivre(() => [
        for (final x in _partie(c).creatures.values)
          if (c.estMj(uid)) x else if (!x.cachee) x.pourJoueur(c.parametres),
      ]);

  @override
  Stream<Map<String, RessourcesPj>> ecouterRessources(Campagne c) =>
      _suivre(() {
        final tout = c.estMj(uid)
            ? c.parametres.fichesVisiblesMj
            : c.parametres.pjVoientRessources;
        return {
          for (final e in _partie(c).ressources.entries)
            if (tout || e.key == uid) e.key: e.value,
        };
      });

  @override
  Stream<List<JetSeance>> ecouterJets(Campagne c, int numero) => _suivre(() => [
        for (final j in _partie(c).jets)
          if (j.seance == numero && j.lecteurs.contains(uid)) j,
      ]);

  void _changer(Campagne c, EtatJeu e) {
    _partie(c).etat = e;
    base.signaler();
  }

  @override
  Future<void> demarrerCombat(Campagne c, List<String> ordre) async {
    _exigerMj(c);
    _changer(c, EtatJeu(mode: ModeJeu.combat, ordre: ordre));
  }

  @override
  Future<void> passerEnExploration(Campagne c) async {
    _exigerMj(c);
    _changer(c, const EtatJeu());
  }

  @override
  Future<void> changerOrdre(Campagne c, List<String> ordre) async {
    _exigerMj(c);
    _changer(c, _partie(c).etat.avecOrdre(ordre));
  }

  @override
  Future<void> passerTour(Campagne c) async {
    final e = _partie(c).etat;
    if (!c.estMj(uid) && e.actif != uid) {
      throw const ErreurCampagne('Ce n\'est pas ton tour.');
    }
    _changer(c, e.suivant());
  }

  @override
  Future<void> tourPrecedent(Campagne c) async {
    _exigerMj(c);
    _changer(c, _partie(c).etat.precedent());
  }

  @override
  Future<void> ajouterCreature(Campagne c, CreatureSeance creature) async {
    _exigerMj(c);
    final id = creature.id.isEmpty ? base.nouvelId() : creature.id;
    _partie(c).creatures[id] = CreatureSeance(
      id: id,
      nom: creature.nom,
      creatureId: creature.creatureId,
      description: creature.description,
      initiative: creature.initiative,
      pv: creature.pv,
      pvMax: creature.pvMax,
      etat: creature.etat,
      cachee: creature.cachee,
      nomCache: creature.nomCache,
    );
    base.signaler();
  }

  @override
  Future<void> modifierCreature(Campagne c, CreatureSeance creature) async {
    _exigerMj(c);
    _partie(c).creatures[creature.id] = creature;
    base.signaler();
  }

  @override
  Future<void> retirerCreature(Campagne c, String creatureId) async {
    _exigerMj(c);
    _partie(c).creatures.remove(creatureId);
    base.signaler();
  }

  @override
  Future<void> lancer(Campagne c, JetSeance jet) async {
    _partie(c).jets.add(jet);
    base.signaler();
  }

  @override
  Future<void> envoyerDegats(Campagne c, DegatsSeance degats) async {
    _partie(c).degats.add(DegatsSeance(
          id: base.nouvelId(),
          cible: degats.cible,
          destinataire: degats.destinataire,
          auteur: degats.auteur,
          montant: degats.montant,
          source: degats.source,
        ));
    base.signaler();
  }

  @override
  Stream<List<DegatsSeance>> ecouterDegats(Campagne c) => _suivre(() => [
        for (final d in _partie(c).degats)
          if (d.destinataire == uid) d,
      ]);

  @override
  Future<bool> prendreDegats(Campagne c, String id) async {
    final liste = _partie(c).degats;
    final avant = liste.length;
    liste.removeWhere((d) => d.id == id);
    return liste.length < avant;
  }

  @override
  Future<void> publierPersonnage(
    Campagne c,
    RessourcesPj ressources, {
    required String resume,
    required int initiative,
  }) async {
    _partie(c).ressources[uid] = ressources;
    final m = base.membres[c.id]?[uid];
    if (m != null) {
      base.membres[c.id]![uid] = MembreCampagne(
        uid: m.uid,
        nom: m.nom,
        personnageId: m.personnageId,
        personnageNom: m.personnageNom,
        personnageResume: resume,
        statut: m.statut,
        date: m.date,
        initiative: initiative,
      );
    }
    base.signaler();
  }

  @override
  Future<String> lireNote(Campagne c, int numero) async =>
      _partie(c).notes['$uid/$numero'] ?? '';

  @override
  Future<void> ecrireNote(Campagne c, int numero, String texte) async {
    _partie(c).notes['$uid/$numero'] = texte;
  }
}
