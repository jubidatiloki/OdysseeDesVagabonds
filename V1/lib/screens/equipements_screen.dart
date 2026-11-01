import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/equipement.dart';
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

  @override
  Widget build(BuildContext context) {
    final tous = widget.referentiel.equipements;
    final liste = [
      for (final e in tous)
        if ((_categorie == null || e.categorie == _categorie) &&
            correspond(e.texteRecherche, _recherche))
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
                          onSelected: (_) => setState(() => _categorie = null),
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
                            onSelected: (_) => setState(() => _categorie = c),
                          ),
                      ],
                    ),
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
