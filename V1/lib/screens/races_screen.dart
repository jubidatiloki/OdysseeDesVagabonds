import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/carac.dart';
import '../models/race.dart';
import '../models/voie.dart';
import '../regles/fiche_calculee.dart';
import '../theme.dart';
import '../widgets/carte_selection.dart';
import '../widgets/consultation.dart';
import '../widgets/liste_detail.dart';
import '../widgets/profil_classe.dart';
import '../widgets/voie_detail.dart';

/// Page « Races » : liste des races ; sur grand écran, le détail de la race
/// choisie s'affiche à droite de la liste (voir `ListeDetail`).
class RacesScreen extends StatelessWidget {
  const RacesScreen({super.key, required this.referentiel});

  final Referentiel referentiel;
  @override
  Widget build(BuildContext context) {
    final races = referentiel.races;
    return Scaffold(
      // Onglet du Glossaire : titre, menu et onglets sont dans GlossaireScreen.
      body: races.isEmpty
          ? const Center(child: TexteAVenir('Aucune race disponible.'))
          : ListeDetail<Race>(
              elements: races,
              nom: (r) => r.nom,
              sousTitre: (r) => 'DV d${r.deVie} · DM d${r.deMana} · '
                  '${r.aDesOrigines ? 'selon l\'origine' : formaterModificateurs(r.modificateurs)}',
              contenu: (r) => InfosRace(r),
              couleurAvatar: (r) =>
                  couleurProfil(r.profil, Theme.of(context).brightness),
              detail: (r) => RaceDetail(race: r),
            ),
    );
  }
}

/// Détail d'une race : description, dés, statistiques, passif, origines,
/// maîtrises, restrictions et voie raciale.
class RaceDetail extends StatelessWidget {
  const RaceDetail({super.key, required this.race});

  final Race race;

  @override
  Widget build(BuildContext context) {
    final r = race;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BlocConsultation(
          titre: 'Description',
          icone: Icons.description_outlined,
          children: [
            if (r.description.isNotEmpty)
              Text(r.description)
            else
              const TexteAVenir('Description à venir.'),
          ],
        ),
        BlocConsultation(
          titre: 'Modificateurs',
          icone: Icons.tune,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: EtiquetteProfil(
                r.profil,
                libelle: libelleProfilRace(r.profil),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                CurseurDe.race(
                  icone: Icons.favorite,
                  couleur: couleurVie(Theme.of(context).brightness),
                  faces: r.deVie,
                  nomDe: 'Dé de vie',
                ),
                CurseurDe.race(
                  icone: Icons.water_drop,
                  couleur: couleurMana(Theme.of(context).brightness),
                  faces: r.deMana,
                  nomDe: 'Dé de mana',
                ),
                CurseurDe.race(
                  icone: kIconeEndurance,
                  couleur: couleurEndurance(Theme.of(context).brightness),
                  faces: r.deEndurance,
                  nomDe: "Dé d'endurance",
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (r.aDesOrigines)
              const LigneDetail(
                libelle: 'Statistiques',
                texte: 'selon l\'origine (voir ci-dessous)',
              )
            else
              _LigneStats(r.modificateurs),
            if (r.pointsCompetenceBonus > 0)
              LigneDetail(
                libelle: 'Points de compétence',
                texte: '+${r.pointsCompetenceBonus} au départ',
              ),
            const SizedBox(height: 6),
            const TexteAVenir(
              'Les dés de la race sont ensuite modifiés par la classe.',
            ),
          ],
        ),
        if (r.passif != null || r.aUnChoixDePassif)
          BlocConsultation(
            titre: 'Passif racial',
            icone: Icons.auto_awesome_outlined,
            children: [
              if (r.passif != null)
                LigneTrait(
                  nom: r.passif!.nom,
                  description: r.passif!.description,
                  effets: r.passif!.effets,
                  type: r.passif!.type,
                ),
              if (r.aUnChoixDePassif) ...[
                const SizedBox(height: 4),
                const Text('Au choix, à la création :'),
                for (final o in r.optionsPassif)
                  LigneDetail(libelle: o.nom, texte: sansChoix(o.description)),
              ],
            ],
          ),
        if (r.aDesOrigines)
          BlocConsultation(
            titre: 'Origines',
            icone: Icons.family_restroom_outlined,
            children: [
              // Une carte par origine, sur deux colonnes si la place le
              // permet.
              LayoutBuilder(
                builder: (context, c) {
                  final colonnes = c.maxWidth >= 560 ? 2 : 1;
                  final largeur = (c.maxWidth - 8 * (colonnes - 1)) / colonnes;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final o in r.origines)
                        SizedBox(width: largeur, child: _CarteOrigine(o)),
                    ],
                  );
                },
              ),
            ],
          ),
        BlocConsultation(
          titre: 'Maîtrises et restrictions',
          icone: Icons.gavel_outlined,
          children: [
            LigneDetail(
              libelle: 'Maîtrises',
              texte: r.maitrises.isEmpty ? 'aucune précisée' : r.maitrises,
            ),
            LigneDetail(
              libelle: 'Restrictions',
              texte: r.restrictions.isEmpty ? 'aucune' : r.restrictions,
            ),
          ],
        ),
        if (r.voieRaciale != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(
              'Compétences (voie raciale)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: VoieDetail(voie: r.voieRaciale!, raciale: true),
          ),
        ],
      ],
    );
  }
}

/// Détail en page entière (téléphone, ou ouverture directe).
class RaceDetailScreen extends StatelessWidget {
  const RaceDetailScreen({super.key, required this.race});

  final Race race;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          race.nom,
          style: const TextStyle(fontFamily: kPoliceAmbiance),
        ),
      ),
      body: LargeurLimitee(child: RaceDetail(race: race)),
    );
  }
}

/// « Statistiques : +3 FOR −2 INT » avec les modificateurs en couleur.
class _LigneStats extends StatelessWidget {
  const _LigneStats(this.modificateurs);

  final Map<Carac, int> modificateurs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques : ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(child: ModificateursCouleur(modificateurs)),
        ],
      ),
    );
  }
}

/// Carte d'une origine : nom, modificateurs en pastilles colorées, passif et
/// bonus avec icône.
class _CarteOrigine extends StatelessWidget {
  const _CarteOrigine(this.origine);

  final OrigineRace origine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final o = origine;
    final mods = [
      for (final c in Carac.values)
        if ((o.modificateurs[c] ?? 0) != 0) (c, o.modificateurs[c]!),
    ]..sort((a, b) => b.$2.compareTo(a.$2)); // bonus d'abord
    return Container(
      key: Key('origine-${o.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            o.nom,
            style: styleAmbiance(theme.textTheme.titleSmall)
                .copyWith(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (c, v) in mods) _PastilleMod(carac: c, valeur: v),
            ],
          ),
          if (o.passif != null) ...[
            const SizedBox(height: 6),
            LigneTrait(
              nom: o.passif!.nom,
              description: o.passif!.description,
              effets: o.passif!.effets,
              type: o.passif!.type,
            ),
          ],
          if (o.bonus != null && o.bonus!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _LigneIcone(
              icone: Icons.star_outline,
              titre: 'Bonus',
              texte: o.bonus!,
            ),
          ],
        ],
      ),
    );
  }
}

/// « +2 FOR » dans une pastille teintée (vert si bonus, rouge si malus).
class _PastilleMod extends StatelessWidget {
  const _PastilleMod({required this.carac, required this.valeur});

  final Carac carac;
  final int valeur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couleur = couleurModificateur(valeur, theme.brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: couleur.withValues(alpha: 0.6)),
      ),
      child: Text(
        '${formaterModificateur(valeur)} ${carac.abrev}',
        style: theme.textTheme.labelLarge
            ?.copyWith(color: couleur, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Icône + titre en gras + texte secondaire (passif, bonus d'une origine).
class _LigneIcone extends StatelessWidget {
  const _LigneIcone({
    required this.icone,
    required this.titre,
    required this.texte,
  });

  final IconData icone;
  final String titre;
  final String texte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 16, color: scheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                texte,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
