import 'package:flutter/material.dart';

/// Charte graphique : voir `ressources/CHARTE_GRAPHIQUE.md`.
/// Toutes les couleurs de l'application viennent d'ici.
/// Thème sombre « Taverne » (bruns chauds, texte parchemin) depuis le
/// 21/10/2026.
abstract final class OdvCouleurs {
  // Neutres « Taverne » (thème sombre), du plus sombre au plus clair
  static const fond = Color(0xFF1C1916); // fond des écrans
  static const encre = Color(0xFF14110F); // champs de saisie, fond des jauges
  static const carteHaut = Color(0xFF2A241F); // haut du dégradé des cartes
  static const carte = Color(0xFF26211D); // cartes, barre du haut
  static const caseStat = Color(0xFF322B25); // cases de statistiques
  static const caseHaute = Color(0xFF3A322B); // cases en relief, survol
  static const bordure = Color(0xFF4A4038); // bordures, séparateurs
  static const texteParchemin = Color(0xFFF1E8DA); // texte principal
  static const texteSecondaire = Color(0xFFB8AC9C); // texte secondaire
  static const texteDiscret = Color(0xFF8F8478); // mentions, désactivé

  // Anciens neutres (gris) — conservés pour référence
  static const primaryDark = Color(0xFF3B3B3B);
  static const primaryDarker = Color(0xFF282828);
  static const grey = Color(0xFF5D5D5D);
  static const lightGrey = Color(0xFF8F8F8F);

  // Accent (orange cuivré) : actions, élément actif
  static const accent = Color(0xFFC87234);
  static const accentDark = Color(0xFFA04824);
  static const accentClair =
      Color(0xFFE59A62); // orange lisible sur fond sombre
  static const accentFond = Color(0xFF3A2A1E); // fond teinté orange

  // Or (pièces du logo) : progression, niveau
  static const or = Color(0xFFD4A24C);
  static const surOr = Color(0xFF2A1E0A); // texte sur fond or

  // Sémantiques
  static const red = Color(0xFFB14742);
  static const lightRed = Color(0xFFC67A76);
  static const darkRed = Color(0xFF92322D);
  static const green = Color(0xFF439E3E);
  static const lightGreen = Color(0xFF83CA7F);
  static const darkGreen = Color(0xFF296A25);
  static const blue = Color(0xFF3E73BE);
  static const lightBlue = Color(0xFF7FA6DE);
  static const darkBlue = Color(0xFF23426E);

  // Thème clair « parchemin »
  static const parchemin = Color(0xFFF4EDE1);
  static const parcheminFonce = Color(0xFFE2D6C3);
  static const texteFonce = Color(0xFF2E2E2E);

  // Usages dans le jeu
  static const pv = lightGreen;
  static const pm = lightBlue;
  static const pe = or; // endurance (classes physiques et hybrides)
  static const peFonce = Color(0xFF8A6420); // endurance sur fond clair
  static const physique = lightRed;
  static const magique = lightBlue;
  static const hybride = Color(0xFFA48FD0); // violet : mélange rouge + bleu
  static const hybrideFonce = Color(0xFF6E56A8); // hybride sur fond clair
}

/// Anciens noms, gardés pour le code existant.
const Color kCouleurOdv = OdvCouleurs.accent;
const Color kCouleurPv = OdvCouleurs.pv;
const Color kCouleurPm = OdvCouleurs.pm;
const Color kCouleurPe = OdvCouleurs.pe;

/// Icône de l'endurance (PE, dé d'endurance) : coureur.
const IconData kIconeEndurance = Icons.directions_run;

/// Couleur de la jauge PV selon l'état : vert au-dessus de 50 %, or
/// (ambre) de 25 à 50 %, rouge en dessous.
Color couleurPv(double ratio) => ratio > 0.5
    ? OdvCouleurs.lightGreen
    : ratio >= 0.25
        ? OdvCouleurs.or
        : OdvCouleurs.lightRed;

/// Couleur d'un modificateur : vert si positif, rouge si négatif, neutre à 0.
Color couleurModificateur(int mod, Brightness brightness) {
  final sombre = brightness == Brightness.dark;
  if (mod > 0) return sombre ? OdvCouleurs.lightGreen : OdvCouleurs.darkGreen;
  if (mod < 0) return sombre ? OdvCouleurs.lightRed : OdvCouleurs.darkRed;
  return sombre ? OdvCouleurs.texteSecondaire : OdvCouleurs.grey;
}

/// Logo de l'app (fond transparent, tiré de `ressources/assets/logo_tr.png`).
const String kLogo = 'assets/images/logo.png';

/// Police d'ambiance (titres : nom de l'app, personnages, races, classes,
/// créatures, titres de section). Changer cette constante suffit.
const String kPoliceAmbiance = 'Cinzel';

/// Applique la police d'ambiance à un style de texte.
TextStyle styleAmbiance(TextStyle? base) =>
    (base ?? const TextStyle()).copyWith(fontFamily: kPoliceAmbiance);

/// Dégradé vertical des cartes, selon le thème.
LinearGradient degradeCarte(Brightness brightness) => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: brightness == Brightness.dark
          ? const [OdvCouleurs.carteHaut, OdvCouleurs.carte]
          : const [Colors.white, OdvCouleurs.parchemin],
    );

const _sombre = ColorScheme(
  brightness: Brightness.dark,
  primary: OdvCouleurs.accent,
  onPrimary: Colors.white,
  primaryContainer: OdvCouleurs.accentFond,
  onPrimaryContainer: OdvCouleurs.accentClair,
  secondary: OdvCouleurs.texteSecondaire,
  onSecondary: OdvCouleurs.fond,
  secondaryContainer: OdvCouleurs.caseHaute,
  onSecondaryContainer: OdvCouleurs.texteParchemin,
  tertiary: OdvCouleurs.or,
  onTertiary: OdvCouleurs.surOr,
  error: OdvCouleurs.lightRed,
  onError: OdvCouleurs.fond,
  errorContainer: OdvCouleurs.darkRed,
  onErrorContainer: Color(0xFFFFDAD6),
  surface: OdvCouleurs.fond,
  onSurface: OdvCouleurs.texteParchemin,
  onSurfaceVariant: OdvCouleurs.texteSecondaire,
  surfaceContainerLowest: OdvCouleurs.encre,
  surfaceContainerLow: Color(0xFF221D19),
  surfaceContainer: OdvCouleurs.carte,
  surfaceContainerHigh: OdvCouleurs.caseStat,
  surfaceContainerHighest: OdvCouleurs.caseStat,
  outline: OdvCouleurs.texteDiscret,
  outlineVariant: OdvCouleurs.bordure,
  inverseSurface: OdvCouleurs.parchemin,
  onInverseSurface: OdvCouleurs.texteFonce,
  inversePrimary: OdvCouleurs.accentDark,
  shadow: Colors.black,
  scrim: Colors.black,
);

const _clair = ColorScheme(
  brightness: Brightness.light,
  // Sur fond clair, l'accent lisible est l'orange foncé.
  primary: OdvCouleurs.accentDark,
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFF3D9C4),
  onPrimaryContainer: Color(0xFF5A2A10),
  secondary: OdvCouleurs.grey,
  onSecondary: Colors.white,
  secondaryContainer: OdvCouleurs.parcheminFonce,
  onSecondaryContainer: OdvCouleurs.texteFonce,
  tertiary: Color(0xFF8A6420),
  onTertiary: Colors.white,
  error: OdvCouleurs.red,
  onError: Colors.white,
  errorContainer: Color(0xFFF6DCDA),
  onErrorContainer: OdvCouleurs.darkRed,
  surface: OdvCouleurs.parchemin,
  onSurface: OdvCouleurs.texteFonce,
  onSurfaceVariant: OdvCouleurs.grey,
  surfaceContainerLowest: Colors.white,
  surfaceContainerLow: Color(0xFFFBF7F0),
  surfaceContainer: Color(0xFFF7F1E7),
  surfaceContainerHigh: Color(0xFFEDE3D3),
  surfaceContainerHighest: OdvCouleurs.parcheminFonce,
  outline: OdvCouleurs.lightGrey,
  outlineVariant: OdvCouleurs.parcheminFonce,
  inverseSurface: OdvCouleurs.carte,
  onInverseSurface: OdvCouleurs.texteParchemin,
  inversePrimary: OdvCouleurs.accent,
  shadow: Colors.black,
  scrim: Colors.black,
);

ThemeData themeOdv(Brightness brightness) {
  final sombre = brightness == Brightness.dark;
  final scheme = sombre ? _sombre : _clair;
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  const pilule = StadiumBorder();
  final fondBarre = sombre ? OdvCouleurs.carte : const Color(0xFFFBF7F0);

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    // Barre du haut sombre avec un filet orange : l'orange reste réservé
    // aux actions.
    appBarTheme: AppBarTheme(
      backgroundColor: fondBarre,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      shape: const Border(
        bottom: BorderSide(color: OdvCouleurs.accent, width: 2),
      ),
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: sombre ? OdvCouleurs.accentClair : OdvCouleurs.accentDark,
      unselectedLabelColor: scheme.onSurfaceVariant,
      indicatorColor: OdvCouleurs.accent,
      dividerColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: sombre ? scheme.surfaceContainer : scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: sombre ? 0.5 : 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: sombre ? OdvCouleurs.caseHaute : OdvCouleurs.parcheminFonce,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: OdvCouleurs.accent,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: OdvCouleurs.accent,
        foregroundColor: Colors.white,
        shape: pilule,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outlineVariant),
        shape: pilule,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor:
            sombre ? OdvCouleurs.accentClair : OdvCouleurs.accentDark,
        shape: pilule,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: sombre ? OdvCouleurs.encre : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: pilule,
      selectedColor: scheme.primaryContainer,
      side: BorderSide(color: scheme.outlineVariant),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: sombre ? OdvCouleurs.carte : scheme.surface,
      indicatorColor: scheme.primaryContainer,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: sombre ? OdvCouleurs.carte : scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: DividerThemeData(
      color: sombre ? OdvCouleurs.bordure : OdvCouleurs.parcheminFonce,
      thickness: 1,
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? OdvCouleurs.accent
            : scheme.outline,
      ),
    ),
  );
}

/// Style du bouton « Monter au niveau » : or (progression).
ButtonStyle styleBoutonProgression() => FilledButton.styleFrom(
      backgroundColor: OdvCouleurs.or,
      foregroundColor: OdvCouleurs.surOr,
      shape: const StadiumBorder(),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    );

/// Carte de la charte : dégradé vertical, coins de 16 px, ombre douce.
/// [selectionnee] : bordure claire (thème sombre) ou orange (thème clair).
class CarteOdv extends StatelessWidget {
  const CarteOdv({
    super.key,
    required this.child,
    this.onTap,
    this.selectionnee = false,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selectionnee;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rayon = BorderRadius.circular(16);
    final sombre = theme.brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: degradeCarte(theme.brightness),
        borderRadius: rayon,
        border: selectionnee
            ? Border.all(
                color: sombre ? OdvCouleurs.texteParchemin : OdvCouleurs.accent,
                width: 2,
              )
            : Border.all(
                color:
                    sombre ? OdvCouleurs.caseHaute : OdvCouleurs.parcheminFonce,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: sombre ? 0.45 : 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: rayon,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Avatar rond de personnage : fond brun teinté, contour et initiale orange.
class AvatarPersonnage extends StatelessWidget {
  const AvatarPersonnage({
    super.key,
    required this.nom,
    this.rayon = 26,
    this.couleur,
  });

  final String nom;
  final double rayon;

  /// Couleur du contour et de l'initiale (orange par défaut).
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sombre = theme.brightness == Brightness.dark;
    return Container(
      width: rayon * 2,
      height: rayon * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: couleur != null
            ? couleur!.withValues(alpha: sombre ? 0.15 : 0.2)
            : (sombre ? OdvCouleurs.accentFond : const Color(0xFFF3D9C4)),
        border: Border.all(color: couleur ?? OdvCouleurs.accent, width: 1.5),
      ),
      child: Text(
        nom.isEmpty ? '?' : nom[0].toUpperCase(),
        style: styleAmbiance(theme.textTheme.titleLarge).copyWith(
          fontSize: rayon * 0.9,
          fontWeight: FontWeight.w700,
          color: couleur ??
              (sombre ? OdvCouleurs.accentClair : OdvCouleurs.accentDark),
        ),
      ),
    );
  }
}
