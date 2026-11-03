import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/aptitude.dart';
import '../models/carac.dart';
import '../models/classe.dart';
import '../models/historique.dart';
import '../models/personnage.dart';
import '../models/race.dart';
import '../models/voie.dart';
import '../regles/des.dart';
import '../regles/fiche_calculee.dart';
import '../regles/montee_niveau.dart';
import '../regles/progression.dart';
import '../regles/regles_particulieres.dart';
import '../state/personnages_controller.dart';
import '../theme.dart';
import '../widgets/carte_choix.dart';
import '../widgets/carte_emprunts.dart';
import '../widgets/voie_detail.dart';
import 'creation/etape_competences.dart';

/// Assistant de montée de niveau en 3 étapes :
/// vie et mana (jets de dés) → nouvelles compétences → récapitulatif.
/// Le personnage n'est modifié qu'à la validation finale.
class MonteeNiveauScreen extends StatefulWidget {
  const MonteeNiveauScreen({
    super.key,
    required this.personnage,
    required this.race,
    required this.classe,
    required this.referentiel,
    required this.controller,
  });

  final Personnage personnage;
  final Race race;
  final Classe classe;
  final Referentiel referentiel;
  final PersonnagesController controller;

  @override
  State<MonteeNiveauScreen> createState() => _MonteeNiveauScreenState();
}

class _MonteeNiveauScreenState extends State<MonteeNiveauScreen> {
  static const List<String> _titres = [
    'Vie et ressources',
    'Compétences',
    'Récapitulatif',
  ];

  final _jetDv = TextEditingController();
  final _jetDm = TextEditingController();
  final _jetDe = TextEditingController();
  int _etape = 0;

  /// Jets lancés avec le bouton « Lancer » (relances comprises), pour les
  /// inscrire dans l'historique si la montée de niveau est annulée.
  final List<int> _lancersVie = [];
  final List<int> _lancersMana = [];
  final List<int> _lancersEndurance = [];
  late Map<String, int> _rangsVoies;

  /// Rangs d'autres classes choisis (« Polyvalence »).
  late Map<String, int> _emprunts;
  late List<AptitudeAcquise> _aptitudes;
  bool _enregistrement = false;

  Personnage get _p => widget.personnage;
  late final FicheCalculee _fiche = FicheCalculee(
    personnage: _p,
    race: widget.race,
    classe: widget.classe,
  );
  int get _nouveauNiveau => _p.niveau + 1;

  /// Dés à lancer pour ce niveau (règles particulières comprises).
  late final ({int deVie, int deMana, int deEndurance}) _des =
      MonteeNiveau.desDuNiveauSuivant(_fiche);

  /// Bonus de PV des règles particulières (Force de la nature…).
  late final ({int bonus, RegleParticuliere? regle}) _bonusPv =
      MonteeNiveau.bonusPvMonteeNiveau(_fiche);

  /// Jets déjà lancés pour ce niveau (y compris lors d'une montée annulée) :
  /// impossible de les relancer.
  JetsMontee? get _jetsFaits {
    final j = _p.jetsMontee;
    return j != null && j.niveau == _nouveauNiveau ? j : null;
  }

  bool get _vieLancee => _jetsFaits?.vie != null;
  bool get _manaLancee => _jetsFaits?.mana != null;
  bool get _enduranceLancee => _jetsFaits?.endurance != null;
  bool get _aDuMana => widget.classe.aDuMana;
  bool get _aDeLEndurance => widget.classe.aDeLEndurance;

  @override
  void initState() {
    super.initState();
    _rangsVoies = Map.of(_p.rangsVoies);
    _emprunts = Map.of(_p.emprunts);
    _aptitudes = List.of(_p.aptitudes);
    final j = _jetsFaits;
    if (j?.vie != null) _jetDv.text = '${j!.vie}';
    if (j?.mana != null) _jetDm.text = '${j!.mana}';
    if (j?.endurance != null) _jetDe.text = '${j!.endurance}';
  }

  /// Garde le jet sur le personnage (sauvegardé tout de suite) : annuler puis
  /// recommencer la montée de niveau ne permet pas de relancer.
  Future<void> _memoriserJet({int? vie, int? mana, int? endurance}) async {
    final j = _jetsFaits ?? JetsMontee(niveau: _nouveauNiveau);
    if (vie != null) j.vie = vie;
    if (mana != null) j.mana = mana;
    if (endurance != null) j.endurance = endurance;
    setState(() => _p.jetsMontee = j);
    await widget.controller.sauvegarder(_p);
  }

  @override
  void dispose() {
    _jetDv.dispose();
    _jetDm.dispose();
    _jetDe.dispose();
    super.dispose();
  }

  int? _lireJet(TextEditingController c, int faces) {
    final v = int.tryParse(c.text.trim());
    if (v == null || v < 1 || v > faces) return null;
    return v;
  }

  int? get _jetVie => _lireJet(_jetDv, _des.deVie);
  int? get _jetMana => _lireJet(_jetDm, _des.deMana);
  int? get _jetEndurance => _lireJet(_jetDe, _des.deEndurance);

  bool get _modifie =>
      _lancersVie.isNotEmpty ||
      _lancersMana.isNotEmpty ||
      _lancersEndurance.isNotEmpty ||
      _jetDe.text.isNotEmpty ||
      _jetDv.text.isNotEmpty ||
      _jetDm.text.isNotEmpty ||
      _aptitudes.length != _p.aptitudes.length ||
      Progression.pointsDepenses(_rangsVoies) !=
          Progression.pointsDepenses(_p.rangsVoies);

  String? get _blocage {
    if (_etape == 0) {
      if (_jetVie == null) {
        return 'Lance ou saisis le dé de vie (1 à ${_des.deVie})';
      }
      if (_aDuMana && _jetMana == null) {
        return 'Lance ou saisis le dé de mana (1 à ${_des.deMana})';
      }
      if (_aDeLEndurance && _jetEndurance == null) {
        return "Lance ou saisis le dé d'endurance (1 à ${_des.deEndurance})";
      }
    }
    if (_etape == _titres.length - 1) {
      if (_empruntsDemandes && !CarteEmprunts.complet(_emprunts)) {
        return "Choix à faire : 2 rangs d'autres classes (Polyvalence)";
      }
      for (final c in _choixAFaire) {
        final permises = _permises(c.choix);
        final valeur = {..._p.choix, ..._choix}[c.choix.cle];
        if (FicheCalculee.choixAFaire(
              c.choix,
              {..._p.choix, ..._choix},
              {..._p.precisionsChoix, ..._precisions},
            ) ||
            (permises != null && !permises.contains(valeur))) {
          return 'Choix à faire : ${c.nom}';
        }
      }
    }
    return null;
  }

  /// Choix faits pendant cette montée de niveau (clé → option).
  Map<String, String> _choix = {};

  /// Précisions saisies pendant cette montée (« Quelle arme ? »).
  Map<String, String> _precisions = {};

  /// Choix que demandent les compétences du nouveau niveau (rang racial
  /// offert, rangs de voies achetés) et ceux restés en attente.
  List<({String nom, String origine, ChoixCompetence choix})>
      get _choixAFaire => _ficheApres.choixEnAttente;

  /// Fiche au nouveau niveau, avec les rangs choisis (sans les choix faits
  /// pendant cette montée : ils restent proposés).
  FicheCalculee get _ficheApres => FicheCalculee(
        personnage: Personnage.depuisJson(_p.versJson())
          ..niveau = _nouveauNiveau
          ..rangsVoies = Map.of(_rangsVoies)
          ..emprunts = Map.of(_emprunts),
        race: widget.race,
        classe: widget.classe,
      );

  /// Options permises d'un choix (Perfectionnement : stat la plus faible).
  Set<String>? _permises(ChoixCompetence c) => _ficheApres.optionsPermises(
        c,
        choix: {..._p.choix, ..._choix},
      );

  /// Choix à une seule option permise (stat la plus faible sans égalité) :
  /// faits d'office.
  void _choisirAutomatiquement() {
    for (final c in _choixAFaire) {
      final p = _permises(c.choix);
      if (p != null && p.length == 1 && !_choix.containsKey(c.choix.cle)) {
        _choix = {..._choix, c.choix.cle: p.single};
      }
    }
  }

  /// Rangs d'autres classes à choisir à ce niveau (« Polyvalence » obtenue,
  /// pas encore choisis).
  bool get _empruntsDemandes {
    final copie = Personnage.depuisJson(_p.versJson())
      ..niveau = _nouveauNiveau
      ..rangsVoies = Map.of(_rangsVoies);
    return FicheCalculee(
          personnage: copie,
          race: widget.race,
          classe: widget.classe,
        ).empruntsAFaire >
        0;
  }

  /// « Barbare · Voie de la brute rang 1, Barde · … rang 1 ».
  String _texteEmprunts() => [
        for (final e in _emprunts.entries)
          for (final v in FicheCalculee.voiesDesClasses)
            if (v.voie.id == e.key)
              '${v.classe} · ${v.voie.nom} rang ${e.value}',
      ].join(', ');

  void _suivant() {
    if (_blocage != null) return;
    if (_etape == _titres.length - 1) {
      _valider();
    } else {
      FocusScope.of(context).unfocus();
      setState(() {
        _etape++;
        // Récapitulatif : choix sans alternative faits d'office.
        if (_etape == _titres.length - 1) _choisirAutomatiquement();
      });
    }
  }

  Future<void> _valider() async {
    if (_enregistrement) return;
    setState(() => _enregistrement = true);
    _p.precisionsChoix.addAll(_precisions);
    if (_empruntsDemandes) {
      _p.emprunts = Map.of(_emprunts);
      _p.journaliser(
        'Polyvalence : ${_texteEmprunts()}',
        categorie: CategorieHistorique.competences,
      );
    }
    MonteeNiveau.appliquer(
      personnage: _p,
      race: widget.race,
      classe: widget.classe,
      jetDeVie: _jetVie!,
      jetDeMana: _jetMana,
      jetDEndurance: _jetEndurance,
      rangsVoies: _rangsVoies,
      aptitudes: _aptitudes,
      catalogueAptitudes: widget.referentiel.aptitudes,
      facesDeVie: _des.deVie,
      facesDeMana: _des.deMana,
      facesDEndurance: _des.deEndurance,
      choix: _choix,
      catalogueEquipements: widget.referentiel.equipements,
    );
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await widget.controller.sauvegarder(_p);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text('${_p.nom} passe au niveau ${_p.niveau} !')),
    );
  }

  Future<void> _confirmerAbandon() async {
    final abandonner = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la montée de niveau ?'),
        content: Text(
          _lancersVie.isEmpty &&
                  _lancersMana.isEmpty &&
                  _lancersEndurance.isEmpty &&
                  _jetVie == null &&
                  _jetMana == null &&
                  _jetEndurance == null
              ? 'Les choix faits seront perdus.'
              : 'Les choix faits seront perdus. Les jets de dés '
                  'déjà faits seront inscrits dans l\'historique.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuer'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Annuler la montée'),
          ),
        ],
      ),
    );
    if (abandonner != true || !mounted) return;
    final navigator = Navigator.of(context);
    final message = _texteAnnulation();
    if (message != null) {
      // Les gains de PV / PM ont déjà été tirés : on garde une trace.
      _p.journaliser(message, categorie: CategorieHistorique.niveau);
      await widget.controller.sauvegarder(_p);
    }
    navigator.pop();
  }

  /// Message d'historique d'une montée annulée après les jets, ou `null` si
  /// aucun dé n'a été lancé ni saisi.
  String? _texteAnnulation() {
    String? jets(String nom, int faces, List<int> lances, int? saisi) {
      if (lances.isEmpty && saisi == null) return null;
      final valeurs = [
        ...lances,
        // Valeur saisie à la main (différente du dernier lancer).
        if (saisi != null && (lances.isEmpty || lances.last != saisi)) saisi,
      ];
      final detail = valeurs.length == 1
          ? '${valeurs.single}'
          : '${valeurs.join(', puis ')} (${valeurs.length} jets)';
      return '$nom d$faces = $detail';
    }

    final parties = [
      jets('dé de vie', _des.deVie, _lancersVie, _jetVie),
      if (_aDuMana) jets('dé de mana', _des.deMana, _lancersMana, _jetMana),
      if (_aDeLEndurance)
        jets("dé d'endurance", _des.deEndurance, _lancersEndurance,
            _jetEndurance),
    ].whereType<String>().toList();
    if (parties.isEmpty) return null;
    return 'Montée au niveau $_nouveauNiveau annulée après les jets : '
        '${parties.join(' · ')}.';
  }

  Widget _contenu() {
    switch (_etape) {
      case 0:
        return _etapeVieMana();
      case 1:
        return EtapeCompetences(
          titre: 'Nouvelles compétences',
          race: widget.race,
          classe: widget.classe,
          niveau: _nouveauNiveau,
          rangsVoies: _rangsVoies,
          aptitudes: _aptitudes,
          catalogueAptitudes: widget.referentiel.aptitudes,
          intFinale: _fiche.carac(Carac.intel),
          rangsVerrouilles: _p.rangsVoies,
          aptitudesVerrouillees: _p.aptitudes,
          onChange: (r) => setState(() => _rangsVoies = r),
          onAptitudes: (a) => setState(() => _aptitudes = a),
        );
      default:
        return _etapeRecapitulatif();
    }
  }

  Widget _etapeVieMana() {
    final theme = Theme.of(context);
    final jv = _jetVie;
    final jm = _jetMana;
    final gainPv = jv == null ? null : jv + _bonusPv.bonus;
    final pvMaxApres = gainPv == null ? null : _fiche.pvMax + gainPv;
    final pmMaxApres = jm == null ? null : _fiche.pmMax + jm;
    final je = _jetEndurance;
    final peMaxApres = je == null ? null : _fiche.peMax + je;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Niveau ${_p.niveau} → $_nouveauNiveau',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Lance les dés (ou saisis le résultat de tes dés). Les points '
          'actuels augmentent du même gain que les maximums.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        _CarteJet(
          cle: 'dv',
          titre: 'Dé de vie',
          faces: _des.deVie,
          controleur: _jetDv,
          onChange: () => setState(() {}),
          verrouille: _vieLancee,
          onLancer: (r) {
            _lancersVie.add(r);
            _memoriserJet(vie: r);
          },
          apercu: pvMaxApres == null
              ? null
              : 'PV max : ${_fiche.pvMax} → $pvMaxApres · PV actuels : '
                  '${_fiche.pvActuels} → '
                  '${_fiche.personnage.pvActuels == null ? pvMaxApres : _fiche.pvActuels + gainPv!}',
        ),
        if (_aDuMana) ...[
          const SizedBox(height: 12),
          _CarteJet(
            cle: 'dm',
            titre: 'Dé de mana',
            faces: _des.deMana,
            controleur: _jetDm,
            onChange: () => setState(() {}),
            verrouille: _manaLancee,
            onLancer: (r) {
              _lancersMana.add(r);
              _memoriserJet(mana: r);
            },
            apercu: pmMaxApres == null
                ? null
                : 'PM max : ${_fiche.pmMax} → $pmMaxApres · PM actuels : '
                    '${_fiche.pmActuels} → '
                    '${_fiche.personnage.pmActuels == null ? pmMaxApres : _fiche.pmActuels + jm!}',
          ),
        ],
        if (_aDeLEndurance) ...[
          const SizedBox(height: 12),
          _CarteJet(
            cle: 'de',
            titre: "Dé d'endurance",
            faces: _des.deEndurance,
            controleur: _jetDe,
            onChange: () => setState(() {}),
            verrouille: _enduranceLancee,
            onLancer: (r) {
              _lancersEndurance.add(r);
              _memoriserJet(endurance: r);
            },
            apercu: peMaxApres == null
                ? null
                : 'PE max : ${_fiche.peMax} → $peMaxApres · PE actuels : '
                    '${_fiche.peActuels} → '
                    '${_fiche.personnage.peActuels == null ? peMaxApres : _fiche.peActuels + je!}',
          ),
        ],
        if (_bonusPv.regle != null) ...[
          const SizedBox(height: 12),
          _CarteRegle(
            regle: _bonusPv.regle!,
            effet:
                'Bonus aux PV gagnés : ${formaterModificateur(_bonusPv.bonus)}',
          ),
        ],
        if (_des.deVie != _fiche.deVie || _des.deMana != _fiche.deMana) ...[
          const SizedBox(height: 12),
          for (final r in ReglesParticulieres.actives(
            personnage: Personnage.depuisJson(_p.versJson())
              ..niveau = _nouveauNiveau,
            race: widget.race,
            classe: widget.classe,
            mod: _fiche.mod,
            deVieAncien: _fiche.deVieDeBase,
            deVieNouveau: _des.deVie,
            deManaAncien: _fiche.deManaDeBase,
            deManaNouveau: _des.deMana,
          ))
            if (!_fiche.reglesParticulieres
                .any((x) => x.reference == r.reference))
              _CarteRegle(regle: r, effet: 'Nouvelle règle à ce niveau'),
        ],
        const SizedBox(height: 16),
        _Info(
          icone: Icons.auto_awesome,
          texte: '+${MonteeNiveau.pointsGagnes(_nouveauNiveau)} points de '
              'compétence au niveau $_nouveauNiveau.',
        ),
        if (Progression.rangRacial(_nouveauNiveau) >
                Progression.rangRacial(_p.niveau) &&
            widget.race.voieRaciale != null)
          _Info(
            icone: Icons.card_giftcard,
            texte: 'Nouveau rang de voie raciale offert : '
                '${widget.race.voieRaciale!.competence(Progression.rangRacial(_nouveauNiveau))?.nom ?? ''}'
                ' (rang ${Progression.rangRacial(_nouveauNiveau)}).',
          ),
      ],
    );
  }

  Widget _etapeRecapitulatif() {
    final theme = Theme.of(context);
    final jv = _jetVie!;
    final jm = _jetMana;
    final je = _jetEndurance;
    final nouvellesCompetences = [
      for (final c in Progression.competencesAcquises(
        niveau: _nouveauNiveau,
        race: widget.race,
        classe: widget.classe,
        rangsVoies: _rangsVoies,
      ))
        if (!Progression.competencesAcquises(
          niveau: _p.niveau,
          race: widget.race,
          classe: widget.classe,
          rangsVoies: _p.rangsVoies,
        ).any((x) =>
            x.voie.id == c.voie.id && x.competence.rang == c.competence.rang))
          c,
    ];
    final anciennes = List<AptitudeAcquise>.of(_p.aptitudes);
    final nouvellesAptitudes = [
      for (final a in _aptitudes)
        if (!anciennes.remove(a)) a,
    ];
    // Simulation sur une copie : chiffres exacts, règles « à la prise »
    // et rétroactives comprises.
    final sim = MonteeNiveau.appliquer(
      personnage: Personnage.depuisJson(_p.versJson())
        ..precisionsChoix.addAll(_precisions)
        ..emprunts = Map.of(_emprunts),
      race: widget.race,
      classe: widget.classe,
      jetDeVie: jv,
      jetDeMana: jm,
      jetDEndurance: je,
      rangsVoies: _rangsVoies,
      aptitudes: _aptitudes,
      facesDeVie: _des.deVie,
      facesDeMana: _des.deMana,
      facesDEndurance: _des.deEndurance,
      choix: _choix,
    );
    final choixAFaire = _choixAFaire;
    final restants = Progression.pointsRestants(
      niveau: _nouveauNiveau,
      race: widget.race,
      rangsVoies: _rangsVoies,
      aptitudes: _aptitudes.length,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${_p.nom} : niveau ${_p.niveau} → $_nouveauNiveau',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        // Rangs d'autres classes (« Polyvalence », obligatoires).
        if (_empruntsDemandes)
          CarteEmprunts(
            nom: 'Polyvalence',
            origine: '${widget.race.nom} · voie raciale',
            voies: _fiche.voiesEmpruntables,
            valeur: _emprunts,
            onChange: (v) => setState(() => _emprunts = v),
          ),
        // Choix demandés par les nouvelles compétences (obligatoires).
        for (final c in choixAFaire)
          CarteChoix(
            nom: c.nom,
            origine: c.origine,
            choix: c.choix,
            valeur: _choix[c.choix.cle],
            permises: _permises(c.choix),
            onChoisir: (o) =>
                setState(() => _choix = {..._choix, c.choix.cle: o}),
            precision: _precisions[c.choix.cle] ?? '',
            elements: (liste) => _fiche.elementsChoix(
              liste,
              catalogue: widget.referentiel.equipements,
              cle: c.choix.cle,
            ),
            onPrecision: (t) => setState(
              () => _precisions = {..._precisions, c.choix.cle: t},
            ),
          ),
        _Info(
          icone: Icons.favorite_outline,
          texte: 'PV max : ${sim.pvMaxAvant} → ${sim.pvMaxApres} '
              '(${formaterModificateur(sim.pvMaxApres - sim.pvMaxAvant)} : '
              'd${_des.deVie} = $jv'
              '${sim.regle != null && sim.bonusRegle != 0 ? ', ${formaterModificateur(sim.bonusRegle)} ${sim.regle!.nom}' : ''})',
        ),
        if (_aDuMana)
          _Info(
            icone: Icons.water_drop_outlined,
            texte: 'PM max : ${sim.pmMaxAvant} → ${sim.pmMaxApres} '
                '(${formaterModificateur(sim.pmMaxApres - sim.pmMaxAvant)} : '
                'd${_des.deMana} = $jm)',
          ),
        if (_aDeLEndurance)
          _Info(
            icone: kIconeEndurance,
            texte: 'PE max : ${sim.peMaxAvant} → ${sim.peMaxApres} '
                '(${formaterModificateur(sim.peMaxApres - sim.peMaxAvant)} : '
                'd${_des.deEndurance} = $je)',
          ),
        if (sim.regle != null && sim.bonusRegle != 0)
          _CarteRegle(
            regle: sim.regle!,
            effet: 'Bonus aux PV gagnés : '
                '${formaterModificateur(sim.bonusRegle)}',
          ),
        for (final r in sim.nouvellesRegles)
          _CarteRegle(regle: r, effet: 'Nouvelle règle active'),
        _Info(
          icone: Icons.auto_awesome,
          texte: '+${MonteeNiveau.pointsGagnes(_nouveauNiveau)} points de '
              'compétence ; $restants point${restants > 1 ? 's' : ''} '
              'restant${restants > 1 ? 's' : ''} après les achats.',
        ),
        const SizedBox(height: 16),
        Text('Nouvelles compétences', style: theme.textTheme.titleSmall),
        if (nouvellesCompetences.isEmpty && nouvellesAptitudes.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Aucune (les points sont conservés).'),
          ),
        for (final c in nouvellesCompetences)
          LigneCompetence(
            competence: c.competence,
            acquise: true,
            mention: c.raciale ? 'Voie raciale · ${c.voie.nom}' : c.voie.nom,
          ),
        // Rangs d'autres classes choisis (« Polyvalence »).
        if (_empruntsDemandes)
          for (final e in _emprunts.entries)
            for (final v in _fiche.voiesEmpruntables)
              if (v.voie.id == e.key)
                for (final c in v.voie.competences)
                  if (c.rang <= e.value)
                    LigneCompetence(
                      competence: c,
                      acquise: true,
                      mention: 'Polyvalence · ${v.classe} · ${v.voie.nom}',
                    ),
        for (final a in nouvellesAptitudes)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '• ${widget.referentiel.aptitude(a.id)?.nom ?? a.id}'
              '${a.precision == null ? '' : ' : ${a.precision}'}',
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocage = _blocage;
    final dernier = _etape == _titres.length - 1;

    return PopScope<void>(
      canPop: !_modifie || _enregistrement,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmerAbandon();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Montée de niveau — ${_p.nom}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Étape ${_etape + 1} sur ${_titres.length} · '
                    '${_titres[_etape]}',
                    style: theme.textTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: (_etape + 1) / _titres.length,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _contenu(),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (blocage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          blocage,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        if (_etape > 0)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _enregistrement
                                  ? null
                                  : () => setState(() => _etape--),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Précédent'),
                            ),
                          )
                        else
                          const Spacer(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            key: const Key('niveau-suivant'),
                            onPressed: blocage == null && !_enregistrement
                                ? _suivant
                                : null,
                            icon: Icon(
                              dernier ? Icons.check : Icons.arrow_forward,
                            ),
                            label: Text(
                              dernier ? 'Valider la montée' : 'Suivant',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte d'un jet de dé : saisie du résultat ou lancer automatique.
class _CarteJet extends StatelessWidget {
  const _CarteJet({
    required this.cle,
    required this.titre,
    required this.faces,
    required this.controleur,
    required this.onChange,
    this.onLancer,
    this.apercu,
    this.verrouille = false,
  });

  final String cle;
  final String titre;
  final int faces;
  final TextEditingController controleur;
  final VoidCallback onChange;

  /// Dé déjà lancé par l'application : résultat définitif.
  final bool verrouille;

  /// Appelé avec le résultat de chaque lancer automatique.
  final ValueChanged<int>? onLancer;
  final String? apercu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('$titre : d$faces', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 96,
                  child: TextField(
                    key: Key('jet-$cle'),
                    controller: controleur,
                    readOnly: verrouille,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Résultat',
                      hintText: '1–$faces',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => onChange(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonalIcon(
                      key: Key('lancer-$cle'),
                      onPressed: verrouille
                          ? null
                          : () {
                              final resultat = lancerDe(faces);
                              controleur.text = '$resultat';
                              onLancer?.call(resultat);
                              onChange();
                            },
                      icon: Icon(
                        verrouille ? Icons.lock_outline : Icons.casino_outlined,
                      ),
                      label:
                          Text(verrouille ? 'Dé lancé' : 'Lancer le d$faces'),
                    ),
                  ),
                ),
              ],
            ),
            if (verrouille) ...[
              const SizedBox(height: 8),
              Text(
                'Jet déjà fait : il ne peut pas être relancé.',
                key: Key('jet-definitif-$cle'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            if (apercu != null) ...[
              const SizedBox(height: 12),
              Text(apercu!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icone, required this.texte});

  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(texte)),
        ],
      ),
    );
  }
}

/// Encadré d'une règle particulière : nom, origine, effet.
class _CarteRegle extends StatelessWidget {
  const _CarteRegle({required this.regle, required this.effet});

  final RegleParticuliere regle;
  final String effet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.gavel_outlined, color: scheme.onTertiaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Règle particulière : ${regle.nom}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: scheme.onTertiaryContainer),
                ),
                Text(
                  'Origine : ${regle.origine}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onTertiaryContainer),
                ),
                const SizedBox(height: 4),
                Text(
                  '$effet. ${regle.description}',
                  style: TextStyle(color: scheme.onTertiaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
