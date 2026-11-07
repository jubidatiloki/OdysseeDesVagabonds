import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/campagne.dart';
import '../models/seance.dart';
import 'seance.dart';

/// Partie en ligne (Firestore), sous `campagnes/{id}` :
/// - `jeu/etat` : mode et tours ;
/// - `creatures/{c}` : ce que les PJ peuvent voir (cartes non cachées) ;
/// - `creaturesMj/{c}` : vrai nom, fiche et PV (MJ seulement) ;
/// - `ressources/{uid}` : PV, PM, PE (selon les paramètres de la campagne) ;
/// - `jets/{j}` : jets de dés, lisibles par leurs seuls `lecteurs` ;
/// - `degats/{d}` : dégâts à appliquer, lus par leur `destinataire` ;
/// - `presences/{uid}` : dernier signal de chaque joueur ;
/// - `messages/{m}` : messages privés, lus par leurs `participants` ;
/// - `notesJoueurs/{uid}/seances/{n}` : notes personnelles du joueur.
class FirestoreServiceSeance implements ServiceSeance {
  FirestoreServiceSeance(this.uid, [FirebaseFirestore? base])
      : _base = base ?? FirebaseFirestore.instance;

  @override
  final String uid;
  final FirebaseFirestore _base;

  DocumentReference<Map<String, dynamic>> _campagne(Campagne c) =>
      _base.collection('campagnes').doc(c.id);
  DocumentReference<Map<String, dynamic>> _etat(Campagne c) =>
      _campagne(c).collection('jeu').doc('etat');
  CollectionReference<Map<String, dynamic>> _creatures(Campagne c) =>
      _campagne(c).collection('creatures');
  CollectionReference<Map<String, dynamic>> _creaturesMj(Campagne c) =>
      _campagne(c).collection('creaturesMj');
  CollectionReference<Map<String, dynamic>> _ressources(Campagne c) =>
      _campagne(c).collection('ressources');
  CollectionReference<Map<String, dynamic>> _jets(Campagne c) =>
      _campagne(c).collection('jets');
  CollectionReference<Map<String, dynamic>> _degats(Campagne c) =>
      _campagne(c).collection('degats');
  DocumentReference<Map<String, dynamic>> _note(Campagne c, int numero) =>
      _campagne(c)
          .collection('notesJoueurs')
          .doc(uid)
          .collection('seances')
          .doc('$numero');

  @override
  Stream<EtatJeu> ecouterEtat(Campagne c) =>
      _etat(c).snapshots().map((d) => EtatJeu.depuisJson(d.data()));

  @override
  Stream<List<CreatureSeance>> ecouterCreatures(Campagne c) {
    if (!c.estMj(uid)) {
      return _creatures(c).where('cachee', isEqualTo: false).snapshots().map(
            (s) => [
              for (final d in s.docs)
                CreatureSeance.depuisDocuments(d.id, d.data()),
            ],
          );
    }
    // MJ : partie publique et partie privée réunies.
    Map<String, Map<String, dynamic>>? publics, prives;
    final abonnements = <StreamSubscription<void>>[];
    late final StreamController<List<CreatureSeance>> sortie;
    void publier() {
      final a = publics, b = prives;
      if (a == null || b == null) return;
      sortie.add([
        for (final e in a.entries)
          CreatureSeance.depuisDocuments(e.key, e.value, b[e.key]),
      ]);
    }

    Map<String, Map<String, dynamic>> lire(
            QuerySnapshot<Map<String, dynamic>> s) =>
        {for (final d in s.docs) d.id: d.data()};
    sortie = StreamController<List<CreatureSeance>>(
      onListen: () {
        abonnements
          ..add(_creatures(c).snapshots().listen((s) {
            publics = lire(s);
            publier();
          }, onError: sortie.addError))
          ..add(_creaturesMj(c).snapshots().listen((s) {
            prives = lire(s);
            publier();
          }, onError: sortie.addError));
      },
      onCancel: () async {
        for (final a in abonnements) {
          await a.cancel();
        }
      },
    );
    return sortie.stream;
  }

  @override
  Stream<Map<String, RessourcesPj>> ecouterRessources(Campagne c) {
    final tout = c.estMj(uid)
        ? c.parametres.fichesVisiblesMj
        : c.parametres.pjVoientRessources;
    if (tout) {
      return _ressources(c).snapshots().map((s) => {
            for (final d in s.docs) d.id: RessourcesPj.depuisJson(d.data()),
          });
    }
    return _ressources(c).doc(uid).snapshots().map((d) => {
          if (d.data() case final j?) uid: RessourcesPj.depuisJson(j),
        });
  }

  @override
  Stream<List<JetSeance>> ecouterJets(Campagne c, int numero) => _jets(c)
      .where('lecteurs', arrayContains: uid)
      .where('seance', isEqualTo: numero)
      .snapshots()
      .map((s) => [
            for (final d in s.docs) JetSeance.depuisJson(d.id, d.data()),
          ]..sort((a, b) => a.date.compareTo(b.date)));

  @override
  Future<void> demarrerCombat(Campagne c, List<String> ordre) =>
      _modifierEtat(c, (e) => e.commencerCombat(ordre));

  @override
  Future<void> passerEnExploration(Campagne c) =>
      _modifierEtat(c, (e) => e.enExploration());

  @override
  Future<void> changerInfos(
    Campagne c, {
    String? lieu,
    Map<String, int>? montees,
  }) =>
      _modifierEtat(c, (e) => e.avecInfos(lieu: lieu, montees: montees));

  Future<void> _modifierEtat(
    Campagne c,
    EtatJeu Function(EtatJeu) changement,
  ) =>
      _base.runTransaction((t) async {
        final ref = _etat(c);
        final e = EtatJeu.depuisJson((await t.get(ref)).data());
        t.set(ref, changement(e).versJson());
      });

  @override
  Future<void> changerOrdre(Campagne c, List<String> ordre) =>
      _modifierEtat(c, (e) => e.avecOrdre(ordre));

  @override
  Future<void> passerTour(Campagne c) => _modifierEtat(c, (e) {
        if (!c.estMj(uid) && e.actif != uid) {
          throw const ErreurCampagne('Ce n\'est pas ton tour.');
        }
        return e.suivant();
      });

  @override
  Future<void> tourPrecedent(Campagne c) =>
      _modifierEtat(c, (e) => e.precedent());

  @override
  Future<void> ajouterCreature(Campagne c, CreatureSeance creature) async {
    final id = creature.id.isEmpty ? _creatures(c).doc().id : creature.id;
    final lot = _base.batch()
      ..set(_creatures(c).doc(id), creature.versPublic(c.parametres))
      ..set(_creaturesMj(c).doc(id), creature.versMj());
    await lot.commit();
  }

  @override
  Future<void> modifierCreature(Campagne c, CreatureSeance creature) =>
      ajouterCreature(c, creature);

  /// Réécrit la partie publique des créatures : les permissions ont changé.
  Future<void> republierCreatures(Campagne c) async {
    final prives = await _creaturesMj(c).get();
    final publics = await _creatures(c).get();
    final parId = {for (final d in publics.docs) d.id: d.data()};
    final lot = _base.batch();
    for (final d in prives.docs) {
      final public = parId[d.id];
      if (public == null) continue;
      final x = CreatureSeance.depuisDocuments(d.id, public, d.data());
      lot.set(_creatures(c).doc(d.id), x.versPublic(c.parametres));
    }
    await lot.commit();
  }

  @override
  Future<void> retirerCreature(Campagne c, String creatureId) async {
    final lot = _base.batch()
      ..delete(_creatures(c).doc(creatureId))
      ..delete(_creaturesMj(c).doc(creatureId));
    await lot.commit();
  }

  @override
  Future<void> lancer(Campagne c, JetSeance jet) =>
      _jets(c).add(jet.versJson());

  @override
  Stream<List<MessageSeance>> ecouterMessages(Campagne c) => _campagne(c)
      .collection('messages')
      .where('participants', arrayContains: uid)
      .snapshots()
      .map((s) => [
            for (final d in s.docs) MessageSeance.depuisJson(d.id, d.data()),
          ]..sort((a, b) => a.date.compareTo(b.date)));

  @override
  Future<void> envoyerMessage(Campagne c, MessageSeance message) =>
      _campagne(c).collection('messages').add(message.versJson());

  @override
  Stream<Map<String, PresenceSeance>> ecouterPresences(Campagne c) =>
      _campagne(c).collection('presences').snapshots().map((s) => {
            for (final d in s.docs) d.id: PresenceSeance.depuisJson(d.data()),
          });

  @override
  Future<void> signalerPresence(Campagne c, {required bool present}) =>
      _campagne(c).collection('presences').doc(uid).set(
            PresenceSeance(vu: DateTime.now(), present: present).versJson(),
          );

  @override
  Future<void> envoyerDegats(Campagne c, DegatsSeance degats) =>
      _degats(c).add(degats.versJson());

  @override
  Stream<List<DegatsSeance>> ecouterDegats(Campagne c) =>
      _degats(c).where('destinataire', isEqualTo: uid).snapshots().map((s) => [
            for (final d in s.docs) DegatsSeance.depuisJson(d.id, d.data()),
          ]);

  @override
  Future<bool> prendreDegats(Campagne c, String id) =>
      _base.runTransaction((t) async {
        final ref = _degats(c).doc(id);
        if (!(await t.get(ref)).exists) return false;
        t.delete(ref);
        return true;
      });

  @override
  Future<void> publierPersonnage(
    Campagne c,
    RessourcesPj ressources, {
    required String resume,
    required int initiative,
    int? ca,
  }) async {
    final lot = _base.batch()
      ..set(_ressources(c).doc(uid), ressources.versJson())
      ..update(_campagne(c).collection('membres').doc(uid), {
        'personnageResume': resume,
        'initiative': initiative,
        if (ca != null) 'ca': ca,
      });
    await lot.commit();
  }

  @override
  Future<String> lireNote(Campagne c, int numero) async =>
      (await _note(c, numero).get()).data()?['texte'] as String? ?? '';

  @override
  Future<void> ecrireNote(Campagne c, int numero, String texte) =>
      _note(c, numero).set({'texte': texte});
}
