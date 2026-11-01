import 'dart:math';

import 'package:flutter/material.dart';

/// Trèfle à quatre feuilles (chance, CHAN), dessiné : les icônes Material
/// n'en ont pas. Quatre feuilles en cœur et une tige.
class IconeTrefle extends StatelessWidget {
  const IconeTrefle({super.key, this.taille = 24, this.couleur});

  final double taille;
  final Color? couleur;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: taille,
        height: taille,
        child: CustomPaint(
          painter: _PeintreTrefle(
            couleur ?? IconTheme.of(context).color ?? Colors.green,
          ),
        ),
      );
}

class _PeintreTrefle extends CustomPainter {
  const _PeintreTrefle(this.couleur);

  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final centre = Offset(size.width / 2, size.height * 0.46);
    final pinceau = Paint()
      ..color = couleur
      ..style = PaintingStyle.fill;

    // Une feuille en cœur, pointe au centre, ouverte vers le haut.
    final h = s * 0.44;
    final w = s * 0.26;
    final feuille = Path()
      ..moveTo(0, 0)
      ..cubicTo(-w * 1.15, -h * 0.4, -w * 0.95, -h * 1.12, 0, -h * 0.74)
      ..cubicTo(w * 0.95, -h * 1.12, w * 1.15, -h * 0.4, 0, 0)
      ..close();

    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    for (var i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(pi / 4 + i * pi / 2);
      canvas.drawPath(feuille, pinceau);
      canvas.restore();
    }
    canvas.restore();

    // Tige légèrement courbée vers le bas à droite.
    final tige = Path()
      ..moveTo(centre.dx, centre.dy)
      ..quadraticBezierTo(
        centre.dx + s * 0.06,
        centre.dy + s * 0.3,
        centre.dx + s * 0.22,
        centre.dy + s * 0.5,
      );
    canvas.drawPath(
      tige,
      Paint()
        ..color = couleur
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.07
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_PeintreTrefle ancien) => ancien.couleur != couleur;
}
