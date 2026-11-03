import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/carac.dart';
import '../models/creature.dart';
import '../regles/fiche_calculee.dart';
import '../theme.dart';
import '../widgets/carte_selection.dart';
import '../widgets/consultation.dart';
import '../widgets/infos_creature.dart';
import '../widgets/liste_detail.dart';
import '../widgets/voie_detail.dart';

/// Page « Bestiaire » : toutes les créatures, avec recherche et filtres
/// (famille, taille).
class BestiaireScreen extends StatefulWidget {
  const BestiaireScreen({
    super.key,
    required this.referentiel,
    this.action,
    this.dansSeance = false,
  });

  final Referentiel referentiel;

  /// Bouton au-dessus du détail d'une créature (séance : l'ajouter).
  final Widget Function(Creature)? action;

  /// Au centre de la séance : le détail remplace la liste, sur place.
  final bool dansSeance;

  @override
  State<BestiaireScreen> createState() => _BestiaireScreenState();
}

class _BestiaireScreenState extends State<BestiaireScreen> {
  String _recherche = '';
  String? _famille;
  TailleCreature? _taille;

  @override
  Widget build(BuildContext context) {
    final toutes = widget.referentiel.creatures;
    final familles = {for (final c in toutes) c.famille}.toList()..sort();
    final tailles = TailleCreature.values
        .where((t) => toutes.any((c) => c.taille == t))
        .toList();
    final liste = [
      for (final c in toutes)
        if ((_famille == null || c.famille == _famille) &&
            (_taille == null || c.taille == _taille) &&
            correspond(c.texteRecherche, _recherche))
          c,
    ]..sort((a, b) => a.nom.compareTo(b.nom));

    return Scaffold(
      // Onglet du Glossaire : titre, menu et onglets sont dans GlossaireScreen.
      body: ListeDetail<Creature>(
        elements: liste,
        nom: (c) => c.nom,
        sousTitre: (c) => '${c.famille} · ${c.archetype} · ${c.taille.libelle}',
        contenu: (c) => InfosCreature(c),
        couleurAvatar: (c) =>
            styleFamille(c.famille, Theme.of(context).brightness).couleur,
        largeurMin: widget.dansSeance ? double.infinity : 900,
        detailEnPlace: widget.dansSeance,
        detail: (c) => widget.action == null
            ? CreatureDetail(creature: c)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: widget.action!(c),
                  ),
                  Expanded(child: CreatureDetail(creature: c)),
                ],
              ),
        entete: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChampRecherche(
              indice: 'Rechercher une créature',
              onChanged: (t) => setState(() => _recherche = t),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  key: const Key('famille-toutes'),
                  label: const Text('Toutes les familles'),
                  selected: _famille == null,
                  onSelected: (_) => setState(() => _famille = null),
                ),
                for (final f in familles)
                  ChoiceChip(
                    key: Key('famille-$f'),
                    avatar: Icon(
                      styleFamille(f, Theme.of(context).brightness).icone,
                      size: 18,
                      color:
                          styleFamille(f, Theme.of(context).brightness).couleur,
                    ),
                    label: Text(f),
                    selected: _famille == f,
                    onSelected: (_) => setState(() => _famille = f),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in tailles)
                  FilterChip(
                    key: Key('taille-${t.code}'),
                    label: Text(t.libelle),
                    selected: _taille == t,
                    onSelected: (oui) =>
                        setState(() => _taille = oui ? t : null),
                  ),
              ],
            ),
          ],
        ),
        vide: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: TexteAVenir(
              toutes.isEmpty
                  ? 'Le bestiaire est vide pour l\'instant.'
                  : 'Aucune créature ne correspond.',
            ),
          ),
        ),
      ),
    );
  }
}

/// Fiche d'une créature : description, comportement, statistiques, voies.
class CreatureDetail extends StatelessWidget {
  const CreatureDetail({super.key, required this.creature});

  final Creature creature;

  @override
  Widget build(BuildContext context) {
    final c = creature;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        InfosCreature(c, avecMesure: true),
        const SizedBox(height: 12),
        BlocConsultation(
          titre: 'Description physique',
          icone: Icons.visibility_outlined,
          children: [
            if (c.description.isNotEmpty)
              Text(c.description)
            else
              const TexteAVenir('Description à venir.'),
          ],
        ),
        BlocConsultation(
          titre: 'Comportement',
          icone: Icons.psychology_outlined,
          children: [
            if (c.comportement.isNotEmpty)
              Text(c.comportement)
            else
              const TexteAVenir('Comportement à venir.'),
          ],
        ),
        BlocConsultation(
          titre: 'Statistiques',
          icone: Icons.bar_chart,
          children: [
            if (!c.aDesStatistiques)
              const TexteAVenir('Statistiques à définir.')
            else ...[
              if (c.pv != null || c.ca != null || c.initiative != null)
                Text(
                  [
                    if (c.ca != null) 'CA ${c.ca}',
                    if (c.pv != null) 'PV ${c.pv}',
                    if (c.initiative != null) 'Initiative ${c.initiative}',
                  ].join(' · '),
                  key: const Key('creature-defense'),
                  style: theme.textTheme.titleSmall,
                ),
              // Modificateurs : toutes les caractéristiques (sauf CHAN), +0
              // quand elles ne sont pas précisées.
              if (c.mods.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final k in Carac.values)
                      if (k != Carac.chan)
                        _CaseMod(carac: k, mod: c.mods[k] ?? 0),
                  ],
                ),
              ],
              if (c.caracs.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final k in Carac.values)
                      if (c.caracs[k] != null)
                        _CaseCarac(carac: k, valeur: c.caracs[k]!),
                  ],
                ),
              ],
              for (final a in c.attaques)
                LigneDetail(
                  libelle: a.portee.isEmpty ? a.nom : '${a.nom} (${a.portee})',
                  texte: [
                    if (a.toucher.isNotEmpty) 'toucher ${a.toucher}',
                    if (a.degats.isNotEmpty) 'dégâts ${a.degats}',
                    if (a.note.isNotEmpty) a.note,
                  ].join(' · '),
                ),
            ],
          ],
        ),
        if (c.note.isNotEmpty)
          BlocConsultation(
            titre: 'À savoir',
            icone: Icons.lightbulb_outline,
            children: [Text(c.note)],
          ),
        if (c.voies.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(
              'Voies de compétence',
              style: theme.textTheme.titleLarge,
            ),
          ),
          for (final v in c.voies)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: v.competences.isEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.nom,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          const TexteAVenir('Compétences à définir.'),
                        ],
                      )
                    : VoieDetail(voie: v, afficherCouts: false),
              ),
            ),
        ],
      ],
    );
  }
}

/// Fiche d'une créature en page entière (téléphone, ouverture directe).
class CreatureDetailScreen extends StatelessWidget {
  const CreatureDetailScreen({super.key, required this.creature});

  final Creature creature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          creature.nom,
          style: const TextStyle(fontFamily: kPoliceAmbiance),
        ),
      ),
      body: LargeurLimitee(child: CreatureDetail(creature: creature)),
    );
  }
}

/// Modificateur d'une caractéristique de créature (« FOR +3 »).
class _CaseMod extends StatelessWidget {
  const _CaseMod({required this.carac, required this.mod});

  final Carac carac;
  final int mod;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      key: Key('creature-mod-${carac.code}'),
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(carac.abrev,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          FittedBox(
            child: Text(
              formaterModificateur(mod),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: mod == 0
                    ? scheme.onSurfaceVariant
                    : couleurModificateur(mod, theme.brightness),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseCarac extends StatelessWidget {
  const _CaseCarac({required this.carac, required this.valeur});

  final Carac carac;
  final int valeur;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(carac.abrev,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          FittedBox(
            child:
                Text('$valeur (${formaterModificateur(modificateur(valeur))})'),
          ),
        ],
      ),
    );
  }
}
