import 'package:flutter/material.dart';

import '../../models/campagne.dart';
import '../../models/personnage.dart';
import '../../regles/fiche_calculee.dart';
import '../../theme.dart';
import '../../widgets/consultation.dart';
import '../../widgets/resume_fiche.dart';
import 'campagnes_screen.dart';

/// Ouvre la fiche (lecture seule) du personnage d'un membre.
void ouvrirFichePartagee(
  BuildContext context,
  ContexteCampagnes contexte,
  MembreCampagne membre,
) =>
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FichePartageeScreen(contexte: contexte, membre: membre),
    ));

/// Fiche d'un autre joueur, partagée pour la campagne : consultation seule.
class FichePartageeScreen extends StatelessWidget {
  const FichePartageeScreen({
    super.key,
    required this.contexte,
    required this.membre,
  });

  final ContexteCampagnes contexte;
  final MembreCampagne membre;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(membre.personnageNom)),
        body: ContenuFichePartagee(contexte: contexte, membre: membre),
      );
}

/// Contenu de la fiche partagée (page à part, ou centre de la séance).
class ContenuFichePartagee extends StatefulWidget {
  const ContenuFichePartagee({
    super.key,
    required this.contexte,
    required this.membre,
  });

  final ContexteCampagnes contexte;
  final MembreCampagne membre;

  @override
  State<ContenuFichePartagee> createState() => _ContenuFichePartageeState();
}

class _ContenuFichePartageeState extends State<ContenuFichePartagee> {
  late final Future<Personnage?> _fiche = _lire();

  Future<Personnage?> _lire() async {
    Personnage? p;
    await widget.contexte.campagnes.agir((s) async {
      p = await s.lireFiche(widget.membre.personnageId);
    });
    return p;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Personnage?>(
      future: _fiche,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = snap.data;
        final ref = widget.contexte.referentiel;
        final race = p == null ? null : ref.race(p.raceId);
        final classe = p == null ? null : ref.classe(p.classeId);
        if (p == null || race == null || classe == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: TexteAVenir('Fiche pas encore partagée : elle le sera '
                  'dès que le joueur ouvrira l\'application.'),
            ),
          );
        }
        return ApercuFiche(
          fiche: FicheCalculee(personnage: p, race: race, classe: classe),
          joueur: widget.membre.nom,
        );
      },
    );
  }
}

/// Fiche en consultation : identité, PV, PM, PE, statistiques.
class ApercuFiche extends StatelessWidget {
  const ApercuFiche({
    super.key,
    required this.fiche,
    this.joueur,
    this.action,
  });

  final FicheCalculee fiche;

  /// Nom du joueur, s'il ne s'agit pas du sien.
  final String? joueur;

  /// Bouton sous l'identité (« Ouvrir ma fiche »).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final f = fiche;
    final p = f.personnage;
    final theme = Theme.of(context);
    return LargeurLimitee(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              AvatarPersonnage(nom: p.nom),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nom,
                      style: styleAmbiance(theme.textTheme.titleLarge),
                    ),
                    Text([
                      f.race.nom,
                      f.classe.nom,
                      'niveau ${p.niveau}',
                      if (joueur != null) 'joueur : $joueur',
                    ].join(' · ')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _Valeur(Icons.favorite, 'PV ${f.pvActuels}/${f.pvMax}',
                  OdvCouleurs.pv),
              if (f.classe.aDuMana)
                _Valeur(Icons.water_drop, 'PM ${f.pmActuels}/${f.pmMax}',
                    OdvCouleurs.pm),
              if (f.classe.aDeLEndurance)
                _Valeur(kIconeEndurance, 'PE ${f.peActuels}/${f.peMax}',
                    OdvCouleurs.pe),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: action),
          ],
          const SizedBox(height: 16),
          ResumeFiche(fiche: f, avecPvPm: true),
        ],
      ),
    );
  }
}

class _Valeur extends StatelessWidget {
  const _Valeur(this.icone, this.texte, this.couleur);

  final IconData icone;
  final String texte;
  final Color couleur;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 18, color: couleur),
          const SizedBox(width: 4),
          Text(texte, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      );
}
