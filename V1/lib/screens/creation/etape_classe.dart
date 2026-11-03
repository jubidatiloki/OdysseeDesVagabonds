import 'package:flutter/material.dart';

import '../../models/classe.dart';
import '../../models/race.dart';
import '../../regles/fiche_calculee.dart';
import '../../widgets/carte_selection.dart';
import '../../widgets/profil_classe.dart';
import '../../widgets/voie_detail.dart';

class EtapeClasse extends StatelessWidget {
  const EtapeClasse({
    super.key,
    required this.classes,
    required this.race,
    required this.classe,
    required this.onClasse,
  });

  final List<Classe> classes;

  /// Race choisie à l'étape précédente : sert à afficher les dés finaux.
  final Race? race;
  final Classe? classe;
  final ValueChanged<Classe> onClasse;

  String _des(Classe c) {
    final r = race;
    if (r == null) {
      return [
        'Dé de vie ${c.modifDeVie.symbole}',
        if (c.aDuMana) 'Dé de mana ${c.modifDeMana.symbole}',
        if (c.aDeLEndurance) "Dé d'endurance ${c.modifDeEndurance.symbole}",
      ].join(' · ');
    }
    final dv = ajusterDe(r.deVie, c.modifDeVie);
    final dm = ajusterDe(r.deMana, c.modifDeMana);
    final de = ajusterDe(r.deEndurance, c.modifDeEndurance);
    return [
      'Dé de vie d$dv',
      if (c.aDuMana) 'Dé de mana d$dm',
      if (c.aDeLEndurance) "Dé d'endurance d$de",
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: classes.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choisis une classe',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (race != null) ...[
                const SizedBox(height: 4),
                Text('Dés calculés pour un ${race!.nom.toLowerCase()}.'),
              ],
            ],
          );
        }
        final c = classes[i - 1];
        final choisie = c.id == classe?.id;
        return CarteSelection(
          titre: c.nom,
          sousTitre: _des(c),
          selectionne: choisie,
          onTap: () => onClasse(c),
          contenu: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil et dés (curseurs à 3 crans) de la charte graphique.
              InfosClasse(c),
              const SizedBox(height: 6),
              if (c.voies.isNotEmpty)
                LigneDetail(
                  libelle: 'Voies',
                  texte: c.voies.map((v) => v.nomCourt).join(', '),
                ),
              if (c.maitrises.isNotEmpty)
                LigneDetail(libelle: 'Maîtrises', texte: c.maitrises),
              if (c.restrictionArmure.isNotEmpty)
                LigneDetail(libelle: 'Armure', texte: c.restrictionArmure),
              if (c.voies.isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    key: Key('voies-${c.id}'),
                    onPressed: () => afficherVoies(
                      context,
                      titre: 'Voies — ${c.nom}',
                      introduction: [
                        'Chaque voie compte 5 rangs à prendre dans l\'ordre. '
                            'Coût des rangs : 1, 1, 2, 2 et 3 points. '
                            'Un rang ne peut pas dépasser le niveau du '
                            'personnage : au niveau 1, seuls les rangs 1 '
                            'sont accessibles.',
                        if (c.note.isNotEmpty) c.note,
                      ].join('\n\n'),
                      voies: c.voies,
                    ),
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: const Text('Voir les voies'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
