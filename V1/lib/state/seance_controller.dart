import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/campagnes.dart';
import '../data/referentiel.dart';
import '../data/seance.dart';
import '../models/campagne.dart';
import '../models/creature.dart';
import '../models/seance.dart';
import '../regles/fiche_calculee.dart';
import 'campagnes_controller.dart';
import 'personnages_controller.dart';

/// Carte sélectionnée dans la portion de gauche.
const String kCarteScript = 'script';
const String kCarteNotes = 'notes';

/// Partie vue par le compte connecté : suit en direct le mode, les tours, les
/// membres, les créatures, les ressources et les jets, et publie les PV, PM
/// et PE du personnage du joueur.
class SeanceController extends ChangeNotifier {
  SeanceController({
    required this.campagnes,
    required this.personnages,
    required this.referentiel,
    required this.campagneId,
  }) {
    final c = campagne;
    final s = _service;
    if (c == null || s == null) return;
    _carte = c.estMj(uid) ? kCarteScript : kCarteNotes;
    _numero = c.seance?.numero ?? 0;
    final seance = s.seance;
    void suivre<T>(Stream<T> flux, void Function(T) recevoir) =>
        _abonnements.add(flux.listen((v) {
          recevoir(v);
          notifyListeners();
        }, onError: (Object _) {}));
    suivre(seance.ecouterEtat(c), (v) => _etat = v);
    suivre(seance.ecouterCreatures(c), (v) => _creatures = v);
    suivre(seance.ecouterRessources(c), (v) => _ressources = v);
    suivre(seance.ecouterJets(c, _numero), (v) => _jets = v);
    suivre(s.ecouterMembres(c.id), (v) {
      _membres = v;
      unawaited(_publier());
    });
    campagnes.addListener(notifyListeners);
    personnages.addListener(_personnagesChanges);
    unawaited(_chargerTexte());
  }

  final CampagnesController campagnes;
  final PersonnagesController personnages;
  final Referentiel referentiel;
  final String campagneId;

  final List<StreamSubscription<void>> _abonnements = [];
  var _numero = 0;
  EtatJeu _etat = const EtatJeu();
  List<CreatureSeance> _creatures = const [];
  Map<String, RessourcesPj> _ressources = const {};
  List<JetSeance> _jets = const [];
  List<MembreCampagne> _membres = const [];
  String _carte = kCarteNotes;
  String _texte = '';
  RessourcesPj? _publiees;
  int? _initiativePubliee;
  String? _resumePublie;

  ServiceCampagnes? get _service => campagnes.serviceActuel;
  Campagne? get campagne => campagnes.parId(campagneId);
  String get uid => campagnes.uid ?? '';
  bool get estMj => campagne?.estMj(uid) ?? false;
  int get numero => _numero;
  EtatJeu get etat => _etat;
  List<CreatureSeance> get creatures => _creatures;
  Map<String, RessourcesPj> get ressources => _ressources;
  List<JetSeance> get jets => _jets;

  /// Joueurs acceptés.
  List<MembreCampagne> get joueurs => [
        for (final m in _membres)
          if (m.statut == StatutMembre.accepte) m,
      ];

  /// Membre du compte (joueur) ; `null` pour le MJ.
  MembreCampagne? get moi {
    for (final m in _membres) {
      if (m.uid == uid) return m;
    }
    return null;
  }

  /// Fiche calculée du personnage du joueur, s'il est sur ce compte.
  FicheCalculee? get maFiche {
    final p = personnages.parId(moi?.personnageId ?? '');
    final race = p == null ? null : referentiel.race(p.raceId);
    final classe = p == null ? null : referentiel.classe(p.classeId);
    if (p == null || race == null || classe == null) return null;
    return FicheCalculee(personnage: p, race: race, classe: classe);
  }

  /// Carte sélectionnée : script, notes, uid d'un joueur ou id de créature.
  String get carte => _carte;

  void choisirCarte(String id) {
    _carte = id;
    notifyListeners();
  }

  /// Script (MJ) ou notes de séance (PJ).
  String get texte => _texte;

  Future<void> _chargerTexte() async {
    final c = campagne;
    final s = _service;
    if (c == null || s == null) return;
    await campagnes.agir((_) async {
      _texte = c.estMj(uid)
          ? (await s.lirePrive(c.id)).script
          : await s.seance.lireNote(c, _numero);
    });
    notifyListeners();
  }

  bool get monTour => _etat.actif == uid;

  /// Le compte peut-il passer le tour en cours ?
  bool get peutPasser => _etat.enCombat && (estMj || monTour);

  /// Nom de celui qui joue : personnage, créature, ou « MJ » pour une
  /// carte que ce compte ne voit pas.
  String get nomActif {
    final a = _etat.actif;
    if (a == null) return '';
    for (final m in _membres) {
      if (m.uid == a) return m.personnageNom;
    }
    for (final x in _creatures) {
      if (x.id == a) return x.nom;
    }
    return 'MJ';
  }

  void _personnagesChanges() {
    unawaited(_publier());
    notifyListeners();
  }

  /// Joueur : publie PV, PM, PE, résumé et initiative quand ils changent.
  Future<void> _publier() async {
    final c = campagne;
    final f = maFiche;
    if (c == null || f == null || !c.joueurs.contains(uid)) return;
    final r = RessourcesPj(
      pv: f.pvActuels,
      pvMax: f.pvMax,
      pm: f.pmActuels,
      pmMax: f.pmMax,
      pe: f.peActuels,
      peMax: f.peMax,
    );
    final resume = '${f.race.nom} · ${f.classe.nom} · '
        'niveau ${f.personnage.niveau}';
    if (r == _publiees &&
        resume == _resumePublie &&
        f.initiative == _initiativePubliee) {
      return;
    }
    _publiees = r;
    _resumePublie = resume;
    _initiativePubliee = f.initiative;
    await campagnes.agir(
      (x) => x.seance.publierPersonnage(
        c,
        r,
        resume: resume,
        initiative: f.initiative,
      ),
    );
  }

  /// Action sur la partie ; renvoie l'erreur en français, ou `null`.
  Future<String?> _agir(
    Future<void> Function(ServiceSeance s, Campagne c) action,
  ) async {
    final c = campagne;
    if (c == null) return 'Cette campagne n\'existe plus.';
    return campagnes.agir((s) => action(s.seance, c));
  }

  /// MJ : combat (ordre par initiative) ou exploration.
  Future<String?> basculerMode() => _agir((s, c) => _etat.enCombat
      ? s.passerEnExploration(c)
      : s.demarrerCombat(c, ordreCombat(joueurs, _creatures)));

  Future<String?> passerTour() => _agir((s, c) => s.passerTour(c));
  Future<String?> tourPrecedent() => _agir((s, c) => s.tourPrecedent(c));

  /// MJ : ajoute une créature du bestiaire (numérotée si elle y est déjà) ;
  /// en combat, elle prend sa place dans l'ordre.
  Future<String?> ajouterCreature(
    Creature creature, {
    bool cachee = false,
    bool nomCache = false,
  }) =>
      _agir((s, c) async {
        await s.ajouterCreature(
          c,
          CreatureSeance(
            id: '',
            nom: nomNumerote(creature.nom, _creatures.map((x) => x.nom)),
            creatureId: creature.id,
            description: creature.description,
            initiative: creature.initiative ?? 0,
            pv: creature.pv,
            pvMax: creature.pv,
            cachee: cachee,
            nomCache: nomCache,
          ),
        );
        await _reordonner(s, c);
      });

  /// En combat : ordre recalculé avec les créatures à jour.
  Future<void> _reordonner(ServiceSeance s, Campagne c) async {
    if (!_etat.enCombat) return;
    final liste = await s.ecouterCreatures(c).first;
    await s.changerOrdre(c, ordreCombat(joueurs, liste));
  }

  Future<String?> modifierCreature(CreatureSeance creature) =>
      _agir((s, c) => s.modifierCreature(c, creature));

  /// MJ : retire une créature de la partie (et de l'ordre).
  Future<String?> retirerCreature(CreatureSeance creature) =>
      _agir((s, c) async {
        await s.retirerCreature(c, creature.id);
        await _reordonner(s, c);
        if (_carte == creature.id) _carte = kCarteScript;
      });

  /// Enregistre un jet pour ses lecteurs.
  Future<String?> lancer({
    required String libelle,
    required String detail,
    required int total,
    required VisibiliteJet visibilite,
    String? cible,
  }) =>
      _agir(
        (s, c) => s.lancer(
          c,
          JetSeance(
            auteur: uid,
            auteurNom: estMj ? 'MJ' : moi?.personnageNom ?? 'Joueur',
            libelle: libelle,
            detail: detail,
            total: total,
            date: DateTime.now(),
            seance: _numero,
            lecteurs: lecteursDuJet(c, visibilite, auteur: uid, cible: cible),
            visibilite: visibilite,
          ),
        ),
      );

  /// Enregistre le script (MJ) ou les notes de séance (PJ).
  Future<String?> enregistrerTexte(String texte) => _agir((s, c) async {
        if (estMj) {
          final service = _service!;
          final p = await service.lirePrive(c.id);
          await service.ecrirePrive(
            c.id,
            PriveCampagne(script: texte, notes: p.notes),
          );
        } else {
          await s.ecrireNote(c, _numero, texte);
        }
        _texte = texte;
      });

  @override
  void dispose() {
    for (final a in _abonnements) {
      a.cancel();
    }
    campagnes.removeListener(notifyListeners);
    personnages.removeListener(_personnagesChanges);
    super.dispose();
  }
}
