import 'dart:math';

import 'package:flutter/material.dart';

import '../../state/seance_controller.dart';
import '../../theme.dart';
import '../../widgets/consultation.dart';
import '../regles_screen.dart';
import 'campagnes_screen.dart';
import 'seance_cartes.dart';
import 'seance_creatures.dart';
import 'seance_des.dart';

/// Interface de jeu d'une séance. En haut, la navigation : Tableau de bord,
/// Créatures (MJ seulement), Règles système, Paramètres. Le tableau de bord
/// a trois portions : les cartes à gauche, le détail de la carte au centre,
/// les dés et l'historique à droite (trois vues sur téléphone).
class SeanceScreen extends StatefulWidget {
  const SeanceScreen({
    super.key,
    required this.contexte,
    required this.campagneId,
    this.aleatoire,
  });

  final ContexteCampagnes contexte;
  final String campagneId;

  /// Dés (tests).
  final Random? aleatoire;

  /// Largeur à partir de laquelle les trois portions tiennent côte à côte.
  static const double largeurTroisPortions = 900;

  @override
  State<SeanceScreen> createState() => _SeanceScreenState();
}

class _SeanceScreenState extends State<SeanceScreen> {
  late final SeanceController _seance = SeanceController(
    campagnes: widget.contexte.campagnes,
    personnages: widget.contexte.personnages,
    referentiel: widget.contexte.referentiel,
    campagneId: widget.campagneId,
  );

  @override
  void dispose() {
    _seance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _seance,
      builder: (context, _) {
        final s = _seance;
        final c = s.campagne;
        if (c == null || !c.seanceEnCours) {
          return Scaffold(
            appBar: AppBar(title: const Text('Séance')),
            body: const Center(
              child: TexteAVenir('Le MJ a terminé la séance.'),
            ),
          );
        }
        const styleOnglet =
            TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
        return DefaultTabController(
          length: s.estMj ? 4 : 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Séance ${s.numero} · ${c.nom}',
                overflow: TextOverflow.ellipsis,
              ),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: styleOnglet,
                unselectedLabelStyle: styleOnglet,
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                tabs: [
                  const Tab(
                    key: Key('seance-tableau'),
                    height: 76,
                    icon: Icon(Icons.dashboard_outlined, size: 28),
                    text: 'Tableau de bord',
                  ),
                  if (s.estMj)
                    const Tab(
                      key: Key('seance-creatures'),
                      height: 76,
                      icon: Icon(Icons.pets_outlined, size: 28),
                      text: 'Créatures',
                    ),
                  const Tab(
                    key: Key('seance-regles'),
                    height: 76,
                    icon: Icon(Icons.menu_book_outlined, size: 28),
                    text: 'Règles système',
                  ),
                  const Tab(
                    key: Key('seance-parametres'),
                    height: 76,
                    icon: Icon(Icons.tune, size: 28),
                    text: 'Paramètres',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _TableauDeBord(
                  seance: s,
                  contexte: widget.contexte,
                  aleatoire: widget.aleatoire,
                ),
                if (s.estMj) OngletCreatures(seance: s),
                ReglesScreen(
                  referentiel: widget.contexte.referentiel,
                  avecBarre: false,
                ),
                _OngletParametres(seance: s, contexte: widget.contexte),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _erreur(BuildContext context, String? erreur) {
  if (erreur == null || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erreur)));
}

/// Attend une action et affiche son erreur éventuelle.
Future<void> _suivre(BuildContext context, Future<String?> action) async {
  final erreur = await action;
  if (context.mounted) _erreur(context, erreur);
}

/// Mode de jeu et tours : au-dessus des trois portions.
class _BarreTours extends StatelessWidget {
  const _BarreTours({required this.seance});

  final SeanceController seance;

  @override
  Widget build(BuildContext context) {
    final s = seance;
    final e = s.etat;
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  e.enCombat ? Icons.sports_martial_arts : Icons.explore,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  e.mode.libelle,
                  key: const Key('mode-jeu'),
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            if (e.enCombat)
              Text(
                'Manche ${e.manche} · '
                '${s.monTour ? 'À toi de jouer' : 'Tour : ${s.nomActif}'}',
                key: const Key('tour-actuel'),
                style: s.monTour
                    ? theme.textTheme.titleSmall
                        ?.copyWith(color: theme.colorScheme.primary)
                    : theme.textTheme.bodyMedium,
              ),
            if (e.enCombat)
              FilledButton.icon(
                key: const Key('passer-tour'),
                onPressed: s.peutPasser
                    ? () => _suivre(context, s.passerTour())
                    : null,
                icon: const Icon(Icons.skip_next),
                label: const Text('Passer son tour'),
              ),
            if (e.enCombat && s.estMj)
              OutlinedButton.icon(
                key: const Key('tour-precedent'),
                onPressed: e.index == 0 && e.manche == 1
                    ? null
                    : () => _suivre(context, s.tourPrecedent()),
                icon: const Icon(Icons.skip_previous),
                label: const Text('Tour précédent'),
              ),
            if (s.estMj)
              OutlinedButton.icon(
                key: const Key('basculer-mode'),
                onPressed: () => _suivre(context, s.basculerMode()),
                icon: Icon(
                  e.enCombat ? Icons.explore : Icons.sports_martial_arts,
                ),
                label: Text(
                  e.enCombat ? 'Passer en exploration' : 'Passer en combat',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Les trois portions, côte à côte ou en trois vues sur téléphone.
class _TableauDeBord extends StatefulWidget {
  const _TableauDeBord({
    required this.seance,
    required this.contexte,
    this.aleatoire,
  });

  final SeanceController seance;
  final ContexteCampagnes contexte;
  final Random? aleatoire;

  @override
  State<_TableauDeBord> createState() => _TableauDeBordState();
}

class _TableauDeBordState extends State<_TableauDeBord>
    with SingleTickerProviderStateMixin {
  late final TabController _vues;

  @override
  void initState() {
    super.initState();
    _vues = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _vues.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.seance;
    return LayoutBuilder(
      builder: (context, contraintes) {
        final large = contraintes.maxWidth >= SeanceScreen.largeurTroisPortions;
        final detail = DetailCarte(seance: s, contexte: widget.contexte);
        final des = PanneauDes(seance: s, aleatoire: widget.aleatoire);
        return Column(
          children: [
            _BarreTours(seance: s),
            const Divider(height: 1),
            Expanded(
              child: large
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 280,
                          child: ListeCartes(seance: s),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(child: detail),
                        const VerticalDivider(width: 1),
                        SizedBox(width: 340, child: des),
                      ],
                    )
                  : Column(
                      children: [
                        TabBar(
                          controller: _vues,
                          tabs: const [
                            Tab(key: Key('vue-cartes'), text: 'Cartes'),
                            Tab(key: Key('vue-detail'), text: 'Détail'),
                            Tab(key: Key('vue-des'), text: 'Dés'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _vues,
                            children: [
                              ListeCartes(
                                seance: s,
                                onChoisie: () => _vues.animateTo(1),
                              ),
                              detail,
                              des,
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// État de la séance ; terminer (MJ) ou quitter (PJ).
class _OngletParametres extends StatelessWidget {
  const _OngletParametres({required this.seance, required this.contexte});

  final SeanceController seance;
  final ContexteCampagnes contexte;

  static String _heure(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final s = seance;
    final c = s.campagne;
    if (c == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return LargeurLimitee(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(c.nom, style: styleAmbiance(theme.textTheme.headlineSmall)),
          const SizedBox(height: 8),
          Text(
            'Séance ${s.numero} en cours depuis ${_heure(c.seance!.debut)}.',
            key: const Key('etat-seance'),
          ),
          Text('Mode : ${s.etat.mode.libelle.toLowerCase()}.'),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: s.estMj
                ? FilledButton.icon(
                    key: const Key('terminer-seance'),
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final erreur = await contexte.campagnes
                          .agir((x) => x.terminerSeance(c));
                      if (erreur == null) {
                        navigator.pop();
                      } else if (context.mounted) {
                        _erreur(context, erreur);
                      }
                    },
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Terminer la séance'),
                  )
                : OutlinedButton.icon(
                    key: const Key('quitter-seance'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.logout),
                    label: const Text('Quitter la séance'),
                  ),
          ),
        ],
      ),
    );
  }
}
