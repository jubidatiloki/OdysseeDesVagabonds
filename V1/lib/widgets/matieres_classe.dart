import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Matières et effets d'ambiance des cadres de classe (charte, décision 26).
/// [dessinerMatiere] : texture fixe (bois griffé, acier brossé, écorce…) ;
/// [PeintreEffet] : effet animé (sang qui coule, feuilles qui tombent…),
/// figé à un instant choisi quand les animations sont coupées.

/// Couleur de fond de la matière (thème sombre) ; éclaircie vers le
/// parchemin en thème clair.
const Map<String, Color> kFondsMatieres = {
  'barbare': Color(0xFF3A271C), // bois
  'barde': Color(0xFF35222F), // tissu brodé
  'chevalier': Color(0xFF2B323B), // acier poli
  'druide': Color(0xFF25301F), // écorce
  'guerrier': Color(0xFF33302C), // fer cabossé
  'ingenieur': Color(0xFF382F1E), // laiton
  'magicien': Color(0xFF1B2140), // nuit étoilée
  'moine': Color(0xFF2E2922), // papier de riz
  'necromancien': Color(0xFF24222A), // pierre
  'pretre': Color(0xFF2F2D2A), // marbre
  'rodeur': Color(0xFF2A2A1D), // cuir et feuillage
  'voleur': Color(0xFF212125), // cuir sombre
};

const Color _parchemin = Color(0xFFF4EDE1);

Color fondMatiere(String classeId, Brightness b) {
  final c = kFondsMatieres[classeId] ?? const Color(0xFF26211D);
  // Teintes atténuées vers le fond des cartes : le texte reste lisible.
  return b == Brightness.dark
      ? Color.lerp(c, const Color(0xFF26211D), 0.4)!
      : Color.lerp(c, _parchemin, 0.88)!;
}

/// Guerrier : centre et rayon de la cible, abscisse des épées croisées
/// (au milieu de la carte, à l'écart du texte et du filigrane).
Offset cibleGuerrier(Size s) => Offset(s.width * 0.56, s.height / 2);
double rayonCibleGuerrier(Size s) => math.min(s.height * 0.3, 26);
double epeesGuerrier(Size s) => s.width * 0.76;

/// Instant montré quand les effets ne sont pas animés.
const double kInstantFige = 0.35;

class _Outils {
  _Outils(this.canvas, this.size, this.couleur, this.sombre, int graine)
      : hasard = math.Random(graine);

  final Canvas canvas;
  final Size size;
  final Color couleur;
  final bool sombre;
  final math.Random hasard;

  double get w => size.width;
  double get h => size.height;

  /// Marques claires (reflets) et foncées (creux), atténuées en thème clair.
  Color clair(double a) => Colors.white.withValues(alpha: sombre ? a : a * 1.6);
  Color fonce(double a) =>
      Colors.black.withValues(alpha: sombre ? a : a * 0.45);
  Color teinte(double a) => couleur.withValues(alpha: a.clamp(0, 1));

  double entre(double a, double b) => a + hasard.nextDouble() * (b - a);

  Paint trait(Color c, double l) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = l
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint plein(Color c) => Paint()..color = c;

  /// Couture / broderie : rectangle arrondi en pointillés.
  void pointilles(double marge, double tiret, double vide, Paint p) {
    final chemin = Path()
      ..addRRect(RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(marge),
        Radius.circular(16 - marge * 0.6),
      ));
    for (final m in chemin.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += tiret + vide) {
        canvas.drawPath(m.extractPath(d, math.min(d + tiret, m.length)), p);
      }
    }
  }

  /// Rivet : tête sombre et reflet.
  void rivet(Offset o, [double r = 2.6]) {
    canvas.drawCircle(o, r, plein(fonce(0.45)));
    canvas.drawCircle(o, r * 0.75, plein(teinte(0.35)));
    canvas.drawCircle(
        o + Offset(-r * 0.3, -r * 0.3), r * 0.35, plein(clair(0.4)));
  }

  /// Feuille en amande orientée selon [angle].
  void feuille(Offset o, double taille, double angle, Color c) {
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.rotate(angle);
    final p = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(taille * 0.5, -taille * 0.45, taille, 0)
      ..quadraticBezierTo(taille * 0.5, taille * 0.45, 0, 0)
      ..close();
    canvas.drawPath(p, plein(c));
    canvas.drawLine(
        Offset.zero, Offset(taille * 0.85, 0), trait(fonce(0.25), 0.6));
    canvas.restore();
  }

  /// Dessine [dessin] dans un repère centré en [c], tourné de [angle]
  /// (0 : orienté vers le haut).
  void _repere(Offset c, double angle, void Function() dessin) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    dessin();
    canvas.restore();
  }

  /// Empreinte de loup : coussinet, quatre doigts, deux griffes.
  void pattes(Offset c, double s, double angle, Color couleurTrace) {
    final p = plein(couleurTrace);
    _repere(c, angle, () {
      canvas.drawPath(
        Path()
          ..moveTo(-0.4 * s, 0.05 * s)
          ..quadraticBezierTo(-0.42 * s, 0.42 * s, 0, 0.4 * s)
          ..quadraticBezierTo(0.42 * s, 0.42 * s, 0.4 * s, 0.05 * s)
          ..quadraticBezierTo(0, -0.22 * s, -0.4 * s, 0.05 * s)
          ..close(),
        p,
      );
      for (final (x, y) in [
        (-0.4, -0.3),
        (-0.14, -0.55),
        (0.14, -0.55),
        (0.4, -0.3)
      ]) {
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(x * s, y * s), width: 0.22 * s, height: 0.3 * s),
          p,
        );
      }
      for (final x in [-0.14, 0.14]) {
        canvas.drawLine(Offset(x * s, -0.74 * s),
            Offset(x * s * 1.1, -0.86 * s), trait(couleurTrace, 0.07 * s));
      }
    });
  }

  /// Empreinte de sabot fendu (cerf).
  void sabot(Offset c, double s, double angle, Color couleurTrace) {
    _repere(c, angle, () {
      for (final sx in [-1.0, 1.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(sx * 0.06 * s, -0.5 * s)
            ..quadraticBezierTo(sx * 0.4 * s, -0.3 * s, sx * 0.3 * s, 0.35 * s)
            ..quadraticBezierTo(sx * 0.18 * s, 0.5 * s, sx * 0.06 * s, 0.38 * s)
            ..close(),
          plein(couleurTrace),
        );
      }
    });
  }

  /// Fleur de lotus posée sur sa feuille ([c] : base des pétales).
  void lotus(Offset c, double s, Color couleurFleur) {
    canvas.drawOval(
      Rect.fromCenter(
          center: c + Offset(0, 0.14 * s), width: 2.4 * s, height: 0.32 * s),
      plein(const Color(0xFF6B8F4A).withValues(alpha: 0.75)),
    );
    for (final (a, l, op) in [
      (-1.05, 0.62, 0.6),
      (1.05, 0.62, 0.6),
      (-0.5, 0.85, 0.8),
      (0.5, 0.85, 0.8),
      (0.0, 1.0, 1.0),
    ]) {
      _repere(c, a, () {
        canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(0.34 * s * l, -0.55 * s * l, 0, -1.05 * s * l)
            ..quadraticBezierTo(-0.34 * s * l, -0.55 * s * l, 0, 0)
            ..close(),
          plein(couleurFleur.withValues(alpha: couleurFleur.a * op)),
        );
      });
    }
  }

  /// Shuriken à quatre branches, tourné de [angle].
  void etoile(Offset c, double r, double angle, Color couleurLame) {
    _repere(c, angle, () {
      final p = Path();
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4;
        final rr = i.isEven ? r : r * 0.32;
        final pt = Offset(math.cos(a), math.sin(a)) * rr;
        i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(p..close(), plein(couleurLame));
      canvas.drawCircle(Offset.zero, r * 0.18, plein(fonce(0.6)));
    });
  }

  /// Flèche dont la pointe est en [pointe], dirigée selon [dir] (unitaire) ;
  /// [plantee] : pointe enfoncée (cachée).
  void fleche(Offset pointe, Offset dir, bool plantee, double opacite) {
    final queue = pointe - dir * 28;
    final perp = Offset(-dir.dy, dir.dx);
    canvas.drawLine(pointe, queue,
        trait(const Color(0xFF8A6A44).withValues(alpha: opacite), 2));
    if (!plantee) {
      canvas.drawPath(
        Path()
          ..moveTo(pointe.dx + dir.dx * 5, pointe.dy + dir.dy * 5)
          ..lineTo(pointe.dx + perp.dx * 3, pointe.dy + perp.dy * 3)
          ..lineTo(pointe.dx - perp.dx * 3, pointe.dy - perp.dy * 3)
          ..close(),
        plein(const Color(0xFFC9CDD4).withValues(alpha: opacite)),
      );
    }
    for (final d in [2.0, 6.0]) {
      final b = queue + dir * d;
      final c = teinte(opacite);
      canvas.drawLine(b, b - dir * 5 + perp * 4, trait(c, 1.6));
      canvas.drawLine(b, b - dir * 5 - perp * 4, trait(c, 1.6));
    }
  }

  /// Épée dont la poignée est en [garde], tournée de [angle] (0 : lame vers
  /// le haut).
  void epee(Offset garde, double angle, double echelle, bool sombre) {
    _repere(garde, angle, () {
      canvas.scale(echelle);
      final acier = sombre ? const Color(0xFFC9CDD4) : const Color(0xFF5C6370);
      canvas.drawPath(
        Path()
          ..moveTo(-2.6, -8)
          ..lineTo(-2.6, -46)
          ..lineTo(0, -53)
          ..lineTo(2.6, -46)
          ..lineTo(2.6, -8)
          ..close(),
        plein(acier),
      );
      canvas.drawLine(
          const Offset(0, -10), const Offset(0, -44), trait(fonce(0.35), 0.8));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-9, -9, 18, 4), const Radius.circular(1.5)),
        plein(const Color(0xFFD4A24C)),
      );
      canvas.drawRect(const Rect.fromLTWH(-1.8, -5, 3.6, 10),
          plein(const Color(0xFF6B5232)));
      canvas.drawCircle(
          const Offset(0, 7), 2.6, plein(const Color(0xFFD4A24C)));
    });
  }

  /// Engrenage (dents, moyeu évidé) tourné de [angle].
  void engrenage(Offset c, double r, double angle, Color couleurRoue) {
    const dents = 10;
    final p = Path();
    for (var i = 0; i < dents * 2; i++) {
      final a0 = angle + i * math.pi / dents;
      final a1 = a0 + math.pi / dents;
      final rr = i.isEven ? r : r * 0.8;
      final p0 = c + Offset(math.cos(a0), math.sin(a0)) * rr;
      final p1 = c + Offset(math.cos(a1), math.sin(a1)) * rr;
      i == 0 ? p.moveTo(p0.dx, p0.dy) : p.lineTo(p0.dx, p0.dy);
      p.lineTo(p1.dx, p1.dy);
    }
    p.close();
    p.addOval(Rect.fromCircle(center: c, radius: r * 0.32));
    p.fillType = PathFillType.evenOdd;
    canvas.drawPath(p, plein(couleurRoue));
    canvas.drawCircle(c, r * 0.55, trait(fonce(0.3), 1.2));
  }
}

/// Texture fixe de la matière de [classeId], dessinée dans le cadre.
void dessinerMatiere(
  Canvas canvas,
  Size size,
  String classeId,
  Color couleur,
  bool sombre,
) {
  final o = _Outils(canvas, size, couleur, sombre, classeId.length * 7919);
  final w = o.w;
  final h = o.h;
  switch (classeId) {
    case 'barbare':
      // Veines du bois, nœuds, trois griffures profondes.
      for (var i = 0; i < 9; i++) {
        final y0 = h * (i + 0.5) / 9;
        final p = Path()..moveTo(0, y0);
        for (var x = 0.0; x <= w; x += 8) {
          p.lineTo(
              x,
              y0 +
                  math.sin(x / w * 8 + i) * 3 +
                  math.sin(x / 37 + i * 2) * 1.5);
        }
        canvas.drawPath(
            p, o.trait(i.isEven ? o.fonce(0.28) : o.clair(0.05), 1));
      }
      for (final c in [Offset(w * 0.3, h * 0.64), Offset(w * 0.55, h * 0.22)]) {
        canvas.drawOval(Rect.fromCenter(center: c, width: 20, height: 8),
            o.trait(o.fonce(0.35), 1.2));
        canvas.drawOval(Rect.fromCenter(center: c, width: 8, height: 3),
            o.plein(o.fonce(0.35)));
      }
      for (var i = 0; i < 3; i++) {
        final a = Offset(w * 0.4 + i * 13, 14);
        final b = Offset(w * 0.4 + 30 + i * 13, h - 16);
        canvas.drawLine(a, b, o.trait(o.fonce(0.45), 3.5));
        canvas.drawLine(a + const Offset(1.8, 0), b + const Offset(1.8, 0),
            o.trait(o.clair(0.12), 1));
      }
    case 'barde':
      // Trame du tissu, broderie au point avant, portée de musique.
      final trame = o.trait(o.clair(0.035), 0.7);
      for (var d = -h; d < w; d += 6) {
        canvas.drawLine(Offset(d, 0), Offset(d + h, h), trame);
        canvas.drawLine(Offset(d + h, 0), Offset(d, h), trame);
      }
      o.pointilles(7, 5, 4, o.trait(o.teinte(0.75), 1.4));
      final y0 = h * 0.52;
      for (var k = 0; k < 5; k++) {
        final p = Path()..moveTo(w * 0.34, y0 + k * 4);
        for (var x = w * 0.34; x <= w - 12; x += 6) {
          p.lineTo(x, y0 + k * 4 + math.sin(x / 40) * 5);
        }
        canvas.drawPath(p, o.trait(o.teinte(0.28), 0.8));
      }
    case 'chevalier':
      // Acier brossé et rivets.
      for (var y = 0.0; y < h; y += 2) {
        canvas.drawLine(
          Offset(0, y),
          Offset(w, y),
          o.trait(
            o.hasard.nextBool()
                ? o.clair(o.entre(0.01, 0.05))
                : o.fonce(o.entre(0.02, 0.08)),
            1,
          ),
        );
      }
      final n = math.max(2, (w / 70).floor());
      for (var i = 0; i <= n; i++) {
        final x = 14 + (w - 28) * i / n;
        o.rivet(Offset(x, 10));
        o.rivet(Offset(x, h - 10));
      }
    case 'druide':
      // Fissures de l'écorce, lierre dans deux coins.
      for (var x = 6.0; x < w; x += 14) {
        var y = 0.0;
        while (y < h) {
          final l = o.entre(10, 30);
          final p = Path()..moveTo(x + o.entre(-2, 2), y);
          p.quadraticBezierTo(
              x + o.entre(-4, 4), y + l / 2, x + o.entre(-2, 2), y + l);
          canvas.drawPath(
              p, o.trait(o.fonce(sombre ? 0.25 : 0.16), o.entre(0.8, 1.8)));
          y += l + o.entre(3, 10);
        }
      }
      void lierre(Offset a, Offset c, Offset b, int feuilles) {
        canvas.drawPath(
          Path()
            ..moveTo(a.dx, a.dy)
            ..quadraticBezierTo(c.dx, c.dy, b.dx, b.dy),
          o.trait(const Color(0xFF5A4630).withValues(alpha: 0.9), 1.6),
        );
        for (var i = 1; i <= feuilles; i++) {
          final t = i / (feuilles + 1);
          final pt = Offset(
            (1 - t) * (1 - t) * a.dx + 2 * (1 - t) * t * c.dx + t * t * b.dx,
            (1 - t) * (1 - t) * a.dy + 2 * (1 - t) * t * c.dy + t * t * b.dy,
          );
          o.feuille(pt, 14, (i.isEven ? 1 : -1) * 0.9 + t * 2,
              i.isEven ? o.teinte(0.85) : const Color(0xFF4F8A47));
        }
      }
      lierre(Offset(0, h * 0.7), const Offset(14, 10), Offset(w * 0.3, 0), 7);
      lierre(
          Offset(w, h * 0.35), Offset(w - 16, h - 8), Offset(w * 0.72, h), 6);
    case 'guerrier':
      // Fer de bataille : bosses et rivets ; cible d'entraînement (les
      // flèches et les épées sont dans l'effet).
      for (var i = 0; i < 5; i++) {
        final c = Offset(o.entre(20, w - 20), o.entre(15, h - 15));
        final r = o.entre(12, 22);
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.3),
              colors: [o.clair(0.06), o.fonce(0.1), Colors.transparent],
              stops: const [0, 0.7, 1],
            ).createShader(Rect.fromCircle(center: c, radius: r)),
        );
      }
      final cible = cibleGuerrier(size);
      final rc = rayonCibleGuerrier(size);
      canvas.drawCircle(cible, rc + 2, o.plein(const Color(0xFF6B5232)));
      for (var k = 0; k < 4; k++) {
        canvas.drawCircle(
          cible,
          rc * (1 - k / 4),
          o.plein(k.isEven
              ? const Color(0xFFE8DCC4).withValues(alpha: sombre ? 0.75 : 0.95)
              : const Color(0xFFB0413A).withValues(alpha: 0.85)),
        );
      }
      canvas.drawCircle(cible, rc * 0.12, o.plein(const Color(0xFFD4A24C)));
      for (final c in [
        const Offset(10, 10),
        Offset(w - 10, 10),
        Offset(10, h - 10),
        Offset(w - 10, h - 10),
      ]) {
        o.rivet(c, 3);
      }
    case 'ingenieur':
      // Plaques de laiton rivetées (les engrenages tournent dans l'effet).
      for (final x in [w * 0.36, w * 0.7]) {
        canvas.drawLine(Offset(x, 0), Offset(x, h), o.trait(o.fonce(0.3), 1.4));
        canvas.drawLine(Offset(x + 1.5, 0), Offset(x + 1.5, h),
            o.trait(o.clair(0.06), 0.8));
        for (var y = 12.0; y < h - 6; y += 18) {
          o.rivet(Offset(x - 6, y), 1.8);
          o.rivet(Offset(x + 8, y), 1.8);
        }
      }
    case 'magicien':
      // Constellation (les étoiles et les runes scintillent dans l'effet).
      final pts = [
        Offset(w * 0.55, h * 0.3),
        Offset(w * 0.63, h * 0.5),
        Offset(w * 0.72, h * 0.38),
        Offset(w * 0.8, h * 0.62),
      ];
      for (var i = 0; i < pts.length - 1; i++) {
        canvas.drawLine(pts[i], pts[i + 1], o.trait(o.teinte(0.25), 0.8));
      }
    case 'moine':
      // Paravent shōji (papier de riz, croisillons de bois), bambous,
      // lotus et bâton d'encens (la fumée et le shuriken dans l'effet).
      for (var i = 0; i < 80; i++) {
        final a = Offset(o.entre(0, w), o.entre(0, h));
        final ang = o.entre(0, math.pi);
        canvas.drawLine(
            a,
            a + Offset(math.cos(ang), math.sin(ang)) * o.entre(5, 14),
            o.trait(o.clair(0.05), 0.7));
      }
      final bois = o.trait(
          const Color(0xFF6B5232).withValues(alpha: sombre ? 0.45 : 0.35), 2);
      for (var k = 1; k < 6; k++) {
        canvas.drawLine(Offset(w * k / 6, 0), Offset(w * k / 6, h), bois);
      }
      for (final y in [h / 3, h * 2 / 3]) {
        canvas.drawLine(Offset(0, y), Offset(w, y), bois);
      }
      for (final (x, l) in [(w - 14, 1.0), (w - 27, 0.8)]) {
        final haut = h * (1 - l);
        canvas.drawLine(Offset(x, h + 2), Offset(x, haut - 2),
            o.trait(const Color(0xFF7FA35A).withValues(alpha: 0.8), 5));
        for (var y = h - 18; y > haut; y -= 20) {
          canvas.drawLine(Offset(x - 3.5, y), Offset(x + 3.5, y),
              o.trait(const Color(0xFF4F6E36), 1.6));
        }
        o.feuille(Offset(x, haut + 14), 16, -2.4,
            const Color(0xFF7FA35A).withValues(alpha: 0.8));
        o.feuille(Offset(x, haut + 26), 13, -0.6,
            const Color(0xFF6B8F4A).withValues(alpha: 0.8));
      }
      o.lotus(Offset(w * 0.5, h - 9), 21, o.teinte(0.7));
      final pied = Offset(w * 0.5 + 26, h - 8);
      canvas.drawLine(pied, pied + const Offset(7, -24),
          o.trait(const Color(0xFF8A5A3A), 1.6));
      canvas.drawCircle(
          pied + const Offset(7, -24), 1.5, o.plein(const Color(0xFFFF8A3D)));
    case 'necromancien':
      // Blocs de pierre, fissures, os croisés.
      const hauteur = 22.0;
      for (var y = hauteur, rang = 0; y < h; y += hauteur, rang++) {
        canvas.drawLine(Offset(0, y), Offset(w, y), o.trait(o.fonce(0.4), 1.2));
        canvas.drawLine(Offset(0, y + 1.2), Offset(w, y + 1.2),
            o.trait(o.clair(0.04), 0.8));
      }
      for (var y = 0.0, rang = 0; y < h; y += hauteur, rang++) {
        for (var x = rang.isEven ? 40.0 : 15.0; x < w; x += 52) {
          canvas.drawLine(Offset(x, y), Offset(x, math.min(y + hauteur, h)),
              o.trait(o.fonce(0.4), 1.2));
        }
      }
      for (var k = 0; k < 2; k++) {
        var p = Offset(o.entre(w * 0.2, w * 0.6), 0);
        final chemin = Path()..moveTo(p.dx, p.dy);
        while (p.dy < h * 0.7) {
          p += Offset(o.entre(-8, 8), o.entre(6, 12));
          chemin.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(chemin, o.trait(o.fonce(0.55), 1));
      }
      for (final a in [0.6, -0.6]) {
        canvas.save();
        canvas.translate(22, h - 18);
        canvas.rotate(a);
        canvas.drawLine(const Offset(-12, 0), const Offset(12, 0),
            o.trait(o.teinte(0.45), 3));
        for (final x in <double>[-12, 12]) {
          canvas.drawCircle(Offset(x, -2), 2.4, o.plein(o.teinte(0.45)));
          canvas.drawCircle(Offset(x, 2), 2.4, o.plein(o.teinte(0.45)));
        }
        canvas.restore();
      }
    case 'pretre':
      // Veines du marbre, double filet d'or, fleurons aux coins.
      for (var i = 0; i < 5; i++) {
        final y = o.entre(0, h);
        final p = Path()
          ..moveTo(-10, y)
          ..cubicTo(w * 0.3, y + o.entre(-30, 30), w * 0.6,
              y + o.entre(-30, 30), w + 10, y + o.entre(-20, 20));
        canvas.drawPath(
            p, o.trait(o.clair(o.entre(0.05, 0.11)), o.entre(0.6, 1.4)));
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            (Offset.zero & size).deflate(8), const Radius.circular(10)),
        o.trait(o.teinte(0.45), 0.7),
      );
      for (final (sx, sy) in [
        (1.0, 1.0),
        (-1.0, 1.0),
        (1.0, -1.0),
        (-1.0, -1.0)
      ]) {
        final c = Offset(sx > 0 ? 16 : w - 16, sy > 0 ? 16 : h - 16);
        final base = math.atan2(sy, sx);
        for (final a in [-0.6, 0.0, 0.6]) {
          canvas.save();
          canvas.translate(c.dx, c.dy);
          canvas.rotate(base + a);
          canvas.drawOval(
              const Rect.fromLTWH(0, -1.6, 7, 3.2), o.plein(o.teinte(0.6)));
          canvas.restore();
        }
      }
    case 'rodeur':
      // Grain du cuir, couture, piste de cerf (sabots) en haut.
      for (var i = 0; i < 140; i++) {
        canvas.drawCircle(Offset(o.entre(0, w), o.entre(0, h)), o.entre(0.4, 1),
            o.plein(o.hasard.nextBool() ? o.fonce(0.2) : o.clair(0.04)));
      }
      o.pointilles(7, 3, 3,
          o.trait(const Color(0xFFC8A46A).withValues(alpha: 0.55), 1.2));
      for (var i = 0; i < 6; i++) {
        final x = w * 0.32 + i * w * 0.1;
        o.sabot(Offset(x, h * 0.26 + (i.isEven ? -5 : 5)), 17, math.pi / 2,
            o.teinte(0.3));
      }
    case 'voleur':
      // Cuir sombre grainé et cousu.
      for (var i = 0; i < 160; i++) {
        canvas.drawCircle(
            Offset(o.entre(0, w), o.entre(0, h)),
            o.entre(0.4, 0.9),
            o.plein(o.hasard.nextBool() ? o.fonce(0.25) : o.clair(0.03)));
      }
      o.pointilles(7, 4, 3, o.trait(o.teinte(0.5), 1.2));
  }
}

/// Effet d'ambiance animé de [classeId] ; `repaint` : l'horloge des cadres.
class PeintreEffet extends CustomPainter {
  PeintreEffet({
    required this.classeId,
    required this.couleur,
    required this.sombre,
    this.horloge,
  }) : super(repaint: horloge);

  final String classeId;
  final Color couleur;
  final bool sombre;

  /// Avancement de l'animation (0 → 1, en boucle) ; `null` : figé.
  final Animation<double>? horloge;

  @override
  void paint(Canvas canvas, Size size) {
    final t = horloge?.value ?? kInstantFige;
    final o = _Outils(canvas, size, couleur, sombre, classeId.length * 104729);
    final w = o.w;
    final h = o.h;
    double phase(int i, int n) => (t + i / n) % 1;

    switch (classeId) {
      case 'barbare':
        // Sang qui coule du bord, gouttes qui tombent.
        final sang =
            (sombre ? const Color(0xFFA32222) : const Color(0xFF8A1515));
        for (final (i, x, l) in [
          (0, w * 0.6, 0.45),
          (1, w * 0.64, 0.3),
          (2, w * 0.83, 0.38)
        ]) {
          final p = phase(i, 3);
          final longueur = h * l * math.min(1, p / 0.7);
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x - 1.5, 0, 3, longueur + 2),
                const Radius.circular(1.5)),
            o.plein(sang.withValues(alpha: 0.85)),
          );
          canvas.drawCircle(Offset(x, longueur + 1), 2.8,
              o.plein(sang.withValues(alpha: 0.9)));
          if (p > 0.7) {
            final q = (p - 0.7) / 0.3;
            canvas.drawCircle(
              Offset(x, h * l + q * h * (1 - l)),
              2.4,
              o.plein(sang.withValues(alpha: 0.9 * (1 - q))),
            );
          }
        }
      case 'barde':
        // Notes qui s'envolent de la portée.
        for (var i = 0; i < 4; i++) {
          final p = phase(i, 4);
          final x = w * 0.38 + p * w * 0.52;
          final y = h * 0.6 - p * h * 0.45 + math.sin(p * 6) * 4;
          final c = o.teinte(0.85 * math.sin(p * math.pi));
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(-0.35);
          canvas.drawOval(const Rect.fromLTWH(-4, -3, 8, 6), o.plein(c));
          canvas.restore();
          canvas.drawLine(
              Offset(x + 3.2, y - 1), Offset(x + 3.2, y - 14), o.trait(c, 1.3));
          canvas.drawPath(
            Path()
              ..moveTo(x + 3.2, y - 14)
              ..quadraticBezierTo(x + 9, y - 11, x + 7, y - 6),
            o.trait(c, 1.3),
          );
        }
      case 'chevalier':
        // Reflet qui passe sur l'acier (puis une pause).
        if (t < 0.45) {
          final x = -w * 0.2 + (t / 0.45) * w * 1.4;
          canvas.save();
          canvas.translate(x, h / 2);
          canvas.rotate(0.4);
          final bande =
              Rect.fromCenter(center: Offset.zero, width: 46, height: h * 3);
          canvas.drawRect(
            bande,
            Paint()
              ..shader = LinearGradient(colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: sombre ? 0.13 : 0.35),
                Colors.transparent,
              ]).createShader(bande),
          );
          canvas.restore();
        }
      case 'druide':
        // Feuilles qui tombent en tournoyant.
        for (var i = 0; i < 5; i++) {
          final p = phase(i, 5);
          final x0 = w * (0.15 + 0.17 * i);
          final pos = Offset(
              x0 + math.sin(p * 2 * math.pi + i) * 18, -18 + p * (h + 36));
          o.feuille(
            pos,
            17,
            p * 4 * math.pi * (i.isEven ? 1 : -1),
            (i.isEven ? o.couleur : const Color(0xFF8DA45A))
                .withValues(alpha: 0.8 * math.sin(p * math.pi)),
          );
        }
      case 'guerrier':
        // D'un côté, trois flèches tirées se plantent dans la cible ; de
        // l'autre, deux épées se lèvent et se croisent (étincelles).
        final cible = cibleGuerrier(size);
        final rc = rayonCibleGuerrier(size);
        final disparition = t < 0.9 ? 1.0 : 1 - (t - 0.9) / 0.1;
        for (final (depart, impact) in [
          (0.04, Offset(-rc * 0.2, -rc * 0.3)),
          (0.13, Offset(rc * 0.35, rc * 0.1)),
          (0.22, Offset(-rc * 0.05, rc * 0.4)),
        ]) {
          final q = (t - depart) / 0.07;
          if (q < 0) continue;
          final arrivee = cible + impact;
          final origine = arrivee - Offset(w * 0.22, -h * 0.12);
          final pointe = Offset.lerp(origine, arrivee, q.clamp(0.0, 1.0))!;
          final dir = (arrivee - origine) / (arrivee - origine).distance;
          o.fleche(pointe, dir, q >= 1, disparition * (q < 1 ? 0.9 : 1));
        }
        // Épées : levée (0,26 → 0,32), croisées (→ 0,5), retour (→ 0,6).
        double croise;
        if (t < 0.26 || t > 0.6) {
          croise = 0;
        } else if (t < 0.32) {
          croise = Curves.easeIn.transform((t - 0.26) / 0.06);
        } else if (t < 0.5) {
          croise = 1;
        } else {
          croise = 1 - Curves.easeOut.transform((t - 0.5) / 0.1);
        }
        final echelle = math.min(1.0, h / 110);
        final centre = Offset(epeesGuerrier(size), h - 12 * echelle);
        final angle = 0.12 + 0.5 * croise;
        for (final sens in [-1.0, 1.0]) {
          o.epee(centre + Offset(sens * 18 * echelle, 0), -sens * angle,
              echelle, sombre);
        }
        final q = (t - 0.32) / 0.08;
        if (q >= 0 && q <= 1) {
          final choc = centre + Offset(0, -18 / math.tan(0.62) * echelle);
          canvas.drawCircle(
            choc,
            3 + 8 * q,
            Paint()
              ..color =
                  const Color(0xFFFFE2A8).withValues(alpha: 0.85 * (1 - q))
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          );
          final etincelles = math.Random(3);
          for (var k = 0; k < 10; k++) {
            final a = -math.pi * (0.1 + 0.8 * etincelles.nextDouble());
            final d = (6 + 22 * etincelles.nextDouble()) * q;
            final dir = Offset(math.cos(a), math.sin(a));
            canvas.drawLine(
              choc + dir * d,
              choc + dir * (d + 4),
              o.trait(const Color(0xFFFFB347).withValues(alpha: 1 - q), 1.4),
            );
          }
        }
      case 'ingenieur':
        // Engrenages qui tournent, fumée qui monte.
        final roue = o.teinte(0.4);
        o.engrenage(Offset(w - 20, 14), 26, t * 2 * math.pi, roue);
        o.engrenage(Offset(w - 58, 30), 16, -t * 2 * math.pi * 1.6 + 0.2, roue);
        o.engrenage(Offset(16, h - 8), 20, -t * 2 * math.pi, roue);
        for (var i = 0; i < 4; i++) {
          final p = phase(i, 4);
          canvas.drawCircle(
            Offset(w - 40 + math.sin(p * 5 + i) * 8, 30 - p * 40 + 20),
            4 + p * 12,
            Paint()
              ..color = (sombre ? Colors.white : Colors.black)
                  .withValues(alpha: 0.12 * (1 - p))
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          );
        }
      case 'magicien':
        // Étoiles qui scintillent, runes qui s'allument tour à tour.
        final etoiles = math.Random(11);
        for (var i = 0; i < 42; i++) {
          final pos = Offset(
              etoiles.nextDouble() * w, 14 + etoiles.nextDouble() * (h - 28));
          final r = 0.5 + etoiles.nextDouble() * 1.2;
          final a = 0.3 +
              0.65 *
                  (0.5 +
                      0.5 *
                          math.sin(
                              2 * math.pi * (t * 2 + etoiles.nextDouble())));
          canvas.drawCircle(
              pos,
              r,
              o.plein((sombre ? const Color(0xFFD8E2FF) : couleur)
                  .withValues(alpha: a)));
        }
        final runes = math.Random(5);
        final n = ((w - 24) / 12).floor();
        for (final y in [4.0, h - 13]) {
          for (var i = 0; i < n; i++) {
            final x = 12 + i * 12.0;
            final lueur = math.max(0.0, 1 - ((i / n - t).abs() * 6));
            final p = o.trait(o.teinte(0.35 + 0.6 * lueur), 1 + lueur * 0.6);
            canvas.drawLine(Offset(x, y), Offset(x, y + 9), p);
            final branches = 1 + runes.nextInt(2);
            for (var b = 0; b < branches; b++) {
              final y0 = y + runes.nextInt(3) * 3.0;
              final dx = runes.nextBool() ? 4.0 : -4.0;
              canvas.drawLine(Offset(x, y0), Offset(x + dx, y0 + 3), p);
            }
          }
        }
      case 'moine':
        // Fumée d'encens qui monte en volutes.
        final bout = Offset(w * 0.5 + 33, h - 32);
        for (var k = 0; k < 3; k++) {
          final p = Path()..moveTo(bout.dx, bout.dy);
          for (var y = 0.0; y < h * 0.85; y += 3) {
            final ondule =
                math.sin(y / 9 - t * 2 * math.pi * 2 + k * 2) * (2 + y * 0.12);
            p.lineTo(bout.dx + ondule + k * 2, bout.dy - y);
          }
          canvas.drawPath(
            p,
            Paint()
              ..shader = LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  (sombre ? Colors.white : Colors.black)
                      .withValues(alpha: sombre ? 0.35 : 0.2),
                  Colors.transparent,
                ],
              ).createShader(Rect.fromLTWH(bout.dx - 20, bout.dy - h, 40, h))
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4 - k * 0.3,
          );
        }
        // Un shuriken file en tournant et se plante dans le bois.
        if (t > 0.55) {
          final cible = Offset(w * 4 / 6, h / 3);
          final q = ((t - 0.55) / 0.12).clamp(0.0, 1.0);
          final pos = Offset.lerp(Offset(-12, h * 0.15), cible, q)!;
          o.etoile(
            pos,
            10,
            q * 6 * math.pi,
            (sombre ? const Color(0xFFCFD3DA) : const Color(0xFF4A4E57))
                .withValues(alpha: t > 0.95 ? (1 - t) / 0.05 : 0.95),
          );
        }
      case 'necromancien':
        // Brume verte qui dérive.
        for (var i = 0; i < 4; i++) {
          final x = ((i * 0.3 + t) % 1.3 - 0.15) * w;
          final y = i.isEven ? h * 0.8 : h * 0.25;
          canvas.drawOval(
            Rect.fromCenter(center: Offset(x, y), width: 120, height: 34),
            Paint()
              ..color = const Color(0xFF7BC4A0).withValues(
                  alpha: (sombre ? 0.22 : 0.2) *
                      (0.6 + 0.4 * math.sin((t + i / 4) * 2 * math.pi)))
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
          );
        }
      case 'pretre':
        // Halo de lumière et rayons qui oscillent.
        final centre = Offset(w / 2, -12);
        final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
        canvas.drawCircle(
          centre,
          h * 1.1,
          Paint()
            ..shader = RadialGradient(colors: [
              o.teinte(0.16 + 0.08 * pulse),
              Colors.transparent,
            ]).createShader(Rect.fromCircle(center: centre, radius: h * 1.1)),
        );
        for (var i = 0; i < 9; i++) {
          final a =
              math.pi / 2 + (i - 4) * 0.28 + math.sin(t * 2 * math.pi) * 0.05;
          canvas.drawLine(
            centre,
            centre + Offset(math.cos(a), math.sin(a)) * h * 1.3,
            Paint()
              ..color = o.teinte(0.06 + 0.04 * pulse)
              ..strokeWidth = 7
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
        }
      case 'rodeur':
        // Piste de loup : les empreintes apparaissent une à une, puis
        // s'effacent en fin de cycle.
        const pas = 9;
        final fin = t < 0.85 ? 1.0 : 1 - (t - 0.85) / 0.15;
        double yDe(double x) =>
            h * 0.68 + math.sin(x / w * 2 * math.pi) * h * 0.1;
        for (var i = 0; i < pas; i++) {
          final x = w * 0.22 + i * (w * 0.7) / (pas - 1);
          final y = yDe(x);
          final pente = math.atan2(yDe(x + 1) - y, 1);
          final cote = i.isEven ? -6.0 : 6.0;
          final pos =
              Offset(x - math.sin(pente) * cote, y + math.cos(pente) * cote);
          final apparition = ((t - i / pas * 0.7) / 0.05).clamp(0.0, 1.0);
          final a = apparition * fin;
          if (a <= 0) continue;
          o.pattes(pos, 21, pente + math.pi / 2, o.teinte(0.75 * a));
        }
      case 'voleur':
        // L'ombre gagne les bords, une pièce brille de temps en temps.
        final r = Offset.zero & size;
        canvas.drawRect(
          r,
          Paint()
            ..shader = RadialGradient(
              radius: 1.1,
              colors: [
                Colors.transparent,
                Colors.black.withValues(
                    alpha: (sombre ? 0.3 : 0.06) +
                        (sombre ? 0.12 : 0.04) * math.sin(t * 2 * math.pi)),
              ],
              stops: const [0.55, 1],
            ).createShader(r),
        );
        final piece = Offset(w * 0.62, h - 18);
        canvas.drawCircle(
            piece, 6, o.plein(const Color(0xFFD4A24C).withValues(alpha: 0.85)));
        canvas.drawCircle(piece, 4,
            o.trait(const Color(0xFF8A6420).withValues(alpha: 0.8), 1));
        final eclat = t < 0.15 ? math.sin(t / 0.15 * math.pi) : 0.0;
        if (eclat > 0) {
          final c = piece + const Offset(3, -3);
          final p = o.plein(Colors.white.withValues(alpha: 0.9 * eclat));
          final l = 7 * eclat;
          canvas.drawPath(
            Path()
              ..moveTo(c.dx, c.dy - l)
              ..lineTo(c.dx + 1.2, c.dy - 1.2)
              ..lineTo(c.dx + l, c.dy)
              ..lineTo(c.dx + 1.2, c.dy + 1.2)
              ..lineTo(c.dx, c.dy + l)
              ..lineTo(c.dx - 1.2, c.dy + 1.2)
              ..lineTo(c.dx - l, c.dy)
              ..lineTo(c.dx - 1.2, c.dy - 1.2)
              ..close(),
            p,
          );
        }
    }
  }

  @override
  bool shouldRepaint(PeintreEffet old) =>
      old.classeId != classeId ||
      old.couleur != couleur ||
      old.sombre != sombre ||
      old.horloge != horloge;
}
