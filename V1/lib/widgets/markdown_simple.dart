import 'dart:math';

import 'package:flutter/material.dart';

/// Mini-lecteur Markdown pour la page des règles (pas de paquet externe).
/// Gère : titres `#`, `##`, `###`, listes `- `, citations `> `, tableaux
/// `| a | b |`, paragraphes, et dans le texte `**gras**`, `*italique*`,
/// `` `code` ``.

/// Une section `## Titre` du document et ses lignes.
class SectionMarkdown {
  SectionMarkdown(this.titre, this.lignes);

  final String titre;
  final List<String> lignes;

  String get texte => '$titre\n${lignes.join('\n')}';
}

/// Document découpé : titre (`#`), introduction, sections (`##`).
class DocumentMarkdown {
  DocumentMarkdown({
    required this.titre,
    required this.introduction,
    required this.sections,
  });

  final String titre;
  final List<String> introduction;
  final List<SectionMarkdown> sections;

  factory DocumentMarkdown.lire(String source) {
    var titre = '';
    final intro = <String>[];
    final sections = <SectionMarkdown>[];
    for (final brute in source.split('\n')) {
      final ligne = brute.trimRight();
      if (ligne.startsWith('## ')) {
        sections.add(SectionMarkdown(ligne.substring(3).trim(), []));
      } else if (ligne.startsWith('# ') && titre.isEmpty && sections.isEmpty) {
        titre = ligne.substring(2).trim();
      } else if (sections.isEmpty) {
        intro.add(ligne);
      } else {
        sections.last.lignes.add(ligne);
      }
    }
    return DocumentMarkdown(
      titre: titre,
      introduction: intro,
      sections: sections,
    );
  }
}

/// Affiche une liste de lignes Markdown (contenu d'une section).
class BlocsMarkdown extends StatelessWidget {
  const BlocsMarkdown(this.lignes, {super.key});

  final List<String> lignes;

  static final _separateurTableau = RegExp(r'^\|[\s\-:|]+\|$');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final blocs = <Widget>[];
    var i = 0;
    while (i < lignes.length) {
      final ligne = lignes[i].trim();
      if (ligne.isEmpty) {
        i++;
        continue;
      }
      if (ligne.startsWith('|')) {
        final rangees = <List<String>>[];
        while (i < lignes.length && lignes[i].trim().startsWith('|')) {
          final l = lignes[i].trim();
          if (!_separateurTableau.hasMatch(l)) rangees.add(_cellules(l));
          i++;
        }
        blocs.add(_Tableau(rangees));
        continue;
      }
      if (ligne.startsWith('### ')) {
        blocs.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              ligne.substring(4),
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      } else if (ligne.startsWith('- ') || ligne.startsWith('* ')) {
        blocs.add(
          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 3, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: TexteMarkdown(ligne.substring(2))),
              ],
            ),
          ),
        );
      } else if (ligne.startsWith('>')) {
        blocs.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              border: Border(left: BorderSide(color: scheme.primary, width: 3)),
            ),
            child: TexteMarkdown(ligne.substring(1).trim()),
          ),
        );
      } else {
        blocs.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TexteMarkdown(ligne),
          ),
        );
      }
      i++;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: blocs,
    );
  }

  static List<String> _cellules(String ligne) {
    var l = ligne;
    if (l.startsWith('|')) l = l.substring(1);
    if (l.endsWith('|')) l = l.substring(0, l.length - 1);
    return l.split('|').map((c) => c.trim()).toList();
  }
}

/// Tableau : en-tête sur la première rangée ; défile horizontalement sur
/// petit écran si les colonnes sont nombreuses.
class _Tableau extends StatelessWidget {
  const _Tableau(this.rangees);

  final List<List<String>> rangees;

  @override
  Widget build(BuildContext context) {
    if (rangees.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final colonnes = rangees.map((r) => r.length).reduce(max);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, contraintes) {
          final largeur = max(contraintes.maxWidth, colonnes * 96.0);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: largeur,
              child: Table(
                border: TableBorder.all(color: scheme.outlineVariant),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  for (var r = 0; r < rangees.length; r++)
                    TableRow(
                      decoration: r == 0
                          ? BoxDecoration(color: scheme.secondaryContainer)
                          : null,
                      children: [
                        for (var c = 0; c < colonnes; c++)
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: TexteMarkdown(
                              c < rangees[r].length ? rangees[r][c] : '',
                              gras: r == 0,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Texte avec mise en forme en ligne : `**gras**`, `*italique*`, `` `code` ``.
class TexteMarkdown extends StatelessWidget {
  const TexteMarkdown(this.texte, {super.key, this.gras = false});

  final String texte;
  final bool gras;

  static final _motif = RegExp(r'(\*\*[^*]+\*\*|\*[^*\s][^*]*\*|`[^`]+`)');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final morceaux = <InlineSpan>[];
    var position = 0;
    for (final m in _motif.allMatches(texte)) {
      if (m.start > position) {
        morceaux.add(TextSpan(text: texte.substring(position, m.start)));
      }
      final t = m.group(0)!;
      if (t.startsWith('**')) {
        morceaux.add(
          TextSpan(
            text: t.substring(2, t.length - 2),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      } else if (t.startsWith('`')) {
        morceaux.add(
          TextSpan(
            text: t.substring(1, t.length - 1),
            style: TextStyle(
              fontFamily: 'monospace',
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        );
      } else {
        morceaux.add(
          TextSpan(
            text: t.substring(1, t.length - 1),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      }
      position = m.end;
    }
    if (position < texte.length) {
      morceaux.add(TextSpan(text: texte.substring(position)));
    }
    return Text.rich(
      TextSpan(
        style: gras ? const TextStyle(fontWeight: FontWeight.w700) : null,
        children: morceaux,
      ),
    );
  }
}
