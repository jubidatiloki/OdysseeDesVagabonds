import 'package:flutter/material.dart';

import '../../models/aptitude.dart';
import '../../models/langues.dart';
import '../../models/classe.dart';
import '../../models/personnage.dart';
import '../../models/race.dart';
import '../../models/voie.dart';
import '../../regles/fiche_calculee.dart';
import '../../regles/maitrises.dart';
import '../../regles/progression.dart';
import '../../widgets/cadre_repliable.dart';
import '../../widgets/libelles_sort.dart';
import '../../widgets/voie_detail.dart';

/// À partir de cette largeur, « Déjà acquis » est un panneau à gauche ; en
/// dessous (téléphone), un cadre repliable en haut de la liste.
const double kLargeurResume = 900;

/// À partir de cette largeur, aptitudes et connaissances passent à droite
/// des voies.
const double kLargeurTroisColonnes = 1200;

/// Largeur maximale des écrans qui affichent ce panneau.
const double kLargeurAvecResume = 1440;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restants == 0
                      ? 'Tous les points sont dépensés'
                      : 'Points disponibles',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  'Les points non dépensés pourront être utilisés plus tard.',
                  key: const Key('points-plus-tard'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
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

    return LayoutBuilder(builder: (context, contraintes) {
      final large = contraintes.maxWidth >= kLargeurResume;
      final groupes = _groupesAcquis();
      final voies = <Widget>[
        if (!large) ...[
          _ResumeReplie(groupes: groupes),
          const SizedBox(height: 12),
        ],
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
          _TitreVoies(
            icone: _iconeRace,
            texte: 'Voie de ta race · ${race.nom}',
            couleur: scheme.tertiary,
          ),
          _CarteVoie(
            icone: _iconeRace,
            couleur: scheme.tertiary,
            titre: voieRaciale.nom,
            sousTitre: 'Voie raciale · rang $rangRacial offert',
            enfants: [
              for (final c in voieRaciale.competences)
                if (c.rang <= rangRacial) ...[
                  LigneCompetence(competence: c, acquise: true),
                  for (final a in c.aussi)
                    LigneCompetence(
                      competence: a,
                      acquise: true,
                      sousCompetence: true,
                    ),
                ],
            ],
          ),
        ],
        const SizedBox(height: 20),
        _TitreVoies(
          icone: _iconeClasse,
          texte: 'Voies de ta classe · ${classe.nom}',
          couleur: scheme.primary,
        ),
        for (final (i, v) in classe.voies.indexed) ...[
          if (i > 0) const SizedBox(height: 12),
          _carteVoieClasse(context, v),
        ],
      ];
      final partieAptitudes = <Widget>[
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
        for (final (f, icone) in _groupesAptitudes)
          if (catalogueAptitudes.any((a) => !a.estSort && a.famille == f)) ...[
            const SizedBox(height: 12),
            _CarteGroupe(
              key: Key('famille-aptitudes-${f.name}'),
              icone: icone,
              titre: f.libelle,
              sousTitre: f.sousTitre,
              acquises: _nombreAcquises((a) => !a.estSort && a.famille == f),
              enfants: [
                for (final a in catalogueAptitudes)
                  if (!a.estSort && a.famille == f) _ligneAptitude(context, a),
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
            acquises:
                _nombreAcquises((a) => a.estSort && a.disponiblePour(classe)),
            enfants: [
              for (final a in catalogueAptitudes)
                if (a.estSort && a.disponiblePour(classe))
                  _ligneAptitude(context, a),
            ],
          ),
        ],
      ];
      Widget colonne(List<Widget> enfants) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: enfants,
          );
      final tout = [...voies, const SizedBox(height: 24), ...partieAptitudes];
      final panneau = Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 0, 16),
        child: SizedBox(width: 280, child: _PanneauAcquis(groupes: groupes)),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: bandeau,
          ),
          Expanded(
            child: !large
                ? colonne(tout)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      panneau,
                      if (contraintes.maxWidth >= kLargeurTroisColonnes) ...[
                        Expanded(child: colonne(voies)),
                        Expanded(child: colonne(partieAptitudes)),
                      ] else
                        Expanded(child: colonne(tout)),
                    ],
                  ),
          ),
        ],
      );
    });
  }

  static const _iconeRace = Icons.diversity_3_outlined;
  static const _iconeClasse = Icons.route_outlined;
  static const _groupesAptitudes = [
    (FamilleAptitude.savoir, Icons.menu_book_outlined),
    (FamilleAptitude.savoirFaire, Icons.handyman_outlined),
    (FamilleAptitude.autre, Icons.military_tech_outlined),
  ];

  /// Tout ce que le personnage possède, voie par voie puis groupe par
  /// groupe ; les groupes vides ne sont pas listés.
  List<_GroupeAcquis> _groupesAcquis() {
    final res = <_GroupeAcquis>[];
    void ajouter(String titre, IconData icone, List<String> lignes) {
      if (lignes.isNotEmpty) {
        res.add(_GroupeAcquis(titre: titre, icone: icone, lignes: lignes));
      }
    }

    List<String> competences(Voie v, int rangMax) => [
          for (final c in v.competences)
            if (c.rang <= rangMax) ...[
              'Rang ${c.rang} · ${c.nom}',
              for (final a in c.aussi) 'Rang ${c.rang} · ${a.nom}',
            ],
        ];
    List<String> aptitudesDe(bool Function(Aptitude) dansLeGroupe) => [
          for (final a in catalogueAptitudes)
            if (dansLeGroupe(a)) ...[
              if (_estInnee(a)) '${a.nom} (inné)',
              for (final x in aptitudes)
                if (x.id == a.id)
                  x.precision == null ? a.nom : '${a.nom} : ${x.precision}',
            ],
        ];

    // Maîtrises du personnage : armes, instruments, langues (classe, race
    // et compétences choisies).
    final fiche = FicheCalculee(
      personnage: Personnage(
        id: 'creation',
        nom: '',
        raceId: race.id,
        classeId: classe.id,
        niveau: niveau,
        rangsVoies: rangsVoies,
        aptitudes: aptitudes,
      ),
      race: race,
      classe: classe,
    );
    final armes = <String>[];
    for (final m in [
      ...classe.maitrisesArmes,
      ...race.maitrisesArmes,
      ...fiche.armesMaitrisees,
    ]) {
      final l = libelleMaitriseArme(m);
      if (!armes.contains(l)) armes.add(l);
    }
    ajouter('Armes maîtrisées', Icons.gavel, armes);
    ajouter('Instruments', Icons.music_note_outlined, [
      for (final i in fiche.instrumentsMaitrises) i.nom,
    ]);
    ajouter('Langues', Icons.translate, fiche.langues);
    if (race.voieRaciale case final v?) {
      ajouter(
          v.nom, _iconeRace, competences(v, Progression.rangRacial(niveau)));
    }
    for (final v in classe.voies) {
      ajouter(v.nom, _iconeClasse, competences(v, rangsVoies[v.id] ?? 0));
    }
    for (final (f, icone) in _groupesAptitudes) {
      ajouter(
        f.libelle,
        icone,
        aptitudesDe((a) => !a.estSort && a.famille == f),
      );
    }
    ajouter(
        'Sorts de rang 0', Icons.auto_awesome, aptitudesDe((a) => a.estSort));
    return res;
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

/// Titre d'une famille de voies : celle de la race, celles de la classe.
class _TitreVoies extends StatelessWidget {
  const _TitreVoies({
    required this.icone,
    required this.texte,
    required this.couleur,
  });

  final IconData icone;
  final String texte;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icone, size: 20, color: couleur),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texte,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: couleur,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cadre d'une voie : en-tête coloré (or : race, orange : classe), réductible.
class _CarteVoie extends StatelessWidget {
  const _CarteVoie({
    required this.titre,
    required this.sousTitre,
    required this.enfants,
    this.icone = EtapeCompetences._iconeClasse,
    this.couleur,
    this.rangsSuivants = 0,
    this.voie,
  });

  final String titre;
  final String sousTitre;
  final List<Widget> enfants;
  final IconData icone;

  /// Couleur de l'en-tête ; par défaut, celle du thème.
  final Color? couleur;

  /// Nombre de rangs pas encore accessibles (masqués, consultables).
  final int rangsSuivants;
  final Voie? voie;

  @override
  Widget build(BuildContext context) {
    return CadreRepliable(
      key: PageStorageKey('voie-$titre'),
      cle: 'voie-$titre',
      icone: icone,
      couleur: couleur,
      titre: titre,
      sousTitre: sousTitre,
      enfants: [
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
    );
  }
}

/// Une voie ou un groupe d'aptitudes dans « Déjà acquis ».
class _GroupeAcquis {
  const _GroupeAcquis({
    required this.titre,
    required this.icone,
    required this.lignes,
  });

  final String titre;
  final IconData icone;
  final List<String> lignes;
}

/// Liste de « Déjà acquis », commune au panneau et au cadre repliable.
class _ListeAcquis extends StatelessWidget {
  const _ListeAcquis({required this.groupes});

  final List<_GroupeAcquis> groupes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (groupes.isEmpty) {
      return Text(
        'Rien pour l\'instant.',
        style:
            theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final g in groupes) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 6),
            child: Row(
              children: [
                Icon(g.icone, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${g.titre} (${g.lignes.length})',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          for (final l in g.lignes)
            Padding(
              padding: const EdgeInsets.only(left: 22, top: 3, bottom: 3),
              child: Text(
                '• $l',
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ),
        ],
      ],
    );
  }
}

String _titreAcquis(List<_GroupeAcquis> groupes) {
  final total = groupes.fold(0, (n, g) => n + g.lignes.length);
  return 'Déjà acquis ($total)';
}

/// Grand écran : panneau fixe à gauche, il défile à part.
class _PanneauAcquis extends StatelessWidget {
  const _PanneauAcquis({required this.groupes});

  final List<_GroupeAcquis> groupes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      key: const Key('panneau-acquis'),
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            _titreAcquis(groupes),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          _ListeAcquis(groupes: groupes),
        ],
      ),
    );
  }
}

/// Téléphone : cadre repliable en haut de la liste.
class _ResumeReplie extends StatelessWidget {
  const _ResumeReplie({required this.groupes});

  final List<_GroupeAcquis> groupes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: ExpansionTile(
        key: const PageStorageKey('resume-acquis'),
        leading: Icon(Icons.checklist, color: scheme.primary),
        title: Text(_titreAcquis(groupes)),
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [_ListeAcquis(groupes: groupes)],
      ),
    );
  }
}

/// Cadre d'un groupe d'aptitudes (connaissances, aptitudes, maîtrises, sorts
/// de rang 0) : en-tête avec icône, titre, sous-titre et nombre acquises ;
/// réductible, les listes sont longues.
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
    return CadreRepliable(
      key: PageStorageKey('groupe-$titre'),
      cle: 'groupe-$titre',
      icone: icone,
      titre: titre,
      sousTitre: sousTitre,
      droite: acquises > 0
          ? Chip(
              visualDensity: VisualDensity.compact,
              label: Text('$acquises acquise${acquises > 1 ? 's' : ''}'),
            )
          : null,
      enfants: enfants,
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
