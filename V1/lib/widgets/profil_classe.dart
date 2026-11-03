import 'package:flutter/material.dart';

import '../models/carac.dart';
import '../models/classe.dart';
import '../models/race.dart';
import '../regles/fiche_calculee.dart';
import '../theme.dart';

/// Couleur d'un profil de classe : physique = rouge, lanceur de sorts =
/// bleu, hybride = violet (mélange des deux).
Color couleurProfil(ProfilClasse p, Brightness brightness) {
  final sombre = brightness == Brightness.dark;
  return switch (p) {
    ProfilClasse.physique =>
      sombre ? OdvCouleurs.lightRed : OdvCouleurs.darkRed,
    ProfilClasse.lanceur => sombre ? OdvCouleurs.lightBlue : OdvCouleurs.blue,
    ProfilClasse.hybride =>
      sombre ? OdvCouleurs.hybride : OdvCouleurs.hybrideFonce,
  };
}

IconData iconeProfil(ProfilClasse p) => switch (p) {
      ProfilClasse.physique => Icons.sports_martial_arts,
      ProfilClasse.lanceur => Icons.auto_awesome,
      ProfilClasse.hybride => Icons.join_inner,
    };

/// Étiquette colorée du profil (« Physique », « Lanceur de sorts »…).
class EtiquetteProfil extends StatelessWidget {
  const EtiquetteProfil(this.profil, {super.key, this.libelle});

  final ProfilClasse profil;

  /// Libellé imposé (races : « Magique » plutôt que « Lanceur de sorts »).
  final String? libelle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = couleurProfil(profil, theme.brightness);
    return Container(
      key: Key('profil-${profil.code}'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconeProfil(profil), size: 14, color: c),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              libelle ?? profil.libelle,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: c, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

String _aideModif(String de, ModifDe m) => switch (m) {
      ModifDe.plus => '$de : un cran au-dessus de celui de la race',
      ModifDe.moins => '$de : un cran en dessous de celui de la race',
      ModifDe.egal => '$de : celui de la race',
    };

/// Couleur de la vie (cœur), du mana (goutte) et de l'endurance (coureur),
/// selon le thème.
Color couleurVie(Brightness b) =>
    b == Brightness.dark ? OdvCouleurs.pv : OdvCouleurs.darkGreen;
Color couleurMana(Brightness b) =>
    b == Brightness.dark ? OdvCouleurs.pm : OdvCouleurs.blue;
Color couleurEndurance(Brightness b) =>
    b == Brightness.dark ? OdvCouleurs.pe : OdvCouleurs.peFonce;

/// Jauge à 3 crans d'un dé de vie ou de mana modifié par la classe, remplie
/// jusqu'au cran atteint : 1 cran = dé inférieur (rouge), 2 crans = dé de la
/// race (neutre), 3 crans = dé supérieur (couleur de la ressource). Icône de la ressource
/// devant, explication au survol.
class CurseurDe extends StatelessWidget {
  const CurseurDe({
    super.key,
    required this.icone,
    required this.couleur,
    required this.modif,
    required this.nomDe,
    this.faces,
    this.absent = false,
  });

  /// Ressource que la classe n'a pas (mana d'une classe physique, endurance
  /// d'un lanceur de sorts) : jauge vide barrée d'une croix.
  const CurseurDe.absent({
    super.key,
    required this.icone,
    required this.couleur,
    required this.nomDe,
  })  : modif = ModifDe.egal,
        faces = null,
        absent = true;

  final bool absent;

  /// Dé d'une race : place le curseur selon sa taille (d4 bas, d6 milieu,
  /// d8 et plus haut) et affiche le dé (« d8 ») après le curseur.
  factory CurseurDe.race({
    Key? key,
    required IconData icone,
    required Color couleur,
    required int faces,
    required String nomDe,
  }) =>
      CurseurDe(
        key: key,
        icone: icone,
        couleur: couleur,
        modif: faces <= 4
            ? ModifDe.moins
            : faces == 6
                ? ModifDe.egal
                : ModifDe.plus,
        nomDe: nomDe,
        faces: faces,
      );

  /// Taille du dé (races) ; `null` pour une modification de classe.
  final int? faces;

  final IconData icone;

  /// Couleur de la ressource (vert pour la vie, bleu pour le mana).
  final Color couleur;
  final ModifDe modif;

  /// « Dé de vie », « Dé de mana » ou « Dé d'endurance ».
  final String nomDe;

  int get _cran => switch (modif) {
        ModifDe.moins => 0,
        ModifDe.egal => 1,
        ModifDe.plus => 2,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sombre = theme.brightness == Brightness.dark;
    final vide = sombre ? OdvCouleurs.caseHaute : OdvCouleurs.parcheminFonce;
    final actif = switch (modif) {
      ModifDe.moins => sombre ? OdvCouleurs.lightRed : OdvCouleurs.red,
      ModifDe.egal => sombre ? OdvCouleurs.texteDiscret : OdvCouleurs.grey,
      ModifDe.plus => couleur,
    };
    final ressource = switch (nomDe) {
      'Dé de vie' => 'vie',
      'Dé de mana' => 'mana',
      _ => 'endurance',
    };
    final aide = absent
        ? '$nomDe : aucun (pas de ${ressource == 'mana' ? 'PM' : 'PE'})'
        : faces == null
            ? _aideModif(nomDe, modif)
            : '$nomDe : d$faces (${switch (modif) {
                ModifDe.moins => 'faible',
                ModifDe.egal => 'moyen',
                ModifDe.plus => 'élevé',
              }})';
    final barre = sombre ? OdvCouleurs.lightRed : OdvCouleurs.red;
    return Tooltip(
      message: aide,
      child: Semantics(
        label: aide,
        child: Row(
          key: Key('curseur-$ressource-${absent ? 'absent' : modif.name}'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: 16,
              color: absent ? theme.colorScheme.onSurfaceVariant : couleur,
            ),
            const SizedBox(width: 4),
            // Ressource absente : jauge vide, barrée d'une croix.
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: 2),
                      Container(
                        width: 12,
                        height: 8,
                        decoration: BoxDecoration(
                          // Jauge remplie jusqu'au cran.
                          color: !absent && i <= _cran ? actif : vide,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ],
                ),
                if (absent) Icon(Icons.close, size: 18, color: barre),
              ],
            ),
            if (faces != null) ...[
              const SizedBox(width: 6),
              Text(
                'd$faces',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: couleur,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Curseurs du dé de mana et du dé d'endurance d'une classe : barrés d'une
/// croix quand la classe n'a pas la ressource (physique : pas de PM ;
/// lanceur de sorts : pas de PE).
List<Widget> curseursRessources(Classe classe, Brightness b) => [
      if (classe.aDuMana)
        CurseurDe(
          icone: Icons.water_drop,
          couleur: couleurMana(b),
          modif: classe.modifDeMana,
          nomDe: 'Dé de mana',
        )
      else
        CurseurDe.absent(
          icone: Icons.water_drop,
          couleur: couleurMana(b),
          nomDe: 'Dé de mana',
        ),
      if (classe.aDeLEndurance)
        CurseurDe(
          icone: kIconeEndurance,
          couleur: couleurEndurance(b),
          modif: classe.modifDeEndurance,
          nomDe: "Dé d'endurance",
        )
      else
        CurseurDe.absent(
          icone: kIconeEndurance,
          couleur: couleurEndurance(b),
          nomDe: "Dé d'endurance",
        ),
    ];

/// Résumé d'une classe pour les listes : profil, vie, mana, endurance,
/// nombre de voies.
class InfosClasse extends StatelessWidget {
  const InfosClasse(this.classe, {super.key});

  final Classe classe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        EtiquetteProfil(classe.profil),
        CurseurDe(
          icone: Icons.favorite,
          couleur: couleurVie(theme.brightness),
          modif: classe.modifDeVie,
          nomDe: 'Dé de vie',
        ),
        ...curseursRessources(classe, theme.brightness),
        _Indicateur(
          icone: Icons.auto_stories_outlined,
          couleur: theme.colorScheme.onSurfaceVariant,
          texte: '${classe.voies.length} voies',
          aide: 'Voies de compétence de la classe',
        ),
      ],
    );
  }
}

class _Indicateur extends StatelessWidget {
  const _Indicateur({
    required this.icone,
    required this.couleur,
    required this.texte,
    required this.aide,
  });

  final IconData icone;
  final Color couleur;
  final String texte;
  final String aide;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: aide,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 16, color: couleur),
          const SizedBox(width: 4),
          Text(
            texte,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: couleur,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Libellé du profil d'une race (« Magique » pour les races magiques).
String libelleProfilRace(ProfilClasse p) =>
    p == ProfilClasse.lanceur ? 'Magique' : p.libelle;

/// Modificateurs de statistiques en couleur : « +3 FOR » vert, « −2 INT »
/// rouge.
class ModificateursCouleur extends StatelessWidget {
  const ModificateursCouleur(this.modificateurs, {super.key});

  final Map<Carac, int> modificateurs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final liste = [
      for (final c in Carac.values)
        if ((modificateurs[c] ?? 0) != 0) (c, modificateurs[c]!),
    ];
    if (liste.isEmpty) {
      return Text(
        'aucun',
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final (c, v) in liste)
          Text(
            '${formaterModificateur(v)} ${c.abrev}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: couleurModificateur(v, theme.brightness),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

/// Résumé d'une race pour les listes : orientation, dés de vie et de mana
/// (curseurs), modificateurs de statistiques ou nombre d'origines.
class InfosRace extends StatelessWidget {
  const InfosRace(this.race, {super.key, this.modificateurs = true});

  final Race race;

  /// Modificateurs en couleur à la suite (non : création, où ils sont sur
  /// la ligne « Caractéristiques »).
  final bool modificateurs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        EtiquetteProfil(race.profil, libelle: libelleProfilRace(race.profil)),
        CurseurDe.race(
          icone: Icons.favorite,
          couleur: couleurVie(theme.brightness),
          faces: race.deVie,
          nomDe: 'Dé de vie',
        ),
        CurseurDe.race(
          icone: Icons.water_drop,
          couleur: couleurMana(theme.brightness),
          faces: race.deMana,
          nomDe: 'Dé de mana',
        ),
        CurseurDe.race(
          icone: kIconeEndurance,
          couleur: couleurEndurance(theme.brightness),
          faces: race.deEndurance,
          nomDe: "Dé d'endurance",
        ),
        if (race.aDesOrigines)
          Tooltip(
            message: 'Statistiques selon l\'origine',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.family_restroom_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${race.origines.length} origines',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else if (modificateurs)
          ModificateursCouleur(race.modificateurs),
      ],
    );
  }
}

/// « Caractéristiques : +3 FOR −2 INT », modificateurs en couleur (vert si
/// positif, rouge si négatif).
class LigneModificateurs extends StatelessWidget {
  const LigneModificateurs(this.modificateurs, {super.key});

  final Map<Carac, int> modificateurs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Caractéristiques : ',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          ModificateursCouleur(modificateurs),
        ],
      ),
    );
  }
}
