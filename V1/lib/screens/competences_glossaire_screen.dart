import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/type_sort.dart';
import '../regles/index_competences.dart';
import '../widgets/consultation.dart';
import '../widgets/voie_detail.dart';

/// Icône d'une catégorie de filtre.
IconData iconeCategorieCompetence(CategorieCompetence c) => switch (c) {
      CategorieCompetence.sort => Icons.auto_awesome_outlined,
      CategorieCompetence.sortMineur => Icons.flare,
      CategorieCompetence.competence => Icons.fitness_center,
      CategorieCompetence.soutien => Icons.pets_outlined,
      CategorieCompetence.soin => Icons.favorite_outline,
      CategorieCompetence.degats => Icons.bolt,
    };

/// Onglet « Compétences » du Glossaire : toutes les compétences des voies
/// de classe, des voies raciales et les sorts de rang 0, regroupées par
/// voie ; filtres (classes, races ; sorts, compétences, soutien, soin,
/// dégâts) et recherche.
class CompetencesGlossaireScreen extends StatefulWidget {
  const CompetencesGlossaireScreen({super.key, required this.referentiel});

  final Referentiel referentiel;

  @override
  State<CompetencesGlossaireScreen> createState() =>
      _CompetencesGlossaireScreenState();
}

class _CompetencesGlossaireScreenState
    extends State<CompetencesGlossaireScreen> {
  late final List<EntreeCompetence> _index =
      IndexCompetences.construire(widget.referentiel);
  String _recherche = '';
  final Set<OrigineCompetence> _origines = {};
  final Set<CategorieCompetence> _categories = {};
  final Set<TypeSort> _typesSort = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final liste = IndexCompetences.filtrer(
      _index,
      origines: _origines,
      categories: _categories,
      typesSort: _typesSort,
      recherche: _recherche,
    );
    // Lignes : en-tête de voie puis ses compétences.
    final lignes = <Widget>[];
    String? groupe;
    final nbVoies = {for (final e in liste) e.titreGroupe}.length;
    for (final e in liste) {
      if (e.titreGroupe != groupe) {
        groupe = e.titreGroupe;
        lignes.add(_EnTeteVoie(
          key: Key('groupe-${e.voie.id}'),
          titre: e.titreGroupe,
          origine: e.origine,
          rang0: e.competence.rang == 0,
        ));
      }
      lignes.add(Padding(
        padding: const EdgeInsets.only(left: 4),
        child: LigneCompetence(competence: e.competence, mention: e.mention),
      ));
    }

    final controles = <Widget>[
      ChampRecherche(
        indice: 'Rechercher (nom, effet, voie…)',
        onChanged: (t) => setState(() => _recherche = t),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final o in OrigineCompetence.values)
            FilterChip(
              key: Key('filtre-origine-${o.name}'),
              avatar: Icon(
                o == OrigineCompetence.classe
                    ? Icons.shield_outlined
                    : Icons.diversity_3_outlined,
                size: 18,
              ),
              label: Text(o.libelle),
              selected: _origines.contains(o),
              onSelected: (oui) =>
                  setState(() => oui ? _origines.add(o) : _origines.remove(o)),
            ),
          // Séparation entre origines et catégories.
          Container(width: 1, height: 24, color: scheme.outlineVariant),
          for (final c in CategorieCompetence.values)
            FilterChip(
              key: Key('filtre-categorie-${c.name}'),
              avatar: Icon(iconeCategorieCompetence(c), size: 18),
              label: Text(c.libelle),
              selected: _categories.contains(c),
              onSelected: (oui) => setState(
                  () => oui ? _categories.add(c) : _categories.remove(c)),
            ),
        ],
      ),
      const SizedBox(height: 8),
      // Types de sort (cumulés avec les autres filtres).
      Wrap(
        key: const Key('filtres-types-sort'),
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Type de sort :',
            style: theme.textTheme.labelLarge
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          for (final t in TypeSort.values)
            FilterChip(
              key: Key('filtre-type-sort-${t.code}'),
              avatar:
                  Icon(t.icone, size: 18, color: t.couleur(theme.brightness)),
              label: Text(t.libelle),
              tooltip: t.definition,
              selected: _typesSort.contains(t),
              onSelected: (oui) => setState(
                  () => oui ? _typesSort.add(t) : _typesSort.remove(t)),
            ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: Text(
              '${liste.length} compétence${liste.length > 1 ? 's' : ''} · '
              '$nbVoies voie${nbVoies > 1 ? 's' : ''}',
              key: const Key('compte-competences'),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          if (_origines.isNotEmpty ||
              _categories.isNotEmpty ||
              _typesSort.isNotEmpty)
            TextButton.icon(
              key: const Key('effacer-filtres'),
              onPressed: () => setState(() {
                _origines.clear();
                _categories.clear();
                _typesSort.clear();
              }),
              icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
              label: const Text('Effacer les filtres'),
            ),
        ],
      ),
      if (liste.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 24),
          child: TexteAVenir('Aucune compétence ne correspond.'),
        ),
    ];

    return LargeurLimitee(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: controles.length + lignes.length,
        itemBuilder: (context, i) =>
            i < controles.length ? controles[i] : lignes[i - controles.length],
      ),
    );
  }
}

/// En-tête d'un groupe : « Barbare · Voie de la brute », icône d'origine.
class _EnTeteVoie extends StatelessWidget {
  const _EnTeteVoie({
    super.key,
    required this.titre,
    required this.origine,
    required this.rang0,
  });

  final String titre;
  final OrigineCompetence origine;
  final bool rang0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 4),
      child: Container(
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Icon(
              rang0
                  ? Icons.auto_awesome_outlined
                  : origine == OrigineCompetence.classe
                      ? Icons.shield_outlined
                      : Icons.diversity_3_outlined,
              size: 18,
              color: scheme.tertiary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titre,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              rang0
                  ? 'Sorts mineurs'
                  : origine == OrigineCompetence.classe
                      ? 'Classe'
                      : 'Race',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
