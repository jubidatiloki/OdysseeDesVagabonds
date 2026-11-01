import 'package:flutter/material.dart';

/// Guitare (instruments de musique), dessinée : les icônes Material n'en ont
/// pas. Caisse en huit, rosace, manche et tête, en diagonale.
class IconeGuitare extends StatelessWidget {
  const IconeGuitare({super.key, this.taille = 24, this.couleur});

  final double taille;
  final Color? couleur;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: taille,
        height: taille,
        child: CustomPaint(
          painter: _PeintreGuitare(
            couleur ?? IconTheme.of(context).color ?? Colors.brown,
          ),
        ),
      );
}

class _PeintreGuitare extends CustomPainter {
  const _PeintreGuitare(this.couleur);

  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final plein = Paint()..color = couleur;
    // Calque à part : la rosace « efface » la caisse (fond visible au travers).
    canvas.saveLayer(Offset.zero & size, Paint());
    // Toute la guitare penchée à 45°, tête en haut à droite.
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(0.785398);

    // Caisse : deux cercles (bas plus large) et la taille entre eux.
    canvas
      ..drawCircle(Offset(0, s * 0.26), s * 0.2, plein)
      ..drawCircle(Offset(0, s * 0.04), s * 0.15, plein)
      ..drawRect(
        Rect.fromCenter(
          center: Offset(0, s * 0.15),
          width: s * 0.24,
          height: s * 0.16,
        ),
        plein,
      );
    // Rosace : trou dans la caisse.
    canvas.drawCircle(
      Offset(0, s * 0.14),
      s * 0.06,
      Paint()..blendMode = BlendMode.clear,
    );
    // Manche et tête.
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-s * 0.035, -s * 0.42, s * 0.07, s * 0.36),
          Radius.circular(s * 0.02),
        ),
        plein,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-s * 0.06, -s * 0.5, s * 0.12, s * 0.1),
          Radius.circular(s * 0.03),
        ),
        plein,
      )
      ..restore()
      ..restore();
  }

  @override
  bool shouldRepaint(_PeintreGuitare ancien) => ancien.couleur != couleur;
}
