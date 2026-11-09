import 'dart:math';

import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/aptitude.dart';
import '../models/carac.dart';
import '../models/historique.dart';
import '../models/objet.dart';
import '../models/voie.dart';
import '../regles/des.dart';
import '../regles/etats.dart';
import '../regles/fiche_calculee.dart';
import '../regles/savoirs.dart';
import '../regles/situations.dart';
import '../state/historique_lancers.dart';
import '../state/personnages_controller.dart';
import '../state/preferences_controller.dart';
import '../theme.dart';
import '../widgets/animation_lancer.dart';
import '../widgets/consultation.dart';
import '../widgets/icone_guitare.dart';
import '../widgets/libelles_sort.dart';

export '../regles/des.dart' show LancerD20, ModeLancer;

/// Page « Lancer de dé » : d20 libre (avantage / désavantage) et, si un
/// personnage actif est choisi, ses jets : tests de caractéristique,
/// toucher, dégâts des armes équipées, initiative. Rappel de ses statistiques
/// et historique des lancers.
class DeScreen extends StatefulWidget {
  const DeScreen({
    super.key,
    this.menu,
    this.aleatoire,
    this.referentiel,
    this.personnages,
    this.preferences,
    this.historique,
  });

  final Widget? menu;

  /// Générateur imposé (tests).
  final Random? aleatoire;

  /// Données et personnages : sans eux, seul le d20 libre est proposé.
  final Referentiel? referentiel;
  final PersonnagesController? personnages;

  /// Personnage actif (choisi ici ou par l'étoile de l'accueil).
  final PreferencesController? preferences;

  /// Historique partagé (gardé quand on change de page) ; sinon local.
  final HistoriqueLancers? historique;

  @override
  State<DeScreen> createState() => _DeScreenState();
}

class _DeScreenState extends State<DeScreen> {
  ModeLancer _mode = ModeLancer.normal;

  /// Groupes de jets repliés (Connaissances, Aptitudes).
  final Set<String> _replies = {};

  /// Faces du dé libre (d4 à d100) ; celui des Préférences (d20) au départ.
  late int _facesLibre = widget.preferences?.deDefaut ?? 20;

  @override
  void initState() {
    super.initState();
    // Groupes ouverts ou repliés selon les Préférences.
    for (final g in GroupeJets.values) {
      if (!(widget.preferences?.groupeOuvert(g) ?? true)) _replies.add(g.name);
    }
  }

  /// Modificateur libre ajouté à tous les jets (en plus des bonus du
  /// personnage actif) ; gardé jusqu'à ce qu'on le change.
  int _modificateur = 0;
  static const int _modificateurMax = 20;

  final HistoriqueLancers _historiqueLocal = HistoriqueLancers();

  HistoriqueLancers get _historique => widget.historique ?? _historiqueLocal;

  /// Nombre total de lancers (relance l'animation à chaque lancer).
  int _compteur = 0;

  /// Écran large : personnage à gauche, dé et historique à droite.
  static const double _largeurDeuxColonnes = 900;
  static const double _largeurTroisColonnes = 1400;

  @override
  void dispose() {
    _historiqueLocal.dispose();
    super.dispose();
  }

  /// Fiche du personnage actif (`null` : aucun ou introuvable).
  FicheCalculee? get _fiche {
    final ref = widget.referentiel;
    final id = widget.preferences?.personnageActifId;
    if (ref == null || id == null) return null;
    final p = widget.personnages?.parId(id);
    if (p == null) return null;
    final race = ref.race(p.raceId);
    final classe = ref.classe(p.classeId);
    if (race == null || classe == null) return null;
    return FicheCalculee(personnage: p, race: race, classe: classe);
  }

  /// Situations cochées (bonus de tests des traits : « +1 en forêt »…),
  /// repérées par [_cleSituation].
  final Set<String> _situations = {};

  static String _cleSituation(SourceEffet s) => cleSituation(s);

  /// Bonus et avantage des situations cochées pour un jet (règle commune à
  /// la page dé et à la séance : `regles/situations.dart`).
  ({List<BonusSituation> bonus, List<String> avantage}) _effetsSituations(
    FicheCalculee fiche,
    Carac? caracTest, {
    bool initiative = false,
    String? savoir,
  }) =>
      effetsSituations(
        fiche,
        _situations,
        caracTest,
        initiative: initiative,
        savoir: savoir,
      );

  /// [brut] : ni modificateur libre, ni situation, ni avantage (recharge,
  /// dégâts des animaux). [caracTest] : caractéristique testée (pour les
  /// situations) ; [origineBonus] : d'où vient [bonus] (« CON ») ;
  /// [avantage] : compétence qui impose l'avantage.
  ResultatLancer? _lancer({
    required String libelle,
    required String de,
    int bonus = 0,
    String? personnage,
    bool brut = false,
    Carac? caracTest,
    String origineBonus = '',
    List<BonusSituation> bonusFixes = const [],
    int? difficulte,
    String? avantage,
    bool deLibre = false,
    int seuilCritique = 20,
    int diviseur = 1,
    int multiplie = 1,
    bool degatsCac = false,
    bool degatsDistance = false,
    String? savoir,
    bool attaque = false,
  }) {
    final fiche = personnage == null ? null : _fiche;
    // Jet d'attaque (toucher, attaque de compétence, attaque magique) :
    // critique / échec élargis (Rune de précision : 18-20 et 1-2).
    var seuilEchec = 1;
    if (attaque && fiche != null) {
      final s = fiche.seuilsAttaques;
      if (s.critique < seuilCritique) seuilCritique = s.critique;
      seuilEchec = s.echec;
    }
    // Dégâts au corps à corps : dégâts des situations cochées (en 1 contre
    // 1 : +1d6), dés ajoutés devant ceux de l'arme. Catégorie « DIST » :
    // seulement pour les dégâts à distance (Proie favorite du rôdeur).
    final fixesSituation = <BonusSituation>[];
    if ((degatsCac || degatsDistance) && fiche != null && !brut) {
      for (final s in fiche.situationsHorsTests) {
        if (s.effet.typeNormalise != 'degats' ||
            (s.effet.categorieNormalisee == 'dist') != degatsDistance ||
            !_situations.contains(_cleSituation(s))) {
          continue;
        }
        if (lireDes(s.effet.valeur) != null) {
          de = '${s.effet.valeur} + $de';
        } else if ((s.effet.valeurEntiere ?? 0) != 0) {
          fixesSituation.add((nom: s.nom, valeur: s.effet.valeurEntiere!));
        }
      }
    }
    bonusFixes = [...bonusFixes, ...fixesSituation];
    final situation = brut || fiche == null
        ? (bonus: const <BonusSituation>[], avantage: const <String>[])
        : _effetsSituations(fiche, caracTest,
            initiative: libelle == 'Initiative', savoir: savoir);
    var mode = brut ? ModeLancer.normal : _mode;
    // Pourquoi avantage / désavantage : choisi, compétence, situation.
    final raisons = <String>[
      if (!brut && _mode != ModeLancer.normal) 'choisi',
    ];
    if (!brut && (avantage != null || situation.avantage.isNotEmpty)) {
      raisons
        ..remove('choisi')
        ..addAll([if (avantage != null) avantage, ...situation.avantage]);
      // Avantage et désavantage s'annulent.
      if (mode == ModeLancer.desavantage) {
        mode = ModeLancer.normal;
        raisons.add('annule le désavantage choisi');
      } else {
        mode = ModeLancer.avantage;
      }
    }
    final lance = ResultatLancer.lancer(
      libelle: libelle,
      de: de,
      bonus: bonus,
      modificateur: brut ? 0 : _modificateur,
      situations: [...bonusFixes, ...situation.bonus],
      origineBonus: origineBonus,
      origineMode: raisons.join(', '),
      difficulte: difficulte,
      mode: mode,
      personnage: personnage,
      aleatoire: widget.aleatoire,
      // Dé libre (d4 à d100) : avantage / désavantage pour tous les dés.
      modeTousDes: deLibre,
      seuilCritique: seuilCritique,
      seuilEchec: seuilEchec,
    );
    if (lance == null) return null;
    // Dégâts divisés (Coup de boucher : ÷2, arrondi à l'inférieur) ou
    // multipliés (Lumière sacrée contre les morts-vivants : ×2).
    final r = lance.divise(diviseur).multiplie(multiplie);
    // États qui ne valent que pour un coup (Feinte préparée) : annulés
    // après les dégâts.
    if (degatsCac && fiche != null) {
      for (final e in fiche.etatsPossibles) {
        if (e.etat.finApresDegats &&
            fiche.personnage.etats.remove(e.etat.nom)) {
          fiche.personnage.journaliser(
            '${e.competence.nom} : ${e.etat.nom} utilisée',
            categorie: CategorieHistorique.competences,
          );
        }
      }
    }
    setState(() => _compteur++);
    AnimationLancer.montrer(
      context,
      total: r.total,
      libelle: r.libelle,
      critique: r.reussiteCritique,
      echec: r.echecCritique,
    );
    _historique.ajouter(r);
    // Les lancers de la page dé ne vont plus dans l'historique du
    // personnage (ceux d'une séance, si : voir la séance). Un lancer envoie
    // quand même les modifications en attente.
    if (fiche != null) widget.personnages?.apresLancer?.call();
    return r;
  }

  /// Jet d'une compétence : difficulté, avantage, paliers (second jet selon
  /// le d20 naturel), PV / PM appliqués au personnage, jet suivant, délai
  /// de recharge.
  /// Compétence qui détruit un objet (Chanceux : porte-bonheur) : demande
  /// confirmation avant de lancer.
  Future<void> _confirmerPuisLancer(JetDisponible j, String nom) async {
    if (j.detruit.isEmpty) {
      _lancerCompetence(j, nom);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Utiliser ${j.origine} ?'),
        content: Text('${j.libelle} : ${j.detruit} sera détruit '
            '(retiré de l\'inventaire).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('confirmer-competence'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Utiliser'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) _lancerCompetence(j, nom);
  }

  /// Retire l'objet [nom] de l'inventaire (détruit par une compétence).
  void _detruire(String nomObjet, String origine) {
    final fiche = _fiche;
    final o = fiche?.objetNomme(nomObjet);
    if (fiche == null || o == null) return;
    final p = fiche.personnage..inventaire.remove(o);
    p.journaliser(
      'Objet détruit : ${o.nom} ($origine)',
      categorie: CategorieHistorique.inventaire,
    );
    widget.personnages?.sauvegarder(p);
  }

  /// Attaques de compétence en cours (Moulinet) : libellé → nombre de cibles
  /// déjà frappées.
  final Map<String, int> _repetitions = {};

  /// Attaque de compétence : jet d'attaque (1d20 + toucher CaC), puis dégâts
  /// de l'arme équipée (dés remplacés, dégâts en plus, malus de la cible
  /// suivante), puis le dé ajouté, relancé s'il fait son maximum.
  void _attaqueCompetence(JetDisponible j, String nom) {
    final fiche = _fiche;
    final a = j.attaque;
    if (fiche == null || a == null) return;
    if (!a.sansArme && fiche.armeAttaque(a) == null) return;
    // Aptitude de l'attaque : AdT à distance (Pistoléro), AdC sinon.
    final apt = a.distance == true ? Carac.adt : Carac.adc;
    final p = fiche.personnage;
    // Attaque payée en mana (Justice divine : 5 PM).
    if (j.coutPm > 0) {
      final avant = fiche.pmActuels;
      if (avant < j.coutPm) return;
      p.pmActuels = avant - j.coutPm;
      p.journaliser(
        '${j.libelle} (−${j.coutPm} PM) · PM : $avant → ${p.pmActuels}',
        categorie: CategorieHistorique.vie,
      );
    }
    final n = _repetitions[j.libelle] ?? 0;
    // Première attaque : état activé (Moulinet : défense réduite).
    final etat = a.etat;
    if (n == 0 && etat != null && p.etats.add(etat)) {
      p.journaliser('${j.origine} : $etat activée',
          categorie: CategorieHistorique.competences);
    }
    final cible = n == 0 ? '' : ' (cible ${n + 1})';
    _lancer(
      libelle: '${j.libelle} · attaque$cible',
      // Dé de l'attaque (Frappe de précision, contre-attaque : d12).
      de: j.des.isEmpty ? '1d20' : j.des,
      bonus: fiche.mod(apt) + (a.toucher ?? 0),
      personnage: nom,
      caracTest: apt,
      origineBonus:
          a.toucher == null ? apt.abrev : '${apt.abrev}, ${j.libelle}',
      bonusFixes: fiche.bonusToucher(distance: a.distance == true),
      attaque: true,
    );
    // Attaque répétable (Moulinet) : la cible suivante sera la n + 2ᵉ.
    if (a.repetable != null) {
      setState(() => _repetitions[j.libelle] = n + 1);
    }
    widget.personnages?.sauvegarder(p);
  }

  /// Dégâts d'une attaque de compétence, lancés à part (seulement si elle a
  /// touché) : dés de l'arme et dés ajoutés en un seul jet ; si le dé ajouté
  /// fait son maximum, il est relancé (Frénésie).
  void _degatsCompetence(JetDisponible j, String nom) {
    final fiche = _fiche;
    final a = j.attaque;
    if (fiche == null || a == null) return;
    final arme = fiche.armeAttaque(a);
    if (arme == null && !a.sansArme) return;
    final n = _repetitions[j.libelle] ?? 0;
    final cible = a.repetable != null && n > 1 ? n : 0;
    final f = degatsAttaque(fiche, j, a.sansArme ? null : arme, cible: cible);
    final r = _lancer(
      libelle: '${j.libelle} · dégâts${cible > 1 ? ' (cible $cible)' : ''}',
      de: f.des,
      bonus: f.bonus,
      personnage: nom,
      origineBonus: a.distance == true
          ? fiche.detailDegatsDistance.carac.abrev
          : fiche.detailDegatsCac.carac.abrev,
      bonusFixes: f.fixes,
      degatsCac: a.distance != true,
      degatsDistance: a.distance == true,
      diviseur: a.diviseDegats ?? 1,
    );
    final de = lireDes(a.degatsEnPlus ?? '');
    if (r == null || de == null || de.nombre != 1) return;
    // Le dé ajouté est le dernier lancé.
    var dernier = r.des.isEmpty ? 0 : r.des.last;
    var relances = 0;
    while (dernier == de.faces && relances < (a.explosion ?? 0)) {
      relances++;
      final x = _lancer(
        libelle: '${j.libelle} · dé bonus (relance $relances)',
        de: '1d${de.faces}',
        personnage: nom,
        brut: true,
      );
      if (x == null) return;
      dernier = x.total;
    }
  }

  /// Fin d'une attaque répétée (Moulinet) : état annulé.
  void _terminerAttaque(JetDisponible j) {
    final p = _fiche?.personnage;
    final etat = j.attaque?.etat;
    setState(() => _repetitions.remove(j.libelle));
    if (p == null || etat == null || !p.etats.remove(etat)) return;
    p.journaliser('${j.origine} : $etat terminée',
        categorie: CategorieHistorique.competences);
    widget.personnages?.sauvegarder(p);
  }

  void _lancerCompetence(
    JetDisponible j,
    String nom, {
    VarianteDegats? variante,
  }) {
    if (j.attaque != null) {
      _attaqueCompetence(j, nom);
      return;
    }
    final groupes = lireFormule(j.des)?.groupes ?? const [];
    final estTest = groupes.length == 1 && groupes.single.faces == 20;
    final r = _lancer(
      libelle:
          variante == null ? j.libelle : '${j.libelle} (${variante.libelle})',
      diviseur: variante?.divise ?? 1,
      multiplie: variante?.multiplie ?? 1,
      de: j.des,
      bonus: j.bonus,
      personnage: nom,
      caracTest: estTest ? j.carac : null,
      origineBonus:
          j.libelleCaracs.isNotEmpty ? j.libelleCaracs : (j.carac?.abrev ?? ''),
      difficulte: j.difficulte,
      avantage: j.avantage
          ? (j.amelioration.isEmpty ? j.origine : j.amelioration)
          : null,
      attaque: j.attaqueMagique,
    );
    if (r == null) return;
    // Méditation : le total est ajouté aux PM (sans dépasser le maximum).
    final fm = _fiche;
    if (j.recuperePm && fm != null) {
      final p = fm.personnage;
      final avant = fm.pmActuels;
      final apres = (avant + r.total).clamp(0, fm.pmMax);
      p.pmActuels = apres;
      p.journaliser('${j.origine} : PM $avant → $apres (+${apres - avant})',
          categorie: CategorieHistorique.vie);
      widget.personnages?.sauvegarder(p);
    }
    if (r.d20 && j.paliers.isNotEmpty) {
      final palier = j.paliers.firstWhere(
        (p) => r.garde <= p.jusqua,
        orElse: () => j.paliers.last,
      );
      _lancer(
        libelle: palier.libelle.isEmpty
            ? '${j.libelle} · ${palier.des}'
            : palier.libelle,
        de: palier.des,
        personnage: nom,
        brut: true,
      );
    }
    if (j.applique.isNotEmpty) _appliquer(j, r.total);
    // Réussi : argent gagné, ajouté à la bourse (Musicien en herbe).
    final g = j.gain;
    final fiche = _fiche;
    if (g != null && r.reussite == true && fiche != null) {
      final carac = Carac.depuisCode(g.carac ?? '');
      final gain = _lancer(
        libelle: '${j.libelle} · gain',
        de: g.des ?? '1d20',
        bonus: carac == null ? 0 : fiche.mod(carac),
        personnage: nom,
        brut: true,
        origineBonus: carac?.abrev ?? '',
      );
      if (gain != null && gain.total > 0) {
        final b = fiche.personnage.bourse;
        final piece = g.piece ?? 'cuivre';
        switch (piece) {
          case 'or':
            b.or += gain.total;
          case 'argent':
            b.argent += gain.total;
          default:
            b.cuivre += gain.total;
        }
        fiche.personnage.journaliser(
          'Gain : +${gain.total} $piece (${j.libelle})',
          categorie: CategorieHistorique.bourse,
        );
        widget.personnages?.sauvegarder(fiche.personnage);
      }
    }
    // Réussi : l'état prend fin (« Sortir de la rage »).
    final p = _fiche?.personnage;
    if (j.finEtat.isNotEmpty && r.reussite == true && p != null) {
      if (p.etats.remove(j.finEtat)) {
        p.journaliser('${j.origine} : ${j.finEtat} terminée (test réussi)',
            categorie: CategorieHistorique.competences);
        widget.personnages?.sauvegarder(p);
        setState(() {});
      }
    }
    if (j.detruit.isNotEmpty) _detruire(j.detruit, j.origine);
    if (j.suite != null) _lancerCompetence(j.suite!, nom);
    // Délai avant de pouvoir recommencer (souffle : 1d4 tours).
    if (j.recharge.isNotEmpty) {
      _lancer(
        libelle: 'Recharge (tours) · ${j.libelle}',
        de: j.recharge,
        personnage: nom,
        brut: true,
      );
    }
  }

  /// Retire / ajoute le résultat aux PV ou PM actuels (PM et PV plafonnés
  /// au maximum), avec une ligne d'historique.
  void _appliquer(JetDisponible j, int valeur) {
    final fiche = _fiche;
    if (fiche == null) return;
    final p = fiche.personnage;
    final pv = j.applique.endsWith('pv');
    final signe = j.applique.startsWith('-') ? -1 : 1;
    final avant = pv ? fiche.pvActuels : fiche.pmActuels;
    final max = pv ? fiche.pvMax : fiche.pmMax;
    // « =pv » : les PV deviennent le résultat (Chanceux : PV = 2d6).
    var apres = j.applique.startsWith('=') ? valeur : avant + signe * valeur;
    if (apres > max) apres = max;
    if (pv) {
      p.pvActuels = apres;
    } else {
      p.pmActuels = apres;
    }
    p.journaliser(
      '${pv ? 'PV' : 'PM'} : $avant → $apres '
      '(${formaterModificateur(apres - avant)}) · ${j.origine}',
      categorie: CategorieHistorique.vie,
    );
    widget.personnages?.sauvegarder(p);
  }

  /// Lance un sort du personnage actif : retire son coût des PM actuels
  /// (refusé s'il n'en reste pas assez), avec une ligne d'historique.
  void _lancerSort(Competence sort, int cout) {
    final fiche = _fiche;
    if (fiche == null) return;
    final p = fiche.personnage;
    // Classe sans mana : le sort se paie en PE.
    final u = fiche.uniteSorts;
    final avant = fiche.pointsPourSorts;
    final messager = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (avant < cout) {
      messager.showSnackBar(SnackBar(
        content: Text('Pas assez de ${fiche.sortsEnEndurance ? 'PE' : 'mana'} '
            'pour ${sort.nom} : $cout $u nécessaires, $avant disponibles.'),
      ));
      return;
    }
    if (fiche.sortsEnEndurance) {
      p.peActuels = avant - cout;
    } else {
      p.pmActuels = avant - cout;
    }
    p.journaliser(
      'Sort lancé : ${sort.nom} (−$cout $u) · $u : $avant → ${avant - cout}',
      categorie: CategorieHistorique.vie,
    );
    // Sort qui active un état (Frappe de ki : dé de mana aux dégâts de
    // l'attaque suivante ; Mur d'air).
    if (sort.etat case final e? when p.etats.add(e.nom)) {
      p.journaliser('${sort.nom} : ${e.nom} activée',
          categorie: CategorieHistorique.competences);
    }
    widget.personnages?.sauvegarder(p);
    messager.showSnackBar(SnackBar(
      content: Text('${sort.nom} : $cout $u dépensés '
          '($u $avant → ${avant - cout}).'),
    ));
    // Puis son jet de réussite s'il en a un (les dégâts / l'effet se lancent
    // à part, seulement s'il a touché) ; sinon ses dégâts, soin et jets
    // (Cri sauvage : test de SOC diff. 10).
    final reussite = fiche.jetReussite(sort);
    if (reussite != null) {
      _lancerCompetence(reussite, p.nom);
    } else {
      _effetSort(sort);
    }
  }

  /// Dégâts, soin et jets propres d'un sort.
  /// Avec une [variante] (×2 contre les morts-vivants, ÷2 si esquivé) :
  /// total de chaque jet multiplié ou divisé.
  void _effetSort(Competence sort, [VarianteDegats? variante]) {
    final fiche = _fiche;
    if (fiche == null) return;
    for (final j in fiche.jetsEffetSort(sort)) {
      _lancerCompetence(j, fiche.personnage.nom, variante: variante);
    }
  }

  /// Active ou annule l'état d'une compétence (réutiliser la compétence
  /// annule l'apparence).
  void _basculerEtat(EtatCompetence etat, String competence) {
    final f = _fiche;
    if (f == null) return;
    // Postures, formes : une seule à la fois (même groupe).
    basculerEtat(f, etat, competence);
    widget.personnages?.sauvegarder(f.personnage);
  }

  /// Utilise une capacité limitée (« Faire jouer son titre ») après
  /// confirmation : une utilisation de moins, notée dans l'historique. La
  /// suite se joue avec le MJ.
  Future<void> _utiliser(String cle, String detail) async {
    final p = _fiche?.personnage;
    if (p == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cle),
        content: Text([
          if (detail.isNotEmpty) detail,
          'Une utilisation sera décomptée ; la suite se joue avec le MJ.',
        ].join('\n\n')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('confirmer-usage'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Utiliser'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    p.utilisations[cle] = (p.utilisations[cle] ?? 0) + 1;
    p.journaliser('$cle : utilisé', categorie: CategorieHistorique.competences);
    widget.personnages?.sauvegarder(p);
  }

  /// Action de compétence payée en endurance (Moulinet : 2 PE) : les PE
  /// sont retirés et l'action inscrite dans l'historique.
  void _depenserEndurance(({String libelle, int cout, String origine}) a) {
    final fiche = _fiche;
    if (fiche == null) return;
    final avant = fiche.peActuels;
    if (avant < a.cout) return;
    final p = fiche.personnage..peActuels = avant - a.cout;
    p.journaliser(
      '${a.libelle} (−${a.cout} PE) · PE : $avant → ${p.peActuels}',
      categorie: CategorieHistorique.vie,
    );
    setState(() {});
    widget.personnages?.sauvegarder(p);
  }

  /// Nouveau combat : les utilisations « par combat » sont rendues.
  void _nouveauCombat() => _rendre('combat', 'Nouveau combat');

  /// Nouveau jour : les utilisations « par jour » sont rendues (potions).
  void _nouveauJour() => _rendre('jour', 'Nouveau jour');

  /// Rend les utilisations dont la période contient [mot].
  void _rendre(String mot, String libelle) {
    final f = _fiche;
    if (f == null) return;
    final cles = {
      for (final u in f.usages)
        if (u.periode.contains(mot)) u.cle,
    };
    if (!f.personnage.utilisations.keys.any(cles.contains)) return;
    f.personnage.utilisations.removeWhere((k, _) => cles.contains(k));
    f.personnage.journaliser('$libelle : utilisations rendues',
        categorie: CategorieHistorique.competences);
    widget.personnages?.sauvegarder(f.personnage);
  }

  /// Nouvelle aventure : toutes les utilisations sont rendues.
  void _nouvelleAventure() {
    final p = _fiche?.personnage;
    if (p == null || p.utilisations.isEmpty) return;
    p.utilisations.clear();
    p.journaliser('Nouvelle aventure : utilisations rendues',
        categorie: CategorieHistorique.competences);
    widget.personnages?.sauvegarder(p);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _historique,
        widget.personnages,
        widget.preferences,
      ]),
      builder: (context, _) => _construire(context),
    );
  }

  Widget _construire(BuildContext context) {
    final fiche = _fiche;
    final nom = fiche?.personnage.nom;
    final lancers = _historique.lancers;
    final dernier = lancers.isEmpty ? null : lancers.first;
    final deLibre = 'd$_facesLibre';
    void lancerLibre() =>
        _lancer(libelle: deLibre, de: '1$deLibre', deLibre: true);

    final reglages = Column(
      children: [
        _ChoixMode(
          mode: _mode,
          onChoisir: (m) => setState(() => _mode = m),
        ),
        const SizedBox(height: 8),
        _Modificateur(
          valeur: _modificateur,
          max: _modificateurMax,
          onChange: (v) => setState(() => _modificateur = v),
        ),
      ],
    );
    // Choix du dé libre (d20 par défaut) juste au-dessus de son bouton.
    final boutonLibre = Column(
      children: [
        _ChoixDe(
          faces: _facesLibre,
          onChoisir: (f) => setState(() => _facesLibre = f),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          key: const Key('bouton-lancer'),
          onPressed: lancerLibre,
          icon: const Icon(Icons.casino),
          label: Text(fiche == null ? 'Lancer le $deLibre' : '$deLibre libre'),
        ),
      ],
    );
    final aide = Text(
      '20 naturel au d20 : réussite critique · 1 naturel : échec critique. '
      'Avantage : 2 dés, on garde le meilleur. Désavantage : 2 dés, on garde '
      'le pire (d20 et dé libre).',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      textAlign: TextAlign.center,
    );
    final selecteur = widget.personnages == null || widget.preferences == null
        ? null
        : _SelecteurPersonnage(
            referentiel: widget.referentiel,
            personnages: widget.personnages!,
            preferences: widget.preferences!,
          );
    void basculerSituation(String cle) => setState(() {
          if (!_situations.remove(cle)) _situations.add(cle);
        });
    final largeur = MediaQuery.sizeOf(context).width;
    // Très grand écran : situations dans une colonne à gauche.
    final situationsAGauche = fiche != null &&
        largeur >= _largeurTroisColonnes &&
        BlocSituations.aDuContenu(fiche);
    final panneau = fiche == null
        ? null
        : _PanneauPersonnage(
            fiche: fiche,
            catalogue: widget.referentiel?.aptitudes ?? const [],
            avecSituations: !situationsAGauche,
            onUtiliser: _utiliser,
            onNouvelleAventure: _nouvelleAventure,
            onEndurance: _depenserEndurance,
            onNouveauCombat: _nouveauCombat,
            onNouveauJour: _nouveauJour,
            replies: _replies,
            onReplier: (cle) => setState(() {
              final ouvert = _replies.remove(cle);
              if (!ouvert) _replies.add(cle);
              // Retenu pour « Comme la dernière fois ».
              for (final g in GroupeJets.values) {
                if (g.name == cle) {
                  widget.preferences?.memoriserGroupe(g, ouvert);
                }
              }
            }),
            onLancer: (libelle, de, bonus, caracTest, origine, fixes,
                    {seuilCritique = 20,
                    degatsCac = false,
                    degatsDistance = false,
                    savoir,
                    attaque = false}) =>
                _lancer(
              libelle: libelle,
              de: de,
              bonus: bonus,
              personnage: nom,
              caracTest: caracTest,
              origineBonus: origine,
              bonusFixes: fixes,
              seuilCritique: seuilCritique,
              degatsCac: degatsCac,
              degatsDistance: degatsDistance,
              savoir: savoir,
              attaque: attaque,
            ),
            onLancerCompetence: (j) => _confirmerPuisLancer(j, nom!),
            repetitions: _repetitions,
            onTerminerAttaque: _terminerAttaque,
            onDegatsCompetence: (j) => _degatsCompetence(j, nom!),
            situations: _situations,
            cleSituation: _cleSituation,
            onSituation: basculerSituation,
            onEtat: _basculerEtat,
            onSort: _lancerSort,
            onEffetSort: _effetSort,
          );
    final historique = _Historique(
      lancers: lancers,
      onEffacer: _historique.effacer,
    );

    return Scaffold(
      drawer: widget.menu,
      appBar: AppBar(title: const Text('Lancer de dé')),
      body: LayoutBuilder(
        builder: (context, c) {
          // Grand écran : personnage à gauche ; dé, résultat, historique à
          // droite.
          if (c.maxWidth >= _largeurDeuxColonnes) {
            return Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: situationsAGauche ? 1700 : 1200),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (situationsAGauche)
                      SizedBox(
                        width: 400,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            CarteOdv(
                              child: BlocSituations(
                                fiche: fiche,
                                situations: _situations,
                                cleSituation: _cleSituation,
                                onSituation: basculerSituation,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (selecteur != null) selecteur,
                          if (panneau != null) ...[
                            const SizedBox(height: 16),
                            panneau,
                          ],
                          if (selecteur != null && panneau == null)
                            const _AucunActif(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          reglages,
                          const SizedBox(height: 20),
                          _Resultat(
                            dernier: dernier,
                            compteur: _compteur,
                            de: deLibre,
                            onTap: lancerLibre,
                          ),
                          const SizedBox(height: 16),
                          boutonLibre,
                          const SizedBox(height: 16),
                          aide,
                          historique,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // Téléphone : résultat toujours visible en haut, le reste défile.
          return LargeurLimitee(
            max: 640,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      reglages,
                      const SizedBox(height: 12),
                      _Resultat(
                        dernier: dernier,
                        compteur: _compteur,
                        de: deLibre,
                        onTap: lancerLibre,
                        compact: fiche != null,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      boutonLibre,
                      const SizedBox(height: 16),
                      if (selecteur != null) selecteur,
                      if (panneau != null) ...[
                        const SizedBox(height: 16),
                        panneau,
                      ],
                      if (selecteur != null && panneau == null)
                        const _AucunActif(),
                      const SizedBox(height: 16),
                      aide,
                      historique,
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Normal / avantage (vert, flèches vers le haut) / désavantage (rouge,
/// flèches vers le bas).
/// Dé du lancer libre : d4, d6, d8, d10, d12, d20 (par défaut) ou d100.
/// L'avantage et le désavantage valent pour tous ces dés (2 dés lancés) ;
/// seul le d20 a des critiques.
class _ChoixDe extends StatelessWidget {
  const _ChoixDe({required this.faces, required this.onChoisir});

  final int faces;
  final ValueChanged<int> onChoisir;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final f in facesDesLibres)
          ChoiceChip(
            key: Key('de-libre-d$f'),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            label: Text('D$f'),
            labelStyle: TextStyle(
              color: f == faces ? scheme.primary : null,
              fontWeight: f == faces ? FontWeight.w700 : FontWeight.w500,
            ),
            selected: f == faces,
            selectedColor: scheme.primary.withValues(alpha: 0.18),
            side: BorderSide(
              color: f == faces ? scheme.primary : scheme.outlineVariant,
              width: f == faces ? 2 : 1,
            ),
            onSelected: (_) => onChoisir(f),
          ),
      ],
    );
  }
}

class _ChoixMode extends StatelessWidget {
  const _ChoixMode({required this.mode, required this.onChoisir});

  final ModeLancer mode;
  final ValueChanged<ModeLancer> onChoisir;

  static IconData _icone(ModeLancer m) => switch (m) {
        ModeLancer.normal => Icons.casino_outlined,
        ModeLancer.avantage => Icons.keyboard_double_arrow_up,
        ModeLancer.desavantage => Icons.keyboard_double_arrow_down,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    Color couleur(ModeLancer m) => switch (m) {
          ModeLancer.normal => scheme.primary,
          ModeLancer.avantage => couleurModificateur(1, theme.brightness),
          ModeLancer.desavantage => couleurModificateur(-1, theme.brightness),
        };
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final m in ModeLancer.values)
          ChoiceChip(
            key: Key('mode-${m.name}'),
            showCheckmark: false,
            avatar: Icon(_icone(m), size: 20, color: couleur(m)),
            label: Text(m.libelle),
            labelStyle: TextStyle(
              color: m == mode ? couleur(m) : null,
              fontWeight: m == mode ? FontWeight.w700 : FontWeight.w500,
            ),
            selected: m == mode,
            selectedColor: couleur(m).withValues(alpha: 0.18),
            side: BorderSide(
              color: m == mode ? couleur(m) : scheme.outlineVariant,
              width: m == mode ? 2 : 1,
            ),
            tooltip: switch (m) {
              ModeLancer.normal => 'Un seul d20',
              ModeLancer.avantage => 'Deux dés, on garde le meilleur',
              ModeLancer.desavantage => 'Deux dés, on garde le pire',
            },
            onSelected: (_) => onChoisir(m),
          ),
      ],
    );
  }
}

/// Modificateur libre du jet : − / valeur / +, remise à zéro.
class _Modificateur extends StatelessWidget {
  const _Modificateur({
    required this.valeur,
    required this.max,
    required this.onChange,
  });

  final int valeur;
  final int max;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couleur = valeur == 0
        ? theme.colorScheme.onSurfaceVariant
        : couleurModificateur(valeur, theme.brightness);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            'Modificateur du jet',
            style: theme.textTheme.labelLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          key: const Key('modif-moins'),
          tooltip: 'Modificateur −1',
          onPressed: valeur > -max ? () => onChange(valeur - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 44,
          child: Text(
            formaterModificateur(valeur),
            key: const Key('modif-valeur'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: couleur, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          key: const Key('modif-plus'),
          tooltip: 'Modificateur +1',
          onPressed: valeur < max ? () => onChange(valeur + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
        IconButton(
          key: const Key('modif-zero'),
          tooltip: 'Remettre à 0',
          onPressed: valeur == 0 ? null : () => onChange(0),
          icon: const Icon(Icons.restart_alt),
        ),
      ],
    );
  }
}

/// Couleur du résultat : vert sur une réussite (ou un 20 naturel), rouge sur
/// un échec (ou un 1 naturel), orange sinon.
Color _couleurResultat(ResultatLancer? r, ColorScheme scheme) => r == null
    ? scheme.onSurfaceVariant
    : r.reussiteCritique || r.reussite == true
        ? OdvCouleurs.lightGreen
        : r.echecCritique || r.reussite == false
            ? scheme.error
            : scheme.primary;

/// Provenance des bonus d'un jet, en pastilles : caractéristique (« CON +2 »),
/// chaque situation cochée (« Vision elfique +1 »), modificateur libre, et
/// raison de l'avantage / du désavantage. Rien si le jet n'a aucun bonus.
class _Provenance extends StatelessWidget {
  const _Provenance(this.r, {this.centre = true});

  final ResultatLancer r;
  final bool centre;

  static String _signe(int v) => formaterModificateur(v);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pastilles = <(String, int?)>[
      if (r.bonus != 0)
        (
          r.origineBonus.isEmpty
              ? 'Bonus ${_signe(r.bonus)}'
              : '${r.origineBonus} ${_signe(r.bonus)}',
          r.bonus,
        ),
      for (final s in r.situations)
        if (s.valeur != 0) ('${s.nom} ${_signe(s.valeur)}', s.valeur),
      if (r.modificateur != 0)
        ('Modificateur libre ${_signe(r.modificateur)}', r.modificateur),
      if (r.mode != ModeLancer.normal)
        (
          '${r.mode.libelle}'
              '${r.origineMode.isEmpty ? '' : ' : ${r.origineMode}'}',
          r.mode == ModeLancer.avantage ? 1 : -1,
        )
      else if (r.origineMode.contains('annule'))
        ('Avantage et désavantage annulés', null),
    ];
    if (pastilles.isEmpty) return const SizedBox.shrink();
    return Padding(
      key: const Key('provenance-de'),
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        alignment: centre ? WrapAlignment.center : WrapAlignment.start,
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final (texte, valeur) in pastilles)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: valeur == null || valeur == 0
                      ? scheme.outlineVariant
                      : couleurModificateur(valeur, theme.brightness),
                ),
              ),
              child: Text(
                texte,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: valeur == null || valeur == 0
                      ? scheme.onSurfaceVariant
                      : couleurModificateur(valeur, theme.brightness),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bandeau « RÉUSSITE » / « ÉCHEC » d'un jet avec difficulté : couleur,
/// icône et petit effet de rebond à chaque nouveau lancer.
class _BandeauReussite extends StatelessWidget {
  const _BandeauReussite({
    super.key,
    required this.reussite,
    required this.difficulte,
    this.critique = false,
  });

  final bool reussite;
  final int difficulte;
  final bool critique;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fond = reussite ? OdvCouleurs.darkGreen : scheme.error;
    final texte = reussite ? Colors.white : scheme.onError;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, echelle, child) =>
          Transform.scale(scale: echelle, child: child),
      child: Container(
        key: const Key('bandeau-reussite'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: fond,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: fond.withValues(alpha: 0.45),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              reussite ? Icons.check_circle : Icons.cancel,
              color: texte,
              size: 22,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${reussite ? 'RÉUSSITE' : 'ÉCHEC'}'
                '${critique ? ' CRITIQUE' : ''} · diff. $difficulte',
                style: TextStyle(
                  color: texte,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dernier résultat : total en grand (vert / rouge sur un critique), ce qui
/// a été lancé et le détail des dés.
class _Resultat extends StatelessWidget {
  const _Resultat({
    required this.dernier,
    required this.compteur,
    required this.onTap,
    this.compact = false,
    this.de = 'd20',
  });

  final ResultatLancer? dernier;
  final int compteur;

  /// Dé libre choisi (« d20 », « d6 »…), affiché avant le premier lancer.
  final String de;

  /// Toucher le dé : dé libre sans bonus.
  /// `null` : bouton désactivé (objet requis absent…).
  final VoidCallback? onTap;

  /// Petit cercle à côté du texte (téléphone avec personnage actif).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = dernier;
    final couleur = _couleurResultat(d, theme.colorScheme);
    final taille = compact ? 84.0 : 180.0;
    final disque = Container(
      width: taille,
      height: taille,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: couleur.withValues(alpha: 0.12),
        border: Border.all(color: couleur, width: compact ? 3 : 4),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: FittedBox(
          key: ValueKey(compteur),
          child: Padding(
            padding: EdgeInsets.all(compact ? 14 : 24),
            child: Text(
              d == null ? de : '${d.total}',
              key: const Key('resultat-de'),
              style: theme.textTheme.displayLarge?.copyWith(
                color: couleur,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
    // Toucher le dé : dé libre sans bonus.
    final cercle = Semantics(
      button: true,
      label: 'Lancer le $de',
      child: InkWell(
        key: const Key('bouton-lancer-de'),
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: disque,
      ),
    );
    final titre = d == null
        ? 'Touchez un jet ou le bouton pour lancer.'
        : [
            if (d.personnage != null) d.personnage!,
            d.libelle,
            if (d.reussiteCritique) 'Réussite critique !',
            if (d.echecCritique) 'Échec critique !',
          ].join(' · ');
    final reussite = d?.reussite;
    final textes = [
      // Réussite / échec contre une difficulté : grand bandeau coloré.
      if (d != null && reussite != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _BandeauReussite(
            key: ValueKey('bandeau-$compteur'),
            reussite: reussite,
            difficulte: d.difficulte!,
            critique: d.reussiteCritique || d.echecCritique,
          ),
        ),
      Text(
        titre,
        key: const Key('commentaire-de'),
        style: theme.textTheme.titleMedium?.copyWith(color: couleur),
        textAlign: compact ? TextAlign.start : TextAlign.center,
      ),
      if (d != null)
        Text(
          d.detail,
          key: const Key('detail-de'),
          style: theme.textTheme.bodyMedium,
          textAlign: compact ? TextAlign.start : TextAlign.center,
        ),
      // D'où viennent les bonus / malus et l'avantage.
      if (d != null) _Provenance(d, centre: !compact),
    ];
    if (compact) {
      return Row(
        children: [
          cercle,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: textes,
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Center(child: cercle),
        const SizedBox(height: 12),
        ...textes,
      ],
    );
  }
}

/// Choix du personnage actif (liste déroulante) : nom, puis race et classe
/// en gris (« Brom · Nain · Prêtre »).
class _SelecteurPersonnage extends StatelessWidget {
  const _SelecteurPersonnage({
    required this.referentiel,
    required this.personnages,
    required this.preferences,
  });

  final Referentiel? referentiel;
  final PersonnagesController personnages;
  final PreferencesController preferences;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final liste = personnages.personnages;
    final id = preferences.personnageActifId;
    final connu = liste.any((p) => p.id == id);
    return DropdownButtonFormField<String?>(
      key: const Key('choix-personnage-actif'),
      initialValue: connu ? id : null,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Personnage actif',
        prefixIcon: Icon(Icons.star_outline),
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Aucun (d20 libre)'),
        ),
        for (final p in liste)
          DropdownMenuItem<String?>(
            value: p.id,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: p.nom,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text:
                        ' · ${referentiel?.race(p.raceId)?.nom ?? 'Race inconnue'}'
                        ' · ${referentiel?.classe(p.classeId)?.nom ?? 'Classe inconnue'}'
                        ' · niveau ${p.niveau}',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              key: Key('personnage-actif-${p.id}'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: preferences.changerPersonnageActif,
    );
  }
}

class _AucunActif extends StatelessWidget {
  const _AucunActif();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(top: 12),
        child: TexteAVenir(
          'Choisis un personnage actif (ici ou avec l\'étoile de la page '
          'Personnages) pour lancer ses tests, ses attaques et son '
          'initiative.',
        ),
      );
}

/// Personnage actif : rappel de ses statistiques, chaque jet est un bouton.
class _PanneauPersonnage extends StatelessWidget {
  const _PanneauPersonnage({
    required this.fiche,
    required this.onLancer,
    required this.onLancerCompetence,
    required this.repetitions,
    required this.onTerminerAttaque,
    required this.onDegatsCompetence,
    required this.situations,
    required this.cleSituation,
    required this.onSituation,
    required this.onEtat,
    required this.onSort,
    required this.onEffetSort,
    this.catalogue = const [],
    this.avecSituations = true,
    this.replies = const {},
    required this.onReplier,
    this.onUtiliser,
    this.onNouvelleAventure,
    this.onEndurance,
    this.onNouveauCombat,
    this.onNouveauJour,
  });

  /// Rend les utilisations « par combat » / « par jour ».
  final VoidCallback? onNouveauCombat;
  final VoidCallback? onNouveauJour;

  /// Capacité limitée utilisée (clé, détail) ; nouvelle aventure.
  final void Function(String cle, String detail)? onUtiliser;
  final VoidCallback? onNouvelleAventure;

  /// Action payée en endurance (PE retirés).
  final ValueChanged<({String libelle, int cout, String origine})>? onEndurance;

  /// Groupes repliés (« connaissances », « aptitudes ») et bascule.
  final Set<String> replies;
  final ValueChanged<String> onReplier;

  final FicheCalculee fiche;

  /// Aptitudes du jeu (savoirs et savoir-faire à lancer).
  final List<Aptitude> catalogue;

  /// Situations dans le panneau (sinon : colonne de gauche, grand écran).
  final bool avecSituations;

  /// (libellé, dés, bonus, caractéristique testée ou `null`, origine du
  /// bonus « CON », bonus fixes des compétences avec leur origine).
  final void Function(
    String libelle,
    String de,
    int bonus,
    Carac? carac,
    String origineBonus,
    List<BonusSituation> bonusFixes, {
    int seuilCritique,
    bool degatsCac,
    bool degatsDistance,
    String? savoir,
    bool attaque,
  }) onLancer;

  /// Jet d'une compétence (difficulté, paliers, recharge…).
  final ValueChanged<JetDisponible> onLancerCompetence;

  /// Attaques répétées en cours (Moulinet) : libellé → cibles frappées.
  final Map<String, int> repetitions;
  final ValueChanged<JetDisponible> onTerminerAttaque;

  /// Dégâts d'une attaque de compétence (lancés à part).
  final ValueChanged<JetDisponible> onDegatsCompetence;

  /// Situations cochées (bonus de tests à ajouter aux jets).
  final Set<String> situations;
  final String Function(SourceEffet) cleSituation;
  final ValueChanged<String> onSituation;

  /// Active / annule l'état d'une compétence (Visage impensable).
  final void Function(EtatCompetence etat, String competence) onEtat;

  /// Lance un sort : dépense son coût en PM.
  final void Function(Competence sort, int cout) onSort;

  /// Dégâts / effet d'un sort à jet de réussite (lancés à part).
  final void Function(Competence sort, [VarianteDegats? variante]) onEffetSort;

  /// Ordre de la fiche : aptitude à côté de sa statistique.
  static const _caracs = [
    Carac.adc,
    Carac.force,
    Carac.adt,
    Carac.dex,
    Carac.adm,
    Carac.intel,
    Carac.con,
    Carac.per,
    Carac.soc,
    Carac.men,
    Carac.chan,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final f = fiche;
    final p = f.personnage;
    final secondaire =
        theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);

    // Caractéristiques avec un avantage permanent (passif du gnome : CHAN),
    // et leur origine.
    final avantages = <Carac, String>{
      for (final s in f.bonusTestsPermanents)
        if (s.effet.carac != null &&
            (s.effet.typeNormalise == 'avantage' ||
                s.effet.valeur.toLowerCase() == 'avantage'))
          s.effet.carac!: s.nom,
    };
    final vert = couleurModificateur(1, theme.brightness);
    // Les jets d'un sort (Cri sauvage) sont lancés depuis son bouton dans
    // « Sorts » : pas de doublon dans « Compétences ».
    final nomsSorts = {for (final s in f.sorts) s.competence.nom};
    final jetsHorsSorts = [
      for (final j in f.jetsCompetences)
        // Attaque d'un sort (arme divine) : avec les autres attaques.
        if (!nomsSorts.contains(j.origine) || j.attaque != null) j,
    ];

    final degats = <Widget>[];
    for (final (cle, d) in [
      ('cac', f.detailDegatsCac),
      ('dist', f.detailDegatsDistance),
    ]) {
      for (final (i, a) in d.armes.indexed) {
        if (lireFormule(d.des(a)) == null) continue;
        degats.add(
          _BoutonJet(
            key: Key('jet-degats-$cle-$i'),
            libelle: 'Dégâts · ${DetailDegats.resumeArme(a)}',
            valeur: d.jet(a),
            large: true,
            onTap: () => onLancer('Dégâts · ${a.nom}', d.des(a), d.bonusAvec(a),
                null, d.carac.abrev, const [],
                degatsCac: cle == 'cac', degatsDistance: cle == 'dist'),
          ),
        );
      }
      // Sans arme de corps à corps : attaque à mains nues (1d4 + FOR).
      if (d.mainsNues) {
        degats.add(
          _BoutonJet(
            key: const Key('jet-degats-mains-nues'),
            libelle: 'Dégâts · Mains nues',
            valeur: formaterJet(d.desMainsNuesAvec, d.bonusMainsNues),
            large: true,
            onTap: () => onLancer('Dégâts · Mains nues', d.desMainsNuesAvec,
                d.bonusMainsNues, null, d.carac.abrev, const [],
                degatsCac: true),
          ),
        );
      }
    }

    return CarteOdv(
      key: const Key('panneau-personnage-actif'),
      selectionnee: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AvatarPersonnage(nom: p.nom),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nom,
                      style: styleAmbiance(theme.textTheme.titleLarge)
                          .copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${f.race.nom} · ${f.classe.nom} · niveau ${p.niveau}',
                      style: secondaire,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _Info(Icons.favorite, 'PV ${f.pvActuels}/${f.pvMax}',
                  OdvCouleurs.pv),
              if (f.classe.aDuMana)
                _Info(Icons.water_drop, 'PM ${f.pmActuels}/${f.pmMax}',
                    OdvCouleurs.pm),
              if (f.classe.aDeLEndurance)
                KeyedSubtree(
                  key: const Key('pe-actuels'),
                  child: _Info(kIconeEndurance, 'PE ${f.peActuels}/${f.peMax}',
                      OdvCouleurs.pe),
                ),
              _Info(
                Icons.shield_outlined,
                [
                  'CA ${f.classeArmure}',
                  if (f.caContre.isNotEmpty) '(${f.caContre.join(', ')})',
                ].join(' '),
                null,
              ),
              // Initiative = valeur de DEX + bonus (pas de jet) ; + bonus de
              // situation cochés (« entouré de végétation »).
              KeyedSubtree(
                key: const Key('initiative-actuelle'),
                child: _Info(
                  Icons.bolt,
                  'Initiative ${f.initiative + [
                        for (final s in f.initiativeSituationnelle)
                          if (situations.contains(cleSituation(s)))
                            s.effet.valeurEntiere ?? 0,
                      ].fold(0, (a, b) => a + b)}',
                  null,
                ),
              ),
            ],
          ),
          const _Titre('Tests de caractéristique', Icons.casino_outlined),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in _caracs)
                _BoutonJet(
                  key: Key('test-${c.code}'),
                  libelle: c.abrev,
                  valeur: formaterModificateur(f.mod(c)),
                  // Avantage permanent (gnome : CHAN) : bouton en vert.
                  precision: avantages.containsKey(c) ? 'avantage' : '',
                  couleurPrecision: avantages.containsKey(c) ? vert : null,
                  miseEnAvant: avantages.containsKey(c) ? vert : null,
                  infobulle: 'Test de ${c.nom} : 1d20 '
                      '${formaterModificateur(f.mod(c))}'
                      '${avantages.containsKey(c) ? '\nAvantage : ${avantages[c]}' : ''}',
                  onTap: () => onLancer('Test de ${c.abrev}', '1d20', f.mod(c),
                      c, c.abrev, const []),
                ),
              // Jet d'esquive : contre ce qui n'a pas de jet d'attaque (souffle,
              // trait des arcanes) ; réussi, il annule dégâts et effet.
              _BoutonJet(
                key: const Key('jet-esquive'),
                libelle: 'Esquive',
                valeur: formaterModificateur(f.bonusJetEsquive),
                infobulle: "Jet d'esquive : 1d20 "
                    '${formaterModificateur(f.bonusJetEsquive)} '
                    "(DEX limitée par l'armure + bonus d'esquive)\n"
                    "Contre ce qui n'a pas de jet d'attaque ; réussi, il annule "
                    'dégâts et effet. 1 esquive par tour.',
                onTap: () => onLancer("Jet d'esquive", '1d20',
                    f.bonusJetEsquive, null, 'Esquive', const []),
              ),
            ],
          ),
          // Capacités à usage limité (Droit du sang : faire jouer son titre).
          if (f.usages.isNotEmpty) ...[
            const _Titre('Usages limités', Icons.event_available_outlined),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final u in f.usages)
                  _BoutonJet(
                    key: Key('usage-${u.cle}'),
                    libelle: u.nom,
                    valeur: '${u.restants} / ${u.max}',
                    large: true,
                    precision: u.restants == 0
                        ? 'épuisé ${u.periode}'.trim()
                        : 'restants ${u.periode}'.trim(),
                    infobulle: [
                      '${u.origine} : ${u.max}× ${u.periode}'.trim(),
                      if (u.detail.isNotEmpty) u.detail,
                    ].join('\n'),
                    onTap: u.restants == 0 || onUtiliser == null
                        ? null
                        : () => onUtiliser!(u.cle, u.detail),
                  ),
                if (f.usages.any(
                    (u) => u.restants < u.max && u.periode.contains('combat')))
                  TextButton.icon(
                    key: const Key('nouveau-combat'),
                    onPressed: onNouveauCombat,
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Nouveau combat'),
                  ),
                if (f.usages.any(
                    (u) => u.restants < u.max && u.periode.contains('jour')))
                  TextButton.icon(
                    key: const Key('nouveau-jour'),
                    onPressed: onNouveauJour,
                    icon: const Icon(Icons.wb_sunny_outlined),
                    label: const Text('Nouveau jour'),
                  ),
                if (f.usages.any((u) => u.restants < u.max))
                  TextButton.icon(
                    key: const Key('nouvelle-aventure'),
                    onPressed: onNouvelleAventure,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Nouvelle aventure'),
                  ),
              ],
            ),
          ],
          // Combat : attaques, sorts, compétences, états (l'initiative est une
          // valeur, dans le rappel en haut).
          const _Categorie('Combat', Icons.sports_martial_arts, cle: 'combat'),
          const _Titre('Attaques', Icons.gps_fixed),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Toucher : aptitude + bonus des compétences avec l'arme
              // équipée (gnome : +1 avec l'arme déjà maîtrisée).
              // Armement barbare, deux armes : l'arme principale attaque au
              // d20, la secondaire au d12.
              for (final (cle, libelle, de, bonus, carac, fixes) in [
                if (f.armesDoubles case final dbl?) ...[
                  (
                    'cac',
                    'CaC · ${dbl.principale.nom}',
                    '1d20',
                    f.toucherCac,
                    Carac.adc,
                    f.bonusToucher(distance: false),
                  ),
                  (
                    'cac-secondaire',
                    'CaC · ${dbl.secondaire.nom} (2ᵉ)',
                    // Ambidextrie : d20 ; armement barbare : d12.
                    f.ambidextre ? '1d20' : '1d12',
                    f.toucherCac,
                    Carac.adc,
                    f.bonusToucher(distance: false),
                  ),
                ] else
                  (
                    'cac',
                    'CaC',
                    '1d20',
                    f.toucherCac,
                    Carac.adc,
                    f.bonusToucher(distance: false),
                  ),
                (
                  'dist',
                  'Distance',
                  '1d20',
                  f.toucherDistance,
                  Carac.adt,
                  f.bonusToucher(distance: true),
                ),
                (
                  'mag',
                  'Magie',
                  '1d20',
                  f.toucherMagie,
                  Carac.adm,
                  <BonusSituation>[]
                ),
              ])
                () {
                  // Arme familiale légendaire : critique sur 19-20.
                  final crit = carac == Carac.adm
                      ? (seuil: 20, origine: '')
                      : f.seuilCritique(distance: carac == Carac.adt);
                  return _BoutonJet(
                    key: Key('jet-toucher-$cle'),
                    libelle: 'Toucher $libelle',
                    valeur: formaterJet(de, bonus),
                    large: true,
                    precision:
                        crit.seuil < 20 ? 'critique ${crit.seuil}-20' : '',
                    couleurPrecision: crit.seuil < 20
                        ? couleurModificateur(1, theme.brightness)
                        : null,
                    infobulle: crit.seuil < 20
                        ? 'Réussite critique sur ${crit.seuil}-20 '
                            '(${crit.origine})'
                        : null,
                    onTap: () => onLancer('Toucher $libelle', de, f.mod(carac),
                        carac, carac.abrev, fixes,
                        seuilCritique: crit.seuil, attaque: true),
                  );
                }(),
              ...degats,
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Dégâts magiques : dé du sort '
            '${formaterModificateur(f.degatsMagie)}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          // Sorts : lancer dépense le mana (coût selon le rang du sort).
          if (f.sorts.isNotEmpty) ...[
            const _Titre('Sorts', Icons.auto_awesome),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (i, s) in f.sorts.indexed)
                  _CarteSort(
                    key: Key('sort-$i'),
                    index: i,
                    sort: s.competence,
                    cout: s.cout,
                    reussite: f.jetReussite(s.competence),
                    effets: f.jetsEffetSort(s.competence),
                    manque: f.pointsPourSorts < s.cout,
                    enEndurance: f.sortsEnEndurance,
                    infobulle: '${s.competence.nom} : sort de rang '
                        '${s.rangSort}, ${s.cout} ${f.uniteSorts} à '
                        "l'activation (${f.uniteSorts} actuels : "
                        '${f.pointsPourSorts})',
                    onLancer: f.pointsPourSorts < s.cout
                        ? null
                        : () => onSort(s.competence, s.cout),
                    onEffet: ([v]) => onEffetSort(s.competence, v),
                  ),
              ],
            ),
          ],
          // Jets des compétences et du passif (griffes, coup de queue,
          // souffle…).
          if (jetsHorsSorts.isNotEmpty) ...[
            const _Titre('Compétences', Icons.auto_stories_outlined),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (i, j) in jetsHorsSorts.indexed)
                  if (j.attaque case final a?) ...[
                    // Attaque de compétence (Brutalité, Moulinet, Frénésie,
                    // Attaque sautée) : le jet d'attaque, puis les dégâts à
                    // part, à lancer seulement si l'attaque a touché.
                    () {
                      final arme = f.armeAttaque(a);
                      final n = repetitions[j.libelle] ?? 0;
                      final repete = a.repetable != null && n > 0;
                      // Justice divine : 5 PM par attaque.
                      final sansPm = j.coutPm > f.pmActuels;
                      return _BoutonJet(
                        key: Key('jet-competence-$i'),
                        libelle: repete
                            ? '${j.libelle} · cible ${n + 1}'
                            : j.libelle,
                        valeur: formaterJet(
                            j.des.isEmpty ? '1d20' : j.des,
                            (a.distance == true
                                    ? f.toucherDistance
                                    : f.toucherCac) +
                                (a.toucher ?? 0)),
                        precision: arme == null && !a.sansArme
                            ? (a.deuxMains == true
                                ? 'arme à 2 mains requise'
                                : a.arme != null
                                    ? '${a.arme!.toLowerCase()} requise'
                                    : a.distance == true
                                        ? 'arme à distance requise'
                                        : 'arme de CaC requise')
                            : [
                                'attaque',
                                if (j.coutPm > 0)
                                  sansPm
                                      ? 'mana insuffisant (${j.coutPm} PM)'
                                      : '−${j.coutPm} PM',
                                if (a.toucher != null)
                                  '${formaterModificateur(a.toucher!)} '
                                      '${a.distance == true ? 'AdT' : 'AdC'}',
                              ].join(' · '),
                        infobulle: [
                          a.distance == true
                              ? '${j.origine} : attaque à distance '
                                  '(dé + toucher distance) ; les dégâts se '
                                  'lancent à part si elle touche'
                              : '${j.origine} : attaque au corps à corps '
                                  '(dé + toucher CaC) ; les dégâts se lancent '
                                  'à part si elle touche',
                          if (a.repetable != null)
                            'Répétable sur une cible suivante'
                                '${a.repetable == 0 ? '' : ' (${a.repetable} DM à chaque fois)'}',
                        ].join('\n'),
                        large: true,
                        onTap: (arme == null && !a.sansArme) || sansPm
                            ? null
                            : () => onLancerCompetence(j),
                      );
                    }(),
                    () {
                      final arme = f.armeAttaque(a);
                      final n = repetitions[j.libelle] ?? 0;
                      final cible = a.repetable != null && n > 1 ? n : 0;
                      // Mains nues (moine) : pas d'arme requise.
                      final nues = a.sansArme;
                      final d = arme == null && !nues
                          ? null
                          : degatsAttaque(f, j, nues ? null : arme,
                              cible: cible);
                      return _BoutonJet(
                        key: Key('degats-competence-$i'),
                        libelle: 'Dégâts · ${j.libelle}'
                            '${cible > 1 ? ' (cible $cible)' : ''}',
                        valeur: d == null
                            ? '—'
                            : formaterJet(
                                d.des,
                                d.bonus +
                                    d.fixes.fold(0, (s, b) => s + b.valeur)),
                        precision: d == null
                            ? ''
                            : [
                                for (final b in d.fixes)
                                  '${formaterModificateur(b.valeur)} ${b.nom}',
                                if ((a.explosion ?? 0) > 0)
                                  'dé ajouté relancé sur un ${lireDes(a.degatsEnPlus ?? '')?.faces ?? ''}',
                                if ((a.diviseDegats ?? 1) > 1)
                                  'dégâts ÷${a.diviseDegats}',
                              ].join(' · '),
                        infobulle: d == null
                            ? null
                            : 'Dégâts ${a.armeInvoquee != null ? deNom(a.armeInvoquee!.toLowerCase()) : nues ? 'à mains nues' : 'de ${arme!.nom}'}'
                                ' et dés ajoutés, en un seul jet : '
                                '${formaterJet(d.des, d.bonus)}',
                        large: true,
                        onTap: d == null ? null : () => onDegatsCompetence(j),
                      );
                    }(),
                    if (a.repetable != null &&
                        (repetitions[j.libelle] ?? 0) > 0)
                      OutlinedButton.icon(
                        key: Key('terminer-attaque-$i'),
                        onPressed: () => onTerminerAttaque(j),
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: Text('Terminer ${j.libelle.toLowerCase()}'),
                      ),
                  ] else
                    _BoutonJet(
                      key: Key('jet-competence-$i'),
                      libelle: j.libelle,
                      valeur: formaterJet(j.des, j.bonus),
                      precision: [
                        if (j.requiert.isNotEmpty &&
                            f.objetNomme(j.requiert) == null)
                          'sans ${j.requiert.toLowerCase()}',
                        // Prestation musicale sans instrument maîtrisé.
                        if (j.instrument && f.instrumentsMaitrises.isEmpty)
                          'instrument maîtrisé requis',
                        if (j.gain != null)
                          'gain : ${j.gain!.des ?? '1d20'} + ${j.gain!.carac ?? ''} ${j.gain!.piece ?? 'cuivre'}',
                        if (j.avantage) 'avantage',
                        if (j.difficulte != null) 'diff. ${j.difficulte}',
                        if (j.recharge.isNotEmpty) 'recharge ${j.recharge}',
                        if (j.detruit.isNotEmpty)
                          'détruit ${j.detruit.toLowerCase()}',
                      ].join(' · '),
                      couleurPrecision: j.avantage
                          ? couleurModificateur(1, theme.brightness)
                          : null,
                      infobulle: [
                        '${j.origine} : ${formaterJet(j.des, j.bonus)}',
                        if (j.avantage)
                          'Avantage'
                              '${j.amelioration.isEmpty ? '' : ' (${j.amelioration})'}'
                              ' : 2 d20, on garde le meilleur',
                        if (j.difficulte != null)
                          'Réussite si le total atteint ${j.difficulte}',
                        if (j.recharge.isNotEmpty)
                          'Recharge après usage : ${j.recharge} tours',
                      ].join('\n'),
                      large: true,
                      // Objet requis absent (porte-bonheur détruit) : grisé.
                      onTap: (j.requiert.isNotEmpty &&
                                  f.objetNomme(j.requiert) == null) ||
                              (j.instrument && f.instrumentsMaitrises.isEmpty)
                          ? null
                          : () => onLancerCompetence(j),
                    ),
              ],
            ),
          ],
          // Actions payées en endurance (classes physiques et hybrides).
          if (f.actionsEndurance.isNotEmpty) ...[
            const _Titre('Endurance', kIconeEndurance),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (i, a) in f.actionsEndurance.indexed)
                  _BoutonJet(
                    key: Key('endurance-$i'),
                    libelle: a.libelle,
                    valeur: '−${a.cout} PE',
                    large: true,
                    precision: f.peActuels < a.cout ? 'PE insuffisants' : '',
                    infobulle: '${a.origine} : ${a.cout} PE dépensés '
                        '(PE actuels : ${f.peActuels})',
                    onTap: f.peActuels < a.cout || onEndurance == null
                        ? null
                        : () => onEndurance!(a),
                  ),
              ],
            ),
          ],
          // États activables (Visage impensable : apparence monstrueuse).
          if (f.etatsPossibles.isNotEmpty) ...[
            const _Titre('États', Icons.theater_comedy_outlined),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in f.etatsPossibles)
                  FilterChip(
                    key: Key('etat-${e.etat.nom}'),
                    avatar: const Icon(Icons.theater_comedy_outlined, size: 18),
                    label: Text(
                      p.etats.contains(e.etat.nom)
                          ? '${e.etat.nom} (active) · annuler'
                          : '${e.competence.nom} : activer',
                    ),
                    selected: p.etats.contains(e.etat.nom),
                    showCheckmark: false,
                    onSelected: (_) => onEtat(e.etat, e.competence.nom),
                  ),
              ],
            ),
          ],
          // Effets reçus d'un allié actifs (Agrandi) : rappel, annulables ;
          // ils se cochent sur la fiche.
          if (f.etatsRecus.any((e) => p.etats.contains(e.etat.nom))) ...[
            const _Titre('Effets reçus', Icons.auto_fix_high_outlined),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in f.etatsRecus)
                  if (p.etats.contains(e.etat.nom))
                    FilterChip(
                      key: Key('etat-${e.etat.nom}'),
                      avatar:
                          const Icon(Icons.auto_fix_high_outlined, size: 18),
                      label: Text('${e.etat.nom} (reçu) · annuler'),
                      selected: true,
                      showCheckmark: false,
                      onSelected: (_) => onEtat(e.etat, e.competence.nom),
                    ),
              ],
            ),
          ],
          // Connaissances : savoirs (maîtrisés +5, complexes −5 sans).
          // Groupes repliables (touche le titre) : état gardé par la page.
          () {
            final jets = jetsSavoirs(f, catalogue, FamilleAptitude.savoir);
            final ouvert = !replies.contains('connaissances');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Categorie(
                  'Connaissances',
                  Icons.menu_book_outlined,
                  cle: 'connaissances',
                  ouvert: ouvert,
                  nombre: jets.length,
                  onBasculer: () => onReplier('connaissances'),
                ),
                if (ouvert)
                  _ListeSavoirs(
                    jets: jets,
                    fiche: f,
                    famille: FamilleAptitude.savoir,
                    onLancer: onLancer,
                  ),
              ],
            );
          }(),
          // Aptitudes : savoir-faire, puis instruments.
          _Categorie(
            'Aptitudes',
            Icons.handyman_outlined,
            cle: 'aptitudes',
            ouvert: !replies.contains('aptitudes'),
            nombre:
                jetsSavoirs(f, catalogue, FamilleAptitude.savoirFaire).length +
                    f.instrumentsMaitrises.length,
            onBasculer: () => onReplier('aptitudes'),
          ),
          if (!replies.contains('aptitudes')) ...[
            _ListeSavoirs(
              jets: jetsSavoirs(f, catalogue, FamilleAptitude.savoirFaire),
              fiche: f,
              famille: FamilleAptitude.savoirFaire,
              onLancer: onLancer,
            ),
            // Instruments : maîtrisés → 1d20 + DEX (+ bonus) ; non maîtrisé →
            // échec automatique (règle système).
            const _Titre('Instruments', Icons.music_note_outlined,
                guitare: true),
            if (f.instrumentsMaitrises.isEmpty)
              Text(
                'Aucun instrument maîtrisé : jouer d\'un instrument est un '
                'échec automatique.',
                key: const Key('aucun-instrument'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              )
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (i, ins) in f.instrumentsMaitrises.indexed)
                    _BoutonJet(
                      key: Key('jet-instrument-$i'),
                      libelle: 'Jouer : ${ins.nom}',
                      valeur: formaterJet('1d20', f.mod(Carac.dex) + ins.bonus),
                      precision: [
                        if (ins.bonus != 0)
                          '${formaterModificateur(ins.bonus)} ${ins.origine}',
                        if (f.avantageInstrument != null) 'avantage',
                      ].join(' · '),
                      couleurPrecision: f.avantageInstrument != null
                          ? couleurModificateur(1, theme.brightness)
                          : null,
                      large: true,
                      // Jet de compétence : avantage du Musicien renommé.
                      onTap: () => onLancerCompetence(JetDisponible(
                        libelle: 'Jouer : ${ins.nom}',
                        des: '1d20',
                        origine: 'Instrument',
                        bonus: f.mod(Carac.dex) + ins.bonus,
                        carac: Carac.dex,
                        libelleCaracs:
                            ins.bonus == 0 ? '' : 'DEX + ${ins.origine}',
                        avantage: f.avantageInstrument != null,
                        amelioration: f.avantageInstrument ?? '',
                      )),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Autre instrument (non maîtrisé) : échec automatique.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
          // Situations : ici sur téléphone ; à gauche sur très grand écran.
          if (avecSituations && BlocSituations.aDuContenu(f))
            BlocSituations(
              fiche: f,
              situations: situations,
              cleSituation: cleSituation,
              onSituation: onSituation,
            ),
        ],
      ),
    );
  }
}

/// Bonus toujours appliqués et situations à cocher (traits qui ajoutent
/// un bonus aux jets selon le moment). Vide s'il n'y en a aucun.
class BlocSituations extends StatelessWidget {
  const BlocSituations({
    super.key,
    required this.fiche,
    required this.situations,
    required this.cleSituation,
    required this.onSituation,
  });

  final FicheCalculee fiche;
  final Set<String> situations;
  final String Function(SourceEffet) cleSituation;
  final ValueChanged<String> onSituation;

  static bool aDuContenu(FicheCalculee f) =>
      f.bonusTestsPermanents.isNotEmpty || f.bonusTestsSituationnels.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final f = fiche;
    return Column(
      key: const Key('bloc-situations'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bonus sans condition : toujours appliqués (pas de case).
        if (f.bonusTestsPermanents.isNotEmpty) ...[
          const _Titre('Toujours appliqués', Icons.verified_outlined),
          Wrap(
            key: const Key('bonus-permanents'),
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in f.bonusTestsPermanents)
                _Pastille(
                  icone: Icons.check,
                  texte: TextSpan(text: '${s.effet.libelle} · ${s.nom}'),
                ),
            ],
          ),
        ],
        // Bonus à cocher selon le moment ; ajoutés automatiquement aux
        // jets concernés.
        if (f.bonusTestsSituationnels.isNotEmpty) ...[
          const _Titre('Situations (à cocher)', Icons.trending_up),
          _Situations(
            sources: f.bonusTestsSituationnels,
            cochees: situations,
            cle: cleSituation,
            onBasculer: onSituation,
          ),
        ],
      ],
    );
  }
}

/// Grande catégorie de jets (Combat, Connaissances, Aptitudes) : titre en
/// capitales or, souligné.
class _Categorie extends StatelessWidget {
  const _Categorie(
    this.texte,
    this.icone, {
    required this.cle,
    this.ouvert,
    this.onBasculer,
    this.nombre,
  });

  final String texte;
  final IconData icone;
  final String cle;

  /// Repliable : `true` ouvert, `false` replié (chevron) ; `null` : fixe.
  final bool? ouvert;
  final VoidCallback? onBasculer;

  /// Nombre de jets, affiché quand le groupe est replié.
  final int? nombre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final titre = Row(
      children: [
        Icon(icone, size: 22, color: scheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texte.toUpperCase(),
            style: styleAmbiance(theme.textTheme.titleMedium).copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
              letterSpacing: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (ouvert == false && nombre != null)
          Text(
            '$nombre',
            style: theme.textTheme.labelMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        if (ouvert != null)
          AnimatedRotation(
            turns: ouvert! ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.expand_more, color: scheme.primary),
          ),
      ],
    );
    return Padding(
      key: Key('categorie-jets-$cle'),
      padding: const EdgeInsets.only(top: 24, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ouvert == null)
            titre
          else
            Semantics(
              button: true,
              label: ouvert! ? 'Réduire $texte' : 'Afficher $texte',
              child: InkWell(
                key: Key('replier-$cle'),
                borderRadius: BorderRadius.circular(8),
                onTap: onBasculer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: titre,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Divider(
            height: 1,
            thickness: 1.5,
            color: scheme.primary.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}

/// Jets de savoirs ou de savoir-faire : maîtrisés d'abord (bordure verte,
/// +5), puis les autres (« non maîtrisé · −5 » en rouge s'ils sont
/// complexes). Les bonus de test de la caractéristique sont rappelés.
class _ListeSavoirs extends StatelessWidget {
  const _ListeSavoirs({
    required this.jets,
    required this.fiche,
    required this.famille,
    required this.onLancer,
  });

  final List<JetSavoir> jets;
  final FicheCalculee fiche;
  final FamilleAptitude famille;
  final void Function(
    String libelle,
    String de,
    int bonus,
    Carac? carac,
    String origineBonus,
    List<BonusSituation> bonusFixes, {
    int seuilCritique,
    String? savoir,
  }) onLancer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final f = fiche;
    final vert = couleurModificateur(1, theme.brightness);
    final rouge = couleurModificateur(-1, theme.brightness);
    final type = famille == FamilleAptitude.savoir ? 'Savoir' : 'Savoir-faire';
    // Bonus de test toujours appliqués, par caractéristique.
    String bonusPermanents(Carac c) => [
          for (final s in f.bonusTestsPermanents)
            if (s.effet.carac == c && (s.effet.valeurEntiere ?? 0) != 0)
              '${formaterModificateur(s.effet.valeurEntiere!)} ${s.nom}'
            else if (s.effet.carac == c &&
                (s.effet.typeNormalise == 'avantage' ||
                    s.effet.valeur.toLowerCase() == 'avantage'))
              'avantage',
        ].join(' · ');
    if (jets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Aucun ${type.toLowerCase()} disponible.',
          style: theme.textTheme.bodySmall,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final j in jets)
            () {
              final permanents = bonusPermanents(j.carac);
              return _BoutonJet(
                key: Key('jet-savoir-${j.aptitude.id}'
                    '${j.precision == null ? '' : '-${j.precision}'}'),
                libelle: j.libelle,
                valeur: formaterJet('1d20', f.mod(j.carac) + j.total),
                large: true,
                precision: [
                  j.mention,
                  if (permanents.isNotEmpty) permanents,
                ].join(' · '),
                couleurPrecision: j.maitrise
                    ? vert
                    : j.modificateur < 0
                        ? rouge
                        : null,
                iconePrecision: j.modificateur < 0
                    ? Icons.keyboard_double_arrow_down
                    : Icons.keyboard_double_arrow_up,
                miseEnAvant: j.maitrise ? vert : null,
                infobulle:
                    '$type ${j.aptitude.complexe ? 'complexe' : 'basique'}'
                    ' · ${j.libelle} : 1d20 + ${j.carac.abrev}'
                    '${[
                  for (final b in j.bonusFixes)
                    ' ${formaterModificateur(b.valeur)} (${b.nom.toLowerCase()})'
                ].join()}'
                    '${j.aptitude.description.isEmpty ? '' : '\n${j.aptitude.description}'}',
                onTap: () => onLancer('$type · ${j.libelle}', '1d20',
                    f.mod(j.carac), j.carac, j.carac.abrev, j.bonusFixes,
                    savoir: j.aptitude.nom),
              );
            }(),
        ],
      ),
    );
  }
}

class _Titre extends StatelessWidget {
  const _Titre(this.texte, this.icone, {this.guitare = false});

  final String texte;
  final IconData icone;

  /// Guitare dessinée à la place de l'icône (instruments).
  final bool guitare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          if (guitare)
            IconeGuitare(taille: 18, couleur: theme.colorScheme.primary)
          else
            Icon(icone, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texte,
              style: styleAmbiance(theme.textTheme.titleSmall)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// « ♥ PV 15/71 », « CA 16 ».
class _Info extends StatelessWidget {
  const _Info(this.icone, this.texte, this.couleur);

  final IconData icone;
  final String texte;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final c = couleur ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 16, color: c),
        const SizedBox(width: 4),
        Text(texte, style: TextStyle(color: c, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// Bouton de jet : libellé (« FOR », « Toucher CaC ») et valeur (« +3 »,
/// « 1d20 +2 »).
/// Sort à lancer : nom, libellés (mana, jet de réussite, dégâts, soin,
/// effet). Sans jet de réussite, toute la carte lance le sort (mana, puis
/// dégâts / effet). Avec un jet de réussite, deux boutons : « Lancer le
/// sort » (mana + jet de réussite) puis « Dégâts / effet », lancés à part
/// (seulement si le sort a touché). Grisé si les PM ne suffisent pas.
class _CarteSort extends StatelessWidget {
  const _CarteSort({
    super.key,
    required this.index,
    required this.sort,
    required this.cout,
    required this.reussite,
    required this.effets,
    required this.manque,
    this.enEndurance = false,
    required this.infobulle,
    required this.onLancer,
    required this.onEffet,
  });

  final int index;
  final Competence sort;
  final int cout;
  final JetDisponible? reussite;
  final List<JetDisponible> effets;
  final bool manque;

  /// Classe sans mana : coût en PE.
  final bool enEndurance;
  final String infobulle;
  final VoidCallback? onLancer;

  /// Dégâts / effet, avec une variante (×2, ÷2) ou non.
  final void Function([VarianteDegats? variante]) onEffet;

  static String _jet(JetDisponible j) => [
        formaterJet(j.des, j.bonus),
        if (j.difficulte != null) 'diff. ${j.difficulte}',
      ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final r = reussite;
    final resumeEffets = effets.map(_jet).join(' · ');
    final contenu = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 16, color: scheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                sort.nom,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LibellesSort(sort, enEndurance: enEndurance),
        if (manque) ...[
          const SizedBox(height: 4),
          Text(
            enEndurance ? 'PE insuffisants' : 'mana insuffisant',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ] else if (r == null && resumeEffets.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Jet : $resumeEffets',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        // Jet de réussite : deux boutons séparés.
        if (r != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              FilledButton.tonalIcon(
                key: Key('lancer-sort-$index'),
                onPressed: onLancer,
                icon: const Icon(Icons.casino_outlined, size: 18),
                label: Text('Lancer · −$cout PM · ${_jet(r)}'),
              ),
              if (effets.isNotEmpty)
                OutlinedButton.icon(
                  key: Key('effet-sort-$index'),
                  onPressed: onEffet,
                  icon: const Icon(Icons.bolt, size: 18),
                  label: Text('Dégâts / effet · $resumeEffets'),
                ),
              // Variantes (×2 contre les morts-vivants, ÷2 si esquivé).
              if (effets.isNotEmpty)
                for (final (k, v) in sort.variantesDegats.indexed)
                  OutlinedButton.icon(
                    key: Key('effet-sort-$index-$k'),
                    onPressed: () => onEffet(v),
                    icon: const Icon(Icons.bolt, size: 18),
                    label: Text(
                        'Dégâts ${v.multiplie > 1 ? '×${v.multiplie}' : '÷${v.divise}'} · ${v.libelle}'),
                  ),
            ],
          ),
        ],
      ],
    );
    return Tooltip(
      message: infobulle,
      child: SizedBox(
        width: r == null ? 260 : 340,
        child: r == null
            ? OutlinedButton(
                onPressed: onLancer,
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: contenu,
              )
            : Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: contenu,
              ),
      ),
    );
  }
}

class _BoutonJet extends StatelessWidget {
  const _BoutonJet({
    super.key,
    required this.libelle,
    required this.valeur,
    required this.onTap,
    this.infobulle,
    this.large = false,
    this.precision = '',
    this.couleurPrecision,
    this.iconePrecision = Icons.keyboard_double_arrow_up,
    this.miseEnAvant,
  });

  final String libelle;
  final String valeur;

  /// Flèche devant la précision colorée (vers le bas : malus).
  final IconData iconePrecision;

  /// `null` : bouton désactivé (objet requis absent…).
  final VoidCallback? onTap;
  final String? infobulle;

  /// Bouton de combat (plus large que ceux des caractéristiques).
  final bool large;

  /// Petite ligne sous la valeur (« avantage · diff. 10 »).
  final String precision;
  final Color? couleurPrecision;

  /// Bordure et valeur de cette couleur (stat avec avantage : vert).
  final Color? miseEnAvant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bouton = SizedBox(
      width: large ? 168 : 84,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: miseEnAvant == null
              ? null
              : BorderSide(color: miseEnAvant!, width: 2),
          backgroundColor: miseEnAvant?.withValues(alpha: 0.1),
        ),
        child: Column(
          children: [
            Text(
              libelle,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valeur,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: miseEnAvant,
                ),
              ),
            ),
            if (precision.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (couleurPrecision != null)
                    Icon(
                      iconePrecision,
                      size: 14,
                      color: couleurPrecision,
                    ),
                  Flexible(
                    child: Text(
                      precision,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: couleurPrecision ?? scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
    return infobulle == null
        ? bouton
        : Tooltip(message: infobulle, child: bouton);
  }
}

/// Situations à cocher, regroupées : « Tous les jets » (bonus sans
/// caractéristique), puis une ligne par caractéristique (ses tests
/// seulement). Chaque pastille montre le bonus et la situation ; le trait
/// d'origine est au survol.
/// Pastille dont le texte passe à la ligne au lieu d'être coupé (bonus
/// toujours appliqués, situations à cocher). Avec [onTap] : se coche.
class _Pastille extends StatelessWidget {
  const _Pastille({
    super.key,
    required this.texte,
    this.icone,
    this.choisie = false,
    this.onTap,
  });

  final InlineSpan texte;
  final IconData? icone;
  final bool choisie;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ic = choisie ? Icons.check : icone;
    return Material(
      color: choisie ? scheme.secondaryContainer : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: choisie ? scheme.primary : scheme.outlineVariant,
          width: choisie ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ic != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(ic, size: 16, color: scheme.primary),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text.rich(
                  texte,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Situations extends StatelessWidget {
  const _Situations({
    required this.sources,
    required this.cochees,
    required this.cle,
    required this.onBasculer,
  });

  final List<SourceEffet> sources;
  final Set<String> cochees;
  final String Function(SourceEffet) cle;
  final ValueChanged<String> onBasculer;

  /// « +5 », « −1 », « Avantage ».
  static String _bonus(SourceEffet s) {
    final e = s.effet;
    if (e.typeNormalise == 'avantage' || e.valeur.toLowerCase() == 'avantage') {
      return 'Avantage';
    }
    final v = e.valeurEntiere;
    final base = v == null
        ? (e.valeur.startsWith('+') ? e.valeur : '+${e.valeur}')
        : formaterModificateur(v);
    // Défense : laquelle (« +3 CA au CaC », « +2 Esquive »).
    String contre(String c) => switch (c) {
          'cac' => 'au CaC',
          'dist' => 'à distance',
          'mag' => 'contre les sorts',
          _ => c,
        };
    return switch (e.typeNormalise) {
      'esquive' when e.categorie.isEmpty => '$base Esquive',
      'esquive' ||
      'ca' when e.categorie.isNotEmpty =>
        '$base CA ${contre(e.categorieNormalisee)}',
      'ca' => '$base CA',
      'savoir' => '$base ${e.categorie}',
      _ => base,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Groupes dans l'ordre : tous les jets, puis l'ordre des caractéristiques.
    // Groupe : « tous », code de caractéristique, « degats » ou « ca ».
    String groupe(SourceEffet s) => switch (s.effet.typeNormalise) {
          'degats' when s.effet.categorieNormalisee == 'dist' => 'degats-dist',
          'degats' => 'degats',
          'ca' || 'esquive' => 'ca',
          'savoir' => 'savoirs',
          _
              when s.effet.carac == null &&
                  s.effet.categorieNormalisee == 'init' =>
            'init',
          _ => s.effet.carac?.code ?? 'tous',
        };
    final groupes = <String, List<SourceEffet>>{};
    for (final s in sources) {
      (groupes[groupe(s)] ??= []).add(s);
    }
    final ordre = [
      if (groupes.containsKey('tous')) 'tous',
      if (groupes.containsKey('init')) 'init',
      for (final c in Carac.values)
        if (groupes.containsKey(c.code)) c.code,
      if (groupes.containsKey('savoirs')) 'savoirs',
      if (groupes.containsKey('degats')) 'degats',
      if (groupes.containsKey('degats-dist')) 'degats-dist',
      if (groupes.containsKey('ca')) 'ca',
    ];
    String titre(String g) => switch (g) {
          'tous' => 'Tous les jets',
          'init' => 'Initiative',
          'savoirs' => 'Savoirs',
          'degats' => 'Dégâts CaC',
          'degats-dist' => 'Dégâts à distance',
          'ca' => 'CA',
          _ => 'Tests ${Carac.depuisCode(g)?.abrev ?? g}',
        };
    final actives = sources.where((s) => cochees.contains(cle(s))).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          actives == 0
              ? 'Coche ce qui s\'applique en ce moment : le bonus s\'ajoute '
                  'tout seul aux jets concernés.'
              : '$actives situation${actives > 1 ? 's' : ''} active'
                  '${actives > 1 ? 's' : ''}.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        for (final c in ordre)
          Padding(
            key: Key('groupe-situation-$c'),
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Étiquette du groupe : « Tous » ou la caractéristique.
                Container(
                  width: 64,
                  margin: const EdgeInsets.only(top: 6, right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: c == 'tous'
                        ? scheme.tertiaryContainer
                        : scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    titre(c),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: c == 'tous'
                          ? scheme.onTertiaryContainer
                          : scheme.onSecondaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in groupes[c]!)
                        Tooltip(
                          message: '${s.nom} — ${s.effet.libelle}',
                          child: _Pastille(
                            key: Key('situation-${cle(s)}'),
                            texte: TextSpan(
                              children: [
                                TextSpan(
                                  text: _bonus(s),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: couleurModificateur(
                                      s.effet.valeurEntiere ?? 1,
                                      theme.brightness,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: s.effet.condition.isEmpty
                                      ? ' · ${s.nom}'
                                      : ' ${s.effet.condition}',
                                ),
                              ],
                            ),
                            choisie: cochees.contains(cle(s)),
                            onTap: () => onBasculer(cle(s)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Historique des lancers (du plus récent au plus ancien).
class _Historique extends StatelessWidget {
  const _Historique({required this.lancers, required this.onEffacer});

  final List<ResultatLancer> lancers;
  final VoidCallback onEffacer;

  static String _heure(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (lancers.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Historique des lancers',
                style: theme.textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              key: const Key('effacer-historique-lancers'),
              onPressed: onEffacer,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Effacer'),
            ),
          ],
        ),
        for (final (i, l) in lancers.indexed)
          ListTile(
            key: Key('lancer-$i'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: l.reussiteCritique
                  ? OdvCouleurs.darkGreen
                  : l.echecCritique
                      ? scheme.errorContainer
                      : scheme.surfaceContainerHighest,
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    '${l.total}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: l.reussiteCritique
                          ? Colors.white
                          : l.echecCritique
                              ? scheme.onErrorContainer
                              : scheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              [if (l.personnage != null) l.personnage!, l.libelle].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${l.detail}'
              '${l.reussiteCritique ? ' · réussite critique' : ''}'
              '${l.echecCritique ? ' · échec critique' : ''}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(_heure(l.date), style: theme.textTheme.bodySmall),
          ),
      ],
    );
  }
}

/// Dégâts d'une attaque de compétence avec [arme] : dés de l'arme (ou ceux
/// qui les remplacent) et dés ajoutés regroupés, bonus de FOR et bonus
/// fixes (« +6 Brutalité », malus de la [cible] suivante au Moulinet).
({String des, int bonus, List<BonusSituation> fixes}) degatsAttaque(
  FicheCalculee fiche,
  JetDisponible j,
  Objet? arme, {
  int cible = 0,
}) {
  final a = j.attaque!;
  final d =
      a.distance == true ? fiche.detailDegatsDistance : fiche.detailDegatsCac;
  String des;
  int bonus;
  if (arme == null) {
    // Mains nues (moine) : dés à mains nues, ou ceux de l'attaque
    // (Uppercut 2d6) avec les dés ajoutés des compétences.
    des = (a.degatsArme ?? '').isNotEmpty
        ? d.desMainsNuesAvec.replaceFirst(d.desMainsNues, a.degatsArme!)
        : d.desMainsNuesAvec;
    bonus = d.bonusMainsNues;
  } else {
    des = d.des(arme);
    if ((a.degatsArme ?? '').isNotEmpty && arme.degatsActuels.isNotEmpty) {
      des = des.replaceFirst(arme.degatsActuels, a.degatsArme!);
    }
    bonus = d.bonusAvec(arme);
  }
  // Déferlement de coups : sans le modificateur de FOR.
  if (a.sansCarac == true) bonus -= d.bonus;
  final enPlus = a.degatsEnPlus ?? '';
  // « FOR » : le modificateur de FOR une fois de plus (Uppercut : FOR × 2) ;
  // « INT » : le modificateur d'INT (Justice divine) ; « 1d6 + PER » : un dé
  // et un modificateur (Points vitaux).
  var fixe = 0;
  for (final morceau in enPlus.split('+')) {
    final m = morceau.trim();
    if (m.isEmpty) continue;
    final carac = Carac.depuisCode(m);
    if (carac != null) {
      fixe += fiche.mod(carac);
    } else if (lireDes(m) != null) {
      des = '$des + $m';
    } else {
      fixe += int.tryParse(m) ?? 0;
    }
  }
  // Moulinet : −1 DM par cible déjà frappée avant celle-ci.
  final malus = cible > 1 ? (a.repetable ?? 0) * (cible - 1) : 0;
  return (
    des: des,
    bonus: bonus,
    fixes: [
      if (fixe != 0) (nom: j.libelle, valeur: fixe),
      if (malus != 0) (nom: 'Cible $cible', valeur: malus),
    ],
  );
}

/// « de l'épée sanguine », « de morsure de loup » (élision devant une
/// voyelle ou un h).
String deNom(String nom) =>
    RegExp(r'^[aeiouyéèêàâîôûh]', caseSensitive: false).hasMatch(nom)
        ? "de l'$nom"
        : 'de $nom';
