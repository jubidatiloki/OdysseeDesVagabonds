import 'package:flutter/material.dart';

import '../models/classe.dart';
import '../models/race.dart';
import '../regles/fiche_calculee.dart';
import '../regles/maitrises.dart';
import '../theme.dart';

/// Maîtrises et restrictions d'une classe, d'une race, ou des deux (fiche) :
/// armes maîtrisées, armures permises, interdits et malus, en pastilles.
class MaitrisesRestrictions extends StatelessWidget {
  const MaitrisesRestrictions({
    super.key,
    this.classe,
    this.race,
    this.origineId,
    this.armesEnPlus = const [],
  });

  final Classe? classe;
  final Race? race;

  /// Origine du personnage ; sans elle, les maîtrises de chaque origine sont
  /// montrées « selon l'origine » (glossaire).
  final String? origineId;

  /// Armes maîtrisées par les compétences et les aptitudes (fiche).
  final List<String> armesEnPlus;

  List<({String texte, String? survol})> get _armes {
    final r = race;
    final origine = r?.origine(origineId);
    final parOrigine = origineId == null
        ? {
            for (final o in r?.origines ?? const <OrigineRace>[])
              ...o.maitrisesArmes,
          }
        : const <String>{};
    final vus = <String>{};
    return [
      for (final m in [
        ...?classe?.maitrisesArmes,
        ...?r?.maitrisesArmes,
        ...?origine?.maitrisesArmes,
        ...armesEnPlus,
      ])
        if (vus.add(libelleMaitriseArme(m)))
          (texte: libelleMaitriseArme(m), survol: _survol(m)),
      for (final m in parOrigine)
        if (vus.add(libelleMaitriseArme(m)))
          (texte: '${libelleMaitriseArme(m)} (selon l\'origine)', survol: null),
    ];
  }

  /// Armes du catalogue d'un groupe : « Bâton, Pelle, Pioche, Hache ».
  static String? _survol(String groupe) {
    final noms = FicheCalculee.armesParGroupe[groupe];
    return noms == null || noms.isEmpty ? null : noms.join(', ');
  }

  /// L'armure la plus lourde permise, la limite la plus stricte l'emporte.
  String? get _armure {
    final limites = [
      if (classe case final c?) c.armureMax,
      if (race case final r?) r.armureMax,
    ];
    final strictes = limites.where((l) => l.isNotEmpty).toList()
      ..sort((a, b) => niveauArmureMax(a).compareTo(niveauArmureMax(b)));
    if (strictes.isNotEmpty) return libelleArmureMax(strictes.first);
    return classe == null ? null : libelleArmureMax('');
  }

  List<String> get _interdits {
    final r = race;
    if (r == null) return const [];
    return [
      for (final a in r.armesInterdites) libelleMaitriseArme(a),
      if (r.desArmeMax case final d?) 'Armes au-delà du d$d (2d6 permis)',
    ];
  }

  List<String> get _malus => [
        for (final e in race?.malusArmes.entries ?? const <MapEntry<String, int>>[])
          '${libelleMaitriseArme(e.key)} : '
              '${'${e.value}'.replaceFirst('-', '−')} au toucher',
      ];

  /// Texte d'origine de la race : ce qui ne concerne pas l'équipement y reste.
  String get _note {
    final t = race?.restrictions.trim() ?? '';
    return t.toLowerCase().startsWith('aucune') ? '' : t;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final vert = theme.brightness == Brightness.dark
        ? OdvCouleurs.lightGreen
        : OdvCouleurs.darkGreen;
    final armes = _armes;
    final armure = _armure;
    final interdits = _interdits;
    final malus = _malus;
    return Column(
      key: const Key('maitrises-restrictions'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Groupe(
          cle: 'groupe-armes',
          icone: Icons.check_circle_outline,
          titre: 'Armes maîtrisées',
          couleur: vert,
          pastilles: armes.isEmpty
              ? const [(texte: 'Aucune', survol: null)]
              : armes,
        ),
        if (armure != null)
          _Groupe(
            cle: 'groupe-armure',
            icone: Icons.shield_outlined,
            titre: 'Armures permises',
            couleur: scheme.primary,
            pastilles: [(texte: armure, survol: null)],
          ),
        if (interdits.isNotEmpty)
          _Groupe(
            cle: 'groupe-interdits',
            icone: Icons.block,
            titre: 'Interdit',
            couleur: scheme.error,
            pastilles: [
              for (final t in interdits) (texte: t, survol: null),
            ],
          ),
        if (malus.isNotEmpty)
          _Groupe(
            cle: 'groupe-malus',
            icone: Icons.trending_down,
            titre: 'Malus',
            couleur: scheme.error,
            pastilles: [
              for (final t in malus) (texte: t, survol: null),
            ],
          ),
        if (_note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _note,
              key: const Key('note-restrictions'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

class _Groupe extends StatelessWidget {
  const _Groupe({
    required this.cle,
    required this.icone,
    required this.titre,
    required this.couleur,
    required this.pastilles,
  });

  final String cle;
  final IconData icone;
  final String titre;
  final Color couleur;
  final List<({String texte, String? survol})> pastilles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      key: Key(cle),
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 16, color: couleur),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  titre,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final p in pastilles)
                _Pastille(texte: p.texte, survol: p.survol, couleur: couleur),
            ],
          ),
        ],
      ),
    );
  }
}

/// Étiquette colorée ; le texte passe à la ligne s'il est trop long.
class _Pastille extends StatelessWidget {
  const _Pastille({
    required this.texte,
    required this.survol,
    required this.couleur,
  });

  final String texte;
  final String? survol;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    final pastille = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        border: Border.all(color: couleur.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(texte, style: Theme.of(context).textTheme.bodySmall),
    );
    final s = survol;
    return s == null ? pastille : Tooltip(message: s, child: pastille);
  }
}
