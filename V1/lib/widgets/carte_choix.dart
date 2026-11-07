import 'package:flutter/material.dart';

import '../models/equipement.dart';
import '../models/voie.dart';
import 'voie_detail.dart';

/// Choix à faire pour une compétence ou un passif (élément du souffle,
/// compétence de « Sang mêlé », bonus de « Chef de guerre ») : une
/// pastille par option, l'effet de l'option choisie en dessous.
class CarteChoix extends StatelessWidget {
  const CarteChoix({
    super.key,
    required this.nom,
    required this.choix,
    required this.valeur,
    required this.onChoisir,
    this.origine,
    this.precision = '',
    this.onPrecision,
    this.validerPrecision = false,
    this.elements,
    this.catalogue = const [],
    this.permises,
  });

  /// Options proposées (`null` : toutes) : « Perfectionnement » → la
  /// caractéristique la plus faible.
  final Set<String>? permises;

  /// Compétence ou passif concerné (« Sang mêlé »).
  final String nom;
  final String? origine;
  final ChoixCompetence choix;

  /// Option choisie (`null` : pas encore choisie).
  final String? valeur;
  final ValueChanged<String> onChoisir;

  /// Précision saisie pour l'option choisie (« Luth ») quand elle pose une
  /// question (« Quel instrument ? »).
  final String precision;
  final ValueChanged<String>? onPrecision;

  /// Précision envoyée avec un bouton « Valider » (sinon à chaque frappe).
  final bool validerPrecision;

  /// Éléments d'une liste (`armes`, `instruments`) avec « déjà maîtrisé » ;
  /// `null` : saisie libre seulement.
  final List<({String nom, bool maitrise})> Function(String liste)? elements;

  /// Catalogue des équipements : affiche les statistiques des armes et des
  /// instruments proposés.
  final List<Equipement> catalogue;

  /// Sélection à la place de `{precision}` dans les textes affichés.
  String get _selection => precision.isEmpty ? 'la sélection' : precision;
  String _avecPrecision(String texte) =>
      texte.replaceAll('{precision}', _selection);

  /// Équipement du catalogue portant ce nom, s'il y en a un.
  Equipement? _equipement(String nom) {
    final n = nom.trim().toLowerCase();
    for (final e in catalogue) {
      if (e.nom.trim().toLowerCase() == n) return e;
    }
    return null;
  }

  /// Équipements offerts par les options : leurs statistiques sont visibles
  /// avant de choisir (Outils de nain : hache ou marteau de guerre).
  List<Equipement> get _equipementsOfferts {
    final res = <Equipement>[];
    for (final o in choix.options) {
      if (o.cache) continue;
      for (final objet in o.objets) {
        final e = _equipement('${objet['nom'] ?? ''}');
        if (e != null && e.resumeStats.isNotEmpty && !res.contains(e)) {
          res.add(e);
        }
      }
    }
    return res;
  }

  /// « +1 au toucher » : ce que donne l'option « déjà maîtrisé » de [o].
  String _bonusSiMaitrise(OptionChoix o) {
    final cible = choix.option(o.siDejaMaitrise);
    if (cible == null) return '';
    final i = cible.nom.indexOf(':');
    return _avecPrecision(
      i < 0 ? cible.nom : cible.nom.substring(i + 1).trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final choisie = choix.option(valeur);
    // Option affichée comme choisie : une option interne renvoie à celle
    // qui la désigne (« arme-maitrisee » → « Arme »).
    OptionChoix? visible = choisie;
    if (choisie != null && choisie.cache) {
      for (final o in choix.options) {
        if (o.siDejaMaitrise == choisie.id) visible = o;
      }
    }
    // Une seule option (« Nouvelle langue ») : sa liste ou sa question est
    // affichée d'emblée, la choisir y répond.
    final visibles = [
      for (final o in choix.options)
        if (!o.cache && (permises?.contains(o.id) ?? true)) o,
    ];
    final seule = visibles.length == 1 ? visibles.first : null;
    final cible = visible ?? seule;
    final aPreciser = choisie ?? seule;
    // Choix multiple (modules du golem, Vagabond) : les options cochées ;
    // complet quand il y en a autant que demandé.
    final multiples =
        choix.nombre > 1 ? choix.choisies(valeur) : const <OptionChoix>[];
    final complet =
        choix.nombre > 1 ? multiples.length >= choix.nombre : choisie != null;
    return Card(
      key: Key('choix-${choix.cle}'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: !complet ? scheme.tertiary : scheme.outlineVariant,
          width: !complet ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  !complet ? Icons.help_outline : Icons.check_circle,
                  size: 20,
                  color: !complet ? scheme.tertiary : scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$nom · ${choix.titre.isEmpty ? 'Choix' : choix.titre}',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            if (origine != null)
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  origine!,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            const SizedBox(height: 10),
            if (choix.nombre > 1)
              // Choix multiple (Vagabond : 6 stats) : pastilles à cocher.
              () {
                final faits = {
                  for (final o in choix.choisies(valeur)) o.id,
                };
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${faits.length} / ${choix.nombre} choisies',
                      key: Key('compte-${choix.cle}'),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: faits.length == choix.nombre
                            ? scheme.primary
                            : scheme.tertiary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final o in visibles)
                          FilterChip(
                            key: Key('option-${choix.cle}-${o.id}'),
                            label: Text(o.nom.isEmpty ? o.id : o.nom),
                            selected: faits.contains(o.id),
                            onSelected: !faits.contains(o.id) &&
                                    faits.length >= choix.nombre
                                ? null
                                : (oui) {
                                    final ids = [
                                      for (final x in choix.options)
                                        if (x.id == o.id
                                            ? oui
                                            : faits.contains(x.id))
                                          x.id,
                                    ];
                                    onChoisir(ids.join(','));
                                  },
                          ),
                      ],
                    ),
                  ],
                );
              }()
            else if (visibles.length > 12)
              // Beaucoup d'options (compétence d'une autre classe) : liste.
              DropdownButtonFormField<String>(
                key: Key('liste-options-${choix.cle}'),
                initialValue: visible?.id,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: choix.titre.isEmpty ? 'Choix' : choix.titre,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  for (final o in visibles)
                    DropdownMenuItem(
                      value: o.id,
                      child: Text(
                        o.nom.isEmpty ? o.id : o.nom,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (id) {
                  if (id != null) onChoisir(id);
                },
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Options internes (« déjà maîtrisée ») : pas de pastille,
                  // leur option visible reste sélectionnée.
                  for (final o in visibles)
                    ChoiceChip(
                      key: Key('option-${choix.cle}-${o.id}'),
                      label: Text(o.nom.isEmpty ? o.id : o.nom),
                      selected: o.id == visible?.id,
                      onSelected: (_) => onChoisir(o.id),
                    ),
                ],
              ),
            // Armes et instruments offerts : statistiques avant de choisir.
            for (final e in _equipementsOfferts) _StatsEquipement(e),
            // Liste déroulante (armes, instruments) : déjà maîtrisé → option
            // « bonus », sinon nouvelle maîtrise.
            // Écuyer : trois propositions (nom et description) en cartes.
            if (cible != null && cible.liste == 'ecuyers' && elements != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  key: Key('propositions-${choix.cle}'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (cible.question.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(cible.question,
                            style: theme.textTheme.titleSmall),
                      ),
                    for (final (i, e) in elements!(cible.liste).indexed)
                      _CarteProposition(
                        key: Key('proposition-${choix.cle}-$i'),
                        texte: e.nom,
                        choisie: e.nom == precision,
                        onTap: () {
                          onChoisir(cible.id);
                          onPrecision?.call(e.nom);
                        },
                      ),
                  ],
                ),
              )
            else if (cible != null &&
                cible.liste.isNotEmpty &&
                elements != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _ListeElements(
                  key: Key('liste-${choix.cle}-${cible.id}'),
                  cle: choix.cle,
                  question: cible.question,
                  // Langues : seulement celles qu'il ne parle pas encore
                  // (sauf celle déjà choisie ici).
                  elements: [
                    for (final e in elements!(cible.liste))
                      if (cible.liste != 'langues' ||
                          !e.maitrise ||
                          e.nom == precision)
                        e,
                  ],
                  bonus: _bonusSiMaitrise(cible),
                  // Savoirs : pas de « nouvelle maîtrise » (simple bonus).
                  mentionNouveau: cible.liste != 'savoirs',
                  selection: precision,
                  equipement: _equipement,
                  onChoisir: (nom, maitrise) {
                    final o = cible;
                    onChoisir(maitrise && o.siDejaMaitrise.isNotEmpty
                        ? o.siDejaMaitrise
                        : o.id);
                    onPrecision?.call(nom);
                  },
                ),
              )
            else if (aPreciser != null && aPreciser.question.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _ChampPrecision(
                  key: Key('precision-${choix.cle}-${aPreciser.id}'),
                  question: aPreciser.question,
                  initial: precision,
                  valider: validerPrecision,
                  onPrecision: (t) {
                    if (choisie == null) onChoisir(aPreciser.id);
                    onPrecision?.call(t);
                  },
                  cle: choix.cle,
                ),
              ),
            // Choix multiple : effets de chaque option cochée.
            for (final o in multiples)
              if (o.effet.isNotEmpty || o.effets.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  o.nom,
                  key: Key('effets-${choix.cle}-${o.id}'),
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (o.effet.isNotEmpty)
                  Text(_avecPrecision(o.effet),
                      style: theme.textTheme.bodyMedium),
                if (o.effets.isNotEmpty)
                  ListeEffets([
                    for (final e in o.effets) e.avecPrecision(_selection),
                  ]),
              ],
            if (choix.nombre <= 1 &&
                choisie != null &&
                (choisie.effet.isNotEmpty || choisie.effets.isNotEmpty)) ...[
              const SizedBox(height: 8),
              if (choisie.effet.isNotEmpty)
                Text(_avecPrecision(choisie.effet),
                    style: theme.textTheme.bodyMedium),
              if (choisie.effets.isNotEmpty)
                ListeEffets([
                  for (final e in choisie.effets) e.avecPrecision(_selection),
                ]),
            ],
          ],
        ),
      ),
    );
  }
}

/// Une proposition à choisir (écuyer : « Nom — description ») : nom en
/// gras, description dessous, coche quand elle est retenue.
class _CarteProposition extends StatelessWidget {
  const _CarteProposition({
    super.key,
    required this.texte,
    required this.choisie,
    required this.onTap,
  });

  final String texte;
  final bool choisie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final i = texte.indexOf(' — ');
    final nom = i < 0 ? texte : texte.substring(0, i);
    final description = i < 0 ? '' : texte.substring(i + 3);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: choisie ? scheme.secondaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: choisie ? scheme.primary : scheme.outlineVariant,
            width: choisie ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  choisie ? Icons.check_circle : Icons.person_outline,
                  color: scheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nom,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (description.isNotEmpty)
                        Text(description, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Saisie de la précision d'une option (« Quelle arme ? »).
class _ChampPrecision extends StatefulWidget {
  const _ChampPrecision({
    super.key,
    required this.question,
    required this.initial,
    required this.valider,
    required this.onPrecision,
    required this.cle,
  });

  final String question;
  final String initial;
  final bool valider;
  final ValueChanged<String>? onPrecision;
  final String cle;

  @override
  State<_ChampPrecision> createState() => _ChampPrecisionState();
}

class _ChampPrecisionState extends State<_ChampPrecision> {
  late final TextEditingController _texte =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final champ = TextField(
      key: Key('champ-precision-${widget.cle}'),
      controller: _texte,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: widget.question,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: widget.valider
          ? (_) => setState(() {})
          : (t) => widget.onPrecision?.call(t.trim()),
    );
    if (!widget.valider) return champ;
    return Row(
      children: [
        Expanded(child: champ),
        const SizedBox(width: 8),
        FilledButton(
          key: Key('valider-precision-${widget.cle}'),
          onPressed: _texte.text.trim().isEmpty
              ? null
              : () => widget.onPrecision?.call(_texte.text.trim()),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}

/// Liste déroulante des éléments d'un choix (armes, instruments), avec
/// l'indication « déjà maîtrisé → bonus » ou « nouvelle maîtrise », et
/// « Autre… » pour saisir un nom absent de la liste.
/// Statistiques d'une arme ou d'un instrument proposé dans un choix.
class _StatsEquipement extends StatelessWidget {
  const _StatsEquipement(this.equipement);

  final Equipement equipement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: scheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${equipement.nom} : ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: equipement.resumeStats),
                ],
              ),
              key: Key('stats-choix-${equipement.id}'),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListeElements extends StatefulWidget {
  const _ListeElements({
    super.key,
    required this.cle,
    required this.question,
    required this.elements,
    required this.bonus,
    required this.selection,
    required this.onChoisir,
    required this.equipement,
    this.mentionNouveau = true,
  });

  /// Fiche du catalogue d'un élément, pour afficher ses statistiques.
  final Equipement? Function(String nom) equipement;

  /// « · nouvelle maîtrise » après un élément pas encore maîtrisé.
  final bool mentionNouveau;

  final String cle;
  final String question;
  final List<({String nom, bool maitrise})> elements;

  /// Ce que donne un élément déjà maîtrisé (« +1 au toucher »).
  final String bonus;
  final String selection;
  final void Function(String nom, bool maitrise) onChoisir;

  @override
  State<_ListeElements> createState() => _ListeElementsState();
}

class _ListeElementsState extends State<_ListeElements> {
  static const _autre = '__autre__';
  late final TextEditingController _texte = TextEditingController(
    text: _dansListe ? '' : widget.selection,
  );
  late bool _saisieLibre = widget.selection.isNotEmpty && !_dansListe;

  bool get _dansListe => widget.elements.any((e) => e.nom == widget.selection);

  /// Équipement choisi, quand il a des statistiques à montrer.
  Equipement? get _choisi {
    final e = widget.equipement(widget.selection);
    return !_saisieLibre && e != null && e.resumeStats.isNotEmpty ? e : null;
  }

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vert = theme.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: Key('liste-elements-${widget.cle}'),
          initialValue:
              _saisieLibre ? _autre : (_dansListe ? widget.selection : null),
          isExpanded: true,
          decoration: InputDecoration(
            labelText: widget.question,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            for (final e in widget.elements)
              DropdownMenuItem(
                value: e.nom,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: e.nom),
                      if (widget.equipement(e.nom)?.degatsCourts case final d?
                          when d.isNotEmpty)
                        TextSpan(text: ' ($d)'),
                      TextSpan(
                        text: e.maitrise
                            ? (widget.bonus.isEmpty
                                ? '  · déjà connu'
                                : '  · déjà maîtrisé → ${widget.bonus}')
                            : (widget.mentionNouveau
                                ? '  · nouvelle maîtrise'
                                : ''),
                        style: TextStyle(
                          color: e.maitrise
                              ? vert
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              e.maitrise ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const DropdownMenuItem(value: _autre, child: Text('Autre…')),
          ],
          onChanged: (v) {
            if (v == null) return;
            if (v == _autre) {
              setState(() => _saisieLibre = true);
              return;
            }
            setState(() => _saisieLibre = false);
            final e = widget.elements.firstWhere((x) => x.nom == v);
            widget.onChoisir(e.nom, e.maitrise);
          },
        ),
        // Statistiques de l'arme ou de l'instrument choisi.
        if (_choisi case final e?) _StatsEquipement(e),
        if (_saisieLibre) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: Key('champ-autre-${widget.cle}'),
                  controller: _texte,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nom (nouvelle maîtrise)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: Key('valider-autre-${widget.cle}'),
                onPressed: _texte.text.trim().isEmpty
                    ? null
                    : () => widget.onChoisir(_texte.text.trim(), false),
                child: const Text('Valider'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
