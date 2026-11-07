import 'dart:math';

import 'package:flutter/material.dart';

import '../../state/preferences_controller.dart';
import '../../state/seance_controller.dart';
import '../../theme.dart';
import '../../widgets/consultation.dart';
import '../glossaire_screen.dart';
import '../regles_screen.dart';
import 'campagnes_screen.dart';
import 'creation_campagne_screen.dart';
import 'seance_cartes.dart';
import 'seance_creatures.dart';
import 'seance_des.dart';
import 'seance_recaps.dart';

/// Interface de jeu d'une séance. Les cartes (à gauche) et les dés (à droite)
/// restent visibles ; la navigation du haut change le centre : Tableau de
/// bord, Créatures (MJ seulement), Règles système, Paramètres. Sur téléphone,
/// trois vues : Cartes, Détail, Dés.
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

class _SeanceScreenState extends State<SeanceScreen>
    with SingleTickerProviderStateMixin {
  late final SeanceController _seance;
  late final TabController _vues;

  /// Taille des portions : préférences de l'appareil.
  late final PreferencesController _preferences =
      widget.contexte.preferences ?? PreferencesController();

  @override
  void initState() {
    super.initState();
    _vues = TabController(length: 3, vsync: this);
    _seance = SeanceController(
      campagnes: widget.contexte.campagnes,
      personnages: widget.contexte.personnages,
      referentiel: widget.contexte.referentiel,
      campagneId: widget.campagneId,
    );
  }

  @override
  void dispose() {
    _vues.dispose();
    _seance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_seance, _preferences]),
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
          length: s.estMj ? 6 : 4,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 76,
              // Combat : tout l'en-tête passe au rouge.
              backgroundColor: s.etat.enCombat
                  ? Color.alphaBlend(
                      OdvCouleurs.red.withValues(alpha: 0.35),
                      Theme.of(context).appBarTheme.backgroundColor ??
                          Theme.of(context).colorScheme.surface,
                    )
                  : null,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Séance ${s.numero} · ${c.nom}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _EnTeteMode(seance: s),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: MediaQuery.sizeOf(context).width < 700
                      ? IconButton(
                          key: Key(
                            s.estMj ? 'terminer-seance' : 'quitter-seance',
                          ),
                          tooltip: s.estMj
                              ? 'Clôturer la séance'
                              : 'Quitter la séance',
                          onPressed: s.estMj
                              ? () => _terminer(context)
                              : () => Navigator.of(context).pop(),
                          icon: Icon(
                            s.estMj ? Icons.stop_circle_outlined : Icons.logout,
                          ),
                        )
                      : s.estMj
                          ? FilledButton.icon(
                              key: const Key('terminer-seance'),
                              onPressed: () => _terminer(context),
                              icon: const Icon(Icons.stop_circle_outlined),
                              label: const Text('Clôturer la séance'),
                            )
                          : OutlinedButton.icon(
                              key: const Key('quitter-seance'),
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.logout),
                              label: const Text('Quitter la séance'),
                            ),
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: styleOnglet,
                unselectedLabelStyle: styleOnglet,
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                // Téléphone : le contenu de l'onglet est dans la vue Détail.
                onTap: (_) => _vues.animateTo(1),
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
                  if (s.estMj)
                    const Tab(
                      key: Key('seance-glossaire'),
                      height: 76,
                      icon: Icon(Icons.auto_stories_outlined, size: 28),
                      text: 'Glossaire',
                    ),
                  const Tab(
                    key: Key('seance-recaps'),
                    height: 76,
                    icon: Icon(Icons.event_note_outlined, size: 28),
                    text: 'Séances précédentes',
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
            body: Builder(builder: _corps),
          ),
        );
      },
    );
  }

  /// MJ : clôture la séance, après confirmation.
  Future<void> _terminer(BuildContext context) async {
    final c = _seance.campagne;
    if (c == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clôturer la séance ${_seance.numero} ?'),
        content: const Text('La séance se termine pour tous les joueurs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuer'),
          ),
          FilledButton(
            key: const Key('confirmer-cloture'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clôturer'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final navigator = Navigator.of(context);
    final erreur =
        await widget.contexte.campagnes.agir((x) => x.terminerSeance(c));
    if (erreur == null) {
      navigator.pop();
    } else if (context.mounted) {
      _erreur(context, erreur);
    }
  }

  Widget _corps(BuildContext context) {
    final s = _seance;
    final onglets = DefaultTabController.of(context);
    // Une carte choisie ramène au tableau de bord, qui affiche son détail.
    void carteChoisie() {
      onglets.animateTo(0);
      _vues.animateTo(1);
    }

    final cartes = ListeCartes(seance: s, onChoisie: carteChoisie);
    final centre = TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        DetailCarte(seance: s, contexte: widget.contexte),
        if (s.estMj) OngletCreatures(seance: s),
        if (s.estMj)
          GlossaireScreen(
            referentiel: widget.contexte.referentiel,
            dansSeance: true,
          ),
        if (s.campagne != null)
          OngletRecaps(
            contexte: widget.contexte,
            campagne: s.campagne!,
            lecture: !s.estMj,
          ),
        ReglesScreen(
          referentiel: widget.contexte.referentiel,
          avecBarre: false,
        ),
        _OngletParametres(
          seance: s,
          contexte: widget.contexte,
          preferences: _preferences,
        ),
      ],
    );
    final des = PanneauDes(seance: s, aleatoire: widget.aleatoire);
    return LayoutBuilder(
      builder: (context, contraintes) {
        final large = contraintes.maxWidth >= SeanceScreen.largeurTroisPortions;
        final g = _preferences.portionGauche;
        final d = _preferences.portionDroite;
        int flex(double v) => (v * 1000).round();
        return DecoratedBox(
          key: Key('cadre-${s.etat.mode.name}'),
          position: DecorationPosition.foreground,
          // Liseré léger : rouge en combat, vert en exploration.
          decoration: BoxDecoration(
            border: Border.all(
              color: s.etat.enCombat
                  ? OdvCouleurs.red.withValues(alpha: 0.8)
                  : OdvCouleurs.green.withValues(alpha: 0.6),
              width: 3,
            ),
          ),
          child: Column(
            children: [
              if (s.estMj || s.etat.enCombat) ...[
                _BarreTours(seance: s),
                const Divider(height: 1),
              ],
              Expanded(
                child: large
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: flex(g), child: cartes),
                          const VerticalDivider(width: 1),
                          Expanded(flex: flex(1 - g - d), child: centre),
                          const VerticalDivider(width: 1),
                          Expanded(flex: flex(d), child: des),
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
                              physics: const NeverScrollableScrollPhysics(),
                              children: [cartes, centre, des],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
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

/// MJ : saisie du lieu de la scène.
class _DialogueLieu extends StatefulWidget {
  const _DialogueLieu({required this.lieu});

  final String lieu;

  @override
  State<_DialogueLieu> createState() => _DialogueLieuState();
}

class _DialogueLieuState extends State<_DialogueLieu> {
  late final _champ = TextEditingController(text: widget.lieu);

  @override
  void dispose() {
    _champ.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lieu de la scène'),
      content: TextField(
        key: const Key('champ-lieu'),
        controller: _champ,
        autofocus: true,
        maxLength: 60,
        textCapitalization: TextCapitalization.sentences,
        decoration:
            const InputDecoration(hintText: 'Ex. : Taverne du Sanglier'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('valider-lieu'),
          onPressed: () => Navigator.pop(context, _champ.text),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// En-tête : pastille du mode, bien visible, et lieu de la scène.
class _EnTeteMode extends StatelessWidget {
  const _EnTeteMode({required this.seance});

  final SeanceController seance;

  Future<void> _modifierLieu(BuildContext context) async {
    final lieu = await showDialog<String>(
      context: context,
      builder: (_) => _DialogueLieu(lieu: seance.etat.lieu),
    );
    if (lieu != null && context.mounted) {
      await _suivre(context, seance.changerLieu(lieu));
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = seance.etat;
    final theme = Theme.of(context);
    final couleur = e.enCombat ? OdvCouleurs.red : OdvCouleurs.darkGreen;
    final texteLieu = e.lieu.isEmpty ? 'Lieu à définir' : e.lieu;
    final lieu = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.place_outlined, size: 18),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            texteLieu,
            key: const Key('lieu-seance'),
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        if (seance.estMj) ...[
          const SizedBox(width: 4),
          const Icon(Icons.edit_outlined, size: 14),
        ],
      ],
    );
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: couleur,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  e.enCombat ? Icons.sports_martial_arts : Icons.explore,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    e.mode.libelle,
                    key: const Key('mode-jeu'),
                    overflow: TextOverflow.ellipsis,
                    style: styleAmbiance(theme.textTheme.titleSmall).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (seance.estMj || e.lieu.isNotEmpty) ...[
          const SizedBox(width: 10),
          Flexible(
            child: seance.estMj
                ? InkWell(
                    key: const Key('modifier-lieu'),
                    onTap: () => _modifierLieu(context),
                    child: lieu,
                  )
                : lieu,
          ),
        ],
      ],
    );
  }
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

/// Permissions (MJ) et graphismes.
class _OngletParametres extends StatefulWidget {
  const _OngletParametres({
    required this.seance,
    required this.contexte,
    required this.preferences,
  });

  final SeanceController seance;
  final ContexteCampagnes contexte;
  final PreferencesController preferences;

  @override
  State<_OngletParametres> createState() => _OngletParametresState();
}

class _OngletParametresState extends State<_OngletParametres> {
  static String _heure(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final s = widget.seance;
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
          const SizedBox(height: 16),
          if (s.estMj)
            BlocConsultation(
              titre: 'Permissions',
              icone: Icons.lock_open_outlined,
              children: [
                FormulairePermissions(
                  valeur: c.parametres,
                  onChange: (p) => _suivre(context, s.enregistrerParametres(p)),
                ),
              ],
            ),
          if (!s.estMj)
            BlocConsultation(
              titre: 'Paramètres de la campagne',
              icone: Icons.tune,
              children: [ResumeParametres(c.parametres)],
            ),
          BlocConsultation(
            titre: 'Graphismes',
            icone: Icons.view_column_outlined,
            children: [
              const Text(
                  'Largeur des menus, sur grand écran ; le corps central '
                  'prend le reste.'),
              _Portions(preferences: widget.preferences),
            ],
          ),
        ],
      ),
    );
  }
}

/// Largeur des menus : trois tailles chacun, le corps central prend le reste.
/// Rien ne bouge tant qu'on n'a pas choisi.
class _Portions extends StatelessWidget {
  const _Portions({required this.preferences});

  final PreferencesController preferences;

  static const _gauche = [0.18, 0.22, 0.30];
  static const _droite = [0.22, 0.26, 0.34];
  static const _libelles = ['Étroit', 'Normal', 'Large'];

  @override
  Widget build(BuildContext context) {
    final p = preferences;
    int proche(List<double> tailles, double v) {
      var meilleur = 0;
      for (var i = 1; i < tailles.length; i++) {
        if ((tailles[i] - v).abs() < (tailles[meilleur] - v).abs()) {
          meilleur = i;
        }
      }
      return meilleur;
    }

    Widget choix(
      String cle,
      String titre,
      List<double> tailles,
      double valeur,
      void Function(double) change,
    ) =>
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titre),
              const SizedBox(height: 4),
              SegmentedButton<int>(
                key: Key(cle),
                showSelectedIcon: false,
                segments: [
                  for (final (i, l) in _libelles.indexed)
                    ButtonSegment(value: i, label: Text(l)),
                ],
                selected: {proche(tailles, valeur)},
                onSelectionChanged: (s) => change(tailles[s.first]),
              ),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        choix('portion-gauche', 'Menu gauche', _gauche, p.portionGauche,
            (v) => p.changerPortions(v, p.portionDroite)),
        choix('portion-droite', 'Menu droite', _droite, p.portionDroite,
            (v) => p.changerPortions(p.portionGauche, v)),
      ],
    );
  }
}
