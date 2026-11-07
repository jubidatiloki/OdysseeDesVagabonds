import 'package:flutter/material.dart';

import '../../state/seance_controller.dart';
import '../../widgets/consultation.dart';

/// Heure d'un message : « 20:15 » le jour même, « 07/11 · 20:15 » sinon.
String heureMessage(DateTime d, DateTime maintenant) {
  String n(int v) => v.toString().padLeft(2, '0');
  final heure = '${n(d.hour)}:${n(d.minute)}';
  final memeJour = d.year == maintenant.year &&
      d.month == maintenant.month &&
      d.day == maintenant.day;
  return memeJour ? heure : '${n(d.day)}/${n(d.month)} · $heure';
}

/// Messagerie privée de la séance : une conversation par joueur avec le MJ.
class OngletMessages extends StatefulWidget {
  const OngletMessages({super.key, required this.seance});

  final SeanceController seance;

  @override
  State<OngletMessages> createState() => _OngletMessagesState();
}

class _OngletMessagesState extends State<OngletMessages> {
  final _texte = TextEditingController();
  String? _joueurChoisi;

  SeanceController get _s => widget.seance;

  /// Joueur de la conversation : soi-même, ou celui que choisit le MJ.
  String? get _joueur {
    if (!_s.estMj) return _s.uid;
    final ids = _s.joueurs.map((m) => m.uid);
    if (ids.contains(_joueurChoisi)) return _joueurChoisi;
    return ids.isEmpty ? null : ids.first;
  }

  /// La conversation affichée a des messages non lus : ils deviennent lus
  /// une fois à l'écran. Seule la conversation visible compte.
  void _lire(String joueur) {
    if (_s.nonLusAvec(joueur) == 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _joueur == joueur) _s.marquerMessagesLus(joueur);
    });
  }

  Future<void> _envoyer() async {
    final j = _joueur;
    if (j == null || _texte.text.trim().isEmpty) return;
    final messager = ScaffoldMessenger.of(context);
    final erreur = await _s.envoyerMessage(j, _texte.text);
    if (erreur != null) {
      messager.showSnackBar(SnackBar(content: Text(erreur)));
    } else {
      _texte.clear();
    }
  }

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reconstruit à chaque message reçu, même si le parent ne bouge pas.
    return ListenableBuilder(
      listenable: _s,
      builder: (context, _) => _contenu(context),
    );
  }

  Widget _contenu(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final j = _joueur;
    if (j == null) {
      return const Center(child: TexteAVenir('Aucun joueur pour l\'instant.'));
    }
    _lire(j);
    final maintenant = DateTime.now();
    final messages = _s.messagesAvec(j).reversed.toList();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_s.estMj)
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Conversation avec'),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  key: const Key('message-joueur'),
                  isDense: true,
                  isExpanded: true,
                  value: j,
                  items: [
                    for (final m in _s.joueurs)
                      DropdownMenuItem(
                        value: m.uid,
                        child: Badge(
                          key: Key('non-lus-${m.uid}'),
                          isLabelVisible:
                              m.uid != j && _s.nonLusAvec(m.uid) > 0,
                          label: Text('${_s.nonLusAvec(m.uid)}'),
                          child: Text(
                            m.personnageNom,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _joueurChoisi = v),
                ),
              ),
            )
          else
            Text('Conversation avec le MJ', style: theme.textTheme.titleSmall),
          if (!_s.anciensMessagesCharges)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('anciens-messages'),
                onPressed: () async {
                  final messager = ScaffoldMessenger.of(context);
                  final erreur = await _s.chargerAnciensMessages();
                  if (erreur != null) {
                    messager.showSnackBar(SnackBar(content: Text(erreur)));
                  }
                },
                icon: const Icon(Icons.history, size: 18),
                label: const Text(
                  'Messages des séances précédentes',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: messages.isEmpty
                ? const Center(child: TexteAVenir('Aucun message.'))
                : ListView.builder(
                    key: const Key('liste-messages'),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final moi = m.de == _s.uid;
                      return Align(
                        alignment:
                            moi ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: moi
                                ? scheme.primaryContainer
                                : scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: moi
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(m.texte),
                              const SizedBox(height: 2),
                              Text(
                                heureMessage(m.date, maintenant),
                                key: Key('heure-message-$i'),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('message-texte'),
                  controller: _texte,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Message privé'),
                  onSubmitted: (_) => _envoyer(),
                ),
              ),
              IconButton(
                key: const Key('message-envoyer'),
                tooltip: 'Envoyer',
                onPressed: _envoyer,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
