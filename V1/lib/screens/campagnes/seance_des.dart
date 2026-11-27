import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/aptitude.dart';
import '../../models/bonus_seance.dart';
import '../../models/carac.dart';
import '../../models/creature.dart';
import '../../models/seance.dart';
import '../../models/voie.dart';
import '../../regles/des.dart';
import '../../regles/fiche_calculee.dart';
import '../../regles/invocations.dart';
import '../../regles/savoirs.dart';
import '../../regles/situations.dart';
import '../../state/seance_controller.dart';
import '../../theme.dart';
import '../../widgets/animation_lancer.dart';
import '../../widgets/consultation.dart';
import '../../widgets/voie_detail.dart';
import '../../widgets/types_competence.dart';
import '../de_screen.dart';
import 'cartes_campagne.dart' show IconePion;
import 'seance_bonus.dart';
import 'seance_cibles.dart';
import 'seance_messages.dart';

/// Portion de droite : onglets Lancer de dés et Historique.
class PanneauDes extends StatelessWidget {
  const PanneauDes({super.key, required this.seance, this.aleatoire});

  final SeanceController seance;
  final Random? aleatoire;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Carte de la campagne affichée : les dés restent à droite (20/11/2026) :
    // lancer libre pour le MJ, actions de son personnage pour le PJ.
    return DefaultTabController(
      length: 3,
      // Fond propre et filet or : on voit que c'est un menu à part.
      child: DecoratedBox(
        key: const Key('menu-droite'),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          border: const Border(
            left: BorderSide(color: OdvCouleurs.or, width: 2),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  Icon(Icons.menu_open, size: 20, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Actions de jeu',
                      overflow: TextOverflow.ellipsis,
                      style: styleAmbiance(theme.textTheme.titleSmall)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              tabs: [
                const Tab(
                  key: Key('onglet-des'),
                  icon: Icon(Icons.casino_outlined),
                  text: 'Dés',
                ),
                const Tab(
                  key: Key('onglet-historique'),
                  icon: Icon(Icons.receipt_long_outlined),
                  text: 'Logs',
                ),
                Tab(
                  key: const Key('onglet-messages'),
                  icon: Badge(
                    isLabelVisible: seance.nonLus > 0,
                    label: Text('${seance.nonLus}'),
                    child: const Icon(Icons.mail_outline),
                  ),
                  text: 'Messages',
                ),
              ],
            ),
            // Réaction acceptée (27/11/2026) : retour à l'onglet des dés.
            Builder(builder: (contexte) {
              if (seance.reactionDemandee != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (contexte.mounted) {
                    DefaultTabController.of(contexte).animateTo(0);
                  }
                });
              }
              return const SizedBox.shrink();
            }),
            Expanded(
              child: TabBarView(
                children: [
                  _Lanceur(seance: seance, aleatoire: aleatoire),
                  _Historique(seance: seance),
                  OngletMessages(seance: seance),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Lanceur extends StatefulWidget {
  const _Lanceur({required this.seance, this.aleatoire});

  final SeanceController seance;
  final Random? aleatoire;

  @override
  State<_Lanceur> createState() => _LanceurState();
}

class _LanceurState extends State<_Lanceur> with AutomaticKeepAliveClientMixin {
  static const _faces = [4, 6, 8, 10, 12, 20, 100];

  var _de = 20;
  var _nombre = 1;
  var _modificateur = 0;
  var _visibilite = VisibiliteJet.tous;
  String? _cible;

  /// Dernières cibles choisies dans la fenêtre de cibles (19/11/2026) ;
  /// vide : aucune cible.
  List<String> _ciblesChoisies = const [];

  /// Sort en cours : ses dégâts ne vont qu'aux cibles touchées par son jet
  /// d'attaque ([_touchees], `null` : pas de jet d'attaque).
  var _sortEnCours = false;
  Set<String>? _touchees;

  /// Dernier résultat affiché.
  _Resultat? _dernier;

  /// Dégâts des attaques de créature sans jet d'attaque (libellé → note) :
  /// le joueur visé peut esquiver.
  final Map<String, String> _sansJet = {};

  /// Situations cochées (« +1 en forêt »…), comme sur la page dé.
  final Set<String> _situations = {};

  /// Alerte : deuxième attaque du tour (rien n'est bloqué).
  String? _alerte;

  /// Réaction en cours (20/11/2026) : tour et manche où le PJ l'a lancée ;
  /// elle s'arrête quand le tour passe. Une par manche.
  String? _reactionPendant;
  String get _tourActuel => '${_s.etat.manche}:${_s.etat.actif}';
  bool get _enReaction => _reactionPendant == _tourActuel;

  /// Réussite critique au toucher (20/11/2026) : la prochaine attaque de
  /// dégâts de celui qui a touché (pendant ce tour) a ses dés au maximum,
  /// puis le total est doublé. « manche:actif|attaquant ».
  String? _critiqueEnAttente;

  /// Arme de chaque jet d'attaque (libellé → « Épée longue »), notée dans
  /// les logs (20/11/2026).
  final Map<String, String> _armes = {};

  /// Compétence d'origine des attaques de compétence (« Riposte » →
  /// « Riposte »), pour le mode Réaction (26/11/2026).
  final Map<String, String> _originesAttaques = {};

  /// Mode Réaction (26/11/2026) : seules les compétences de la catégorie
  /// « Réaction » sont permises (tests, aptitudes et dégâts restent libres).
  bool get _filtreReaction => _enReaction && !_s.estMj;

  /// Compétences de réaction de la fiche, et celles « si actif ».
  Set<String> _reactions(FicheCalculee f, GenreReaction genre) => {
        for (final c in f.competencesAcquises)
          if (genreReaction(c.competence.type) == genre) c.competence.nom,
      };

  /// Action permise en réaction : sa compétence est une réaction, ou son
  /// libellé commence par le nom d'une réaction (« Riposte » donnée par
  /// Désarmement).
  bool _permiseEnReaction(FicheCalculee? f, String origine, String libelle) {
    if (!_filtreReaction) return true;
    if (f == null) return false;
    final noms = _reactions(f, GenreReaction.reaction);
    return noms.contains(origine) || noms.any(libelle.startsWith);
  }

  /// Une action du tour commence (attaque, sort, compétence) : le prochain
  /// jet est marqué comme tel (limite d'actions par tour, 20/11/2026).
  var _nouvelleAction = false;

  /// PJ en combat, à son tour : plus d'action possible ce tour.
  bool get _actionsEpuisees => !_enReaction && _s.actionsRestantes == 0;

  /// Recherche dans les actions du panneau (20/11/2026).
  String _recherche = '';
  final _champRecherche = TextEditingController();

  @override
  void dispose() {
    _champRecherche.dispose();
    super.dispose();
  }

  /// Texte sans accents ni majuscules, pour la recherche.
  static String _simple(String t) {
    const accents = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'ô': 'o',
      'ö': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'œ': 'oe',
    };
    final b = StringBuffer();
    for (final c in t.toLowerCase().split('')) {
      b.write(accents[c] ?? c);
    }
    return b.toString();
  }

  bool _trouve(String texte) =>
      _recherche.isEmpty || _simple(texte).contains(_simple(_recherche));

  /// Ordre alphabétique (sans accents).
  static int _alpha(String a, String b) => _simple(a).compareTo(_simple(b));

  /// Prévient si l'attaquant a déjà attaqué pendant cette manche.
  void _verifierAttaque() {
    final deja = _s.dejaAttaque(_s.idAttaquant);
    setState(() {
      _alerte = deja ? 'Attaque déjà faite ce tour.' : null;
    });
  }

  @override
  bool get wantKeepAlive => true;

  SeanceController get _s => widget.seance;

  /// Choix proposés : le MJ peut viser un seul PJ ; un PJ peut cacher son jet
  /// aux autres, ou à lui-même (le MJ seul le voit).
  List<VisibiliteJet> get _choix => _s.estMj
      ? const [VisibiliteJet.tous, VisibiliteJet.mjSeul, VisibiliteJet.unJoueur]
      : const [
          VisibiliteJet.tous,
          VisibiliteJet.mjEtAuteur,
          VisibiliteJet.mjSeul,
        ];

  String _libelle(VisibiliteJet v) => switch (v) {
        VisibiliteJet.mjSeul when _s.estMj => 'Visible de moi seul',
        VisibiliteJet.mjSeul => 'Caché pour moi aussi (MJ seul)',
        _ => v.libelle,
      };

  /// Attaques de qui agit : toucher et dégâts du personnage, ou de la
  /// créature sélectionnée (MJ).
  List<({String libelle, String des, int bonus, bool degats, String type})>
      _attaques() {
    final a = _s.attaquant;
    final res =
        <({String libelle, String des, int bonus, bool degats, String type})>[];
    void ajouter(String libelle, String des, int bonus,
        {String type = 'physique'}) {
      // Deux armes identiques équipées : une seule carte (20/11/2026).
      if (res.any((x) => x.libelle == libelle)) return;
      if (lireFormule(des) != null) {
        res.add((
          libelle: libelle,
          des: des,
          bonus: bonus,
          degats: _estDegats(libelle),
          type: type,
        ));
      }
    }

    _sansJet.clear();
    _armes.clear();
    _originesAttaques.clear();
    if (a.creature case final c?) {
      // Compagnon choisi par le MJ : toucher d'après la fiche de son maître.
      final maitre = _s.ficheDe(_s.creatureChoisie?.proprietaire ?? '');
      final rang = maitre == null
          ? 0
          : maitre.rangCompetence(_competenceDe(maitre, c.id));
      for (final x in c.attaques) {
        final b = maitre == null
            ? null
            : bonusToucherSelonMaitre(x.toucher, maitre, rang);
        if (b != null) {
          ajouter('${x.nom} · toucher', '1d20', b);
        } else {
          ajouter('${x.nom} · toucher', x.toucher, 0);
        }
        // « 4d6 (de son élément) » : la formule en tête suffit.
        final des = lireFormule(x.degats) != null
            ? x.degats
            : RegExp(r'^\d+d\d+(\s*[+-]\s*\d+)?').stringMatch(x.degats) ?? '';
        ajouter('${x.nom} · dégâts', des, 0, type: typeDegatsDepuis(x.degats));
        if (x.toucher.isEmpty && des.isNotEmpty) {
          _sansJet['${x.nom} · dégâts'] = x.note;
        }
      }
    }
    if (a.fiche case final f?) {
      // Attaque au contact : avec une arme de mêlée équipée, ou à mains nues
      // quand aucune arme n'est équipée ; à distance : avec une arme à
      // distance équipée. L'attaque magique passe par les sorts.
      final cac = f.detailDegatsCac;
      final dist = f.detailDegatsDistance;
      final mainsNues = cac.mainsNues && dist.armes.isEmpty;
      String noms(Iterable<String> l) => l.toSet().join(' et ');
      if (cac.armes.isNotEmpty || mainsNues) {
        ajouter('Toucher CaC', '1d20', f.toucherCac);
        _armes['Toucher CaC'] =
            mainsNues ? 'Mains nues' : noms(cac.armes.map((x) => x.nom));
      }
      if (dist.armes.isNotEmpty) {
        ajouter('Toucher distance', '1d20', f.toucherDistance);
        _armes['Toucher distance'] = noms(dist.armes.map((x) => x.nom));
      }
      for (final d in [cac, dist]) {
        for (final arme in d.armes) {
          ajouter(
            'Dégâts · ${arme.nom}',
            d.des(arme),
            d.bonusAvec(arme),
            type: arme.element.isEmpty ? 'physique' : arme.element,
          );
        }
      }
      if (mainsNues) {
        ajouter(
            'Dégâts · Mains nues', cac.desMainsNuesAvec, cac.bonusMainsNues);
      }
      // Attaques de compétence (Brutalité, Moulinet…).
      for (final j in f.jetsCompetences) {
        final x = j.attaque;
        if (x == null) continue;
        final arme = f.armeAttaque(x);
        if (arme == null && !x.sansArme) continue;
        ajouter(
          j.libelle,
          j.des.isEmpty ? '1d20' : j.des,
          (x.distance == true ? f.toucherDistance : f.toucherCac) +
              (x.toucher ?? 0),
        );
        _armes[j.libelle] = x.sansArme ? 'Mains nues' : arme!.nom;
        _originesAttaques[j.libelle] = j.origine;
        final g = degatsAttaque(f, j, x.sansArme ? null : arme);
        ajouter(
          'Dégâts · ${j.libelle}',
          g.des,
          g.bonus + g.fixes.fold(0, (s, b) => s + b.valeur),
        );
      }
      // Compagnons et familiers : ils attaquent au tour de leur maître,
      // toucher chiffré d'après sa fiche (« 1d20 + RANG + AdC du druide »).
      for (final k in compagnonsCombattants(
          f, {for (final x in _s.referentiel.creatures) x.id: x})) {
        final rang = f.rangCompetence(k.competence);
        for (final x in k.creature.attaques) {
          final nom = '${k.creature.nom} · ${x.nom}';
          final b = bonusToucherSelonMaitre(x.toucher, f, rang);
          if (b != null) {
            ajouter('$nom · toucher', '1d20', b);
          } else {
            ajouter('$nom · toucher', x.toucher, 0);
          }
          final des = lireFormule(x.degats) != null
              ? x.degats
              : RegExp(r'^\d+d\d+(\s*[+-]\s*\d+)?').stringMatch(x.degats) ?? '';
          ajouter('$nom · dégâts', des, 0, type: typeDegatsDepuis(x.degats));
        }
      }
    }
    return res;
  }

  /// Mode Réaction : les réactions possibles de la fiche (26/11/2026).
  String _texteReaction() {
    final f = _s.attaquant.fiche;
    final noms = f == null
        ? const <String>[]
        : [
            ..._reactions(f, GenreReaction.reaction),
            for (final n in _reactions(f, GenreReaction.siActif))
              '$n (si actif)',
          ];
    return noms.isEmpty
        ? 'Réaction : aucune compétence de réaction ; tests et dégâts '
            'restent possibles.'
        : 'Réaction : ${noms.join(', ')}. Notée comme telle dans les logs.';
  }

  /// Compétence qui donne la créature [id] au personnage (pour son RANG).
  String _competenceDe(FicheCalculee f, String id) {
    for (final k in compagnonsCombattants(
        f, {for (final x in _s.referentiel.creatures) x.id: x})) {
      if (k.creature.id == id) return k.competence;
    }
    return '';
  }

  /// Joueur en combat, hors de son tour : attaques, sorts et compétences
  /// attendent son tour (12/11/2026) ; tests de statistique, aptitudes et
  /// esquive restent possibles. Le MJ n'est jamais bloqué.
  bool get _horsTour =>
      !_s.estMj && _s.etat.enCombat && !_s.monTour && !_enReaction;

  /// Jet de dégâts : son total est retiré des PV de la cible.
  static bool _estDegats(String libelle) =>
      libelle.toLowerCase().contains('dégâts');

  /// Noms des cibles dans un jet (« soi-même » pour celui qui agit).
  String _nomsCibles(List<String> ids) => [
        for (final id in ids)
          id == _s.idAttaquant ? 'soi-même' : _s.nomCible(id, _visibilite),
      ].where((n) => n.isNotEmpty).join(', ');

  /// Ouvre la fenêtre de cibles (19/11/2026) ; `null` : annulé.
  Future<List<String>?> _choisirCibles(
    String titre, {
    int? maximum = 1,
    bool aucune = true,
  }) async {
    final r = await showDialog<List<String>>(
      context: context,
      builder: (_) => DialogueCibles(
        titre: titre,
        cibles: _s.ciblesPotentielles,
        maximum: maximum,
        aucune: aucune,
        derniere: _ciblesChoisies,
      ),
    );
    if (r == null || !mounted) return null;
    setState(() => _ciblesChoisies = r);
    return r;
  }

  /// Cibles d'une compétence ou d'un sort selon sa cible : soi-même, les
  /// alliés, une ou plusieurs au choix (fenêtre) ; `null` : annulé.
  Future<List<String>?> _ciblesDe(FicheCalculee f, Competence c) async {
    final soi = _s.idAttaquant;
    switch (c.cible) {
      case CibleCompetence.soi:
        return [soi];
      case CibleCompetence.allies:
        return [for (final m in _s.joueurs) m.uid];
      case CibleCompetence.alliesSansLanceur:
        return [
          for (final m in _s.joueurs)
            if (m.uid != soi) m.uid,
        ];
      case CibleCompetence.unique:
        return _choisirCibles(c.nom, aucune: false);
      case CibleCompetence.selection:
        return _choisirCibles(
          c.nom,
          maximum: c.ciblesMax.isEmpty
              ? null
              : SeanceController.nombreDuree(f, c, c.ciblesMax, null),
          aucune: false,
        );
      case null:
        return _choisirCibles(c.nom);
    }
  }

  /// Sort : dépense son coût, puis lance ses dés (réussite, effets).
  Future<void> _lancerSort(
    FicheCalculee f,
    ({Competence competence, int rangSort, int cout}) s,
  ) async {
    final sort = s.competence;
    // Cibles d'abord (fenêtre) : annulé, rien n'est dépensé.
    final cibles = await _ciblesDe(f, sort);
    if (cibles == null || !mounted) return;
    _verifierAttaque();
    _nouvelleAction = true;
    await _s.depenserSort(f, sort.nom, s.cout);
    _sortEnCours = true;
    _touchees = null;
    final jets = [
      if (f.jetReussite(sort) case final j?) j,
      ...f.jetsEffetSort(sort),
    ].where((j) => lireFormule(j.des) != null).toList();
    // Jets lancés (durée et nombre d'une invocation, réussite). Un seul jet
    // pour toutes les cibles (19/11/2026).
    final resultats = <String, ResultatLancer>{};
    for (final j in jets) {
      final t = await _lancerFormule(
        j.libelle,
        j.des,
        j.bonus,
        parAttaquant: true,
        avecCible: true,
        degats: j.applique.isEmpty && _estDegats(j.libelle),
        type: sort.typeDegats.isEmpty ? 'physique' : sort.typeDegats,
        genre: GenreJet.sort,
        contreCa: j.attaqueMagique && j.difficulte == null,
        cibles: cibles,
        soin: j.libelle.endsWith('· soin'),
      );
      if (t != null) resultats[j.libelle.toLowerCase()] = t;
    }
    if (jets.isEmpty) {
      await _lancer(
        libelle: sort.nom,
        parAttaquant: true,
        avecCible: true,
        genre: GenreJet.sort,
        cibles: cibles,
      );
    }
    // Soin sans dés (« 1 PV » : Petit soin) : rendu tel quel à chaque cible.
    if (FicheCalculee.desDans(sort.soin) == null) {
      final m = RegExp(r'^\s*(\d+)\s*PV').firstMatch(sort.soin);
      if (m != null) {
        for (final c in cibles) {
          await _s.soigner(c, int.parse(m[1]!),
              '${_s.nomDuJet(VisibiliteJet.tous)} · ${sort.nom}');
        }
      }
    }
    _sortEnCours = false;
    _touchees = null;
    final totaux = {
      for (final e in resultats.entries) e.key: e.value.total,
    };
    // Sort qui donne un bonus ou un malus : réussi si son jet de réussite
    // atteint la difficulté (ou sans difficulté).
    final jr = f.jetReussite(sort);
    await _donnerBonus(
      f,
      sort.nom,
      reussi: reussiteJet(
        jr == null ? null : resultats[jr.libelle.toLowerCase()],
        jr?.difficulte,
      ),
      cibles: cibles,
    );
    // Invocation temporaire : elle entre dans la partie, sous le lanceur,
    // pour la durée lancée (en tours).
    final temporaires = [
      for (final x in invocationsDeCompetence(sort, choix: f.personnage.choix))
        if (!x.permanente) x,
    ];
    if (temporaires.isNotEmpty) {
      int? total(String mot) {
        for (final e in totaux.entries) {
          if (e.key.contains(mot)) return e.value;
        }
        return null;
      }

      await _s.invoquer(
        temporaires.first,
        nombre: total('nombre') ?? 1,
        tours: total('durée'),
      );
    }
  }

  /// Lance une formule (« 1d8 + 1d6 + 2 »). Pour un d20 du personnage :
  /// bonus des situations (cochées ou permanentes) et avantage, comme sur la
  /// page dé ; [carac] : caractéristique testée, [savoir] : aptitude.
  /// Renvoie le lancer (`null` : rien lancé). [cibles] : celles choisies
  /// (sinon les dernières) ; [soin] : le total rend des PV aux cibles.
  Future<ResultatLancer?> _lancerFormule(
    String libelle,
    String des,
    int bonus, {
    bool parAttaquant = false,
    bool avecCible = false,
    bool degats = false,
    String type = 'physique',
    GenreJet genre = GenreJet.libre,
    bool contreCa = false,
    Carac? carac,
    String? savoir,
    List<String>? cibles,
    bool soin = false,
  }) async {
    final f = lireFormule(des);
    if (f == null) return null;
    final d20 = f.groupes.length == 1 &&
        f.groupes.first.nombre == 1 &&
        f.groupes.first.faces == 20;
    final fiche = parAttaquant ? _s.attaquant.fiche : null;
    final situ = fiche != null && d20
        ? effetsSituations(
            fiche,
            _situations,
            carac,
            initiative: libelle == 'Initiative',
            savoir: savoir,
          )
        : (bonus: const <BonusSituation>[], avantage: const <String>[]);
    // Bonus et malus de séance reçus par celui qui agit (18/11/2026).
    final retenus = parAttaquant
        ? _s.bonusRetenus(
            _s.idAttaquant,
            genre: genre,
            d20: d20,
            degats: degats,
            carac: carac,
            initiative: libelle == 'Initiative',
          )
        : const <BonusSeance>[];
    final recus = [for (final b in retenus) (nom: b.nom, valeur: b.valeur)];
    final seuils = fiche != null && contreCa ? fiche.seuilsAttaques : null;
    final cleCritique = '$_tourActuel|${_s.idAttaquant}';
    final critique = degats && _critiqueEnAttente == cleCritique;
    final r = critique
        ? degatsCritiques(
            libelle: libelle,
            de: des,
            bonus: bonus,
            situations: [...situ.bonus, ...recus],
          )
        : ResultatLancer.lancer(
            libelle: libelle,
            de: des,
            bonus: bonus,
            situations: [...situ.bonus, ...recus],
            mode:
                situ.avantage.isEmpty ? ModeLancer.normal : ModeLancer.avantage,
            origineMode: situ.avantage.join(', '),
            aleatoire: widget.aleatoire,
            seuilCritique: seuils?.critique ?? 20,
            seuilEchec: seuils?.echec ?? 1,
          );
    if (r == null) return null;
    if (critique) _critiqueEnAttente = null;
    // Toucher critique : les prochains dégâts seront doublés au maximum.
    if (contreCa && d20 && r.reussiteCritique) {
      _critiqueEnAttente = cleCritique;
    }
    // Bonus « en actions » qui ont compté : une action de moins.
    if (retenus.isNotEmpty) unawaited(_s.consommerBonus(retenus));
    await _lancer(
      libelle: critique ? '$libelle (critique : dés au max ×2)' : libelle,
      resultat: r,
      parAttaquant: parAttaquant,
      avecCible: avecCible,
      degats: degats,
      type: type,
      genre: genre,
      contreCa: contreCa && d20,
      cibles: cibles,
      soin: soin,
    );
    return r;
  }

  /// Enregistre le jet ; [resultat] `null` : action sans dés (sort sans jet,
  /// action en endurance).
  Future<void> _lancer({
    required String libelle,
    ResultatLancer? resultat,
    bool parAttaquant = false,
    bool avecCible = false,
    bool degats = false,
    String type = 'physique',
    GenreJet genre = GenreJet.libre,
    bool contreCa = false,
    List<String>? cibles,
    bool soin = false,
  }) async {
    final r = resultat;
    final ids = avecCible ? cibles ?? _ciblesChoisies : const <String>[];
    final total = r?.total ?? 0;
    if (r != null) {
      AnimationLancer.montrer(
        context,
        total: total,
        libelle: libelle,
        critique: r.reussiteCritique,
        echec: r.echecCritique,
      );
    }
    final fiche = parAttaquant ? _s.attaquant.fiche : null;
    // Attaque : comparée à la CA de chaque cible, si elle est connue (un
    // seul jet pour toutes, 19/11/2026).
    final visees = [
      for (final id in ids)
        if (id != _s.idAttaquant) id,
    ];
    final attaque = contreCa && r != null && r.d20;
    // CA visée : sorts → contre les sorts ; tir → distance ; sinon corps à
    // corps (bonus de CA de séance, 19/11/2026).
    final bas = libelle.toLowerCase();
    final contre = genre == GenreJet.sort
        ? 'MAG'
        : bas.contains('distance') || bas.contains('tir')
            ? 'DIST'
            : 'CaC';
    final cas = {
      for (final id in visees) id: attaque ? _s.caDe(id, contre: contre) : null,
    };
    // 20 naturel (ou seuil de critique) : touche toujours ; 1 : rate.
    bool toucheCa(int? ca) =>
        ca == null || r!.reussiteCritique || (!r.echecCritique && total >= ca);
    final ca = visees.length == 1 ? cas[visees.first] : null;
    bool? touche;
    var sansComparaison = '';
    if (attaque) {
      if (visees.isEmpty) {
        sansComparaison = 'Sans cible : pas de comparaison';
      } else if (visees.length == 1) {
        if (ca == null) {
          sansComparaison = 'CA de la cible inconnue';
        } else {
          touche = toucheCa(ca);
        }
      } else {
        final ok = [
          for (final id in visees)
            if (toucheCa(cas[id])) id,
        ];
        final rates = [
          for (final id in visees)
            if (!ok.contains(id)) id,
        ];
        sansComparaison = [
          'Touché : ${ok.isEmpty ? 'personne' : _nomsCibles(ok)}',
          if (rates.isNotEmpty) 'raté : ${_nomsCibles(rates)}',
        ].join(' · ');
      }
      if (_sortEnCours) {
        _touchees = {
          for (final id in visees)
            if (toucheCa(cas[id])) id,
        };
      }
    }
    final detail = r?.detail ?? '';
    // Hors de son tour, en réaction : noté comme tel (une par manche).
    // Attaque : l'arme utilisée (20/11/2026).
    final arme = genre == GenreJet.attaque ? _armes[libelle] : null;
    final libelleArme =
        arme == null || arme.isEmpty ? libelle : '$libelle · $arme';
    final libelleJet = parAttaquant && _enReaction
        ? '${SeanceController.prefixeReaction}$libelleArme'
        : libelleArme;
    final action = parAttaquant && _nouvelleAction;
    _nouvelleAction = false;
    final erreur = await _s.lancer(
      libelle: libelleJet,
      detail: detail,
      total: total,
      visibilite: _visibilite,
      cible: _cible,
      parAttaquant: parAttaquant,
      genre: genre,
      caCible: ca,
      touche: touche,
      sansComparaison: sansComparaison,
      action: action,
      // Critique d'un d20 (26/11/2026) : noté dans les notes de séance.
      ciblesIds: visees,
      contact: attaque && contre == 'CaC',
      critique: r == null || !r.d20
          ? ''
          : r.reussiteCritique
              ? JetSeance.critiqueReussite
              : r.echecCritique
                  ? JetSeance.critiqueEchec
                  : '',
      cibleJet: avecCible
          ? [
              _nomsCibles(ids),
              if (degats && type != 'physique' && ids.isNotEmpty) '($type)',
            ].join(' ')
          : '',
    );
    // Jet du personnage : inscrit dans son historique, avec la séance ;
    // avant les dégâts et soins (un soin sur soi-même est écrit sur la
    // fiche juste après : il ne doit pas être écrasé par cette copie).
    if (erreur == null && r != null && fiche != null) {
      await _s.journaliserJet(
        fiche,
        '$libelleArme : $total ($detail)'
        '${r.reussiteCritique ? ' · réussite critique' : ''}'
        '${r.echecCritique ? ' · échec critique' : ''}'
        '${touche == null ? '' : touche ? ' · touché' : ' · raté'}',
      );
    }
    if (erreur == null && (degats || soin)) {
      // Sort avec un jet d'attaque : seulement les cibles touchées.
      final touchees = _sortEnCours ? _touchees : null;
      final source = '${_s.nomDuJet(VisibiliteJet.tous)} · $libelle';
      int? esquive;
      var moitie = false;
      var demande = false;
      for (final cible in ids) {
        if (touchees != null && !touchees.contains(cible)) continue;
        if (soin) {
          await _s.soigner(cible, total, source);
          continue;
        }
        // Attaque sans jet d'attaque sur un joueur : il pourra esquiver
        // (difficulté demandée une fois).
        final joueur = _s.joueurs.any((m) => m.uid == cible);
        final note = _sansJet[libelle];
        if (note != null && joueur && !demande) {
          demande = true;
          esquive = await _demanderDifficulte(libelle);
          moitie = esquiveDonneMoitie(note);
        }
        await _s.infligerDegats(
          cible,
          total,
          source,
          type: type,
          esquive: joueur ? esquive : null,
          moitie: moitie,
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _dernier = _Resultat(
        libelle: libelle,
        total: total,
        detail: detail,
        touche: touche,
        // La CA de la cible n'est jamais montrée aux PJ.
        ca: _s.estMj ? ca : null,
        note: sansComparaison,
        critique: r?.reussiteCritique ?? false,
        echec: r?.echecCritique ?? false,
        avantage: r != null && r.mode == ModeLancer.avantage,
        secret: !_s.estMj && _visibilite == VisibiliteJet.mjSeul,
        sansDes: r == null,
        erreur: erreur,
      );
    });
  }

  /// Difficulté du jet d'esquive demandé au joueur (15 par défaut) ;
  /// `null` : dégâts appliqués sans esquive.
  Future<int?> _demanderDifficulte(String libelle) {
    final champ = TextEditingController(text: '15');
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(libelle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pas de jet d'attaque : le joueur peut esquiver. "
                "Difficulté du jet d'esquive :"),
            const SizedBox(height: 8),
            TextField(
              key: const Key('difficulte-esquive'),
              controller: champ,
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('sans-esquive'),
            onPressed: () => Navigator.pop(context),
            child: const Text('Sans esquive'),
          ),
          FilledButton(
            key: const Key('demander-esquive'),
            onPressed: () =>
                Navigator.pop(context, int.tryParse(champ.text.trim()) ?? 15),
            child: const Text("Demander l'esquive"),
          ),
        ],
      ),
    ).whenComplete(champ.dispose);
  }

  /// Compétence acquise du personnage, par son nom.
  Competence? _competenceNommee(FicheCalculee f, String nom) {
    for (final c in f.competencesAcquises) {
      if (c.competence.nom == nom) return c.competence;
    }
    return null;
  }

  /// Compétence ou sort lancé : s'il donne un bonus ou un malus, il est posé
  /// sur ses cibles (choisies ici pour une cible unique ou une sélection).
  Future<void> _donnerBonus(
    FicheCalculee f,
    String nom, {
    required bool reussi,
    List<String>? cibles,
  }) async {
    final c = _competenceNommee(f, nom);
    if (c == null || c.bonusDonnes.isEmpty) return;
    final messager = ScaffoldMessenger.of(context);
    if (!reussi && c.bonusDonnes.every((b) => b.siReussite)) {
      messager.showSnackBar(SnackBar(
        content: Text('${c.nom} : jet raté, pas de bonus.'),
      ));
      return;
    }
    var choisis = const <String>[];
    if (c.cible == CibleCompetence.unique ||
        c.cible == CibleCompetence.selection) {
      // Cibles choisies au lancement (sinon demandées maintenant).
      final r = cibles ?? await _ciblesDe(f, c);
      if (r == null || r.isEmpty || !mounted) return;
      choisis = r;
    }
    // Options (bénédiction : arme, ou autre choix sans bonus automatique).
    var option = '';
    if (c.optionsBonus.isNotEmpty) {
      final o = await showDialog<String>(
        context: context,
        builder: (_) => DialogueOptionBonus(
          titre: c.nom,
          options: c.optionsBonus,
        ),
      );
      if (o == null || o.isEmpty || !mounted) return;
      option = o;
    }
    final noms = await _s.donnerBonusDe(
      f,
      c,
      reussi: reussi,
      choisis: choisis,
      option: option,
      aleatoire: widget.aleatoire,
    );
    if (noms.isEmpty || !mounted) return;
    final d = c.duree;
    messager.showSnackBar(SnackBar(
      content: Text('${c.nom} : bonus donné à ${noms.join(', ')}'
          '${d != null && d.affichee ? ' (${d.texte})' : ''}.'),
    ));
  }

  /// Jets de compétences (hors sorts et attaques), lançables ici.
  List<JetDisponible> _jetsCompetences(FicheCalculee fiche) {
    // Les jets d'un sort partent de son bouton, les attaques de « Combat ».
    final nomsSorts = {for (final s in fiche.sorts) s.competence.nom};
    return [
      for (final j in fiche.jetsCompetences)
        if (j.attaque == null &&
            !nomsSorts.contains(j.origine) &&
            lireFormule(j.des) != null)
          j,
    ];
  }

  /// Bouton mis en avant (avantage, maîtrise) : bordure et texte verts.
  /// [favori] : clé de favori de l'action (20/11/2026) : étoile sur la
  /// puce pour la mettre en favori ou l'en retirer.
  Widget _puce({
    required String cle,
    required String texte,
    required VoidCallback? onPressed,
    Color? vert,
    FicheCalculee? fiche,
    String? favori,
  }) {
    final label = Text(
      texte,
      style: vert == null
          ? null
          : TextStyle(color: vert, fontWeight: FontWeight.w700),
    );
    final side = vert == null ? null : BorderSide(color: vert, width: 2);
    if (fiche == null || favori == null) {
      return ActionChip(
        key: Key(cle),
        side: side,
        label: label,
        onPressed: onPressed,
      );
    }
    final estFavori = fiche.personnage.favoris.contains(favori);
    return InputChip(
      key: Key(cle),
      side: side,
      label: label,
      onPressed: onPressed,
      isEnabled: onPressed != null,
      deleteIcon: Icon(
        estFavori ? Icons.star : Icons.star_outline,
        key: Key('etoile-$cle'),
        size: 18,
        color: OdvCouleurs.or,
      ),
      deleteButtonTooltipMessage:
          estFavori ? 'Retirer des favoris' : 'Mettre en favori',
      onDeleted: () async {
        await _s.basculerFavori(fiche, favori);
        if (mounted) setState(() {});
      },
    );
  }

  Widget _puceSort(
    FicheCalculee fiche,
    ({Competence competence, int rangSort, int cout}) s,
    String cle,
    bool pasDeCible,
  ) =>
      _puce(
        cle: cle,
        texte: '${s.competence.nom} : ${s.cout} ${fiche.uniteSorts}',
        fiche: fiche,
        favori: s.competence.nom,
        onPressed: pasDeCible ||
                _horsTour ||
                _actionsEpuisees ||
                !_permiseEnReaction(
                    fiche, s.competence.nom, s.competence.nom) ||
                fiche.pointsPourSorts < s.cout
            ? null
            : () => _lancerSort(fiche, s),
      );

  Widget _puceJet(
    FicheCalculee fiche,
    JetDisponible j,
    String cle,
    bool pasDeCible,
  ) =>
      _puce(
        cle: cle,
        texte: '${j.libelle} : ${formaterJet(j.des, j.bonus)}',
        fiche: fiche,
        favori: j.origine,
        onPressed: pasDeCible ||
                _horsTour ||
                _actionsEpuisees ||
                !_permiseEnReaction(fiche, j.origine, j.libelle)
            ? null
            : () async {
                // Compétence qui donne un bonus : cibles choisies d'abord.
                final c = _competenceNommee(fiche, j.origine);
                List<String>? cibles;
                if (c != null && c.bonusDonnes.isNotEmpty) {
                  cibles = await _ciblesDe(fiche, c);
                  if (cibles == null) return;
                }
                _nouvelleAction = true;
                final r = await _lancerFormule(
                  j.libelle,
                  j.des,
                  j.bonus,
                  parAttaquant: true,
                  genre: GenreJet.test,
                );
                if (r == null) return;
                await _donnerBonus(
                  fiche,
                  j.origine,
                  reussi: reussiteJet(r, j.difficulte),
                  cibles: cibles,
                );
              },
      );

  Widget _puceAction(
    FicheCalculee fiche,
    ({String libelle, int cout, String origine}) a,
    String cle,
    bool pasDeCible,
  ) =>
      _puce(
        cle: cle,
        texte: '${a.libelle} : ${a.cout} PE',
        fiche: fiche,
        favori: a.origine,
        onPressed: pasDeCible ||
                _horsTour ||
                _actionsEpuisees ||
                !_permiseEnReaction(fiche, a.origine, a.libelle) ||
                fiche.peActuels < a.cout
            ? null
            : () async {
                // Compétence qui donne un bonus (musique vivifiante) : cibles
                // choisies d'abord, puis son jet ; bonus donné s'il réussit.
                final c = _competenceNommee(fiche, a.origine);
                final donne = c != null && c.bonusDonnes.isNotEmpty;
                List<String>? cibles;
                if (donne) {
                  cibles = await _ciblesDe(fiche, c);
                  if (cibles == null) return;
                }
                await _s.depenserAction(fiche, a);
                _nouvelleAction = true;
                await _lancer(
                  libelle: '${a.libelle} (${a.cout} PE)',
                  parAttaquant: true,
                );
                if (!donne) return;
                JetDisponible? jet;
                for (final j in fiche.jetsCompetences) {
                  if (j.origine == a.origine && lireFormule(j.des) != null) {
                    jet = j;
                    break;
                  }
                }
                final r = jet == null
                    ? null
                    : await _lancerFormule(
                        jet.libelle,
                        jet.des,
                        jet.bonus,
                        parAttaquant: true,
                        genre: GenreJet.test,
                      );
                await _donnerBonus(
                  fiche,
                  a.origine,
                  reussi: jet == null || reussiteJet(r, jet.difficulte),
                  cibles: cibles,
                );
              },
      );

  /// Test de caractéristique ; avantage permanent (gnome : CHAN) en vert.
  Widget _puceStat(
    FicheCalculee fiche,
    Carac c,
    String cle,
    bool pasDeCible,
  ) {
    final avantage = avantagesPermanents(fiche)[c];
    final vert = avantage == null
        ? null
        : couleurModificateur(1, Theme.of(context).brightness);
    return Builder(
      builder: (_) => _puce(
        cle: cle,
        texte: '${c.abrev} ${formaterModificateur(fiche.mod(c))}'
            '${avantage == null ? '' : ' · avantage'}',
        vert: vert,
        fiche: fiche,
        favori: 'stat:${c.code}',
        onPressed: pasDeCible
            ? null
            : () => _lancerFormule(
                  'Test de ${c.abrev}',
                  '1d20',
                  fiche.mod(c),
                  parAttaquant: true,
                  genre: GenreJet.test,
                  carac: c,
                ),
      ),
    );
  }

  /// Jet d'aptitude ; maîtrisée ou avec avantage : en vert.
  Widget _puceAptitude(
    FicheCalculee fiche,
    JetSavoir j,
    String cle,
    bool pasDeCible,
  ) {
    final avantage = j.avantage ?? avantageSavoir(fiche, j.aptitude.nom);
    final vert = avantage != null || j.maitrise
        ? couleurModificateur(1, Theme.of(context).brightness)
        : null;
    return _puce(
      cle: cle,
      texte: '${j.libelle} '
          '${formaterModificateur(fiche.mod(j.carac) + j.total)}'
          '${avantage == null ? '' : ' · avantage'}',
      vert: vert,
      fiche: fiche,
      favori: 'apt:${j.libelle}',
      onPressed: pasDeCible
          ? null
          : () => _lancerFormule(
                j.libelle,
                '1d20',
                fiche.mod(j.carac) + j.total,
                parAttaquant: true,
                genre: GenreJet.test,
                carac: j.carac,
                savoir: j.aptitude.nom,
              ),
    );
  }

  /// Attaque ou dégâts.
  Widget _puceAttaque(
    FicheCalculee? fiche,
    ({String libelle, String des, int bonus, bool degats, String type}) a,
    String cle,
    bool pasDeCible,
  ) {
    final bouton = _puce(
      cle: cle,
      texte: '${a.libelle} : ${formaterJet(a.des, a.bonus)}',
      fiche: fiche,
      favori: 'att:${a.libelle}',
      // Dégâts : partie de l'attaque, jamais bloqués par la limite.
      onPressed: pasDeCible ||
              _horsTour ||
              (!a.degats && _actionsEpuisees) ||
              // En réaction : toucher d'une réaction seulement.
              (!a.degats &&
                  !_permiseEnReaction(
                      fiche, _originesAttaques[a.libelle] ?? '', a.libelle))
          ? null
          : () async {
              // Fenêtre de cibles (19/11/2026) à chaque attaque.
              final cibles = await _choisirCibles(a.libelle);
              if (cibles == null) return;
              if (!a.degats) {
                _verifierAttaque();
                _nouvelleAction = true;
              }
              await _lancerFormule(
                a.libelle,
                a.des,
                a.bonus,
                carac: a.libelle == 'Toucher CaC'
                    ? Carac.adc
                    : a.libelle == 'Toucher distance'
                        ? Carac.adt
                        : null,
                contreCa: !a.degats,
                parAttaquant: true,
                avecCible: true,
                degats: a.degats,
                type: a.type,
                genre: a.degats ? GenreJet.degats : GenreJet.attaque,
                cibles: cibles,
              );
            },
    );
    return bouton;
  }

  /// Jets d'aptitudes (savoirs, savoir-faire) du personnage.
  List<JetSavoir> _aptitudes(FicheCalculee fiche) => [
        ...jetsSavoirs(
          fiche,
          _s.referentiel.aptitudes,
          FamilleAptitude.savoir,
        ),
        ...jetsSavoirs(
          fiche,
          _s.referentiel.aptitudes,
          FamilleAptitude.savoirFaire,
        ),
      ];

  /// Fenêtre « Gérer les favoris » : toutes les actions du personnage, par
  /// famille, chacune avec son étoile (favori ou non).
  Future<void> _gererFavoris(
    FicheCalculee fiche,
    List<({String libelle, String des, int bonus, bool degats, String type})>
        attaques,
    List<JetSavoir> aptitudes,
  ) async {
    final vus = <String>{};
    List<({String cle, String nom})> uniques(
            Iterable<({String cle, String nom})> l) =>
        [
          for (final x in l)
            if (vus.add(x.cle)) x,
        ];
    final familles = <({
      String titre,
      IconData icone,
      List<({String cle, String nom})> actions,
    })>[
      (
        titre: 'Attaques',
        icone: Icons.sports_martial_arts,
        actions: uniques([
          for (final a in attaques) (cle: 'att:${a.libelle}', nom: a.libelle),
        ]),
      ),
      (
        titre: 'Sorts',
        icone: Icons.auto_awesome_outlined,
        actions: uniques([
          for (final s in fiche.sorts)
            (cle: s.competence.nom, nom: s.competence.nom),
        ]),
      ),
      (
        titre: 'Compétences',
        icone: Icons.bolt_outlined,
        actions: uniques([
          for (final j in _jetsCompetences(fiche))
            (cle: j.origine, nom: j.origine),
          for (final a in fiche.actionsEndurance)
            (cle: a.origine, nom: a.origine),
        ]),
      ),
      (
        titre: 'Statistiques',
        icone: Icons.casino_outlined,
        actions: uniques([
          for (final c in Carac.values)
            (cle: 'stat:${c.code}', nom: '${c.nom} (${c.code})'),
        ]),
      ),
      (
        titre: 'Aptitudes',
        icone: Icons.school_outlined,
        actions: uniques([
          for (final j in aptitudes) (cle: 'apt:${j.libelle}', nom: j.libelle),
        ]),
      ),
    ];
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) {
          final theme = Theme.of(context);
          final fav = fiche.personnage.favoris;
          final hauteur = MediaQuery.sizeOf(context).height;
          return Dialog(
            key: const Key('fenetre-favoris'),
            insetPadding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: 520, maxHeight: hauteur * 0.85),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Favoris (${fav.length})',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Fermer',
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      "Touche une action pour l'ajouter aux favoris (étoile "
                      'pleine) ou l\'en retirer : les favoris sont en tête des '
                      'dés.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        for (final g in familles)
                          if (g.actions.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
                              child: Row(
                                children: [
                                  Icon(g.icone,
                                      size: 16,
                                      color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    g.titre.toUpperCase(),
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            for (final a in g.actions)
                              ListTile(
                                key: Key('etoile-${a.cle}'),
                                dense: true,
                                title: Text(a.nom,
                                    overflow: TextOverflow.ellipsis),
                                trailing: Icon(
                                  fav.contains(a.cle)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: fav.contains(a.cle)
                                      ? OdvCouleurs.or
                                      : theme.colorScheme.outline,
                                ),
                                onTap: () async {
                                  await _s.basculerFavori(fiche, a.cle);
                                  setDialog(() {});
                                  if (mounted) setState(() {});
                                },
                              ),
                          ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Favoris : toutes les actions mises en favori, réunies en tête.
  Widget? _groupeFavoris(
    FicheCalculee fiche,
    bool pasDeCible,
    List<({String libelle, String des, int bonus, bool degats, String type})>
        attaques,
    List<JetSavoir> aptitudes,
  ) {
    final fav = fiche.personnage.favoris;
    final puces = <Widget>[
      for (final (i, a) in [
        for (final a in attaques)
          if (fav.contains('att:${a.libelle}')) a,
      ].indexed)
        _puceAttaque(fiche, a, 'favori-attaque-$i', pasDeCible),
      for (final (i, s) in [
        for (final s in fiche.sorts)
          if (fav.contains(s.competence.nom)) s,
      ].indexed)
        _puceSort(fiche, s, 'favori-sort-$i', pasDeCible),
      for (final (i, j) in [
        for (final j in _jetsCompetences(fiche))
          if (fav.contains(j.origine)) j,
      ].indexed)
        _puceJet(fiche, j, 'favori-competence-$i', pasDeCible),
      for (final (i, a) in [
        for (final a in fiche.actionsEndurance)
          if (fav.contains(a.origine)) a,
      ].indexed)
        _puceAction(fiche, a, 'favori-endurance-$i', pasDeCible),
      for (final (i, c) in [
        for (final c in Carac.values)
          if (fav.contains('stat:${c.code}')) c,
      ].indexed)
        _puceStat(fiche, c, 'favori-stat-$i', pasDeCible),
      for (final (i, j) in [
        for (final j in aptitudes)
          if (fav.contains('apt:${j.libelle}')) j,
      ].indexed)
        _puceAptitude(fiche, j, 'favori-aptitude-$i', pasDeCible),
    ];
    return _GroupeJets(
      cle: 'groupe-favoris',
      titre: puces.isEmpty ? 'Favoris' : 'Favoris (${puces.length})',
      icone: Icons.star_outline,
      children: [
        if (puces.isEmpty)
          Text(
            'Aucun favori : choisis tes actions les plus utilisées pour les '
            'avoir ici, en tête.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          )
        else
          Wrap(spacing: 6, runSpacing: 6, children: puces),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const Key('gerer-favoris'),
            onPressed: () => _gererFavoris(fiche, attaques, aptitudes),
            icon: const Icon(Icons.star_rate_outlined),
            label: const Text('Gérer les favoris'),
          ),
        ),
      ],
    );
  }

  Widget _groupeCompetences(FicheCalculee fiche, bool pasDeCible) {
    final fav = fiche.personnage.favoris;
    // Ordre alphabétique (20/11/2026).
    final jets = [
      for (final j in _jetsCompetences(fiche))
        if (!fav.contains(j.origine)) j,
    ]..sort((a, b) => _alpha(a.libelle, b.libelle));
    final actions = [
      for (final a in fiche.actionsEndurance)
        if (!fav.contains(a.origine)) a,
    ]..sort((a, b) => _alpha(a.libelle, b.libelle));
    return _GroupeJets(
      cle: 'groupe-competences',
      memoire: 'groupe-competences-${_s.etat.mode.name}',
      ouvert: _s.etat.enCombat,
      titre: 'Compétences',
      icone: Icons.bolt_outlined,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (i, j) in jets.indexed)
              _puceJet(fiche, j, 'competence-seance-$i', pasDeCible),
            for (final (i, a) in actions.indexed)
              _puceAction(fiche, a, 'endurance-seance-$i', pasDeCible),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Favoris : l\'étoile de chaque action, ou « Gérer les favoris ».',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const Key('detail-competences'),
            onPressed: () => _afficherCompetences(fiche),
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('Détail des compétences et sorts'),
          ),
        ),
      ],
    );
  }

  /// Toutes les compétences et tous les sorts, avec leur effet.
  void _afficherCompetences(FicheCalculee fiche) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compétences et sorts'),
        content: SizedBox(
          width: 560,
          child: StatefulBuilder(
            builder: (context, majDialogue) => ListView(
              key: const Key('liste-competences-seance'),
              shrinkWrap: true,
              children: [
                for (final (i, c) in fiche.competencesAcquises.indexed)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LigneCompetence(
                          competence: c.competence,
                          acquise: true,
                          choixFaits: fiche.personnage.choix,
                          sortsEnEndurance: fiche.sortsEnEndurance,
                          mention: c.voie.nom,
                        ),
                      ),
                      IconButton(
                        key: Key('favori-$i'),
                        tooltip:
                            fiche.personnage.favoris.contains(c.competence.nom)
                                ? 'Retirer des favoris'
                                : 'Mettre en favori',
                        onPressed: () async {
                          await _s.basculerFavori(fiche, c.competence.nom);
                          majDialogue(() {});
                          if (mounted) setState(() {});
                        },
                        icon: Icon(
                          fiche.personnage.favoris.contains(c.competence.nom)
                              ? Icons.star
                              : Icons.star_outline,
                          color: OdvCouleurs.or,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// MJ (21/11/2026) : qui agit, même quand une carte est affichée au
  /// centre.
  /// MJ (26/11/2026) : liste « Qui agit » regroupée par camp
  /// (personnages, alliés et compagnons, neutres, ennemis), avec l'icône de
  /// chacun et ses repères (à son tour, caché, mort).
  Widget _choixActeur() {
    final theme = Theme.of(context);
    final actif = _s.etat.enCombat ? _s.etat.actif : '';
    final creatures = _s.creaturesOrdonnees;
    final groupes = <(String, List<(String, Widget, String, List<String>)>)>[
      (
        'Personnages',
        [
          for (final m in _s.joueursOrdonnes)
            (
              m.uid,
              IconePion(pion: _s.pionDe(m), rayon: 12),
              m.personnageNom,
              <String>[]
            ),
        ],
      ),
      for (final (titre, garde) in [
        ('Alliés et compagnons', (CreatureSeance c) => c.duCotePj),
        ('Neutres', (CreatureSeance c) => !c.duCotePj && c.neutre),
        ('Ennemis', (CreatureSeance c) => c.ennemie),
      ])
        (
          titre,
          [
            for (final c in creatures)
              if (garde(c))
                (
                  c.id,
                  IconePion(pion: _s.pionCreature(c), rayon: 12),
                  c.nom,
                  [
                    if (c.morte) 'mort',
                    if (c.cachee) 'caché',
                    if (!c.cachee && c.nomCache) 'nom caché',
                  ],
                ),
          ],
        ),
    ];
    Widget ligne(Widget icone, String nom, List<String> reperes, bool joue) =>
        Row(
          children: [
            icone,
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                nom,
                overflow: TextOverflow.ellipsis,
                style:
                    joue ? const TextStyle(fontWeight: FontWeight.w700) : null,
              ),
            ),
            if (joue)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.play_arrow, size: 18, color: OdvCouleurs.or),
              ),
            if (reperes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  reperes.join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        );
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem(
        value: '',
        child: ligne(
          const Icon(Icons.casino_outlined, size: 24),
          'Personne (MJ)',
          const [],
          false,
        ),
      ),
      for (final (titre, liste) in groupes)
        if (liste.isNotEmpty) ...[
          // Titre de groupe : pas sélectionnable.
          DropdownMenuItem(
            value: '#$titre',
            enabled: false,
            child: Text(
              '${titre.toUpperCase()} (${liste.length})',
              key: Key('groupe-acteur-$titre'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 1,
              ),
            ),
          ),
          for (final (id, icone, nom, reperes) in liste)
            DropdownMenuItem(
              value: id,
              child: ligne(icone, nom, reperes, id == actif),
            ),
        ],
    ];
    return DropdownButtonFormField<String>(
      key: const Key('acteur-mj'),
      initialValue: _s.acteurMj,
      isExpanded: true,
      itemHeight: null,
      menuMaxHeight: 520,
      decoration: const InputDecoration(
        labelText: 'Qui agit',
        prefixIcon: Icon(Icons.person_search_outlined),
      ),
      items: items,
      onChanged: (v) {
        if (v == null || v.startsWith('#')) return;
        _s.choisirActeur(v);
      },
    );
  }

  /// MJ (26/11/2026) : tests de caractéristique d'une créature, avec les
  /// modificateurs de sa fiche du bestiaire (+0 s'ils manquent).
  Widget _statsCreature(Creature creature, bool pasDeCible, bool combat) {
    final aDefinir = creature.caracs.isEmpty && creature.mods.isEmpty;
    return _GroupeJets(
      cle: 'groupe-stats-creature',
      memoire: 'groupe-stats-creature-${_s.etat.mode.name}',
      ouvert: !combat,
      titre: 'Statistiques',
      icone: Icons.bar_chart,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in Carac.values)
              ActionChip(
                key: Key('test-creature-${c.code}'),
                label: Text(
                    '${c.abrev} ${formaterModificateur(creature.mods[c] ?? 0)}'),
                onPressed: pasDeCible
                    ? null
                    : () => _lancerFormule(
                          'Test de ${c.abrev}',
                          '1d20',
                          creature.mods[c] ?? 0,
                          parAttaquant: true,
                          genre: GenreJet.test,
                        ),
              ),
          ],
        ),
        if (aDefinir)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Statistiques à définir dans le bestiaire : +0 partout.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
      ],
    );
  }

  /// Réaction acceptée dans la fenêtre (27/11/2026) : mode Réaction (PJ),
  /// l'attaquant ciblé, la compétence cherchée dans les actions.
  void _prendreReaction() {
    final r = _s.reactionDemandee;
    if (r == null) return;
    _s.reactionPrise();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        if (!_s.estMj) _reactionPendant = _tourActuel;
        _ciblesChoisies = [r.attaquant];
        _champRecherche.text = r.competence;
        _recherche = r.competence;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _prendreReaction();
    final theme = Theme.of(context);
    final attaquant = _s.attaquant;
    final fiche = attaquant.fiche;
    final nom = attaquant.nom;
    final attaques = _attaques();
    final pasDeCible = _visibilite == VisibiliteJet.unJoueur && _cible == null;
    final fav = fiche?.personnage.favoris ?? const <String>{};
    final aptitudes = fiche == null ? const <JetSavoir>[] : _aptitudes(fiche);
    final favoris = fiche == null
        ? null
        : _groupeFavoris(fiche, pasDeCible, attaques, aptitudes);
    // Groupes ouverts au départ selon le mode : combat et compétences en
    // combat, statistiques et aptitudes en exploration.
    final combat = _s.etat.enCombat;
    final mode = _s.etat.mode.name;
    final attaquesAffichees = [
      for (final a in attaques)
        if (fiche == null || !fav.contains('att:${a.libelle}')) a,
    ];
    final sortsHorsFavoris = [
      for (final s in fiche?.sorts ??
          const <({Competence competence, int rangSort, int cout})>[])
        if (!fav.contains(s.competence.nom)) s,
    ]..sort((a, b) => _alpha(a.competence.nom, b.competence.nom));
    return ListView(
      key: const Key('panneau-des'),
      padding: const EdgeInsets.all(12),
      children: [
        // MJ (21/11/2026) : qui agit, même quand une carte est affichée au
        // centre.
        if (_s.estMj) ...[
          // Reconstruite quand l'acteur change (carte touchée à gauche).
          KeyedSubtree(
            key: ValueKey('acteur-${_s.acteurMj}'),
            child: _choixActeur(),
          ),
          const SizedBox(height: 8),
        ],
        // Jets libres : MJ seulement ; les PJ passent par leurs boutons.
        if (_s.estMj) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final f in _faces)
                ChoiceChip(
                  key: Key('de-$f'),
                  label: Text('d$f'),
                  selected: _de == f,
                  onSelected: (_) => setState(() => _de = f),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _Compteur(
            cle: 'nombre-des',
            libelle: 'Nombre',
            valeur: _nombre,
            min: 1,
            max: 20,
            onChange: (v) => setState(() => _nombre = v),
          ),
          _Compteur(
            cle: 'modificateur-de',
            libelle: 'Modificateur',
            valeur: _modificateur,
            min: -30,
            max: 30,
            onChange: (v) => setState(() => _modificateur = v),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<VisibiliteJet>(
          key: const Key('visibilite-jet'),
          initialValue: _visibilite,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Qui voit ce jet ?'),
          items: [
            for (final v in _choix)
              DropdownMenuItem(
                value: v,
                child: Text(_libelle(v), overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) => setState(() {
            _visibilite = v ?? VisibiliteJet.tous;
            _cible = null;
          }),
        ),
        if (_visibilite == VisibiliteJet.unJoueur) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: const Key('cible-jet'),
            initialValue: _cible,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Quel joueur ?'),
            items: [
              for (final m in _s.joueurs)
                DropdownMenuItem(
                  value: m.uid,
                  child: Text(m.personnageNom, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => _cible = v),
          ),
        ],
        if (_s.estMj) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('lancer-seance'),
            onPressed: pasDeCible
                ? null
                : () => _lancerFormule(
                      '${_nombre}d$_de',
                      '${_nombre}d$_de',
                      _modificateur,
                    ),
            icon: const Icon(Icons.casino_outlined),
            label: const Text('Lancer'),
          ),
        ],
        if (_dernier case final d?) ...[
          const SizedBox(height: 12),
          _CarteResultat(resultat: d),
        ],
        if (_alerte != null) ...[
          const SizedBox(height: 8),
          Row(
            key: const Key('alerte-attaque'),
            children: [
              Icon(
                Icons.warning_amber,
                size: 18,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _alerte!,
                  style: TextStyle(color: theme.colorScheme.tertiary),
                ),
              ),
            ],
          ),
        ],
        // Limite d'actions du tour (20/11/2026).
        if (!_horsTour && !_enReaction && _s.actionsRestantes != null) ...[
          const SizedBox(height: 8),
          Row(
            key: const Key('actions-restantes'),
            children: [
              Icon(
                _actionsEpuisees ? Icons.block : Icons.bolt,
                size: 18,
                color: _actionsEpuisees
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _actionsEpuisees
                      ? "Plus d'action ce tour : seuls les dégâts restent."
                      : 'Actions restantes ce tour : ${_s.actionsRestantes}',
                ),
              ),
            ],
          ),
        ],
        if (_horsTour) ...[
          const SizedBox(height: 8),
          Row(
            key: const Key('hors-tour'),
            children: [
              Icon(
                Icons.hourglass_top,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tour de ${_s.nomActif} : attaques, sorts et compétences '
                  'attendent ton tour.',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          // Réaction (contre-attaque, tenir en joue…) : une par manche.
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const Key('reaction'),
              onPressed: _s.reactionUtilisee
                  ? null
                  : () => setState(() => _reactionPendant = _tourActuel),
              icon: const Icon(Icons.flash_on),
              label: Text(_s.reactionUtilisee
                  ? 'Réaction (ou esquive) déjà faite cette manche'
                  : 'Réaction'),
            ),
          ),
        ],
        if (_enReaction) ...[
          const SizedBox(height: 8),
          Row(
            key: const Key('en-reaction'),
            children: [
              const Icon(Icons.flash_on, size: 18, color: OdvCouleurs.or),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _texteReaction(),
                  key: const Key('texte-reaction'),
                ),
              ),
              TextButton(
                key: const Key('fin-reaction'),
                onPressed: () => setState(() => _reactionPendant = null),
                child: const Text('Terminer'),
              ),
            ],
          ),
        ],
        // Recherche dans les actions (20/11/2026).
        if (fiche != null || attaques.isNotEmpty) ...[
          const SizedBox(height: 8),
          TextField(
            key: const Key('recherche-actions'),
            controller: _champRecherche,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search),
              hintText: 'Rechercher une attaque, un sort, un jet…',
              suffixIcon: _recherche.isEmpty
                  ? null
                  : IconButton(
                      key: const Key('effacer-recherche'),
                      tooltip: 'Effacer',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _champRecherche.clear();
                        _recherche = '';
                      }),
                    ),
            ),
            onChanged: (v) => setState(() => _recherche = v.trim()),
          ),
        ],
        if (_recherche.isNotEmpty)
          _resultatsRecherche(fiche, attaques, aptitudes, pasDeCible)
        else ...[
          const SizedBox(height: 8),
          // Favoris en tête : les actions les plus utilisées.
          if (favoris != null) favoris,
          // Bonus et malus de séance : reçus (verrouillés), donnés, à donner.
          _GroupeJets(
            cle: 'groupe-bonus',
            titre: () {
              final n =
                  fiche == null ? 0 : _s.bonusRecus(_s.idAttaquant).length;
              return n == 0 ? 'Bonus et malus' : 'Bonus et malus ($n reçus)';
            }(),
            icone: Icons.auto_fix_high_outlined,
            ouvert: fiche != null && _s.bonusRecus(_s.idAttaquant).isNotEmpty,
            children: [
              BlocBonus(
                seance: _s,
                cible: fiche == null ? null : _s.idAttaquant,
              ),
            ],
          ),
          // Situations à cocher (comme sur la page dé) : ajoutées aux jets.
          if (fiche != null && BlocSituations.aDuContenu(fiche))
            _GroupeJets(
              cle: 'groupe-situations',
              titre: _situations.isEmpty
                  ? 'Situations'
                  : 'Situations (${_situations.length})',
              icone: Icons.tune,
              ouvert: false,
              children: [
                BlocSituations(
                  fiche: fiche,
                  situations: _situations,
                  cleSituation: cleSituation,
                  onSituation: (cle) => setState(() {
                    if (!_situations.remove(cle)) _situations.add(cle);
                  }),
                ),
              ],
            ),
          if (attaques.isNotEmpty)
            _GroupeJets(
              cle: 'groupe-combat',
              memoire: 'groupe-combat-$mode',
              ouvert: combat,
              titre: 'Combat · $nom',
              icone: Icons.sports_martial_arts,
              children: [
                // Attaques du personnage ou de la créature sélectionnée ; la
                // cible est choisie dans une fenêtre à chaque attaque.
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final (i, a) in attaquesAffichees.indexed)
                      _puceAttaque(fiche, a, 'attaque-$i', pasDeCible),
                  ],
                ),
              ],
            ),
          // Sorts : dépensent leur coût, puis lancent leurs dés.
          if (fiche != null && sortsHorsFavoris.isNotEmpty)
            _GroupeJets(
              cle: 'groupe-sorts',
              // Replié en exploration, comme le combat (13/11/2026).
              memoire: 'groupe-sorts-$mode',
              ouvert: combat,
              titre: 'Sorts',
              icone: Icons.auto_awesome_outlined,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final (i, s) in sortsHorsFavoris.indexed)
                      _puceSort(fiche, s, 'sort-seance-$i', pasDeCible),
                  ],
                ),
              ],
            ),
          // Compétences : leurs jets, leurs actions en endurance, leur détail.
          if (fiche != null && fiche.competencesAcquises.isNotEmpty)
            _groupeCompetences(fiche, pasDeCible),
          if (attaques.isEmpty && _s.estMj) ...[
            const SizedBox(height: 16),
            const Text('Sélectionne un personnage ou une créature pour lancer '
                'ses attaques.'),
          ],
          // Tests de caractéristique d'une créature (MJ, 26/11/2026).
          if (fiche == null && attaquant.creature != null)
            _statsCreature(attaquant.creature!, pasDeCible, combat),
          // Tests de caractéristique du personnage du joueur.
          if (fiche != null) ...[
            _GroupeJets(
              cle: 'groupe-stats',
              memoire: 'groupe-stats-$mode',
              ouvert: !combat,
              titre: 'Statistiques',
              icone: Icons.bar_chart,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final c in Carac.values)
                      if (!fav.contains('stat:${c.code}'))
                        _puceStat(
                            fiche, c, 'test-seance-${c.code}', pasDeCible),
                  ],
                ),
              ],
            ),
            // Connaissances et aptitudes.
            _GroupeJets(
              cle: 'groupe-aptitudes',
              memoire: 'groupe-aptitudes-$mode',
              ouvert: !combat,
              titre: 'Aptitudes',
              icone: Icons.school_outlined,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final (i, j) in ([
                      for (final j in aptitudes)
                        if (!fav.contains('apt:${j.libelle}')) j,
                    ]..sort((a, b) => _alpha(a.libelle, b.libelle)))
                        .indexed)
                      _puceAptitude(fiche, j, 'aptitude-seance-$i', pasDeCible),
                  ],
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  /// Résultats de la recherche (20/11/2026) : toutes les actions dont le
  /// nom contient le texte, par ordre alphabétique, en une seule liste.
  Widget _resultatsRecherche(
    FicheCalculee? fiche,
    List<({String libelle, String des, int bonus, bool degats, String type})>
        attaques,
    List<JetSavoir> aptitudes,
    bool pasDeCible,
  ) {
    final puces = <({String nom, Widget puce})>[
      for (final (i, a) in attaques.indexed)
        if (_trouve(a.libelle))
          (
            nom: a.libelle,
            puce: _puceAttaque(fiche, a, 'trouve-attaque-$i', pasDeCible),
          ),
      if (fiche != null) ...[
        for (final (i, s) in fiche.sorts.indexed)
          if (_trouve(s.competence.nom))
            (
              nom: s.competence.nom,
              puce: _puceSort(fiche, s, 'trouve-sort-$i', pasDeCible),
            ),
        for (final (i, j) in _jetsCompetences(fiche).indexed)
          if (_trouve(j.libelle))
            (
              nom: j.libelle,
              puce: _puceJet(fiche, j, 'trouve-competence-$i', pasDeCible),
            ),
        for (final (i, a) in fiche.actionsEndurance.indexed)
          if (_trouve(a.libelle))
            (
              nom: a.libelle,
              puce: _puceAction(fiche, a, 'trouve-endurance-$i', pasDeCible),
            ),
        for (final c in Carac.values)
          if (_trouve(c.nom) || _trouve(c.abrev))
            (
              nom: c.nom,
              puce: _puceStat(fiche, c, 'trouve-stat-${c.code}', pasDeCible),
            ),
        for (final (i, j) in aptitudes.indexed)
          if (_trouve(j.libelle))
            (
              nom: j.libelle,
              puce: _puceAptitude(fiche, j, 'trouve-aptitude-$i', pasDeCible),
            ),
      ],
    ]..sort((a, b) => _alpha(a.nom, b.nom));
    return Padding(
      key: const Key('resultats-recherche'),
      padding: const EdgeInsets.only(top: 12),
      child: puces.isEmpty
          ? Text(
              'Aucune action ne correspond.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final p in puces) p.puce],
            ),
    );
  }
}

/// Dernier jet lancé depuis le panneau.
class _Resultat {
  const _Resultat({
    required this.libelle,
    required this.total,
    required this.detail,
    required this.touche,
    required this.ca,
    required this.note,
    required this.critique,
    required this.echec,
    required this.avantage,
    required this.secret,
    required this.sansDes,
    required this.erreur,
  });

  final String libelle;
  final int total;
  final String detail;
  final bool? touche;
  final int? ca;

  /// Pourquoi l'attaque n'est pas comparée à une CA.
  final String note;
  final bool critique;
  final bool echec;
  final bool avantage;

  /// Jet caché au joueur lui-même (MJ seul).
  final bool secret;
  final bool sansDes;
  final String? erreur;
}

/// Résultat lisible : grand total coloré, libellé, détail, touché ou raté.
class _CarteResultat extends StatelessWidget {
  const _CarteResultat({required this.resultat});

  final _Resultat resultat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final r = resultat;
    final sombre = theme.brightness == Brightness.dark;
    final vert = sombre ? OdvCouleurs.lightGreen : OdvCouleurs.darkGreen;
    final rouge = scheme.error;
    if (r.erreur case final e?) {
      return Text(
        e,
        key: const Key('resultat-seance'),
        style: TextStyle(color: rouge),
      );
    }
    if (r.secret || r.sansDes) {
      return Card(
        key: const Key('resultat-seance'),
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(r.secret ? Icons.lock_outline : Icons.check),
          title: Text(
            r.secret ? 'Jet envoyé au MJ : résultat caché.' : r.libelle,
          ),
          subtitle: r.secret ? null : const Text('Action lancée'),
        ),
      );
    }
    final couleur = r.critique || r.touche == true
        ? vert
        : r.echec || r.touche == false
            ? rouge
            : OdvCouleurs.or;
    final verdict = [
      if (r.critique) 'Réussite critique !',
      if (r.echec) 'Échec critique !',
      if (r.touche == true) r.ca == null ? 'Touché' : 'Touché (CA ${r.ca})',
      if (r.touche == false) 'Raté',
      if (r.note.isNotEmpty) r.note,
    ].join(' · ');
    return Card(
      key: const Key('resultat-seance'),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: couleur, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '${r.total}',
                    key: const Key('resultat-total'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: couleur,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.libelle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (verdict.isNotEmpty)
                    Text(
                      verdict,
                      key: const Key('resultat-verdict'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: couleur,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    r.detail,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Groupe de boutons de dés, repliable.
class _GroupeJets extends StatelessWidget {
  const _GroupeJets({
    required this.cle,
    required this.titre,
    required this.icone,
    required this.children,
    this.ouvert = true,
    this.memoire,
  });

  final String cle;

  /// Clé de l'état ouvert / replié (par mode de jeu : chaque mode garde le
  /// sien) ; [cle] par défaut.
  final String? memoire;
  final String titre;
  final IconData icone;
  final List<Widget> children;
  final bool ouvert;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey(memoire ?? cle),
        initiallyExpanded: ouvert,
        leading: Icon(icone, color: scheme.primary),
        title: Text(titre, overflow: TextOverflow.ellipsis),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        shape: const Border(),
        collapsedShape: const Border(),
        children: children,
      ),
    );
  }
}

class _Compteur extends StatelessWidget {
  const _Compteur({
    required this.cle,
    required this.libelle,
    required this.valeur,
    required this.min,
    required this.max,
    required this.onChange,
  });

  final String cle;
  final String libelle;
  final int valeur;
  final int min;
  final int max;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(libelle, overflow: TextOverflow.ellipsis)),
          IconButton(
            key: Key('$cle-moins'),
            onPressed: valeur > min ? () => onChange(valeur - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 36,
            child: Text('$valeur', textAlign: TextAlign.center),
          ),
          IconButton(
            key: Key('$cle-plus'),
            onPressed: valeur < max ? () => onChange(valeur + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      );
}

/// Jets que ce compte peut lire, du plus récent au plus ancien.
/// Icône de chaque nature de jet.
IconData iconeGenreJet(GenreJet g) => switch (g) {
      GenreJet.libre => Icons.casino_outlined,
      GenreJet.attaque => Icons.gps_fixed,
      GenreJet.degats => Icons.local_fire_department_outlined,
      GenreJet.sort => Icons.auto_awesome_outlined,
      GenreJet.test => Icons.fact_check_outlined,
      GenreJet.lieu => Icons.place_outlined,
    };

/// Section des logs (21/11/2026) : jets d'un même combat ou d'une même
/// phase d'exploration, numérotée depuis le début de la séance.
typedef SectionLogs = ({ModeJeu mode, int numero, List<JetSeance> jets});

/// Regroupe les jets (du plus ancien au plus récent) en sections, à chaque
/// changement de mode ; renvoie les sections de la plus récente à la plus
/// ancienne, jets du plus récent au plus ancien.
List<SectionLogs> sectionsLogs(List<JetSeance> jets) {
  final sections = <SectionLogs>[];
  final numeros = <ModeJeu, int>{};
  for (final j in jets) {
    if (sections.isEmpty || sections.last.mode != j.mode) {
      final n = numeros[j.mode] = (numeros[j.mode] ?? 0) + 1;
      sections.add((mode: j.mode, numero: n, jets: <JetSeance>[]));
    }
    sections.last.jets.add(j);
  }
  return [
    for (final s in sections.reversed)
      (mode: s.mode, numero: s.numero, jets: s.jets.reversed.toList()),
  ];
}

class _Historique extends StatefulWidget {
  const _Historique({required this.seance});

  final SeanceController seance;

  @override
  State<_Historique> createState() => _HistoriqueState();
}

class _HistoriqueState extends State<_Historique> {
  /// Sections ouvertes ou fermées à la main (« combat-2 » → ouverte) ; par
  /// défaut, seule la plus récente est ouverte.
  final Map<String, bool> _ouvertes = {};

  static String _cle(SectionLogs s) => '${s.mode.name}-${s.numero}';

  @override
  Widget build(BuildContext context) {
    final sections = sectionsLogs(widget.seance.jets);
    if (sections.isEmpty) {
      return const Center(child: TexteAVenir('Aucun jet pour l\'instant.'));
    }
    bool ouverte(SectionLogs s) =>
        _ouvertes[_cle(s)] ?? identical(s, sections.first);
    final toutOuvert = sections.every(ouverte);
    final lignes = <Widget>[
      if (sections.length > 1)
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            key: const Key('logs-tout'),
            onPressed: () => setState(() {
              for (final s in sections) {
                _ouvertes[_cle(s)] = !toutOuvert;
              }
            }),
            icon: Icon(toutOuvert ? Icons.unfold_less : Icons.unfold_more),
            label: Text(toutOuvert ? 'Tout replier' : 'Tout déplier'),
          ),
        ),
      for (final s in sections) ...[
        _TitreSectionLogs(
          section: s,
          ouverte: ouverte(s),
          onTap: () => setState(() => _ouvertes[_cle(s)] = !ouverte(s)),
        ),
        if (ouverte(s))
          for (final j in s.jets) _LigneJet(jet: j),
      ],
    ];
    return ListView(
      key: const Key('historique-seance'),
      padding: const EdgeInsets.all(8),
      children: lignes,
    );
  }
}

/// Début d'une section des logs : combat ou exploration, numéro, nombre de
/// lignes et heures ; toucher l'ouvre ou la replie (21/11/2026).
class _TitreSectionLogs extends StatelessWidget {
  const _TitreSectionLogs({
    required this.section,
    required this.ouverte,
    required this.onTap,
  });

  final SectionLogs section;
  final bool ouverte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mode = section.mode;
    final combat = mode == ModeJeu.combat;
    final couleur = combat ? OdvCouleurs.red : OdvCouleurs.green;
    String heure(DateTime d) {
      final h = d.toLocal();
      return '${h.hour.toString().padLeft(2, '0')}:'
          '${h.minute.toString().padLeft(2, '0')}';
    }

    final debut = heure(section.jets.last.heure);
    final fin = heure(section.jets.first.heure);
    final n = section.jets.length;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Material(
        color: couleur.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          key: Key('logs-${mode.name}-${section.numero}'),
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            key: Key('logs-${mode.name}'),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Icon(
                  combat ? Icons.sports_martial_arts : Icons.explore,
                  size: 16,
                  color: couleur,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${mode.libelle} ${section.numero} · $n ligne'
                    '${n > 1 ? 's' : ''} · '
                    '${debut == fin ? debut : '$debut – $fin'}',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                Icon(
                  ouverte ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Une ligne des logs : nature du jet, qui, quoi, dés et bonus, total.
class _LigneJet extends StatelessWidget {
  const _LigneJet({required this.jet});

  final JetSeance jet;

  @override
  Widget build(BuildContext context) {
    final j = jet;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sombre = theme.brightness == Brightness.dark;
    final (:des, :modificateur) = j.decomposition;
    String deux(int n) => n.toString().padLeft(2, '0');
    final h = j.heure.toLocal();
    final heure = '${deux(h.hour)}:${deux(h.minute)}';
    final malus = modificateur.startsWith('−') || modificateur.startsWith('-');
    final couleurBonus = malus
        ? scheme.error
        : sombre
            ? OdvCouleurs.lightGreen
            : OdvCouleurs.darkGreen;
    return Padding(
      key: Key('jet-${j.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          Tooltip(
            message: j.genre.libelle,
            child: Icon(
              iconeGenreJet(j.genre),
              key: Key('genre-${j.genre.name}'),
              size: 22,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (j.visibilite != VisibiliteJet.tous)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Tooltip(
                          message: j.visibilite.libelle,
                          child: const Icon(Icons.visibility_off_outlined,
                              size: 16),
                        ),
                      ),
                    Flexible(
                      // Long : sur plusieurs lignes (20/11/2026).
                      child: Text(
                        '${j.auteurNom} · ${j.libelle}'
                        '${j.cible.isEmpty ? '' : ' → ${j.cible}'}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                Text.rich(
                  TextSpan(
                    text: heure,
                    children: [
                      if (j.detail.isNotEmpty) TextSpan(text: ' · $des'),
                      if (modificateur.isNotEmpty)
                        TextSpan(
                          text: '  $modificateur',
                          style: TextStyle(
                            color: couleurBonus,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  key: Key('detail-jet-${j.id}'),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                if (j.resultatCible.isNotEmpty)
                  Text(
                    j.resultatCible,
                    key: Key('touche-jet-${j.id}'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: switch (j.touche) {
                        null => scheme.onSurfaceVariant,
                        true => sombre
                            ? OdvCouleurs.lightGreen
                            : OdvCouleurs.darkGreen,
                        false => scheme.error,
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (j.detail.isNotEmpty) ...[
            const SizedBox(width: 8),
            // Le résultat final, bonus et malus compris : il ressort.
            Container(
              key: Key('total-jet-${j.id}'),
              constraints: const BoxConstraints(minWidth: 44),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: OdvCouleurs.or.withValues(alpha: 0.18),
                border: Border.all(color: OdvCouleurs.or),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${j.total}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
