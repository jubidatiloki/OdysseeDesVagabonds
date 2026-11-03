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

  Future<Personnage?> _lire() async {
    Personnage? p;
    await contexte.campagnes.agir((s) async {
      p = await s.lireFiche(membre.personnageId);
    });
    return p;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(membre.personnageNom)),
      body: FutureBuilder<Personnage?>(
        future: _lire(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = snap.data;
          final ref = contexte.referentiel;
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
          final f = FicheCalculee(personnage: p, race: race, classe: classe);
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
                          Text('${race.nom} · ${classe.nom} · niveau '
                              '${p.niveau} · joueur : ${membre.nom}'),
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
                    if (classe.aDuMana)
                      _Valeur(Icons.water_drop, 'PM ${f.pmActuels}/${f.pmMax}',
                          OdvCouleurs.pm),
                    if (classe.aDeLEndurance)
                      _Valeur(kIconeEndurance, 'PE ${f.peActuels}/${f.peMax}',
                          OdvCouleurs.pe),
                  ],
                ),
                const SizedBox(height: 16),
                ResumeFiche(fiche: f, avecPvPm: true),
              ],
            ),
          );
        },
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
