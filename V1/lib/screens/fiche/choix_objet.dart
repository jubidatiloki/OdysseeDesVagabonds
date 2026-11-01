import 'package:flutter/material.dart';

import '../../models/equipement.dart';
import '../../models/objet.dart';
import '../../regles/inventaire.dart';
import '../../widgets/consultation.dart';
import '../equipements_screen.dart'
    show iconeCategorieEquipement, iconeEquipement;
import 'formulaire_objet.dart' show FormulaireObjet;

/// Ajout d'un objet à l'inventaire : choix dans le catalogue des équipements
/// (le formulaire s'ouvre pré-rempli, modifiable) ou objet personnalisé
/// (formulaire vide). Renvoie l'objet créé ou `null` si annulé.
class ChoixObjet extends StatefulWidget {
  const ChoixObjet({super.key, required this.equipements});

  final List<Equipement> equipements;

  /// Sans catalogue, ouvre directement le formulaire vide.
  static Future<Objet?> ouvrir(
    BuildContext context,
    List<Equipement> equipements,
  ) {
    if (equipements.isEmpty) return FormulaireObjet.ouvrir(context);
    return Navigator.of(context).push<Objet>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ChoixObjet(equipements: equipements),
      ),
    );
  }

  @override
  State<ChoixObjet> createState() => _ChoixObjetState();
}

class _ChoixObjetState extends State<ChoixObjet> {
  String _recherche = '';

  /// `null` : toutes les catégories.
  CategorieEquipement? _categorie;

  Future<void> _creer({Objet? modele}) async {
    final objet = await FormulaireObjet.ouvrir(context, modele: modele);
    if (objet != null && mounted) Navigator.of(context).pop(objet);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tous = widget.equipements;
    final presentes = {for (final e in tous) e.categorie};
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
      appBar: AppBar(title: const Text('Ajouter un objet')),
      body: LargeurLimitee(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.tonalIcon(
                      key: const Key('objet-personnalise'),
                      onPressed: _creer,
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Créer un objet personnalisé'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ou choisir dans les équipements',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
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
                          key: const Key('choix-categorie-toutes'),
                          label: const Text('Tout'),
                          selected: _categorie == null,
                          onSelected: (_) => setState(() => _categorie = null),
                        ),
                        for (final c in CategorieEquipement.values)
                          if (presentes.contains(c))
                            ChoiceChip(
                              key: Key('choix-categorie-${c.code}'),
                              avatar: iconeCategorieEquipement(c),
                              label: Text(c.libelle),
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
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: TexteAVenir(
                      'Aucun équipement ne correspond à la recherche.',
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
                  itemBuilder: (context, i) {
                    final e = liste[i];
                    final apercu = ObjetDuCatalogue.depuis(e);
                    final details = [
                      apercu.categorie.libelle,
                      if (apercu.resume.isNotEmpty) apercu.resume,
                    ];
                    return Card(
                      key: Key('catalogue-${e.id}'),
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: iconeEquipement(e,
                            couleur: theme.colorScheme.primary),
                        title: Text(
                          e.nom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          details.join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () => _creer(modele: apercu),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
