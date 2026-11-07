import 'package:flutter/material.dart';

import '../../models/campagne.dart';
import '../../widgets/consultation.dart';
import 'campagnes_screen.dart';

/// Séances précédentes (MJ) : un récapitulatif modifiable par séance, de la
/// plus récente à la plus ancienne, pendant ou après la séance.
class OngletRecaps extends StatefulWidget {
  const OngletRecaps({
    super.key,
    required this.contexte,
    required this.campagne,
    this.lecture = false,
  });

  final ContexteCampagnes contexte;
  final Campagne campagne;

  /// Joueur : récapitulatifs du MJ, sans les modifier.
  final bool lecture;

  @override
  State<OngletRecaps> createState() => _OngletRecapsState();
}

class _OngletRecapsState extends State<OngletRecaps>
    with AutomaticKeepAliveClientMixin {
  final Map<int, TextEditingController> _textes = {};
  var _charge = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    var recaps = <int, String>{};
    await widget.contexte.campagnes.agir((s) async {
      recaps = await s.lireRecaps(widget.campagne.id);
    });
    if (!mounted) return;
    setState(() {
      _charge = true;
      for (final e in recaps.entries) {
        _texte(e.key).text = e.value;
      }
    });
  }

  TextEditingController _texte(int n) => _textes[n] ??= TextEditingController();

  Future<void> _enregistrer(int n) async {
    final messager = ScaffoldMessenger.of(context);
    final texte = _texte(n).text;
    final erreur = await widget.contexte.campagnes
        .agir((s) => s.ecrireRecap(widget.campagne.id, n, texte));
    messager.showSnackBar(SnackBar(content: Text(erreur ?? 'Enregistré.')));
  }

  @override
  void dispose() {
    for (final t in _textes.values) {
      t.dispose();
    }
    super.dispose();
  }

  Widget _lecture() {
    final ecrits = [
      for (final e in _textes.entries)
        if (e.value.text.trim().isNotEmpty) e,
    ]..sort((a, b) => b.key.compareTo(a.key));
    if (ecrits.isEmpty) {
      return const Center(
        child: TexteAVenir('Le MJ n\'a pas encore écrit de récapitulatif.'),
      );
    }
    return LargeurLimitee(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final e in ecrits)
            BlocConsultation(
              key: Key('recap-lecture-${e.key}'),
              titre: 'Séance ${e.key}',
              icone: Icons.event_note_outlined,
              children: [SelectableText(e.value.text)],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_charge) return const Center(child: CircularProgressIndicator());
    if (widget.lecture) return _lecture();
    final derniere = widget.campagne.seance?.numero ?? 0;
    if (derniere == 0) {
      return const Center(
        child: TexteAVenir('Aucune séance pour l\'instant.'),
      );
    }
    return LargeurLimitee(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var n = derniere; n >= 1; n--)
            BlocConsultation(
              titre: 'Séance $n',
              icone: Icons.event_note_outlined,
              children: [
                TextField(
                  key: Key('recap-$n'),
                  controller: _texte(n),
                  minLines: 3,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Ce qui s\'est passé, ce qu\'il faut retenir…',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    key: Key('enregistrer-recap-$n'),
                    onPressed: () => _enregistrer(n),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
