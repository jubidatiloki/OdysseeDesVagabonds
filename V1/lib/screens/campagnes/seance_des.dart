import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/aptitude.dart';
import '../../models/carac.dart';
import '../../models/seance.dart';
import '../../models/voie.dart';
import '../../regles/des.dart';
import '../../regles/fiche_calculee.dart';
import '../../regles/savoirs.dart';
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
  String? _resultat;

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

    if (a.creature case final c?) {
      for (final x in c.attaques) {
        ajouter('${x.nom} · toucher', x.toucher, 0);
        ajouter('${x.nom} · dégâts', x.degats, 0,
            type: typeDegatsDepuis(x.degats));
      }
    }
    if (a.fiche case final f?) {
      ajouter('Toucher CaC', '1d20', f.toucherCac);
      ajouter('Toucher distance', '1d20', f.toucherDistance);
      ajouter('Toucher magie', '1d20', f.toucherMagie);
      for (final d in [f.detailDegatsCac, f.detailDegatsDistance]) {
        for (final arme in d.armes) {
          ajouter(
            'Dégâts · ${arme.nom}',
            d.des(arme),
            d.bonusAvec(arme),
            type: arme.element.isEmpty ? 'physique' : arme.element,
          );
        }
        if (d.mainsNues) {
          ajouter('Dégâts · Mains nues', d.desMainsNuesAvec, d.bonusMainsNues);
        }
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
    }
    return res;
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
    for (final j in jets) {
      await _lancerFormule(
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
    }
    if (jets.isEmpty) {
      await _lancer(
        libelle: sort.nom,
        jets: const [],
        modificateur: 0,
        parAttaquant: true,
        avecCible: true,
        genre: GenreJet.sort,
      );
    }
  }

  /// Lance une formule (« 1d8 + 1d6 + 2 »).
  Future<void> _lancerFormule(
    String libelle,
    String des,
    int bonus, {
    bool parAttaquant = false,
    bool avecCible = false,
    bool degats = false,
    String type = 'physique',
    GenreJet genre = GenreJet.libre,
    bool contreCa = false,
  }) async {
    final f = lireFormule(des);
    if (f == null) return;
    await _lancer(
      libelle: libelle,
      jets: [
        for (final g in f.groupes)
          for (var i = 0; i < g.nombre; i++)
            lancerDe(g.faces, aleatoire: widget.aleatoire),
      ],
      modificateur: f.bonus + bonus,
      parAttaquant: parAttaquant,
      avecCible: avecCible,
      degats: degats,
      type: type,
      genre: genre,
      contreCa:
          contreCa && f.groupes.length == 1 && f.groupes.first.faces == 20,
    );
  }

  Future<void> _lancer({
    required String libelle,
    required List<int> jets,
    required int modificateur,
    bool parAttaquant = false,
    bool avecCible = false,
    bool degats = false,
    String type = 'physique',
    GenreJet genre = GenreJet.libre,
    bool contreCa = false,
  }) async {
    final total = jets.fold(0, (a, b) => a + b) + modificateur;
    AnimationLancer.montrer(context, total: total, libelle: libelle);
    // Attaque : comparée à la CA de la cible, si elle est connue.
    final cibleCa = _cibleEnCours == 'soi' ? '' : _cibleEnCours;
    final attaque = contreCa && jets.length == 1;
    final ca = attaque && cibleCa.isNotEmpty ? _s.caDe(cibleCa) : null;
    // Pas de comparaison : le jet dit pourquoi.
    final sansComparaison = !attaque || ca != null
        ? ''
        : cibleCa.isEmpty
            ? 'Sans cible : pas de comparaison'
            : 'CA de la cible inconnue';
    final touche = ca == null
        ? null
        : attaqueTouche(naturel: jets.first, total: total, ca: ca);
    final detail = jets.isEmpty
        ? ''
        : [
            jets.join(' + '),
            if (modificateur != 0) formaterModificateur(modificateur),
          ].join(' ');
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
      await _s.infligerDegats(
        cible,
        total,
        '${_s.attaquant.nom} · $libelle',
        type: type,
      );
    }
    if (!mounted) return;
    final secret = !_s.estMj && _visibilite == VisibiliteJet.mjSeul;
    setState(() {
      _resultat = erreur ??
          (secret
              ? 'Jet envoyé au MJ : résultat caché.'
              : jets.isEmpty
                  ? '$libelle : lancé'
                  : '$libelle : $total ($detail)'
                      '${touche != null ? ' · ${touche ? 'Touché (CA $ca)' : 'Raté'}' : sansComparaison.isEmpty ? '' : ' · $sansComparaison'}');
    });
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

  /// Appui long sur un bouton : met sa compétence en favori, ou l'en retire.
  Widget _avecFavori(FicheCalculee fiche, String nom, Widget bouton) =>
      GestureDetector(
        onLongPress: () => _basculerFavori(fiche, nom),
        child: bouton,
      );

  Future<void> _basculerFavori(FicheCalculee fiche, String nom) async {
    final ajoute = !fiche.personnage.favoris.contains(nom);
    final messager = ScaffoldMessenger.of(context);
    await _s.basculerFavori(fiche, nom);
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

  Widget _puceSort(
    FicheCalculee fiche,
    ({Competence competence, int rangSort, int cout}) s,
    String cle,
    bool pasDeCible,
  ) =>
      _avecFavori(
        fiche,
        s.competence.nom,
        ActionChip(
          key: Key(cle),
          label: Text('${s.competence.nom} : ${s.cout} ${fiche.uniteSorts}'),
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
        ActionChip(
          key: Key(cle),
          label: Text('${j.libelle} : ${formaterJet(j.des, j.bonus)}'),
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
        ActionChip(
          key: Key(cle),
          label: Text('${a.libelle} : ${a.cout} PE'),
          onPressed: pasDeCible || fiche.peActuels < a.cout
              ? null
              : () async {
                  await _s.depenserAction(fiche, a);
                  await _lancer(
                    libelle: '${a.libelle} (${a.cout} PE)',
                    jets: const [],
                    modificateur: 0,
                    parAttaquant: true,
                  );
                },
        ),
      );

  /// Favoris : sorts, jets et actions des compétences mises en favori.
  Widget? _groupeFavoris(FicheCalculee fiche, bool pasDeCible) {
    final fav = fiche.personnage.favoris;
    if (fav.isEmpty) return null;
    final sorts = [
      for (final s in fiche.sorts)
        if (fav.contains(s.competence.nom)) s,
    ];
    final jets = [
      for (final j in _jetsCompetences(fiche))
        if (fav.contains(j.origine)) j,
    ];
    final actions = [
      for (final a in fiche.actionsEndurance)
        if (fav.contains(a.origine)) a,
    ];
    if (sorts.isEmpty && jets.isEmpty && actions.isEmpty) return null;
    return _GroupeJets(
      cle: 'groupe-favoris',
      titre: 'Favoris',
      icone: Icons.star_outline,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (i, s) in sorts.indexed)
              _puceSort(fiche, s, 'favori-sort-$i', pasDeCible),
            for (final (i, j) in jets.indexed)
              _puceJet(fiche, j, 'favori-competence-$i', pasDeCible),
            for (final (i, a) in actions.indexed)
              _puceAction(fiche, a, 'favori-endurance-$i', pasDeCible),
          ],
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
          'Appui long sur un bouton, ou étoile du détail : favori.',
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
    final favoris = fiche == null ? null : _groupeFavoris(fiche, pasDeCible);
    final sortsHorsFavoris = [
      for (final s in fiche?.sorts ??
          const <({Competence competence, int rangSort, int cout})>[])
        if (!fiche!.personnage.favoris.contains(s.competence.nom)) s,
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
        if (_resultat != null) ...[
          const SizedBox(height: 12),
          Text(
            _resultat!,
            key: const Key('resultat-seance'),
            style: theme.textTheme.titleMedium,
          ),
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
        // Favoris en tête : les compétences et sorts les plus utilisés.
        if (favoris != null) favoris,
        if (attaques.isNotEmpty)
          _GroupeJets(
            cle: 'groupe-combat',
            titre: 'Combat · $nom',
            icone: Icons.sports_martial_arts,
            children: [
              // Attaques du personnage ou de la créature sélectionnée.
              ...[
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
                    for (final (i, a) in attaques.indexed)
                      ActionChip(
                        key: Key('attaque-$i'),
                        label: Text(
                            '${a.libelle} : ${formaterJet(a.des, a.bonus)}'),
                        onPressed: pasDeCible
                            ? null
                            : () {
                                if (!a.degats) _verifierAttaque();
                                _lancerFormule(
                                  a.libelle,
                                  a.des,
                                  a.bonus,
                                  contreCa: !a.degats,
                                  parAttaquant: true,
                                  avecCible: true,
                                  degats: a.degats,
                                  type: a.type,
                                  genre: a.degats
                                      ? GenreJet.degats
                                      : GenreJet.attaque,
                                );
                              },
                      ),
                  ],
                ),
              ],
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
            titre: 'Statistiques',
            icone: Icons.bar_chart,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in Carac.values)
                    ActionChip(
                      key: Key('test-seance-${c.code}'),
                      label: Text(
                        '${c.abrev} ${formaterModificateur(fiche.mod(c))}',
                      ),
                      onPressed: pasDeCible
                          ? null
                          : () => _lancerFormule(
                                'Test de ${c.abrev}',
                                '1d20',
                                fiche.mod(c),
                                parAttaquant: true,
                                genre: GenreJet.test,
                              ),
                    ),
                ],
              ),
            ],
          ),
          // Connaissances et aptitudes : replié, la liste est longue.
          _GroupeJets(
            cle: 'groupe-aptitudes',
            titre: 'Aptitudes',
            icone: Icons.school_outlined,
            ouvert: false,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final (i, j) in [
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
                  ].indexed)
                    ActionChip(
                      key: Key('aptitude-seance-$i'),
                      label: Text(
                        '${j.libelle} ${formaterModificateur(fiche.mod(j.carac) + j.total)}',
                      ),
                      onPressed: pasDeCible
                          ? null
                          : () => _lancerFormule(
                                j.libelle,
                                '1d20',
                                fiche.mod(j.carac) + j.total,
                                parAttaquant: true,
                                genre: GenreJet.test,
                              ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ],
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
  });

  final String cle;
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
        key: PageStorageKey(cle),
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
