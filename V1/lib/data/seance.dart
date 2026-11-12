import 'dart:async';

import '../models/butin.dart';
import '../models/campagne.dart';
import '../models/objet.dart';
import '../models/seance.dart';
import 'campagnes.dart';

/// Partie en cours d'une campagne, vue par un compte (MJ ou joueur). Ce que
/// le compte n'a pas le droit de voir n'arrive jamais jusqu'à lui : créatures
/// cachées, PV des créatures, ressources des autres (selon les paramètres),
/// jets dont il n'est pas lecteur.
/// Jets suivis en direct pendant une séance (les plus récents).
const int kJetsSuivis = 50;

abstract class ServiceSeance {
  String get uid;

  /// Mode et tours, en direct.
  Stream<EtatJeu> ecouterEtat(Campagne c);

  /// Créatures de la partie (MJ : toutes ; PJ : ce qu'il peut en savoir).
  Stream<List<CreatureSeance>> ecouterCreatures(Campagne c);

  /// Ressources lisibles par ce compte (uid du joueur → PV, PM, PE).
  Stream<Map<String, RessourcesPj>> ecouterRessources(Campagne c);

  /// Jets de la séance [numero] lisibles par ce compte : les [kJetsSuivis]
  /// derniers (moins de lectures en revenant dans la séance).
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
  /// MJ : lieu de la scène et montées de niveau autorisées.
  Future<void> changerInfos(
    Campagne c, {
    String? lieu,
    Map<String, int>? montees,
  });
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

  /// Butins : le MJ les écrit, les PJ y prennent ce qu'il reste ; renvoie ce
  /// qui a vraiment été pris.
  Stream<List<ButinSeance>> ecouterButins(Campagne c);
  Future<void> ecrireButin(Campagne c, ButinSeance butin);
  Future<void> retirerButin(Campagne c, String id);
  Future<({Bourse argent, Objet? objet})> prendreButin(
    Campagne c,
    String id, {
    Bourse? argent,
    String? objetId,
    int? quantite,
  });

  /// Objets envoyés d'un PJ à un autre : pris une seule fois par leur
  /// destinataire (`false` : déjà pris).
  Future<void> envoyerObjet(Campagne c, EnvoiObjet envoi);
  Stream<List<EnvoiObjet>> ecouterEnvois(Campagne c);
  Future<bool> prendreEnvoi(Campagne c, String id);

  /// Messages privés de ce compte écrits pendant la séance [numero]
  /// (MJ : tous ; joueur : les siens).
  Stream<List<MessageSeance>> ecouterMessages(Campagne c, int numero);

  /// Tous les messages de ce compte, lus une fois (séances précédentes).
  Future<List<MessageSeance>> lireMessages(Campagne c);
  Future<void> envoyerMessage(Campagne c, MessageSeance message);

  /// Présence des joueurs (uid → dernier signal), en direct.
  Stream<Map<String, PresenceSeance>> ecouterPresences(Campagne c);

  /// Joueur : signale qu'il est dans la séance, ou qu'il la quitte.
  Future<void> signalerPresence(Campagne c, {required bool present});

  /// Joueur : publie ses PV, PM, PE, le résumé et l'initiative du personnage.
  /// Seul ce qui est donné est écrit : PV seuls, ou carte du membre seule.
  Future<void> publierPersonnage(
    Campagne c, {
    RessourcesPj? ressources,
    String? resume,
    int? initiative,
    int? ca,
    String? nom,
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
  final Map<String, ButinSeance> butins = {};
  final List<EnvoiObjet> envois = [];
  final Map<String, PresenceSeance> presences = {};
  final List<MessageSeance> messages = [];

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
  Stream<List<JetSeance>> ecouterJets(Campagne c, int numero) => _suivre(() {
        final l = [
          for (final j in _partie(c).jets)
            if (j.seance == numero && j.lecteurs.contains(uid)) j,
        ];
        return l.length > kJetsSuivis ? l.sublist(l.length - kJetsSuivis) : l;
      });

  void _changer(Campagne c, EtatJeu e) {
    _partie(c).etat = e;
    base.signaler();
  }

  @override
  Future<void> demarrerCombat(Campagne c, List<String> ordre) async {
    _exigerMj(c);
    _changer(c, _partie(c).etat.commencerCombat(ordre));
  }

  @override
  Future<void> passerEnExploration(Campagne c) async {
    _exigerMj(c);
    _changer(c, _partie(c).etat.enExploration());
  }

  @override
  Future<void> changerInfos(
    Campagne c, {
    String? lieu,
    Map<String, int>? montees,
  }) async {
    _exigerMj(c);
    _changer(c, _partie(c).etat.avecInfos(lieu: lieu, montees: montees));
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
      famille: creature.famille,
      description: creature.description,
      initiative: creature.initiative,
      pv: creature.pv,
      pvMax: creature.pvMax,
      ca: creature.ca,
      etat: creature.etat,
      cachee: creature.cachee,
      nomCache: creature.nomCache,
      proprietaire: creature.proprietaire,
      toursRestants: creature.toursRestants,
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
    // Identifiant attribué comme en ligne.
    _partie(c).jets.add(jet.id.isNotEmpty
        ? jet
        : JetSeance.depuisJson(base.nouvelId(), jet.versJson()));
    base.signaler();
  }

  @override
  Stream<List<MessageSeance>> ecouterMessages(Campagne c, int numero) =>
      _suivre(() => [
            for (final m in _partie(c).messages)
              if ((m.mj == uid || m.joueur == uid) && m.seance == numero) m,
          ]);

  @override
  Future<List<MessageSeance>> lireMessages(Campagne c) async => [
        for (final m in _partie(c).messages)
          if (m.mj == uid || m.joueur == uid) m,
      ];

  @override
  Future<void> envoyerMessage(Campagne c, MessageSeance message) async {
    _partie(c).messages.add(message);
    base.signaler();
  }

  @override
  Stream<Map<String, PresenceSeance>> ecouterPresences(Campagne c) =>
      _suivre(() => Map.of(_partie(c).presences));

  @override
  Future<void> signalerPresence(Campagne c, {required bool present}) async {
    _partie(c).presences[uid] =
        PresenceSeance(vu: DateTime.now(), present: present);
    base.signaler();
  }

  @override
  Future<void> envoyerDegats(Campagne c, DegatsSeance degats) async {
    _partie(c).degats.add(degats.copie(id: base.nouvelId()));
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
  Stream<List<ButinSeance>> ecouterButins(Campagne c) =>
      _suivre(() => _partie(c).butins.values.toList());

  @override
  Future<void> ecrireButin(Campagne c, ButinSeance butin) async {
    _exigerMj(c);
    final id = butin.id.isEmpty ? base.nouvelId() : butin.id;
    _partie(c).butins[id] = butin.copie(id: id);
    base.signaler();
  }

  @override
  Future<void> retirerButin(Campagne c, String id) async {
    _exigerMj(c);
    _partie(c).butins.remove(id);
    base.signaler();
  }

  @override
  Future<({Bourse argent, Objet? objet})> prendreButin(
    Campagne c,
    String id, {
    Bourse? argent,
    String? objetId,
    int? quantite,
  }) async {
    final b = _partie(c).butins[id];
    if (b == null) return (argent: Bourse(), objet: null);
    final pris =
        b.prendre(demande: argent, objetId: objetId, quantite: quantite);
    _partie(c).butins[id] = pris.reste;
    base.signaler();
    return (argent: pris.argent, objet: pris.objet);
  }

  @override
  Future<void> envoyerObjet(Campagne c, EnvoiObjet envoi) async {
    _partie(c).envois.add(envoi.avecId(base.nouvelId()));
    base.signaler();
  }

  @override
  Stream<List<EnvoiObjet>> ecouterEnvois(Campagne c) => _suivre(() => [
        for (final e in _partie(c).envois)
          if (e.destinataire == uid) e,
      ]);

  @override
  Future<bool> prendreEnvoi(Campagne c, String id) async {
    final liste = _partie(c).envois;
    final avant = liste.length;
    liste.removeWhere((e) => e.id == id);
    base.signaler();
    return liste.length < avant;
  }

  @override
  Future<void> publierPersonnage(
    Campagne c, {
    RessourcesPj? ressources,
    String? resume,
    int? initiative,
    int? ca,
    String? nom,
  }) async {
    if (ressources != null) _partie(c).ressources[uid] = ressources;
    final m = base.membres[c.id]?[uid];
    if (m != null && resume != null && initiative != null) {
      base.membres[c.id]![uid] = MembreCampagne(
        uid: m.uid,
        nom: m.nom,
        personnageId: m.personnageId,
        personnageNom: nom ?? m.personnageNom,
        personnageResume: resume,
        statut: m.statut,
        date: m.date,
        initiative: initiative,
        ca: ca,
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
