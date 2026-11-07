import 'package:flutter/material.dart';

import '../models/carac.dart';
import '../regles/fiche_calculee.dart';
import '../theme.dart';
import 'icone_trefle.dart';

/// Texte des modificateurs raciaux : « FOR +3 · INT −2 ».
String texteModificateurs(Map<Carac, int> mods) {
  final parties = <String>[];
  for (final c in Carac.values) {
    final v = mods[c];
    if (v != null && v != 0) {
      parties.add('${c.abrev} ${formaterModificateur(v)}');
    }
  }
  return parties.isEmpty ? 'Aucun' : parties.join(' · ');
}

/// Statistiques d'un personnage, organisées comme la fiche papier :
/// - en tête : DV · DM · CHAN ;
/// - Combat : défensif (CA et les 5 RD), offensif (initiative en
///   grand, toucher, dégâts) ;
/// - Personnage : aptitudes à côté de leur statistique associée
///   (AdC · FOR, AdT · DEX, AdM · INT), puis CON · PER et SOC · MEN.
/// Les caractéristiques mettent le **modificateur** en avant (c'est lui que
/// les règles utilisent), la valeur est rappelée à part, dans un cadre.
/// Utilisé par la fiche et par le récapitulatif de création.
class ResumeFiche extends StatelessWidget {
  const ResumeFiche({super.key, required this.fiche, this.avecPvPm = false});

  final FicheCalculee fiche;

  /// Affiche aussi PV max et PM max (récapitulatif de création : la fiche,
  /// elle, les montre déjà dans ses jauges).
  final bool avecPvPm;

  static const _iconeCac = Icons.gavel;
  static const _iconeDistance = Icons.gps_fixed;
  static const _iconeMagie = Icons.auto_awesome;
  static const _explicationToucher =
      'Jet à lancer pour toucher, comparé à la CA de la cible.';

  @override
  Widget build(BuildContext context) {
    final f = fiche;
    Widget carac(Carac c) => _CaseCarac(
          key: Key('carac-${c.code}'),
          carac: c,
          valeur: f.carac(c),
          mod: f.mod(c),
          bonus: f.bonusEffets(c),
        );
    Widget trio(String prefixe, List<String> valeurs) => _Rangee([
          _CaseValeur(
            key: Key('stat-$prefixe-cac'),
            libelle: 'CaC',
            titre: 'Toucher au corps à corps',
            explication: _explicationToucher,
            icone: _iconeCac,
            valeur: valeurs[0],
          ),
          _CaseValeur(
            key: Key('stat-$prefixe-dist'),
            libelle: 'Distance',
            titre: 'Toucher à distance',
            explication: _explicationToucher,
            icone: _iconeDistance,
            valeur: valeurs[1],
          ),
          _CaseValeur(
            key: Key('stat-$prefixe-mag'),
            libelle: 'Magie',
            titre: 'Toucher avec les sorts',
            explication: _explicationToucher,
            icone: _iconeMagie,
            valeur: valeurs[2],
          ),
        ]);
    // Dégâts : dé de chaque arme équipée + bonus (une ligne par arme) ;
    // origine au survol ou au toucher.
    Widget degats() {
      Widget caseDegats(
          String cle, String libelle, IconData icone, DetailDegats d) {
        final entrees = d.entrees;
        return _CaseValeur(
          key: Key('stat-deg-$cle'),
          libelle: libelle,
          titre: 'Dégâts · $libelle',
          icone: icone,
          valeur: entrees.first.$1,
          detail: entrees.first.$2,
          suite: entrees.skip(1).toList(),
          infobulle: d.explication,
        );
      }

      return _Rangee([
        caseDegats('cac', 'CaC', _iconeCac, f.detailDegatsCac),
        caseDegats('dist', 'Distance', _iconeDistance, f.detailDegatsDistance),
        caseDegats('mag', 'Magie', _iconeMagie, f.detailDegatsMagie),
      ]);
    }

    // Résistances aux dégâts (RD) des races et compétences : les 5 types
    // toujours affichés (« — » à 0), puis les autres s'il y en a.
    const typesRd = ['physique', 'magique', 'feu', 'glace', 'foudre'];
    final autresRd = [
      for (final r in f.resistances)
        if (!typesRd.contains(r.type)) r.type,
    ];
    Widget rd(String type) {
      final r = f.resistances.where((r) => r.type == type).firstOrNull;
      return _CaseValeur(
        key: Key('stat-rd-$type'),
        libelle: 'RD $type',
        explication: 'Résistance aux dégâts de type $type.',
        icone: Icons.shield_moon_outlined,
        valeur: r == null ? '—' : formaterModificateur(r.total),
        detail: r?.sources.map((s) => s.nom).join(', '),
        infobulle: r == null
            ? null
            : [
                for (final s in r.sources)
                  '${formaterModificateur(s.valeur)} : ${s.nom}',
              ].join('\n'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (avecPvPm) ...[
          _Rangee(colonnes: 3, [
            _CaseValeur(
              libelle: 'PV max',
              explication: 'Quantité de coups et de blessures encaissables '
                  'avant de s\'évanouir ou de mourir.',
              valeur: '${f.pvMax}',
              detail: f.bonusPvCompetences != 0
                  ? 'dont ${formaterModificateur(f.bonusPvCompetences)} comp.'
                  : 'd${f.deVie} + CON',
            ),
            if (f.classe.aDuMana)
              _CaseValeur(
                libelle: 'PM max',
                explication: 'Quantité de magie utilisable. Régénération : '
                    'dé de mana par nuit de sommeil.',
                valeur: '${f.pmMax}',
                detail: 'd${f.deMana}',
              ),
            if (f.classe.aDeLEndurance)
              _CaseValeur(
                key: const Key('stat-pe-max'),
                libelle: 'PE max',
                explication: 'Effort physique disponible, dépensé par les '
                    'compétences. Régénération : dé d\'endurance par nuit de '
                    'sommeil.',
                valeur: '${f.peMax}',
                detail: 'd${f.deEndurance}',
              ),
          ]),
          const SizedBox(height: 8),
        ],
        // Hybride : dé de vie, de mana, d'endurance et CHAN sur 4 colonnes.
        _Rangee(colonnes: f.classe.aDuMana && f.classe.aDeLEndurance ? 4 : 3, [
          _CaseValeur(
            key: const Key('stat-dv'),
            libelle: 'Dé de vie',
            explication: 'Gain de points de vie par montée de niveau, et '
                'limite encaissable avant de mourir.',
            valeur: 'd${f.deVie}',
          ),
          if (f.classe.aDuMana)
            _CaseValeur(
              key: const Key('stat-dm'),
              libelle: 'Dé de mana',
              explication: 'Gain de points de mana par montée de niveau.',
              valeur: 'd${f.deMana}',
            ),
          if (f.classe.aDeLEndurance)
            _CaseValeur(
              key: const Key('stat-de'),
              libelle: "Dé d'endurance",
              explication: "Gain de points d'endurance par montée de niveau.",
              valeur: 'd${f.deEndurance}',
            ),
          carac(Carac.chan),
        ]),
        const SizedBox(height: 20),
        const _TitreSection('Combat', icone: Icons.sports_martial_arts),
        const _SousTitre('Défensif', icone: Icons.shield_outlined),
        // CA, puis les 5 résistances (refonte du 29/10/2026) ; l'esquive est
        // un jet (page dé), pas une valeur de la fiche.
        _Rangee([
          _CaseValeur(
            key: const Key('stat-ca'),
            libelle: 'CA',
            titre: "Classe d'armure",
            explication: 'Faculté à ne pas subir les attaques, grâce à son '
                'armure ou à son agilité.',
            icone: Icons.shield_outlined,
            valeur: '${f.classeArmure}',
            detail: [
              ...f.caContre,
              if (f.limiteDex != null)
                'DEX max ${formaterModificateur(f.limiteDex!)}',
            ].join(', '),
            infobulle: [
              'CA ${f.classeArmure} = 10'
                  ' ${formaterModificateur(f.bonusCAEquipement)} équipement'
                  ' ${formaterModificateur(f.dexDefense)} DEX'
                  '${f.limiteDex == null ? '' : ' (max ${formaterModificateur(f.limiteDex!)})'}'
                  ' ${formaterModificateur(f.bonusCACompetences)} compétences',
              for (final c in f.caContre) 'CA $c',
              'Attaques (CaC, distance, sorts) contre la CA ; le reste : '
                  "jet d'esquive (page dé).",
            ].join('\n'),
          ),
          rd('physique'),
          rd('magique'),
        ]),
        const SizedBox(height: 8),
        _Rangee([rd('feu'), rd('glace'), rd('foudre')]),
        if (autresRd.isNotEmpty) ...[
          const SizedBox(height: 8),
          _Rangee([for (final t in autresRd) rd(t)]),
        ],
        const SizedBox(height: 14),
        const _SousTitre('Offensif', icone: Icons.bolt),
        _BlocAvecGrandeCase(
          grande: _GrandeCase(
            key: const Key('stat-init'),
            libelle: 'Initiative',
            explication: 'Vitesse de réaction : la plus grande joue avant la '
                'plus petite. Valeur de DEX + bonus, sans jet.',
            icone: Icons.bolt,
            // Valeur de DEX + bonus : pas de jet (règle du 31/10/2026).
            valeur: '${f.initiative}',
          ),
          rangees: [
            (
              'Toucher',
              trio('tou', [
                formaterJet('1d20', f.toucherCac),
                formaterJet('1d20', f.toucherDistance),
                formaterJet('1d20', f.toucherMagie),
              ])
            ),
            ('Dégâts', degats()),
          ],
        ),
        const SizedBox(height: 14),
        // Déplacement par action de mouvement : 10 m + compétences.
        const _SousTitre('Mouvement', icone: Icons.directions_run),
        _Rangee([
          _CaseValeur(
            key: const Key('stat-deplacement'),
            libelle: 'Déplacement',
            explication: 'Distance parcourue par action de mouvement.',
            icone: Icons.directions_run,
            valeur: '${f.deplacement} m',
            detail: f.bonusDeplacement.isEmpty
                ? 'par action de mouvement'
                : 'dont ${[
                    for (final b in f.bonusDeplacement)
                      '${formaterModificateur(b.valeur)} m ${b.nom}',
                  ].join(', ')}',
            infobulle: [
              'Par action de mouvement : ${FicheCalculee.deplacementDeBase} m',
              for (final b in f.bonusDeplacement)
                '${formaterModificateur(b.valeur)} m : ${b.nom}',
            ].join('\n'),
          ),
          // Insaisissable : 2 actions de mouvement par tour.
          _CaseValeur(
            key: const Key('stat-actions-mouvement'),
            libelle: 'Actions de mvt',
            titre: 'Actions de mouvement',
            explication: "Nombre d'actions de mouvement par tour.",
            icone: Icons.repeat,
            valeur: '${f.actionsMouvement} / tour',
            detail: f.actionsMouvement > 1 ? 'Insaisissable' : null,
          ),
          // Bond du chat : chute sans dégâts jusqu'à RANG × 3 m.
          if (f.chuteSansDegats > 0)
            _CaseValeur(
              key: const Key('stat-chute'),
              libelle: 'Chute sans dégâts',
              explication: 'Hauteur de chute qui ne cause aucun dégât.',
              icone: Icons.south,
              valeur: "jusqu'à ${f.chuteSansDegats} m",
            ),
        ]),
        const SizedBox(height: 20),
        const _TitreSection('Personnage', icone: Icons.person_outline),
        _Rangee(colonnes: 2, [carac(Carac.adc), carac(Carac.force)]),
        const SizedBox(height: 8),
        _Rangee(colonnes: 2, [carac(Carac.adt), carac(Carac.dex)]),
        const SizedBox(height: 8),
        _Rangee(colonnes: 2, [carac(Carac.adm), carac(Carac.intel)]),
        const SizedBox(height: 8),
        _Rangee(colonnes: 2, [carac(Carac.con), carac(Carac.per)]),
        const SizedBox(height: 8),
        _Rangee(colonnes: 2, [carac(Carac.soc), carac(Carac.men)]),
      ],
    );
  }
}

class _TitreSection extends StatelessWidget {
  const _TitreSection(this.texte, {required this.icone});

  final String texte;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icone, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            texte,
            style: styleAmbiance(theme.textTheme.titleMedium)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SousTitre extends StatelessWidget {
  const _SousTitre(this.texte, {required this.icone});

  final String texte;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couleur = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Row(
        children: [
          Icon(icone, size: 16, color: couleur),
          const SizedBox(width: 6),
          Text(
            texte,
            style: theme.textTheme.labelLarge?.copyWith(color: couleur),
          ),
        ],
      ),
    );
  }
}

/// Une rangée de cases de même largeur, sur une grille de [colonnes]
/// colonnes : les cases manquantes laissent un vide, pour que les colonnes
/// restent alignées d'une rangée à l'autre.
class _Rangee extends StatelessWidget {
  const _Rangee(this.cases, {this.colonnes = 3});

  final List<Widget> cases;
  final int colonnes;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var c = 0; c < colonnes; c++) ...[
            if (c > 0) const SizedBox(width: 8),
            Expanded(
              child: c < cases.length ? cases[c] : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Une grande case (CA, initiative) à gauche, et à droite des rangées
/// titrées (« Esquive », « Toucher », « Dégâts »).
class _BlocAvecGrandeCase extends StatelessWidget {
  const _BlocAvecGrandeCase({required this.grande, required this.rangees});

  final Widget grande;
  final List<(String, Widget)> rangees;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: grande),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < rangees.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 4),
                    child: Text(
                      rangees[i].$1,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  rangees[i].$2,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Petite fenêtre au survol (souris) ou au toucher : titre en Cinzel, puis
/// l'explication. Son cadre vient de `tooltipTheme` (charte graphique).
class _Infobulle extends StatelessWidget {
  const _Infobulle({
    required this.titre,
    required this.texte,
    required this.child,
  });

  final String titre;
  final String texte;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      richMessage: TextSpan(
        children: [
          TextSpan(
            text: '$titre\n',
            style: styleAmbiance(theme.textTheme.labelLarge).copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: texte),
        ],
      ),
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 6),
      child: child,
    );
  }
}

/// Fond commun des cases.
class _Fond extends StatelessWidget {
  const _Fond({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      // Coupe le filigrane (trèfle de la chance) au bord de la case.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

/// Case simple : libellé (avec icône éventuelle), valeur, détail.
class _CaseValeur extends StatelessWidget {
  const _CaseValeur({
    super.key,
    required this.libelle,
    required this.valeur,
    this.icone,
    this.detail,
    this.infobulle,
    this.titre,
    this.explication,
    this.suite = const [],
  });

  final String libelle;

  /// Titre de la fenêtre de survol ; par défaut, le libellé.
  final String? titre;

  /// À quoi sert cette statistique (première ligne de la fenêtre de survol).
  final String? explication;
  final String valeur;
  final IconData? icone;
  final String? detail;

  /// Valeurs supplémentaires (valeur, détail) affichées sous la première
  /// (dégâts de plusieurs armes équipées).
  final List<(String, String?)> suite;

  /// Explication affichée au survol (souris) ou au toucher.
  final String? infobulle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final contenu = _Fond(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icone != null) ...[
                Icon(icone, size: 14, color: scheme.primary),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  libelle,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (infobulle != null)
                Icon(Icons.info_outline, size: 12, color: scheme.outline),
            ],
          ),
          const SizedBox(height: 2),
          for (final (i, (v, d)) in [(valeur, detail), ...suite].indexed) ...[
            if (i > 0) Divider(height: 10, color: scheme.outlineVariant),
            // Réduit le texte s'il est trop long (« 1d20 +3 » dans une case
            // étroite).
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                v,
                key: Key(i == 0 ? 'valeur' : 'valeur-$i'),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (d != null)
              Text(
                d,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ],
      ),
    );
    final texte = [
      if (explication != null) explication!,
      if (infobulle != null && infobulle!.isNotEmpty) infobulle!,
    ].join('\n');
    if (texte.isEmpty) return contenu;
    return _Infobulle(titre: titre ?? libelle, texte: texte, child: contenu);
  }
}

/// Grande case (CA, initiative) : grande icône en filigrane, valeur en grand.
class _GrandeCase extends StatelessWidget {
  const _GrandeCase({
    super.key,
    required this.libelle,
    required this.icone,
    required this.valeur,
    required this.explication,
  });

  final String libelle;
  final IconData icone;
  final String valeur;
  final String explication;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final contenu = Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icone,
              size: 64,
              color: scheme.primary.withValues(alpha: 0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  libelle,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    valeur,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return _Infobulle(titre: libelle, texte: explication, child: contenu);
  }
}

/// Case de caractéristique : le modificateur en grand et en couleur (vert
/// positif, rouge négatif), la valeur à droite dans un petit cadre, bien
/// séparée.
class _CaseCarac extends StatelessWidget {
  const _CaseCarac({
    super.key,
    required this.carac,
    required this.valeur,
    required this.mod,
    this.bonus = 0,
  });

  final Carac carac;
  final int valeur;
  final int mod;

  /// Part de la valeur venant des traits et compétences (« +2 SOC »).
  final int bonus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final contenu = _Infobulle(
      titre: carac.nom,
      texte: '${carac.description}\n'
          'Valeur $valeur'
          '${bonus == 0 ? '' : ' (dont ${formaterModificateur(bonus)} des traits et compétences)'}'
          ', modificateur ${formaterModificateur(mod)}',
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  carac.abrev,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formaterModificateur(mod),
                    key: const Key('modificateur'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: couleurModificateur(mod, theme.brightness),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Valeur de la caractéristique, encadrée et à l'écart.
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'valeur',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: scheme.outline, fontSize: 10),
                ),
                Text(
                  '$valeur',
                  key: const Key('valeur'),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (carac != Carac.chan) return _Fond(child: contenu);
    // Chance : trèfle à quatre feuilles en filigrane (comme le bouclier de
    // la CA), à gauche de la valeur encadrée.
    return _Fond(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 46,
            bottom: -18,
            child: IconeTrefle(
              key: const Key('trefle-chan'),
              taille: 54,
              couleur: scheme.primary.withValues(alpha: 0.18),
            ),
          ),
          contenu,
        ],
      ),
    );
  }
}
