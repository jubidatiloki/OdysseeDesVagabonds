import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/carac.dart';
import '../../models/seance.dart';
import '../../regles/des.dart';
import '../../regles/fiche_calculee.dart';
import '../../state/seance_controller.dart';
import '../../widgets/consultation.dart';

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

  Future<void> _lancer({
    required String libelle,
    required int nombre,
    required int faces,
    required int modificateur,
  }) async {
    final jets = [
      for (var i = 0; i < nombre; i++)
        lancerDe(faces, aleatoire: widget.aleatoire),
    ];
    final total = jets.fold(0, (a, b) => a + b) + modificateur;
    final detail = [
      jets.join(' + '),
      if (modificateur != 0) formaterModificateur(modificateur),
    ].join(' ');
    final erreur = await _s.lancer(
      libelle: libelle,
      detail: detail,
      total: total,
      visibilite: _visibilite,
      cible: _cible,
    );
    if (!mounted) return;
    final secret = !_s.estMj && _visibilite == VisibiliteJet.mjSeul;
    setState(() {
      _resultat = erreur ??
          (secret
              ? 'Jet envoyé au MJ : résultat caché.'
              : '$libelle : $total ($detail)');
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final fiche = _s.maFiche;
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
              : () => _lancer(
                    libelle: '${_nombre}d$_de',
                    nombre: _nombre,
                    faces: _de,
                    modificateur: _modificateur,
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
                      : () => _lancer(
                            libelle: 'Test de ${c.abrev}',
                            nombre: 1,
                            faces: 20,
                            modificateur: fiche.mod(c),
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
            '${j.auteurNom} · ${j.libelle}',
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(j.detail, overflow: TextOverflow.ellipsis),
          trailing: Text('${j.total}', style: theme.textTheme.titleMedium),
        );
      },
    );
  }
}
