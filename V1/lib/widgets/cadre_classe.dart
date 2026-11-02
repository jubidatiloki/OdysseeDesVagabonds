import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'emblemes_race.dart';
import 'matieres_classe.dart';

/// Motifs décoratifs des classes : dessinés (labrys, flûte, crâne…) ou
/// repris des icônes Material quand elles existent ([icone]).
enum MotifClasse {
  labrys,
  sang,
  flute,
  baluchon,
  notes(Icons.music_note),
  casque,
  ecusson,
  feuille(Icons.eco),
  fleur(Icons.local_florist),
  patte(Icons.pets),
  lapin(Icons.cruelty_free),
  epee,
  arc,
  bouclier,
  marteau,
  bombe,
  poudre,
  livre(Icons.menu_book),
  sort(Icons.auto_fix_high),
  etoiles(Icons.auto_awesome),
  poing(Icons.sports_mma),
  hadoken,
  lotus,
  ninja(Icons.sports_martial_arts),
  shuriken,
  crane,
  demon,
  vitalite,
  piege,
  dague,
  bourse,
  // Équipements (glossaire, inventaire).
  pioche,
  plastron,
  potion,
  // Arme à poudre (pétoire, pistolet, mousquet, canon) : pistolet à silex.
  pistolet;

  const MotifClasse([this.icone]);

  final IconData? icone;
}

/// Habillage d'une classe : couleur, motifs du filigrane, cadre abîmé.
/// Charte : décision 25 (`ressources/CHARTE_GRAPHIQUE.md`).
class StyleClasse {
  const StyleClasse({
    required this.couleur,
    required this.motifs,
    this.abime = false,
  });

  /// Couleur de la classe (thème sombre ; assombrie sur le parchemin).
  final Color couleur;

  /// Motifs du filigrane ; le premier sert d'emblème (avatar).
  final List<MotifClasse> motifs;

  /// Cadre ébréché, fissuré et taché de sang (barbare).
  final bool abime;

  Color couleurPour(Brightness b) =>
      b == Brightness.dark ? couleur : Color.lerp(couleur, Colors.black, 0.35)!;

  static const Map<String, StyleClasse> parClasse = {
    'barbare': StyleClasse(
      couleur: Color(0xFFC0463E),
      motifs: [MotifClasse.labrys, MotifClasse.labrys, MotifClasse.sang],
      abime: true,
    ),
    'barde': StyleClasse(
      couleur: Color(0xFFD883B0),
      motifs: [MotifClasse.flute, MotifClasse.baluchon, MotifClasse.notes],
    ),
    'chevalier': StyleClasse(
      couleur: Color(0xFF8FA7C4),
      motifs: [MotifClasse.casque, MotifClasse.ecusson],
    ),
    'druide': StyleClasse(
      couleur: Color(0xFF6DB363),
      motifs: [
        MotifClasse.feuille,
        MotifClasse.patte,
        MotifClasse.fleur,
        MotifClasse.lapin,
      ],
    ),
    'guerrier': StyleClasse(
      couleur: Color(0xFFC49A62),
      motifs: [MotifClasse.bouclier, MotifClasse.arc],
    ),
    'ingenieur': StyleClasse(
      couleur: Color(0xFFE0B040),
      motifs: [MotifClasse.marteau, MotifClasse.bombe, MotifClasse.poudre],
    ),
    'magicien': StyleClasse(
      couleur: Color(0xFF6E8FE0),
      motifs: [MotifClasse.livre, MotifClasse.sort, MotifClasse.etoiles],
    ),
    'moine': StyleClasse(
      couleur: Color(0xFFE08A3C),
      motifs: [MotifClasse.lotus, MotifClasse.ninja, MotifClasse.shuriken],
    ),
    'necromancien': StyleClasse(
      couleur: Color(0xFF9A7BD0),
      motifs: [MotifClasse.crane, MotifClasse.demon],
    ),
    'pretre': StyleClasse(
      couleur: Color(0xFFE8D27A),
      motifs: [MotifClasse.vitalite, MotifClasse.bouclier],
    ),
    'rodeur': StyleClasse(
      couleur: Color(0xFF8DA45A),
      motifs: [MotifClasse.arc, MotifClasse.piege, MotifClasse.patte],
    ),
    'voleur': StyleClasse(
      couleur: Color(0xFFA6A6B8),
      motifs: [MotifClasse.dague, MotifClasse.bourse],
    ),
  };

  static StyleClasse? de(String? classeId) => parClasse[classeId];
}

/// Motif seul (icône Material ou dessin), de la taille donnée.
class IconeMotif extends StatelessWidget {
  const IconeMotif(this.motif, {super.key, this.taille = 24, this.couleur});

  final MotifClasse motif;
  final double taille;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final c = couleur ?? IconTheme.of(context).color ?? Colors.white;
    final icone = motif.icone;
    if (icone != null) return Icon(icone, size: taille, color: c);
    return SizedBox.square(
      dimension: taille,
      child: CustomPaint(painter: _PeintreMotif(motif, c)),
    );
  }
}

/// Active ou coupe les effets animés des cadres de classe (page
/// Préférences), pour tout ce qui est en dessous.
class AnimationsCadres extends InheritedWidget {
  const AnimationsCadres({
    super.key,
    required this.actives,
    required super.child,
  });

  final bool actives;

  /// Animations voulues ici (oui par défaut, sans réglage au-dessus).
  static bool de(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AnimationsCadres>()?.actives ??
      true;

  @override
  bool updateShouldNotify(AnimationsCadres old) => old.actives != actives;
}

/// Carte habillée dans la **matière** de la classe ([classeId]) : bois
/// griffé du barbare, acier poli du chevalier, nuit étoilée du magicien…,
/// avec bordure et coins ornés de la couleur de la classe, motifs en
/// filigrane et un **effet d'ambiance animé** (sang qui coule, feuilles qui
/// tombent, runes qui scintillent…), figé si les animations sont coupées.
/// Sans style connu : [CarteOdv].
class CadreClasse extends StatefulWidget {
  const CadreClasse({
    super.key,
    required this.classeId,
    required this.child,
    this.onTap,
    this.selectionnee = false,
    this.padding = const EdgeInsets.all(16),
    this.tailleMotifs = 64,
  });

  /// `false` : jamais d'animation (tests : une animation en boucle
  /// empêcherait `pumpAndSettle` de se terminer).
  static bool animationsAutorisees = true;

  /// Écran étroit (téléphone, moins de 600 px) : décor allégé là où il
  /// cacherait les infos (guerrier : cible, flèches et épées retirées, seul
  /// le filigrane du coin en bas à droite reste).
  static bool estCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  /// Durée d'un cycle d'effet.
  static const Duration cycle = Duration(seconds: 8);

  final String? classeId;
  final Widget child;
  final VoidCallback? onTap;
  final bool selectionnee;
  final EdgeInsetsGeometry padding;

  /// Taille du plus grand motif du filigrane.
  final double tailleMotifs;

  @override
  State<CadreClasse> createState() => _CadreClasseState();
}

class _CadreClasseState extends State<CadreClasse>
    with SingleTickerProviderStateMixin {
  AnimationController? _horloge;

  /// Démarre ou arrête l'horloge selon les réglages.
  void _regler(bool animer) {
    if (animer == (_horloge != null)) return;
    if (animer) {
      _horloge = AnimationController(vsync: this, duration: CadreClasse.cycle)
        ..repeat();
    } else {
      _horloge?.dispose();
      _horloge = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _regler(_animer);
  }

  @override
  void didUpdateWidget(CadreClasse old) {
    super.didUpdateWidget(old);
    _regler(_animer);
  }

  bool get _animer =>
      CadreClasse.animationsAutorisees &&
      StyleClasse.de(widget.classeId) != null &&
      aEffetAnime(widget.classeId!, compact: CadreClasse.estCompact(context)) &&
      AnimationsCadres.de(context) &&
      !MediaQuery.of(context).disableAnimations;

  @override
  void dispose() {
    _horloge?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classeId = widget.classeId;
    final style = StyleClasse.de(classeId);
    if (style == null || classeId == null) {
      return CarteOdv(
        onTap: widget.onTap,
        selectionnee: widget.selectionnee,
        padding: widget.padding,
        child: widget.child,
      );
    }
    final theme = Theme.of(context);
    final sombre = theme.brightness == Brightness.dark;
    final couleur = style.couleurPour(theme.brightness);
    final voile = sombre ? OdvCouleurs.fond : OdvCouleurs.parchemin;
    final compact = CadreClasse.estCompact(context);
    final rayon = BorderRadius.circular(16);
    return DecoratedBox(
      key: Key('cadre-classe-$classeId'),
      decoration: BoxDecoration(
        borderRadius: rayon,
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
          onTap: widget.onTap,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _PeintreCadre(
                    classeId: classeId,
                    style: style,
                    couleur: couleur,
                    sombre: sombre,
                    selectionnee: widget.selectionnee,
                    compact: compact,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 6,
                bottom: 6,
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Opacity(
                      opacity: sombre ? 0.2 : 0.18,
                      child: _Filigrane(
                        motifs: style.motifs,
                        couleur: couleur,
                        taille: widget.tailleMotifs,
                      ),
                    ),
                  ),
                ),
              ),
              // Effet d'ambiance (repeint seul, sans reconstruire la carte).
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: rayon,
                      child: CustomPaint(
                        key: Key('effet-classe-$classeId'),
                        painter: PeintreEffet(
                          classeId: classeId,
                          couleur: couleur,
                          sombre: sombre,
                          compact: compact,
                          horloge: _horloge,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Voile derrière le texte (à gauche) : lisibilité.
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: rayon,
                      gradient: LinearGradient(
                        colors: [
                          voile.withValues(alpha: 0.6),
                          voile.withValues(alpha: 0.35),
                          voile.withValues(alpha: 0),
                        ],
                        stops: const [0, 0.3, 0.55],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(padding: widget.padding, child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar du personnage : emblème de sa race (à la place de l'initiale)
/// sur le fond de la race, contour dans la couleur de sa classe, emblème de
/// la classe (premier motif) en médaillon.
class AvatarClasse extends StatelessWidget {
  const AvatarClasse({
    super.key,
    required this.nom,
    required this.classeId,
    this.raceId,
    this.element,
    this.rayon = 26,
  });

  final String nom;
  final String? classeId;

  /// Race : son emblème remplace l'initiale (décision 28).
  final String? raceId;

  /// Élément du draconien (`feu`, `glace`, `foudre`) : couleur du fond ;
  /// neutre sans élément (ailes vestigiales).
  final String? element;
  final double rayon;

  @override
  Widget build(BuildContext context) {
    final style = StyleClasse.de(classeId);
    final theme = Theme.of(context);
    final sombre = theme.brightness == Brightness.dark;
    final couleur = style?.couleurPour(theme.brightness) ?? OdvCouleurs.accent;
    final race = raceId;
    final Widget cercle;
    if (race != null && kRacesAvecEmbleme.contains(race)) {
      final base = sombre ? OdvCouleurs.carte : Colors.white;
      final teintes = [
        for (final c in couleursFondRace(race, element: element))
          Color.alphaBlend(c.withValues(alpha: sombre ? 0.45 : 0.35), base),
      ];
      // Emblème clair (sombre) ou foncé (clair), teinté par la classe.
      final trait = Color.lerp(
          couleur, sombre ? Colors.white : Colors.black, sombre ? 0.55 : 0.3)!;
      cercle = Container(
        key: Key('embleme-race-$race'),
        width: rayon * 2,
        height: rayon * 2,
        padding: EdgeInsets.all(rayon * 0.24),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: teintes.length == 1 ? teintes.first : null,
          // Demi-elfe : deux moitiés.
          gradient: teintes.length > 1
              ? LinearGradient(
                  colors: [teintes[0], teintes[0], teintes[1], teintes[1]],
                  stops: const [0, 0.5, 0.5, 1],
                )
              : null,
          border: Border.all(color: couleur, width: 1.5),
        ),
        child: EmblemeRace(raceId: race, couleur: trait, taille: rayon * 1.52),
      );
    } else {
      cercle = AvatarPersonnage(
        nom: nom,
        rayon: rayon,
        couleur: style == null ? null : couleur,
      );
    }
    if (style == null) return cercle;
    final medaillon = rayon * 0.78;
    return SizedBox.square(
      dimension: rayon * 2 + medaillon * 0.3,
      child: Stack(
        children: [
          cercle,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              key: const Key('embleme-classe'),
              width: medaillon,
              height: medaillon,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sombre ? OdvCouleurs.carte : Colors.white,
                border: Border.all(color: couleur, width: 1.5),
              ),
              child: IconeMotif(
                style.motifs.first,
                taille: medaillon * 0.62,
                couleur: couleur,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Motifs en filigrane, légèrement inclinés, le plus grand à droite.
class _Filigrane extends StatelessWidget {
  const _Filigrane({
    required this.motifs,
    required this.couleur,
    required this.taille,
  });

  final List<MotifClasse> motifs;
  final Color couleur;
  final double taille;

  static const _angles = [-0.35, 0.3, -0.15, 0.2];

  @override
  Widget build(BuildContext context) {
    final n = motifs.length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Ordre inversé : le premier motif (le plus grand) à droite.
        for (var i = n - 1; i >= 0; i--)
          Padding(
            padding: EdgeInsets.only(
              left: 2,
              bottom: i.isOdd ? taille * 0.3 : 0,
            ),
            child: Transform.rotate(
              angle: _angles[i % _angles.length],
              child: IconeMotif(
                motifs[i],
                taille: i == 0 ? taille : taille * (n > 3 ? 0.6 : 0.72),
                couleur: couleur,
              ),
            ),
          ),
      ],
    );
  }
}

/// Fond, filets, coins ornés ; éclats, fissures et sang si abîmé.
class _PeintreCadre extends CustomPainter {
  _PeintreCadre({
    required this.classeId,
    required this.style,
    required this.couleur,
    required this.sombre,
    required this.selectionnee,
    this.compact = false,
  });

  final String classeId;
  final StyleClasse style;
  final Color couleur;
  final bool sombre;
  final bool selectionnee;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    var forme = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect.deflate(0.75), const Radius.circular(16)),
      );
    if (style.abime) {
      forme = Path.combine(PathOperation.difference, forme, _eclats(w, h));
    }

    // Fond : la matière de la classe, un peu plus claire en haut à gauche.
    final bas =
        fondMatiere(classeId, sombre ? Brightness.dark : Brightness.light);
    final haut = Color.lerp(bas, Colors.white, sombre ? 0.06 : 0.4)!;
    canvas.drawPath(
      forme,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(couleur.withValues(alpha: 0.10), haut),
            bas,
            Color.lerp(bas, Colors.black, sombre ? 0.15 : 0.04)!,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(rect),
    );

    // Texture de la matière, gardée dans la forme du cadre et atténuée.
    canvas.save();
    canvas.clipPath(forme);
    canvas.saveLayer(
        rect, Paint()..color = Colors.black.withValues(alpha: 0.6));
    dessinerMatiere(canvas, size, classeId, couleur, sombre, compact: compact);
    canvas.restore();
    canvas.restore();

    // Filet intérieur fin.
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(5), const Radius.circular(12)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = couleur.withValues(alpha: 0.35),
    );

    // Bordure (plus épaisse et plus claire pour le personnage actif).
    canvas.drawPath(
      forme,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selectionnee ? 3 : 1.6
        ..color = selectionnee
            ? Color.lerp(couleur, sombre ? Colors.white : Colors.black, 0.25)!
            : couleur.withValues(alpha: 0.9),
    );

    // Coins ornés : losange et deux traits terminés par un point.
    final orne = Paint()
      ..color = couleur
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (final (sx, sy) in [
      (1.0, 1.0),
      (-1.0, 1.0),
      (1.0, -1.0),
      (-1.0, -1.0)
    ]) {
      final c = Offset(sx > 0 ? 9 : w - 9, sy > 0 ? 9 : h - 9);
      final losange = Path()
        ..moveTo(c.dx, c.dy - 3.5)
        ..lineTo(c.dx + 3.5, c.dy)
        ..lineTo(c.dx, c.dy + 3.5)
        ..lineTo(c.dx - 3.5, c.dy)
        ..close();
      canvas.drawPath(losange, orne);
      for (final d in [Offset(sx, 0), Offset(0, sy)]) {
        canvas.drawLine(c + d * 7, c + d * 20, orne);
        canvas.drawCircle(c + d * 23, 1.3, orne);
      }
    }

    if (style.abime) _blessures(canvas, w, h);
  }

  /// Éclats retirés du bord (triangles à cheval sur le cadre).
  Path _eclats(double w, double h) {
    Path tri(Offset a, Offset b, Offset c) => Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
    final x1 = w * 0.24;
    final x2 = w * 0.66;
    final x3 = w * 0.42;
    final y1 = h * 0.58;
    final y2 = h * 0.32;
    return Path()
      ..addPath(tri(Offset(x1 - 7, -1), Offset(x1 + 6, -1), Offset(x1 + 1, 7)),
          Offset.zero)
      ..addPath(tri(Offset(x2 - 5, -1), Offset(x2 + 8, -1), Offset(x2, 9)),
          Offset.zero)
      ..addPath(
          tri(Offset(w + 1, y1 - 6), Offset(w + 1, y1 + 7), Offset(w - 8, y1)),
          Offset.zero)
      ..addPath(
          tri(Offset(x3 - 6, h + 1), Offset(x3 + 7, h + 1), Offset(x3, h - 8)),
          Offset.zero)
      ..addPath(tri(Offset(-1, y2 - 5), Offset(-1, y2 + 8), Offset(9, y2 + 2)),
          Offset.zero)
      // Coin arraché en bas à droite
      ..addPath(
          tri(Offset(w - 26, h + 1), Offset(w + 1, h - 18),
              Offset(w + 1, h + 1)),
          Offset.zero);
  }

  /// Fissures partant des éclats, éclaboussures et coulures de sang.
  void _blessures(Canvas canvas, double w, double h) {
    final fissure = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round
      ..color = couleur.withValues(alpha: 0.6);
    void ligne(List<Offset> pts) {
      final p = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final o in pts.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(p, fissure);
    }

    final x1 = w * 0.24 + 1;
    ligne([
      Offset(x1, 7),
      Offset(x1 + 4, 15),
      Offset(x1 - 2, 24),
      Offset(x1 + 3, 31)
    ]);
    final y1 = h * 0.58;
    ligne([Offset(w - 8, y1), Offset(w - 18, y1 + 4), Offset(w - 26, y1 - 2)]);
    final y2 = h * 0.32 + 2;
    ligne([Offset(9, y2), Offset(17, y2 + 7), Offset(23, y2 + 3)]);
    ligne([
      Offset(w - 22, h - 4),
      Offset(w - 30, h - 12),
      Offset(w - 38, h - 10)
    ]);

    final sang = Paint()
      ..color = (sombre ? const Color(0xFFA32222) : const Color(0xFF8A1515))
          .withValues(alpha: 0.9);
    // Éclaboussure en haut à droite, avec coulures depuis le bord.
    final xs = w * 0.8;
    canvas.drawOval(
        Rect.fromCenter(center: Offset(xs, 3), width: 22, height: 9), sang);
    for (final (dx, longueur, epaisseur) in [
      (-6.0, 24.0, 3.0),
      (0.0, 14.0, 4.0),
      (6.0, 9.0, 3.0),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(xs + dx - epaisseur / 2, 2, epaisseur, longueur),
          Radius.circular(epaisseur / 2),
        ),
        sang,
      );
      canvas.drawCircle(Offset(xs + dx, 2 + longueur), epaisseur * 0.85, sang);
    }
    for (final (o, r) in [
      (Offset(xs + 15, 12), 2.0),
      (Offset(xs - 15, 10), 1.6),
      (Offset(xs + 20, 5), 1.3),
      (Offset(xs - 22, 4), 1.0),
    ]) {
      canvas.drawCircle(o, r, sang);
    }
    // Éclaboussure en bas à gauche.
    for (final (o, r) in [
      (Offset(16, h - 12), 4.0),
      (Offset(26, h - 7), 2.0),
      (Offset(10, h - 24), 1.5),
      (Offset(30, h - 16), 1.2),
    ]) {
      canvas.drawCircle(o, r, sang);
    }
  }

  @override
  bool shouldRepaint(_PeintreCadre old) =>
      old.couleur != couleur ||
      old.sombre != sombre ||
      old.selectionnee != selectionnee ||
      old.compact != compact ||
      old.style != style ||
      old.classeId != classeId;
}

/// Dessin d'un motif dans un carré de 100 × 100 (mis à l'échelle). Les
/// trous (yeux du crâne, croix du cœur…) sont gommés dans un calque.
class _PeintreMotif extends CustomPainter {
  _PeintreMotif(this.motif, this.couleur);

  final MotifClasse motif;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final cote = math.min(size.width, size.height);
    if (cote <= 0) return;
    canvas.save();
    canvas.translate((size.width - cote) / 2, (size.height - cote) / 2);
    canvas.saveLayer(Rect.fromLTWH(0, 0, cote, cote), Paint());
    canvas.scale(cote / 100);
    _dessiner(canvas);
    canvas.restore();
    canvas.restore();
  }

  void _dessiner(Canvas canvas) {
    final plein = Paint()..color = couleur;
    Paint trait(double l) => Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = l
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final gomme = Paint()..blendMode = BlendMode.clear;
    Paint gommeTrait(double l) => Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = l
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    RRect rr(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));

    switch (motif) {
      case MotifClasse.labrys:
        canvas.drawLine(const Offset(50, 10), const Offset(50, 95), trait(6));
        for (final s in [-1.0, 1.0]) {
          double x(double v) => 50 + s * v;
          canvas.drawPath(
            Path()
              ..moveTo(x(3), 20)
              ..lineTo(x(3), 50)
              ..quadraticBezierTo(x(18), 44, x(36), 60)
              ..quadraticBezierTo(x(48), 35, x(36), 8)
              ..quadraticBezierTo(x(18), 26, x(3), 20)
              ..close(),
            plein,
          );
        }
        canvas.drawCircle(const Offset(50, 8), 5, plein);
      case MotifClasse.sang:
        canvas.drawPath(
          Path()
            ..moveTo(50, 8)
            ..quadraticBezierTo(70, 44, 72, 62)
            ..arcToPoint(const Offset(28, 62),
                radius: const Radius.circular(22))
            ..quadraticBezierTo(30, 44, 50, 8)
            ..close(),
          plein,
        );
        canvas.drawCircle(const Offset(81, 28), 5, plein);
        canvas.drawCircle(const Offset(18, 86), 4, plein);
        canvas.drawCircle(const Offset(86, 82), 3, plein);
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(50, 62), radius: 13),
          math.pi * 0.95,
          0.8,
          false,
          gommeTrait(3),
        );
      case MotifClasse.flute:
        canvas.save();
        canvas.translate(50, 50);
        canvas.rotate(-0.7);
        canvas.drawRRect(rr(-47, -6, 94, 12, 6), plein);
        for (final x in <double>[-12.0, 0, 12, 24]) {
          canvas.drawCircle(Offset(x, 0), 2.6, gomme);
        }
        canvas.drawRect(const Rect.fromLTWH(-34, -7, 3, 14), gomme);
        canvas.restore();
      case MotifClasse.baluchon:
        canvas.drawLine(const Offset(10, 94), const Offset(64, 32), trait(5));
        canvas.drawCircle(const Offset(70, 40), 22, plein);
        canvas.drawPath(
          Path()
            ..moveTo(62, 22)
            ..lineTo(52, 6)
            ..lineTo(70, 14)
            ..lineTo(86, 4)
            ..lineTo(80, 22)
            ..close(),
          plein,
        );
        for (final o in const [
          Offset(62, 38),
          Offset(76, 32),
          Offset(70, 50),
          Offset(82, 46),
          Offset(58, 52),
        ]) {
          canvas.drawCircle(o, 2.5, gomme);
        }
      case MotifClasse.casque:
        canvas.drawPath(
          Path()
            ..moveTo(22, 94)
            ..lineTo(22, 50)
            ..cubicTo(22, 14, 78, 14, 78, 50)
            ..lineTo(78, 94)
            ..quadraticBezierTo(50, 86, 22, 94)
            ..close(),
          plein,
        );
        canvas.drawRRect(rr(28, 50, 44, 7, 3), gomme);
        for (final y in <double>[68.0, 77]) {
          for (final x in <double>[40.0, 50, 60]) {
            canvas.drawCircle(Offset(x, y), 2, gomme);
          }
        }
        canvas.drawPath(
          Path()
            ..moveTo(50, 22)
            ..quadraticBezierTo(58, 0, 86, 4)
            ..quadraticBezierTo(68, 8, 58, 26)
            ..close(),
          plein,
        );
      case MotifClasse.ecusson:
        canvas.drawPath(
          Path()
            ..moveTo(16, 10)
            ..lineTo(84, 10)
            ..lineTo(84, 44)
            ..quadraticBezierTo(84, 80, 50, 96)
            ..quadraticBezierTo(16, 80, 16, 44)
            ..close(),
          plein,
        );
        canvas.drawPath(
          Path()
            ..moveTo(28, 64)
            ..lineTo(50, 42)
            ..lineTo(72, 64),
          gommeTrait(8),
        );
        canvas.drawCircle(const Offset(50, 25), 5, gomme);
      case MotifClasse.epee:
        canvas.drawPath(
          Path()
            ..moveTo(50, 3)
            ..lineTo(57, 15)
            ..lineTo(57, 64)
            ..lineTo(43, 64)
            ..lineTo(43, 15)
            ..close(),
          plein,
        );
        canvas.drawLine(
            const Offset(50, 18), const Offset(50, 58), gommeTrait(2));
        canvas.drawRRect(rr(27, 64, 46, 7, 3), plein);
        canvas.drawRect(const Rect.fromLTWH(46.5, 71, 7, 16), plein);
        canvas.drawCircle(const Offset(50, 91), 5, plein);
      case MotifClasse.arc:
        canvas.drawPath(
          Path()
            ..moveTo(36, 5)
            ..quadraticBezierTo(90, 50, 36, 95),
          trait(6),
        );
        canvas.drawLine(const Offset(36, 5), const Offset(36, 95), trait(1.5));
        canvas.drawLine(const Offset(10, 50), const Offset(84, 50), trait(3));
        canvas.drawPath(
          Path()
            ..moveTo(96, 50)
            ..lineTo(80, 41)
            ..lineTo(80, 59)
            ..close(),
          plein,
        );
        for (final x in <double>[10.0, 17]) {
          canvas.drawLine(Offset(x, 50), Offset(x - 6, 42), trait(2.5));
          canvas.drawLine(Offset(x, 50), Offset(x - 6, 58), trait(2.5));
        }
      case MotifClasse.pistolet:
        // Canon (vers la gauche), bouche évasée, chien et crosse courbée.
        canvas.drawRRect(rr(10, 27, 62, 16, 3), plein);
        canvas.drawRRect(rr(4, 23, 10, 24, 2), plein);
        canvas.drawPath(
          Path()
            ..moveTo(60, 30)
            ..lineTo(84, 30)
            ..quadraticBezierTo(96, 34, 94, 50)
            ..lineTo(90, 86)
            ..quadraticBezierTo(80, 94, 70, 88)
            ..lineTo(72, 56)
            ..quadraticBezierTo(70, 46, 62, 42)
            ..close(),
          plein,
        );
        // Chien (silex) au-dessus de la crosse.
        canvas.drawPath(
          Path()
            ..moveTo(70, 30)
            ..lineTo(66, 18)
            ..lineTo(74, 16)
            ..lineTo(78, 30)
            ..close(),
          plein,
        );
        // Pontet et détente.
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(62, 50), radius: 9),
          0,
          math.pi,
          false,
          trait(3),
        );
        canvas.drawLine(const Offset(62, 42), const Offset(60, 52), trait(2.5));
        // Fumée à la bouche du canon.
        canvas.drawCircle(const Offset(5, 18), 4, plein);
        canvas.drawCircle(const Offset(12, 12), 3, plein);
        canvas.drawCircle(const Offset(3, 8), 2.5, plein);
      case MotifClasse.bouclier:
        canvas.drawCircle(const Offset(50, 50), 43, plein);
        canvas.drawCircle(const Offset(50, 50), 33, gommeTrait(3));
        canvas.drawCircle(const Offset(50, 50), 12, gomme);
        canvas.drawCircle(const Offset(50, 50), 8, plein);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          canvas.drawCircle(
            Offset(50 + 38.5 * math.cos(a), 50 + 38.5 * math.sin(a)),
            2,
            gomme,
          );
        }
      case MotifClasse.marteau:
        canvas.save();
        canvas.translate(50, 50);
        canvas.rotate(-0.5);
        canvas.drawRRect(rr(-30, -42, 60, 24, 4), plein);
        canvas.drawRect(const Rect.fromLTWH(-30, -32, 60, 3), gomme);
        canvas.drawRRect(rr(-5, -18, 10, 64, 3), plein);
        canvas.restore();
      case MotifClasse.bombe:
        canvas.drawCircle(const Offset(44, 60), 32, plein);
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(44, 60), radius: 22),
          math.pi * 1.1,
          0.8,
          false,
          gommeTrait(4),
        );
        canvas.save();
        canvas.translate(64, 32);
        canvas.rotate(0.7);
        canvas.drawRRect(rr(-7, -6, 14, 12, 2), plein);
        canvas.restore();
        canvas.drawPath(
          Path()
            ..moveTo(68, 26)
            ..quadraticBezierTo(72, 12, 84, 14),
          trait(3),
        );
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          final c = const Offset(88, 12);
          canvas.drawLine(
            c + Offset(math.cos(a), math.sin(a)) * 3,
            c + Offset(math.cos(a), math.sin(a)) * 9,
            trait(2.2),
          );
        }
      case MotifClasse.poudre:
        canvas.drawPath(
          Path()
            ..moveTo(6, 92)
            ..quadraticBezierTo(30, 54, 50, 52)
            ..quadraticBezierTo(70, 54, 94, 92)
            ..close(),
          plein,
        );
        for (final (o, r) in const [
          (Offset(20, 40), 3.0),
          (Offset(34, 30), 2.5),
          (Offset(50, 20), 3.2),
          (Offset(66, 30), 2.5),
          (Offset(80, 40), 3.0),
          (Offset(42, 42), 2.0),
          (Offset(60, 44), 2.0),
          (Offset(50, 6), 1.8),
        ]) {
          canvas.drawCircle(o, r, plein);
        }
      case MotifClasse.hadoken:
        canvas.drawCircle(const Offset(64, 50), 20, plein);
        canvas.drawCircle(const Offset(64, 50), 29, trait(3));
        canvas.drawCircle(const Offset(64, 50), 8, gomme);
        canvas.drawLine(const Offset(6, 36), const Offset(36, 42), trait(5));
        canvas.drawLine(const Offset(2, 52), const Offset(32, 52), trait(5));
        canvas.drawLine(const Offset(8, 68), const Offset(36, 61), trait(5));
      case MotifClasse.lotus:
        canvas.drawOval(const Rect.fromLTWH(6, 82, 88, 12), plein);
        canvas.drawLine(
            const Offset(10, 82), const Offset(90, 82), gommeTrait(3));
        for (final (a, l) in const [
          (-1.05, 0.6),
          (1.05, 0.6),
          (-0.5, 0.85),
          (0.5, 0.85),
          (0.0, 1.0),
        ]) {
          canvas.save();
          canvas.translate(50, 80);
          canvas.rotate(a);
          final petale = Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(22 * l, -38 * l, 0, -72 * l)
            ..quadraticBezierTo(-22 * l, -38 * l, 0, 0)
            ..close();
          canvas.drawPath(petale, gommeTrait(4));
          canvas.drawPath(petale, plein);
          canvas.restore();
        }
      case MotifClasse.shuriken:
        final etoile = Path();
        for (var i = 0; i < 8; i++) {
          final a = -math.pi / 2 + i * math.pi / 4;
          final r = i.isEven ? 47.0 : 13.0;
          final o = Offset(50 + r * math.cos(a), 50 + r * math.sin(a));
          i == 0 ? etoile.moveTo(o.dx, o.dy) : etoile.lineTo(o.dx, o.dy);
        }
        canvas.drawPath(etoile..close(), plein);
        canvas.drawCircle(const Offset(50, 50), 6, gomme);
      case MotifClasse.crane:
        canvas.drawCircle(const Offset(50, 42), 34, plein);
        canvas.drawRRect(rr(30, 58, 40, 30, 6), plein);
        for (final x in <double>[36.0, 64]) {
          canvas.drawOval(
            Rect.fromCenter(center: Offset(x, 46), width: 18, height: 20),
            gomme,
          );
        }
        canvas.drawPath(
          Path()
            ..moveTo(50, 58)
            ..lineTo(45, 68)
            ..lineTo(55, 68)
            ..close(),
          gomme,
        );
        for (final x in <double>[40.0, 50, 60]) {
          canvas.drawLine(Offset(x, 76), Offset(x, 88), gommeTrait(2.5));
        }
      case MotifClasse.demon:
        canvas.drawOval(const Rect.fromLTWH(24, 32, 52, 60), plein);
        for (final s in [-1.0, 1.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(50 + s * 10, 38)
              ..quadraticBezierTo(50 + s * 30, 28, 50 + s * 42, 2)
              ..quadraticBezierTo(50 + s * 44, 34, 50 + s * 24, 52)
              ..close(),
            plein,
          );
          canvas.drawPath(
            Path()
              ..moveTo(50 + s * 5, 58)
              ..lineTo(50 + s * 20, 50)
              ..lineTo(50 + s * 17, 61)
              ..close(),
            gomme,
          );
        }
        canvas.drawPath(
          Path()
            ..moveTo(36, 76)
            ..lineTo(42, 72)
            ..lineTo(46, 78)
            ..lineTo(50, 72)
            ..lineTo(54, 78)
            ..lineTo(58, 72)
            ..lineTo(64, 76),
          gommeTrait(2.5),
        );
      case MotifClasse.vitalite:
        canvas.drawPath(
          Path()
            ..moveTo(50, 92)
            ..cubicTo(8, 62, 2, 32, 24, 16)
            ..cubicTo(38, 6, 50, 16, 50, 28)
            ..cubicTo(50, 16, 62, 6, 76, 16)
            ..cubicTo(98, 32, 92, 62, 50, 92)
            ..close(),
          plein,
        );
        canvas.drawRRect(rr(44, 30, 12, 38, 2), gomme);
        canvas.drawRRect(rr(31, 43, 38, 12, 2), gomme);
      case MotifClasse.piege:
        canvas.drawCircle(const Offset(50, 48), 38, trait(5));
        for (var i = 0; i < 12; i++) {
          final a = i * 2 * math.pi / 12;
          Offset pt(double r, double da) =>
              Offset(50 + r * math.cos(a + da), 48 + r * math.sin(a + da));
          canvas.drawPath(
            Path()
              ..moveTo(pt(37, -0.2).dx, pt(37, -0.2).dy)
              ..lineTo(pt(37, 0.2).dx, pt(37, 0.2).dy)
              ..lineTo(pt(24, 0).dx, pt(24, 0).dy)
              ..close(),
            plein,
          );
        }
        canvas.drawCircle(const Offset(50, 48), 8, plein);
        canvas.drawRRect(rr(30, 88, 40, 8, 2), plein);
      case MotifClasse.dague:
        canvas.drawPath(
          Path()
            ..moveTo(50, 5)
            ..quadraticBezierTo(63, 24, 58, 58)
            ..lineTo(42, 58)
            ..quadraticBezierTo(37, 24, 50, 5)
            ..close(),
          plein,
        );
        canvas.drawLine(
            const Offset(50, 16), const Offset(50, 52), gommeTrait(2));
        canvas.drawPath(
          Path()
            ..moveTo(26, 55)
            ..quadraticBezierTo(50, 67, 74, 55),
          trait(6),
        );
        canvas.drawRect(const Rect.fromLTWH(46.5, 62, 7, 21), plein);
        canvas.drawCircle(const Offset(50, 88), 5.5, plein);
      case MotifClasse.pioche:
        // Manche en diagonale, fer courbe à deux pointes.
        canvas.drawLine(const Offset(22, 94), const Offset(64, 30), trait(8));
        canvas.drawPath(
          Path()
            ..moveTo(10, 44)
            ..quadraticBezierTo(50, -2, 96, 34)
            ..lineTo(88, 40)
            ..quadraticBezierTo(52, 16, 18, 50)
            ..close(),
          plein,
        );
        canvas.drawRRect(rr(56, 18, 16, 18, 3), plein);
      case MotifClasse.plastron:
        // Cuirasse : épaules, encolure, arête centrale, pectoraux.
        canvas.drawPath(
          Path()
            ..moveTo(20, 18)
            ..lineTo(38, 10)
            ..quadraticBezierTo(50, 24, 62, 10)
            ..lineTo(80, 18)
            ..lineTo(86, 42)
            ..quadraticBezierTo(78, 62, 82, 88)
            ..quadraticBezierTo(50, 100, 18, 88)
            ..quadraticBezierTo(22, 62, 14, 42)
            ..close(),
          plein,
        );
        canvas.drawLine(
            const Offset(50, 30), const Offset(50, 90), gommeTrait(2.5));
        canvas.drawPath(
          Path()
            ..moveTo(26, 44)
            ..quadraticBezierTo(38, 56, 48, 46),
          gommeTrait(2.5),
        );
        canvas.drawPath(
          Path()
            ..moveTo(74, 44)
            ..quadraticBezierTo(62, 56, 52, 46),
          gommeTrait(2.5),
        );
        canvas.drawLine(
            const Offset(24, 74), const Offset(76, 74), gommeTrait(2));
      case MotifClasse.potion:
        // Fiole ronde : bouchon, col, liquide et bulles.
        canvas.drawRRect(rr(38, 2, 24, 9, 3), plein);
        canvas.drawRect(const Rect.fromLTWH(42, 12, 16, 18), plein);
        canvas.drawCircle(const Offset(50, 62), 32, plein);
        canvas.drawLine(
            const Offset(42, 30), const Offset(58, 30), gommeTrait(2));
        canvas.drawPath(
          Path()
            ..moveTo(22, 56)
            ..quadraticBezierTo(36, 48, 50, 56)
            ..quadraticBezierTo(64, 64, 78, 56),
          gommeTrait(3),
        );
        for (final (o, r) in const [
          (Offset(40, 72), 4.0),
          (Offset(58, 80), 3.0),
          (Offset(52, 68), 2.2),
        ]) {
          canvas.drawCircle(o, r, gomme);
        }
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(50, 62), radius: 24),
          math.pi * 1.1,
          0.7,
          false,
          gommeTrait(3),
        );
      case MotifClasse.bourse:
        canvas.drawPath(
          Path()
            ..moveTo(34, 40)
            ..cubicTo(6, 56, 10, 95, 50, 95)
            ..cubicTo(90, 95, 94, 56, 66, 40)
            ..close(),
          plein,
        );
        canvas.drawRRect(rr(31, 31, 38, 9, 4), plein);
        canvas.drawLine(
            const Offset(33, 43), const Offset(67, 43), gommeTrait(2));
        canvas.drawPath(
          Path()
            ..moveTo(36, 32)
            ..lineTo(27, 12)
            ..lineTo(42, 22)
            ..lineTo(50, 8)
            ..lineTo(58, 22)
            ..lineTo(73, 12)
            ..lineTo(64, 32)
            ..close(),
          plein,
        );
        canvas.drawCircle(const Offset(50, 69), 11, gommeTrait(3));
        canvas.drawLine(
            const Offset(50, 63), const Offset(50, 75), gommeTrait(2.5));
      default:
        // Motifs repris des icônes Material : rien à dessiner.
        break;
    }
  }

  @override
  bool shouldRepaint(_PeintreMotif old) =>
      old.motif != motif || old.couleur != couleur;
}
