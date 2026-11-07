import '../models/classe.dart';
import '../models/equipement.dart';
import '../models/historique.dart';
import '../models/objet.dart';
import 'fiche_calculee.dart';

/// Règles d'équipement (règles §6.1) : 1 armure, 1 casque,
/// 2 bijoux/accessoires portés en même temps ; armes et boucliers dans la
/// limite de **2 mains** (une arme ou un bouclier à une main dans chaque
/// main, ou un seul à deux mains).
class ReglesInventaire {
  static const int mainsMax = 2;

  static int nombreEquipes(List<Objet> inventaire, CategorieObjet c) =>
      inventaire.where((o) => o.equipe && o.categorie == c).length;

  /// Objets équipés tenus en main, hors [sauf].
  static List<Objet> enMain(List<Objet> inventaire, {Objet? sauf}) => [
        for (final o in inventaire)
          if (o.equipe && o.mains > 0 && !identical(o, sauf)) o,
      ];

  /// Mains occupées par les armes et boucliers équipés, hors [sauf].
  static int mainsOccupees(List<Objet> inventaire, {Objet? sauf}) =>
      enMain(inventaire, sauf: sauf).fold(0, (n, o) => n + o.mains);

  /// Deux armes au plus, sans bouclier (Armement barbare).
  static bool _deuxArmes(List<Objet> enMain) =>
      enMain.length <= 2 &&
      enMain.every((o) => o.categorie == CategorieObjet.arme);

  /// Les objets en main dépassent-ils ce qui est permis ?
  static bool mainsDepassees(
    List<Objet> inventaire, {
    bool deuxArmesDeuxMains = false,
  }) {
    if (deuxArmesDeuxMains && _deuxArmes(enMain(inventaire))) return false;
    return mainsOccupees(inventaire) > mainsMax;
  }

  /// Raison pour laquelle on ne peut pas équiper [objet] (`null` si possible).
  /// [deuxArmesDeuxMains] : Armement barbare, deux armes (même à deux mains)
  /// au plus, sans bouclier.
  static String? refusEquipement(
    List<Objet> inventaire,
    Objet objet, {
    bool deuxArmesDeuxMains = false,
  }) {
    final c = objet.categorie;
    if (!c.equipable) return '${c.libelle} : ne s\'équipe pas.';
    if (objet.equipe) return null;
    final max = c.emplacementsMax;
    if (max != null && nombreEquipes(inventaire, c) >= max) {
      return max == 1
          ? 'Un objet « ${c.libelle.toLowerCase()} » est déjà porté : '
              'retire-le d\'abord.'
          : 'Déjà $max objets « ${c.libelle.toLowerCase()} » portés : '
              'retires-en un d\'abord.';
    }
    return _refusMains(inventaire, objet, objet.mains,
        deuxArmesDeuxMains: deuxArmesDeuxMains);
  }

  /// Raison pour laquelle [objet], équipé, ne peut pas passer à [deuxMains]
  /// (`null` si possible ou s'il n'est pas équipé).
  static String? refusPrise(
    List<Objet> inventaire,
    Objet objet, {
    required bool deuxMains,
    bool deuxArmesDeuxMains = false,
  }) {
    if (!objet.equipe) return null;
    return _refusMains(inventaire, objet, deuxMains ? 2 : 1,
        deuxArmesDeuxMains: deuxArmesDeuxMains);
  }

  static String? _refusMains(
    List<Objet> inventaire,
    Objet objet,
    int mains, {
    bool deuxArmesDeuxMains = false,
  }) {
    if (mains == 0) return null;
    final autres = enMain(inventaire, sauf: objet);
    if (deuxArmesDeuxMains && _deuxArmes([...autres, objet])) return null;
    final occupees = autres.fold(0, (n, o) => n + o.mains);
    if (occupees + mains <= mainsMax) return null;
    return '${objet.nom} se tient à ${mains == 2 ? 'deux mains' : 'une main'}'
        ' : déjà en main ${autres.map((o) => o.nom).join(' et ')}. '
        'Retire d\'abord une arme ou un bouclier.';
  }
}

/// Conversion d'un équipement du catalogue (`equipements.json`) en objet
/// d'inventaire pré-rempli.
class ObjetDuCatalogue {
  /// Propriétés du catalogue qui ne sont pas recopiées dans la description.
  static const _ignorees = ['prix', 'deblocage'];

  static Objet depuis(Equipement e) {
    // « deux main » / « 2 mains » → « deux mains » ; « 1 main » → « une main ».
    final etiquettes = [
      for (final t in e.etiquettes)
        switch (_norm(t)) {
          'deux main' || '2 mains' || '2 main' => 'deux mains',
          '1 main' || 'une mains' => 'une main',
          final n => n,
        },
    ];
    bool a(String t) => etiquettes.contains(t);
    final categorie = _categorie(e.categorie, a);
    final estArme = categorie == CategorieObjet.arme;

    String? propriete(String cle) {
      for (final p in e.proprietes.entries) {
        if (_norm(p.key) == cle) return p.value;
      }
      return null;
    }

    final uneMain = propriete('degats (une main)');
    final deuxMainsDegats = propriete('degats (deux mains)');
    final polyvalente = estArme && uneMain != null && deuxMainsDegats != null;
    final degats = estArme ? (uneMain ?? propriete('degats')) : null;

    // Propriétés reprises dans des champs de l'objet : pas dans la description.
    final utilisees = <String>{
      if (estArme) ...['degats', 'degats (une main)', 'degats (deux mains)'],
      if (categorie.protection) ...['ca', 'dex max'],
    };
    final autres = [
      for (final p in e.proprietes.entries)
        if (!utilisees.contains(_norm(p.key)) &&
            !_ignorees.any((i) => _norm(p.key).startsWith(i)))
          '${p.key} : ${p.value}',
    ];

    return Objet(
      nom: e.nom,
      categorie: categorie,
      groupeArme: e.groupeArme,
      description: [
        if (e.description.isNotEmpty) e.description,
        if (autres.isNotEmpty) autres.join(' · '),
      ].join('\n'),
      degats: degats == null ? '' : _des(degats),
      typeDegats: estArme ? _typeDegats(etiquettes) : null,
      deuxMains: (estArme || categorie == CategorieObjet.bouclier) &&
          !polyvalente &&
          a('deux mains') &&
          !a('une main'),
      polyvalente: polyvalente,
      degatsDeuxMains: polyvalente ? _des(deuxMainsDegats) : '',
      distance: estArme && a('distance'),
      duCatalogue: true,
      bonusCA: categorie.protection ? _entier(propriete('ca')) : 0,
      // « DEX max » : limite du bonus de DEX à la CA (armure de plaques : +1).
      dexMax: categorie.protection && propriete('dex max') != null
          ? _entier(propriete('dex max'))
          : null,
      matiere: _matiere(etiquettes),
      // Armure : « légère », « intermédiaire », « lourde ».
      poidsArmure: categorie == CategorieObjet.armure
          ? (a('legere')
              ? PoidsArmure.legere
              : a('intermediaire')
                  ? PoidsArmure.intermediaire
                  : a('lourde')
                      ? PoidsArmure.lourde
                      : PoidsArmure.nonPrecise)
          : PoidsArmure.nonPrecise,
    );
  }

  static CategorieObjet _categorie(
    CategorieEquipement c,
    bool Function(String) a,
  ) {
    // Étiquette « instrument » : instrument de musique.
    if (c != CategorieEquipement.arme && a('instrument')) {
      return CategorieObjet.instrument;
    }
    switch (c) {
      case CategorieEquipement.arme:
        return CategorieObjet.arme;
      case CategorieEquipement.armure:
        if (a('casque')) return CategorieObjet.casque;
        if (a('bouclier')) return CategorieObjet.bouclier;
        return CategorieObjet.armure;
      case CategorieEquipement.consommable:
        return CategorieObjet.consommable;
      case CategorieEquipement.objetMagique:
        return a('potion') ? CategorieObjet.consommable : CategorieObjet.divers;
      case CategorieEquipement.accessoire:
        return a('outil') ? CategorieObjet.divers : CategorieObjet.accessoire;
      case CategorieEquipement.instrument:
        return CategorieObjet.instrument;
      case CategorieEquipement.autre:
        return CategorieObjet.divers;
    }
  }

  /// Matière d'après les étiquettes : « bois », « cuir », « tissu », « métal »
  /// (ou fer, acier, plaque, mailles) ; arcs et bâtons en bois.
  static MatiereObjet _matiere(List<String> etiquettes) {
    for (final t in etiquettes) {
      if (const [
        'metal',
        'metallique',
        'fer',
        'acier',
        'plaque',
        'plaques',
        'mailles',
        'cotte de mailles'
      ].contains(t)) {
        return MatiereObjet.metal;
      }
      if (t == 'bois' || t == 'arc' || t == 'baton') return MatiereObjet.bois;
      if (t == 'cuir') return MatiereObjet.cuir;
      if (t == 'tissu') return MatiereObjet.tissu;
    }
    return MatiereObjet.nonPrecisee;
  }

  /// « 1D6 phy » → « 1d6 » (le dé seul quand il est reconnu).
  static String _des(String texte) {
    final m = RegExp(r'^\s*(\d*[dD]\d+(\s*[+−-]\s*\d+)?)').firstMatch(texte);
    return m == null ? texte.trim() : m.group(1)!.toLowerCase();
  }

  /// Étiquettes « tranchante », « contondant », « perçant » → type de dégâts.
  static String? _typeDegats(List<String> etiquettes) {
    for (final t in etiquettes) {
      if (t.startsWith('tranchant')) return 'tranchant';
      if (t.startsWith('contondant')) return 'contondant';
      if (t.startsWith('percant')) return 'perçant';
    }
    return null;
  }

  /// « +5 » → 5 ; 0 si illisible.
  static int _entier(String? texte) =>
      int.tryParse(
        RegExp(r'[+−-]?\s*\d+')
                .firstMatch(texte ?? '')
                ?.group(0)
                ?.replaceAll('−', '-')
                .replaceAll(' ', '')
                .replaceAll('+', '') ??
            '',
      ) ??
      0;

  /// Inventaire de base d'une classe, repris du [catalogue] (les ids
  /// inconnus sont ignorés).
  static List<Objet> inventaireBase(Classe c, List<Equipement> catalogue) => [
        for (final b in c.inventaireBase)
          for (final e in catalogue)
            if (e.id == b.id) depuis(e)..quantite = b.quantite,
      ];

  /// Texte sans accents ni majuscules.
  static String normaliser(String texte) => _norm(texte);

  static String _norm(String texte) => texte
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[éèê]'), 'e')
      .replaceAll('â', 'a')
      .replaceAll('î', 'i')
      .replaceAll('ç', 'c');
}

/// Objets donnés par les compétences (porte-bonheur, sacoche du gnome).
class ObjetsDonnes {
  /// Ajoute à l'inventaire les objets que les compétences acquises doivent
  /// donner et qui n'ont jamais été reçus (origine Race / Classe,
  /// verrouillée), avec une ligne d'historique chacun. Renvoie leurs noms.
  ///
  /// Un modèle avec `"catalogue": true` reprend l'équipement du [catalogue]
  /// de même nom s'il existe (arme choisie : dégâts, prise…). [descriptions]
  /// (clé → texte) : description saisie par le joueur (porte-bonheur), mise
  /// avant la description de base.
  static List<String> recevoir(
    FicheCalculee fiche, {
    List<Equipement> catalogue = const [],
    Map<String, String> descriptions = const {},
    DateTime? maintenant,
  }) {
    final p = fiche.personnage;
    final recus = <String>[];
    String norm(Object? s) => '${s ?? ''}'.trim().toLowerCase();
    for (final a in fiche.objetsARecevoir) {
      Equipement? modele;
      if (a.objet['catalogue'] == true) {
        for (final e in catalogue) {
          if (norm(e.nom) == norm(a.objet['nom'])) modele = e;
        }
      }
      final objet = modele != null
          ? (ObjetDuCatalogue.depuis(modele)
            ..equipe = a.objet['equipe'] == true)
          : Objet.depuisJson({
              'nom': 'Objet',
              ...a.objet,
              'id': Objet.nouvelId(),
            });
      objet
        ..origine = a.raciale ? OrigineObjet.race : OrigineObjet.classe
        ..precisionOrigine = a.competence
        ..donnePar = a.cle;
      final texte = descriptions[a.cle]?.trim() ?? '';
      if (texte.isNotEmpty) {
        objet.description =
            objet.description.isEmpty ? texte : '$texte\n${objet.description}';
      }
      p.inventaire.add(objet);
      p.objetsRecus.add(a.cle);
      p.journaliser(
        'Objet reçu : ${objet.nom} (${a.competence})',
        categorie: CategorieHistorique.inventaire,
        maintenant: maintenant,
      );
      recus.add(objet.nom);
    }
    return recus;
  }
}
