import 'package:flutter/material.dart';

/// Barre de PV, PM ou PE qui glisse vers sa nouvelle valeur (19/11/2026) :
/// les dégâts, soins et dépenses se voient sur les cartes de la séance et
/// dans le détail.
class JaugeAnimee extends StatelessWidget {
  const JaugeAnimee({
    super.key,
    required this.valeur,
    required this.max,
    required this.couleur,
    this.couleurSelon,
    this.largeur,
    this.hauteur = 4,
    this.fond,
  });

  final int valeur;
  final int max;
  final Color couleur;

  /// Couleur selon le remplissage (PV : vert, or puis rouge).
  final Color Function(double ratio)? couleurSelon;

  /// `null` : toute la largeur disponible.
  final double? largeur;
  final double hauteur;
  final Color? fond;

  static const duree = Duration(milliseconds: 600);

  @override
  Widget build(BuildContext context) {
    final ratio = max <= 0 ? 0.0 : (valeur / max).clamp(0.0, 1.0).toDouble();
    return SizedBox(
      width: largeur,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: ratio),
        duration: duree,
        curve: Curves.easeOutCubic,
        builder: (context, r, _) => LinearProgressIndicator(
          value: r,
          minHeight: hauteur,
          color: couleurSelon?.call(r) ?? couleur,
          backgroundColor:
              fond ?? Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(hauteur / 2),
        ),
      ),
    );
  }
}
