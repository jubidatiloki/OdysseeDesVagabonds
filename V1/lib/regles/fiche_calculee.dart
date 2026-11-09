import 'dart:math' as math;

import '../models/carac.dart';
import '../models/classe.dart';
import '../models/effet.dart';
import '../models/equipement.dart';
import '../models/langues.dart';
import '../models/objet.dart';
import '../models/personnage.dart';
import '../models/race.dart';
import '../models/voie.dart';
import 'des.dart';
import 'ecuyers.dart';
import 'inventaire.dart';
import 'maitrises.dart';
import 'progression.dart';
import 'regles_particulieres.dart';

/// Toutes les règles de calcul sont regroupées ici pour être faciles à
/// ajuster quand les règles du jeu évoluent.
/// Référence : AVANCEMENT.md, section 7 (règles tranchées et formules).
///
/// Principe : quand une règle cite une stat (« + CON », « DEX/2 »…), il
/// s'agit de son MODIFICATEUR, sauf mention contraire.

/// Dés possibles, du plus petit au plus grand. Minimum : d4.
const List<int> kDesDisponibles = [4, 6, 8, 10, 12];

/// Applique le modificateur de classe au dé de la race (±1 cran, min d4).
/// Exemple des règles : draconien (DV 8 / DM 4) + magicien (DV −, DM +)
/// → DV 6 / DM 6.
int ajusterDe(int deRace, ModifDe modif) {
  var i = kDesDisponibles.indexOf(deRace);
  if (i < 0) return deRace;
  switch (modif) {
    case ModifDe.plus:
      i++;
    case ModifDe.moins:
      i--;
    case ModifDe.egal:
      break;
  }
  if (i < 0) i = 0;
  if (i >= kDesDisponibles.length) i = kDesDisponibles.length - 1;
  return kDesDisponibles[i];
}

/// Modificateur d'une valeur de stat : 2 points = 1 de bonus/malus en
/// partant de 10, arrondi à l'inférieur (7 → −2, 9 → −1, 10/11 → 0, 12 → +1).
int modificateur(int valeur) => ((valeur - 10) / 2).floor();

/// Moitié arrondie au supérieur (règle « X/2, arrondi au supérieur »).
int demiArrondiSup(int valeur) => (valeur / 2).ceil();

/// Affiche un modificateur avec son signe : +2, +0, −1.
String formaterModificateur(int m) => m < 0 ? '−${-m}' : '+$m';

/// Formule de jet : « 1d20 +3 », « 1d6 −1 », « 1d20 » (bonus nul).
String formaterJet(String de, int bonus) =>
    bonus == 0 ? de : '$de ${formaterModificateur(bonus)}';

// ---------------------------------------------------------------------------
// Création : répartition des points de caractéristiques
// ---------------------------------------------------------------------------

/// Règles de répartition à la création (AVANCEMENT.md §7, règles 1 et 13) :
/// toutes les stats à 10, 12 points à répartir, 16 max par stat avant
/// la race, impossible de descendre sous 10, CHAN non modifiable.
class RepartitionCreation {
  static const int pointsTotal = 12;
  static const int valeurDepart = 10;
  static const int valeurMax = 16;

  /// Caractéristiques sur lesquelles on peut répartir des points.
  static bool estModifiable(Carac c) => c != Carac.chan;

  static Map<Carac, int> valeursDepart() =>
      {for (final c in Carac.values) c: valeurDepart};

  static int pointsDepenses(Map<Carac, int> base) {
    var total = 0;
    for (final c in Carac.values) {
      if (!estModifiable(c)) continue;
      final v = base[c] ?? valeurDepart;
      if (v > valeurDepart) total += v - valeurDepart;
    }
    return total;
  }

  static int pointsRestants(Map<Carac, int> base) =>
      pointsTotal - pointsDepenses(base);

  static bool peutAugmenter(Map<Carac, int> base, Carac c) =>
      estModifiable(c) &&
      (base[c] ?? valeurDepart) < valeurMax &&
      pointsRestants(base) > 0;

  static bool peutDiminuer(Map<Carac, int> base, Carac c) =>
      estModifiable(c) && (base[c] ?? valeurDepart) > valeurDepart;

  /// Vrai si la répartition respecte toutes les règles et que tous les
  /// points sont dépensés.
  static bool estComplete(Map<Carac, int> base) {
    for (final c in Carac.values) {
      final v = base[c] ?? valeurDepart;
      if (!estModifiable(c) && v != valeurDepart) return false;
      if (v < valeurDepart || v > valeurMax) return false;
    }
    return pointsRestants(base) == 0;
  }
}

// ---------------------------------------------------------------------------
// Fiche calculée
// ---------------------------------------------------------------------------

/// Un effet détaillé actif sur un personnage, avec sa provenance.
typedef SourceEffet = ({String nom, String origine, Effet effet});

/// Objet qu'une compétence doit donner : clé (jamais redonné), modèle JSON,
/// compétence d'origine, race (`true`) ou classe.
typedef ObjetARecevoir = ({
  String cle,
  Map<String, dynamic> objet,
  String competence,
  bool raciale,
});

/// Jet d'une compétence ou d'un passif, prêt à lancer : libellé (choix
/// remplacés), dés, bonus (modificateur), recharge (« 1d4 » tours) et nom
/// de la compétence d'origine.
class JetDisponible {
  const JetDisponible({
    required this.libelle,
    required this.des,
    required this.origine,
    this.bonus = 0,
    this.carac,
    this.recharge = '',
    this.difficulte,
    this.paliers = const [],
    this.avantage = false,
    this.applique = '',
    this.suite,
    this.amelioration = '',
    this.requiert = '',
    this.detruit = '',
    this.attaque,
    this.finEtat = '',
    this.libelleCaracs = '',
    this.instrument = false,
    this.gain,
    this.attaqueMagique = false,
    this.recuperePm = false,
    this.coutPm = 0,
  });

  /// PM dépensés à chaque utilisation (Justice divine : 5 PM par attaque).
  final int coutPm;

  /// Test de prestation musicale : instrument maîtrisé requis.
  final bool instrument;

  /// Argent gagné si le jet réussit (Musicien en herbe).
  final GainJet? gain;

  /// Jet de réussite d'un sort (attaque magique) : critique / échec
  /// élargis par la Rune de précision.
  final bool attaqueMagique;

  /// Le total est ajouté aux PM (Méditation du moine).
  final bool recuperePm;

  final String libelle;

  /// Attaque de compétence ; « RANG » déjà calculé dans `degatsEnPlus`
  /// (« 2×RANG » → « 6 »).
  final AttaqueJet? attaque;

  /// État annulé si le jet réussit (« Sortir de la rage »).
  final String finEtat;

  /// Caractéristiques additionnées dans [bonus] (« FOR + CON ») ; vide :
  /// celle de [carac].
  final String libelleCaracs;

  /// Dés à lancer, « RANG » déjà remplacé (« 3d6 »).
  final String des;
  final String origine;

  /// Compétence qui a modifié ce jet (« Harmonie avec la nature » : avantage).
  final String amelioration;

  /// Objet nécessaire (porte-bonheur) et objet détruit après le jet.
  final String requiert;
  final String detruit;
  final int bonus;

  /// Caractéristique du jet (bonus de situation liés à cette stat).
  final Carac? carac;
  final String recharge;
  final int? difficulte;
  final List<PalierJet> paliers;
  final bool avantage;

  /// `-pv`, `+pv`, `-pm`, `+pm` : appliqué au personnage.
  final String applique;
  final JetDisponible? suite;
}

class FicheCalculee {
  const FicheCalculee({
    required this.personnage,
    required this.race,
    required this.classe,
  });

  final Personnage personnage;
  final Race race;
  final Classe classe;

  /// Voies de toutes les classes (avec le nom de leur classe), remplies au
  /// chargement des données : « Polyvalence » y prend ses rangs.
  static List<({Voie voie, String classe})> voiesDesClasses = const [];

  /// Sorts de rang 0 (id de l'aptitude → sort), remplis au chargement des
  /// données (`sorts_rang0.json`) : achetés comme des aptitudes (1 point).
  static Map<String, Competence> sortsRang0 = const {};

  /// Savoirs du jeu (id de l'aptitude → nom), remplis au chargement des
  /// données : liste « Quelle connaissance ? » (Éducation du chevalier).
  static Map<String, String> savoirs = const {};

  /// Groupes des armes du catalogue (nom sans accents → groupe), remplis au
  /// chargement : retrouvent le groupe d'une arme d'une ancienne fiche.
  static Map<String, String> groupesArmes = const {};

  /// Noms des armes du catalogue par groupe de maîtrise (fenêtres de survol).
  static Map<String, List<String>> armesParGroupe = const {};

  /// Armures de corps du catalogue par niveau (0 tissu, 1 cuir, 2 cotte de
  /// mailles, 3 plaques) : fenêtres de détail des armures permises.
  static Map<int, List<String>> armuresParNiveau = const {};

  /// Groupe des sorts de rang 0 sur la fiche.
  static const Voie voieSortsRang0 =
      Voie(id: 'sorts-rang-0', nom: 'Sorts de rang 0');

  /// Voies des autres classes où « Polyvalence » peut prendre des rangs.
  List<({Voie voie, String classe})> get voiesEmpruntables => [
        for (final v in voiesDesClasses)
          if (!classe.voies.any((x) => x.id == v.voie.id)) v,
      ];

  /// Voie prise par « Polyvalence » (pas une voie de la classe).
  bool estEmprunt(Voie v) =>
      personnage.emprunts.containsKey(v.id) &&
      !classe.voies.any((x) => x.id == v.id);

  /// Rangs d'autres classes donnés par les compétences acquises.
  int get empruntsAutorises => [
        for (final c in competencesAcquises) c.competence.emprunts,
      ].fold(0, (a, b) => a + b);

  /// Rangs d'autres classes encore à choisir.
  int get empruntsAFaire {
    final faits = personnage.emprunts.values.fold(0, (a, b) => a + b);
    return (empruntsAutorises - faits).clamp(0, 99);
  }

  OrigineRace? get origine => race.origine(personnage.origineId);
  OptionPassif? get optionPassif =>
      race.optionPassif(personnage.optionPassifId);

  /// Dés sans les règles particulières (race ± classe).
  int get deVieDeBase => ajusterDe(race.deVie, classe.modifDeVie);
  int get deManaDeBase => ajusterDe(race.deMana, classe.modifDeMana);

  /// Dé de vie final (Vitalité elfique : race portée à d6).
  int get deVie => ajusterDe(
        ReglesParticulieres.deVieRace(personnage, race),
        classe.modifDeVie,
      );

  /// Dé d'endurance (race ± classe) : classes physiques et hybrides ;
  /// 0 pour les lanceurs de sorts (pas de PE).
  int get deEndurance => classe.aDeLEndurance
      ? ajusterDe(race.deEndurance, classe.modifDeEndurance)
      : 0;

  /// Dé de mana final (Mental d'acier : +1 cran).
  int get deMana {
    var de = deManaDeBase;
    for (var i = 0; i < ReglesParticulieres.cransDeManaBonus(personnage); i++) {
      de = ajusterDe(de, ModifDe.plus);
    }
    return de;
  }

  /// Somme des modificateurs de race et d'origine pour une caractéristique.
  int modificateurRacial(Carac c) =>
      (race.modificateurs[c] ?? 0) + (origine?.modificateurs[c] ?? 0);

  /// Effets détaillés (`effets` des données) des passifs de race et
  /// d'origine et des compétences acquises, avec leur provenance.
  List<SourceEffet> get effetsActifs {
    final res = <SourceEffet>[];
    void ajouter(String nom, String origine, List<Effet> effets) {
      for (final e in effets) {
        // « 1dDM » : dé de mana du personnage (Frappe de ki).
        final x =
            e.valeur.contains('DM') ? e.avecValeur(avecDeMana(e.valeur)) : e;
        res.add((nom: nom, origine: origine, effet: x));
      }
    }

    final passif = race.passif;
    if (passif != null) {
      ajouter(passif.nom, '${race.nom} · passif racial', passif.effets);
    }
    final op = optionPassif;
    if (op != null) {
      ajouter(op.nom, '${race.nom} · passif racial', op.effets);
    }
    final o = origine;
    if (o != null && o.passif != null) {
      ajouter(o.passif!.nom, '${race.nom} · ${o.nom}', o.passif!.effets);
    }
    // Objets équipés (porte-bonheur : +2 CHAN).
    for (final o in personnage.inventaire) {
      if (o.equipe && o.effets.isNotEmpty) {
        ajouter(o.nom, 'objet équipé', o.effets);
      }
    }
    for (final c in competencesAcquises) {
      // « RANG » dans une valeur : rang atteint dans la voie (CA + RANG).
      final rang = _rangAtteint(c);
      // Effets débloqués à un rang de la voie (traits de l'arme familiale) ;
      // `{precision:cle}` : précision d'un autre choix (l'arme familiale).
      ajouter(c.competence.nom, _origine(c), [
        for (final e in c.competence.effets)
          if (e.actifAuRang(rang))
            e.avecRang(rang).avecPrecisions(personnage.precisionsChoix),
      ]);
    }
    // Effets d'un état selon le rang de la voie (Bénédiction : +2 avec Lien
    // vital, rang 3).
    for (final (etat, comp, rang) in _etatsActifs) {
      ajouter(etat.nom, '$comp (actif)', [
        for (final e in etat.effets)
          if (e.actifAuRang(rang)) e.avecRang(rang),
      ]);
    }
    return res;
  }

  /// États actifs (apparence monstrueuse, rage, forme animale…) avec la
  /// compétence qui les donne et le rang atteint dans sa voie. Un état du
  /// même nom obtenu plus tard (rage niveau 2) remplace le précédent. Les
  /// effets reçus d'un autre personnage (Agrandissement) comptent aussi.
  List<(EtatCompetence, String, int)> get _etatsActifs {
    final etats = <String, (EtatCompetence, String, int)>{};
    for (final e in etatsRecus) {
      if (personnage.etats.contains(e.etat.nom)) {
        etats[e.etat.nom] = (e.etat, e.competence.nom, e.competence.rang);
      }
    }
    for (final c in competencesAcquises) {
      for (final etat in c.competence.etats) {
        if (personnage.etats.contains(etat.nom)) {
          etats[etat.nom] = (etat, c.competence.nom, _rangAtteint(c));
        }
      }
    }
    return etats.values.toList();
  }

  /// États qu'un autre personnage peut donner (Agrandissement,
  /// Transformation majeure sur une cible consentante) : activables sur
  /// la fiche, section « Effets reçus » ; sauf ceux que le personnage peut
  /// activer lui-même.
  List<({Competence competence, EtatCompetence etat})> get etatsRecus {
    final propres = {
      for (final c in competencesAcquises)
        for (final e in c.competence.etats) e.nom,
    };
    final res = <String, ({Competence competence, EtatCompetence etat})>{};
    for (final v in voiesDesClasses) {
      for (final c in v.voie.competences) {
        for (final e in c.etats) {
          if (e.recevable && !propres.contains(e.nom)) {
            res[e.nom] ??= (competence: c, etat: e);
          }
        }
      }
    }
    return res.values.toList();
  }

  /// « Draconien · voie raciale, rang 2 », « Barbare · Voie de la brute,
  /// rang 1 ».
  String _origine(({Voie voie, Competence competence, bool raciale}) c) => c
          .raciale
      ? '${race.nom} · voie raciale, rang ${c.competence.rang}'
      : c.voie.id == voieSortsRang0.id
          ? 'Sort de rang 0 (1 point)'
          : empruntDe(c.voie) != null
              ? '${nomEmprunt(c.voie)} · ${_classeDe(c.voie)} · '
                  '${c.voie.nom}, rang ${c.competence.rang}'
              : estEmprunt(c.voie)
                  ? 'Polyvalence · ${_classeDe(c.voie)} · ${c.voie.nom}, '
                      'rang ${c.competence.rang}'
                  : '${classe.nom} · ${c.voie.nom}, rang ${c.competence.rang}';

  /// Nom de la compétence qui a donné l'emprunt (« Diversité culturelle »).
  String nomEmprunt(Voie v) {
    final e = empruntDe(v);
    for (final w in [
      if (race.voieRaciale != null) race.voieRaciale!,
      ...classe.voies,
    ]) {
      for (final c in w.competences) {
        if (c.emprunt?.cle == e?.cle) return c.nom;
      }
    }
    return 'Emprunt';
  }

  String _classeDe(Voie v) {
    for (final x in voiesDesClasses) {
      if (x.voie.id == v.id) return x.classe;
    }
    return '';
  }

  /// Tous les choix possibles de la race et de la classe (clé → choix),
  /// pour afficher le nom d'une option choisie.
  Map<String, ChoixCompetence> get choixConnus => {
        for (final op in race.optionsPassif)
          if (op.choix != null) op.choix!.cle: op.choix!,
        for (final v in [
          if (race.voieRaciale != null) race.voieRaciale!,
          ...classe.voies,
        ])
          for (final c in v.competences)
            // Compétence, autres compétences du rang et leurs variantes.
            for (final x in [c, ...c.aussi])
              for (final ch in [
                x.choix,
                for (final va in [
                  ...x.selonPassif.values,
                  ...x.selonOrigine.values,
                ])
                  va.choix,
              ])
                if (ch != null) ch.cle: ch,
        for (final e in _empruntsRangPossibles) e.cle: choixEmprunt(e),
      };

  /// La compétence telle que l'a ce personnage (variante selon son passif,
  /// option choisie, `{cle}` remplacés).
  Competence resoudre(Competence c) => c.pour(
        optionPassifId: personnage.optionPassifId,
        profil: classe.profil.code,
        origineId: personnage.origineId,
        choixFaits: personnage.choix,
        autresChoix: choixConnus,
        precisions: personnage.precisionsChoix,
      );

  /// Compétences acquises (voie raciale + voies de classe), résolues pour
  /// ce personnage.
  List<({Voie voie, Competence competence, bool raciale})>
      get competencesAcquises => [
            for (final c in Progression.competencesAcquises(
              niveau: personnage.niveau,
              race: race,
              classe: classe,
              rangsVoies: personnage.rangsVoies,
            )) ...[
              (
                voie: c.voie,
                competence: resoudre(c.competence),
                raciale: c.raciale,
              ),
              // Autres compétences du même rang (deux compétences distinctes).
              for (final autre in c.competence.aussi)
                (voie: c.voie, competence: resoudre(autre), raciale: c.raciale),
            ],
            // Sorts de rang 0 achetés (aptitudes à 1 point).
            for (final a in personnage.aptitudes)
              if (sortsRang0[a.id] case final s?)
                (voie: voieSortsRang0, competence: resoudre(s), raciale: false),
            // Rangs pris dans d'autres classes (« Polyvalence »).
            for (final e in personnage.emprunts.entries)
              for (final v in voiesDesClasses)
                if (v.voie.id == e.key && !classe.voies.contains(v.voie))
                  for (final c in v.voie.competences)
                    if (c.rang <= e.value)
                      (voie: v.voie, competence: resoudre(c), raciale: false),
            // Compétence d'une autre classe (Diversité culturelle).
            for (final e in _empruntsRang)
              if (_voieEmpruntee(e) case final v?)
                if (v.competence(e.rang) case final c?)
                  (voie: v, competence: resoudre(c), raciale: false),
          ];

  /// Emprunts d'un rang (Diversité culturelle) des voies du personnage
  /// (sa race et sa classe), qu'il les ait déjà ou non.
  List<EmpruntRang> get _empruntsRangPossibles => [
        for (final v in [
          if (race.voieRaciale != null) race.voieRaciale!,
          ...classe.voies,
        ])
          for (final c in v.competences)
            if (c.emprunt case final e?) e,
      ];

  /// Emprunts d'un rang acquis : la compétence qui le donne est obtenue.
  List<EmpruntRang> get _empruntsRang => [
        for (final c in Progression.competencesAcquises(
          niveau: personnage.niveau,
          race: race,
          classe: classe,
          rangsVoies: personnage.rangsVoies,
        ))
          if (c.competence.emprunt case final e?) e,
      ];

  /// Voie choisie pour l'emprunt [e] (`null` : pas encore choisie).
  Voie? _voieEmpruntee(EmpruntRang e) {
    final id = personnage.choix[e.cle];
    for (final v in voiesDesClasses) {
      if (v.voie.id == id) return v.voie;
    }
    return null;
  }

  /// Compétence qui a fait choisir la voie [v] (« Diversité culturelle »),
  /// `null` si elle n'a pas été prise ainsi.
  EmpruntRang? empruntDe(Voie v) {
    for (final e in _empruntsRangPossibles) {
      if (personnage.choix[e.cle] == v.id &&
          !classe.voies.any((x) => x.id == v.id)) {
        return e;
      }
    }
    return null;
  }

  /// Choix de la compétence empruntée : le rang demandé de chaque voie des
  /// autres classes, sauf le type exclu (renforcement).
  ChoixCompetence choixEmprunt(EmpruntRang e) => ChoixCompetence(
        cle: e.cle,
        titre: "Compétence de rang ${e.rang} d'une autre classe",
        options: [
          for (final v in voiesEmpruntables)
            if (v.voie.competence(e.rang) case final c?)
              if (e.exclure.isEmpty ||
                  !c.type.toLowerCase().contains(e.exclure.toLowerCase()))
                OptionChoix(
                  id: v.voie.id,
                  nom: '${v.classe} · ${v.voie.nomCourt} — ${c.nom}',
                  effet: c.effet,
                  effets: const [],
                ),
        ],
      );

  /// Choix pas encore faits (passif choisi à la création, compétences
  /// acquises) : à faire en montant de niveau ou depuis la fiche.
  List<({String nom, String origine, ChoixCompetence choix})>
      get choixEnAttente {
    final res = <({String nom, String origine, ChoixCompetence choix})>[];
    final vus = <String>{};
    void ajouter(String nom, String origine, ChoixCompetence? c) {
      if (c == null ||
          !choixAFaire(c, personnage.choix, personnage.precisionsChoix)) {
        return;
      }
      if (vus.add(c.cle)) res.add((nom: nom, origine: origine, choix: c));
    }

    final op = optionPassif;
    if (op != null) ajouter(op.nom, '${race.nom} · passif racial', op.choix);
    for (final c in competencesAcquises) {
      ajouter(c.competence.nom, _origine(c), c.competence.choix);
      // Diversité culturelle : la compétence à prendre.
      if (c.competence.emprunt case final e?) {
        ajouter(c.competence.nom, _origine(c), choixEmprunt(e));
      }
    }
    return res;
  }

  /// Le choix [c] reste-t-il à faire : pas d'option choisie, ou option qui
  /// demande une précision (« Quelle arme ? ») encore vide.
  static bool choixAFaire(
    ChoixCompetence c,
    Map<String, String> choix,
    Map<String, String> precisions,
  ) {
    // Choix multiple : il faut autant d'options différentes que demandé.
    if (c.nombre > 1) {
      return {for (final o in c.choisies(choix[c.cle])) o.id}.length < c.nombre;
    }
    final o = c.option(choix[c.cle]);
    if (o == null) return true;
    return o.question.isNotEmpty && (precisions[c.cle] ?? '').trim().isEmpty;
  }

  /// Options permises du choix [c] (`null` : toutes), d'après son `filtre`
  /// et les choix faits [choix] (par défaut ceux du personnage) :
  /// « Perfectionnement » → la ou les caractéristiques les plus faibles (hors
  /// CHAN, avant les +2 de la compétence), puis une autre.
  Set<String>? optionsPermises(
    ChoixCompetence c, {
    Map<String, String>? choix,
  }) {
    final faits = choix ?? personnage.choix;
    final f = c.filtre;
    if (f == 'plus-faible') {
      // Sans les choix filtrés : valeurs avant le bonus de la compétence.
      final filtres = {
        for (final x in choixConnus.values)
          if (x.filtre.isNotEmpty) x.cle,
      };
      final sans = Personnage.depuisJson(personnage.versJson())
        ..choix.removeWhere((k, _) => filtres.contains(k));
      final fiche = FicheCalculee(personnage: sans, race: race, classe: classe);
      final valeurs = {
        for (final o in c.options)
          if (Carac.depuisCode(o.id) case final carac?)
            o.id: fiche.carac(carac),
      };
      if (valeurs.isEmpty) return null;
      final min = valeurs.values.reduce((a, b) => a < b ? a : b);
      return {
        for (final e in valeurs.entries)
          if (e.value == min) e.key,
      };
    }
    if (f.startsWith('autre:')) {
      final exclue = faits[f.substring(6)];
      return {
        for (final o in c.options)
          if (o.id != exclue) o.id,
      };
    }
    return null;
  }

  /// Objets que les compétences acquises doivent donner et que le personnage
  /// n'a pas encore reçus (clé « voie/rang/nom », modèle JSON, compétence).
  /// Aussi ceux de l'option choisie (l'arme ou l'instrument du gnome), avec
  /// `{precision}` remplacé — seulement une fois le choix complet.
  List<ObjetARecevoir> get objetsARecevoir {
    final res = <ObjetARecevoir>[];
    void ajouter(String cle, Map<String, dynamic> o, String comp, bool rac) {
      if (personnage.objetsRecus.contains(cle)) return;
      res.add((cle: cle, objet: o, competence: comp, raciale: rac));
    }

    for (final c in competencesAcquises) {
      final base = '${c.voie.id}/${c.competence.rang}';
      for (final o in c.competence.objets) {
        ajouter('$base/${o['nom']}', o, c.competence.nom, c.raciale);
      }
      final choix = c.competence.choix;
      if (choix == null ||
          choixAFaire(choix, personnage.choix, personnage.precisionsChoix)) {
        continue;
      }
      // Choix multiple (modules du golem, Vagabond) : chaque option.
      final options = choix.nombre > 1
          ? choix.choisies(personnage.choix[choix.cle])
          : [
              if (choix.option(personnage.choix[choix.cle]) case final o?) o,
            ];
      final precision = personnage.precisionsChoix[choix.cle] ?? '';
      // Écuyer : « Nom — description » séparés.
      final ecuyer = lireEcuyer(precision);
      for (final option in options) {
        for (final o in option.objets) {
          final objet = {
            for (final e in o.entries)
              e.key: e.value is String
                  ? (e.value as String)
                      .replaceAll('{precision.nom}', ecuyer.nom)
                      .replaceAll('{precision.description}', ecuyer.description)
                      .replaceAll('{precision}', precision)
                  : e.value,
          };
          ajouter(
            '$base/${choix.cle}/${option.id}/${objet['nom']}',
            objet,
            c.competence.nom,
            c.raciale,
          );
        }
      }
    }
    return res;
  }

  /// Instruments maîtrisés (aptitudes « Maîtrise d'un instrument » et effets
  /// `maitrise` / `instrument`), avec le bonus pour en jouer (+2 pour
  /// l'instrument du gnome déjà maîtrisé) et l'origine de ce bonus.
  List<({String nom, int bonus, String origine})> get instrumentsMaitrises {
    final res = <String, ({String nom, int bonus, String origine})>{};
    String norm(String s) => s.trim().toLowerCase();
    void ajouter(String nom, {int bonus = 0, String origine = ''}) {
      if (nom.trim().isEmpty) return;
      final avant = res[norm(nom)];
      res[norm(nom)] = (
        nom: avant?.nom ?? nom.trim(),
        bonus: (avant?.bonus ?? 0) + bonus,
        origine: [avant?.origine ?? '', origine]
            .where((o) => o.isNotEmpty)
            .join(', '),
      );
    }

    for (final a in personnage.aptitudes) {
      if (a.id == 'instrument') ajouter(a.precision ?? '');
    }
    for (final s in effetsActifs) {
      final e = s.effet;
      if (e.typeNormalise == 'maitrise' &&
          e.categorieNormalisee == 'instrument') {
        ajouter(e.valeur);
      }
      if (e.typeNormalise == 'instrument' && e.condition.isNotEmpty) {
        ajouter(e.condition, bonus: e.valeurEntiere ?? 0, origine: s.nom);
      }
    }
    // Bonus pour tous les instruments (Début artistique : +2 par rang).
    final generaux = bonusInstrumentsGeneraux;
    return [
      for (final i in res.values)
        (
          nom: i.nom,
          bonus: i.bonus + generaux.fold(0, (n, b) => n + b.valeur),
          origine: [
            i.origine,
            for (final b in generaux) b.nom,
          ].where((o) => o.isNotEmpty).join(', '),
        ),
    ];
  }

  /// Bonus à tous les tests de prestation musicale (effet `instrument` sans
  /// condition : Début artistique).
  List<BonusSituation> get bonusInstrumentsGeneraux => [
        for (final s in effetsActifs)
          if (s.effet.typeNormalise == 'instrument' &&
              s.effet.condition.isEmpty &&
              s.effet.valeurEntiere != null)
            (nom: s.nom, valeur: s.effet.valeurEntiere!),
      ];

  /// Compétence qui donne l'avantage aux tests de prestation musicale
  /// (Musicien renommé), `null` sinon.
  String? get avantageInstrument {
    for (final s in effetsActifs) {
      if (s.effet.typeNormalise == 'instrument' &&
          s.effet.valeur.toLowerCase() == 'avantage') {
        return s.nom;
      }
    }
    return null;
  }

  /// Titres du personnage (« Musicien de renom »), affichés sous son nom.
  /// « Masculin|Féminin » (« Comte|Comtesse ») : la forme féminine pour un
  /// personnage de sexe féminin, la masculine sinon.
  List<String> get titres => [
        for (final s in effetsActifs)
          if (s.effet.typeNormalise == 'titre' && s.effet.valeur.isNotEmpty)
            () {
              final formes = s.effet.valeur.split('|');
              return (personnage.sexe == Sexe.femme && formes.length > 1
                      ? formes[1]
                      : formes[0])
                  .trim();
            }(),
      ];

  /// Capacités à usage limité (effets `usage` : « Faire jouer son titre »,
  /// RANG fois par aventure) avec le nombre restant
  /// ([Personnage.utilisations]).
  List<
      ({
        String cle,
        String nom,
        int max,
        int restants,
        String periode,
        String detail,
        String origine,
      })> get usages => [
        for (final s in effetsActifs)
          if (s.effet.typeNormalise == 'usage' &&
              (s.effet.valeurEntiere ?? 0) > 0)
            () {
              final nom = s.effet.nom.isEmpty ? s.nom : s.effet.nom;
              final max = s.effet.valeurEntiere!;
              final faits = personnage.utilisations[nom] ?? 0;
              return (
                cle: nom,
                nom: nom,
                max: max,
                restants: (max - faits).clamp(0, max),
                periode: s.effet.condition,
                detail: s.effet.texte,
                origine: s.nom,
              );
            }(),
      ];

  /// Coût d'activation d'un sort selon son rang (règles, « Coût en mana »).
  static const List<int> coutsSorts = [1, 3, 6, 10, 15];

  /// Sorts acquis (type contenant « sort ») avec leur coût en PM : rang de
  /// « coût rang N » s'il est indiqué, sinon rang de la compétence.
  /// Sort modulable (Boule de feu) : une entrée par puissance, de 1 au rang
  /// atteint dans la voie (« Boule de feu (2d6) », coût d'un rang 2).
  /// Réduction de coût des compétences (effet `cout-mana`, condition = id
  /// de la voie : Artéfact magique, −1 PM sur les sorts des arcanes, min 1).
  List<({Competence competence, int rangSort, int cout})> get sorts {
    final res = <({Competence competence, int rangSort, int cout})>[];
    for (final c in competencesAcquises) {
      final s = coutSort(c.competence);
      if (s == null) continue;
      final reduction = [
        for (final e in effetsActifs)
          if (e.effet.typeNormalise == 'cout-mana' &&
              e.effet.condition == c.voie.id)
            e.effet.valeurEntiere ?? 0,
      ].fold(0, (a, b) => a + b);
      int cout(int base) => base == 0 ? 0 : math.max(1, base + reduction);
      final k = c.competence;
      if (!k.modulable) {
        res.add((competence: k, rangSort: s.rang, cout: cout(s.cout)));
        continue;
      }
      final max = _rangAtteint(c).clamp(1, coutsSorts.length);
      for (var n = 1; n <= max; n++) {
        final degats =
            k.degats.replaceFirst(RegExp(r'^\s*\d*\s*[dD]'), '${n}d');
        final de = RegExp(r'^\s*\d+d\d+').firstMatch(degats)?.group(0)?.trim();
        res.add((
          competence: k.copie(
            nom: '${k.nom} (${de ?? 'rang $n'})',
            degats: degats,
            mana: '${cout(coutsSorts[n - 1])} PM',
          ),
          rangSort: n,
          cout: cout(coutsSorts[n - 1]),
        ));
      }
    }
    return res;
  }

  /// Jet de réussite du sort (1d20 + mod de la stat + bonus, difficulté) ;
  /// `null` si le sort réussit d'office.
  JetDisponible? jetReussite(Competence sort) {
    final r = sort.reussite;
    if (r == null) return null;
    final carac = Carac.depuisCode(r.carac);
    return JetDisponible(
      libelle: '${sort.nom} · ${r.libelle.isEmpty ? 'réussite' : r.libelle}',
      des: '1d20',
      origine: sort.nom,
      bonus: (carac == null ? 0 : mod(carac)) + r.bonus,
      carac: carac,
      difficulte: r.difficulte,
      attaqueMagique: true,
    );
  }

  /// Premier groupe de dés d'un texte (« 1d8 chaos (×2…) » → « 1d8 »).
  static String? desDans(String texte) {
    final m = RegExp(r'(\d*)\s*[dD]\s*(\d+)').firstMatch(texte);
    if (m == null) return null;
    return '${m.group(1)!.isEmpty ? '1' : m.group(1)}d${m.group(2)}';
  }

  /// Jets « dégâts / effet » d'un sort : dégâts (dé du sort + mod INT,
  /// règle des dégâts magiques), soin (dés seuls), puis ses propres jets.
  /// Un jet « Nom · dégâts » de la compétence elle-même (Éclat des arcanes :
  /// dés selon le rang) remplace celui tiré du texte des dégâts.
  List<JetDisponible> jetsEffetSort(Competence sort) => [
        if (desDans(avecDeMana(sort.degats)) case final d?)
          if (!jetsCompetences.any((j) =>
              j.origine == sort.nom && j.libelle == '${sort.nom} · dégâts'))
            JetDisponible(
              libelle: '${sort.nom} · dégâts',
              des: d,
              origine: sort.nom,
              // Sort de rang 0 : dés seuls, sans bonus de stat.
              bonus: sort.rang == 0 ? 0 : degatsMagie,
              carac: sort.rang == 0 ? null : Carac.intel,
            ),
        if (desDans(sort.soin) case final d?)
          JetDisponible(
            libelle: '${sort.nom} · soin',
            des: d,
            origine: sort.nom,
            // Soins : dés seuls, sauf « + INT » écrit (Fruit de la vie).
            bonus: _soinAvecInt(sort) ? degatsMagie : 0,
            carac: _soinAvecInt(sort) ? Carac.intel : null,
          ),
        for (final j in jetsCompetences)
          if (j.origine == sort.nom && j.attaque == null) j,
      ];

  static bool _soinAvecInt(Competence sort) =>
      sort.rang > 0 && RegExp(r'\+\s*INT\b').hasMatch(sort.soin);

  /// Rang et coût en PM d'une compétence si c'est un sort (`null` sinon) :
  /// rang de « coût rang N » s'il est indiqué, sinon rang de la compétence.
  static ({int rang, int cout})? coutSort(Competence c) {
    final type = c.type.toLowerCase();
    if (!RegExp(r'\bsort\b').hasMatch(type)) return null;
    // Sort de rang 0 : gratuit (règle 4.2).
    if (c.rang == 0) return (rang: 0, cout: 0);
    // Coût fixe (« coût 0 PM » : Justice divine, seules les attaques coûtent).
    final fixe = RegExp(r'coût (\d+) pm').firstMatch(type);
    if (fixe != null) {
      return (rang: c.rang.clamp(1, 5), cout: int.parse(fixe.group(1)!));
    }
    final m = RegExp(r'coût rang (\d)').firstMatch(type);
    final rang = (m == null ? c.rang : int.parse(m.group(1)!)).clamp(1, 5);
    return (rang: rang, cout: coutsSorts[rang - 1]);
  }

  /// Langues parlées : le commun (tout le monde), celle(s) de la race, les
  /// aptitudes « Nouvelle langue » et les maîtrises de langue des
  /// compétences (« Elfique » ; pas les textes « … au choix »).
  List<String> get langues {
    final res = <String, String>{};
    void ajouter(String l) {
      final t = l.trim();
      if (t.isEmpty || t.contains('au choix') || t.contains('{')) return;
      res.putIfAbsent(t.toLowerCase(), () => t);
    }

    ajouter(kCommun);
    race.langues.forEach(ajouter);
    for (final a in personnage.aptitudes) {
      if (a.id == 'langue') ajouter(a.precision ?? '');
    }
    for (final s in effetsActifs) {
      if (s.effet.typeNormalise == 'maitrise' &&
          s.effet.categorieNormalisee.contains('langue')) {
        ajouter(s.effet.valeur);
      }
    }
    return res.values.toList();
  }

  /// Armes maîtrisées connues : aptitudes « Maîtrise d'une arme » et effets
  /// `maitrise` de catégorie arme. (Les maîtrises de race / classe écrites
  /// en texte libre ne sont pas comptées.)
  List<String> get armesMaitrisees => [
        for (final a in personnage.aptitudes)
          if (a.id == 'arme' && (a.precision ?? '').trim().isNotEmpty)
            a.precision!.trim(),
        for (final s in effetsActifs)
          if (s.effet.typeNormalise == 'maitrise' &&
              s.effet.categorieNormalisee == 'arme' &&
              s.effet.valeur.trim().isNotEmpty)
            s.effet.valeur.trim(),
      ];

  /// Éléments proposés dans la liste déroulante d'un choix ([liste] :
  /// `armes` ou `instruments`) : catalogue, inventaire et maîtrises, chacun
  /// marqué « déjà maîtrisé ». Le choix [cle] lui-même est ignoré (sinon ce
  /// qu'il donne compterait comme déjà maîtrisé).
  List<({String nom, bool maitrise})> elementsChoix(
    String liste, {
    List<Equipement> catalogue = const [],
    String cle = '',
  }) {
    final sans = Personnage.depuisJson(personnage.versJson())
      ..choix.remove(cle)
      ..precisionsChoix.remove(cle);
    final f = FicheCalculee(personnage: sans, race: race, classe: classe);
    // Savoirs : tous ceux du jeu, ceux déjà achetés marqués.
    if (liste == 'savoirs') {
      final acquis = {for (final a in personnage.aptitudes) a.id};
      return [
        for (final e in savoirs.entries)
          (nom: e.value, maitrise: acquis.contains(e.key)),
      ];
    }
    // Écuyers : trois propositions tirées pour ce personnage.
    if (liste == 'ecuyers') {
      return [
        for (final e in propositionsEcuyer(personnage.id))
          (nom: e.texte, maitrise: false),
      ];
    }
    // Langues : la liste du monde, celles déjà parlées marquées.
    if (liste == 'langues') {
      final parlees = {for (final l in f.langues) l.toLowerCase()};
      return [
        for (final l in kLangues)
          (nom: l, maitrise: parlees.contains(l.toLowerCase())),
      ];
    }
    final armes = liste == 'armes';
    final maitrises = armes
        ? f.armesMaitrisees
        : [for (final i in f.instrumentsMaitrises) i.nom];
    String norm(String s) => s.trim().toLowerCase();
    bool maitrise(String nom) => maitrises.any(
          (m) => norm(nom).contains(norm(m)) || norm(m).contains(norm(nom)),
        );
    final noms = <String, String>{};
    void ajouter(String nom) {
      if (nom.trim().isNotEmpty) noms.putIfAbsent(norm(nom), () => nom.trim());
    }

    for (final e in catalogue) {
      final instrument = e.etiquettes.any((t) => norm(t) == 'instrument');
      if (armes ? e.categorie == CategorieEquipement.arme : instrument) {
        ajouter(e.nom);
      }
    }
    for (final o in personnage.inventaire) {
      if (o.categorie ==
          (armes ? CategorieObjet.arme : CategorieObjet.instrument)) {
        ajouter(o.nom);
      }
    }
    maitrises.forEach(ajouter);
    final res = [
      for (final nom in noms.values) (nom: nom, maitrise: maitrise(nom)),
    ];
    // Déjà maîtrisés d'abord, puis ordre alphabétique.
    res.sort((a, b) => a.maitrise != b.maitrise
        ? (a.maitrise ? -1 : 1)
        : a.nom.compareTo(b.nom));
    return res;
  }

  /// Bonus au toucher donnés par les compétences pour les armes équipées de
  /// cette portée (gnome : +1 avec l'arme déjà maîtrisée), avec leur origine.
  /// Un effet sans condition (`si` vide) vaut pour toutes les attaques, même
  /// sans arme (rage : −2 aux attaques).
  List<BonusSituation> bonusToucher({required bool distance}) => [
        for (final s in effetsActifs)
          if (s.effet.typeNormalise == 'toucher' && s.effet.si.isEmpty)
            (nom: s.nom, valeur: s.effet.valeurEntiere ?? 0)
          // Pugilat : +RANG au toucher à mains nues (aucune arme de CaC).
          else if (s.effet.typeNormalise == 'toucher' &&
              s.effet.si == 'mains-nues')
            if (!distance && aMainsNues)
              (nom: s.nom, valeur: s.effet.valeurEntiere ?? 0)
            else
              ...const <BonusSituation>[]
          else if (s.effet.typeNormalise == 'toucher' &&
              personnage.inventaire.any(
                (o) =>
                    o.equipe &&
                    o.categorie == CategorieObjet.arme &&
                    o.distance == distance &&
                    conditionRemplie(s.effet, arme: o),
              ))
            (nom: s.nom, valeur: s.effet.valeurEntiere ?? 0),
        ...malusArme(distance: distance),
      ];

  /// Plus petit résultat naturel du d20 qui donne une réussite critique au
  /// toucher (20 ; 19 avec l'arme familiale légendaire en main), et la
  /// compétence qui l'abaisse.
  ({int seuil, String origine}) seuilCritique({required bool distance}) {
    var res = (seuil: 20, origine: '');
    for (final s in effetsActifs) {
      if (s.effet.typeNormalise != 'critique') continue;
      final v = s.effet.valeurEntiere;
      if (v == null || v >= res.seuil || v < 2) continue;
      final ok = s.effet.si.isEmpty ||
          personnage.inventaire.any(
            (o) =>
                o.equipe &&
                o.categorie == CategorieObjet.arme &&
                o.distance == distance &&
                conditionRemplie(s.effet, arme: o),
          );
      if (ok) res = (seuil: v, origine: s.nom);
    }
    return res;
  }

  /// Seuils de toutes les attaques (toucher, attaques de compétence,
  /// attaques magiques), sans condition d'arme : critique dès [critique]
  /// (Rune de précision : 18), échec critique jusqu'à [echec] (2).
  ({int critique, int echec}) get seuilsAttaques {
    var critique = 20;
    var echec = 1;
    for (final s in effetsActifs) {
      final v = s.effet.valeurEntiere;
      if (v == null || s.effet.si.isNotEmpty) continue;
      if (s.effet.typeNormalise == 'critique' && v < critique && v >= 2) {
        critique = v;
      }
      if (s.effet.typeNormalise == 'echec-critique' && v > echec && v < 20) {
        echec = v;
      }
    }
    return (critique: critique, echec: echec);
  }

  /// Jets proposés par le passif choisi et les compétences acquises (page
  /// Lancer de dé). Un jet de même libellé obtenu plus tard remplace le
  /// précédent (souffle 1D6 → 2D6 au rang 5).
  List<JetDisponible> get jetsCompetences {
    // Libellé brut → (jet, compétence d'origine, rang atteint dans la voie).
    final parLibelle =
        <String, ({JetCompetence jet, String origine, int rang, String par})>{};
    void ajouter(List<JetCompetence> jets, String origine, int rang) {
      for (final j in jets) {
        final avant = parLibelle[j.libelle];
        // Sans dés : modifie le jet déjà obtenu (avantage au rang 5…).
        if (j.des.isEmpty) {
          if (avant != null) {
            parLibelle[j.libelle] = (
              jet: avant.jet.modifiePar(j),
              origine: avant.origine,
              rang: avant.rang,
              par: origine,
            );
          }
          continue;
        }
        // Remplacé par un rang plus haut (Éclat des arcanes 1d4 → 2d4) : le
        // jet reste rattaché à sa compétence d'origine (carte du sort).
        parLibelle[j.libelle] = avant == null
            ? (jet: j, origine: origine, rang: rang, par: '')
            : (jet: j, origine: avant.origine, rang: rang, par: origine);
      }
    }

    final op = optionPassif;
    if (op != null) ajouter(op.jets, op.nom, 0);
    for (final c in competencesAcquises) {
      ajouter(c.competence.jets, c.competence.nom, _rangAtteint(c));
    }
    // Jets d'un état actif (forme de loup : morsure).
    for (final (etat, comp, rang) in _etatsActifs) {
      ajouter(etat.jets, comp, rang);
    }
    final connus = choixConnus;
    JetDisponible convertir(
      JetCompetence j,
      String origine,
      int rang, [
      String par = '',
    ]) {
      // « FOR+CON » : modificateurs additionnés (durée de la rage).
      final caracs = [
        for (final c in j.carac.split('+'))
          if (Carac.depuisCode(c.trim()) case final x?) x,
      ];
      final carac = caracs.isEmpty ? null : caracs.first;
      final a = j.attaque;
      return JetDisponible(
        libelle: remplacerChoix(j.libelle, personnage.choix, connus),
        des: avecDeMana(j.des.replaceAll('RANG', '$rang')),
        origine: origine,
        // Prestation musicale : + bonus de tous les instruments.
        bonus: caracs.fold(0, (n, c) => n + mod(c)) +
            (j.instrument
                ? bonusInstrumentsGeneraux.fold(0, (n, b) => n + b.valeur)
                : 0),
        carac: carac,
        libelleCaracs: [
          if (caracs.length > 1 ||
              (j.instrument && bonusInstrumentsGeneraux.isNotEmpty))
            [
              for (final c in caracs) c.abrev,
              if (j.instrument)
                for (final b in bonusInstrumentsGeneraux) b.nom,
            ].join(' + '),
        ].join(),
        attaque: a?.modifiePar(AttaqueJet(
          degatsEnPlus: a.degatsEnPlus == null
              ? null
              : evaluerRang(a.degatsEnPlus!, rang),
        )),
        finEtat: j.finEtat,
        instrument: j.instrument,
        gain: j.gain,
        recuperePm: j.recuperePm,
        coutPm: j.coutPm,
        recharge: j.recharge,
        difficulte: j.difficulte,
        paliers: j.paliers,
        avantage: j.avantage || (j.instrument && avantageInstrument != null),
        applique: j.applique,
        suite: j.suite == null ? null : convertir(j.suite!, origine, rang),
        amelioration: par.isEmpty && j.instrument && avantageInstrument != null
            ? avantageInstrument!
            : par,
        requiert: j.requiert,
        detruit: j.detruit,
      );
    }

    return [
      for (final e in parLibelle.values)
        convertir(e.jet, e.origine, e.rang, e.par),
    ];
  }

  /// « 2×RANG » → « 6 » au rang 3 ; un dé (« 1d6 ») reste tel quel.
  static String evaluerRang(String texte, int rang) {
    final t = texte.replaceAll('RANG', '$rang');
    final m = RegExp(r'^\s*(\d+)\s*[×x*]\s*(\d+)\s*$').firstMatch(t);
    if (m == null) return t;
    return '${int.parse(m.group(1)!) * int.parse(m.group(2)!)}';
  }

  /// Arme de corps à corps équipée pour une attaque de compétence :
  /// l'arme principale d'abord ; à deux mains si l'attaque l'exige.
  /// `null` : aucune arme qui convient (bouton grisé).
  Objet? armeAttaque(AttaqueJet a) {
    final armes = [
      for (final o in personnage.inventaire)
        if (o.equipe &&
            o.categorie == CategorieObjet.arme &&
            // Attaque à distance (Pistoléro) : arme à distance ; sinon CaC.
            o.distance == (a.distance == true) &&
            (a.deuxMains != true || o.mains == 2) &&
            // Charge à la lance : arme nommée obligatoire.
            (a.arme == null ||
                o.nom.toLowerCase().contains(a.arme!.toLowerCase())))
          o,
    ]..sort((x, y) => (y.principale ? 1 : 0) - (x.principale ? 1 : 0));
    return armes.isEmpty ? null : armes.first;
  }

  /// Objets que les compétences acquises permettent de fabriquer (Assaut).
  List<({String competence, Map<String, dynamic> objet})> get fabrications => [
        for (final c in competencesAcquises)
          for (final o in c.competence.fabrication)
            (competence: c.competence.nom, objet: o),
      ];

  /// Armement barbare : peut équiper deux armes à deux mains.
  bool get deuxArmesDeuxMains => effetsActifs.any(
        (s) =>
            s.effet.typeNormalise == 'maitrise' &&
            s.effet.categorieNormalisee == 'armement',
      );

  /// Deux armes de corps à corps équipées avec l'Armement barbare :
  /// (principale, attaque au d20 ; secondaire, au d12). La principale est
  /// celle marquée « principale », sinon la première équipée. `null` : pas
  /// de double arme.
  /// Ambidextrie (guerrier) : la 2ᵉ arme attaque au d20 (au lieu du d12).
  bool get ambidextre => effetsActifs.any(
        (s) =>
            s.effet.typeNormalise == 'maitrise' &&
            s.effet.categorieNormalisee == 'ambidextrie',
      );

  ({Objet principale, Objet secondaire})? get armesDoubles {
    if (!deuxArmesDeuxMains && !ambidextre) return null;
    final armes = [
      for (final o in personnage.inventaire)
        if (o.equipe && o.categorie == CategorieObjet.arme && !o.distance) o,
    ];
    if (armes.length < 2) return null;
    final principale =
        armes.firstWhere((o) => o.principale, orElse: () => armes.first);
    final secondaire = armes.firstWhere((o) => !identical(o, principale));
    return (principale: principale, secondaire: secondaire);
  }

  /// Rang atteint dans la voie d'une compétence (« RANG » des données).
  int _rangAtteint(({Voie voie, Competence competence, bool raciale}) c) =>
      c.raciale
          ? Progression.rangRacial(personnage.niveau)
          : personnage.rangsVoies[c.voie.id] ??
              personnage.emprunts[c.voie.id] ??
              // Diversité culturelle : RANG = 2 (sans les rangs 1 et 2).
              empruntDe(c.voie)?.rangCalcul ??
              c.competence.rang;

  /// Compétences acquises qui peuvent activer un état (Visage impensable).
  /// Un seul bouton par état (le niveau le plus haut : rage niveau 2) ; pas
  /// ceux qu'une attaque active elle-même (Moulinet).
  List<({Competence competence, EtatCompetence etat})> get etatsPossibles {
    final parAttaque = {
      for (final j in jetsCompetences)
        if (j.attaque?.etat case final e?) e,
    };
    final res = <String, ({Competence competence, EtatCompetence etat})>{};
    for (final c in competencesAcquises) {
      for (final etat in c.competence.etats) {
        if (parAttaque.contains(etat.nom)) continue;
        res[etat.nom] = (competence: c.competence, etat: etat);
      }
    }
    return res.values.toList();
  }

  /// L'objet nommé [nom] est-il dans l'inventaire (porte-bonheur) ?
  Objet? objetNomme(String nom) {
    final n = nom.trim().toLowerCase();
    for (final o in personnage.inventaire) {
      if (o.nom.trim().toLowerCase() == n) return o;
    }
    return null;
  }

  /// Le personnage porte-t-il une armure (catégorie Armure) en métal ?
  bool get armureMetallique => personnage.inventaire.any(
        (o) =>
            o.equipe &&
            o.categorie == CategorieObjet.armure &&
            o.matiere == MatiereObjet.metal,
      );

  /// Condition calculée d'un effet (`si`) remplie pour ce personnage (et
  /// cette arme pour `arme-non-metallique`).
  bool conditionRemplie(Effet e, {Objet? arme}) => switch (e.si) {
        '' => true,
        // À cocher sur la page dé (dégâts, CA en 1 contre 1…) : jamais
        // compté d'office.
        'situation' => false,
        // Monté : une monture équipée (Cavalier émérite).
        'monte' => estMonte,
        // Bouclier équipé (Rempart arcanique).
        'bouclier' => personnage.inventaire
            .any((o) => o.equipe && o.categorie == CategorieObjet.bouclier),
        'sans-armure-metallique' => !armureMetallique,
        // Légèreté animale : armure légère ou pas d'armure.
        'armure-legere' => !personnage.inventaire.any(
            (o) =>
                o.equipe &&
                o.categorie == CategorieObjet.armure &&
                o.poidsArmure != PoidsArmure.legere,
          ),
        'arme-non-metallique' =>
          arme != null && arme.matiere != MatiereObjet.metal,
        // Arme dont le nom contient la précision (« Épée » → « Épée longue »).
        // Plusieurs noms possibles séparés par des virgules (« Hache, Marteau »).
        'arme-choisie' => arme != null &&
            e.condition.split(',').any(
                  (n) =>
                      n.trim().isNotEmpty &&
                      arme.nom.toLowerCase().contains(n.trim().toLowerCase()),
                ),
        _ => false,
      };

  /// Réduction de dégâts contre un type (le chaos ignore toute RD).
  int rdContre(String type) {
    if (type == 'chaos') return 0;
    for (final r in resistances) {
      if (r.type == type) return r.total;
    }
    return 0;
  }

  /// Résistances aux dégâts (effets `bonus` de catégorie « RD feu »,
  /// « RD phy »…), additionnées par type (physique, magique, feu, glace,
  /// foudre…) avec leurs sources ; types triés dans un ordre fixe.
  List<({String type, int total, List<BonusSituation> sources})>
      get resistances {
    const synonymes = {'phy': 'physique', 'mag': 'magique'};
    const ordre = ['physique', 'magique', 'feu', 'glace', 'foudre'];
    final parType = <String, List<BonusSituation>>{};
    for (final s in effetsActifs) {
      final e = s.effet;
      final m = RegExp(r'^rd\s+(\S+)').firstMatch(e.categorieNormalisee);
      if (e.typeNormalise != 'bonus' || m == null) continue;
      if (!conditionRemplie(e)) continue;
      final v = e.valeurEntiere;
      if (v == null || v == 0) continue;
      final type = synonymes[m.group(1)] ?? m.group(1)!;
      (parType[type] ??= []).add((nom: s.nom, valeur: v));
    }
    final types = parType.keys.toList()
      ..sort((a, b) {
        final ia = ordre.indexOf(a), ib = ordre.indexOf(b);
        return (ia < 0 ? 99 : ia).compareTo(ib < 0 ? 99 : ib);
      });
    return [
      for (final t in types)
        (
          type: t,
          total: parType[t]!.fold(0, (n, b) => n + b.valeur),
          sources: parType[t]!,
        ),
    ];
  }

  /// Aptitudes données par les compétences (effets `aptitude`, valeur =
  /// id : équitation du Cheval de guerre) : comptées comme maîtrisées.
  Set<String> get aptitudesOffertes => {
        for (final s in effetsActifs)
          if (s.effet.typeNormalise == 'aptitude' && s.effet.valeur.isNotEmpty)
            s.effet.valeur,
      };

  /// Savoirs et savoir-faire maîtrisés par les compétences (noms sans
  /// accents) : effets `maitrise` de catégorie aptitude ou connaissance.
  Set<String> get savoirsMaitrises => {
        for (final s in effetsActifs)
          if (s.effet.typeNormalise == 'maitrise' &&
              const ['aptitude', 'connaissance']
                  .contains(s.effet.categorieNormalisee))
            ObjetDuCatalogue.normaliser(s.effet.valeur),
      };

  /// Une monture est équipée (= montée).
  bool get estMonte => personnage.inventaire
      .any((o) => o.equipe && o.categorie == CategorieObjet.monture);

  /// Condition d'un effet de défense, avec l'arme familiale en main pour
  /// `arme-choisie`.
  bool _conditionDefense(Effet e) => e.si == 'arme-choisie'
      ? personnage.inventaire.any((o) =>
          o.equipe &&
          o.categorie == CategorieObjet.arme &&
          conditionRemplie(e, arme: o))
      : conditionRemplie(e);

  /// Bonus de CA des compétences **contre un type d'attaque** (« CA CaC »,
  /// « CA DIST », « CA MAG » : effets `ca` — ou anciens effets `esquive` —
  /// de catégorie `CaC`, `DIST`, `MAG` ; Foi : +RANG contre les sorts).
  int bonusCAContre(String categorie) {
    var total = 0;
    for (final s in effetsActifs) {
      final t = s.effet.typeNormalise;
      if ((t == 'ca' || t == 'esquive') &&
          s.effet.categorieNormalisee == categorie.toLowerCase() &&
          _conditionDefense(s.effet)) {
        total += s.effet.valeurEntiere ?? 0;
      }
    }
    return total;
  }

  /// Bonus de CA des compétences contre toutes les attaques (Équipement
  /// naturel : +2 sans armure métallique) ; pas ceux d'un type d'attaque.
  int get bonusCACompetences {
    var total = 0;
    for (final s in effetsActifs) {
      if (s.effet.typeNormalise != 'ca' || s.effet.categorie.isNotEmpty) {
        continue;
      }
      if (_conditionDefense(s.effet)) total += s.effet.valeurEntiere ?? 0;
    }
    return total;
  }

  /// Bonus d'esquive des compétences (effets `esquive` sans catégorie).
  int get bonusEsquive {
    var total = 0;
    for (final s in effetsActifs) {
      if (s.effet.typeNormalise == 'esquive' &&
          s.effet.categorie.isEmpty &&
          _conditionDefense(s.effet)) {
        total += s.effet.valeurEntiere ?? 0;
      }
    }
    return total;
  }

  /// Dés de dégâts ajoutés à une arme par les compétences (Équipement
  /// naturel : +1d6 aux armes non métalliques).
  /// Aussi les bonus fixes (Outils de nain : +1 avec hache et marteau) ; une
  /// valeur « INT » vaut le modificateur d'INT (Marque de sang).
  List<SourceEffet> desEnPlus(Objet? arme) => [
        for (final s in effetsActifs)
          if (s.effet.typeNormalise == 'degats' &&
              conditionRemplie(s.effet, arme: arme))
            if (Carac.depuisCode(s.effet.valeur) case final c?)
              (
                nom: s.nom,
                origine: s.origine,
                effet: s.effet.avecValeur('${mod(c)}'),
              )
            else if (lireDes(s.effet.valeur) != null ||
                s.effet.valeurEntiere != null)
              s,
      ];

  /// Bonus permanents de caractéristiques (« +2 SOC »), ajoutés à la valeur.
  List<SourceEffet> get bonusCaracteristiques => [
        for (final s in effetsActifs)
          if (s.effet.estBonusCarac) s
      ];

  /// Bonus aux tests seulement (« +5 aux tests de MEN »), à ajouter au
  /// lancer de dés.
  /// Une valeur qui est le code d'une caractéristique (« FOR ») vaut son
  /// modificateur (Style barbaresque : + mod FOR aux tests de MEN).
  List<SourceEffet> get bonusTests => [
        for (final s in effetsActifs)
          if (s.effet.estBonusTest)
            if (s.effet.valeurEntiere == null &&
                Carac.depuisCode(s.effet.valeur) != null)
              (
                nom: s.nom,
                origine: s.origine,
                effet: s.effet
                    .avecValeur('${mod(Carac.depuisCode(s.effet.valeur)!)}'),
              )
            else
              s
      ];

  /// Bonus de tests **sans condition** (« Avantage aux jets de CHAN »,
  /// « +3 aux tests de CON ») : toujours appliqués aux jets concernés.
  List<SourceEffet> get bonusTestsPermanents => [
        for (final s in bonusTests)
          if (s.effet.condition.isEmpty) s
      ];

  /// Bonus de tests liés à une situation (« en forêt », « contre le
  /// froid ») : à cocher sur la page Lancer de dé.
  /// Aussi les dégâts et la CA « à cocher » (`si` : `situation` : en 1
  /// contre 1, aux côtés de ses soldats…).
  List<SourceEffet> get bonusTestsSituationnels => [
        for (final s in bonusTests)
          if (s.effet.condition.isNotEmpty) s,
        ...situationsHorsTests,
      ];

  /// Dégâts, CA et esquives à cocher (`si` : `situation`) : dégâts ajoutés
  /// aux jets de dégâts au corps à corps une fois cochés ; CA rappelée.
  List<SourceEffet> get situationsHorsTests => [
        for (final s in effetsActifs)
          if (s.effet.si == 'situation' &&
              const {'degats', 'ca', 'esquive', 'savoir'}
                  .contains(s.effet.typeNormalise))
            s,
      ];

  /// Total des bonus de compétences / passifs pour une caractéristique.
  int bonusEffets(Carac c) {
    var total = 0;
    for (final s in bonusCaracteristiques) {
      if (s.effet.carac == c) total += s.effet.valeurEntiere!;
    }
    return total;
  }

  /// Renforcement acquis qui améliore cette compétence (« Adaptabilité
  /// (niveau 1) » améliorée par « adaptabilité (niveau 2) »), sinon `null`.
  SourceEffet? ameliorationDe(Competence competence) =>
      ameliorationDeNom(competence.nom);

  /// Renforcement acquis qui améliore le trait ou la compétence nommé [nom]
  /// (« Passé de violence (niveau 1) » ← « passé de violence (niveau 2) »).
  SourceEffet? ameliorationDeNom(String nom) {
    final base = Effet.nomDeBase(nom);
    for (final s in effetsActifs) {
      if (s.effet.estRenforcement &&
          s.effet.nom.isNotEmpty &&
          s.nom != nom &&
          Effet.nomDeBase(s.effet.nom) == base) {
        return s;
      }
    }
    return null;
  }

  /// Valeur finale d'une caractéristique : base + race + origine + bonus
  /// des passifs et compétences acquises (effets « bonus »).
  int carac(Carac c) =>
      (personnage.caracBase[c] ?? kValeurCaracParDefaut) +
      modificateurRacial(c) +
      bonusEffets(c);

  /// Modificateur de la valeur finale d'une caractéristique.
  int mod(Carac c) => modificateur(carac(c));

  // --- Vie et mana ---------------------------------------------------------

  /// PV max = DV max + mod(CON) au niveau 1, + 1 jet de DV par niveau,
  /// + bonus des règles particulières (Force de la nature, Style
  /// barbaresque, Vitalité elfique…). Minimum 1.
  /// Le DV max du niveau 1 est celui de la création : Vitalité elfique ne le
  /// recalcule pas (elle donne +10 PV max à la prise).
  int get pvMax {
    var total = deVieDeBase + mod(Carac.con);
    for (final jet in personnage.jetsDeVie) {
      total += jet;
    }
    total += bonusPvCompetences;
    return total < 1 ? 1 : total;
  }

  /// Part des PV max venant des règles particulières.
  int get bonusPvCompetences {
    var total = 0;
    for (final b in personnage.bonusDeVie) {
      total += b;
    }
    total += ReglesParticulieres.bonusPvALaPrise(
      personnage,
      race,
      mod(Carac.force),
    );
    return total;
  }

  /// Règles particulières actives (avec leur origine), pour l'affichage.
  List<RegleParticuliere> get reglesParticulieres =>
      ReglesParticulieres.actives(
        personnage: personnage,
        race: race,
        classe: classe,
        mod: mod,
        deVieAncien: deVieDeBase,
        deVieNouveau: deVie,
        deManaAncien: deManaDeBase,
        deManaNouveau: deMana,
      );

  /// PM max = DM max au niveau 1, puis + 1 jet de DM par niveau. Classes
  /// physiques : 0 (pas de mana, règle du 03/11/2026).
  int get pmMax {
    if (!classe.aDuMana) return 0;
    var total = deMana;
    for (final jet in personnage.jetsDeMana) {
      total += jet;
    }
    return total;
  }

  int get pvActuels => personnage.pvActuels ?? pvMax;
  int get pmActuels => classe.aDuMana ? personnage.pmActuels ?? pmMax : 0;

  /// PE max = DE max au niveau 1, puis + 1 jet de DE par niveau (comme le
  /// mana). Lanceurs de sorts : 0 (pas d'endurance).
  int get peMax {
    if (!classe.aDeLEndurance) return 0;
    var total = deEndurance;
    for (final jet in personnage.jetsDEndurance) {
      total += jet;
    }
    // Personnage créé avant l'endurance (03/11/2026) : les jets des niveaux
    // déjà passés comptent pour la moyenne du dé, arrondie au-dessus.
    final manquants = personnage.niveau - 1 - personnage.jetsDEndurance.length;
    if (manquants > 0) total += manquants * (deEndurance ~/ 2 + 1);
    return total;
  }

  int get peActuels => classe.aDeLEndurance ? personnage.peActuels ?? peMax : 0;

  /// PV rendus par une nuit de sommeil : jet de DV + mod(CON), minimum 0.
  int pvRecuperesNuit(int jetDeVie) {
    final pv = jetDeVie + mod(Carac.con);
    return pv < 0 ? 0 : pv;
  }

  /// PV rendus par une demi-nuit de sommeil : un jet de DV (sans CON).
  int pvRecuperesDemiNuit(int jetDeVie) => jetDeVie < 0 ? 0 : jetDeVie;

  /// PM rendus par une nuit de sommeil : DM (÷2 pour une demi-nuit).
  int pmRecuperesNuit({bool demiNuit = false}) => !classe.aDuMana
      ? 0
      : demiNuit
          ? deMana ~/ 2
          : deMana;

  /// PE rendus par une nuit de sommeil : DE (÷2 pour une demi-nuit).
  int peRecuperesNuit({bool demiNuit = false}) =>
      demiNuit ? deEndurance ~/ 2 : deEndurance;

  /// Classe sans mana (physique) : ses sorts (raciaux : Cri sauvage, Visage
  /// impensable) se paient en PE, au même coût (règle du 03/11/2026).
  bool get sortsEnEndurance => !classe.aDuMana;

  /// Points disponibles pour lancer un sort : PE ou PM.
  int get pointsPourSorts => sortsEnEndurance ? peActuels : pmActuels;

  /// « PE » ou « PM » : ressource dépensée par les sorts.
  String get uniteSorts => sortsEnEndurance ? 'PE' : 'PM';

  /// Actions des compétences acquises qui coûtent de l'endurance (page
  /// Lancer de dé) : (libellé, coût, compétence d'origine).
  List<({String libelle, int cout, String origine})> get actionsEndurance => [
        if (classe.aDeLEndurance)
          for (final c in competencesAcquises)
            for (final e in c.competence.endurance)
              (
                libelle: e.libelle.isEmpty ? c.competence.nom : e.libelle,
                cout: e.cout,
                origine: c.competence.nom,
              ),
      ];

  // --- Défense -------------------------------------------------------------

  /// Initiative = **valeur** de DEX + bonus d'initiative permanents (règle du
  /// 31/10/2026) : plus de jet, pas de limite de DEX liée à l'armure.
  int get initiative =>
      carac(Carac.dex) + bonusInitiative.fold(0, (n, b) => n + b.valeur);

  /// Bonus d'initiative permanents des compétences (effets `test` de
  /// catégorie INIT sans condition : Rune de vitesse +5).
  List<BonusSituation> get bonusInitiative => [
        for (final s in bonusTestsPermanents)
          if (s.effet.carac == null &&
              s.effet.categorieNormalisee == 'init' &&
              (s.effet.valeurEntiere ?? 0) != 0)
            (nom: s.nom, valeur: s.effet.valeurEntiere!),
      ];

  /// Bonus d'initiative selon la situation (« entouré de végétation ») : à
  /// cocher sur la page dé.
  List<SourceEffet> get initiativeSituationnelle => [
        for (final s in bonusTestsSituationnels)
          if (s.effet.carac == null && s.effet.categorieNormalisee == 'init') s,
      ];

  /// Déplacement d'une action de mouvement, par défaut (règle système).
  static const int deplacementDeBase = 10;

  /// Bonus de déplacement des compétences (Colosse infatigable : +5 m).
  List<BonusSituation> get bonusDeplacement => [
        for (final s in effetsActifs)
          if (s.effet.typeNormalise == 'deplacement' &&
              s.effet.valeurEntiere != null)
            (nom: s.nom, valeur: s.effet.valeurEntiere!),
      ];

  /// Actions de mouvement par tour : 1 + compétences (Insaisissable).
  int get actionsMouvement =>
      1 +
      [
        for (final s in effetsActifs)
          if (s.effet.typeNormalise == 'mouvement') s.effet.valeurEntiere ?? 0,
      ].fold(0, (a, b) => a + b);

  /// Hauteur de chute sans dégâts (Bond du chat : RANG × 3 m), 0 sinon.
  int get chuteSansDegats => [
        0,
        for (final s in effetsActifs)
          if (s.effet.typeNormalise == 'chute') s.effet.valeurEntiere ?? 0,
      ].reduce((a, b) => a > b ? a : b);

  /// Mètres parcourus par action de mouvement : 10 m + bonus.
  int get deplacement =>
      deplacementDeBase + bonusDeplacement.fold(0, (n, b) => n + b.valeur);

  /// Bonus de CA des armures, boucliers et casques portés.
  int get bonusCAEquipement {
    var total = 0;
    for (final o in personnage.inventaire) {
      if (o.equipe && o.categorie.protection) total += o.bonusCA;
    }
    return total;
  }

  /// Plus forte limite de DEX des protections portées (armure de plaques :
  /// +1) ; `null` : aucune limite.
  int? get limiteDex {
    int? limite;
    for (final o in personnage.inventaire) {
      final m = o.dexMax;
      if (o.equipe && o.categorie.protection && m != null) {
        limite = limite == null ? m : math.min(limite, m);
      }
    }
    return limite;
  }

  /// Mod de DEX compté en défense : plafonné par l'armure (un malus de DEX
  /// compte en entier).
  int get dexDefense {
    final d = mod(Carac.dex);
    final l = limiteDex;
    return l == null ? d : math.min(d, l);
  }

  /// CA = 10 + CA d'armure (armure, bouclier, casque) + mod(DEX) dans la
  /// limite de l'armure + compétences (refonte du 29/10/2026). Les jets
  /// d'attaque (CaC, distance, sorts) visent la CA.
  int get classeArmure =>
      10 + bonusCAEquipement + dexDefense + bonusCACompetences;

  /// CA contre les attaques au corps à corps, à distance et les sorts : CA +
  /// bonus des compétences contre ce type (Foi : +RANG contre les sorts).
  int get caCac => classeArmure + bonusCAContre('CaC');
  int get caDistance => classeArmure + bonusCAContre('DIST');
  int get caMagie => classeArmure + bonusCAContre('MAG');

  /// Bonus de CA contre un type d'attaque, non nuls : « +3 contre les sorts ».
  List<String> get caContre => [
        for (final (cat, texte) in const [
          ('CaC', 'au CaC'),
          ('DIST', 'à distance'),
          ('MAG', 'contre les sorts'),
        ])
          if (bonusCAContre(cat) case final b when b != 0)
            '${b > 0 ? '+' : '−'}${b.abs()} $texte',
      ];

  /// Jet d'esquive = 1d20 + mod(DEX) dans la limite de l'armure + bonus
  /// d'esquive (29/10/2026) : contre ce qui n'a pas de jet d'attaque
  /// (souffle, trait des arcanes) ; réussi, il annule tout. Pas de valeur
  /// fixe affichée sur la fiche : c'est un jet.
  int get bonusJetEsquive => dexDefense + bonusEsquive;

  // --- Attaque -------------------------------------------------------------

  /// Toucher = 1d20 + mod(aptitude) + bonus. Renvoie le bonus ajouté au d20.
  /// (+ bonus des compétences avec l'arme équipée : gnome, arme maîtrisée.)
  int get toucherCac => mod(Carac.adc) + _somme(bonusToucher(distance: false));
  int get toucherDistance =>
      mod(Carac.adt) + _somme(bonusToucher(distance: true));

  static int _somme(List<BonusSituation> l) =>
      l.fold(0, (n, b) => n + b.valeur);
  int get toucherMagie => mod(Carac.adm);

  /// Bonus de dégâts au corps à corps = mod(FOR).
  int get degatsCac => mod(Carac.force);

  /// Bonus de dégâts à distance = mod(DEX) (décision du 21/10/2026).
  int get degatsDistance => mod(Carac.dex);

  /// Bonus de dégâts magiques = mod(INT) (décision du 21/10/2026).
  int get degatsMagie => mod(Carac.intel);

  /// Dégâts au corps à corps : dé de l'arme de CaC équipée + mod(FOR).
  DetailDegats get detailDegatsCac =>
      _detailDegats(Carac.force, degatsCac, distance: false);

  /// Dégâts à distance : dé de l'arme à distance équipée + mod(DEX).
  DetailDegats get detailDegatsDistance =>
      _detailDegats(Carac.dex, degatsDistance, distance: true);

  /// Dégâts magiques : dé du sort + mod(INT).
  DetailDegats get detailDegatsMagie =>
      DetailDegats(carac: Carac.intel, bonus: degatsMagie, magie: true);

  DetailDegats _detailDegats(Carac c, int bonus, {required bool distance}) =>
      DetailDegats(
        carac: c,
        bonus: bonus,
        distance: distance,
        armes: [
          for (final o in personnage.inventaire)
            if (o.equipe &&
                o.categorie == CategorieObjet.arme &&
                o.distance == distance)
              o,
        ],
        enPlus: {
          for (final o in personnage.inventaire)
            if (o.equipe && o.categorie == CategorieObjet.arme)
              o.id: desEnPlus(o),
          // Mains nues : effets sans condition d'arme (rage : +1d6).
          '': desEnPlus(null),
        },
        desMainsNues: desMainsNues,
        // Armes à feu : pas de DEX aux dégâts, sauf Expertise de la poudre.
        sansCarac: {
          if (distance && !expertisePoudre)
            for (final o in personnage.inventaire)
              if (estArmeAFeu(o)) o.id,
        },
      );

  /// Dé des attaques à mains nues : 1d4, ou le dernier effet `mains-nues`
  /// des compétences (Pugilat : 1d6, Poing de fer : 1d8).
  String get desMainsNues {
    var de = DetailDegats.desMainsNuesDeBase;
    for (final s in effetsActifs) {
      if (s.effet.typeNormalise == 'mains-nues' &&
          lireDes(s.effet.valeur) != null) {
        de = s.effet.valeur;
      }
    }
    return de;
  }

  /// Aucune arme de corps à corps équipée (combat à mains nues).
  bool get aMainsNues => !personnage.inventaire.any(
      (o) => o.equipe && o.categorie == CategorieObjet.arme && !o.distance);

  /// « 1dDM », « 4dDM » : dés de mana du personnage (Frappe de ki,
  /// Kenn-do-ha) ; le reste du texte est gardé.
  /// « 3dDV » : dés de vie (Puits d'arcane) ; « 1dDE » : dés d'endurance.
  String avecDeMana(String texte) => texte
      .replaceAll(RegExp(r'd\s*DM\b'), 'd$deMana')
      .replaceAll(RegExp(r'd\s*DV\b'), 'd$deVie')
      .replaceAll(RegExp(r'd\s*DE\b'), 'd$deEndurance');

  /// Arme à poudre (pétoire, pistolet, mousquet, canon…), d'après son nom.
  static bool estArmeAFeu(Objet o) =>
      o.categorie == CategorieObjet.arme &&
      RegExp(r'p[ée]toire|pistolet|mousquet|canon|arquebuse',
              caseSensitive: false)
          .hasMatch(o.nom);

  /// Expertise de la poudre (ingénieur) : la DEX s'ajoute aux dégâts des
  /// armes à feu.
  bool get expertisePoudre => effetsActifs.any(
        (s) =>
            s.effet.typeNormalise == 'maitrise' &&
            s.effet.categorieNormalisee == 'expertise-poudre',
      );

  /// Bidouillage (ingénieur) : les armes à poudre peuvent être améliorées.
  bool get bidouillage => effetsActifs.any(
        (s) =>
            s.effet.typeNormalise == 'maitrise' &&
            s.effet.categorieNormalisee == 'bidouillage',
      );
}

/// Dégâts d'un type d'attaque, avec l'origine de chaque partie : dé de
/// chaque arme équipée de cette portée + modificateur de stat.
class DetailDegats {
  const DetailDegats({
    required this.carac,
    required this.bonus,
    this.armes = const [],
    this.distance = false,
    this.magie = false,
    this.enPlus = const {},
    this.sansCarac = const {},
    this.desMainsNues = desMainsNuesDeBase,
  });

  final Carac carac;
  final int bonus;

  /// Armes (id) dont les dégâts ne prennent pas le modificateur [bonus]
  /// (armes à feu sans Expertise de la poudre).
  final Set<String> sansCarac;

  /// Dés ajoutés par les compétences, par arme (id → sources).
  final Map<String, List<SourceEffet>> enPlus;

  /// Armes équipées de cette portée (une ligne de dégâts chacune).
  final List<Objet> armes;
  final bool distance;
  final bool magie;

  /// Une entrée par arme : (« 1d8 +3 », « Bâton · 2 mains ») ; sans arme,
  /// le bonus seul (« +3 », pas de nom).
  List<(String, String?)> get entrees => armes.isEmpty
      ? [
          mainsNues
              ? (formaterJet(desMainsNuesAvec, bonusMainsNues), 'Mains nues')
              : (formaterModificateur(bonus), null),
        ]
      : [for (final a in armes) (jet(a), resumeArme(a))];

  /// Dés d'une attaque à mains nues (règle système : 1d4 ; Pugilat du
  /// moine : 1d6, Poing de fer : 1d8).
  static const String desMainsNuesDeBase = '1d4';
  final String desMainsNues;

  /// Corps à corps sans arme : attaque à mains nues (1d4 + FOR).
  bool get mainsNues => armes.isEmpty && !distance && !magie;

  /// Dés à mains nues avec ceux des compétences (rage : « 1d4 + 1d6 »).
  String get desMainsNuesAvec => [
        desMainsNues,
        for (final s in enPlus[''] ?? const <SourceEffet>[])
          if (lireDes(s.effet.valeur) != null) s.effet.valeur,
      ].join(' + ');

  /// Bonus à mains nues : modificateur + bonus fixes des compétences.
  int get bonusMainsNues =>
      bonus +
      [
        for (final s in enPlus[''] ?? const <SourceEffet>[])
          if (lireDes(s.effet.valeur) == null) s.effet.valeurEntiere ?? 0,
      ].fold(0, (a, b) => a + b);

  /// Dégâts de la première entrée.
  String get texte => entrees.first.$1;

  /// Dés de [arme] selon sa prise, plus ceux des compétences : « 1d8 + 1d6 ».
  String des(Objet arme) {
    final de = arme.degatsActuels;
    if (de.isEmpty) return '';
    return [
      de,
      for (final s in enPlus[arme.id] ?? const <SourceEffet>[])
        if (lireDes(s.effet.valeur) != null) s.effet.valeur,
    ].join(' + ');
  }

  /// Bonus ajouté aux dés de [arme] : modificateur + bonus fixes des
  /// compétences (+1 DM des Outils de nain).
  int bonusAvec(Objet arme) =>
      (sansCarac.contains(arme.id) ? 0 : bonus) +
      [
        for (final s in enPlus[arme.id] ?? const <SourceEffet>[])
          if (lireDes(s.effet.valeur) == null) s.effet.valeurEntiere ?? 0,
      ].fold(0, (a, b) => a + b);

  /// « 1d8 + 1d6 +3 » pour [arme] (le bonus seul si ses dégâts sont vides).
  String jet(Objet arme) {
    final de = des(arme);
    return de.isEmpty
        ? formaterModificateur(bonusAvec(arme))
        : formaterJet(de, bonusAvec(arme));
  }

  /// Nom de l'arme, avec sa prise : « Bâton · 2 mains ».
  static String resumeArme(Objet a) => a.polyvalente
      ? '${a.nom} · ${a.tenueDeuxMains ? '2 mains' : '1 main'}'
      : a.nom;

  /// Détail ligne par ligne (infobulle de la fiche).
  String get explication {
    String origine(Objet a) {
      final de = a.degatsActuels;
      return '${a.nom}'
          '${a.polyvalente ? ' (tenu à ${a.tenueDeuxMains ? 'deux mains' : 'une main'})' : ''}'
          ' : ${de.isEmpty ? 'dégâts non renseignés' : de}'
          '${a.typeDegats == null ? '' : ' ${a.typeDegats}'}';
    }

    final lignes = <String>[
      if (magie)
        'Dé de dégâts : celui du sort lancé'
      else if (armes.isEmpty)
        distance
            ? 'Aucune arme à distance équipée'
            : 'Mains nues (aucune arme de CaC équipée) : $desMainsNues'
      else
        for (final a in armes) ...[
          origine(a),
          for (final s in enPlus[a.id] ?? const <SourceEffet>[])
            '${lireDes(s.effet.valeur) == null ? formaterModificateur(s.effet.valeurEntiere ?? 0) : '+${s.effet.valeur}'} (${s.nom}'
                '${s.effet.condition.isEmpty ? '' : ', ${s.effet.condition}'})',
          if (sansCarac.contains(a.id))
            'Arme à feu : sans ${carac.abrev} (Expertise de la poudre requise)',
        ],
      'Modificateur ${carac.abrev} : ${formaterModificateur(bonus)}',
      if (armes.length > 1)
        for (final a in armes) 'Total ${a.nom} : ${jet(a)}'
      else
        'Total : $texte',
    ];
    return lignes.join('\n');
  }
}
