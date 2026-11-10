import 'package:flutter/material.dart';

/// Épée et flèche, dessinées : les icônes Material n'en ont pas. Toutes deux
/// en diagonale, pointe en haut à droite.
class IconeEpee extends StatelessWidget {
  const IconeEpee({super.key, this.taille = 24, this.couleur});

  final double taille;
  final Color? couleur;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: taille,
        height: taille,
        child: CustomPaint(
          painter: _PeintreArme(
            couleur ?? IconTheme.of(context).color ?? Colors.grey,
            fleche: false,
          ),
        ),
      );
}

class IconeFleche extends StatelessWidget {
  const IconeFleche({super.key, this.taille = 24, this.couleur});

  final double taille;
  final Color? couleur;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: taille,
        height: taille,
        child: CustomPaint(
          painter: _PeintreArme(
            couleur ?? IconTheme.of(context).color ?? Colors.grey,
            fleche: true,
          ),
        ),
      );
}

class _PeintreArme extends CustomPainter {
  const _PeintreArme(this.couleur, {required this.fleche});

  final Color couleur;
  final bool fleche;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final plein = Paint()..color = couleur;
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(0.785398);
    if (fleche) {
      // Hampe, pointe triangulaire, empennage en deux ailettes.
      canvas
        ..drawRect(
          Rect.fromLTWH(-s * 0.03, -s * 0.3, s * 0.06, s * 0.72),
          plein,
        )
        ..drawPath(
          Path()
            ..moveTo(0, -s * 0.48)
            ..lineTo(s * 0.12, -s * 0.26)
            ..lineTo(-s * 0.12, -s * 0.26)
            ..close(),
          plein,
        );
      for (final cote in [-1.0, 1.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(cote * s * 0.03, s * 0.2)
            ..lineTo(cote * s * 0.13, s * 0.3)
            ..lineTo(cote * s * 0.13, s * 0.46)
            ..lineTo(cote * s * 0.03, s * 0.36)
            ..close(),
          plein,
        );
      }
    } else {
      // Lame effilée, garde, poignée, pommeau.
      canvas
        ..drawPath(
          Path()
            ..moveTo(0, -s * 0.48)
            ..lineTo(s * 0.065, -s * 0.38)
            ..lineTo(s * 0.065, s * 0.16)
            ..lineTo(-s * 0.065, s * 0.16)
            ..lineTo(-s * 0.065, -s * 0.38)
            ..close(),
          plein,
        )
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-s * 0.2, s * 0.16, s * 0.4, s * 0.07),
            Radius.circular(s * 0.03),
          ),
          plein,
        )
        ..drawRect(
          Rect.fromLTWH(-s * 0.035, s * 0.23, s * 0.07, s * 0.17),
          plein,
        )
        ..drawCircle(Offset(0, s * 0.43), s * 0.055, plein);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeintreArme ancien) =>
      ancien.couleur != couleur || ancien.fleche != fleche;
}
