import 'package:flutter/material.dart';

import '../../models/carac.dart';
import '../../models/equipement.dart';
import '../../models/historique.dart';
import '../../models/personnage.dart';
import '../../models/voie.dart';
import '../../regles/des.dart';
import '../../regles/etats.dart';
import '../../regles/fiche_calculee.dart';
import '../../regles/inventaire.dart';
import '../../regles/montee_niveau.dart';
import '../../theme.dart';
import '../../widgets/carte_choix.dart';
import '../../widgets/carte_emprunts.dart';
import '../../widgets/carte_identite.dart';
import '../../widgets/carte_selection.dart';
import '../../widgets/resume_fiche.dart';
import '../../widgets/voie_detail.dart';

/// Onglet principal. En haut : identité, description, montée de niveau,
/// PV / PM, repos. Puis deux colonnes (l'une sous l'autre sur téléphone) :
/// statistiques à gauche ; traits passifs, compétences actives, règles
/// particulières et maîtrises à droite.
class OngletFiche extends StatelessWidget {
  const OngletFiche({
    super.key,
    required this.fiche,
    required this.onModifie,
    this.onModifierIdentite,
    this.equipements = const [],
  });

  final FicheCalculee fiche;
  final Future<void> Function() onModifie;

  /// Catalogue (arme choisie par le gnome reprise du catalogue).
  final List<Equipement> equipements;

  /// Ouvre la modification du nom, du sexe et de la description.
  final VoidCallback? onModifierIdentite;

  /// PV minimum affichable : en dessous de −DV, le personnage est mort.
  int get _pvMin => -fiche.deVie - 1;

  void _changerPv(int valeur, bool parPas, [String commentaire = '']) {
    final avant = fiche.pvActuels;
    var v = valeur;
    if (v > fiche.pvMax) v = fiche.pvMax;
    if (v < _pvMin) v = _pvMin;
    fiche.personnage
      ..pvActuels = v
      ..journaliserValeur(
        cle: 'pv',
        libelle: 'PV',
        avant: avant,
        apres: v,
        categorie: CategorieHistorique.vie,
        regrouper: parPas,
        commentaire: commentaire,
      );
    onModifie();
  }

  void _changerPm(int valeur, bool parPas, [String commentaire = '']) {
    final avant = fiche.pmActuels;
    var v = valeur;
    if (v > fiche.pmMax) v = fiche.pmMax;
    if (v < 0) v = 0;
    fiche.personnage
      ..pmActuels = v
      ..journaliserValeur(
        cle: 'pm',
        libelle: 'PM',
        avant: avant,
        apres: v,
        categorie: CategorieHistorique.vie,
        regrouper: parPas,
        commentaire: commentaire,
      );
    onModifie();
  }

  void _changerPe(int valeur, bool parPas, [String commentaire = '']) {
    final avant = fiche.peActuels;
    var v = valeur;
    if (v > fiche.peMax) v = fiche.peMax;
    if (v < 0) v = 0;
    fiche.personnage
      ..peActuels = v
      ..journaliserValeur(
        cle: 'pe',
        libelle: 'PE',
        avant: avant,
        apres: v,
        categorie: CategorieHistorique.vie,
        regrouper: parPas,
        commentaire: commentaire,
      );
    onModifie();
  }

  String? get _etatPv {
    final pv = fiche.pvActuels;
    if (pv < -fiche.deVie) return 'Mort';
    if (pv <= 0) return 'Inconscient (1d6 heures)';
    return null;
  }

  Future<void> _repos(BuildContext context) async {
    final type = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Repos'),
        children: [
          SimpleDialogOption(
            key: const Key('repos-nuit'),
            onPressed: () => Navigator.of(context).pop('nuit'),
            child: ListTile(
              leading: const Icon(Icons.bedtime_outlined),
              title: const Text('Nuit complète'),
              subtitle: Text(
                _texteRepos('+ 1d${fiche.deVie} + CON PV', demiNuit: false),
              ),
            ),
          ),
          SimpleDialogOption(
            key: const Key('repos-demi'),
            onPressed: () => Navigator.of(context).pop('demi'),
            child: ListTile(
              leading: const Icon(Icons.nights_stay_outlined),
              title: const Text('Demi-nuit'),
              subtitle: Text(
                _texteRepos('+ 1d${fiche.deVie} PV', demiNuit: true),
              ),
            ),
          ),
        ],
      ),
    );
    if (type == null || !context.mounted) return;
    final p = fiche.personnage;
    final messenger = ScaffoldMessenger.of(context);
    final pvAvant = fiche.pvActuels;
    final pmAvant = fiche.pmActuels;
    final peAvant = fiche.peActuels;
    String detail;
    if (type == 'nuit') {
      final jet = lancerDe(fiche.deVie);
      final gain = fiche.pvRecuperesNuit(jet);
      p.pvActuels = _borne(pvAvant + gain, _pvMin, fiche.pvMax);
      p.pmActuels = _borne(pmAvant + fiche.pmRecuperesNuit(), 0, fiche.pmMax);
      p.peActuels = _borne(peAvant + fiche.peRecuperesNuit(), 0, fiche.peMax);
      detail = 'Nuit complète : jet d${fiche.deVie} = $jet, '
          '${formaterModificateur(fiche.mod(Carac.con))} CON → '
          '+${p.pvActuels! - pvAvant} PV${_gains(p, pmAvant, peAvant)}.';
    } else {
      final jet = lancerDe(fiche.deVie);
      p.pvActuels = _borne(
        pvAvant + fiche.pvRecuperesDemiNuit(jet),
        _pvMin,
        fiche.pvMax,
      );
      p.pmActuels = _borne(
        pmAvant + fiche.pmRecuperesNuit(demiNuit: true),
        0,
        fiche.pmMax,
      );
      p.peActuels = _borne(
        peAvant + fiche.peRecuperesNuit(demiNuit: true),
        0,
        fiche.peMax,
      );
      detail = 'Demi-nuit : jet d${fiche.deVie} = $jet → '
          '+${p.pvActuels! - pvAvant} PV${_gains(p, pmAvant, peAvant)}.';
    }
    p.journaliser(detail, categorie: CategorieHistorique.vie);
    await onModifie();
    messenger.showSnackBar(SnackBar(content: Text(detail)));
  }

  /// Sous-titre d'un repos : PV, puis PM et PE si la classe en a.
  String _texteRepos(String pv, {required bool demiNuit}) => [
        pv,
        if (fiche.classe.aDuMana)
          '+ ${fiche.pmRecuperesNuit(demiNuit: demiNuit)} PM',
        if (fiche.classe.aDeLEndurance)
          '+ ${fiche.peRecuperesNuit(demiNuit: demiNuit)} PE',
      ].join(' · ');

  /// « , +3 PM, +4 PE » : gains de mana et d'endurance d'un repos.
  String _gains(Personnage p, int pmAvant, int peAvant) => [
        if (fiche.classe.aDuMana) ', +${p.pmActuels! - pmAvant} PM',
        if (fiche.classe.aDeLEndurance) ', +${p.peActuels! - peAvant} PE',
      ].join();

  static int _borne(int v, int min, int max) =>
      v < min ? min : (v > max ? max : v);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = fiche.personnage;
    // --- En haut : identité, description, PV / PM (la montée de niveau est
    // dans la barre du haut) ----------------------------------------------------
    final haut = <Widget>[
      CarteIdentite(fiche: fiche, onModifier: onModifierIdentite),
      if (p.description.isNotEmpty) ...[
        const SizedBox(height: 12),
        // Description en citation : filet orange à gauche, italique.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            border: const Border(
              left: BorderSide(color: OdvCouleurs.accent, width: 3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  p.description,
                  key: const Key('texte-description'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 16),
      LayoutBuilder(
        builder: (context, c) {
          final large = c.maxWidth >= 560;
          final pv = _Jauge(
            cle: 'pv',
            titre: 'Points de vie',
            actuel: fiche.pvActuels,
            max: fiche.pvMax,
            min: _pvMin,
            couleur: kCouleurPv,
            icone: Icons.favorite,
            etat: _etatPv,
            libelleMoins: 'Dégâts',
            libellePlus: 'Soins',
            iconeMoins: Icons.heart_broken_outlined,
            iconePlus: Icons.healing,
            onChange: _changerPv,
          );
          final pm = _Jauge(
            cle: 'pm',
            titre: 'Points de mana',
            actuel: fiche.pmActuels,
            max: fiche.pmMax,
            min: 0,
            couleur: kCouleurPm,
            icone: Icons.water_drop,
            libelleMoins: 'Dépenser',
            libellePlus: 'Récupérer',
            iconeMoins: Icons.auto_awesome,
            iconePlus: Icons.autorenew,
            onChange: _changerPm,
          );
          final pe = _Jauge(
            cle: 'pe',
            titre: "Points d'endurance",
            actuel: fiche.peActuels,
            max: fiche.peMax,
            min: 0,
            couleur: kCouleurPe,
            icone: kIconeEndurance,
            libelleMoins: 'Dépenser',
            libellePlus: 'Récupérer',
            iconeMoins: Icons.trending_down,
            iconePlus: Icons.autorenew,
            onChange: _changerPe,
          );
          // Physique : PV + PE ; lanceur : PV + PM ; hybride : les trois.
          final jauges = [
            pv,
            if (fiche.classe.aDuMana) pm,
            if (fiche.classe.aDeLEndurance) pe,
          ];
          if (large) {
            Widget ligne(List<Widget> j) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: j[0]),
                    const SizedBox(width: 12),
                    Expanded(child: j.length > 1 ? j[1] : const SizedBox()),
                  ],
                );
            return Column(
              children: [
                ligne(jauges.sublist(0, 2)),
                if (jauges.length > 2) ...[
                  const SizedBox(height: 12),
                  ligne(jauges.sublist(2)),
                ],
              ],
            );
          }
          return Column(
            children: [
              for (final (i, j) in jauges.indexed) ...[
                if (i > 0) const SizedBox(height: 12),
                j,
              ],
            ],
          );
        },
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          key: const Key('bouton-repos'),
          onPressed: () => _repos(context),
          icon: const Icon(Icons.bedtime_outlined),
          label: const Text('Nuit de repos'),
        ),
      ),
      // Objets donnés par une compétence déjà acquise mais pas encore reçus
      // (personnage créé avant la règle).
      if (fiche.objetsARecevoir.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Card(
            key: const Key('objets-a-recevoir'),
            margin: EdgeInsets.zero,
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest,
            child: ListTile(
              leading: const Icon(Icons.card_giftcard_outlined),
              title: Text(
                'Objets à recevoir : '
                '${fiche.objetsARecevoir.map((o) => o.objet['nom']).join(', ')}',
              ),
              subtitle: Text(
                'Donnés par : '
                '${fiche.objetsARecevoir.map((o) => o.competence).toSet().join(', ')}',
              ),
              trailing: FilledButton(
                key: const Key('recevoir-objets'),
                onPressed: () {
                  ObjetsDonnes.recevoir(fiche, catalogue: equipements);
                  onModifie();
                },
                child: const Text('Recevoir'),
              ),
            ),
          ),
        ),
      // Effets reçus d'un allié (Agrandissement, forme animale) : à cocher.
      if (fiche.etatsRecus.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Card(
            margin: EdgeInsets.zero,
            child: ExpansionTile(
              key: const Key('effets-recus'),
              leading: const Icon(Icons.auto_fix_high_outlined),
              title: const Text('Effets reçus'),
              subtitle:
                  const Text('Sorts lancés sur ce personnage par un allié'),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedAlignment: Alignment.centerLeft,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in fiche.etatsRecus)
                      FilterChip(
                        key: Key('effet-recu-${e.etat.nom}'),
                        label: Text('${e.etat.nom} (${e.competence.nom})'),
                        tooltip: e.etat.effets.map((x) => x.libelle).join('\n'),
                        selected: p.etats.contains(e.etat.nom),
                        onSelected: (oui) {
                          basculerEtat(fiche, e.etat, e.competence.nom,
                              actif: oui);
                          onModifie();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      // États actifs (apparence monstrueuse…) : rappel, annulables ici.
      for (final e in [...fiche.etatsPossibles, ...fiche.etatsRecus])
        if (p.etats.contains(e.etat.nom))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: InputChip(
              key: Key('etat-actif-${e.etat.nom}'),
              avatar: const Icon(Icons.theater_comedy_outlined, size: 18),
              label: Text('${e.etat.nom} active (${e.competence.nom})'),
              deleteIcon: const Icon(Icons.close),
              deleteButtonTooltipMessage: 'Annuler',
              onDeleted: () {
                p.etats.remove(e.etat.nom);
                p.journaliser(
                  '${e.competence.nom} : ${e.etat.nom} annulée',
                  categorie: CategorieHistorique.competences,
                );
                onModifie();
              },
            ),
          ),
      // Rangs d'autres classes à choisir (« Polyvalence »).
      if (fiche.empruntsAFaire > 0) ...[
        const SizedBox(height: 16),
        CarteEmprunts(
          nom: 'Polyvalence',
          origine: '${fiche.race.nom} · voie raciale',
          voies: fiche.voiesEmpruntables,
          valeur: p.emprunts,
          onChange: (v) {
            p.emprunts = v;
            if (CarteEmprunts.complet(v)) {
              p.journaliser(
                'Polyvalence : ${[
                  for (final e in v.entries)
                    for (final x in fiche.voiesEmpruntables)
                      if (x.voie.id == e.key)
                        '${x.classe} · ${x.voie.nom} rang ${e.value}',
                ].join(', ')}',
                categorie: CategorieHistorique.competences,
              );
            }
            onModifie();
          },
        ),
      ],
      // Choix en attente (personnage déjà au niveau d'une compétence à
      // choix, ou passif sans son élément) : à faire ici.
      if (fiche.choixEnAttente.isNotEmpty) ...[
        const SizedBox(height: 16),
        const _TitreColonne(titre: 'Choix à faire', icone: Icons.help_outline),
        for (final c in fiche.choixEnAttente)
          CarteChoix(
            nom: c.nom,
            origine: c.origine,
            choix: c.choix,
            valeur: p.choix[c.choix.cle],
            permises: fiche.optionsPermises(c.choix),
            onChoisir: (o) {
              p.choix[c.choix.cle] = o;
              p.precisionsChoix.remove(c.choix.cle);
              // Option avec question : inscrite une fois la précision validée.
              if (c.choix.option(o)?.question.isEmpty ?? true) {
                MonteeNiveau.journaliserChoix(p, fiche, {c.choix.cle: o});
              }
              onModifie();
            },
            precision: p.precisionsChoix[c.choix.cle] ?? '',
            elements: (liste) => fiche.elementsChoix(
              liste,
              catalogue: equipements,
              cle: c.choix.cle,
            ),
            validerPrecision: true,
            onPrecision: (t) {
              p.precisionsChoix[c.choix.cle] = t;
              MonteeNiveau.journaliserChoix(
                p,
                fiche,
                {c.choix.cle: p.choix[c.choix.cle]!},
              );
              onModifie();
            },
          ),
      ],
    ];

    // --- Statistiques ----------------------------------------------------------
    final stats = <Widget>[
      const _TitreColonne(titre: 'Statistiques', icone: Icons.bar_chart),
      ResumeFiche(fiche: fiche),
    ];

    // --- Traits passifs, compétences actives ----------------------------------
    // Compétences telles que les a le personnage (variante de son passif,
    // option choisie).
    final competences = fiche.competencesAcquises;
    final passives = [
      for (final c in competences)
        if (_estPassive(c.competence)) c,
    ];
    final actives = [
      for (final c in competences)
        if (!_estPassive(c.competence)) c,
    ];
    // Trait ou compétence amélioré par un renforcement acquis plus tard.
    // « Améliorée par « Harmonie avec la nature » : Avantage sur le jet. »
    String? ameliore(String nom) {
      final a = fiche.ameliorationDeNom(nom);
      if (a == null) return null;
      final e = a.effet;
      final details = e.texte.isNotEmpty
          ? e.texte
          : e.sousEffets.map((s) => s.libelle).join(' ; ');
      return 'Améliorée par « ${a.nom} »'
          '${details.isEmpty ? '' : ' : $details'}';
    }

    String? mention(({Voie voie, Competence competence, bool raciale}) c) =>
        ameliore(c.competence.nom);

    // Compétence améliorée : affichée sous le nom de son nouveau niveau
    // (« Amis de la forêt (niveau 2) »), avec le type du renforcement.
    Competence affichee(Competence c) {
      final a = fiche.ameliorationDe(c);
      if (a == null || a.effet.nom.isEmpty) return c;
      final nom = a.effet.nom;
      return Competence(
        rang: c.rang,
        nom: nom[0].toUpperCase() + nom.substring(1),
        type: a.effet.typeCompetence.isEmpty ? c.type : a.effet.typeCompetence,
        effet: c.effet,
        effets: c.effets,
        jets: c.jets,
        choix: c.choix,
        selonPassif: c.selonPassif,
        selonOrigine: c.selonOrigine,
        selonProfil: c.selonProfil,
        endurance: c.endurance,
        etat: c.etat,
        objets: c.objets,
        aussi: c.aussi,
        degats: c.degats,
        effetApplique: c.effetApplique,
        mana: c.mana,
        soin: c.soin,
        reussite: c.reussite,
        fabrication: c.fabrication,
        emprunt: c.emprunt,
        typesSort: c.typesSort,
        modulable: c.modulable,
        etatsAuChoix: c.etatsAuChoix,
        variantesDegats: c.variantesDegats,
        invocations: c.invocations,
      );
    }

    // Groupes (passif de race, origine, puis une voie par groupe) : chaque
    // groupe a son en-tête et est séparé du précédent par un filet.
    List<Widget> groupes(List<(String, List<Widget>)> liste) => [
          for (final (i, (titre, lignes)) in liste.indexed) ...[
            if (i > 0) const _Separateur(),
            _EnTeteGroupe(titre),
            ...lignes,
          ],
        ];

    List<(String, List<Widget>)> parVoie(
      List<({Voie voie, Competence competence, bool raciale})> liste, {
      bool cleActive = false,
    }) {
      final voies = <String, (String, List<Widget>)>{};
      for (final c in liste) {
        final groupe = voies.putIfAbsent(
          c.voie.id,
          () => (
            c.raciale
                ? 'Voie raciale · ${c.voie.nom}'
                : fiche.estEmprunt(c.voie)
                    ? 'Polyvalence · ${c.voie.nom}'
                    : fiche.empruntDe(c.voie) != null
                        ? '${fiche.nomEmprunt(c.voie)} · ${c.voie.nom}'
                        : c.voie.nom,
            <Widget>[],
          ),
        );
        groupe.$2.add(
          LigneCompetence(
            key: cleActive
                ? Key(
                    'active-${c.voie.id}-${c.competence.rang}-${c.competence.nom}')
                : null,
            competence: affichee(c.competence),
            acquise: true,
            mention: mention(c),
            choixFaits: fiche.personnage.choix,
            sortsEnEndurance: fiche.sortsEnEndurance,
          ),
        );
      }
      return voies.values.toList();
    }

    final race = fiche.race;
    final origine = fiche.origine;
    final traits = <Widget>[
      const _TitreColonne(
          titre: 'Traits passifs', icone: Icons.shield_moon_outlined),
      ...groupes([
        if (race.passif != null || fiche.optionPassif != null)
          (
            'Passif racial · ${race.nom}',
            [
              if (race.passif != null)
                LigneTrait(
                  nom: race.passif!.nom,
                  description: race.passif!.description,
                  effets: race.passif!.effets,
                  type: race.passif!.type,
                  mention: ameliore(race.passif!.nom),
                ),
              if (fiche.optionPassif != null)
                LigneTrait(
                  nom: fiche.optionPassif!.nom,
                  description: remplacerChoix(
                    fiche.optionPassif!.description,
                    p.choix,
                    fiche.choixConnus,
                  ),
                  effets: fiche.optionPassif!.effets,
                  type: fiche.optionPassif!.type,
                  mention: ameliore(fiche.optionPassif!.nom),
                ),
            ],
          ),
        if (origine?.passif != null)
          (
            'Origine · ${origine!.nom}',
            [
              LigneTrait(
                nom: origine.passif!.nom,
                description: origine.passif!.description,
                effets: origine.passif!.effets,
                type: origine.passif!.type,
                mention: ameliore(origine.passif!.nom),
              ),
            ],
          ),
        ...parVoie(passives),
      ]),
    ];
    final activesW = <Widget>[
      const _TitreColonne(titre: 'Compétences actives', icone: Icons.bolt),
      if (actives.isEmpty)
        Text(
          'Aucune compétence active.',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        )
      else
        ...groupes(parVoie(actives, cleActive: true)),
    ];

    // --- Résumés : règles particulières, bonus, maîtrises ----------------------
    // Placés sous les statistiques (les bonus modifient les caractéristiques).
    final resumes = <Widget>[
      if (fiche.reglesParticulieres.isNotEmpty) ...[
        const SizedBox(height: 20),
        const _TitreColonne(
          titre: 'Règles particulières appliquées',
          icone: Icons.gavel_outlined,
        ),
        for (final r in fiche.reglesParticulieres)
          Container(
            key: Key('regle-${r.nom}'),
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.nom,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                Text(
                  'Origine : ${r.origine}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  r.description,
                  style: TextStyle(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
      ],
      if (fiche.bonusCaracteristiques.isNotEmpty ||
          fiche.bonusTests.isNotEmpty) ...[
        const SizedBox(height: 20),
        const _TitreColonne(
          titre: 'Bonus des traits et compétences',
          icone: Icons.trending_up,
        ),
        if (fiche.bonusCaracteristiques.isNotEmpty) ...[
          const _SousTitreBonus(
            'Ajoutés aux caractéristiques (déjà comptés dans les statistiques)',
          ),
          for (final s in fiche.bonusCaracteristiques) _LigneBonus(s),
        ],
        if (fiche.bonusTests.isNotEmpty) ...[
          const _SousTitreBonus('Aux tests (à ajouter au lancer de dés)'),
          for (final s in fiche.bonusTests) _LigneBonus(s),
        ],
      ],
      const SizedBox(height: 20),
      const _TitreColonne(
        titre: 'Maîtrises et restrictions',
        icone: Icons.construction_outlined,
      ),
      LigneDetail(
        key: const Key('langues-parlees'),
        libelle: 'Langues',
        texte: fiche.langues.join(', '),
      ),
      if (fiche.race.maitrises.isNotEmpty)
        LigneDetail(libelle: 'Maîtrises (race)', texte: fiche.race.maitrises),
      if (fiche.classe.maitrises.isNotEmpty)
        LigneDetail(
          libelle: 'Maîtrises (classe)',
          texte: fiche.classe.maitrises,
        ),
      if (fiche.classe.restrictionArmure.isNotEmpty)
        LigneDetail(libelle: 'Armure', texte: fiche.classe.restrictionArmure),
      if (fiche.race.restrictions.isNotEmpty)
        LigneDetail(
          libelle: 'Restrictions (race)',
          texte: fiche.race.restrictions,
        ),
    ];

    return ListView(
      key: const PageStorageKey('onglet-fiche'),
      padding: const EdgeInsets.all(16),
      children: [
        ...haut,
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, c) {
            Widget colonne(int flex, List<Widget> enfants) => Expanded(
                  flex: flex,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: enfants,
                  ),
                );
            const espace = SizedBox(width: 24);
            const ecart = SizedBox(height: 20);
            // Très grand écran : stats et résumés | traits | actives.
            if (c.maxWidth >= _largeurTroisColonnes) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  colonne(5, [...stats, ...resumes]),
                  espace,
                  colonne(4, traits),
                  espace,
                  colonne(4, activesW),
                ],
              );
            }
            // Écran large : stats et résumés | traits et actives.
            if (c.maxWidth >= _largeurDeuxColonnes) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  colonne(5, [...stats, ...resumes]),
                  espace,
                  colonne(4, [...traits, ecart, ...activesW]),
                ],
              );
            }
            // Téléphone : une colonne, stats puis traits, actives et résumés.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...stats,
                const SizedBox(height: 24),
                ...traits,
                ecart,
                ...activesW,
                ...resumes,
              ],
            );
          },
        ),
      ],
    );
  }

  /// Largeurs (du contenu) à partir desquelles la fiche passe sur deux puis
  /// trois colonnes.
  static const double _largeurDeuxColonnes = 720;
  static const double _largeurTroisColonnes = 1300;

  /// Une compétence est un trait passif si son type contient « passif »
  /// (« passif », « renforcement + passif »…), sinon elle est active.
  static bool _estPassive(Competence c) =>
      c.type.toLowerCase().contains('passif');
}

/// Titre d'une colonne de la fiche, avec icône.
class _TitreColonne extends StatelessWidget {
  const _TitreColonne({required this.titre, required this.icone});

  final String titre;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icone, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              titre,
              style: styleAmbiance(theme.textTheme.titleMedium)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// En-tête d'un groupe de traits ou de compétences : la voie (ou la race,
/// l'origine) dont ils viennent.
class _EnTeteGroupe extends StatelessWidget {
  const _EnTeteGroupe(this.titre);

  final String titre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.alt_route, size: 15, color: OdvCouleurs.or),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              titre,
              style: theme.textTheme.labelLarge?.copyWith(
                color: OdvCouleurs.or,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Filet fin entre deux groupes (voies différentes).
class _Separateur extends StatelessWidget {
  const _Separateur();

  @override
  Widget build(BuildContext context) => Divider(
        height: 20,
        thickness: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      );
}

/// Jauge PV ou PM : valeur actuelle / max, barre, boutons − / + et saisie.
class _Jauge extends StatelessWidget {
  const _Jauge({
    required this.cle,
    required this.titre,
    required this.actuel,
    required this.max,
    required this.min,
    required this.couleur,
    required this.icone,
    required this.libelleMoins,
    required this.libellePlus,
    required this.iconeMoins,
    required this.iconePlus,
    required this.onChange,
    this.etat,
  });

  final String cle;
  final String titre;
  final int actuel;
  final int max;
  final int min;
  final Color couleur;

  /// Icône de la carte (cœur pour les PV, goutte pour les PM).
  final IconData icone;
  final String libelleMoins;
  final String libellePlus;

  /// Icônes des boutons de dépense (dégâts) et de gain (soins).
  final IconData iconeMoins;
  final IconData iconePlus;
  final String? etat;

  /// [parPas] : vrai pour les boutons −1 / +1 (regroupés dans l'historique) ;
  /// [commentaire] : raison saisie (« morsure de loup »), notée dans
  /// l'historique.
  final void Function(int valeur, bool parPas, [String commentaire]) onChange;

  /// Rouge pour la dépense ; vert (PV) ou bleu mana (PM) pour le gain.
  static Color couleurMoins(BuildContext context) =>
      couleurModificateur(-1, Theme.of(context).brightness);
  Color couleurPlus(BuildContext context) => cle == 'pv'
      ? couleurModificateur(1, Theme.of(context).brightness)
      : couleur;

  Future<void> _saisir(BuildContext context) async {
    final resultat = await showDialog<({int montant, String commentaire})>(
      context: context,
      builder: (context) => _DialogueMontant(
        titre: titre,
        icone: icone,
        couleur: couleur,
        libelleMoins: libelleMoins,
        libellePlus: libellePlus,
        iconeMoins: iconeMoins,
        iconePlus: iconePlus,
        couleurMoins: couleurMoins(context),
        couleurPlus: couleurPlus(context),
      ),
    );
    if (resultat != null) {
      onChange(actuel + resultat.montant, false, resultat.commentaire);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ratio = max <= 0 ? 0.0 : (actuel / max).clamp(0.0, 1.0).toDouble();
    final rouge = couleurMoins(context);
    final gain = couleurPlus(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icone, key: Key('$cle-icone'), size: 22, color: couleur),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(titre, style: theme.textTheme.titleSmall),
                ),
                Text(
                  '$actuel',
                  key: Key('$cle-actuel'),
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  ' / $max',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 12,
                // PV : vert, or puis rouge selon l'état ; PM : bleu.
                color: cle == 'pv' ? couleurPv(ratio) : couleur,
                backgroundColor: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            if (etat != null) ...[
              const SizedBox(height: 6),
              Text(
                etat!,
                style:
                    theme.textTheme.labelLarge?.copyWith(color: scheme.error),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                // −1 en rouge, +1 en vert (PV) ou bleu (PM).
                IconButton(
                  key: Key('$cle-moins'),
                  tooltip: '$libelleMoins : −1',
                  color: rouge,
                  onPressed:
                      actuel > min ? () => onChange(actuel - 1, true) : null,
                  icon: const Icon(Icons.remove_circle),
                ),
                IconButton(
                  key: Key('$cle-plus'),
                  tooltip: '$libellePlus : +1',
                  color: gain,
                  onPressed:
                      actuel < max ? () => onChange(actuel + 1, true) : null,
                  icon: const Icon(Icons.add_circle),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      key: Key('$cle-saisir'),
                      onPressed: () => _saisir(context),
                      icon: const Icon(Icons.edit_note, size: 20),
                      label: Text(
                        '$libelleMoins / $libellePlus',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Saisie d'un montant à retirer (dégâts, dépense) ou ajouter (soins), avec
/// un commentaire facultatif. Renvoie le montant signé (négatif pour un
/// retrait) et le commentaire.
class _DialogueMontant extends StatefulWidget {
  const _DialogueMontant({
    required this.titre,
    required this.icone,
    required this.couleur,
    required this.libelleMoins,
    required this.libellePlus,
    required this.iconeMoins,
    required this.iconePlus,
    required this.couleurMoins,
    required this.couleurPlus,
  });

  final String titre;
  final IconData icone;
  final Color couleur;
  final String libelleMoins;
  final String libellePlus;
  final IconData iconeMoins;
  final IconData iconePlus;
  final Color couleurMoins;
  final Color couleurPlus;

  @override
  State<_DialogueMontant> createState() => _DialogueMontantState();
}

class _DialogueMontantState extends State<_DialogueMontant> {
  final _controleur = TextEditingController();
  final _commentaire = TextEditingController();

  @override
  void dispose() {
    _controleur.dispose();
    _commentaire.dispose();
    super.dispose();
  }

  int? get _valeur {
    final v = int.tryParse(_controleur.text.trim());
    return (v == null || v <= 0) ? null : v;
  }

  void _valider(int montant) => Navigator.of(context)
      .pop((montant: montant, commentaire: _commentaire.text.trim()));

  @override
  Widget build(BuildContext context) {
    final v = _valeur;
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.icone, color: widget.couleur),
          const SizedBox(width: 8),
          Flexible(child: Text(widget.titre)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('champ-montant'),
            controller: _controleur,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Montant',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          // Raison de la dépense ou du gain, notée dans l'historique.
          TextField(
            key: const Key('champ-commentaire'),
            controller: _commentaire,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Commentaire (facultatif)',
              hintText: 'Morsure de loup, potion de santé…',
              prefixIcon: Icon(Icons.chat_bubble_outline),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        OutlinedButton.icon(
          key: const Key('montant-moins'),
          style: OutlinedButton.styleFrom(
            foregroundColor: widget.couleurMoins,
            side: BorderSide(color: widget.couleurMoins),
          ),
          onPressed: v == null ? null : () => _valider(-v),
          icon: Icon(widget.iconeMoins, size: 18),
          label: Text(widget.libelleMoins),
        ),
        FilledButton.icon(
          key: const Key('montant-plus'),
          style: FilledButton.styleFrom(
            backgroundColor: widget.couleurPlus,
            foregroundColor: Colors.white,
          ),
          onPressed: v == null ? null : () => _valider(v),
          icon: Icon(widget.iconePlus, size: 18),
          label: Text(widget.libellePlus),
        ),
      ],
    );
  }
}

class _SousTitreBonus extends StatelessWidget {
  const _SousTitreBonus(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Text(
        texte,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// « +2 SOC » / « +5 aux tests de MEN (intimidation) » avec sa provenance.
class _LigneBonus extends StatelessWidget {
  const _LigneBonus(this.source);

  final SourceEffet source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              iconeEffet(source.effet),
              size: 16,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.effet.libelle,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${source.nom} · ${source.origine}',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
