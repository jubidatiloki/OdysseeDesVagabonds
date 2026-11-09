import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/equipement.dart';
import '../regles/inventaire.dart';
import '../regles/maitrises.dart';
import '../widgets/cadre_classe.dart';
import '../widgets/carte_selection.dart';
import '../widgets/consultation.dart';
import '../widgets/icone_guitare.dart';

IconData iconeCategorie(CategorieEquipement c) => switch (c) {
      CategorieEquipement.arme => Icons.gavel,
      CategorieEquipement.armure => Icons.shield_outlined,
      CategorieEquipement.objetMagique => Icons.auto_fix_high,
      CategorieEquipement.accessoire => Icons.diamond_outlined,
      CategorieEquipement.instrument => Icons.music_note_outlined,
      CategorieEquipement.consommable => Icons.local_drink_outlined,
      CategorieEquipement.autre => Icons.inventory_2_outlined,
    };

/// Motif dessiné d'un équipement (charte, décision 31), d'après sa catégorie
/// et ses étiquettes : outil → pioche ; arme à distance → arc, de corps à
/// corps → épée ; armure : bouclier, casque ou plastron ; consommable →
/// potion. `null` : icône de la catégorie.
MotifClasse? motifEquipement(CategorieEquipement c, List<String> etiquettes) {
  final tags = {for (final t in etiquettes) t.trim().toLowerCase()};
  if (tags.contains('outil')) return MotifClasse.pioche;
  return switch (c) {
    // Armes à poudre (étiquette « poudre ») : pistolet ; à distance : arc.
    CategorieEquipement.arme => tags.contains('poudre')
        ? MotifClasse.pistolet
        : tags.contains('distance')
            ? MotifClasse.arc
            : MotifClasse.epee,
    CategorieEquipement.armure => tags.contains('bouclier')
        ? MotifClasse.bouclier
        : tags.contains('casque')
            ? MotifClasse.casque
            : MotifClasse.plastron,
    CategorieEquipement.consommable => MotifClasse.potion,
    _ => null,
  };
}

/// Icône d'un équipement : son motif dessiné, sinon l'icône de sa catégorie.
/// Instruments de musique (étiquette « instrument ») : guitare dessinée.
Widget iconeEquipement(Equipement e, {double taille = 24, Color? couleur}) {
  if (e.etiquettes.any((t) => t.toLowerCase() == 'instrument')) {
    return IconeGuitare(taille: taille, couleur: couleur);
  }
  final m = motifEquipement(e.categorie, e.etiquettes);
  return m == null
      ? Icon(iconeCategorie(e.categorie), size: taille, color: couleur)
      : IconeMotif(m, taille: taille, couleur: couleur);
}

/// Icône d'une catégorie (pastilles de filtre) : épée, plastron, potion…
Widget iconeCategorieEquipement(
  CategorieEquipement c, {
  double taille = 18,
  Color? couleur,
}) {
  if (c == CategorieEquipement.instrument) {
    return IconeGuitare(taille: taille, couleur: couleur);
  }
  final m = motifEquipement(c, const []);
  return m == null
      ? Icon(iconeCategorie(c), size: taille, color: couleur)
      : IconeMotif(m, taille: taille, couleur: couleur);
}

/// Famille d'un équipement : celle des armes (« Arme civile », « Arme
/// commune de mêlée »…) ou des armures (« Armure légère »…) ; `null` sinon.
String? familleEquipement(Equipement e) {
  if (e.groupeArme.isNotEmpty) {
    return switch (e.groupeArme) {
      'civile' => 'Arme civile',
      'commune-melee' => 'Arme commune de mêlée',
      'commune-distance' => 'Arme commune à distance',
      'poudre' => 'Arme à poudre',
      'siege' => 'Arme de siège',
      final g => 'Arme : $g',
    };
  }
  final n = niveauArmure(ObjetDuCatalogue.depuis(e));
  return n == null ? null : 'Armure ${familleArmure(n).toLowerCase()}';
}

/// Étiquette ramenée à une forme commune (« Légère », « legère » →
/// « legere » ; « deux main » → « deux mains »).
String _cleEtiquette(String t) {
  final n = ObjetDuCatalogue.normaliser(t);
  return n == 'deux main' ? 'deux mains' : n;
}

/// Étiquettes d'un équipement pour le filtre : sa famille et ses
/// étiquettes, ramenées à une forme commune.
Set<String> _clesEquipement(Equipement e) => {
      if (familleEquipement(e) case final f?) _cleEtiquette(f),
      for (final t in e.etiquettes) _cleEtiquette(t),
    };

/// Page « Équipements » : index de tous les équipements, avec recherche et
/// filtre par catégorie.
class EquipementsScreen extends StatefulWidget {
  const EquipementsScreen({super.key, required this.referentiel});

  final Referentiel referentiel;
  @override
  State<EquipementsScreen> createState() => _EquipementsScreenState();
}

class _EquipementsScreenState extends State<EquipementsScreen> {
  String _recherche = '';

  /// `null` : toutes les catégories.
  CategorieEquipement? _categorie;

  /// Étiquettes choisies dans la catégorie (« lourde », « Armure légère »…) :
  /// un équipement doit les avoir toutes.
  final Set<String> _etiquettes = {};

  @override
  Widget build(BuildContext context) {
    final tous = widget.referentiel.equipements;
    final dansCategorie = [
      for (final e in tous)
        if (_categorie == null || e.categorie == _categorie) e,
    ];
    // Étiquettes proposées : familles d'abord, puis les autres, par ordre
    // alphabétique ; libellé de la première rencontrée.
    final libelles = <String, String>{};
    final familles = <String>{};
    for (final e in dansCategorie) {
      if (familleEquipement(e) case final f?) {
        libelles.putIfAbsent(_cleEtiquette(f), () => f);
        familles.add(_cleEtiquette(f));
      }
      for (final t in e.etiquettes) {
        libelles.putIfAbsent(_cleEtiquette(t), () => t.toLowerCase());
      }
    }
    final cles = libelles.keys.toList()
      ..sort((a, b) {
        final fa = familles.contains(a) ? 0 : 1;
        final fb = familles.contains(b) ? 0 : 1;
        return fa != fb ? fa - fb : a.compareTo(b);
      });
    final liste = [
      for (final e in dansCategorie)
        if (correspond(e.texteRecherche, _recherche) &&
            _clesEquipement(e).containsAll(_etiquettes))
          e,
    ]..sort((a, b) {
        final c = a.categorie.index.compareTo(b.categorie.index);
        return c != 0 ? c : a.nom.compareTo(b.nom);
      });

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
                      indice: 'Rechercher un équipement',
                      onChanged: (t) => setState(() => _recherche = t),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          key: const Key('categorie-toutes'),
                          label: Text('Tout (${tous.length})'),
                          selected: _categorie == null,
                          onSelected: (_) => setState(() {
                            _categorie = null;
                            _etiquettes.clear();
                          }),
                        ),
                        for (final c in CategorieEquipement.values)
                          ChoiceChip(
                            key: Key('categorie-${c.code}'),
                            avatar: iconeCategorieEquipement(c),
                            label: Text(
                              '${c.libelle} '
                              '(${tous.where((e) => e.categorie == c).length})',
                            ),
                            selected: _categorie == c,
                            onSelected: (_) => setState(() {
                              _categorie = c;
                              _etiquettes.clear();
                            }),
                          ),
                      ],
                    ),
                    // Catégorie choisie : filtre plus fin par étiquette
                    // (« lourde », « Arme à poudre »…).
                    if (_categorie != null && cles.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        key: const Key('filtres-etiquettes'),
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final k in cles)
                            FilterChip(
                              key: Key('etiquette-$k'),
                              label: Text(libelles[k]!),
                              selected: _etiquettes.contains(k),
                              onSelected: (v) => setState(() {
                                v ? _etiquettes.add(k) : _etiquettes.remove(k);
                              }),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (liste.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: TexteAVenir(
                      _recherche.trim().isNotEmpty
                          ? 'Aucun équipement ne correspond à la recherche.'
                          : 'Aucun équipement dans cette catégorie pour '
                              'l\'instant : les règles ne les détaillent pas '
                              'encore.',
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverList.separated(
                  itemCount: liste.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, i) => _CarteEquipement(liste[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CarteEquipement extends StatelessWidget {
  const _CarteEquipement(this.equipement);

  final Equipement equipement;

  @override
  Widget build(BuildContext context) {
    final e = equipement;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                iconeEquipement(e, couleur: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.nom,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Etiquette(e.categorie.libelle),
                if (familleEquipement(e) case final f?)
                  Etiquette(f, icone: Icons.category_outlined),
                for (final t in e.etiquettes) Etiquette(t),
              ],
            ),
            if (e.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(e.description),
            ],
            for (final p in e.proprietes.entries)
              LigneDetail(libelle: p.key, texte: p.value),
          ],
        ),
      ),
    );
  }
}
