import 'package:flutter/material.dart';

import '../models/carac.dart';
import '../regles/fiche_calculee.dart';
import '../theme.dart';

/// Widgets communs aux pages de consultation (Classes, Races, Équipements,
/// Bestiaire, Règles).

/// Centre le contenu et limite sa largeur sur grand écran.
class LargeurLimitee extends StatelessWidget {
  const LargeurLimitee({super.key, required this.child, this.max = 760});

  final Widget child;
  final double max;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: max),
        child: child,
      ),
    );
  }
}

/// Encadré avec un titre (et une icône), pour regrouper des informations.
class BlocConsultation extends StatelessWidget {
  const BlocConsultation({
    super.key,
    required this.titre,
    required this.children,
    this.icone,
  });

  final String titre;
  final IconData? icone;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (icone != null) ...[
                  Icon(icone, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    titre,
                    style: styleAmbiance(theme.textTheme.titleMedium)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Texte grisé en italique pour une information pas encore définie.
class TexteAVenir extends StatelessWidget {
  const TexteAVenir(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Text(
      texte,
      style: TextStyle(
        fontStyle: FontStyle.italic,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Petite étiquette arrondie (famille, taille, catégorie…).
class Etiquette extends StatelessWidget {
  const Etiquette(this.texte, {super.key, this.icone});

  final String texte;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 14, color: scheme.onSecondaryContainer),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              texte,
              style: TextStyle(color: scheme.onSecondaryContainer),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Champ de recherche des pages de consultation.
class ChampRecherche extends StatelessWidget {
  const ChampRecherche({
    super.key,
    required this.onChanged,
    this.indice = 'Rechercher',
  });

  final ValueChanged<String> onChanged;
  final String indice;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('champ-recherche'),
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: indice,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

/// « +3 FOR, −2 INT » (ou « aucun »).
String formaterModificateurs(Map<Carac, int> modifs) {
  final liste = [
    for (final c in Carac.values)
      if ((modifs[c] ?? 0) != 0)
        '${formaterModificateur(modifs[c]!)} ${c.abrev}',
  ];
  return liste.isEmpty ? 'aucun' : liste.join(', ');
}

/// Minuscules sans accents, pour une recherche tolérante.
String normaliserRecherche(String texte) {
  const accents = {
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'ç': 'c',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'ô': 'o',
    'ö': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'œ': 'oe',
    'æ': 'ae',
  };
  final b = StringBuffer();
  for (final ch in texte.toLowerCase().split('')) {
    b.write(accents[ch] ?? ch);
  }
  return b.toString();
}

/// Vrai si [texte] contient [recherche] (sans tenir compte des accents ni
/// des majuscules). Une recherche vide correspond à tout.
bool correspond(String texte, String recherche) {
  final r = normaliserRecherche(recherche.trim());
  return r.isEmpty || normaliserRecherche(texte).contains(r);
}
