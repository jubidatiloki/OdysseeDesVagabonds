import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/campagne.dart';
import '../models/personnage.dart';
import '../models/seance.dart';
import 'campagnes.dart';
import 'firestore_personnage_repository.dart';
import 'firestore_seance.dart';

/// Campagnes en ligne (Firestore) :
/// - `campagnes/{id}` : nom, description, MJ, code, `joueurs` et `demandes`
///   (uids), paramètres, séance ;
/// - `campagnes/{id}/prive/mj` : script et notes (MJ seulement) ;
/// - `campagnes/{id}/membres/{uid}` : joueur, personnage, statut ;
/// - `codes/{code}` : campagne d'un code d'invitation.
/// Les règles de sécurité sont dans `firestore.rules`.
class FirestoreServiceCampagnes implements ServiceCampagnes {
  FirestoreServiceCampagnes(this.uid, [FirebaseFirestore? base])
      : _base = base ?? FirebaseFirestore.instance;

  @override
  final String uid;
  final FirebaseFirestore _base;

  @override
  late final FirestoreServiceSeance seance = FirestoreServiceSeance(uid, _base);

  CollectionReference<Map<String, dynamic>> get _campagnes =>
      _base.collection('campagnes');
  CollectionReference<Map<String, dynamic>> get _codes =>
      _base.collection('codes');
  DocumentReference<Map<String, dynamic>> _prive(String id) =>
      _campagnes.doc(id).collection('prive').doc('mj');
  CollectionReference<Map<String, dynamic>> _membres(String id) =>
      _campagnes.doc(id).collection('membres');

  static Campagne _campagne(DocumentSnapshot<Map<String, dynamic>> d) =>
      Campagne.depuisJson(d.id, d.data() ?? const {});

  String get _maintenant => DateTime.now().toIso8601String();

  @override
  Stream<List<Campagne>> ecouter() {
    // Trois requêtes (MJ, joueur, demande) réunies en une liste.
    final requetes = [
      _campagnes.where('mj', isEqualTo: uid),
      _campagnes.where('joueurs', arrayContains: uid),
      _campagnes.where('demandes', arrayContains: uid),
    ];
    final parts = List<Map<String, Campagne>?>.filled(requetes.length, null);
    final abonnements = <StreamSubscription<void>>[];
    late final StreamController<List<Campagne>> sortie;
    void publier() {
      if (parts.contains(null)) return;
      final tout = <String, Campagne>{for (final p in parts) ...?p};
      sortie.add(tout.values.toList()
        ..sort((a, b) => b.modifieLe.compareTo(a.modifieLe)));
    }

    sortie = StreamController<List<Campagne>>(
      onListen: () {
        for (final (i, q) in requetes.indexed) {
          abonnements.add(q.snapshots().listen((s) {
            parts[i] = {for (final d in s.docs) d.id: _campagne(d)};
            publier();
          }, onError: sortie.addError));
        }
      },
      onCancel: () async {
        for (final a in abonnements) {
          await a.cancel();
        }
      },
    );
    return sortie.stream;
  }

  Future<String> _codeLibre() async {
    for (var i = 0; i < 20; i++) {
      final code = CodeInvitation.generer();
      if (!(await _codes.doc(code).get()).exists) return code;
    }
    throw const ErreurCampagne('Impossible de créer un code, réessaie.');
  }

  @override
  Future<Campagne> creer({
    required String nom,
    required String mjNom,
    String description = '',
    PriveCampagne prive = const PriveCampagne(),
    ParametresCampagne parametres = const ParametresCampagne(),
  }) async {
    final n = ReglesCampagne.verifierNom(nom);
    final doc = _campagnes.doc();
    final code = await _codeLibre();
    final maintenant = DateTime.now();
    final c = Campagne(
      id: doc.id,
      nom: n,
      mj: uid,
      mjNom: mjNom,
      description: description.trim(),
      code: code,
      parametres: parametres,
      creeLe: maintenant,
      modifieLe: maintenant,
    );
    // La campagne d'abord (les règles du script et du code la lisent).
    await doc.set(c.versJson());
    final lot = _base.batch()
      ..set(_prive(doc.id), prive.versJson())
      ..set(_codes.doc(code), {'campagne': doc.id, 'mj': uid});
    await lot.commit();
    return c;
  }

  @override
  Future<void> modifier(Campagne campagne) async {
    await _campagnes.doc(campagne.id).update({
      'nom': ReglesCampagne.verifierNom(campagne.nom),
      'description': campagne.description.trim(),
      'joueursMax': campagne.parametres.joueursMax,
      'parametres': campagne.parametres.versJson(),
      'modifieLe': _maintenant,
    });
    // Les permissions décident de ce que les PJ lisent des créatures.
    await seance.republierCreatures(campagne);
  }

  @override
  Future<void> supprimer(Campagne campagne) async {
    final doc = _campagnes.doc(campagne.id);
    // Tout ce que la campagne contient (lots de 400 écritures).
    final refs = <DocumentReference<Map<String, dynamic>>>[
      _prive(campagne.id),
      _codes.doc(campagne.code),
      doc.collection('jeu').doc('etat'),
    ];
    for (final q in <Query<Map<String, dynamic>>>[
      _membres(campagne.id),
      doc.collection('creatures'),
      doc.collection('creaturesMj'),
      doc.collection('ressources'),
      doc.collection('jets').where('lecteurs', arrayContains: uid),
    ]) {
      refs.addAll((await q.get()).docs.map((d) => d.reference));
    }
    for (var i = 0; i < refs.length; i += 400) {
      final lot = _base.batch();
      for (final r in refs.skip(i).take(400)) {
        lot.delete(r);
      }
      await lot.commit();
    }
    await _campagnes.doc(campagne.id).delete();
  }

  @override
  Future<PriveCampagne> lirePrive(String campagneId) async =>
      PriveCampagne.depuisJson((await _prive(campagneId).get()).data());

  @override
  Future<void> ecrirePrive(String campagneId, PriveCampagne prive) =>
      _prive(campagneId).set(prive.versJson());

  @override
  Future<String> nouveauCode(Campagne campagne) async {
    final code = await _codeLibre();
    final lot = _base.batch()
      ..set(_codes.doc(code), {'campagne': campagne.id, 'mj': uid})
      ..update(_campagnes.doc(campagne.id), {
        'code': code,
        'modifieLe': _maintenant,
      });
    if (campagne.code.isNotEmpty) lot.delete(_codes.doc(campagne.code));
    await lot.commit();
    return code;
  }

  @override
  Stream<List<MembreCampagne>> ecouterMembres(String campagneId) =>
      _membres(campagneId).snapshots().map((s) => [
            for (final d in s.docs) MembreCampagne.depuisJson(d.data()),
          ]..sort((a, b) => a.date.compareTo(b.date)));

  @override
  Future<Campagne> trouverParCode(String code) async {
    final c = CodeInvitation.normaliser(code);
    if (!CodeInvitation.valide(c)) {
      throw const ErreurCampagne(
          'Code incomplet : un mot et 4 chiffres, par exemple LOUP-4827.');
    }
    final lien = await _codes.doc(c).get();
    final id = lien.data()?['campagne'] as String?;
    final doc = id == null ? null : await _campagnes.doc(id).get();
    if (doc == null || !doc.exists) {
      throw const ErreurCampagne(
          'Code inconnu : vérifie-le auprès de ton MJ (il a pu le changer).');
    }
    return _campagne(doc);
  }

  @override
  Future<void> demander(Campagne campagne, MembreCampagne membre) async {
    final c = _campagne(await _campagnes.doc(campagne.id).get());
    ReglesCampagne.verifierDemande(c, uid);
    final lot = _base.batch()
      ..set(_membres(c.id).doc(uid),
          membre.copie(statut: StatutMembre.demande).versJson())
      ..update(_campagnes.doc(c.id), {
        'demandes': FieldValue.arrayUnion([uid]),
      });
    await lot.commit();
  }

  @override
  Future<void> accepter(Campagne campagne, String joueur) async {
    final c = _campagne(await _campagnes.doc(campagne.id).get());
    if (c.complete) {
      throw const ErreurCampagne(
          'La campagne est complète : augmente le nombre de joueurs dans '
          'les paramètres.');
    }
    final lot = _base.batch()
      ..update(_membres(c.id).doc(joueur), {'statut': 'accepte'})
      ..update(_campagnes.doc(c.id), {
        'demandes': FieldValue.arrayRemove([joueur]),
        'joueurs': FieldValue.arrayUnion([joueur]),
        'modifieLe': _maintenant,
      });
    await lot.commit();
  }

  @override
  Future<void> retirer(Campagne campagne, String joueur) async {
    final lot = _base.batch()
      ..delete(_membres(campagne.id).doc(joueur))
      ..update(_campagnes.doc(campagne.id), {
        'demandes': FieldValue.arrayRemove([joueur]),
        'joueurs': FieldValue.arrayRemove([joueur]),
        'modifieLe': _maintenant,
      });
    await lot.commit();
  }

  @override
  Future<void> quitter(Campagne campagne) async {
    final lot = _base.batch()
      ..delete(_membres(campagne.id).doc(uid))
      ..update(_campagnes.doc(campagne.id), {
        'demandes': FieldValue.arrayRemove([uid]),
        'joueurs': FieldValue.arrayRemove([uid]),
      });
    await lot.commit();
  }

  @override
  Future<void> demarrerSeance(Campagne campagne) async {
    final c = _campagne(await _campagnes.doc(campagne.id).get());
    // Une séance commence en exploration.
    final lot = _base.batch()
      ..update(_campagnes.doc(c.id), {
        'seance': Seance(
          numero: (c.seance?.numero ?? 0) + 1,
          debut: DateTime.now(),
        ).versJson(),
        'modifieLe': _maintenant,
      })
      ..set(_campagnes.doc(c.id).collection('jeu').doc('etat'),
          const EtatJeu().versJson());
    await lot.commit();
  }

  @override
  Future<void> terminerSeance(Campagne campagne) =>
      _campagnes.doc(campagne.id).update({
        'seance.enCours': false,
        'modifieLe': _maintenant,
      });

  @override
  Future<Personnage?> lireFiche(String personnageId) async {
    try {
      final d = await _base
          .collection(FirestorePersonnageRepository.collection)
          .doc(personnageId)
          .get();
      final data = d.data();
      return data == null
          ? null
          : FirestorePersonnageRepository.depuisDocument(data);
    } on FirebaseException {
      // Pas partagée avec ce compte.
      return null;
    }
  }

  @override
  Stream<Personnage?> ecouterFiche(String personnageId) => _base
          .collection(FirestorePersonnageRepository.collection)
          .doc(personnageId)
          .snapshots()
          .map((d) {
        final data = d.data();
        return data == null
            ? null
            : FirestorePersonnageRepository.depuisDocument(data);
      });

  @override
  Future<void> ecrireFiche(Personnage personnage) {
    personnage.modifieLe = DateTime.now();
    return _base
        .collection(FirestorePersonnageRepository.collection)
        .doc(personnage.id)
        .update({
      'nom': personnage.nom,
      'modifieLe': personnage.modifieLe.toIso8601String(),
      'fiche': jsonEncode(personnage.versJson()),
    });
  }

  @override
  Future<void> partagerFiche(
    String personnageId,
    List<String> uids, {
    List<String> editeurs = const [],
  }) =>
      _base
          .collection(FirestorePersonnageRepository.collection)
          .doc(personnageId)
          .update({'partageAvec': uids, 'modifiablePar': editeurs});
}
