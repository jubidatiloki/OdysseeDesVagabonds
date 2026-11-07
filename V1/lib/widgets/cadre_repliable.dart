import 'package:flutter/material.dart';

/// Cadre à en-tête coloré, que l'on réduit en touchant son en-tête : voies de
/// compétences, groupes d'aptitudes, notes de séances.
class CadreRepliable extends StatefulWidget {
  const CadreRepliable({
    super.key,
    required this.cle,
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.enfants,
    this.couleur,
    this.droite,
    this.ouvertAuDepart = true,
  });

  /// Identifie le cadre : l'état réduit survit au défilement de la liste.
  final String cle;
  final IconData icone;
  final String titre;
  final String sousTitre;
  final List<Widget> enfants;

  /// Couleur de l'en-tête ; par défaut, celle du thème.
  final Color? couleur;

  /// À droite de l'en-tête, avant le chevron (nombre d'acquis, bouton…).
  final Widget? droite;
  final bool ouvertAuDepart;

  @override
  State<CadreRepliable> createState() => _CadreRepliableState();
}

class _CadreRepliableState extends State<CadreRepliable> {
  late bool _ouvert;

  @override
  void initState() {
    super.initState();
    final memoire = PageStorage.maybeOf(context)
        ?.readState(context, identifier: widget.cle);
    _ouvert = memoire is bool ? memoire : widget.ouvertAuDepart;
  }

  void _basculer() {
    setState(() => _ouvert = !_ouvert);
    PageStorage.maybeOf(context)
        ?.writeState(context, _ouvert, identifier: widget.cle);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final teinte = widget.couleur ?? scheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: teinte.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête coloré : le cadre se repère d'un coup d'œil.
          Material(
            color: teinte.withValues(alpha: 0.15),
            child: InkWell(
              key: Key('replier-${widget.cle}'),
              onTap: _basculer,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                child: Row(
                  children: [
                    Icon(widget.icone, color: teinte),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.titre,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: teinte,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (widget.sousTitre.isNotEmpty)
                            Text(
                              widget.sousTitre,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                    if (widget.droite case final d?) ...[
                      const SizedBox(width: 8),
                      d,
                    ],
                    const SizedBox(width: 4),
                    Icon(
                      _ouvert ? Icons.expand_less : Icons.expand_more,
                      semanticLabel: _ouvert ? 'Réduire' : 'Déplier',
                      color: teinte,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_ouvert)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.enfants,
              ),
            ),
        ],
      ),
    );
  }
}
