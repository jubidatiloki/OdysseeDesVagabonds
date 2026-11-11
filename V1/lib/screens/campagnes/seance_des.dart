import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/aptitude.dart';
import '../../models/carac.dart';
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
import '../de_screen.dart';
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

  /// Cible choisie pour les attaques et les sorts ('soi', '' : aucune).
  String? _cibleAttaque;

  /// Dernier résultat affiché.
  _Resultat? _dernier;

  /// Dégâts des attaques de créature sans jet d'attaque (libellé → note) :
  /// le joueur visé peut esquiver.
  final Map<String, String> _sansJet = {};

  /// Situations cochées (« +1 en forêt »…), comme sur la page dé.
  final Set<String> _situations = {};

  /// Alerte : deuxième attaque du tour (rien n'est bloqué).
  String? _alerte;

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
      if (cac.armes.isNotEmpty || mainsNues) {
        ajouter('Toucher CaC', '1d20', f.toucherCac);
      }
      if (dist.armes.isNotEmpty) {
        ajouter('Toucher distance', '1d20', f.toucherDistance);
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

  /// Compétence qui donne la créature [id] au personnage (pour son RANG).
  String _competenceDe(FicheCalculee f, String id) {
    for (final k in compagnonsCombattants(
        f, {for (final x in _s.referentiel.creatures) x.id: x})) {
      if (k.creature.id == id) return k.competence;
    }
    return '';
  }

  /// Jet de dégâts : son total est retiré des PV de la cible.
  static bool _estDegats(String libelle) =>
      libelle.toLowerCase().contains('dégâts');

  /// Cible en vigueur : celle choisie, sinon la première autre que soi.
  String get _cibleEnCours {
    final ids = _s.cibles.map((c) => c.id);
    final v = _cibleAttaque;
    if (v != null && (v == 'soi' || v.isEmpty || ids.contains(v))) return v;
    return ids.isEmpty ? '' : ids.first;
  }

  String get _nomCible => _cibleEnCours == 'soi'
      ? 'soi-même'
      : _s.nomCible(_cibleEnCours, _visibilite);

  /// Sort : dépense son coût, puis lance ses dés (réussite, effets).
  Future<void> _lancerSort(
    FicheCalculee f,
    ({Competence competence, int rangSort, int cout}) s,
  ) async {
    final sort = s.competence;
    _verifierAttaque();
    await _s.depenserSort(f, sort.nom, s.cout);
    final jets = [
      if (f.jetReussite(sort) case final j?) j,
      ...f.jetsEffetSort(sort),
    ].where((j) => lireFormule(j.des) != null).toList();
    // Totaux des jets (durée et nombre d'une invocation).
    final totaux = <String, int>{};
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
      );
      if (t != null) totaux[j.libelle.toLowerCase()] = t;
    }
    if (jets.isEmpty) {
      await _lancer(
        libelle: sort.nom,
        parAttaquant: true,
        avecCible: true,
        genre: GenreJet.sort,
      );
    }
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
  /// Renvoie le total lancé (`null` : rien lancé).
  Future<int?> _lancerFormule(
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
    final seuils = fiche != null && contreCa ? fiche.seuilsAttaques : null;
    final r = ResultatLancer.lancer(
      libelle: libelle,
      de: des,
      bonus: bonus,
      situations: situ.bonus,
      mode: situ.avantage.isEmpty ? ModeLancer.normal : ModeLancer.avantage,
      origineMode: situ.avantage.join(', '),
      aleatoire: widget.aleatoire,
      seuilCritique: seuils?.critique ?? 20,
      seuilEchec: seuils?.echec ?? 1,
    );
    if (r == null) return null;
    await _lancer(
      libelle: libelle,
      resultat: r,
      parAttaquant: parAttaquant,
      avecCible: avecCible,
      degats: degats,
      type: type,
      genre: genre,
      contreCa: contreCa && d20,
    );
    return r.total;
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
  }) async {
    final r = resultat;
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
    // Attaque : comparée à la CA de la cible, si elle est connue.
    final cibleCa = _cibleEnCours == 'soi' ? '' : _cibleEnCours;
    final attaque = contreCa && r != null && r.d20;
    final ca = attaque && cibleCa.isNotEmpty ? _s.caDe(cibleCa) : null;
    // Pas de comparaison : le jet dit pourquoi.
    final sansComparaison = !attaque || ca != null
        ? ''
        : cibleCa.isEmpty
            ? 'Sans cible : pas de comparaison'
            : 'CA de la cible inconnue';
    final touche = ca == null || r == null
        ? null
        : attaqueTouche(naturel: r.garde, total: total, ca: ca);
    final detail = r?.detail ?? '';
    final erreur = await _s.lancer(
      libelle: libelle,
      detail: detail,
      total: total,
      visibilite: _visibilite,
      cible: _cible,
      parAttaquant: parAttaquant,
      genre: genre,
      caCible: ca,
      touche: touche,
      sansComparaison: sansComparaison,
      cibleJet: avecCible
          ? [
              _nomCible,
              if (degats && type != 'physique' && _nomCible.isNotEmpty)
                '($type)',
            ].join(' ')
          : '',
    );
    if (erreur == null && degats) {
      final cible = _cibleEnCours == 'soi' ? _s.idAttaquant : _cibleEnCours;
      // Attaque sans jet d'attaque sur un joueur : il pourra esquiver.
      int? esquive;
      var moitie = false;
      final note = _sansJet[libelle];
      if (note != null && _s.joueurs.any((m) => m.uid == cible)) {
        esquive = await _demanderDifficulte(libelle);
        moitie = esquiveDonneMoitie(note);
      }
      await _s.infligerDegats(
        cible,
        total,
        '${_s.attaquant.nom} · $libelle',
        type: type,
        esquive: esquive,
        moitie: moitie,
      );
    }
    // Jet du personnage : inscrit dans son historique, avec la séance.
    if (erreur == null && r != null && fiche != null) {
      await _s.journaliserJet(
        fiche,
        '$libelle : $total ($detail)'
        '${r.reussiteCritique ? ' · réussite critique' : ''}'
        '${r.echecCritique ? ' · échec critique' : ''}'
        '${touche == null ? '' : touche ? ' · touché' : ' · raté'}',
      );
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

  /// Appui long sur un bouton : met l'action en favori, ou l'en retire.
  /// [cle] : nom de la compétence, ou « stat:FOR », « apt:… », « att:… ».
  Widget _avecFavori(
    FicheCalculee fiche,
    String cle,
    String nom,
    Widget bouton,
  ) =>
      GestureDetector(
        onLongPress: () => _basculerFavori(fiche, cle, nom),
        child: bouton,
      );

  Future<void> _basculerFavori(
    FicheCalculee fiche,
    String cle,
    String nom,
  ) async {
    final ajoute = !fiche.personnage.favoris.contains(cle);
    final messager = ScaffoldMessenger.of(context);
    await _s.basculerFavori(fiche, cle);
    if (!mounted) return;
    setState(() {});
    messager
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ajoute
                ? '$nom : ajouté aux favoris.'
                : '$nom : retiré des favoris.',
          ),
        ),
      );
  }

  /// Bouton mis en avant (avantage, maîtrise) : bordure et texte verts.
  Widget _puce({
    required String cle,
    required String texte,
    required VoidCallback? onPressed,
    Color? vert,
  }) =>
      ActionChip(
        key: Key(cle),
        side: vert == null ? null : BorderSide(color: vert, width: 2),
        label: Text(
          texte,
          style: vert == null
              ? null
              : TextStyle(color: vert, fontWeight: FontWeight.w700),
        ),
        onPressed: onPressed,
      );

  Widget _puceSort(
    FicheCalculee fiche,
    ({Competence competence, int rangSort, int cout}) s,
    String cle,
    bool pasDeCible,
  ) =>
      _avecFavori(
        fiche,
        s.competence.nom,
        s.competence.nom,
        _puce(
          cle: cle,
          texte: '${s.competence.nom} : ${s.cout} ${fiche.uniteSorts}',
          onPressed: pasDeCible || fiche.pointsPourSorts < s.cout
              ? null
              : () => _lancerSort(fiche, s),
        ),
      );

  Widget _puceJet(
    FicheCalculee fiche,
    JetDisponible j,
    String cle,
    bool pasDeCible,
  ) =>
      _avecFavori(
        fiche,
        j.origine,
        j.origine,
        _puce(
          cle: cle,
          texte: '${j.libelle} : ${formaterJet(j.des, j.bonus)}',
          onPressed: pasDeCible
              ? null
              : () => _lancerFormule(
                    j.libelle,
                    j.des,
                    j.bonus,
                    parAttaquant: true,
                    genre: GenreJet.test,
                  ),
        ),
      );

  Widget _puceAction(
    FicheCalculee fiche,
    ({String libelle, int cout, String origine}) a,
    String cle,
    bool pasDeCible,
  ) =>
      _avecFavori(
        fiche,
        a.origine,
        a.origine,
        _puce(
          cle: cle,
          texte: '${a.libelle} : ${a.cout} PE',
          onPressed: pasDeCible || fiche.peActuels < a.cout
              ? null
              : () async {
                  await _s.depenserAction(fiche, a);
                  await _lancer(
                    libelle: '${a.libelle} (${a.cout} PE)',
                    parAttaquant: true,
                  );
                },
        ),
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
    return _avecFavori(
      fiche,
      'stat:${c.code}',
      'Test de ${c.abrev}',
      // Pas d'infobulle : elle capterait l'appui long (favori).
      Builder(
        builder: (_) => _puce(
          cle: cle,
          texte: '${c.abrev} ${formaterModificateur(fiche.mod(c))}'
              '${avantage == null ? '' : ' · avantage'}',
          vert: vert,
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
    return _avecFavori(
      fiche,
      'apt:${j.libelle}',
      j.libelle,
      _puce(
        cle: cle,
        texte: '${j.libelle} '
            '${formaterModificateur(fiche.mod(j.carac) + j.total)}'
            '${avantage == null ? '' : ' · avantage'}',
        vert: vert,
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
      ),
    );
  }

  /// Attaque ou dégâts ; en favori seulement pour un personnage.
  Widget _puceAttaque(
    FicheCalculee? fiche,
    ({String libelle, String des, int bonus, bool degats, String type}) a,
    String cle,
    bool pasDeCible,
  ) {
    final bouton = _puce(
      cle: cle,
      texte: '${a.libelle} : ${formaterJet(a.des, a.bonus)}',
      onPressed: pasDeCible
          ? null
          : () {
              if (!a.degats) _verifierAttaque();
              _lancerFormule(
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
              );
            },
    );
    return fiche == null
        ? bouton
        : _avecFavori(fiche, 'att:${a.libelle}', a.libelle, bouton);
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
    final jets = [
      for (final j in _jetsCompetences(fiche))
        if (!fav.contains(j.origine)) j,
    ];
    final actions = [
      for (final a in fiche.actionsEndurance)
        if (!fav.contains(a.origine)) a,
    ];
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
          'Favoris : bouton « Gérer les favoris » (ou appui long).',
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
    ];
    return ListView(
      key: const Key('panneau-des'),
      padding: const EdgeInsets.all(12),
      children: [
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
        const SizedBox(height: 8),
        // Favoris en tête : les actions les plus utilisées.
        if (favoris != null) favoris,
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
              // Attaques du personnage ou de la créature sélectionnée.
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Cible'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    key: const Key('cible-attaque'),
                    isDense: true,
                    isExpanded: true,
                    value: _cibleEnCours,
                    items: [
                      for (final c in _s.cibles)
                        DropdownMenuItem(
                          value: c.id,
                          child: Text(c.nom, overflow: TextOverflow.ellipsis),
                        ),
                      const DropdownMenuItem(
                          value: 'soi', child: Text('Soi-même')),
                      const DropdownMenuItem(
                          value: '', child: Text('Aucune cible')),
                    ],
                    onChanged: (v) => setState(() => _cibleAttaque = v),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                      _puceStat(fiche, c, 'test-seance-${c.code}', pasDeCible),
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
                  for (final (i, j) in [
                    for (final j in aptitudes)
                      if (!fav.contains('apt:${j.libelle}')) j,
                  ].indexed)
                    _puceAptitude(fiche, j, 'aptitude-seance-$i', pasDeCible),
                ],
              ),
            ],
          ),
        ],
      ],
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
    };

class _Historique extends StatelessWidget {
  const _Historique({required this.seance});

  final SeanceController seance;

  @override
  Widget build(BuildContext context) {
    final jets = seance.jets.reversed.toList();
    if (jets.isEmpty) {
      return const Center(child: TexteAVenir('Aucun jet pour l\'instant.'));
    }
    // Une section à chaque changement de mode (du plus récent au plus ancien).
    final lignes = <Widget>[];
    for (final (i, j) in jets.indexed) {
      if (i == 0 || jets[i - 1].mode != j.mode) {
        lignes.add(_TitreSectionLogs(mode: j.mode));
      }
      lignes.add(_LigneJet(jet: j));
    }
    return ListView(
      key: const Key('historique-seance'),
      padding: const EdgeInsets.all(8),
      children: lignes,
    );
  }
}

/// Début d'une section des logs : combat ou exploration.
class _TitreSectionLogs extends StatelessWidget {
  const _TitreSectionLogs({required this.mode});

  final ModeJeu mode;

  @override
  Widget build(BuildContext context) {
    final combat = mode == ModeJeu.combat;
    final couleur = combat ? OdvCouleurs.red : OdvCouleurs.green;
    return Container(
      key: Key('logs-${mode.name}'),
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            combat ? Icons.sports_martial_arts : Icons.explore,
            size: 16,
            color: couleur,
          ),
          const SizedBox(width: 6),
          Text(mode.libelle, style: Theme.of(context).textTheme.labelLarge),
        ],
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
    final heure = '${deux(j.date.hour)}:${deux(j.date.minute)}';
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
                      child: Text(
                        '${j.auteurNom} · ${j.libelle}'
                        '${j.cible.isEmpty ? '' : ' → ${j.cible}'}',
                        overflow: TextOverflow.ellipsis,
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
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                if (j.resultatCible.isNotEmpty)
                  Text(
                    j.resultatCible,
                    key: Key('touche-jet-${j.id}'),
                    overflow: TextOverflow.ellipsis,
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
