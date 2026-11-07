import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/affliction.dart';
import '../regles/index_competences.dart';
import '../widgets/liste_detail.dart';
import 'afflictions_glossaire_screen.dart';
import 'aptitudes_glossaire_screen.dart';
import 'bestiaire_screen.dart';
import 'competences_glossaire_screen.dart';
import 'classes_screen.dart';
import 'equipements_screen.dart';
import 'races_screen.dart';

/// Les onglets du Glossaire, dans l'ordre.
enum OngletGlossaire {
  classes('Classes', Icons.shield_outlined),
  races('Races', Icons.diversity_3_outlined),
  competences('Compétences', Icons.menu_book_outlined),
  aptitudes('Connaissances & Aptitudes', Icons.school_outlined),
  equipements('Équipements', Icons.backpack_outlined),
  bestiaire('Bestiaire', Icons.pets_outlined),
  afflictions('Afflictions & effets', Icons.healing_outlined);

  const OngletGlossaire(this.libelle, this.icone);

  final String libelle;
  final IconData icone;

  /// Nombre d'entrées (pastille sur l'onglet).
  int nombre(Referentiel r) => switch (this) {
        classes => r.classes.length,
        races => r.races.length,
        competences => IndexCompetences.construire(r).length,
        aptitudes => AptitudesGlossaireScreen.entrees(r).length,
        equipements => r.equipements.length,
        bestiaire => r.creatures.length,
        afflictions => kAfflictions.length + kEffetsDegats.length,
      };
}

/// Glossaire (charte, décision 30) : classes, races, compétences (sorts
/// mineurs compris), connaissances & aptitudes, équipements et bestiaire
/// réunis sous un seul titre, un onglet chacun (icône, nom,
/// nombre d'entrées). On passe de l'un à l'autre en touchant l'onglet ou
/// en glissant ; l'onglet ouvert est retenu quand on revient au Glossaire.
class GlossaireScreen extends StatefulWidget {
  const GlossaireScreen({
    super.key,
    required this.referentiel,
    this.menu,
    this.onglet = OngletGlossaire.classes,
    this.onOnglet,
    this.dansSeance = false,
  });

  /// Au centre de la séance : pas de barre de titre, détail sur place.
  final bool dansSeance;

  final Referentiel referentiel;

  /// Menu latéral (fourni par l'écran racine).
  final Widget? menu;

  /// Onglet ouvert au départ, et rappel quand il change (retenu par
  /// l'écran racine).
  final OngletGlossaire onglet;
  final ValueChanged<OngletGlossaire>? onOnglet;

  @override
  State<GlossaireScreen> createState() => _GlossaireScreenState();
}

class _GlossaireScreenState extends State<GlossaireScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _onglets = TabController(
    length: OngletGlossaire.values.length,
    vsync: this,
    initialIndex: widget.onglet.index,
  )..addListener(_changement);

  void _changement() {
    if (_onglets.indexIsChanging) return;
    widget.onOnglet?.call(OngletGlossaire.values[_onglets.index]);
    setState(() {});
  }

  @override
  void dispose() {
    _onglets
      ..removeListener(_changement)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ref = widget.referentiel;
    final courant = OngletGlossaire.values[_onglets.index];
    final onglets = TabBar(
      controller: _onglets,
      // Grand écran : onglets groupés au centre, au-dessus du contenu
      // (lui aussi centré) ; téléphone : 6 onglets qui défilent.
      isScrollable: true,
      tabAlignment:
          !widget.dansSeance && MediaQuery.sizeOf(context).width >= 900
              ? TabAlignment.center
              : TabAlignment.start,
      labelPadding:
          !widget.dansSeance && MediaQuery.sizeOf(context).width >= 900
              ? const EdgeInsets.symmetric(horizontal: 28)
              : const EdgeInsets.symmetric(horizontal: 14),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      tabs: [
        for (final o in OngletGlossaire.values)
          Tab(
            key: Key('onglet-glossaire-${o.name}'),
            height: 60,
            icon: Badge(
              label: Text('${o.nombre(ref)}'),
              backgroundColor: theme.colorScheme.secondaryContainer,
              textColor: theme.colorScheme.onSecondaryContainer,
              offset: const Offset(14, -6),
              child: Icon(o.icone),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(o.libelle),
            ),
          ),
      ],
    );
    // Texte sélectionnable, donc copiable, dans tous les onglets.
    final contenu = SelectionArea(
      child: TabBarView(
        controller: _onglets,
        children: [
          ClassesScreen(referentiel: ref),
          RacesScreen(referentiel: ref),
          CompetencesGlossaireScreen(referentiel: ref),
          AptitudesGlossaireScreen(referentiel: ref),
          EquipementsScreen(referentiel: ref),
          BestiaireScreen(referentiel: ref),
          const AfflictionsGlossaireScreen(),
        ],
      ),
    );
    if (widget.dansSeance) {
      return DetailSurPlace(
        child: Column(children: [onglets, Expanded(child: contenu)]),
      );
    }
    return Scaffold(
      drawer: widget.menu,
      appBar: AppBar(
        // « Glossaire · Races » : on sait toujours où l'on est.
        title: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Glossaire'),
              TextSpan(
                text: ' · ${courant.libelle}',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          key: const Key('titre-glossaire'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: onglets,
      ),
      body: contenu,
    );
  }
}
