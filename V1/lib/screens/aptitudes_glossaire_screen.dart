import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/aptitude.dart';
import '../models/carac.dart';
import '../widgets/consultation.dart';

/// Icône d'une famille d'aptitudes (Glossaire, création).
IconData iconeFamilleAptitude(FamilleAptitude f) => switch (f) {
      FamilleAptitude.savoir => Icons.menu_book_outlined,
      FamilleAptitude.savoirFaire => Icons.handyman_outlined,
      FamilleAptitude.autre => Icons.workspace_premium_outlined,
    };

/// Onglet « Connaissances & Aptitudes » du Glossaire : savoirs, savoir-faire
/// et maîtrises (1 point chacun), regroupés par famille, avec recherche et
/// filtres (famille, basique / complexe). Les sorts de rang 0 sont dans
/// l'onglet Compétences.
class AptitudesGlossaireScreen extends StatefulWidget {
  const AptitudesGlossaireScreen({super.key, required this.referentiel});

  final Referentiel referentiel;

  /// Entrées affichées dans cet onglet (sans les sorts de rang 0).
  static List<Aptitude> entrees(Referentiel r) => [
        for (final a in r.aptitudes)
          if (!a.estSort) a,
      ];

  @override
  State<AptitudesGlossaireScreen> createState() =>
      _AptitudesGlossaireScreenState();
}

class _AptitudesGlossaireScreenState extends State<AptitudesGlossaireScreen> {
  String _recherche = '';

  /// `null` : toutes les familles.
  FamilleAptitude? _famille;

  /// `null` : basiques et complexes.
  bool? _complexe;

  /// Caractéristique du test (« FOR »…) ; `null` : toutes.
  String? _carac;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final toutes = AptitudesGlossaireScreen.entrees(widget.referentiel);
    final liste = [
      for (final a in toutes)
        if ((_famille == null || a.famille == _famille) &&
            (_complexe == null ||
                (a.famille != FamilleAptitude.autre &&
                    a.complexe == _complexe)) &&
            (_carac == null || a.carac == _carac) &&
            correspond(
              '${a.nom} ${a.description} ${a.resume} ${a.famille.libelle}',
              _recherche,
            ))
          a,
    ];

    Widget pastille(String cle, String texte, bool choisie, VoidCallback onTap,
            {Widget? avatar}) =>
        ChoiceChip(
          key: Key(cle),
          avatar: avatar,
          label: Text(texte),
          selected: choisie,
          onSelected: (_) => onTap(),
        );

    return Scaffold(
      // Onglet du Glossaire : titre, menu et onglets sont dans GlossaireScreen.
      body: LargeurLimitee(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ChampRecherche(
                      indice: 'Rechercher une connaissance ou une aptitude',
                      onChanged: (t) => setState(() => _recherche = t),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        pastille(
                          'famille-toutes',
                          'Tout (${toutes.length})',
                          _famille == null,
                          () => setState(() => _famille = null),
                        ),
                        for (final f in FamilleAptitude.values)
                          pastille(
                            'famille-${f.name}',
                            '${f.libelle} '
                                '(${toutes.where((a) => a.famille == f).length})',
                            _famille == f,
                            () => setState(() => _famille = f),
                            avatar: Icon(iconeFamilleAptitude(f), size: 18),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final (cle, texte, valeur) in [
                          ('basique', 'Basiques', false),
                          ('complexe', 'Complexes (−5 sans)', true),
                        ])
                          FilterChip(
                            key: Key('filtre-$cle'),
                            label: Text(texte),
                            selected: _complexe == valeur,
                            onSelected: (oui) =>
                                setState(() => _complexe = oui ? valeur : null),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Caractéristique du test : celles utilisées, dans
                    // l'ordre des caractéristiques.
                    Wrap(
                      key: const Key('filtres-carac'),
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Test :',
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        for (final c in Carac.values)
                          if (toutes.any((a) => a.carac == c.code))
                            ChoiceChip(
                              key: Key('filtre-carac-${c.code}'),
                              visualDensity: VisualDensity.compact,
                              tooltip: c.nom,
                              label: Text(
                                '${c.abrev} '
                                '(${toutes.where((a) => a.carac == c.code).length})',
                              ),
                              selected: _carac == c.code,
                              onSelected: (oui) =>
                                  setState(() => _carac = oui ? c.code : null),
                            ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1 point de compétence chacune. Maîtrisée : +5 aux tests '
                      'liés ; complexe sans la maîtrise : −5.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            if (liste.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: TexteAVenir(
                      'Aucune connaissance ni aptitude ne correspond.',
                    ),
                  ),
                ),
              )
            else
              for (final f in FamilleAptitude.values)
                if (liste.any((a) => a.famille == f)) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        key: Key('groupe-aptitudes-${f.name}'),
                        children: [
                          Icon(iconeFamilleAptitude(f),
                              size: 20, color: scheme.primary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              f.libelle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              f.sousTitre,
                              style: TextStyle(color: scheme.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.separated(
                      itemCount: liste.where((a) => a.famille == f).length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) => _CarteAptitude(
                        liste.where((a) => a.famille == f).elementAt(i),
                      ),
                    ),
                  ),
                ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _CarteAptitude extends StatelessWidget {
  const _CarteAptitude(this.aptitude);

  final Aptitude aptitude;

  @override
  Widget build(BuildContext context) {
    final a = aptitude;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      key: Key('carte-aptitude-${a.id}'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              a.nom,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (a.famille != FamilleAptitude.autre)
                  Etiquette(a.complexe ? 'Complexe' : 'Basique'),
                if (a.carac.isNotEmpty) Etiquette('Test : ${a.carac}'),
                if (a.question != null) Etiquette(a.question!),
                if (a.multiple) const Etiquette('Plusieurs fois'),
                if (a.inneeSiIntAuMoins != null)
                  Etiquette('Innée si INT ≥ ${a.inneeSiIntAuMoins}'),
                if (a.race.isNotEmpty) const Etiquette('Innée pour ce peuple'),
              ],
            ),
            if (a.regle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                a.regle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: a.complexe ? scheme.tertiary : scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (a.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(a.description),
            ],
          ],
        ),
      ),
    );
  }
}
