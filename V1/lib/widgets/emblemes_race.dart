import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Emblèmes de race dessinés dans le cercle des cartes de personnage
/// (charte, décision 28), à la place de l'initiale : humain couronne, nain
/// barbe tressée et casque à cornes, gnome bonnet pointu à engrenage, elfe
/// sylvain tête d'elfe devant un arbre, haut-elfe tête d'elfe sous les
/// étoiles, demi-elfe visage aux deux oreilles, demi-orque mâchoire à
/// crocs, draconien tête de dragon.

const Set<String> kRacesAvecEmbleme = {
  'humain',
  'nain',
  'gnome',
  'elfe-sylvain',
  'haut-elfe',
  'demi-elfe',
  'demi-orque',
  'draconien',
};

/// Couleurs du fond du cercle selon la race ; draconien : selon l'élément
/// choisi (neutre sans élément, ailes vestigiales). Demi-elfe : deux
/// moitiés (forêt et parchemin).
List<Color> couleursFondRace(String? raceId, {String? element}) =>
    switch (raceId) {
      'humain' => const [Color(0xFFB89A6A)],
      'nain' => const [Color(0xFF8A7A66)],
      'gnome' => const [Color(0xFF6F8F4E)],
      'elfe-sylvain' => const [Color(0xFF3F7A3A)],
      'haut-elfe' => const [Color(0xFF8FA8C8)],
      'demi-elfe' => const [Color(0xFF3F7A3A), Color(0xFFB89A6A)],
      'demi-orque' => const [Color(0xFF6F7F62)],
      'draconien' => [
          switch (element) {
            'feu' => const Color(0xFFC0463E),
            'glace' => const Color(0xFF7FC4E0),
            'foudre' => const Color(0xFFE0C040),
            _ => const Color(0xFF7A7A80),
          },
        ],
      _ => const [],
    };

/// Emblème de [raceId] dans un carré de [taille].
class EmblemeRace extends StatelessWidget {
  const EmblemeRace({
    super.key,
    required this.raceId,
    required this.couleur,
    this.taille = 40,
  });

  final String raceId;
  final Color couleur;
  final double taille;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: taille,
        child: CustomPaint(painter: _PeintreRace(raceId, couleur)),
      );
}

class _PeintreRace extends CustomPainter {
  _PeintreRace(this.raceId, this.couleur);

  final String raceId;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final cote = math.min(size.width, size.height);
    if (cote <= 0) return;
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.translate((size.width - cote) / 2, (size.height - cote) / 2);
    canvas.scale(cote / 100);
    _dessiner(canvas);
    canvas.restore();
  }

  void _dessiner(Canvas canvas) {
    final plein = Paint()..color = couleur;
    final gomme = Paint()..blendMode = BlendMode.clear;
    Paint gommeTrait(double l) => Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = l
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    void ovale(Offset c, double w, double h, double angle, Paint p) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(angle);
      canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: w, height: h), p);
      canvas.restore();
    }

    /// Tête d'elfe de face centrée en (50, [cy]) : oreilles pointues, longs
    /// cheveux, yeux en amande. Chaque partie est détourée (gommée) pour se
    /// détacher des autres et du décor derrière.
    void tete(double cy) {
      for (final s in [-1.0, 1.0]) {
        final oreille = Path()
          ..moveTo(50 + s * 14, cy - 4)
          ..lineTo(50 + s * 38, cy - 24)
          ..lineTo(50 + s * 16, cy + 10)
          ..close();
        canvas.drawPath(oreille, gommeTrait(4));
        canvas.drawPath(oreille, plein);
      }
      final visage =
          Rect.fromCenter(center: Offset(50, cy + 4), width: 32, height: 42);
      canvas.drawOval(visage, gommeTrait(4));
      canvas.drawOval(visage, plein);
      final cheveux = Path()
        ..moveTo(32, cy + 2)
        ..cubicTo(28, cy - 32, 72, cy - 32, 68, cy + 2)
        ..lineTo(71, cy + 34)
        ..quadraticBezierTo(66, cy + 38, 61, cy + 34)
        ..lineTo(62, cy - 6)
        ..quadraticBezierTo(50, cy - 16, 38, cy - 6)
        ..lineTo(39, cy + 34)
        ..quadraticBezierTo(34, cy + 38, 29, cy + 34)
        ..close();
      canvas.drawPath(cheveux, gommeTrait(3.5));
      canvas.drawPath(cheveux, plein);
      for (final x in [44.0, 56.0]) {
        ovale(Offset(x, cy + 4), 7, 3.6, x < 50 ? 0.25 : -0.25, gomme);
      }
      canvas.drawArc(
          Rect.fromCenter(center: Offset(50, cy + 13), width: 10, height: 6),
          0.3,
          math.pi - 0.6,
          false,
          gommeTrait(2));
    }

    /// Étoile à [n] branches.
    void etoile(Offset c, double r, int n, double creux) {
      final p = Path();
      for (var i = 0; i < n * 2; i++) {
        final a = -math.pi / 2 + i * math.pi / n;
        final rr = i.isEven ? r : r * creux;
        final pt = c + Offset(math.cos(a), math.sin(a)) * rr;
        i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(p..close(), plein);
    }

    switch (raceId) {
      case 'humain':
        // Couronne : pointes à perles, bandeau serti de pierres.
        canvas.drawPath(
          Path()
            ..moveTo(16, 70)
            ..lineTo(14, 30)
            ..lineTo(33, 50)
            ..lineTo(50, 20)
            ..lineTo(67, 50)
            ..lineTo(86, 30)
            ..lineTo(84, 70)
            ..close(),
          plein,
        );
        for (final c in const [
          Offset(14, 26),
          Offset(50, 16),
          Offset(86, 26)
        ]) {
          canvas.drawCircle(c, 6, plein);
        }
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(14, 68, 72, 18), const Radius.circular(3)),
          plein,
        );
        canvas.drawLine(
            const Offset(16, 68), const Offset(84, 68), gommeTrait(2.5));
        for (final x in <double>[30, 50, 70]) {
          canvas.drawCircle(Offset(x, 77), 4.5, gomme);
        }
        canvas.drawPath(
          Path()
            ..moveTo(50, 36)
            ..lineTo(56, 46)
            ..lineTo(50, 56)
            ..lineTo(44, 46)
            ..close(),
          gomme,
        );
      case 'nain':
        // Casque à cornes et barbe tressée.
        canvas.drawPath(
          Path()
            ..moveTo(24, 48)
            ..cubicTo(24, 14, 76, 14, 76, 48)
            ..close(),
          plein,
        );
        for (final s in [-1.0, 1.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(50 + s * 22, 38)
              ..quadraticBezierTo(50 + s * 42, 32, 50 + s * 44, 6)
              ..quadraticBezierTo(50 + s * 34, 30, 50 + s * 24, 28)
              ..close(),
            plein,
          );
        }
        canvas.drawRect(const Rect.fromLTWH(20, 44, 60, 9), plein);
        for (final x in <double>[30, 50, 70]) {
          canvas.drawCircle(Offset(x, 48.5), 2.2, gomme);
        }
        canvas.drawPath(
          Path()
            ..moveTo(24, 58)
            ..quadraticBezierTo(28, 86, 50, 97)
            ..quadraticBezierTo(72, 86, 76, 58)
            ..quadraticBezierTo(50, 68, 24, 58)
            ..close(),
          plein,
        );
        canvas.drawPath(
          Path()
            ..moveTo(32, 62)
            ..quadraticBezierTo(50, 72, 68, 62),
          gommeTrait(3),
        );
        for (var y = 72.0; y < 92; y += 6) {
          canvas.drawPath(
            Path()
              ..moveTo(44, y)
              ..lineTo(50, y + 4)
              ..lineTo(56, y),
            gommeTrait(2.2),
          );
        }
      case 'gnome':
        // Bonnet pointu orné d'un engrenage, gros nez, petite barbe.
        canvas.drawPath(
          Path()
            ..moveTo(16, 60)
            ..quadraticBezierTo(36, 40, 58, 4)
            ..quadraticBezierTo(62, 34, 84, 60)
            ..close(),
          plein,
        );
        canvas.drawOval(const Rect.fromLTWH(10, 54, 80, 13), plein);
        final c = const Offset(52, 38);
        final dents = Path();
        for (var i = 0; i < 16; i++) {
          final a = i * math.pi / 8;
          final r = i.isEven ? 10.0 : 7.5;
          final p = c + Offset(math.cos(a), math.sin(a)) * r;
          i == 0 ? dents.moveTo(p.dx, p.dy) : dents.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(dents..close(), gomme);
        canvas.drawCircle(c, 3.5, plein);
        canvas.drawPath(
          Path()
            ..moveTo(28, 70)
            ..quadraticBezierTo(50, 104, 72, 70)
            ..close(),
          plein,
        );
        canvas.drawCircle(const Offset(50, 74), 9, gommeTrait(3));
        canvas.drawCircle(const Offset(50, 74), 7.5, plein);
      case 'elfe-sylvain':
        // Tête d'elfe devant un arbre (feuillage et racines).
        for (final (o, r) in const [
          (Offset(26, 30), 18.0),
          (Offset(50, 18), 20.0),
          (Offset(74, 30), 18.0),
          (Offset(16, 50), 12.0),
          (Offset(84, 50), 12.0),
        ]) {
          canvas.drawCircle(o, r, plein);
        }
        canvas.drawRect(const Rect.fromLTWH(44, 30, 12, 66), plein);
        for (final s in [-1.0, 1.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(50, 84)
              ..quadraticBezierTo(50 + s * 20, 88, 50 + s * 36, 98)
              ..lineTo(50 + s * 6, 98)
              ..close(),
            plein,
          );
        }
        tete(60);
      case 'haut-elfe':
        // Tête d'elfe, étoiles au-dessus de sa tête.
        tete(64);
        etoile(const Offset(50, 14), 12, 8, 0.38);
        etoile(const Offset(24, 22), 7, 4, 0.35);
        etoile(const Offset(76, 22), 7, 4, 0.35);
        canvas.drawCircle(const Offset(36, 8), 2, plein);
        canvas.drawCircle(const Offset(66, 6), 1.8, plein);
      case 'demi-elfe':
        // Visage : oreille ronde d'un côté, pointue de l'autre.
        canvas.drawOval(const Rect.fromLTWH(28, 22, 44, 62), plein);
        canvas.drawCircle(const Offset(27, 54), 9, plein);
        canvas.drawPath(
          Path()
            ..moveTo(70, 44)
            ..lineTo(96, 16)
            ..lineTo(72, 66)
            ..close(),
          plein,
        );
        for (var y = 18.0; y < 88; y += 9) {
          canvas.drawLine(Offset(50, y), Offset(50, y + 4), gommeTrait(2));
        }
        canvas.drawCircle(const Offset(41, 50), 3.8, gomme);
        canvas.drawCircle(const Offset(59, 50), 3.8, gomme);
        canvas.drawArc(const Rect.fromLTWH(40, 58, 20, 14), 0.3, math.pi - 0.6,
            false, gommeTrait(2.5));
      case 'demi-orque':
        // Mâchoire lourde, sourcils froncés, défenses.
        canvas.drawPath(
          Path()
            ..moveTo(18, 26)
            ..lineTo(82, 26)
            ..lineTo(88, 60)
            ..quadraticBezierTo(50, 100, 12, 60)
            ..close(),
          plein,
        );
        for (final s in [-1.0, 1.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(50 + s * 6, 46)
              ..lineTo(50 + s * 24, 36)
              ..lineTo(50 + s * 22, 46)
              ..close(),
            gomme,
          );
          final defense = Path()
            ..moveTo(50 + s * 14, 70)
            ..lineTo(50 + s * 22, 70)
            ..lineTo(50 + s * 19, 50)
            ..close();
          canvas.drawPath(defense, gommeTrait(3.5));
          canvas.drawPath(defense, plein);
        }
        canvas.drawPath(
          Path()
            ..moveTo(28, 70)
            ..quadraticBezierTo(50, 80, 72, 70),
          gommeTrait(3.5),
        );
      case 'draconien':
        // Tête de dragon de profil : cornes, œil fendu, naseau.
        canvas.drawPath(
          Path()
            ..moveTo(8, 96)
            ..lineTo(18, 62)
            ..quadraticBezierTo(24, 36, 46, 32)
            ..lineTo(76, 38)
            ..lineTo(94, 50)
            ..lineTo(86, 57)
            ..lineTo(60, 58)
            ..lineTo(82, 66)
            ..lineTo(54, 73)
            ..quadraticBezierTo(40, 78, 38, 96)
            ..close(),
          plein,
        );
        for (final (a, b, c) in [
          (const Offset(30, 38), const Offset(10, 6), const Offset(42, 32)),
          (const Offset(42, 33), const Offset(34, 8), const Offset(52, 32)),
          (const Offset(20, 64), const Offset(6, 56), const Offset(22, 54)),
          (const Offset(18, 78), const Offset(4, 74), const Offset(18, 70)),
        ]) {
          canvas.drawPath(
            Path()
              ..moveTo(a.dx, a.dy)
              ..lineTo(b.dx, b.dy)
              ..lineTo(c.dx, c.dy)
              ..close(),
            plein,
          );
        }
        ovale(const Offset(58, 44), 12, 6, 0.2, gomme);
        ovale(const Offset(58, 44), 2.2, 6, 0.2, plein);
        canvas.drawCircle(const Offset(86, 47), 2, gomme);
        canvas.drawLine(
            const Offset(62, 58), const Offset(80, 62), gommeTrait(1.5));
    }
  }

  @override
  bool shouldRepaint(_PeintreRace old) =>
      old.raceId != raceId || old.couleur != couleur;
}
