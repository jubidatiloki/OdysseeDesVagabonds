import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Animation montrée à chaque lancer de dés : un dé qui roule en faisant
/// défiler des chiffres, puis le résultat, par-dessus l'écran. Elle ne bloque
/// ni les clics ni la lecture de l'écran, et disparaît seule.
class AnimationLancer extends StatefulWidget {
  const AnimationLancer({
    super.key,
    required this.total,
    required this.libelle,
    this.critique = false,
    this.echec = false,
    this.surFin,
  });

  /// Durée totale : roulement, résultat, disparition.
  static const Duration duree = Duration(milliseconds: 2400);

  final int total;
  final String libelle;

  /// Réussite critique (vert) ou échec critique (rouge).
  final bool critique;
  final bool echec;
  final VoidCallback? surFin;

  static OverlayEntry? _entree;

  /// Montre l'animation par-dessus l'écran de [context]. Un nouveau lancer
  /// remplace l'animation en cours. Rien si les animations sont coupées
  /// (réglage d'accessibilité de l'appareil).
  static void montrer(
    BuildContext context, {
    required int total,
    required String libelle,
    bool critique = false,
    bool echec = false,
  }) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _retirer();
    late final OverlayEntry entree;
    entree = OverlayEntry(
      builder: (_) => AnimationLancer(
        key: const Key('animation-lancer'),
        total: total,
        libelle: libelle,
        critique: critique,
        echec: echec,
        surFin: () {
          if (_entree == entree) _retirer();
        },
      ),
    );
    _entree = entree;
    overlay.insert(entree);
  }

  static void _retirer() {
    final e = _entree;
    _entree = null;
    if (e != null && e.mounted) e.remove();
  }

  @override
  State<AnimationLancer> createState() => _AnimationLancerState();
}

class _AnimationLancerState extends State<AnimationLancer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: AnimationLancer.duree)
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) widget.surFin?.call();
        })
        ..forward();

  /// Chiffres qui défilent pendant le roulement (toujours les mêmes pour un
  /// même total : l'animation ne dépend pas du hasard).
  late final List<int> _defilement = [
    for (var i = 0; i < 12; i++) 1 + (widget.total.abs() * 7 + i * 13) % 20,
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _couleur => widget.critique
      ? OdvCouleurs.green
      : widget.echec
          ? OdvCouleurs.red
          : OdvCouleurs.or;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = _ctrl.value;
            // 0,77 s : le dé roule ; puis le résultat reste ~1,4 s ; puis fondu.
            const finRoulement = 0.32;
            final roule = t < finRoulement;
            final p = roule ? t / finRoulement : 1.0;
            final angle =
                roule ? Curves.easeOut.transform(p) * math.pi * 4 : 0.0;
            final echelle = roule
                ? 0.6 + 0.4 * Curves.easeOut.transform(p)
                : 1.0 +
                    0.15 *
                        math.sin(
                            ((t - finRoulement) / 0.15).clamp(0, 1) * math.pi);
            final opacite =
                t < 0.88 ? 1.0 : (1 - (t - 0.88) / 0.12).clamp(0.0, 1.0);
            final chiffre = roule
                ? _defilement[(p * (_defilement.length - 1)).floor()]
                : widget.total;
            return Opacity(
              opacity: opacite,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: angle,
                      child: Transform.scale(
                        scale: echelle,
                        child: CustomPaint(
                          size: const Size.square(120),
                          painter: _DePainter(
                            couleur: _couleur,
                            fond: theme.colorScheme.surface,
                          ),
                          child: SizedBox.square(
                            dimension: 120,
                            child: Center(
                              // RichText : chiffres décoratifs, hors de la
                              // lecture de l'écran.
                              child: RichText(
                                text: TextSpan(
                                  text: '$chiffre',
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    color: _couleur,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!roule && widget.libelle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 260),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.9,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            text: widget.libelle,
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Dé à vingt faces vu de face : un hexagone et son triangle central.
class _DePainter extends CustomPainter {
  const _DePainter({required this.couleur, required this.fond});

  final Color couleur;
  final Color fond;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final rayon = size.shortestSide / 2;
    Offset sommet(double r, int i, int n, double depart) {
      final a = depart + i * 2 * math.pi / n;
      return centre + Offset(math.cos(a), math.sin(a)) * r;
    }

    final hexagone = Path();
    for (var i = 0; i < 6; i++) {
      final s = sommet(rayon, i, 6, -math.pi / 2);
      i == 0 ? hexagone.moveTo(s.dx, s.dy) : hexagone.lineTo(s.dx, s.dy);
    }
    hexagone.close();
    canvas.drawShadow(hexagone, Colors.black, 6, false);
    canvas.drawPath(hexagone, Paint()..color = fond);
    canvas.drawPath(
      hexagone,
      Paint()..color = couleur.withValues(alpha: 0.15),
    );
    final trait = Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(hexagone, trait);
    // Triangle central et arêtes vers les sommets.
    final triangle = Path();
    for (var i = 0; i < 3; i++) {
      final s = sommet(rayon * 0.62, i, 3, -math.pi / 2);
      i == 0 ? triangle.moveTo(s.dx, s.dy) : triangle.lineTo(s.dx, s.dy);
    }
    triangle.close();
    final fin = Paint()
      ..color = couleur.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(triangle, fin);
    for (var i = 0; i < 6; i++) {
      final ext = sommet(rayon, i, 6, -math.pi / 2);
      final interne = sommet(rayon * 0.62, i ~/ 2, 3, -math.pi / 2);
      canvas.drawLine(ext, interne, fin);
    }
  }

  @override
  bool shouldRepaint(_DePainter ancien) =>
      ancien.couleur != couleur || ancien.fond != fond;
}
