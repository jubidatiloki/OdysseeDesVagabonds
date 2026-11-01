import '../data/referentiel.dart';
import '../models/type_sort.dart';
import '../models/voie.dart';
import '../widgets/consultation.dart';
import 'fiche_calculee.dart';

/// D'où vient une compétence : voie de classe (et sorts de rang 0) ou voie
/// raciale.
enum OrigineCompetence {
  classe('Classes'),
  race('Races');

  const OrigineCompetence(this.libelle);

  final String libelle;
}

/// Catégories de filtre du Glossaire (onglet Compétences).
enum CategorieCompetence {
  sort('Sorts'),
  sortMineur('Sorts mineurs'),
  competence('Compétences'),
  soutien('Soutien'),
  soin('Soin'),
  degats('Dégâts');

  const CategorieCompetence(this.libelle);

  final String libelle;
}

/// Une compétence du Glossaire, avec sa voie et ses catégories.
class EntreeCompetence {
  const EntreeCompetence({
    required this.competence,
    required this.voie,
    required this.titreGroupe,
    required this.origine,
    required this.categories,
    required this.texteRecherche,
    this.mention,
  });

  final Competence competence;
  final Voie voie;

  /// « Barbare · Voie de la brute », « Nain · Voie du nain ».
  final String titreGroupe;
  final OrigineCompetence origine;
  final Set<CategorieCompetence> categories;

  /// Nom, type, effets… sans accents (recherche).
  final String texteRecherche;

  /// Petit texte sous la compétence (sorts mineurs : « Pour : Druide »).
  final String? mention;
}

/// Toutes les compétences des voies de classe, des voies raciales et les
/// sorts de rang 0, regroupées par voie ; filtres et recherche.
class IndexCompetences {
  /// Soin : « soigne », « soin », « regagne 2d6 PV » (pas « regagner du mana »
  /// ni « ne peut pas regagner de PV »).
  static final _soin =
      RegExp(r'soign|\bsoins?\b|(?<!pas )regagne\w*\s+(?:\S+\s+){0,2}pv\b');
  static final _degats = RegExp(r'degat|\bdm\b|\bdmg\b');

  /// Catégories d'une compétence, d'après son type, ses champs (dégâts,
  /// soin, attaque) et le texte de ses effets.
  static Set<CategorieCompetence> categories(Competence c) {
    final type = normaliserRecherche(c.type);
    final texte = _texte(c);
    final sort = FicheCalculee.coutSort(c) != null;
    return {
      if (sort) CategorieCompetence.sort,
      // Sorts mineurs : rang 0 (appris comme une aptitude, 0 PM).
      if (sort && c.rang == 0) CategorieCompetence.sortMineur,
      if (!sort && type.contains('competence')) CategorieCompetence.competence,
      if (type.contains('soutien') || c.objets.isNotEmpty)
        CategorieCompetence.soutien,
      if (c.soin.isNotEmpty || _soin.hasMatch(texte)) CategorieCompetence.soin,
      if (c.degats.isNotEmpty ||
          c.jets.any((j) => j.attaque != null) ||
          _degats.hasMatch(texte))
        CategorieCompetence.degats,
    };
  }

  static String _texte(Competence c) => normaliserRecherche([
        c.nom,
        c.type,
        c.effet,
        c.degats,
        c.soin,
        c.effetApplique,
        for (final e in c.effets) e.libelle,
        for (final s in c.etats)
          for (final e in s.effets) e.libelle,
        for (final t in c.typesSort) t.libelle,
      ].join(' '));

  /// L'index complet, dans l'ordre : classes (voies), sorts de rang 0,
  /// races (voie raciale).
  static List<EntreeCompetence> construire(Referentiel r) {
    final res = <EntreeCompetence>[];
    // Sorts mineurs : classes qui peuvent les apprendre.
    final pour = <Competence, String>{
      for (final a in r.sortsRang0)
        a.sort!: a.classes.isEmpty
            ? 'Pour : toutes les classes magiques et hybrides'
            : 'Pour : ${a.classes.map((id) => r.classe(id)?.nom ?? id).join(', ')}',
    };
    void ajouter(Voie v, String titre, OrigineCompetence o) {
      for (final c in v.competences) {
        for (final x in [c, ...c.aussi]) {
          res.add(EntreeCompetence(
            competence: x,
            voie: v,
            titreGroupe: titre,
            origine: o,
            categories: categories(x),
            texteRecherche:
                '${normaliserRecherche(titre)} ${_texte(x)} ${normaliserRecherche(pour[x] ?? '')}',
            mention: pour[x],
          ));
        }
      }
    }

    for (final cl in r.classes) {
      for (final v in cl.voies) {
        ajouter(v, '${cl.nom} · ${v.nom}', OrigineCompetence.classe);
      }
    }
    final rang0 = Voie(
      id: FicheCalculee.voieSortsRang0.id,
      nom: FicheCalculee.voieSortsRang0.nom,
      competences: [
        for (final a in r.sortsRang0) a.sort!,
      ],
    );
    if (rang0.competences.isNotEmpty) {
      ajouter(rang0, 'Sorts mineurs (rang 0)', OrigineCompetence.classe);
    }
    for (final ra in r.races) {
      final v = ra.voieRaciale;
      if (v != null) ajouter(v, '${ra.nom} · ${v.nom}', OrigineCompetence.race);
    }
    return res;
  }

  /// Entrées gardées : origine parmi [origines] (une compétence n'en a
  /// qu'une), **toutes** les catégories de [categories] (« Sorts » +
  /// « Dégâts » : les sorts de dégâts seulement) ; ensembles vides : pas de
  /// filtre ; texte contenant [recherche].
  static List<EntreeCompetence> filtrer(
    List<EntreeCompetence> index, {
    Set<OrigineCompetence> origines = const {},
    Set<CategorieCompetence> categories = const {},
    Set<TypeSort> typesSort = const {},
    String recherche = '',
  }) {
    final r = normaliserRecherche(recherche.trim());
    return [
      for (final e in index)
        if ((origines.isEmpty || origines.contains(e.origine)) &&
            categories.every(e.categories.contains) &&
            // Types de sort cochés : tous à la fois (Offensif + Contrôle).
            typesSort.every(e.competence.typesSort.contains) &&
            (r.isEmpty || e.texteRecherche.contains(r)))
          e,
    ];
  }
}
