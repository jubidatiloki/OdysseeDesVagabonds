import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../data/campagnes.dart';
import '../data/referentiel.dart';
import '../data/seance.dart';
import '../models/bonus_seance.dart';
import '../models/butin.dart';
import '../models/campagne.dart';
import '../models/carac.dart';
import '../models/carte_campagne.dart';
import '../models/creature.dart';
import '../models/historique.dart';
import '../models/objet.dart';
import '../models/personnage.dart';
import '../models/seance.dart';
import '../models/voie.dart';
import '../regles/des.dart';
import '../regles/invocations.dart';
import '../regles/fiche_calculee.dart';
import 'campagnes_controller.dart';
import 'personnages_controller.dart';

/// Carte sélectionnée dans la portion de gauche.
const String kCarteScript = 'script';
const String kCarteNotes = 'notes';

/// Sélection d'une carte diffusée : « plan: » + son identifiant.
const String kPrefixePlan = 'plan:';

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
    suivre(seance.ecouterEtat(c), (v) {
      final debutCombat = v.enCombat && !_etat.enCombat;
      final ancien = _etat;
      _etat = v;
      unawaited(_decompterTours(ancien, v));
      // Fin du combat : les bonus « jusqu'à la fin du combat » s'arrêtent.
      if (ancien.enCombat && !v.enCombat) unawaited(_finirBonusCombat());
      // Début du combat : les PV en attente partent sans attendre.
      if (debutCombat && _minuteriePublication != null) {
        _minuteriePublication!.cancel();
        _minuteriePublication = null;
        unawaited(_publier(force: true));
      }
    });
    suivre(seance.ecouterBonus(c), (v) {
      _bonus = v;
      unawaited(_ajusterOrdre());
    });
    suivre(seance.ecouterJets(c, _numero), (v) {
      // Ordre chronologique selon l'heure du serveur (20/11/2026).
      _jets = [...v]..sort((a, b) => a.heure.compareTo(b.heure));
      _traiterInvocations();
    });
    suivre(seance.ecouterPresences(c), (v) => _presences = v);
    suivre(seance.ecouterMessages(c, _numero), (v) => _messages = v);
    // Joueur : signale sa présence (toutes les 3 minutes).
    _signalerPresence(true);
    _minuteriePresence = Timer.periodic(PresenceSeance.intervalle, (_) {
      _signalerPresence(true);
    });
    // Tous : les absents sont réévalués chaque minute, sans rien écrire.
    _minuterieAbsences = Timer.periodic(const Duration(minutes: 1), (_) {
      _suivreFiches();
      notifyListeners();
    });
    suivre(seance.ecouterDegats(c), (v) {
      _degats = v;
      _traiterDegats();
    });
    suivre(seance.ecouterButins(c), (v) => _butins = v);
    // Cartes : leurs informations seulement (nom, taille, diffusion).
    suivre(s.ecouterCartes(c), (v) {
      _plans = v;
      // Carte retirée aux PJ alors qu'elle était affichée.
      if (_carte.startsWith(kPrefixePlan) &&
          !cartesDiffusees.any((p) => '$kPrefixePlan${p.id}' == _carte)) {
        _carte = estMj ? kCarteScript : kCarteNotes;
      }
    });
    suivre(seance.ecouterEnvois(c), (v) {
      _envois = v;
      _traiterEnvois();
    });
    suivre(s.ecouterMembres(c.id), (v) {
      _membres = v;
      _noterMontees();
      _suivreFiches();
      _traiterDegats();
      _traiterEnvois();
      unawaited(_publier());
      unawaited(_ajusterOrdre());
      unawaited(_synchroniserCompagnons());
    });
    _suivreSelonPermissions();
    campagnes.addListener(_campagneChangee);
    personnages.addListener(_personnagesChanges);
    unawaited(_chargerTexte());
  }

  /// Écritures espacées : le joueur publie ses PV au plus toutes les
  /// 2 secondes en combat (les autres attendent de les voir bouger) et toutes
  /// les 15 secondes en exploration ; le MJ enregistre les fiches au plus
  /// toutes les 3 secondes.
  static const Duration delaiEcritureCombat = Duration(seconds: 2);
  static const Duration delaiEcritureExploration = Duration(seconds: 15);
  static const Duration delaiEcritureMj = Duration(seconds: 3);

  /// Délai entre deux publications du joueur, selon le mode de jeu.
  Duration get delaiEcritureJoueur =>
      _etat.enCombat ? delaiEcritureCombat : delaiEcritureExploration;

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
  int? _caPubliee;
  String? _santePubliee;
  String? _nomPublie;
  final Set<String> _caCompletees = {};
  String? _resumePublie;
  Map<String, PresenceSeance> _presences = const {};
  List<MessageSeance> _messages = const [];

  /// Messages des séances précédentes, chargés à la demande (`null` : pas
  /// encore chargés).
  List<MessageSeance>? _anciens;
  bool get anciensMessagesCharges => _anciens != null;

  /// Messages reçus déjà lus, par conversation (uid du joueur).
  final Map<String, int> _lus = {};
  Timer? _minuteriePresence;
  Timer? _minuterieAbsences;

  /// Fiche pas encore partagée (permission qui vient de changer) : nouvel
  /// essai quelques secondes après (20/11/2026), au lieu d'attendre la
  /// minute ; au plus [_essaisFicheMax] fois par fiche.
  Timer? _minuterieEssaiFiches;
  final Map<String, int> _essaisFiche = {};
  static const int _essaisFicheMax = 10;
  static const Duration delaiEssaiFiche = Duration(seconds: 3);

  /// Dégâts reçus, traités un par un (deux coups ne s'écrasent pas).
  List<DegatsSeance> _degats = const [];
  final Set<String> _degatsPris = {};
  Future<void> _fileDegats = Future.value();
  StreamSubscription<void>? _creaturesFlux;
  StreamSubscription<void>? _ressourcesFlux;
  String _permissions = '';

  /// Fiches des autres joueurs, en direct (id de fiche → fiche).
  final Map<String, StreamSubscription<void>> _fichesFlux = {};
  final Map<String, Personnage> _fiches = {};

  /// Butins de la partie, objets reçus d'autres PJ.
  List<ButinSeance> _butins = const [];
  List<BonusSeance> _bonus = const [];
  List<CarteCampagne> _plans = const [];
  List<EnvoiObjet> _envois = const [];
  final Set<String> _envoisPris = {};
  Future<void> _fileEnvois = Future.value();

  /// Message à montrer au joueur (objet reçu).
  final ValueNotifier<String?> annonce = ValueNotifier(null);

  /// Joueur : publication espacée de [delaiEcritureJoueur].
  DateTime? _dernierePublication;
  Timer? _minuteriePublication;

  /// MJ : fiches modifiées, envoyées au plus toutes les 3 secondes.
  final Map<String, Personnage> _aEcrire = {};
  Timer? _minuterieFiches;

  ServiceCampagnes? get _service => campagnes.serviceActuel;
  Campagne? get campagne => campagnes.parId(campagneId);
  String get uid => campagnes.uid ?? '';
  bool get estMj => campagne?.estMj(uid) ?? false;
  int get numero => _numero;
  EtatJeu get etat => _etat;
  List<CreatureSeance> get creatures => _creatures;
  Map<String, RessourcesPj> get ressources => _ressources;
  List<JetSeance> get jets => _jets;

  /// Butins : tous pour le MJ, ceux qu'il n'a pas cachés pour les PJ.
  List<ButinSeance> get butins => estMj
      ? _butins
      : [
          for (final b in _butins)
            if (!b.cache) b
        ];

  /// Cartes de la campagne diffusées aux PJ (16/11/2026), dans la liste
  /// de gauche de tous ; l'image n'est lue qu'à l'ouverture.
  List<CarteCampagne> get cartesDiffusees => [
        for (final p in _plans)
          if (p.diffusee) p,
      ];

  /// MJ : montre ou cache la carte d'un butin aux PJ.
  Future<String?> montrerButin(ButinSeance butin, {required bool visible}) =>
      modifierButin(butin.copie(cache: !visible));

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

  /// Pion d'un personnage de joueur (20/11/2026) : icône d'après sa fiche
  /// si ce compte la lit, sinon d'après son résumé (« Nain · Guerrier »).
  PionCarte pionDe(MembreCampagne m) {
    final p = ficheDe(m.uid)?.personnage;
    var race = p?.raceId ?? '';
    var classe = p?.classeId ?? '';
    if (p == null) {
      final parts = m.personnageResume.split(' · ');
      for (final r in referentiel.races) {
        if (parts.isNotEmpty && r.nom == parts.first) race = r.id;
      }
      for (final c in referentiel.classes) {
        if (parts.length > 1 && c.nom == parts[1]) classe = c.id;
      }
    }
    return PionCarte(
      id: m.uid,
      nom: m.personnageNom,
      personnage: true,
      proprietaire: m.uid,
      allie: true,
      raceId: race,
      classeId: classe,
      element: p?.choix['element-draconien'] ?? '',
    );
  }

  /// Pion d'une créature de la partie (nom vu des PJ).
  PionCarte pionCreature(CreatureSeance c) => PionCarte(
        id: c.id,
        nom: c.nomPublic,
        personnage: false,
        proprietaire: c.proprietaire,
        allie: c.duCotePj,
        neutre: c.neutre,
        famille:
            c.famille.isNotEmpty ? c.famille : ficheCreature(c)?.famille ?? '',
      );

  /// Ce compte peut-il gérer [pion] sur une carte (20/11/2026) ? Le MJ
  /// toujours ; un PJ selon les permissions de la campagne.
  bool peutGererPion(PionCarte pion) =>
      estMj ||
      (campagne?.parametres.pjGerePion(
            uid,
            (proprietaire: pion.proprietaire, allie: pion.allie),
          ) ??
          false);

  /// Pions que ce compte peut poser : personnages et créatures de la
  /// partie (cartes cachées exclues pour les PJ : ils ne les voient pas).
  List<PionCarte> get pionsPossibles => [
        for (final m in joueurs) pionDe(m),
        for (final c in _creatures) pionCreature(c),
      ].where(peutGererPion).toList();

  /// Fiche d'un joueur, si ce compte peut la lire.
  FicheCalculee? ficheDe(String joueur) {
    if (joueur == uid) return maFiche;
    for (final m in _membres) {
      if (m.uid != joueur) continue;
      final p = _fiches[m.personnageId];
      final race = p == null ? null : referentiel.race(p.raceId);
      final classe = p == null ? null : referentiel.classe(p.classeId);
      if (p == null || race == null || classe == null) return null;
      return FicheCalculee(personnage: p, race: race, classe: classe);
    }
    return null;
  }

  /// Compagnons et familiers d'un joueur qui peuvent se battre (si ce
  /// compte peut lire sa fiche), affichés sous lui.
  List<({Creature creature, String type, String competence})> compagnonsDe(
      String joueur) {
    final f = ficheDe(joueur);
    if (f == null) return const [];
    return compagnonsCombattants(
      f,
      {for (final x in referentiel.creatures) x.id: x},
    );
  }

  /// Demande d'invocation temporaire : [creature] × [nombre] pendant [tours]
  /// tours, pour qui agit. Le MJ l'ajoute tout de suite ; un joueur passe
  /// par un jet (ligne des logs) que l'application du MJ transforme en
  /// créatures.
  Future<String?> invoquer(
    Creature creature, {
    int nombre = 1,
    int? tours,
  }) {
    final proprietaire = idAttaquant;
    final n = nombre.clamp(1, 12);
    if (estMj) {
      return _agir((s, c) async {
        await _ajouterInvocation(
            s, c, '${DateTime.now().microsecondsSinceEpoch}', creature,
            nombre: n, tours: tours, proprietaire: proprietaire);
      });
    }
    return _agir(
      (s, c) => s.lancer(
        c,
        JetSeance(
          auteur: uid,
          auteurNom: moi?.personnageNom ?? 'Joueur',
          libelle: 'Invocation : ${creature.nom}${n > 1 ? ' ×$n' : ''}',
          detail: tours == null ? '' : '$tours tour${tours > 1 ? 's' : ''}',
          total: tours ?? 0,
          date: DateTime.now(),
          seance: _numero,
          lecteurs: lecteursDuJet(c, VisibiliteJet.tous, auteur: uid),
          mode: _etat.mode,
          manche: _etat.manche,
          attaquant: proprietaire,
          invocation: creature.id,
          nombre: n,
          tours: tours,
        ),
      ),
    );
  }

  /// Renvoie une invocation temporaire avant la fin : le MJ la retire tout
  /// de suite ; son lanceur passe par un jet (ligne des logs) que
  /// l'application du MJ applique.
  Future<String?> renvoyerInvocation(CreatureSeance x) {
    if (estMj) return retirerCreature(x);
    return _agir(
      (s, c) => s.lancer(
        c,
        JetSeance(
          auteur: uid,
          auteurNom: moi?.personnageNom ?? 'Joueur',
          libelle: 'Renvoi : ${x.nom}',
          detail: '',
          total: 0,
          date: DateTime.now(),
          seance: _numero,
          lecteurs: lecteursDuJet(c, VisibiliteJet.tous, auteur: uid),
          mode: _etat.mode,
          manche: _etat.manche,
          renvoi: x.id,
        ),
      ),
    );
  }

  Future<void> _ajouterInvocation(
    ServiceSeance s,
    Campagne c,
    String cle,
    Creature cr, {
    required int nombre,
    required int? tours,
    required String proprietaire,
  }) async {
    // Noms numérotés : Diablotin, Diablotin 2…
    final noms = [for (final x in _creatures) x.nom];
    for (var i = 0; i < nombre; i++) {
      final nom = nomNumerote(cr.nom, noms);
      noms.add(nom);
      await s.ajouterCreature(
        c,
        CreatureSeance(
          id: 'invocation-$cle-$i',
          nom: nom,
          creatureId: cr.id,
          famille: cr.famille,
          description: cr.description,
          initiative: cr.initiative ?? 0,
          pv: cr.pv,
          pvMax: cr.pv,
          ca: cr.ca,
          proprietaire: proprietaire,
          toursRestants: tours,
        ),
      );
    }
    await _reordonner(s, c);
  }

  /// MJ : jets d'invocation des joueurs arrivés pendant la séance (ceux
  /// déjà là à l'ouverture ont été traités avant).
  final Set<String> _invocationsVues = {};
  bool _jetsLus = false;
  void _traiterInvocations() {
    final nouveaux = [
      for (final j in _jets)
        if ((j.invocation.isNotEmpty || j.renvoi.isNotEmpty) &&
            _invocationsVues.add(j.id))
          j,
    ];
    final premiers = !_jetsLus;
    _jetsLus = true;
    if (premiers || !estMj) return;
    for (final j in nouveaux) {
      // Renvoi par son lanceur : seulement sa propre invocation.
      if (j.renvoi.isNotEmpty) {
        for (final x in _creatures) {
          if (x.id == j.renvoi &&
              x.proprietaire == j.auteur &&
              x.toursRestants != null) {
            unawaited(retirerCreature(x, raison: 'renvoyée par son lanceur'));
          }
        }
        continue;
      }
      Creature? cr;
      for (final x in referentiel.creatures) {
        if (x.id == j.invocation) cr = x;
      }
      if (cr == null) continue;
      final fiche = cr;
      unawaited(_agir((s, c) => _ajouterInvocation(s, c, j.id, fiche,
          nombre: j.nombre, tours: j.tours, proprietaire: j.attaquant)));
    }
  }

  /// MJ : à chaque nouvelle manche de combat, les invocations temporaires
  /// perdent un tour ; à 0, elles disparaissent.
  Future<void> _decompterTours(EtatJeu avant, EtatJeu apres) async {
    if (!estMj || !apres.enCombat || !avant.enCombat) return;
    if (apres.manche <= avant.manche) return;
    final passees = apres.manche - avant.manche;
    await _decompterBonus(passees);
    final temporaires = [
      for (final x in _creatures)
        if (x.toursRestants != null) x,
    ];
    if (temporaires.isEmpty) return;
    await _agir((s, c) async {
      for (final x in temporaires) {
        final reste = x.toursRestants! - passees;
        if (reste <= 0) {
          await s.retirerCreature(c, x.id);
          await _retirerPions(c, x.id);
          await _noterDisparition(s, c, x, 'durée expirée');
          if (_carte == x.id) _carte = kCarteScript;
        } else {
          await s.modifierCreature(c, x.copie(toursRestants: reste));
        }
      }
      await _reordonner(s, c);
    });
  }

  /// Bonus et malus de la séance en cours (18/11/2026).
  List<BonusSeance> get bonus => [
        for (final b in _bonus)
          if (b.seance == _numero) b,
      ];

  /// Ceux que reçoit [cible] (uid d'un joueur).
  List<BonusSeance> bonusRecus(String cible) => [
        for (final b in bonus)
          if (b.cibles.contains(cible)) b,
      ];

  /// Ce compte voit-il les bonus et malus reçus par [id] ? (19/11/2026) Le
  /// MJ toujours ; un PJ les siens et ceux de ses compagnons, ceux des
  /// autres PJ et alliés ou des créatures selon les permissions.
  bool voitEffetsDe(String id) {
    if (estMj || id == uid) return true;
    final p = campagne?.parametres ?? const ParametresCampagne();
    CreatureSeance? creature;
    for (final c in _creatures) {
      if (c.id == id) creature = c;
    }
    if (creature != null && creature.proprietaire == uid) return true;
    final allie =
        joueurs.any((m) => m.uid == id) || (creature?.duCotePj ?? false);
    return allie ? p.pjVoientEffetsAllies : p.pjVoientEffetsCreatures;
  }

  /// Bonus et malus reçus par [id] que ce compte peut voir (les siens, ceux
  /// qu'il a donnés, les autres selon [voitEffetsDe]).
  List<BonusSeance> bonusVisibles(String id) {
    final tous = voitEffetsDe(id);
    return [
      for (final b in bonusRecus(id))
        if (tous || b.auteur == uid) b,
    ];
  }

  /// Icône de la carte (19/11/2026) : nombre de bonus et de malus visibles
  /// (une affliction compte comme un malus) ; `null` : aucun.
  ({int bonus, int malus})? bonusSurCarte(String id) {
    var bon = 0;
    var mal = 0;
    for (final b in bonusVisibles(id)) {
      if (b.estEtat || b.valeur < 0) {
        mal++;
      } else if (b.valeur > 0) {
        bon++;
      }
    }
    return bon + mal == 0 ? null : (bonus: bon, malus: mal);
  }

  /// Personnages des joueurs dans la liste de gauche (19/11/2026) : pour un
  /// PJ, le sien d'abord, puis par ordre alphabétique. En combat : par
  /// initiative, le plus rapide en haut (20/11/2026).
  List<MembreCampagne> get joueursOrdonnes {
    final liste = [...joueurs]..sort((a, b) {
        if (_etat.enCombat && a.initiative != b.initiative) {
          return b.initiative.compareTo(a.initiative);
        }
        if (!estMj && (a.uid == uid) != (b.uid == uid)) {
          return a.uid == uid ? -1 : 1;
        }
        return a.personnageNom
            .toLowerCase()
            .compareTo(b.personnageNom.toLowerCase());
      });
    return liste;
  }

  /// CA affichée sur la carte d'un joueur : la sienne d'après sa fiche (à
  /// jour sans attendre la publication), celle publiée pour les autres.
  int? caJoueur(MembreCampagne m) =>
      m.uid == uid ? maFiche?.classeArmure ?? m.ca : m.ca;

  /// CA sur la carte d'une créature (20/11/2026) : alliés, compagnons et
  /// invocations pour tous ; créatures rencontrées pour le MJ seul (la CA
  /// d'une cible n'est jamais montrée aux PJ).
  int? caCarte(CreatureSeance c) =>
      estMj || c.duCotePj ? c.ca ?? ficheCreature(c)?.ca : null;

  /// Liste de gauche en combat (20/11/2026) : personnages des joueurs,
  /// alliés et créatures rencontrées mêlés, dans l'ordre du combat
  /// (initiative) ; ceux qui n'y sont pas encore suivent, par initiative.
  /// Compagnons et invocations restent sous leur maître.
  List<({MembreCampagne? joueur, CreatureSeance? creature})>
      get ordreDesCartes {
    final liste = <({MembreCampagne? joueur, CreatureSeance? creature})>[
      for (final m in joueurs) (joueur: m, creature: null),
      for (final c in _creatures)
        if (!c.estAUnJoueur) (joueur: null, creature: c),
    ];
    int rang(String id) {
      // Ordre de la manche (embusqués en tête à la manche 1).
      final i = _etat.ordreTour.indexOf(id);
      return i < 0 ? 1 << 20 : i;
    }

    String id(({MembreCampagne? joueur, CreatureSeance? creature}) x) =>
        x.joueur?.uid ?? x.creature!.id;
    int ini(({MembreCampagne? joueur, CreatureSeance? creature}) x) =>
        x.joueur?.initiative ?? x.creature!.initiative;
    return liste
      ..sort((a, b) {
        final r = rang(id(a)).compareTo(rang(id(b)));
        return r != 0 ? r : ini(b).compareTo(ini(a));
      });
  }

  /// Créatures de la liste de gauche (20/11/2026) : en combat, par
  /// initiative (le plus rapide en haut) ; sinon dans l'ordre d'ajout.
  List<CreatureSeance> get creaturesOrdonnees {
    final liste = [..._creatures];
    if (_etat.enCombat) {
      liste.sort((a, b) => b.initiative.compareTo(a.initiative));
    }
    return liste;
  }

  /// Ceux que ce compte peut retirer : les siens ; tous pour le MJ.
  List<BonusSeance> get bonusRetirables => [
        for (final b in bonus)
          if (estMj || b.auteur == uid) b,
      ];

  /// Bonus qui comptent pour un jet de [cible] (le plus fort par nom).
  List<({String nom, int valeur})> bonusApplicables(
    String cible, {
    required GenreJet genre,
    required bool d20,
    bool degats = false,
    Carac? carac,
    bool initiative = false,
  }) =>
      BonusSeance.applicables(
        bonus,
        cible,
        genre: genre,
        d20: d20,
        degats: degats,
        carac: carac,
        initiative: initiative,
      );

  /// Bonus d'initiative de chaque joueur (ordre de combat).
  Map<String, int> get _bonusInitiative => {
        for (final m in joueurs)
          m.uid: bonusApplicables(
            m.uid,
            genre: GenreJet.test,
            d20: true,
            initiative: true,
          ).fold(0, (n, b) => n + b.valeur),
      };

  /// Donne un bonus ou un malus à un ou plusieurs joueurs ; noté dans les
  /// logs de la table.
  Future<String?> poserBonus({
    required String nom,
    required int valeur,
    required PorteeBonus portee,
    Carac? carac,
    required List<String> cibles,
    required DureeBonus duree,
    int tours = 3,
    String? auteurNom,
    String contre = '',
    String etat = '',
  }) {
    final nomAuteur =
        auteurNom ?? (estMj ? 'MJ' : (moi?.personnageNom ?? 'Joueur'));
    final b = BonusSeance(
      nom: nom.trim().isEmpty ? 'Bonus' : nom.trim(),
      valeur: valeur,
      portee: portee,
      carac: portee == PorteeBonus.carac ? carac : null,
      contre: portee == PorteeBonus.ca ? contre : '',
      etat: portee == PorteeBonus.etat ? etat : '',
      cibles: cibles,
      auteur: uid,
      auteurNom: nomAuteur,
      duree: duree,
      toursRestants: switch (duree) {
        DureeBonus.tours ||
        DureeBonus.actions ||
        DureeBonus.minutes ||
        DureeBonus.heures ||
        DureeBonus.jours =>
          tours,
        _ => null,
      },
      seance: _numero,
      date: DateTime.now(),
    );
    final noms = nomsCibles(cibles);
    return _agir((s, c) async {
      await s.poserBonus(c, b);
      await _noter(
        s,
        c,
        '${b.nom} (${b.effet}, ${b.dureeTexte}) : ${noms.join(', ')}',
        VisibiliteJet.tous,
      );
    });
  }

  /// Lance l'effet d'une compétence ou d'un sort qui donne un bonus ou un
  /// malus (19/11/2026) : à ses cibles (selon sa cible), pour sa durée.
  /// [reussi] : le jet de la compétence a réussi (sinon rien, si le bonus
  /// l'exige) ; [choisis] : cibles choisies (cible unique ou sélection).
  /// [option] : option choisie (bénédiction d'une arme…), si elle en a.
  /// Renvoie les noms des personnages qui le reçoivent (vide : rien donné).
  Future<List<String>> donnerBonusDe(
    FicheCalculee f,
    Competence c, {
    required bool reussi,
    List<String> choisis = const [],
    String option = '',
    math.Random? aleatoire,
  }) async {
    final rang = f.rangCompetence(c.nom);
    final donnes = [
      for (final b in c.bonusDonnes)
        if ((b.valeur != 0 || b.portee == 'etat') &&
            (b.rangMin == null || rang >= b.rangMin!) &&
            (b.rangMax == null || rang <= b.rangMax!) &&
            !(b.siReussite && !reussi) &&
            (b.option.isEmpty || b.option == option))
          b,
    ];
    if (donnes.isEmpty) return [];
    final soi = idAttaquant;
    final cibles = switch (c.cible ?? CibleCompetence.soi) {
      CibleCompetence.soi => [soi],
      // Alliés : tous les PJ, le lanceur compris ; ou sans lui.
      CibleCompetence.allies => [for (final m in joueurs) m.uid],
      CibleCompetence.alliesSansLanceur => [
          for (final m in joueurs)
            if (m.uid != soi) m.uid,
        ],
      CibleCompetence.unique || CibleCompetence.selection => choisis,
    };
    if (cibles.isEmpty) return [];
    final d = c.duree ?? const DureeCompetence(type: TypeDuree.indefini);
    final duree = switch (d.type) {
      TypeDuree.finCombat => DureeBonus.finCombat,
      TypeDuree.tours => DureeBonus.tours,
      TypeDuree.actions || TypeDuree.aucune => DureeBonus.actions,
      TypeDuree.minutes => DureeBonus.minutes,
      TypeDuree.heures => DureeBonus.heures,
      TypeDuree.jours => DureeBonus.jours,
      TypeDuree.indefini => DureeBonus.retrait,
    };
    final tours = nombreDuree(f, c, d.valeur, aleatoire);
    for (final b in donnes) {
      final erreur = await poserBonus(
        nom: c.nom,
        valeur: b.valeur,
        portee: PorteeBonus.depuisCode(b.portee),
        carac: Carac.depuisCode(b.carac),
        cibles: cibles,
        duree: duree,
        tours: tours,
        auteurNom: f.personnage.nom,
        contre: b.contre,
        etat: b.etat,
      );
      if (erreur != null) return [];
    }
    return nomsCibles(cibles);
  }

  /// Nombre d'une durée : chiffre, caractéristique (son modificateur, 1 au
  /// moins), dés ou formule (« 1d6 + INT », « INT × 10 », « INT + RANG ») ;
  /// 1 par défaut.
  static int nombreDuree(
    FicheCalculee f,
    Competence c,
    String valeur,
    math.Random? a,
  ) {
    var v = valeur.trim();
    if (v.isEmpty) return 1;
    if (int.tryParse(v) case final n?) return math.max(1, n);
    // Caractéristiques (leur modificateur) et RANG remplacés par leur
    // valeur : « 1d6 + INT » devient « 1d6 + 3 ».
    v = v.replaceAllMapped(RegExp(r'[A-Za-z]{2,4}'), (m) {
      final mot = m[0]!;
      if (mot.toUpperCase() == 'RANG') return '${f.rangCompetence(c.nom)}';
      final carac = Carac.depuisCode(mot);
      return carac == null ? mot : '${f.mod(carac)}';
    });
    // Somme de termes (« 1d6 + 3 », « 2 + 3 », « 3 × 10 », « 1d6/2 ») :
    // chaque terme est un nombre ou des dés, multiplié ou divisé.
    final hasard = a ?? math.Random();
    final formule = v.replaceAll('×', '*').replaceAll(' ', '');
    var total = 0;
    for (final m in RegExp(r'([+-]?)([^+-]+)').allMatches(formule)) {
      var valeurTerme = 1;
      for (final (i, facteur) in m[2]!.split(RegExp(r'(?=[*/])')).indexed) {
        final op = i == 0 ? '*' : facteur[0];
        final brut = i == 0 ? facteur : facteur.substring(1);
        final des = RegExp(r'^(\d*)d(\d+)$').firstMatch(brut);
        final int x;
        if (des != null) {
          final nb = int.tryParse(des[1]!) ?? 1;
          final faces = int.parse(des[2]!);
          x = [for (var k = 0; k < nb; k++) hasard.nextInt(faces) + 1]
              .fold(0, (s, d) => s + d);
        } else {
          final n = int.tryParse(brut);
          if (n == null) return 1;
          x = n;
        }
        valeurTerme =
            op == '/' ? valeurTerme ~/ math.max(1, x) : valeurTerme * x;
      }
      total += m[1] == '-' ? -valeurTerme : valeurTerme;
    }
    return math.max(1, total);
  }

  /// Après un jet : les bonus « en actions » qui y ont compté perdent une
  /// action ; à zéro, ils s'arrêtent.
  Future<void> consommerBonus(List<BonusSeance> utilises) async {
    final aDecompter = [
      for (final b in utilises)
        if (b.duree == DureeBonus.actions) b,
    ];
    if (aDecompter.isEmpty) return;
    await _agir((s, c) async {
      for (final b in aDecompter) {
        final reste = (b.toursRestants ?? 1) - 1;
        if (reste <= 0) {
          await s.retirerBonus(c, b);
        } else {
          await s.modifierBonus(c, b.copie(toursRestants: reste));
        }
      }
    });
  }

  /// Bonus retenus pour un jet de [cible] (à consommer ensuite).
  List<BonusSeance> bonusRetenus(
    String cible, {
    required GenreJet genre,
    required bool d20,
    bool degats = false,
    Carac? carac,
    bool initiative = false,
  }) =>
      BonusSeance.retenus(
        bonus,
        cible,
        genre: genre,
        d20: d20,
        degats: degats,
        carac: carac,
        initiative: initiative,
      );

  /// Noms des cibles d'un bonus : personnages puis créatures.
  List<String> nomsCibles(List<String> cibles) => [
        for (final m in joueurs)
          if (cibles.contains(m.uid)) m.personnageNom,
        for (final c in _creatures)
          if (cibles.contains(c.id)) c.nomPublic,
      ];

  /// États (afflictions) posés sur un personnage ou une créature.
  List<BonusSeance> etatsDe(String id) => [
        for (final b in bonus)
          if (b.estEtat && b.cibles.contains(id)) b,
      ];

  /// Retire un bonus (son auteur ou le MJ).
  Future<String?> retirerBonus(BonusSeance b) => _agir((s, c) async {
        await s.retirerBonus(c, b);
        await _noter(s, c, '${b.nom} : terminé', VisibiliteJet.tous);
      });

  /// MJ : fin du combat, les bonus « jusqu'à la fin du combat » s'arrêtent.
  Future<void> _finirBonusCombat() async {
    if (!estMj) return;
    final fin = [
      for (final b in bonus)
        if (b.duree == DureeBonus.finCombat || b.duree == DureeBonus.tours) b,
    ];
    if (fin.isEmpty) return;
    await _agir((s, c) async {
      for (final b in fin) {
        await s.retirerBonus(c, b);
      }
    });
  }

  /// MJ : un tour de moins pour les bonus à durée en tours.
  Future<void> _decompterBonus(int passees) async {
    final aDecompter = [
      for (final b in bonus)
        if (b.duree == DureeBonus.tours) b,
    ];
    if (aDecompter.isEmpty) return;
    await _agir((s, c) async {
      for (final b in aDecompter) {
        final reste = (b.toursRestants ?? 0) - passees;
        if (reste <= 0) {
          await s.retirerBonus(c, b);
        } else {
          await s.modifierBonus(c, b.copie(toursRestants: reste));
        }
      }
    });
  }

  /// Compagnon ou invocation d'un autre joueur : ses PV se voient si les PJ
  /// voient les PV des autres PJ, sa fiche si les fiches sont visibles entre
  /// PJ (permissions de la campagne). Le MJ et son propriétaire voient tout.
  bool voitPvDe(CreatureSeance x) =>
      estMj ||
      !x.estAUnJoueur ||
      x.proprietaire == uid ||
      (campagne?.parametres.pjVoientRessources ?? false);

  bool voitFicheDe(CreatureSeance x) =>
      estMj ||
      !x.estAUnJoueur ||
      x.proprietaire == uid ||
      (campagne?.parametres.fichesEntrePj(enSeance: true) ?? false);

  /// Compagnons et invocations d'un joueur entrés dans la partie (PV
  /// suivis, initiative).
  List<CreatureSeance> compagnonsEnJeu(String joueur) => [
        for (final x in _creatures)
          if (x.proprietaire == joueur) x,
      ];

  /// MJ : les compagnons qui se battent entrent dans la partie comme des
  /// créatures (identifiant fixe, sans doublon) et en sortent quand le
  /// personnage ne les a plus ; seulement pour les fiches que le MJ lit.
  bool _synchronisation = false;
  Future<void> _synchroniserCompagnons() async {
    if (!estMj || _synchronisation || _service == null) return;
    final c = campagne;
    if (c == null) return;
    final aAjouter = <CreatureSeance>[];
    final aRetirer = <CreatureSeance>[];
    final uids = {for (final m in joueurs) m.uid};
    for (final x in _creatures) {
      if (x.estAUnJoueur && !uids.contains(x.proprietaire)) aRetirer.add(x);
    }
    for (final m in joueurs) {
      if (ficheDe(m.uid) == null) continue;
      final voulus = {
        for (final x in compagnonsDe(m.uid))
          'compagnon-${m.uid}-${x.creature.id}': x.creature,
      };
      final presents = [
        for (final x in compagnonsEnJeu(m.uid))
          if (x.estCompagnon) x,
      ];
      for (final x in presents) {
        if (!voulus.containsKey(x.id)) aRetirer.add(x);
      }
      for (final e in voulus.entries) {
        if (presents.any((x) => x.id == e.key)) continue;
        final cr = e.value;
        aAjouter.add(CreatureSeance(
          id: e.key,
          nom: cr.nom,
          creatureId: cr.id,
          famille: cr.famille,
          description: cr.description,
          initiative: cr.initiative ?? 0,
          pv: cr.pv,
          pvMax: cr.pv,
          ca: cr.ca,
          proprietaire: m.uid,
        ));
      }
    }
    if (aAjouter.isEmpty && aRetirer.isEmpty) return;
    _synchronisation = true;
    try {
      await _agir((s, c) async {
        for (final x in aAjouter) {
          await s.ajouterCreature(c, x);
        }
        for (final x in aRetirer) {
          await s.retirerCreature(c, x.id);
          await _retirerPions(c, x.id);
        }
        await _reordonner(s, c);
      });
    } finally {
      _synchronisation = false;
    }
  }

  /// Fiche du bestiaire d'une créature de la partie.
  Creature? ficheCreature(CreatureSeance c) {
    for (final x in referentiel.creatures) {
      if (x.id == c.creatureId) return x;
    }
    return null;
  }

  /// MJ (21/11/2026) : qui agit dans le panneau des dés, gardé quand on
  /// affiche autre chose au centre (une carte, le script) ; '' : personne.
  String? _acteurMj;

  /// Personnage ou créature de la partie ?
  bool _estActeur(String id) =>
      _creatures.any((c) => c.id == id) || joueurs.any((m) => m.uid == id);

  /// Qui agit : pour le MJ, celui choisi (ou la dernière carte de
  /// personnage ou de créature touchée) ; sinon la carte sélectionnée.
  String get _acteur {
    final a = _acteurMj;
    if (estMj && a != null && (a.isEmpty || _estActeur(a))) return a;
    return _carte;
  }

  /// MJ : qui agit dans le panneau des dés ('' : personne).
  String get acteurMj => estMj && _estActeur(_acteur) ? _acteur : '';

  /// MJ : choisit qui agit, sans changer ce qui est affiché au centre.
  void choisirActeur(String id) {
    _acteurMj = id;
    notifyListeners();
  }

  /// Créature sélectionnée (celle qui agit pour le MJ), s'il y en a une.
  CreatureSeance? get creatureChoisie {
    for (final c in _creatures) {
      if (c.id == _acteur) return c;
    }
    return null;
  }

  /// Qui attaque dans le lancer de dés : le PJ pour lui-même ; le MJ pour le
  /// personnage ou la créature sélectionnés.
  ({FicheCalculee? fiche, Creature? creature, String nom}) get attaquant {
    if (!estMj) {
      final f = maFiche;
      return (fiche: f, creature: null, nom: f?.personnage.nom ?? '');
    }
    final c = creatureChoisie;
    if (c != null) return (fiche: null, creature: ficheCreature(c), nom: c.nom);
    final f = ficheDe(_acteur);
    return (fiche: f, creature: null, nom: f?.personnage.nom ?? '');
  }

  /// Carte sélectionnée : script, notes, uid d'un joueur ou id de créature.
  String get carte => _carte;

  void choisirCarte(String id) {
    _carte = id;
    // MJ : toucher un personnage ou une créature le fait agir.
    if (estMj && _estActeur(id)) _acteurMj = id;
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

  /// Messages d'une conversation (clé `MessageSeance.cle`) : uid du joueur
  /// (avec le MJ), `MessageSeance.general` (toute la table) ou « pj:a|b »
  /// (deux joueurs, 20/11/2026).
  List<MessageSeance> messagesAvec(String cle) => [
        for (final m in [...?_anciens, ..._messages])
          if (m.cle == cle) m,
      ];

  /// Conversations proposées (20/11/2026) : pour le MJ, une par joueur ;
  /// pour un PJ, le MJ puis les autres PJ ; toute la table pour tous.
  List<({String cle, String nom})> get conversations => [
        if (estMj)
          for (final m in joueurs) (cle: m.uid, nom: m.personnageNom)
        else ...[
          (cle: uid, nom: 'MJ'),
          for (final m in joueurs)
            if (m.uid != uid)
              (cle: MessageSeance.entrePj(uid, m.uid), nom: m.personnageNom),
        ],
        (cle: MessageSeance.general, nom: 'Toute la table'),
      ];

  /// Nom de qui a écrit un message (conversation générale) : son
  /// personnage, ou « MJ ».
  String nomAuteurMessage(MessageSeance m) {
    if (m.de == campagne?.mj) return 'MJ';
    for (final x in joueurs) {
      if (x.uid == m.de) return x.personnageNom;
    }
    return 'Joueur';
  }

  /// Lit une fois les messages des séances précédentes.
  Future<String?> chargerAnciensMessages() => _agir((s, c) async {
        final tous = await s.lireMessages(c);
        _anciens = [
          for (final m in tous)
            if (m.seance != _numero) m,
        ];
        notifyListeners();
      });

  int _recusAvec(String cle) =>
      _messages.where((m) => m.cle == cle && m.de != uid).length;

  /// Messages reçus pas encore lus dans la conversation avec [joueur].
  int nonLusAvec(String joueur) {
    final n = _recusAvec(joueur) - (_lus[joueur] ?? 0);
    return n > 0 ? n : 0;
  }

  /// Messages reçus pas encore lus, toutes conversations confondues.
  int get nonLus {
    final cles = {for (final m in _messages) m.cle};
    return cles.fold(0, (n, k) => n + nonLusAvec(k));
  }

  /// La conversation avec [joueur] est à l'écran : ses messages sont lus.
  void marquerMessagesLus(String joueur) {
    final recus = _recusAvec(joueur);
    if (recus == (_lus[joueur] ?? 0)) return;
    _lus[joueur] = recus;
    notifyListeners();
  }

  /// Envoie un message dans la conversation [cle] : uid du joueur (avec le
  /// MJ), toute la table, ou deux joueurs entre eux.
  Future<String?> envoyerMessage(String cle, String texte) {
    return _agir((s, c) async {
      final t = texte.trim();
      if (t.isEmpty) return;
      final avecMj = cle != MessageSeance.general && !cle.startsWith('pj:');
      await s.envoyerMessage(
        c,
        MessageSeance(
          de: uid,
          joueur: avecMj ? cle : (estMj ? '' : uid),
          mj: c.mj,
          texte: t,
          date: DateTime.now(),
          seance: _numero,
          conversation: avecMj ? '' : cle,
        ),
      );
    });
  }

  void _signalerPresence(bool present) {
    if (estMj) return;
    unawaited(_agir((s, c) => s.signalerPresence(c, present: present)));
  }

  /// Le joueur est-il dans la séance ? (Jamais absent pour lui-même.)
  bool estPresent(String joueur) {
    if (joueur == uid) return true;
    final maintenant = DateTime.now();
    if (_presences[joueur]?.estLa(maintenant) ?? false) return true;
    // Un jet récent prouve aussi qu'il est là.
    return _jets.any(
      (j) =>
          j.auteur == joueur &&
          maintenant.difference(j.date) < PresenceSeance.delaiAbsence,
    );
  }

  void _campagneChangee() {
    _suivreSelonPermissions();
    notifyListeners();
  }

  /// Ce que ce compte reçoit dépend des permissions : créatures, ressources
  /// et fiches sont relues quand elles changent.
  void _suivreSelonPermissions() {
    final c = campagne;
    final s = _service;
    if (c == null || s == null) return;
    final cle = '${c.parametres.versJson()}';
    if (cle == _permissions) return;
    _permissions = cle;
    _creaturesFlux?.cancel();
    _ressourcesFlux?.cancel();
    _creaturesFlux = s.seance.ecouterCreatures(c).listen((v) {
      _creatures = v;
      _completerCa();
      unawaited(_synchroniserCompagnons());
      notifyListeners();
    }, onError: (Object _) {});
    _ressourcesFlux = s.seance.ecouterRessources(c).listen((v) {
      _ressources = v;
      notifyListeners();
    }, onError: (Object _) {});
    _suivreFiches();
  }

  /// Suit les fiches des autres joueurs que ce compte peut lire.
  /// Personnages dont les événements sont rattachés à cette séance.
  final Set<String> _personnagesMarques = {};

  /// Rattache à la séance les événements des fiches qu'elle touche (la
  /// sienne pour un joueur, celles des joueurs pour le MJ) : l'historique
  /// du personnage les regroupe.
  void _marquerSeance() {
    final c = campagne;
    if (c == null) return;
    final titre = '${c.nom} · ${c.titreSeance(_numero)}';
    for (final m in _membres) {
      if (m.personnageId.isEmpty || (!estMj && m.uid != uid)) continue;
      Personnage.seancesEnCours[m.personnageId] = titre;
      _personnagesMarques.add(m.personnageId);
    }
  }

  void _suivreFiches() {
    _marquerSeance();
    final c = campagne;
    final s = _service;
    if (c == null || s == null) return;
    final visibles = estMj
        ? c.parametres.fichesVisiblesMj
        : c.parametres.fichesEntrePj(enSeance: true);
    final ids = {
      if (visibles)
        for (final m in joueurs)
          if (m.uid != uid) m.personnageId,
    };
    for (final id in _fichesFlux.keys.toList()) {
      if (ids.contains(id)) continue;
      _fichesFlux.remove(id)?.cancel();
      _fiches.remove(id);
    }
    for (final id in ids) {
      _fichesFlux[id] ??= s.ecouterFiche(id).listen((p) {
        // Une modification du MJ en attente garde la main.
        if (_aEcrire.containsKey(id)) return;
        _essaisFiche.remove(id);
        if (p == null) {
          _fiches.remove(id);
        } else {
          _fiches[id] = p;
        }
        notifyListeners();
        unawaited(_synchroniserCompagnons());
      }, onError: (Object _) {
        // Pas encore partagée (permission qui vient de changer, joueur qui
        // change de personnage) : nouvel essai dans quelques secondes.
        _fichesFlux.remove(id)?.cancel();
        final n = (_essaisFiche[id] ?? 0) + 1;
        _essaisFiche[id] = n;
        if (n <= _essaisFicheMax) {
          _minuterieEssaiFiches ??= Timer(delaiEssaiFiche, () {
            _minuterieEssaiFiches = null;
            _suivreFiches();
          });
        }
      });
    }
  }

  /// MJ : une initiative a changé (joueur arrivé) : ordre recalculé.
  Future<void> _ajusterOrdre() async {
    if (!estMj || !_etat.enCombat) return;
    final ordre =
        ordreCombat(joueurs, _creatures, bonusInitiative: _bonusInitiative);
    if (listEquals(ordre, _etat.ordre)) return;
    await _agir((s, c) => s.changerOrdre(c, ordre));
  }

  /// MJ : fiches qu'il a modifiées lui-même, et quand (le joueur les reçoit,
  /// puis republie ses PV : la fiche du MJ garde la main entre-temps).
  final Map<String, DateTime> _modifiesParMj = {};
  static const Duration _attenteRepublication = Duration(seconds: 20);

  bool _modifieeParMj(String joueur) {
    if (!estMj) return false;
    for (final m in _membres) {
      if (m.uid != joueur) continue;
      final quand = _modifiesParMj[m.personnageId];
      return quand != null &&
          DateTime.now().difference(quand) < _attenteRepublication;
    }
    return false;
  }

  /// MJ : enregistre une fiche modifiée ; la première écriture part tout de
  /// suite, les suivantes sont regroupées toutes les 3 secondes.
  Future<void> enregistrerFiche(Personnage p) async {
    _aEcrire[p.id] = p;
    _modifiesParMj[p.id] = DateTime.now();
    notifyListeners();
    if (_minuterieFiches == null) await _ecrireFiches();
  }

  Future<void> _ecrireFiches() async {
    if (_aEcrire.isEmpty) return;
    final lot = _aEcrire.values.toList();
    _aEcrire.clear();
    _minuterieFiches = Timer(delaiEcritureMj, () {
      _minuterieFiches = null;
      unawaited(_ecrireFiches());
    });
    for (final p in lot) {
      await campagnes.agir((s) => s.ecrireFiche(p));
    }
  }

  /// MJ : enregistre les paramètres et permissions de la campagne.
  Future<String?> enregistrerParametres(ParametresCampagne p) => _agir(
      (s, c) => campagnes.serviceActuel!.modifier(c.copie(parametres: p)));

  void _personnagesChanges() {
    final f = estMj ? null : maFiche;
    final niveau = f?.personnage.niveau;
    if (niveau != null && _niveauVu != null && niveau != _niveauVu) {
      // Montée de niveau pendant la séance (13/11/2026) : nouveaux PV, PM
      // et PE publiés tout de suite, et la fiche envoyée en ligne (le MJ la
      // lit : niveau, compétences), même en envoi différé.
      _minuteriePublication?.cancel();
      _minuteriePublication = null;
      unawaited(_publier(force: true));
      unawaited(campagnes.compte.synchroniser());
    } else {
      unawaited(_publier());
    }
    if (niveau != null) _niveauVu = niveau;
    notifyListeners();
  }

  /// Niveau du personnage du joueur, pour repérer une montée de niveau.
  int? _niveauVu;

  /// Joueur : publie PV, PM, PE, résumé, initiative et CA quand ils changent.
  Future<void> _publier({bool force = false}) async {
    final c = campagne;
    final f = maFiche;
    if (c == null || f == null || !c.joueurs.contains(uid)) return;
    _niveauVu ??= f.personnage.niveau;
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
    final ressourcesChangent = r != _publiees;
    final nom = f.personnage.nom.trim();
    final sante = SantePj.depuisPv(f.pvActuels, f.pvMax).name;
    final membreChange = resume != _resumePublie ||
        sante != _santePubliee ||
        nom != _nomPublie ||
        f.initiative != _initiativePubliee ||
        f.classeArmure != _caPubliee;
    if (!ressourcesChangent && !membreChange) return;
    if (!force) {
      // Changement trop rapproché : publié à la fin du délai.
      if (_minuteriePublication != null) return;
      final dernier = _dernierePublication;
      final reste = dernier == null
          ? Duration.zero
          : delaiEcritureJoueur - DateTime.now().difference(dernier);
      if (reste > Duration.zero) {
        _minuteriePublication = Timer(reste, () {
          _minuteriePublication = null;
          unawaited(_publier(force: true));
        });
        return;
      }
    }
    _dernierePublication = DateTime.now();
    _publiees = r;
    _resumePublie = resume;
    _initiativePubliee = f.initiative;
    _caPubliee = f.classeArmure;
    _santePubliee = sante;
    _nomPublie = nom;
    // Seul ce qui a changé est écrit (PV seuls le plus souvent).
    final erreur = await campagnes.agir(
      (x) => x.seance.publierPersonnage(
        c,
        ressources: ressourcesChangent ? r : null,
        resume: membreChange ? resume : null,
        initiative: membreChange ? f.initiative : null,
        ca: membreChange ? f.classeArmure : null,
        nom: membreChange && nom.isNotEmpty ? nom : null,
        sante: membreChange ? sante : null,
      ),
    );
    // Échec : réessayé au prochain changement.
    if (erreur != null) _publiees = null;
  }

  /// Action sur la partie ; renvoie l'erreur en français, ou `null`.
  Future<String?> _agir(
    Future<void> Function(ServiceSeance s, Campagne c) action,
  ) async {
    final c = campagne;
    if (c == null) return 'Cette campagne n\'existe plus.';
    return campagnes.agir((s) => action(s.seance, c));
  }

  /// MJ : combat (ordre par initiative) ou exploration. Le début d'un
  /// combat est noté dans le récapitulatif de la séance.
  Future<String?> basculerMode({
    DateTime? maintenant,
    List<String> embusques = const [],
  }) async {
    final debut = !_etat.enCombat;
    final erreur = await _agir((s, c) => _etat.enCombat
        ? s.passerEnExploration(c)
        : s.demarrerCombat(c,
            ordreCombat(joueurs, _creatures, bonusInitiative: _bonusInitiative),
            embusques: embusques));
    if (erreur != null) return erreur;
    // Embuscade (21/11/2026) : notée dans le récapitulatif.
    if (debut && embusques.isNotEmpty) {
      await noterDansRecap('Embuscade : ${[
        for (final id in embusques) nomParticipant(id),
      ].join(', ')}');
    }
    final h = maintenant ?? DateTime.now();
    if (debut) {
      // Sans les compagnons ni les invocations des joueurs ; les
      // adversaires identiques regroupés (« 2 Aigles »).
      final adversaires = resumeAdversaires([
        for (final c in _creatures)
          if (!c.duCotePj) c.nom,
      ]);
      _debutCombat = h;
      await noterDansRecap(
        'Début du combat à ${_heure(h)}'
        '${adversaires.isEmpty ? '' : ' : $adversaires'}',
        maintenant: h,
      );
    } else {
      final depuis = _debutCombat;
      _debutCombat = null;
      final duree = depuis == null ? null : h.difference(depuis).inMinutes;
      await noterDansRecap(
        'Fin du combat à ${_heure(h)}'
        '${duree == null ? '' : ' ($duree min)'}',
        maintenant: h,
      );
    }
    return null;
  }

  /// Heure du début du combat en cours (MJ, pour sa durée).
  DateTime? _debutCombat;

  static String _heure(DateTime h) => '${h.hour.toString().padLeft(2, '0')}:'
      '${h.minute.toString().padLeft(2, '0')}';

  /// MJ : lieu de la scène, noté dans le récapitulatif de la séance, avec
  /// l'ancien lieu (« Forêt enchantée → Blancherive »).
  Future<String?> changerLieu(String lieu) async {
    final nouveau = lieu.trim();
    final ancien = _etat.lieu.trim();
    final change = nouveau != ancien;
    final erreur = await _agir((s, c) => s.changerInfos(c, lieu: nouveau));
    if (erreur == null && change && nouveau.isNotEmpty) {
      final texte =
          ancien.isEmpty ? 'Lieu : $nouveau' : 'Lieu : $ancien → $nouveau';
      await noterDansRecap(texte);
      // Aussi dans les logs, pour tous (21/11/2026).
      await _agir(
        (s, c) => s.lancer(
          c,
          JetSeance(
            auteur: uid,
            auteurNom: 'MJ',
            libelle: texte,
            detail: '',
            total: 0,
            date: DateTime.now(),
            seance: _numero,
            lecteurs: lecteursDuJet(c, VisibiliteJet.tous, auteur: uid),
            genre: GenreJet.lieu,
            mode: _etat.mode,
            manche: _etat.manche,
          ),
        ),
      );
    }
    return erreur;
  }

  /// MJ : autorise ou retire la montée de niveau d'un joueur.
  Future<String?> basculerMontee(
    String joueur,
    int niveau, {
    String personnage = '',
  }) async {
    final montees = Map<String, int>.of(_etat.montees);
    final autorise = !_etat.peutMonter(joueur, niveau, personnage: personnage);
    // Une seule autorisation par joueur : celle de son personnage actuel.
    montees.removeWhere((k, _) => k == joueur || k.startsWith('$joueur:'));
    if (autorise) {
      montees[EtatJeu.cleMontee(joueur, personnage)] = niveau + 1;
    }
    // Pas de note ici : seule la vraie montée de niveau est notée
    // (19/11/2026, voir [_noterMontees]).
    return _agir((s, c) => s.changerInfos(c, montees: montees));
  }

  /// Niveaux des personnages (« uid:personnage » → niveau), pour noter les
  /// vraies montées de niveau.
  final Map<String, int> _niveauxVus = {};

  /// MJ : un personnage a changé de niveau (son résumé « … · niveau 3 ») :
  /// noté dans le récapitulatif de la séance (19/11/2026).
  void _noterMontees() {
    if (!estMj) return;
    for (final m in joueurs) {
      final n = int.tryParse(
        RegExp(r'niveau (\d+)').firstMatch(m.personnageResume)?[1] ?? '',
      );
      if (n == null) continue;
      final cle = '${m.uid}:${m.personnageId}';
      final avant = _niveauxVus[cle];
      _niveauxVus[cle] = n;
      if (avant != null && n > avant) {
        unawaited(noterDansRecap('${m.personnageNom} passe au niveau $n'));
      }
    }
  }

  /// MJ : fin de la séance, avec son heure et sa durée (19/11/2026).
  Future<void> noterFinSeance({DateTime? maintenant}) async {
    final h = maintenant ?? DateTime.now();
    final debut = campagne?.seance?.debut;
    final minutes = debut == null ? null : h.difference(debut).inMinutes;
    String duree(int m) => m < 60
        ? '$m min'
        : '${m ~/ 60} h ${(m % 60).toString().padLeft(2, '0')}';
    await noterDansRecap(
      'Fin de la séance à ${_heure(h)}'
      '${minutes == null || minutes < 0 ? '' : ' (durée : ${duree(minutes)})'}',
      maintenant: h,
    );
  }

  /// MJ : ajoute une ligne horodatée (« - 20:15 · Lieu : Taverne ») au
  /// récapitulatif de la séance en cours (« Séances précédentes ») : les
  /// notes de séance se rédigent toutes seules.
  Future<void> noterDansRecap(String ligne, {DateTime? maintenant}) async {
    final c = campagne;
    if (c == null || !estMj) return;
    final h = maintenant ?? DateTime.now();
    String n(int v) => v.toString().padLeft(2, '0');
    final entree = '- ${n(h.hour)}:${n(h.minute)} · $ligne';
    await campagnes.agir((s) async {
      final avant = (await s.lireRecaps(c.id))[_numero] ?? '';
      await s.ecrireRecap(
        c.id,
        _numero,
        avant.trim().isEmpty ? entree : '${avant.trimRight()}\n$entree',
      );
    });
  }

  /// CA d'une cible (créature ou joueur) ; `null` : inconnue. Pour un joueur :
  /// avec ses bonus de CA de séance face à une attaque [contre] (« CaC »,
  /// « DIST », « MAG »), 19/11/2026.
  int? caDe(String id, {String? contre}) {
    for (final c in _creatures) {
      if (c.id == id) return c.ca ?? ficheCreature(c)?.ca;
    }
    // La fiche si ce compte la lit, sinon la CA publiée par le joueur.
    int? base;
    if (ficheDe(id) case final f?) {
      base = f.classeArmure;
    } else {
      for (final m in _membres) {
        if (m.uid == id) base = m.ca;
      }
    }
    return base == null
        ? null
        : base + BonusSeance.totalCa(bonus, id, contre: contre);
  }

  /// MJ : les créatures ajoutées avant la version 0.30.0 n'ont pas leur CA
  /// dans la partie, les PJ ne pourraient pas y comparer leurs attaques.
  void _completerCa() {
    if (!estMj) return;
    for (final c in _creatures) {
      final ca = c.ca == null ? ficheCreature(c)?.ca : null;
      if (ca != null && _caCompletees.add(c.id)) {
        unawaited(modifierCreature(c.copie(ca: ca)));
      }
    }
  }

  /// En combat : [id] a déjà attaqué ou lancé un sort pendant cette manche.
  bool dejaAttaque(String id) {
    if (!_etat.enCombat) return false;
    for (final j in _jets.reversed) {
      if (j.mode != ModeJeu.combat || j.manche != _etat.manche) return false;
      if (j.attaquant == id &&
          (j.genre == GenreJet.attaque || j.genre == GenreJet.sort)) {
        return true;
      }
    }
    return false;
  }

  /// Ligne des logs sans dés (butin, envoi d'objet).
  Future<void> _noter(
    ServiceSeance s,
    Campagne c,
    String libelle,
    VisibiliteJet visibilite,
  ) =>
      s.lancer(
        c,
        JetSeance(
          auteur: uid,
          auteurNom: moi?.personnageNom ?? 'Joueur',
          libelle: libelle,
          detail: '',
          total: 0,
          date: DateTime.now(),
          seance: _numero,
          lecteurs: lecteursDuJet(c, visibilite, auteur: uid),
          visibilite: visibilite,
          mode: _etat.mode,
          manche: _etat.manche,
        ),
      );

  /// Invocation temporaire disparue (19/11/2026) : notée dans les logs avec
  /// la raison (vaincu, durée expirée, renvoyée).
  Future<void> _noterDisparition(
    ServiceSeance s,
    Campagne c,
    CreatureSeance x,
    String raison,
  ) {
    var lanceur = '';
    for (final m in joueurs) {
      if (m.uid == x.proprietaire) lanceur = m.personnageNom;
    }
    return _noter(
      s,
      c,
      '${x.nom}${lanceur.isEmpty ? '' : ' (invocation de $lanceur)'} '
      'disparaît : $raison',
      VisibiliteJet.tous,
    );
  }

  /// Nuit de repos d'un personnage (19/11/2026) : notée dans les logs, avec
  /// les jets de regain (PM et PE seulement s'il en a).
  Future<String?> noterRepos(String personnage, String detail) =>
      _agir((s, c) => _noter(
            s,
            c,
            '$personnage · ${detail.replaceAll(RegExp(r'\.$'), '')}',
            VisibiliteJet.tous,
          ));

  /// MJ : nouveau butin, caché par défaut (12/11/2026) : le MJ le remplit
  /// (argent, objets) avant de le révéler aux joueurs.
  Future<String?> creerButin(String nom) => _agir((s, c) => s.ecrireButin(
        c,
        ButinSeance(
          nom: nom.trim().isEmpty ? 'Butin' : nom.trim(),
          cache: true,
        ),
      ));

  Future<String?> modifierButin(ButinSeance butin) =>
      _agir((s, c) => s.ecrireButin(c, butin));

  Future<String?> retirerButin(ButinSeance butin) => _agir((s, c) async {
        await s.retirerButin(c, butin.id);
        if (_carte == butin.id) _carte = kCarteScript;
      });

  /// PJ : prend de l'argent ou un objet du butin, ajoutés à sa fiche.
  Future<String?> prendreDuButin(
    ButinSeance butin, {
    Bourse? argent,
    Objet? objet,
    int? quantite,
  }) async {
    final f = maFiche;
    if (f == null) return 'Ta fiche n\'est pas disponible.';
    return _agir((s, c) async {
      final pris = await s.prendreButin(
        c,
        butin.id,
        argent: argent,
        objetId: objet?.id,
        quantite: quantite,
      );
      final o = pris.objet;
      if (o == null && pris.argent.vide) return;
      final p = f.personnage;
      p.bourse
        ..or += pris.argent.or
        ..argent += pris.argent.argent
        ..cuivre += pris.argent.cuivre;
      if (o != null) p.inventaire.addAll(o.separe());
      final quoi = [
        if (o != null) o.quantite > 1 ? '${o.nom} ×${o.quantite}' : o.nom,
        if (!pris.argent.vide) pris.argent.texte,
      ].join(', ');
      p.journaliser(
        'Pris dans ${butin.nom} : $quoi',
        categorie: CategorieHistorique.inventaire,
      );
      await personnages.sauvegarder(p);
      await _noter(s, c, 'Prend $quoi (${butin.nom})', VisibiliteJet.tous);
    });
  }

  /// PJ : envoie [quantite] exemplaires d'un objet non équipé à [joueur].
  /// [discret] : il n'est pas prévenu.
  Future<String?> envoyerObjet(
    Objet objet,
    String joueur, {
    int quantite = 1,
    bool discret = false,
  }) async {
    final f = maFiche;
    if (f == null) return 'Ta fiche n\'est pas disponible.';
    if (objet.equipe) return 'Déséquipe d\'abord cet objet.';
    final n = quantite.clamp(1, objet.quantite);
    final copie = Objet.depuisJson(objet.versJson()..remove('id'))
      ..quantite = n;
    var nomCible = '';
    for (final m in joueurs) {
      if (m.uid == joueur) nomCible = m.personnageNom;
    }
    return _agir((s, c) async {
      await s.envoyerObjet(
        c,
        EnvoiObjet(
          destinataire: joueur,
          auteur: uid,
          auteurNom: f.personnage.nom,
          objet: copie,
          discret: discret,
        ),
      );
      final p = f.personnage;
      if (n >= objet.quantite) {
        p.inventaire.remove(objet);
      } else {
        objet.quantite -= n;
      }
      p.journaliser(
        'Objet envoyé à $nomCible : ${objet.nom}'
        '${n > 1 ? ' ×$n' : ''}${discret ? ' (discrètement)' : ''}',
        categorie: CategorieHistorique.inventaire,
      );
      await personnages.sauvegarder(p);
      await _noter(
        s,
        c,
        'Envoie ${objet.nom} à $nomCible${discret ? ' (discrètement)' : ''}',
        VisibiliteJet.mjEtAuteur,
      );
    });
  }

  void _traiterEnvois() {
    if (maFiche == null) return;
    for (final e in _envois) {
      if (!_envoisPris.add(e.id)) continue;
      _fileEnvois = _fileEnvois.then((_) => _recevoir(e));
    }
  }

  /// Ajoute un objet reçu à la fiche ; prévenu, sauf envoi discret.
  Future<void> _recevoir(EnvoiObjet e) async {
    await _agir((s, c) async {
      if (!await s.prendreEnvoi(c, e.id)) return;
      final f = maFiche;
      if (f == null) return;
      final p = f.personnage..inventaire.addAll(e.objet.separe());
      if (!e.discret) {
        p.journaliser(
          'Objet reçu de ${e.auteurNom} : ${e.objet.nom}',
          categorie: CategorieHistorique.inventaire,
        );
      }
      await personnages.sauvegarder(p);
      if (!e.discret) {
        annonce.value = '${e.auteurNom} t\'a envoyé : ${e.objet.nom}';
      }
    });
  }

  /// MJ : donne un objet au joueur dont il voit la fiche.
  Future<String?> donnerObjet(String joueur, Objet objet) async {
    final f = ficheDe(joueur);
    if (f == null) return 'Fiche non partagée.';
    f.personnage.inventaire.addAll(objet.separe());
    f.personnage.journaliser(
      'Objet reçu du MJ : ${objet.nom}',
      categorie: CategorieHistorique.inventaire,
    );
    await enregistrerFiche(f.personnage);
    return null;
  }

  Future<String?> passerTour() => _agir((s, c) => s.passerTour(c));

  /// Celui dont c'est le tour est à terre (0 PV ou moins, 20/11/2026) :
  /// le MJ confirme s'il joue son tour. Clé « manche:actif » (une seule
  /// question par tour), `null` sinon.
  String? get tourAConfirmer {
    if (!estMj || !_etat.enCombat) return null;
    final a = _etat.actif;
    if (a == null) return null;
    int? pv;
    for (final x in _creatures) {
      if (x.id == a) pv = x.pv;
    }
    if (joueurs.any((m) => m.uid == a)) pv = ressourcesDe(a)?.pv;
    return pv != null && pv <= 0 ? '${_etat.manche}:$a' : null;
  }

  Future<String?> tourPrecedent() => _agir((s, c) => s.tourPrecedent(c));

  /// MJ : ajoute une créature du bestiaire (numérotée si elle y est déjà) ;
  /// en combat, elle prend sa place dans l'ordre.
  Future<String?> ajouterCreature(
    Creature creature, {
    bool cachee = false,
    bool nomCache = false,
    bool allie = false,
    bool neutre = false,
  }) =>
      _agir((s, c) async {
        await s.ajouterCreature(
          c,
          CreatureSeance(
            id: '',
            nom: nomNumerote(creature.nom, _creatures.map((x) => x.nom)),
            creatureId: creature.id,
            famille: creature.famille,
            description: creature.description,
            initiative: creature.initiative ?? 0,
            pv: creature.pv,
            pvMax: creature.pv,
            ca: creature.ca,
            cachee: cachee,
            nomCache: nomCache,
            allie: allie,
            neutre: neutre && !allie,
          ),
        );
        await _reordonner(s, c);
      });

  /// En combat : ordre recalculé avec les créatures à jour.
  Future<void> _reordonner(ServiceSeance s, Campagne c) async {
    if (!_etat.enCombat) return;
    final liste = await s.ecouterCreatures(c).first;
    await s.changerOrdre(
        c, ordreCombat(joueurs, liste, bonusInitiative: _bonusInitiative));
  }

  Future<String?> modifierCreature(CreatureSeance creature) =>
      _agir((s, c) => s.modifierCreature(c, creature));

  /// MJ : retire une créature de la partie (et de l'ordre). Invocation
  /// temporaire : sa disparition est notée dans les logs, avec [raison].
  Future<String?> retirerCreature(
    CreatureSeance creature, {
    String raison = 'renvoyée par le MJ',
  }) =>
      _agir((s, c) async {
        await s.retirerCreature(c, creature.id);
        await _retirerPions(c, creature.id);
        if (creature.toursRestants != null) {
          await _noterDisparition(s, c, creature, raison);
        }
        await _reordonner(s, c);
        if (_carte == creature.id) _carte = kCarteScript;
      });

  /// Nom affiché pour un jet de qui agit (attaque, test) : le personnage ou
  /// la créature. Un jet que voient les PJ ne révèle ni un nom caché, ni une
  /// créature dont la carte est cachée.
  String nomDuJet(VisibiliteJet visibilite) {
    final c = creatureChoisie;
    if (estMj && c != null) {
      if (visibilite == VisibiliteJet.mjSeul) return c.nom;
      return c.cachee ? 'MJ' : c.nomPublic;
    }
    final nom = attaquant.nom;
    return nom.isEmpty ? (estMj ? 'MJ' : 'Joueur') : nom;
  }

  /// Créature qui quitte la partie (21/11/2026) : ses pions disparaissent
  /// des cartes (un échec n'empêche pas le retrait).
  Future<void> _retirerPions(Campagne c, String id) async {
    try {
      await campagnes.serviceActuel?.retirerPionsDe(c, id);
    } catch (_) {}
  }

  /// Nom d'un participant au combat (personnage ou créature).
  String nomParticipant(String id) {
    for (final m in joueurs) {
      if (m.uid == id) return m.personnageNom;
    }
    for (final c in _creatures) {
      if (c.id == id) return c.nom;
    }
    return id;
  }

  /// Participants possibles d'une embuscade : personnages et créatures qui
  /// ont leur propre tour (pas les compagnons).
  List<({String id, String nom, bool joueur})> get participantsCombat => [
        for (final m in joueurs)
          (id: m.uid, nom: m.personnageNom, joueur: true),
        for (final c in _creatures)
          if (!c.estCompagnon) (id: c.id, nom: c.nom, joueur: false),
      ];

  /// Celui qui agit dans le lancer de dés : joueur (uid) ou créature (id).
  String get idAttaquant => estMj ? creatureChoisie?.id ?? _acteur : uid;

  /// Cibles possibles d'une attaque ou d'un sort, sauf celui qui agit. La
  /// première sert de cible par défaut : une créature rencontrée pour un PJ
  /// ou pour un compagnon / une invocation, un PJ pour une créature du MJ.
  List<({String id, String nom})> get cibles {
    final soi = idAttaquant;
    final rencontrees = [
      for (final c in _creatures)
        if (c.id != soi && !c.duCotePj) (id: c.id, nom: c.nom),
    ];
    final desJoueurs = [
      for (final c in _creatures)
        if (c.id != soi && c.duCotePj) (id: c.id, nom: c.nom),
    ];
    final lesJoueurs = [
      for (final m in joueurs)
        if (m.uid != soi) (id: m.uid, nom: m.personnageNom),
    ];
    final choisie = estMj ? creatureChoisie : null;
    return choisie != null && !choisie.duCotePj
        ? [...lesJoueurs, ...desJoueurs, ...rencontrees]
        : [...rencontrees, ...lesJoueurs, ...desJoueurs];
  }

  /// Cibles proposées dans la fenêtre de cibles (19/11/2026), avec leur camp
  /// vu de celui qui agit : soi-même, allié ou ennemi. Ordre de [cibles]
  /// (ennemis d'abord pour un PJ), puis soi-même.
  List<CibleSeance> get ciblesPotentielles {
    final soi = idAttaquant;
    final choisie = estMj ? creatureChoisie : null;
    final cotePj = choisie == null || choisie.duCotePj;
    bool estCotePj(String id) =>
        joueurs.any((m) => m.uid == id) ||
        _creatures.any((c) => c.id == id && c.duCotePj);
    // Neutres (21/11/2026) : à part, ni alliés ni ennemis.
    bool estNeutre(String id) => _creatures.any((c) => c.id == id && c.neutre);
    return [
      for (final c in cibles)
        (
          id: c.id,
          nom: c.nom,
          camp: estNeutre(c.id)
              ? CampCible.neutre
              : estCotePj(c.id) == cotePj
                  ? CampCible.allie
                  : CampCible.ennemi,
        ),
      if (soi.isNotEmpty) (id: soi, nom: attaquant.nom, camp: CampCible.soi),
    ];
  }

  /// Soin (19/11/2026) : PV rendus à la cible, sans dépasser ses PV max ;
  /// envoyé comme des dégâts de type « soin » à qui peut écrire sa fiche.
  Future<String?> soigner(String cible, int montant, String source) =>
      infligerDegats(cible, montant, source, type: kTypeSoin);

  /// PV, PM, PE d'une carte, à jour : sa propre fiche pour le joueur ; pour
  /// les autres, ce que le joueur a publié depuis sa fiche (13/11/2026).
  /// La fiche en ligne peut avoir du retard (envoi différé du compte : PV
  /// après une esquive, nouveaux maximums après une montée de niveau) ; le
  /// MJ ne la préfère que juste après l'avoir modifiée lui-même.
  RessourcesPj? ressourcesDe(String joueur) {
    final publiees = _ressources[joueur];
    if (joueur != uid && publiees != null && !_modifieeParMj(joueur)) {
      return publiees;
    }
    final f = joueur == uid || estMj ? ficheDe(joueur) : null;
    if (f == null) return publiees;
    return RessourcesPj(
      pv: f.pvActuels,
      pvMax: f.pvMax,
      pm: f.pmActuels,
      pmMax: f.pmMax,
      pe: f.peActuels,
      peMax: f.peMax,
    );
  }

  /// Envoie des dégâts à la cible : retirés de ses PV par le joueur (sa
  /// fiche, après sa RD) ou par le MJ (créature : pas de RD au bestiaire).
  /// [esquive] : difficulté du jet d'esquive du joueur visé (attaque sans
  /// jet d'attaque) ; [moitie] : esquive réussie = moitié des dégâts.
  Future<String?> infligerDegats(
    String cible,
    int montant,
    String source, {
    String type = 'physique',
    int? esquive,
    bool moitie = false,
  }) {
    final c0 = campagne;
    if (c0 == null) return Future.value('Cette campagne n\'existe plus.');
    if (montant <= 0 || cible.isEmpty) return Future.value();
    final d = DegatsSeance(
      cible: cible,
      destinataire: joueurs.any((m) => m.uid == cible) ? cible : c0.mj,
      auteur: uid,
      montant: montant,
      source: source,
      type: type,
      difficulteEsquive: esquive,
      moitieSiEsquive: moitie,
    );
    // Pour soi-même (MJ → créature, PJ → lui-même) : appliqué ici, sans
    // passer par la base (19/11/2026). En ligne, la transaction qui prend
    // les dégâts ne voyait pas encore le document qu'on venait d'écrire :
    // les dégâts étaient perdus (élémentaire du MJ contre un jeune ours).
    if (d.destinataire == uid && esquive == null) {
      _fileDegats = _fileDegats.then((_) => _appliquerDegats(d, stocke: false));
      return _fileDegats.then((_) => null);
    }
    return _agir((s, c) => s.envoyerDegats(c, d));
  }

  /// Attaques sans jet d'attaque qui visent ce joueur : il choisit
  /// d'esquiver ou de subir les dégâts.
  final List<DegatsSeance> _esquives = [];
  List<DegatsSeance> get esquivesEnAttente => List.unmodifiable(_esquives);

  /// Préfixe des jets faits en réaction, hors de son tour (20/11/2026).
  static const prefixeReaction = 'Réaction · ';

  /// Une seule réaction par manche (20/11/2026) : déjà faite ?
  bool get reactionUtilisee =>
      _etat.enCombat &&
      _jets.any(
        (j) =>
            j.auteur == uid &&
            j.libelle.startsWith(prefixeReaction) &&
            j.mode == ModeJeu.combat &&
            j.manche == _etat.manche,
      );

  /// Actions qui restent au PJ pendant son tour de combat (20/11/2026),
  /// selon la limite de la campagne ; `null` : pas de limite (MJ, hors
  /// combat, réglage « sans limite »). Les réactions ne comptent pas.
  int? get actionsRestantes {
    final max = campagne?.parametres.actionsParTour ?? 0;
    if (estMj || !_etat.enCombat || max <= 0) return null;
    final faites = _jets
        .where(
          (j) =>
              j.auteur == uid &&
              j.action &&
              !j.libelle.startsWith(prefixeReaction) &&
              j.mode == ModeJeu.combat &&
              j.manche == _etat.manche,
        )
        .length;
    return max - faites < 0 ? 0 : max - faites;
  }

  /// Une seule esquive par tour de combat (règles §3.3).
  bool get esquiveUtilisee =>
      _etat.enCombat &&
      _jets.any(
        (j) =>
            j.auteur == uid &&
            j.libelle.startsWith("Jet d'esquive") &&
            j.mode == ModeJeu.combat &&
            j.manche == _etat.manche,
      );

  /// Réponse du joueur à une attaque sans jet : [esquiver] lance
  /// 1d20 + bonus d'esquive contre la difficulté ; réussi, aucun dégât (ou
  /// la moitié pour un souffle). Renvoie le jet, les dégâts subis (avant la
  /// RD), la RD et les PV réellement perdus.
  Future<({ResultatLancer? jet, int subis, int rd, int perdus})>
      repondreEsquive(
    DegatsSeance d, {
    required bool esquiver,
    math.Random? aleatoire,
  }) async {
    _esquives.removeWhere((x) => x.id == d.id);
    _degatsPris.add(d.id);
    final f = maFiche;
    ResultatLancer? r;
    var montant = d.montant;
    if (esquiver && f != null && !esquiveUtilisee) {
      r = ResultatLancer.lancer(
        libelle: "Jet d'esquive",
        de: '1d20',
        bonus: f.bonusJetEsquive,
        origineBonus: 'esquive',
        difficulte: d.difficulteEsquive,
        // Bonus de séance reçus (« tous les jets »).
        situations: bonusApplicables(uid, genre: GenreJet.test, d20: true),
        aleatoire: aleatoire,
      );
      if (r != null) {
        final ok = r.reussite ?? false;
        montant = !ok
            ? d.montant
            : d.moitieSiEsquive
                ? d.montant ~/ 2
                : 0;
        final issue = !ok
            ? 'esquive ratée'
            : d.moitieSiEsquive
                ? 'esquive réussie : moitié des dégâts'
                : 'esquive réussie : aucun dégât';
        await lancer(
          libelle: "Jet d'esquive · ${d.source}",
          detail: '${r.detail} · $issue',
          total: r.total,
          visibilite: VisibiliteJet.tous,
          genre: GenreJet.test,
        );
        await journaliserJet(
            f, "Jet d'esquive : ${r.total} (${r.detail}) · $issue");
      }
    }
    notifyListeners();
    if (montant <= 0) {
      await _agir((s, c) async {
        await s.prendreDegats(c, d.id);
      });
    } else {
      _fileDegats =
          _fileDegats.then((_) => _appliquerDegats(d.copie(montant: montant)));
      await _fileDegats;
    }
    final rd = montant > 0 ? f?.rdContre(d.type) ?? 0 : 0;
    return (
      jet: r,
      subis: montant,
      rd: rd,
      perdus: math.max(0, montant - rd),
    );
  }

  void _traiterDegats() {
    for (final d in _degats) {
      // Sa fiche doit être chargée pour lui retirer des PV.
      if (d.cible == uid && maFiche == null) continue;
      // Attaque sans jet : le joueur répond d'abord (esquive).
      if (d.cible == uid && d.difficulteEsquive != null) {
        if (!_degatsPris.contains(d.id) &&
            !_esquives.any((x) => x.id == d.id)) {
          _esquives.add(d);
        }
        continue;
      }
      if (!_degatsPris.add(d.id)) continue;
      _fileDegats = _fileDegats.then((_) => _appliquerDegats(d));
    }
  }

  /// [stocke] : dégâts lus dans la base (pris une seule fois, par
  /// transaction) ; sinon appliqués directement (dégâts pour soi-même).
  Future<void> _appliquerDegats(DegatsSeance d, {bool stocke = true}) async {
    await _agir((s, c) async {
      if (stocke && !await s.prendreDegats(c, d.id)) return;
      if (d.cible == uid) {
        final f = maFiche;
        if (f == null) return;
        final p = f.personnage;
        final avant = f.pvActuels;
        if (d.type == kTypeSoin) {
          final apres = math.max(avant, math.min(f.pvMax, avant + d.montant));
          p
            ..pvActuels = apres
            ..journaliser(
              '${d.source} : +${apres - avant} PV · PV : $avant → $apres',
              categorie: CategorieHistorique.vie,
            );
          await personnages.sauvegarder(p);
          _minuteriePublication?.cancel();
          _minuteriePublication = null;
          unawaited(_publier(force: true));
          return;
        }
        final rd = f.rdContre(d.type);
        final net = math.max(0, d.montant - rd);
        final apres = math.max(avant - net, -f.deVie - 1);
        p
          ..pvActuels = apres
          ..journaliser(
            '${d.source} (${d.type}) : −$net PV'
            '${rd > 0 ? ' (RD $rd sur ${d.montant})' : ''} · PV : $avant → $apres',
            categorie: CategorieHistorique.vie,
          );
        await personnages.sauvegarder(p);
        // Dégâts reçus : les autres voient ses PV tout de suite, sans
        // attendre la fin du délai entre deux publications (13/11/2026).
        _minuteriePublication?.cancel();
        _minuteriePublication = null;
        unawaited(_publier(force: true));
        return;
      }
      final liste = await s.ecouterCreatures(c).first;
      for (final x in liste) {
        final pv = x.pv;
        if (x.id != d.cible || pv == null) continue;
        if (d.type == kTypeSoin) {
          final max = x.pvMax ?? pv + d.montant;
          await s.modifierCreature(
              c, x.copie(pv: math.max(pv, math.min(max, pv + d.montant))));
          continue;
        }
        final reste = math.max(0, pv - d.montant);
        // Invocation temporaire à 0 PV : elle se dissipe.
        if (reste == 0 && x.toursRestants != null) {
          await s.retirerCreature(c, x.id);
          await _retirerPions(c, x.id);
          await _noterDisparition(s, c, x, 'vaincu');
          if (_carte == x.id) _carte = kCarteScript;
          await _reordonner(s, c);
        } else {
          await s.modifierCreature(c, x.copie(pv: reste));
        }
      }
    });
    // Dégâts pour soi-même : aucun flux ne prévient, l'écran est redessiné ici.
    notifyListeners();
  }

  /// Nom de la cible dans un jet : même discrétion que pour le lanceur.
  String nomCible(String id, VisibiliteJet visibilite) {
    for (final m in joueurs) {
      if (m.uid == id) return m.personnageNom;
    }
    for (final c in _creatures) {
      if (c.id != id) continue;
      if (!estMj || visibilite == VisibiliteJet.mjSeul) return c.nom;
      return c.cachee ? '' : c.nomPublic;
    }
    return '';
  }

  /// Dépense le coût d'un sort (PM, ou PE pour une classe sans mana) sur la
  /// fiche de celui qui le lance.
  Future<void> depenserSort(FicheCalculee f, String nom, int cout) async {
    final p = f.personnage;
    final u = f.uniteSorts;
    final avant = f.pointsPourSorts;
    if (f.sortsEnEndurance) {
      p.peActuels = avant - cout;
    } else {
      p.pmActuels = avant - cout;
    }
    p.journaliser(
      'Sort lancé : $nom (−$cout $u) · $u : $avant → ${avant - cout}',
      categorie: CategorieHistorique.vie,
    );
    if (p.id == moi?.personnageId) {
      await personnages.sauvegarder(p);
    } else {
      await enregistrerFiche(p);
    }
  }

  /// Action de compétence payée en endurance (Moulinet : 2 PE).
  /// Met en favori une compétence ou un sort (par son nom), ou l'en retire :
  /// en séance, les favoris sont réunis dans un groupe en tête.
  Future<void> basculerFavori(FicheCalculee f, String nom) async {
    final p = f.personnage;
    if (!p.favoris.remove(nom)) p.favoris.add(nom);
    notifyListeners();
    if (p.id == moi?.personnageId) {
      await personnages.sauvegarder(p);
    } else {
      await enregistrerFiche(p);
    }
  }

  /// Jet lancé en séance : inscrit dans l'historique du personnage, avec le
  /// nom de la séance.
  Future<void> journaliserJet(FicheCalculee f, String texte) async {
    final c = campagne;
    final p = f.personnage;
    // Rattaché à la séance par `Personnage.seancesEnCours`.
    if (c != null) {
      Personnage.seancesEnCours[p.id] ??=
          '${c.nom} · ${c.titreSeance(_numero)}';
      _personnagesMarques.add(p.id);
    }
    p.journaliser(texte, categorie: CategorieHistorique.des);
    if (p.id == moi?.personnageId) {
      await personnages.sauvegarder(p);
    } else {
      await enregistrerFiche(p);
    }
  }

  Future<void> depenserAction(
    FicheCalculee f,
    ({String libelle, int cout, String origine}) a,
  ) async {
    final avant = f.peActuels;
    final p = f.personnage..peActuels = avant - a.cout;
    p.journaliser(
      '${a.libelle} (−${a.cout} PE) · PE : $avant → ${p.peActuels}',
      categorie: CategorieHistorique.vie,
    );
    if (p.id == moi?.personnageId) {
      await personnages.sauvegarder(p);
    } else {
      await enregistrerFiche(p);
    }
  }

  /// Enregistre un jet pour ses lecteurs ; [parAttaquant] : au nom du
  /// personnage ou de la créature qui agit.
  Future<String?> lancer({
    required String libelle,
    required String detail,
    required int total,
    required VisibiliteJet visibilite,
    String? cible,
    bool parAttaquant = false,
    String cibleJet = '',
    GenreJet genre = GenreJet.libre,
    int? caCible,
    bool? touche,
    String sansComparaison = '',
    bool action = false,
  }) =>
      _agir(
        (s, c) => s.lancer(
          c,
          JetSeance(
            auteur: uid,
            auteurNom: parAttaquant
                ? nomDuJet(visibilite)
                : estMj
                    ? 'MJ'
                    : moi?.personnageNom ?? 'Joueur',
            libelle: libelle,
            detail: detail,
            total: total,
            date: DateTime.now(),
            seance: _numero,
            lecteurs: lecteursDuJet(c, visibilite, auteur: uid, cible: cible),
            visibilite: visibilite,
            cible: cibleJet,
            genre: genre,
            mode: _etat.mode,
            manche: _etat.manche,
            attaquant: parAttaquant ? idAttaquant : '',
            caCible: caCible,
            touche: touche,
            sansComparaison: sansComparaison,
            action: action,
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
    for (final id in _personnagesMarques) {
      Personnage.seancesEnCours.remove(id);
    }
    _minuteriePresence?.cancel();
    _minuterieAbsences?.cancel();
    _minuterieEssaiFiches?.cancel();
    _minuteriePublication?.cancel();
    annonce.dispose();
    _signalerPresence(false);
    for (final a in _abonnements) {
      a.cancel();
    }
    _creaturesFlux?.cancel();
    _ressourcesFlux?.cancel();
    for (final a in _fichesFlux.values) {
      a.cancel();
    }
    _minuterieFiches?.cancel();
    // Modifications du MJ pas encore envoyées.
    for (final p in _aEcrire.values) {
      unawaited(campagnes.agir((s) => s.ecrireFiche(p)));
    }
    campagnes.removeListener(_campagneChangee);
    personnages.removeListener(_personnagesChanges);
    super.dispose();
  }
}
