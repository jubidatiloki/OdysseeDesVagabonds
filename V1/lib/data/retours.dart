import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/retour.dart';

/// Envoi des retours (bugs, idées) : collection `retours` en ligne, en
/// écriture seule (personne ne les relit depuis l'application).
abstract class ServiceRetours {
  Future<void> envoyer(Retour retour);
}

class FirestoreServiceRetours implements ServiceRetours {
  FirestoreServiceRetours([FirebaseFirestore? base])
      : _base = base ?? FirebaseFirestore.instance;

  final FirebaseFirestore _base;

  @override
  Future<void> envoyer(Retour retour) =>
      _base.collection('retours').add(retour.versJson());
}

/// En mémoire (tests).
class ServiceRetoursMemoire implements ServiceRetours {
  final List<Retour> envoyes = [];

  @override
  Future<void> envoyer(Retour retour) async => envoyes.add(retour);
}
