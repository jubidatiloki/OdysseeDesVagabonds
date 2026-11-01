import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../widgets/consultation.dart';
import '../widgets/markdown_simple.dart';

/// Page « Règles système » : les règles du jeu (assets/data/regles_systeme.md),
/// en sections dépliables, avec une recherche.
class ReglesScreen extends StatefulWidget {
  const ReglesScreen({super.key, required this.referentiel, this.menu});

  final Referentiel referentiel;
  final Widget? menu;

  @override
  State<ReglesScreen> createState() => _ReglesScreenState();
}

class _ReglesScreenState extends State<ReglesScreen> {
  late final DocumentMarkdown _document =
      DocumentMarkdown.lire(widget.referentiel.reglesSysteme);
  String _recherche = '';

  @override
  Widget build(BuildContext context) {
    final enRecherche = _recherche.trim().isNotEmpty;
    final sections = [
      for (final s in _document.sections)
        if (correspond(s.texte, _recherche)) s,
    ];
    return Scaffold(
      drawer: widget.menu,
      appBar: AppBar(title: const Text('Règles système')),
      body: LargeurLimitee(
        max: 900,
        child: _document.sections.isEmpty
            ? const Center(child: TexteAVenir('Règles indisponibles.'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_document.introduction.any((l) => l.trim().isNotEmpty))
                    BlocsMarkdown(_document.introduction),
                  const SizedBox(height: 8),
                  ChampRecherche(
                    indice: 'Rechercher dans les règles',
                    onChanged: (t) => setState(() => _recherche = t),
                  ),
                  const SizedBox(height: 12),
                  if (sections.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: TexteAVenir('Aucune règle ne correspond.'),
                      ),
                    ),
                  for (final s in sections)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        // Clé liée à la recherche : les sections trouvées
                        // s'ouvrent, et se referment quand on l'efface.
                        key: ValueKey('${s.titre}-$enRecherche'),
                        initiallyExpanded: enRecherche,
                        title: Text(
                          s.titre,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [BlocsMarkdown(s.lignes)],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
