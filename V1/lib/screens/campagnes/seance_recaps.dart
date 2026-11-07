import 'package:flutter/material.dart';

import '../../models/campagne.dart';
import '../../widgets/cadre_repliable.dart';
import '../../widgets/consultation.dart';
import '../fiche/onglet_historique.dart' show formaterDate;
import 'campagnes_screen.dart';

/// Notes de séances : un récapitulatif par séance, de la plus récente à la
/// plus ancienne, avec sa date. Le MJ les écrit, pendant ou après la séance ;
/// les joueurs les lisent.
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

  /// Textes tels qu'ils sont enregistrés : le bouton sait s'il y a du neuf.
  final Map<int, String> _enregistres = {};
  Map<int, DateTime> _dates = {};
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
    var dates = <int, DateTime>{};
    await widget.contexte.campagnes.agir((s) async {
      recaps = await s.lireRecaps(widget.campagne.id);
      dates = await s.lireDatesRecaps(widget.campagne.id);
    });
    if (!mounted) return;
    setState(() {
      _charge = true;
      _dates = dates;
      for (final e in recaps.entries) {
        _texte(e.key).text = e.value;
        _enregistres[e.key] = e.value;
      }
    });
  }

  TextEditingController _texte(int n) => _textes[n] ??=
      TextEditingController()..addListener(() => setState(() {}));

  /// Date d'une séance : notée, sinon le début de la dernière séance.
  DateTime? _date(int n) {
    final s = widget.campagne.seance;
    return _dates[n] ?? (s?.numero == n ? s?.debut : null);
  }

  String _sousTitre(int n) {
    final d = _date(n);
    final enCours =
        widget.campagne.seance?.numero == n && widget.campagne.seance!.enCours;
    return [
      if (d != null)
        formaterDate(d)
      else if (!widget.lecture)
        'Date à préciser',
      if (enCours) 'en cours',
    ].join(' · ');
  }

  Future<void> _enregistrer(int n) async {
    final messager = ScaffoldMessenger.of(context);
    final texte = _texte(n).text;
    final erreur = await widget.contexte.campagnes
        .agir((s) => s.ecrireRecap(widget.campagne.id, n, texte));
    if (erreur == null && mounted) setState(() => _enregistres[n] = texte);
    messager.showSnackBar(SnackBar(content: Text(erreur ?? 'Enregistré.')));
  }

  Future<void> _choisirDate(int n) async {
    final messager = ScaffoldMessenger.of(context);
    final date = await showDatePicker(
      context: context,
      initialDate: _date(n) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Date de la séance $n',
    );
    if (date == null) return;
    final erreur = await widget.contexte.campagnes
        .agir((s) => s.ecrireDateRecap(widget.campagne.id, n, date));
    if (erreur != null) {
      messager.showSnackBar(SnackBar(content: Text(erreur)));
    } else if (mounted) {
      setState(() => _dates = {..._dates, n: date});
    }
  }

  @override
  void dispose() {
    for (final t in _textes.values) {
      t.dispose();
    }
    super.dispose();
  }

  Widget _liste(String resume, List<Widget> cadres) {
    final theme = Theme.of(context);
    return LargeurLimitee(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Notes de séances', style: theme.textTheme.titleLarge),
          Text(
            resume,
            key: const Key('resume-recaps'),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          for (final c in cadres) ...[const SizedBox(height: 12), c],
        ],
      ),
    );
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
    return _liste(
      '${ecrits.length} récapitulatif${ecrits.length > 1 ? 's' : ''} du MJ',
      [
        for (final e in ecrits)
          KeyedSubtree(
            key: Key('recap-lecture-${e.key}'),
            child: CadreRepliable(
              key: PageStorageKey('recap-${e.key}'),
              cle: 'recap-${e.key}',
              icone: Icons.event_note_outlined,
              titre: 'Séance ${e.key}',
              sousTitre: _sousTitre(e.key),
              enfants: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SelectableText(e.value.text),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cadreMj(int n, int derniere) {
    final modifie = _texte(n).text != (_enregistres[n] ?? '');
    final sauve = !modifie && _texte(n).text.isNotEmpty;
    return CadreRepliable(
      key: PageStorageKey('recap-$n'),
      cle: 'recap-$n',
      icone: Icons.event_note_outlined,
      titre: 'Séance $n',
      sousTitre: _sousTitre(n),
      // Les séances passées sont réduites : la dernière reste sous la main.
      ouvertAuDepart: n == derniere,
      droite: IconButton(
        key: Key('date-recap-$n'),
        tooltip: 'Choisir la date',
        visualDensity: VisualDensity.compact,
        onPressed: () => _choisirDate(n),
        icon: const Icon(Icons.calendar_month_outlined),
      ),
      enfants: [
        const SizedBox(height: 8),
        TextField(
          key: Key('recap-$n'),
          controller: _texte(n),
          minLines: 4,
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
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            key: Key('enregistrer-recap-$n'),
            onPressed: modifie ? () => _enregistrer(n) : null,
            icon: Icon(sauve ? Icons.check : Icons.save_outlined),
            label: Text(sauve ? 'Enregistré' : 'Enregistrer'),
          ),
        ),
      ],
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
    final ecrits =
        _enregistres.values.where((t) => t.trim().isNotEmpty).length;
    return _liste(
      '$derniere séance${derniere > 1 ? 's' : ''} · '
      '$ecrits récapitulatif${ecrits > 1 ? 's' : ''} écrit${ecrits > 1 ? 's' : ''}',
      [for (var n = derniere; n >= 1; n--) _cadreMj(n, derniere)],
    );
  }
}
