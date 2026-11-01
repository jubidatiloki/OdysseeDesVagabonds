import 'package:flutter/material.dart';

import '../../models/aptitude.dart';
import '../../models/langues.dart';
import '../../models/classe.dart';
import '../../models/race.dart';
import '../../models/voie.dart';
import '../../regles/progression.dart';
import '../../widgets/libelles_sort.dart';
import '../../widgets/voie_detail.dart';

/// Choix des premières compétences : voie raciale (rang 1 offert),
/// rangs des voies de classe et aptitudes (1 point chacune).
/// Dépenser tous les points n'est pas obligatoire : le reste est conservé
/// pour les niveaux suivants.
class EtapeCompetences extends StatelessWidget {
  const EtapeCompetences({
    super.key,
    required this.race,
    required this.classe,
    required this.niveau,
    required this.rangsVoies,
    required this.aptitudes,
    required this.catalogueAptitudes,
    required this.intFinale,
    required this.onChange,
    required this.onAptitudes,
    this.titre = 'Choisis tes compétences',
    this.rangsVerrouilles = const {},
    this.aptitudesVerrouillees = const [],
  });

  final String titre;

  /// Rangs déjà acquis avant cet écran (montée de niveau) : ne peuvent pas
  /// être retirés.
  final Map<String, int> rangsVerrouilles;

  /// Aptitudes déjà acquises avant cet écran : ne peuvent pas être retirées.
  final List<AptitudeAcquise> aptitudesVerrouillees;

  final Race race;
  final Classe classe;
  final int niveau;
  final Map<String, int> rangsVoies;
  final List<AptitudeAcquise> aptitudes;
  final List<Aptitude> catalogueAptitudes;

  /// INT finale du personnage (lire et écrire est inné si INT ≥ 10).
  final int intFinale;
  final ValueChanged<Map<String, int>> onChange;
  final ValueChanged<List<AptitudeAcquise>> onAptitudes;

  int get _total => Progression.pointsTotaux(niveau, race);
  int get _restants => Progression.pointsRestants(
        niveau: niveau,
        race: race,
        rangsVoies: rangsVoies,
        aptitudes: aptitudes.length,
      );

  void _monter(Voie v) {
    final copie = Map<String, int>.of(rangsVoies);
    copie[v.id] = (copie[v.id] ?? 0) + 1;
    onChange(copie);
  }

  void _descendre(Voie v) {
    final copie = Map<String, int>.of(rangsVoies);
    final rang = (copie[v.id] ?? 0) - 1;
    if (rang <= 0) {
      copie.remove(v.id);
    } else {
      copie[v.id] = rang;
    }
    onChange(copie);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final restants = _restants;
    final voieRaciale = race.voieRaciale;
    final rangRacial = Progression.rangRacial(niveau);

    // Points disponibles : fixés en haut, toujours visibles pendant qu'on
    // fait défiler les voies et les aptitudes.
    final bandeau = Container(
      key: const Key('bandeau-points'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:
            restants == 0 ? scheme.primaryContainer : scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            restants == 0 ? Icons.check_circle : Icons.auto_awesome,
            color: restants == 0
                ? scheme.onPrimaryContainer
                : scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              restants == 0
                  ? 'Tous les points sont dépensés'
                  : 'Points disponibles',
              style: theme.textTheme.titleMedium,
            ),
          ),
          Text(
            '$restants / $_total',
            key: const Key('points-competence'),
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: bandeau,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              Text(titre, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Dépense tes points dans les voies de ta classe (au niveau $niveau, '
                'jusqu\'au rang $niveau) ou dans des aptitudes à 1 point. '
                'Rien n\'oblige à tout dépenser : les points restants sont '
                'conservés pour les niveaux suivants.'
                '${race.pointsCompetenceBonus > 0 ? ' Bonus de race : +${race.pointsCompetenceBonus} point.' : ''}',
              ),
              if (voieRaciale != null) ...[
                const SizedBox(height: 16),
                _CarteVoie(
                  titre: voieRaciale.nom,
                  sousTitre: 'Voie raciale · rang $rangRacial offert',
                  enfants: [
                    for (final c in voieRaciale.competences)
                      if (c.rang <= rangRacial) ...[
                        LigneCompetence(competence: c, acquise: true),
                        for (final a in c.aussi)
                          LigneCompetence(competence: a, acquise: true),
                      ],
                  ],
                ),
              ],
              for (final v in classe.voies) ...[
                const SizedBox(height: 12),
                _carteVoieClasse(context, v),
              ],
              const SizedBox(height: 24),
              Text(
                'Aptitudes et connaissances',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '1 point chacune.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              // Un cadre par groupe : connaissances (savoirs), aptitudes
              // (savoir-faire), puis maîtrises et autres.
              for (final (f, icone) in const [
                (FamilleAptitude.savoir, Icons.menu_book_outlined),
                (FamilleAptitude.savoirFaire, Icons.handyman_outlined),
                (FamilleAptitude.autre, Icons.military_tech_outlined),
              ])
                if (catalogueAptitudes
                    .any((a) => !a.estSort && a.famille == f)) ...[
                  const SizedBox(height: 12),
                  _CarteGroupe(
                    key: Key('famille-aptitudes-${f.name}'),
                    icone: icone,
                    titre: f.libelle,
                    sousTitre: f.sousTitre,
                    acquises:
                        _nombreAcquises((a) => !a.estSort && a.famille == f),
                    enfants: [
                      for (final a in catalogueAptitudes)
                        if (!a.estSort && a.famille == f)
                          _ligneAptitude(context, a),
                    ],
                  ),
                ],
              // Sorts de rang 0 : classes lanceuses de sorts ou hybrides.
              if (catalogueAptitudes
                  .any((a) => a.estSort && a.disponiblePour(classe))) ...[
                const SizedBox(height: 12),
                _CarteGroupe(
                  key: const Key('titre-sorts-rang0'),
                  icone: Icons.auto_awesome,
                  titre: 'Sorts de rang 0',
                  sousTitre:
                      '1 point chacun · 0 PM · une fois par tour · pas de maintien',
                  acquises: _nombreAcquises(
                      (a) => a.estSort && a.disponiblePour(classe)),
                  enfants: [
                    for (final a in catalogueAptitudes)
                      if (a.estSort && a.disponiblePour(classe))
                        _ligneAptitude(context, a),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Aptitudes acquises parmi celles du groupe (filtre sur le catalogue).
  int _nombreAcquises(bool Function(Aptitude) dansLeGroupe) {
    final ids = {
      for (final a in catalogueAptitudes)
        if (dansLeGroupe(a)) a.id,
    };
    return aptitudes.where((x) => ids.contains(x.id)).length;
  }

  bool _estInnee(Aptitude a) => a.estInnee(raceId: race.id, intel: intFinale);

  Widget _ligneAptitude(BuildContext context, Aptitude a) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final acquises = [
      for (final x in aptitudes)
        if (x.id == a.id) x,
    ];
    final innee = _estInnee(a);
    final peutPrendre = !innee &&
        _restants >= Progression.coutAptitude &&
        (a.multiple || acquises.isEmpty);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.nom,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                // « Savoir complexe · INT » puis l'effet en jeu.
                if (a.resume.isNotEmpty)
                  Text(
                    a.regle.isEmpty ? a.resume : '${a.resume} · ${a.regle}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: a.complexe ? scheme.tertiary : scheme.primary,
                    ),
                  ),
                // Sort de rang 0 : mana, dégâts, effet.
                if (a.sort case final s?) ...[
                  const SizedBox(height: 4),
                  LibellesSort(s),
                  const SizedBox(height: 2),
                ],
                Text(
                  innee
                      ? (a.race == race.id
                          ? 'Déjà acquis (sa propre race).'
                          : 'Déjà acquis (INT ≥ ${a.inneeSiIntAuMoins}).')
                      : a.description,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                if (acquises.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final x in acquises)
                        InputChip(
                          key: Key(
                              'aptitude-acquise-${a.id}-${x.precision ?? ''}'),
                          label: Text(x.precision ?? 'Acquis'),
                          onDeleted: aptitudesVerrouillees.contains(x)
                              ? null
                              : () => onAptitudes(
                                    List.of(aptitudes)..remove(x),
                                  ),
                          deleteButtonTooltipMessage: 'Retirer',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            key: Key('aptitude-${a.id}'),
            tooltip: 'Prendre (1 point)',
            onPressed: peutPrendre ? () => _ajouterAptitude(context, a) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Future<void> _ajouterAptitude(BuildContext context, Aptitude a) async {
    String? precision;
    if (a.demandePrecision) {
      precision = await showDialog<String>(
        context: context,
        builder: (context) => _DialoguePrecision(aptitude: a),
      );
      if (precision == null || precision.trim().isEmpty) return;
      precision = precision.trim();
      final doublon = aptitudes.any(
        (x) =>
            x.id == a.id &&
            x.precision?.toLowerCase() == precision!.toLowerCase(),
      );
      if (doublon) return;
    }
    onAptitudes([
      ...aptitudes,
      AptitudeAcquise(id: a.id, precision: precision),
    ]);
  }

  Widget _carteVoieClasse(BuildContext context, Voie v) {
    final rang = rangsVoies[v.id] ?? 0;
    final peutMonter = Progression.peutMonter(
      voie: v,
      niveau: niveau,
      race: race,
      rangsVoies: rangsVoies,
      aptitudes: aptitudes.length,
    );
    return _CarteVoie(
      titre: v.nom,
      sousTitre: rang == 0 ? 'Aucun rang' : 'Rang $rang',
      enfants: [
        for (final c in v.competences)
          if (c.rang <= rang)
            LigneCompetence(
              competence: c,
              acquise: true,
              action: c.rang == rang && rang > (rangsVerrouilles[v.id] ?? 0)
                  ? IconButton(
                      key: Key('retirer-${v.id}'),
                      tooltip: 'Retirer',
                      onPressed: () => _descendre(v),
                      icon: const Icon(Icons.remove_circle_outline),
                    )
                  : null,
            )
          else if (c.rang == rang + 1)
            LigneCompetence(
              competence: c,
              attenuee: !peutMonter,
              mention: _mention(c),
              action: IconButton.filledTonal(
                key: Key('prendre-${v.id}'),
                tooltip: 'Prendre ce rang',
                onPressed: peutMonter ? () => _monter(v) : null,
                icon: const Icon(Icons.add),
              ),
            )
          else if (c.rang <= niveau)
            LigneCompetence(competence: c, attenuee: true)
      ],
      rangsSuivants: v.competences
          .where((c) => c.rang > rang + 1 && c.rang > niveau)
          .length,
      voie: v,
    );
  }

  String _mention(Competence c) {
    final cout = Progression.coutRang(c.rang);
    final texteCout = 'Coût : $cout pt${cout > 1 ? 's' : ''}';
    if (c.rang > niveau) return '$texteCout · niveau ${c.rang} requis';
    if (cout > _restants) return '$texteCout · pas assez de points';
    return texteCout;
  }
}

class _CarteVoie extends StatelessWidget {
  const _CarteVoie({
    required this.titre,
    required this.sousTitre,
    required this.enfants,
    this.rangsSuivants = 0,
    this.voie,
  });

  final String titre;
  final String sousTitre;
  final List<Widget> enfants;

  /// Nombre de rangs pas encore accessibles (masqués, consultables).
  final int rangsSuivants;
  final Voie? voie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              titre,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              sousTitre,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            ...enfants,
            if (rangsSuivants > 0 && voie != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => afficherVoies(
                    context,
                    titre: voie!.nom,
                    voies: [voie!],
                  ),
                  child: Text(
                    'Voir les rangs suivants ($rangsSuivants)',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Cadre d'un groupe d'aptitudes (connaissances, aptitudes, maîtrises, sorts
/// de rang 0) : en-tête avec icône, titre, sous-titre et nombre acquises.
class _CarteGroupe extends StatelessWidget {
  const _CarteGroupe({
    super.key,
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.acquises,
    required this.enfants,
  });

  final IconData icone;
  final String titre;
  final String sousTitre;
  final int acquises;
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête coloré : le groupe se repère d'un coup d'œil.
          Container(
            color: scheme.primary.withValues(alpha: 0.15),
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
            child: Row(
              children: [
                Icon(icone, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titre,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        sousTitre,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (acquises > 0)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text('$acquises acquise${acquises > 1 ? 's' : ''}'),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: enfants,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fenêtre demandant la précision d'une aptitude (« Quelle langue ? »).
class _DialoguePrecision extends StatefulWidget {
  const _DialoguePrecision({required this.aptitude});

  final Aptitude aptitude;

  @override
  State<_DialoguePrecision> createState() => _DialoguePrecisionState();
}

class _DialoguePrecisionState extends State<_DialoguePrecision> {
  final _controleur = TextEditingController();

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  void _valider() {
    final texte = _controleur.text.trim();
    if (texte.isEmpty) return;
    Navigator.of(context).pop(texte);
  }

  /// Choix dans la liste (langues) ; `null` : « Autre… », saisie libre.
  String? _choixListe;
  bool _autre = false;

  @override
  Widget build(BuildContext context) {
    final liste =
        widget.aptitude.liste == 'langues' ? kLangues : const <String>[];
    final champ = TextField(
      key: const Key('champ-precision'),
      controller: _controleur,
      autofocus: liste.isEmpty,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: liste.isEmpty ? widget.aptitude.question : 'Laquelle ?',
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) => _valider(),
    );
    return AlertDialog(
      title: Text(widget.aptitude.nom),
      content: liste.isEmpty
          ? champ
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  key: const Key('liste-precision'),
                  initialValue: _autre ? '' : _choixListe,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: widget.aptitude.question,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final l in liste)
                      DropdownMenuItem(value: l, child: Text(l)),
                    const DropdownMenuItem(value: '', child: Text('Autre…')),
                  ],
                  onChanged: (v) => setState(() {
                    _autre = v == '';
                    _choixListe = _autre ? null : v;
                    _controleur.text = _autre ? '' : (v ?? '');
                  }),
                ),
                if (_autre) ...[const SizedBox(height: 12), champ],
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('valider-precision'),
          onPressed: _controleur.text.trim().isEmpty ? null : _valider,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
