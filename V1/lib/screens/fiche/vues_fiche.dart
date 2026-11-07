import 'package:flutter/material.dart';

import '../../data/referentiel.dart';
import '../../models/objet.dart';
import '../../models/personnage.dart';
import '../../regles/fiche_calculee.dart';
import '../../regles/maitrises.dart';
import '../../state/personnages_controller.dart';
import 'formulaire_identite.dart';
import 'onglet_competences.dart';
import 'onglet_fiche.dart';
import 'onglet_historique.dart';
import 'onglet_inventaire.dart';
import 'onglet_notes.dart';

/// Les cinq vues d'une fiche modifiable : Fiche, Compétences, Inventaire,
/// Notes, Historique (page du personnage, centre de la séance).
/// [controller] `null` : pas de dépense de points (fiche d'un joueur ouverte
/// par le MJ). [verrous] : permissions de la campagne, hors séance.
List<Widget> vuesFiche(
  BuildContext context, {
  required FicheCalculee fiche,
  required Referentiel referentiel,
  required Future<void> Function() onModifie,
  PersonnagesController? controller,
  void Function(Objet)? onEnvoyerObjet,
  ({bool inventaire, bool competences}) verrous = (
    inventaire: false,
    competences: false,
  ),
}) {
  final p = fiche.personnage;
  return [
    // La fiche utilise toute la largeur (deux colonnes sur grand écran, trois
    // sur très grand écran) ; les autres onglets restent centrés.
    _Largeur(
      max: 1700,
      child: OngletFiche(
        fiche: fiche,
        onModifie: onModifie,
        equipements: referentiel.equipements,
        onModifierIdentite: () async {
          if (await FormulaireIdentite.ouvrir(context, p)) {
            await onModifie();
          }
        },
      ),
    ),
    _Largeur(
      child: OngletCompetences(
        fiche: fiche,
        referentiel: referentiel,
        controller: controller,
        verrouille: verrous.competences,
      ),
    ),
    _Largeur(
      child: OngletInventaire(
        personnage: p,
        verrouille: verrous.inventaire,
        onModifie: onModifie,
        onEnvoyer: onEnvoyerObjet,
        refusRestriction: fiche.refusRestriction,
        alerteObjet: (o) => fiche.armeMaitrisee(o)
            ? null
            : 'Non maîtrisée : −${kMalusArmeNonMaitrisee.abs()} au toucher',
        equipements: referentiel.equipements,
        deuxArmesDeuxMains: fiche.deuxArmesDeuxMains,
        fabrications: fiche.fabrications,
        usagesRestants: {
          for (final u in fiche.usages) u.cle: u.restants,
        },
        bidouillage: fiche.bidouillage,
      ),
    ),
    _Largeur(child: OngletNotes(personnage: p, onModifie: onModifie)),
    _Largeur(child: OngletHistorique(personnage: p)),
  ];
}

/// Onglets des cinq vues, avec leur barre (centre de la séance).
class FicheComplete extends StatelessWidget {
  const FicheComplete({
    super.key,
    required this.fiche,
    required this.referentiel,
    required this.onModifie,
    this.controller,
    this.onEnvoyerObjet,
  });

  final FicheCalculee fiche;
  final Referentiel referentiel;
  final Future<void> Function() onModifie;
  final PersonnagesController? controller;

  /// En séance : envoyer un objet non équipé à un autre PJ.
  final void Function(Objet)? onEnvoyerObjet;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(key: Key('vue-fiche'), text: 'Fiche'),
              Tab(key: Key('vue-competences'), text: 'Compétences'),
              Tab(key: Key('vue-inventaire'), text: 'Inventaire'),
              Tab(text: 'Notes'),
              Tab(text: 'Historique'),
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: vuesFiche(
                context,
                fiche: fiche,
                referentiel: referentiel,
                onModifie: onModifie,
                controller: controller,
                onEnvoyerObjet: onEnvoyerObjet,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inventaire en consultation seule.
class InventaireLecture extends StatelessWidget {
  const InventaireLecture({super.key, required this.personnage, this.message});

  final Personnage personnage;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final p = personnage;
    return ListView(
      key: const Key('inventaire-lecture'),
      padding: const EdgeInsets.all(16),
      children: [
        if (message != null) ...[Text(message!), const SizedBox(height: 12)],
        Text(p.bourse.texte),
        const SizedBox(height: 8),
        if (p.inventaire.isEmpty) const Text('Inventaire vide.'),
        for (final o in p.inventaire)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              o.equipe ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
            ),
            title: Text(
              '${o.quantite > 1 ? '${o.quantite} × ' : ''}${o.nom}',
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: o.resume.isEmpty ? null : Text(o.resume),
          ),
      ],
    );
  }
}

/// Centre un onglet et limite sa largeur sur grand écran.
class _Largeur extends StatelessWidget {
  const _Largeur({required this.child, this.max = 760});

  final Widget child;
  final double max;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: max),
        child: child,
      ),
    );
  }
}
