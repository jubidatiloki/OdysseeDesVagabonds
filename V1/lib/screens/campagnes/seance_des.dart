import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/carac.dart';
import '../../models/seance.dart';
import '../../models/voie.dart';
import '../../regles/des.dart';
import '../../regles/fiche_calculee.dart';
import '../../state/seance_controller.dart';
import '../../widgets/consultation.dart';
import '../de_screen.dart';

/// Portion de droite : onglets Lancer de dés et Historique.
class PanneauDes extends StatelessWidget {
  const PanneauDes({super.key, required this.seance, this.aleatoire});

  final SeanceController seance;
  final Random? aleatoire;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(key: Key('onglet-des'), text: 'Lancer de dés'),
              Tab(key: Key('onglet-historique'), text: 'Historique'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _Lanceur(seance: seance, aleatoire: aleatoire),
                _Historique(seance: seance),
              ],
            ),
          ),
        ],
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
  List<({String libelle, String des, int bonus})> _attaques() {
    final a = _s.attaquant;
    final res = <({String libelle, String des, int bonus})>[];
    void ajouter(String libelle, String des, int bonus) {
      if (lireFormule(des) != null) {
        res.add((libelle: libelle, des: des, bonus: bonus));
      }
    }

    if (a.creature case final c?) {
      for (final x in c.attaques) {
        ajouter('${x.nom} · toucher', x.toucher, 0);
        ajouter('${x.nom} · dégâts', x.degats, 0);
      }
    }
    if (a.fiche case final f?) {
      ajouter('Toucher CaC', '1d20', f.toucherCac);
      ajouter('Toucher distance', '1d20', f.toucherDistance);
      ajouter('Toucher magie', '1d20', f.toucherMagie);
      for (final d in [f.detailDegatsCac, f.detailDegatsDistance]) {
        for (final arme in d.armes) {
          ajouter('Dégâts · ${arme.nom}', d.des(arme), d.bonusAvec(arme));
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
      );
    }
    if (jets.isEmpty) {
      await _lancer(
        libelle: sort.nom,
        jets: const [],
        modificateur: 0,
        parAttaquant: true,
        avecCible: true,
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
    );
  }

  Future<void> _lancer({
    required String libelle,
    required List<int> jets,
    required int modificateur,
    bool parAttaquant = false,
    bool avecCible = false,
  }) async {
    final total = jets.fold(0, (a, b) => a + b) + modificateur;
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
      cibleJet: avecCible ? _nomCible : '',
    );
    if (!mounted) return;
    final secret = !_s.estMj && _visibilite == VisibiliteJet.mjSeul;
    setState(() {
      _resultat = erreur ??
          (secret
              ? 'Jet envoyé au MJ : résultat caché.'
              : jets.isEmpty
                  ? '$libelle : lancé'
                  : '$libelle : $total ($detail)');
    });
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
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
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
        if (_resultat != null) ...[
          const SizedBox(height: 12),
          Text(
            _resultat!,
            key: const Key('resultat-seance'),
            style: theme.textTheme.titleMedium,
          ),
        ],
        // Attaques du personnage ou de la créature sélectionnée.
        if (attaques.isNotEmpty) ...[
          const SizedBox(height: 16),
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
                  const DropdownMenuItem(value: 'soi', child: Text('Soi-même')),
                  const DropdownMenuItem(
                      value: '', child: Text('Aucune cible')),
                ],
                onChanged: (v) => setState(() => _cibleAttaque = v),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Attaques · $nom', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (i, a) in attaques.indexed)
                ActionChip(
                  key: Key('attaque-$i'),
                  label: Text('${a.libelle} : ${formaterJet(a.des, a.bonus)}'),
                  onPressed: pasDeCible
                      ? null
                      : () => _lancerFormule(
                            a.libelle,
                            a.des,
                            a.bonus,
                            parAttaquant: true,
                            avecCible: true,
                          ),
                ),
            ],
          ),
        ],
        // Sorts : dépensent leur coût, puis lancent leurs dés.
        if (fiche != null && fiche.sorts.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Sorts · $nom', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (i, s) in fiche.sorts.indexed)
                ActionChip(
                  key: Key('sort-seance-$i'),
                  label: Text(
                    '${s.competence.nom} : ${s.cout} ${fiche.uniteSorts}',
                  ),
                  onPressed: pasDeCible || fiche.pointsPourSorts < s.cout
                      ? null
                      : () => _lancerSort(fiche, s),
                ),
            ],
          ),
        ],
        if (attaques.isEmpty && _s.estMj) ...[
          const SizedBox(height: 16),
          const Text('Sélectionne un personnage ou une créature pour lancer '
              'ses attaques.'),
        ],
        // Tests de caractéristique du personnage du joueur.
        if (fiche != null) ...[
          const SizedBox(height: 16),
          Text('Tests de caractéristique', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
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
                          ),
                ),
            ],
          ),
        ],
      ],
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
class _Historique extends StatelessWidget {
  const _Historique({required this.seance});

  final SeanceController seance;

  @override
  Widget build(BuildContext context) {
    final jets = seance.jets.reversed.toList();
    if (jets.isEmpty) {
      return const Center(child: TexteAVenir('Aucun jet pour l\'instant.'));
    }
    final theme = Theme.of(context);
    return ListView.builder(
      key: const Key('historique-seance'),
      padding: const EdgeInsets.all(8),
      itemCount: jets.length,
      itemBuilder: (context, i) {
        final j = jets[i];
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: j.visibilite == VisibiliteJet.tous
              ? null
              : Tooltip(
                  message: j.visibilite.libelle,
                  child: const Icon(Icons.visibility_off_outlined, size: 18),
                ),
          title: Text(
            '${j.auteurNom} · ${j.libelle}'
            '${j.cible.isEmpty ? '' : ' → ${j.cible}'}',
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: j.detail.isEmpty
              ? null
              : Text(j.detail, overflow: TextOverflow.ellipsis),
          trailing: j.detail.isEmpty
              ? null
              : Text('${j.total}', style: theme.textTheme.titleMedium),
        );
      },
    );
  }
}
