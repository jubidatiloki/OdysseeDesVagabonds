import 'dart:async';
import 'dart:math';

import '../models/campagne.dart';
import '../models/personnage.dart';
import 'seance.dart';

/// Campagnes en ligne d'un compte (uid). L'interface permet de remplacer
/// Firestore par une version en mémoire dans les tests.
abstract class ServiceCampagnes {
  /// Compte connecté.
  String get uid;

  /// Partie en cours (tours, créatures, jets).
  ServiceSeance get seance;

  /// Campagnes où le compte est MJ, joueur ou en attente, en direct.
  Stream<List<Campagne>> ecouter();

  /// Crée une campagne (le compte en est le MJ) avec un code d'invitation.
  Future<Campagne> creer({
    required String nom,
    required String mjNom,
    String description = '',
    PriveCampagne prive = const PriveCampagne(),
    ParametresCampagne parametres = const ParametresCampagne(),
  });

  /// MJ : nom, description, paramètres.
  Future<void> modifier(Campagne campagne);

  /// MJ : supprime la campagne (membres, script, notes, code).
  Future<void> supprimer(Campagne campagne);

  /// MJ : script et notes.
  Future<PriveCampagne> lirePrive(String campagneId);
  Future<void> ecrirePrive(String campagneId, PriveCampagne prive);

  /// MJ : récapitulatif de chaque séance (numéro → texte).
  Future<Map<int, String>> lireRecaps(String campagneId);
  Future<void> ecrireRecap(String campagneId, int numero, String texte);

  /// Dates des séances (numéro → date), posées au démarrage ou par le MJ.
  Future<Map<int, DateTime>> lireDatesRecaps(String campagneId);
  Future<void> ecrireDateRecap(String campagneId, int numero, DateTime date);

  /// MJ : remplace le code d'invitation (l'ancien ne marche plus).
  Future<String> nouveauCode(Campagne campagne);

  /// Joueurs et demandes d'une campagne, en direct.
  Stream<List<MembreCampagne>> ecouterMembres(String campagneId);

  /// Joueur : campagne d'un code d'invitation (erreur si inconnu).
  Future<Campagne> trouverParCode(String code);

  /// Joueur : demande à rejoindre avec un personnage (ou change de
  /// personnage : nouvelle demande).
  Future<void> demander(Campagne campagne, MembreCampagne membre);

  /// MJ : accepte une demande.
  Future<void> accepter(Campagne campagne, String joueur);

  /// MJ : refuse une demande ou retire un joueur.
  Future<void> retirer(Campagne campagne, String joueur);

  /// Joueur : quitte la campagne (ou annule sa demande).
  Future<void> quitter(Campagne campagne);

  /// MJ : démarre une séance (numéro suivant) ou termine celle en cours.
  Future<void> demarrerSeance(Campagne campagne);

  /// MJ : nom d'une séance (vide : aucun).
  Future<void> nommerSeance(Campagne campagne, int numero, String nom);
  Future<void> terminerSeance(Campagne campagne);

  /// Fiche partagée par un autre joueur (lecture seule) ; `null` si elle
  /// n'est pas partagée avec ce compte.
  Future<Personnage?> lireFiche(String personnageId);

  /// Fiche partagée, en direct (`null` si elle n'est pas lisible).
  Stream<Personnage?> ecouterFiche(String personnageId);

  /// MJ : enregistre une fiche modifiée pendant la séance.
  Future<void> ecrireFiche(Personnage personnage);

  /// Joueur : comptes qui peuvent lire sa fiche (MJ, autres joueurs) et
  /// comptes qui peuvent la modifier (MJ).
  Future<void> partagerFiche(
    String personnageId,
    List<String> uids, {
    List<String> editeurs = const [],
  });
}

/// Contrôles communs aux implémentations.
abstract final class ReglesCampagne {
  static String verifierNom(String nom) {
    final n = nom.trim();
    if (n.isEmpty) {
      throw const ErreurCampagne('Donne un nom à la campagne.');
    }
    return n;
  }

  /// Le joueur peut-il demander à rejoindre [c] ?
  static void verifierDemande(Campagne c, String uid) {
    if (c.estMj(uid)) {
      throw const ErreurCampagne('Tu es le maître du jeu de cette campagne.');
    }
    if (c.joueurs.contains(uid)) {
      throw const ErreurCampagne('Tu fais déjà partie de cette campagne.');
    }
    if (c.complete) {
      throw const ErreurCampagne(
          'La campagne est complète : demande au MJ de faire de la place.');
    }
  }
}

/// Données partagées des campagnes en mémoire (tests) : plusieurs comptes
/// ([ServiceCampagnesMemoire]) y accèdent comme à une base en ligne.
class BaseCampagnesMemoire {
  final Map<String, Campagne> campagnes = {};
  final Map<String, PriveCampagne> prives = {};
  final Map<String, Map<String, MembreCampagne>> membres = {};
  final Map<String, String> codes = {};

  /// Parties en cours (id de campagne → partie).
  final Map<String, PartieMemoire> parties = {};

  /// Récapitulatifs (id de campagne → numéro → texte).
  final Map<String, Map<int, String>> recaps = {};

  /// Dates des séances (id de campagne → numéro → date).
  final Map<String, Map<int, DateTime>> datesRecaps = {};

  /// Fiches en ligne (id → fiche, propriétaire, partage).
  final Map<
      String,
      ({
        Personnage fiche,
        String proprietaire,
        List<String> partage,
        List<String> editeurs
      })> fiches = {};
  final _changements = StreamController<void>.broadcast();
  var _compteur = 0;
  final Random aleatoire;

  BaseCampagnesMemoire([Random? aleatoire])
      : aleatoire = aleatoire ?? Random(7);

  void signaler() => _changements.add(null);
  Stream<void> get changements => _changements.stream;
  String nouvelId() => 'c${++_compteur}';

  String codeLibre() {
    while (true) {
      final c = CodeInvitation.generer(aleatoire);
      if (!codes.containsKey(c)) return c;
    }
  }
}

/// Campagnes en mémoire pour un compte (tests, aperçu sans réseau).
class ServiceCampagnesMemoire implements ServiceCampagnes {
  ServiceCampagnesMemoire(this.base, this.uid, {DateTime Function()? horloge})
      : _horloge = horloge ?? DateTime.now;

  final BaseCampagnesMemoire base;
  @override
  final String uid;
  final DateTime Function() _horloge;

  @override
  late final ServiceSeance seance = ServiceSeanceMemoire(base, uid);

  Campagne _lire(String id) {
    final c = base.campagnes[id];
    if (c == null) {
      throw const ErreurCampagne('Cette campagne n\'existe plus.');
    }
    return c;
  }

  void _exigerMj(Campagne c) {
    if (!_lire(c.id).estMj(uid)) {
      throw const ErreurCampagne('Seul le MJ peut faire cela.');
    }
  }

  void _ecrire(Campagne c) {
    base.campagnes[c.id] = c.copie(modifieLe: _horloge());
    base.signaler();
  }

  List<Campagne> _miennes() => [
        for (final c in base.campagnes.values)
          if (c.estMj(uid) ||
              c.joueurs.contains(uid) ||
              c.demandes.contains(uid))
            c,
      ]..sort((a, b) => b.modifieLe.compareTo(a.modifieLe));

  @override
  Stream<List<Campagne>> ecouter() async* {
    yield _miennes();
    await for (final _ in base.changements) {
      yield _miennes();
    }
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
    final id = base.nouvelId();
    final code = base.codeLibre();
    final maintenant = _horloge();
    final c = Campagne(
      id: id,
      nom: n,
      mj: uid,
      mjNom: mjNom,
      description: description.trim(),
      code: code,
      parametres: parametres,
      creeLe: maintenant,
      modifieLe: maintenant,
    );
    base.codes[code] = id;
    base.prives[id] = prive;
    base.membres[id] = {};
    _ecrire(c);
    return base.campagnes[id]!;
  }

  @override
  Future<void> modifier(Campagne campagne) async {
    _exigerMj(campagne);
    final actuelle = _lire(campagne.id);
    _ecrire(actuelle.copie(
      nom: ReglesCampagne.verifierNom(campagne.nom),
      description: campagne.description,
      parametres: campagne.parametres,
    ));
  }

  @override
  Future<void> supprimer(Campagne campagne) async {
    _exigerMj(campagne);
    base.codes.removeWhere((_, id) => id == campagne.id);
    base.campagnes.remove(campagne.id);
    base.prives.remove(campagne.id);
    base.membres.remove(campagne.id);
    base.parties.remove(campagne.id);
    base.signaler();
  }

  @override
  Future<PriveCampagne> lirePrive(String campagneId) async {
    _exigerMj(_lire(campagneId));
    return base.prives[campagneId] ?? const PriveCampagne();
  }

  @override
  Future<void> ecrirePrive(String campagneId, PriveCampagne prive) async {
    _exigerMj(_lire(campagneId));
    base.prives[campagneId] = prive;
    base.signaler();
  }

  @override
  Future<Map<int, String>> lireRecaps(String campagneId) async {
    final c = _lire(campagneId);
    if (!c.joueurs.contains(uid)) _exigerMj(c);
    return Map.of(base.recaps[campagneId] ?? const {});
  }

  @override
  Future<void> ecrireRecap(String campagneId, int numero, String texte) async {
    _exigerMj(_lire(campagneId));
    (base.recaps[campagneId] ??= {})[numero] = texte;
  }

  @override
  Future<Map<int, DateTime>> lireDatesRecaps(String campagneId) async {
    final c = _lire(campagneId);
    if (!c.joueurs.contains(uid)) _exigerMj(c);
    return Map.of(base.datesRecaps[campagneId] ?? const {});
  }

  @override
  Future<void> ecrireDateRecap(
    String campagneId,
    int numero,
    DateTime date,
  ) async {
    _exigerMj(_lire(campagneId));
    (base.datesRecaps[campagneId] ??= {})[numero] = date;
  }

  @override
  Future<String> nouveauCode(Campagne campagne) async {
    _exigerMj(campagne);
    final c = _lire(campagne.id);
    base.codes.remove(c.code);
    final code = base.codeLibre();
    base.codes[code] = c.id;
    _ecrire(c.copie(code: code));
    return code;
  }

  @override
  Stream<List<MembreCampagne>> ecouterMembres(String campagneId) async* {
    List<MembreCampagne> liste() => [
          ...?base.membres[campagneId]?.values,
        ]..sort((a, b) => a.date.compareTo(b.date));
    yield liste();
    await for (final _ in base.changements) {
      yield liste();
    }
  }

  @override
  Future<Campagne> trouverParCode(String code) async {
    final id = base.codes[CodeInvitation.normaliser(code)];
    final c = id == null ? null : base.campagnes[id];
    if (c == null) {
      throw const ErreurCampagne(
          'Code inconnu : vérifie-le auprès de ton MJ (il a pu le changer).');
    }
    return c;
  }

  @override
  Future<void> demander(Campagne campagne, MembreCampagne membre) async {
    final c = _lire(campagne.id);
    ReglesCampagne.verifierDemande(c, uid);
    base.membres[c.id]![uid] = membre.copie(statut: StatutMembre.demande);
    _ecrire(c.copie(demandes: {...c.demandes, uid}.toList()));
  }

  @override
  Future<void> accepter(Campagne campagne, String joueur) async {
    _exigerMj(campagne);
    final c = _lire(campagne.id);
    final m = base.membres[c.id]?[joueur];
    if (m == null) {
      throw const ErreurCampagne('Cette demande n\'existe plus.');
    }
    if (c.complete) {
      throw const ErreurCampagne(
          'La campagne est complète : augmente le nombre de joueurs dans '
          'les paramètres.');
    }
    base.membres[c.id]![joueur] = m.copie(statut: StatutMembre.accepte);
    _ecrire(c.copie(
      demandes: [...c.demandes]..remove(joueur),
      joueurs: {...c.joueurs, joueur}.toList(),
    ));
  }

  @override
  Future<void> retirer(Campagne campagne, String joueur) async {
    _exigerMj(campagne);
    final c = _lire(campagne.id);
    base.membres[c.id]?.remove(joueur);
    _ecrire(c.copie(
      demandes: [...c.demandes]..remove(joueur),
      joueurs: [...c.joueurs]..remove(joueur),
    ));
  }

  @override
  Future<void> quitter(Campagne campagne) async {
    final c = _lire(campagne.id);
    base.membres[c.id]?.remove(uid);
    _ecrire(c.copie(
      demandes: [...c.demandes]..remove(uid),
      joueurs: [...c.joueurs]..remove(uid),
    ));
  }

  @override
  Future<void> demarrerSeance(Campagne campagne) async {
    _exigerMj(campagne);
    final c = _lire(campagne.id);
    // Une séance commence en exploration, au lieu où la précédente a fini.
    final partie = base.parties[c.id];
    if (partie != null) partie.etat = partie.etat.nouvelleSeance();
    final seance =
        Seance(numero: (c.seance?.numero ?? 0) + 1, debut: _horloge());
    (base.datesRecaps[c.id] ??= {})[seance.numero] = seance.debut;
    _ecrire(c.copie(seance: seance));
  }

  @override
  Future<void> nommerSeance(Campagne campagne, int numero, String nom) async {
    _exigerMj(campagne);
    final c = _lire(campagne.id);
    _ecrire(c.copie(nomsSeances: {...c.nomsSeances, numero: nom.trim()}));
  }

  @override
  Future<void> terminerSeance(Campagne campagne) async {
    _exigerMj(campagne);
    final c = _lire(campagne.id);
    final s = c.seance;
    if (s == null) return;
    _ecrire(c.copie(
      seance: Seance(numero: s.numero, debut: s.debut, enCours: false),
    ));
  }

  @override
  Future<Personnage?> lireFiche(String personnageId) async {
    final f = base.fiches[personnageId];
    if (f == null) return null;
    if (f.proprietaire != uid && !f.partage.contains(uid)) return null;
    return f.fiche;
  }

  @override
  Stream<Personnage?> ecouterFiche(String personnageId) async* {
    yield await lireFiche(personnageId);
    await for (final _ in base.changements) {
      yield await lireFiche(personnageId);
    }
  }

  @override
  Future<void> ecrireFiche(Personnage personnage) async {
    final f = base.fiches[personnage.id];
    if (f == null || !f.editeurs.contains(uid)) {
      throw const ErreurCampagne('Cette fiche n\'est pas modifiable.');
    }
    base.fiches[personnage.id] = (
      fiche: personnage,
      proprietaire: f.proprietaire,
      partage: f.partage,
      editeurs: f.editeurs,
    );
    base.signaler();
  }

  @override
  Future<void> partagerFiche(
    String personnageId,
    List<String> uids, {
    List<String> editeurs = const [],
  }) async {
    final f = base.fiches[personnageId];
    if (f == null || f.proprietaire != uid) return;
    base.fiches[personnageId] = (
      fiche: f.fiche,
      proprietaire: f.proprietaire,
      partage: uids,
      editeurs: editeurs,
    );
  }
}
