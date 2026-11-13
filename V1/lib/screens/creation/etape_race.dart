import 'package:flutter/material.dart';

import '../../models/race.dart';
import '../../models/voie.dart';
import '../../widgets/maitrises_restrictions.dart';
import '../../widgets/carte_choix.dart';
import '../../widgets/carte_selection.dart';
import '../../widgets/profil_classe.dart';
import '../../widgets/voie_detail.dart';

class EtapeRace extends StatelessWidget {
  const EtapeRace({
    super.key,
    required this.races,
    required this.race,
    required this.origineId,
    required this.optionPassifId,
    required this.onRace,
    required this.onOrigine,
    required this.onOptionPassif,
    this.choix = const {},
    this.onChoix,
  });

  final List<Race> races;
  final Race? race;
  final String? origineId;
  final String? optionPassifId;
  final ValueChanged<Race> onRace;
  final ValueChanged<String> onOrigine;
  final ValueChanged<String> onOptionPassif;

  /// Choix déjà faits (élément du souffle draconien…) et leur saisie.
  final Map<String, String> choix;
  final void Function(String cle, String option)? onChoix;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: races.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Text(
            'Choisis une race',
            style: Theme.of(context).textTheme.titleLarge,
          );
        }
        final r = races[i - 1];
        final choisie = r.id == race?.id;
        return CarteSelection(
          titre: r.nom,
          sousTitre: 'Dé de vie d${r.deVie} · Dé de mana d${r.deMana} · '
              "Dé d'endurance d${r.deEndurance}",
          selectionne: choisie,
          onTap: () => onRace(r),
          contenu: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Orientation et dés (curseurs) ; les modificateurs sont sur la
              // ligne « Caractéristiques », en couleur.
              InfosRace(r, modificateurs: false),
              const SizedBox(height: 6),
              if (r.aDesOrigines)
                const LigneDetail(
                  libelle: 'Caractéristiques',
                  texte: 'selon l\'origine',
                )
              else
                LigneModificateurs(r.modificateurs),
              for (final passif in r.passifs)
                LigneDetail(libelle: passif.nom, texte: _texte(passif)),
              if (choisie && r.aDesOrigines)
                _Choix(
                  titre: 'Origine',
                  options: [
                    for (final o in r.origines) (id: o.id, nom: o.nom),
                  ],
                  selection: origineId,
                  onChoix: onOrigine,
                  details: _detailOrigine(r.origine(origineId)),
                ),
              if (choisie && r.aUnChoixDePassif)
                _Choix(
                  titre: 'Héritage (définitif)',
                  options: [
                    for (final o in r.optionsPassif) (id: o.id, nom: o.nom),
                  ],
                  selection: optionPassifId,
                  onChoix: onOptionPassif,
                  details: _detailPassif(r.optionPassif(optionPassifId)),
                ),
              // Choix lié à l'héritage (élément du souffle draconien).
              if (choisie && r.optionPassif(optionPassifId)?.choix != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CarteChoix(
                    nom: r.optionPassif(optionPassifId)!.nom,
                    choix: r.optionPassif(optionPassifId)!.choix!,
                    valeur: choix[r.optionPassif(optionPassifId)!.choix!.cle],
                    onChoisir: (o) => onChoix?.call(
                      r.optionPassif(optionPassifId)!.choix!.cle,
                      o,
                    ),
                  ),
                ),
              if (choisie) ...[
                const SizedBox(height: 8),
                MaitrisesRestrictions(race: r),
              ],
              if (r.voieRaciale != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    key: Key('voie-raciale-${r.id}'),
                    onPressed: () => afficherVoies(
                      context,
                      titre: 'Voie raciale — ${r.nom}',
                      introduction: 'Les rangs de la voie raciale sont offerts '
                          'gratuitement aux niveaux impairs (1, 3, 5, 7, 9). '
                          'Le rang 1 est acquis dès la création.',
                      voies: [r.voieRaciale!],
                      afficherCouts: false,
                    ),
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: const Text('Voir la voie raciale'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Origine choisie, dans le style des races sans origine : modificateurs
  /// en couleur, passif et bonus en lignes « Libellé : texte ».
  List<Widget> _detailOrigine(OrigineRace? o) => [
        if (o != null) ...[
          LigneModificateurs(o.modificateurs),
          if (o.passif != null)
            LigneDetail(libelle: o.passif!.nom, texte: _texte(o.passif!)),
          if (o.bonus != null) LigneDetail(libelle: 'Bonus', texte: o.bonus!),
        ],
      ];

  /// Description de l'héritage, `{cle}` remplacés par les choix faits.
  List<Widget> _detailPassif(OptionPassif? o) => [
        if (o != null)
          LigneDetail(
            libelle: o.nom,
            texte: remplacerChoix(
              o.description,
              choix,
              {if (o.choix != null) o.choix!.cle: o.choix!},
            ),
          ),
      ];

  /// Description du passif, ou ses effets détaillés s'il n'en a pas.
  static String _texte(Passif p) => p.description.isNotEmpty
      ? p.description
      : p.effets.map((e) => e.libelle).join(' ; ');
}

class _Choix extends StatelessWidget {
  const _Choix({
    required this.titre,
    required this.options,
    required this.selection,
    required this.onChoix,
    this.details = const [],
  });

  final String titre;
  final List<({String id, String nom})> options;
  final String? selection;
  final ValueChanged<String> onChoix;

  /// Détail de l'option choisie (lignes « Libellé : texte »).
  final List<Widget> details;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selection == null ? '$titre — à choisir' : titre,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in options)
                ChoiceChip(
                  label: Text(o.nom),
                  selected: o.id == selection,
                  onSelected: (_) => onChoix(o.id),
                ),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...details,
          ],
        ],
      ),
    );
  }
}
