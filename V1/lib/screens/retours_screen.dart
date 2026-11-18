import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/retours.dart';
import '../models/retour.dart';
import '../state/compte_controller.dart';
import '../version.dart';
import '../widgets/consultation.dart';

/// Écran « Donner son avis » (18/11/2026) : signaler un bug, proposer une
/// idée ou autre chose. Avec un compte, le retour part en ligne (avec la
/// version de l'application et l'appareil) ; sans compte, on peut le copier.
class RetoursScreen extends StatefulWidget {
  const RetoursScreen({super.key, this.menu, this.compte, this.service});

  final Widget? menu;
  final CompteController? compte;

  /// Envoi des retours (remplacé dans les tests) ; en ligne par défaut.
  final ServiceRetours? service;

  /// Délai entre deux envois (évite les envois en double).
  static const Duration delaiEntreEnvois = Duration(seconds: 30);

  @override
  State<RetoursScreen> createState() => _RetoursScreenState();
}

class _RetoursScreenState extends State<RetoursScreen> {
  static DateTime? _dernierEnvoi;

  final _texte = TextEditingController();
  var _type = TypeRetour.bug;
  var _envoi = false;

  static String get _plateforme => kIsWeb ? 'web' : defaultTargetPlatform.name;

  @override
  void initState() {
    super.initState();
    _texte.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  void _message(String texte) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texte)));

  /// Texte complet, à copier quand on n'a pas de compte.
  String get _texteComplet => '[${_type.libelle}] L\'odyssée des vagabonds '
      '$kVersionApp ($_plateforme)\n\n${_texte.text.trim()}';

  Future<void> _envoyer() async {
    final u = widget.compte?.utilisateur;
    final texte = _texte.text.trim();
    if (u == null || texte.isEmpty) return;
    final dernier = _dernierEnvoi;
    if (dernier != null &&
        DateTime.now().difference(dernier) < RetoursScreen.delaiEntreEnvois) {
      _message('Patiente quelques secondes avant d\'envoyer un autre retour.');
      return;
    }
    setState(() => _envoi = true);
    try {
      await (widget.service ?? FirestoreServiceRetours())
          .envoyer(Retour(
            type: _type,
            texte: texte.length > Retour.longueurMax
                ? texte.substring(0, Retour.longueurMax)
                : texte,
            auteur: u.uid,
            nom: u.nom ?? '',
            version: kVersionApp,
            plateforme: _plateforme,
            date: DateTime.now(),
          ))
          .timeout(const Duration(seconds: 12));
      _dernierEnvoi = DateTime.now();
      if (!mounted) return;
      _texte.clear();
      _message('Merci ! Ton retour est bien arrivé.');
    } catch (e) {
      if (mounted) {
        _message('Envoi impossible (connexion ?). Réessaie, ou copie ton '
            'texte pour l\'envoyer autrement.');
      }
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  Future<void> _copier() async {
    await Clipboard.setData(ClipboardData(text: _texteComplet));
    if (mounted) _message('Texte copié : colle-le dans un message.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final u = widget.compte?.utilisateur;
    final vide = _texte.text.trim().isEmpty;
    return Scaffold(
      drawer: widget.menu,
      appBar: AppBar(title: const Text('Donner son avis')),
      body: LargeurLimitee(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Un bug, une idée, une question ? Dis-le ici : chaque retour '
              'est lu et aide à améliorer l\'application.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in TypeRetour.values)
                  ChoiceChip(
                    key: Key('type-retour-${t.name}'),
                    avatar: Icon(
                      switch (t) {
                        TypeRetour.bug => Icons.bug_report_outlined,
                        TypeRetour.idee => Icons.lightbulb_outline,
                        TypeRetour.autre => Icons.chat_bubble_outline,
                      },
                      size: 18,
                    ),
                    label: Text(t.libelle),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('texte-retour'),
              controller: _texte,
              minLines: 6,
              maxLines: 14,
              maxLength: Retour.longueurMax,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: _type.aide,
                alignLabelWithHint: true,
                hintText: _type == TypeRetour.bug
                    ? 'Sur quel écran ? Qu\'as-tu fait ? Qu\'attendais-tu ?'
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            Text(
              'Envoyé avec : version $kVersionApp · $_plateforme.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (u == null) ...[
              Card(
                key: const Key('retour-sans-compte'),
                color: theme.colorScheme.secondaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Connecte-toi (page Compte) pour envoyer ton retour '
                    'directement. Sans compte, copie-le pour l\'envoyer par '
                    'message.',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const Key('copier-retour'),
                onPressed: vide ? null : _copier,
                icon: const Icon(Icons.copy),
                label: const Text('Copier le texte'),
              ),
            ] else
              FilledButton.icon(
                key: const Key('envoyer-retour'),
                onPressed: vide || _envoi ? null : _envoyer,
                icon: _envoi
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(_envoi ? 'Envoi…' : 'Envoyer'),
              ),
          ],
        ),
      ),
    );
  }
}
