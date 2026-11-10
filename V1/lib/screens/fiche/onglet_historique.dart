import 'package:flutter/material.dart';

import '../../models/historique.dart';
import '../../models/personnage.dart';

const List<String> _jours = [
  'lundi',
  'mardi',
  'mercredi',
  'jeudi',
  'vendredi',
  'samedi',
  'dimanche',
];

const List<String> _mois = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

String _deuxChiffres(int n) => n.toString().padLeft(2, '0');

/// « 14:05 »
String formaterHeure(DateTime d) =>
    '${_deuxChiffres(d.hour)}:${_deuxChiffres(d.minute)}';

/// « Aujourd'hui », « Hier » ou « lundi 19 octobre 2026 ».
String formaterJour(DateTime d, {DateTime? maintenant}) {
  final now = maintenant ?? DateTime.now();
  final jour = DateTime(d.year, d.month, d.day);
  final aujourdhui = DateTime(now.year, now.month, now.day);
  final ecart = aujourdhui.difference(jour).inDays;
  if (ecart == 0) return 'Aujourd\'hui';
  if (ecart == 1) return 'Hier';
  return formaterDate(d);
}

/// « lundi 19 octobre 2026 ».
String formaterDate(DateTime d) =>
    '${_jours[d.weekday - 1]} ${d.day} ${_mois[d.month - 1]} ${d.year}';

IconData iconeHistorique(CategorieHistorique c) {
  switch (c) {
    case CategorieHistorique.creation:
      return Icons.auto_awesome;
    case CategorieHistorique.identite:
      return Icons.badge_outlined;
    case CategorieHistorique.niveau:
      return Icons.trending_up;
    case CategorieHistorique.vie:
      return Icons.favorite_outline;
    case CategorieHistorique.inventaire:
      return Icons.backpack_outlined;
    case CategorieHistorique.bourse:
      return Icons.account_balance_wallet_outlined;
    case CategorieHistorique.competences:
      return Icons.auto_stories_outlined;
    case CategorieHistorique.notes:
      return Icons.edit_note;
    case CategorieHistorique.des:
      return Icons.casino_outlined;
    case CategorieHistorique.autre:
      return Icons.history;
  }
}

/// « Séance 3 · Test de FOR : 15 » (anciens jets de séance) → « Séance 3 ».
final RegExp _prefixeSeance = RegExp(r'^(Séance \d+[^·]*?) · ');

/// Séance d'un événement : celle enregistrée, sinon le préfixe des anciens
/// jets de séance ; `null` hors séance.
String? seanceDe(EvenementHistorique e) =>
    e.seance ?? _prefixeSeance.firstMatch(e.message)?.group(1);

/// Message sans le préfixe « Séance 3 · » (il est dans le titre du cadre).
String sansPrefixeSeance(String m) => m.replaceFirst(_prefixeSeance, '');

/// Journal des modifications du personnage, du plus récent au plus ancien,
/// regroupé par jour, avec un filtre par catégorie.
class OngletHistorique extends StatefulWidget {
  const OngletHistorique({super.key, required this.personnage});

  final Personnage personnage;

  @override
  State<OngletHistorique> createState() => _OngletHistoriqueState();
}

class _OngletHistoriqueState extends State<OngletHistorique> {
  /// `null` = toutes les catégories.
  CategorieHistorique? _filtre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Anciens lancers de la page dé (« Lancer · … ») : plus affichés ; les
    // jets de séance restent.
    final tous = [
      for (final e in widget.personnage.historique)
        if (!(e.categorie == CategorieHistorique.des &&
            e.message.startsWith('Lancer · ')))
          e,
    ];
    final presentes = {for (final e in tous) e.categorie};
    final evenements = [
      for (final e in tous.reversed)
        if (_filtre == null || e.categorie == _filtre) e,
    ];

    Widget ligne(EvenementHistorique e, String message) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  formaterHeure(e.date),
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              Icon(
                iconeHistorique(e.categorie),
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        );

    // Événements d'une même séance, à la suite : un seul cadre repliable.
    final lignes = <Widget>[];
    String? jourCourant;
    var i = 0;
    while (i < evenements.length) {
      final e = evenements[i];
      final jour = formaterJour(e.date);
      if (jour != jourCourant) {
        jourCourant = jour;
        lignes.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
            child: Text(
              jour[0].toUpperCase() + jour.substring(1),
              style:
                  theme.textTheme.titleSmall?.copyWith(color: scheme.primary),
            ),
          ),
        );
      }
      final seance = seanceDe(e);
      if (seance == null) {
        lignes.add(ligne(e, e.message));
        i++;
        continue;
      }
      final groupe = <EvenementHistorique>[];
      while (i < evenements.length && seanceDe(evenements[i]) == seance) {
        groupe.add(evenements[i]);
        i++;
      }
      lignes.add(
        Card(
          key: Key(
              'groupe-seance-$seance-${groupe.first.date.toIso8601String()}'),
          margin: const EdgeInsets.symmetric(vertical: 6),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            leading: Icon(Icons.groups_outlined, color: scheme.primary),
            title: Text(seance, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              '${groupe.length} événement${groupe.length > 1 ? 's' : ''} · '
              '${formaterHeure(groupe.last.date)} – '
              '${formaterHeure(groupe.first.date)}',
            ),
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            shape: const Border(),
            collapsedShape: const Border(),
            children: [
              for (final x in groupe) ligne(x, sansPrefixeSeance(x.message)),
            ],
          ),
        ),
      );
    }

    return ListView(
      key: const PageStorageKey('onglet-historique'),
      padding: const EdgeInsets.all(16),
      children: [
        if (presentes.length > 1)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                key: const Key('filtre-tout'),
                label: const Text('Tout'),
                selected: _filtre == null,
                onSelected: (_) => setState(() => _filtre = null),
              ),
              for (final c in CategorieHistorique.values)
                if (presentes.contains(c))
                  ChoiceChip(
                    key: Key('filtre-${c.name}'),
                    avatar: Icon(iconeHistorique(c), size: 16),
                    label: Text(c.libelle),
                    selected: _filtre == c,
                    onSelected: (_) => setState(() => _filtre = c),
                  ),
            ],
          ),
        if (evenements.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Text(
              'Aucune modification enregistrée pour l\'instant.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          )
        else
          ...lignes,
        if (tous.length >= Personnage.tailleMaxHistorique)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Seules les ${Personnage.tailleMaxHistorique} dernières '
              'modifications sont conservées.',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
