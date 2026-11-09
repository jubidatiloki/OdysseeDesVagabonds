import 'dart:math' as math;

import '../models/objet.dart';
import 'des.dart';
import 'fiche_calculee.dart';
import 'inventaire.dart';

/// Malus au toucher d'une arme non maîtrisée (règles §5.5 : maîtrise d'arme,
/// aptitude complexe).
const int kMalusArmeNonMaitrisee = -5;

/// Mots d'un nom, sans accents ni majuscules : « Lance d'arçon » →
/// {lance, d, arcon}. « arc » ne se confond pas avec « arçon ».
Set<String> _mots(String texte) => ObjetDuCatalogue.normaliser(texte)
    .split(RegExp('[^a-z0-9]+'))
    .where((m) => m.isNotEmpty)
    .toSet();

bool _nomContient(String nom, String motsCherches) {
  final cherches = _mots(motsCherches);
  return cherches.isNotEmpty && _mots(nom).containsAll(cherches);
}

/// Niveau d'une armure : tissu 0, cuir 1, cotte de mailles 2, plaques 3.
int? _niveauArmure(Objet o) => switch (o.poidsArmure) {
      PoidsArmure.lourde => 3,
      PoidsArmure.intermediaire => 2,
      PoidsArmure.legere => o.matiere == MatiereObjet.tissu ? 0 : 1,
      PoidsArmure.nonPrecise => null,
    };

/// Limite d'armure (classe, race) → niveau le plus lourd permis. Familles
/// (09/11/2026) : légère (tissu, cuir), intermédiaire (cotte de mailles),
/// lourde (plaques). Les anciens codes « cuir » et « mailles » restent lus.
const Map<String, int> _niveauxMax = {
  'tissu': 0,
  'legere': 1,
  'cuir': 1,
  'intermediaire': 2,
  'mailles': 2,
};

/// Niveau d'une armure du catalogue (`null` : pas une armure de corps, ou
/// poids non précisé).
int? niveauArmure(Objet o) =>
    o.categorie == CategorieObjet.armure ? _niveauArmure(o) : null;

/// « Légère », « Intermédiaire », « Lourde » d'après le niveau d'armure.
String familleArmure(int niveau) => switch (niveau) {
      <= 1 => 'Légère',
      2 => 'Intermédiaire',
      _ => 'Lourde',
    };

/// Niveau d'une limite d'armure ; vide : aucune limite.
int niveauArmureMax(String m) => _niveauxMax[m] ?? 3;

/// « Communes de mêlée » ; un mot d'un nom prend une majuscule (« Arc »).
String libelleMaitriseArme(String m) => switch (m) {
      'civile' => 'Civiles',
      'commune' => 'Communes',
      'commune-melee' => 'Communes de mêlée',
      'commune-distance' => 'Communes à distance',
      'commune-1-main' => 'Communes à une main',
      'poudre' => 'Armes à poudre',
      'siege' => 'Armes de siège',
      _ => m.isEmpty ? m : m[0].toUpperCase() + m.substring(1),
    };

/// « Armures légères maximum » ; vide : toutes.
String libelleArmureMax(String m) => switch (m) {
      'tissu' => 'Vêtements de tissu seulement',
      'legere' || 'cuir' => 'Armures légères maximum',
      'intermediaire' || 'mailles' => 'Armures intermédiaires maximum',
      _ => 'Toutes',
    };

/// Maîtrises d'armes et restrictions de classe et de race (règles du
/// 07/11/2026).
extension MaitrisesFiche on FicheCalculee {
  /// Groupes et mots donnés par la classe, la race et l'origine.
  List<String> get _maitrisesDeBase => [
        ...classe.maitrisesArmes,
        ...race.maitrisesArmes,
        ...?race.origine(personnage.origineId)?.maitrisesArmes,
      ];

  /// Une arme sans groupe (personnalisée) ou une classe sans liste de
  /// maîtrises ne donnent pas de malus.
  bool armeMaitrisee(Objet o) {
    if (o.categorie != CategorieObjet.arme) return true;
    final groupe = o.groupeArme.isNotEmpty
        ? o.groupeArme
        : FicheCalculee.groupesArmes[ObjetDuCatalogue.normaliser(o.nom)] ?? '';
    final base = _maitrisesDeBase;
    if (groupe.isEmpty || base.isEmpty) return true;
    final commune = groupe.startsWith('commune');
    for (final m in base) {
      final ok = switch (m) {
        'civile' || 'commune-melee' || 'commune-distance' => m == groupe,
        'poudre' || 'siege' => m == groupe,
        'commune' => commune,
        'commune-1-main' => commune && !o.deuxMains,
        _ => _nomContient(o.nom, m),
      };
      if (ok) return true;
    }
    return armesMaitrisees.any((a) => _nomContient(o.nom, a));
  }

  /// Arme équipée qui attaque : la principale, sinon la première.
  Objet? _armeEnMain({required bool distance}) {
    final armes = [
      for (final o in personnage.inventaire)
        if (o.equipe &&
            o.categorie == CategorieObjet.arme &&
            o.distance == distance)
          o,
    ];
    if (armes.isEmpty) return null;
    for (final o in armes) {
      if (o.principale) return o;
    }
    return armes.first;
  }

  /// Malus au toucher dus à l'arme en main : non maîtrisée, ou d'un groupe
  /// que la race méprise (haut-elfe : −2 avec les armes à poudre).
  List<BonusSituation> malusArme({required bool distance}) {
    final o = _armeEnMain(distance: distance);
    if (o == null) return const [];
    final groupe = o.groupeArme.isNotEmpty
        ? o.groupeArme
        : FicheCalculee.groupesArmes[ObjetDuCatalogue.normaliser(o.nom)] ?? '';
    return [
      if (!armeMaitrisee(o))
        (nom: 'Arme non maîtrisée', valeur: kMalusArmeNonMaitrisee),
      if (race.malusArmes[groupe] case final m?)
        (nom: '${race.nom} : ${o.nom}', valeur: m),
    ];
  }

  /// Plus grand dé d'une formule ; « 2d6 » reste permis au gnome.
  bool _depasseDes(String formule, int desMax) {
    final f = lireFormule(formule);
    if (f == null) return false;
    return f.groupes.any(
      (g) =>
          g.faces > desMax ||
          (g.nombre > 1 && !(g.nombre == 2 && g.faces == 6)),
    );
  }

  /// Raison pour laquelle la classe ou la race interdit d'équiper [o]
  /// (`null` si rien ne l'interdit).
  String? refusRestriction(Objet o) {
    if (o.categorie == CategorieObjet.armure) {
      final niveau = _niveauArmure(o);
      if (niveau == null) return null;
      if (race.armuresPermises.any((m) => _nomContient(o.nom, m))) return null;
      final maxClasse = _niveauxMax[classe.armureMax] ?? 3;
      final maxRace = _niveauxMax[race.armureMax] ?? 3;
      if (niveau <= math.min(maxClasse, maxRace)) return null;
      return niveau > maxClasse
          ? '${classe.nom} : ${classe.restrictionArmure}'
          : '${race.nom} : ${race.restrictions}';
    }
    if (o.categorie != CategorieObjet.arme) return null;
    final desMax = race.desArmeMax;
    final interdite = race.armesInterdites.any((m) => _nomContient(o.nom, m)) ||
        (desMax != null &&
            (_depasseDes(o.degats, desMax) ||
                _depasseDes(o.degatsDeuxMains, desMax)));
    return interdite ? '${race.nom} : ${race.restrictions}' : null;
  }
}
