import 'package:flutter/material.dart';

import '../models/voie.dart';
import '../regles/fiche_calculee.dart';
import '../theme.dart';

/// Libellés d'un sort (charte, décision 27) : endurance dépensée (coureur,
/// or, décision 61, aussi pour les compétences qui ne sont pas des sorts),
/// mana dépensé (goutte, bleu),
/// jet de réussite s'il en faut un (dé, or),
/// dégâts infligés s'il y en a (éclair, rouge), soin s'il y en a (cœur,
/// vert), effet appliqué s'il y en a (baguette magique, violet). Rien si la
/// compétence n'est pas un sort.
/// Données : `reussite`, `degats`, `soin`, `effetApplique` et `mana` (texte du coût, sinon
/// calculé selon le rang) dans `classes.json` / `races.json`.
class LibellesSort extends StatelessWidget {
  const LibellesSort(this.competence, {super.key});

  final Competence competence;

  @override
  Widget build(BuildContext context) {
    final cout = FicheCalculee.coutSort(competence);
    if (cout == null && competence.endurance.isEmpty) {
      return const SizedBox.shrink();
    }
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final c = competence;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        // Endurance dépensée (classes physiques et hybrides) : coureur, or.
        for (final (i, e) in c.endurance.indexed)
          _Libelle(
            key: Key('cout-endurance-$i'),
            icone: kIconeEndurance,
            texte: e.libelle.isEmpty
                ? '${e.cout} PE'
                : '${e.libelle} : ${e.cout} PE',
            infobulle: "Points d'endurance dépensés",
            couleur: sombre ? OdvCouleurs.pe : OdvCouleurs.peFonce,
          ),
        if (cout != null) ...[
          // Types du sort (offensif, support…), chacun avec son icône.
          for (final t in c.typesSort)
            _Libelle(
              key: Key('type-sort-${t.code}'),
              icone: t.icone,
              texte: t.libelle,
              infobulle: '${t.libelle} : ${t.definition}',
              couleur: t.couleur(Theme.of(context).brightness),
            ),
          _Libelle(
            icone: Icons.water_drop,
            texte: c.mana.isNotEmpty ? c.mana : '${cout.cout} PM',
            infobulle: 'Mana dépensé (sort de rang ${cout.rang})',
            couleur: sombre ? OdvCouleurs.pm : OdvCouleurs.blue,
          ),
          if (c.reussite case final r?)
            _Libelle(
              icone: Icons.casino_outlined,
              texte: [
                [
                  '1d20',
                  if (r.carac.isNotEmpty) r.carac,
                  if (r.bonus != 0) '${r.bonus}',
                ].join(' + '),
                if (r.difficulte != null) 'diff. ${r.difficulte}',
                if (r.contre.isNotEmpty) 'contre ${r.contre}',
              ].join(' · '),
              infobulle: '${r.libelle.isEmpty ? 'Jet de réussite' : r.libelle} '
                  '(dégâts et effet seulement si le sort réussit)',
              couleur: sombre ? OdvCouleurs.or : const Color(0xFF8A6420),
            ),
          if (c.degats.isNotEmpty)
            _Libelle(
              icone: Icons.bolt,
              texte: c.degats,
              infobulle: 'Dégâts infligés',
              couleur: sombre ? OdvCouleurs.physique : OdvCouleurs.darkRed,
            ),
          if (c.soin.isNotEmpty)
            _Libelle(
              icone: Icons.favorite,
              texte: c.soin,
              infobulle: 'Soin prodigué',
              couleur: sombre ? OdvCouleurs.pv : OdvCouleurs.darkGreen,
            ),
          if (c.effetApplique.isNotEmpty)
            _Libelle(
              icone: Icons.auto_fix_high,
              texte: c.effetApplique,
              infobulle: 'Effet appliqué',
              couleur: sombre ? OdvCouleurs.hybride : OdvCouleurs.hybrideFonce,
            ),
        ],
      ],
    );
  }
}

/// Pastille teintée : icône et texte de la même couleur.
class _Libelle extends StatelessWidget {
  const _Libelle({
    super.key,
    required this.icone,
    required this.texte,
    required this.infobulle,
    required this.couleur,
  });

  final IconData icone;
  final String texte;
  final String infobulle;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: infobulle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: couleur.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: couleur.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 14, color: couleur),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                texte,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: couleur,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
