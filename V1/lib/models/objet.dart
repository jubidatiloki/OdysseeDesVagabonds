import 'dart:math';

import 'effet.dart';

/// Catégorie d'un objet d'inventaire.
/// [emplacementsMax] : nombre d'objets de cette catégorie portables en même
/// temps (règles §6.1 : 1 casque, 1 armure, 2 bijoux/accessoires).
/// `null` = pas de limite propre (armes et boucliers : limités par les deux
/// mains, voir `ReglesInventaire`) ; 0 = ne s'équipe pas.
enum CategorieObjet {
  arme('Arme', null),
  armure('Armure', 1),
  bouclier('Bouclier', null),
  casque('Casque', 1),
  accessoire('Bijou / accessoire', 2),
  // Extra : porté sans limite ni main (porte-bonheur…).
  extra('Extra', null),
  // Monture : « équipée » = montée (une seule à la fois, sans main).
  monture('Monture', 1),
  // Compagnon (écuyer du chevalier…) : personnage qui suit, sans main.
  compagnon('Compagnon', 0),
  instrument('Instrument de musique', 0),
  consommable('Potion / consommable', 0),
  divers('Objet divers', 0);

  const CategorieObjet(this.libelle, this.emplacementsMax);

  final String libelle;
  final int? emplacementsMax;

  bool get equipable => emplacementsMax != 0;

  /// Catégories qui donnent un bonus de CA.
  bool get protection => this == armure || this == bouclier || this == casque;

  static CategorieObjet depuisCode(String? code) {
    for (final c in values) {
      if (c.name == code) return c;
    }
    return divers;
  }
}

/// Comment le personnage a obtenu un objet. « Race » et « Classe » (objets
/// donnés par la race ou la classe) ne se choisissent pas et ne se modifient
/// pas.
enum OrigineObjet {
  inconnue('Inconnue'),
  achat('Achat'),
  butin('Butin'),
  cadeau('Cadeau'),
  quete('Récompense de quête'),
  fabrication('Fabrication'),
  race('Race'),
  classe('Classe'),
  autre('Autre');

  const OrigineObjet(this.libelle);

  final String libelle;

  /// Donnée par la race ou la classe : non modifiable.
  bool get verrouillee => this == race || this == classe;

  static OrigineObjet depuisCode(String? code) {
    for (final o in values) {
      if (o.name == code) return o;
    }
    return inconnue;
  }
}

/// Matière principale d'un objet (Équipement naturel de l'elfe-sylvain :
/// armes et armures métalliques ou non). « Non précisée » compte comme non
/// métallique.
enum MatiereObjet {
  nonPrecisee('Non précisée'),
  metal('Métal'),
  bois('Bois'),
  cuir('Cuir'),
  tissu('Tissu'),
  autre('Autre');

  const MatiereObjet(this.libelle);

  final String libelle;

  static MatiereObjet depuisCode(String? code) {
    for (final m in values) {
      if (m.name == code) return m;
    }
    return nonPrecisee;
  }
}

/// Poids d'une armure (Légèreté animale du barbare : CA si armure légère ou
/// sans armure).
enum PoidsArmure {
  nonPrecise('Non précisé'),
  legere('Légère'),
  intermediaire('Intermédiaire'),
  lourde('Lourde');

  const PoidsArmure(this.libelle);

  final String libelle;

  static PoidsArmure depuisCode(String? code) {
    for (final p in values) {
      if (p.name == code) return p;
    }
    return nonPrecise;
  }
}

/// Types de dégâts d'une arme (règles §3.2).
const List<String> kTypesDegats = ['tranchant', 'contondant', 'perçant'];

/// Un objet de l'inventaire.
class Objet {
  Objet({
    String? id,
    required this.nom,
    this.categorie = CategorieObjet.divers,
    this.quantite = 1,
    this.description = '',
    this.equipe = false,
    this.degats = '',
    this.typeDegats,
    this.element = '',
    this.affliction = '',
    this.deuxMains = false,
    this.polyvalente = false,
    this.degatsDeuxMains = '',
    this.tenueDeuxMains = false,
    this.distance = false,
    this.bonusCA = 0,
    this.dexMax,
    this.origine = OrigineObjet.inconnue,
    this.precisionOrigine = '',
    this.matiere = MatiereObjet.nonPrecisee,
    this.poidsArmure = PoidsArmure.nonPrecise,
    this.principale = false,
    this.effets = const [],
    this.donnePar = '',
    this.duCatalogue = false,
    this.personnalise = false,
    this.groupeArme = '',
  }) : id = id ?? nouvelId();

  final String id;
  String nom;
  CategorieObjet categorie;
  int quantite;
  String description;

  /// Porté / en main (uniquement pour les catégories équipables).
  bool equipe;

  /// Arme : dés de dégâts (« 1d8 », « 2d6 »…) ; pour une arme
  /// [polyvalente], dégâts quand elle est tenue à une main.
  String degats;

  /// Arme : tranchant, contondant ou perçant.
  String? typeDegats;

  /// Arme à deux mains.
  bool deuxMains;

  /// Arme utilisable à une ou deux mains (ex. bâton : 1d6 / 1d8).
  bool polyvalente;

  /// Arme polyvalente : dégâts quand elle est tenue à deux mains.
  String degatsDeuxMains;

  /// Arme polyvalente : actuellement tenue à deux mains.
  bool tenueDeuxMains;

  /// Arme à distance (arc, pétoire…) ; sinon arme de corps à corps.
  bool distance;

  /// Arme ou bouclier : se tient en main.
  bool get seTientEnMain =>
      categorie == CategorieObjet.arme || categorie == CategorieObjet.bouclier;

  /// Nombre de mains occupées quand l'objet est équipé (0, 1 ou 2).
  int get mains {
    if (!seTientEnMain) return 0;
    if (polyvalente) return tenueDeuxMains ? 2 : 1;
    return deuxMains ? 2 : 1;
  }

  /// Dégâts selon la prise actuelle (deux mains si l'arme polyvalente est
  /// tenue ainsi et que ses dégâts à deux mains sont renseignés).
  String get degatsActuels =>
      polyvalente && tenueDeuxMains && degatsDeuxMains.isNotEmpty
          ? degatsDeuxMains
          : degats;

  /// Armure, bouclier, casque : bonus de CA quand l'objet est porté.
  int bonusCA;

  /// Armure : bonus de DEX maximum à la CA et à l'esquive (cuir +3,
  /// plaques +1) ; `null` : sans limite.
  int? dexMax;

  /// Comment l'objet a été obtenu (« Inconnue » par défaut).
  OrigineObjet origine;

  /// Précision libre (« marchand de Port-Réal », « gobelin du col »).
  String precisionOrigine;

  /// Métal, bois, cuir… (« Non précisée » par défaut).
  MatiereObjet matiere;

  /// Armure : légère, intermédiaire ou lourde.
  PoidsArmure poidsArmure;

  /// Arme principale (attaque au d20) quand deux armes à deux mains sont
  /// maniées (Armement barbare : la secondaire attaque au d12).
  bool principale;

  /// Effets quand l'objet est équipé (porte-bonheur : +2 CHAN).
  List<Effet> effets;

  /// Élément des dégâts d'une arme (feu, glace…) ; vide : physiques.
  String element;

  /// Affliction infligée par l'arme, appliquée par le MJ ; vide : aucune.
  String affliction;

  /// Compétence qui a donné l'objet (« race-gnome/1/Porte-bonheur »).
  String donnePar;

  /// Ajouté depuis le catalogue des équipements.
  bool duCatalogue;

  /// Objet du catalogue ou donné par une compétence dont les attributs ont
  /// été édités (clé à molette à côté du nom).
  bool personnalise;

  /// Groupe de l'arme du catalogue (civile, commune-melee…) ; vide : arme
  /// personnalisée, sans malus de maîtrise.
  String groupeArme;

  /// Attributs non modifiables sans passer par « Éditer l'objet » : objet
  /// du catalogue ou donné par une compétence, pas encore personnalisé
  /// (seules l'origine, sa précision et la quantité changent).
  bool get verrouille => (duCatalogue || donnePar.isNotEmpty) && !personnalise;

  /// Empreinte des attributs (nom, catégorie, dégâts, CA…) : sans la
  /// quantité, l'origine ni l'état porté, pour savoir s'il a été édité.
  String get empreinteAttributs {
    final j = versJson()
      ..remove('id')
      ..remove('quantite')
      ..remove('groupeArme')
      ..remove('equipe')
      ..remove('tenueDeuxMains')
      ..remove('principale')
      ..remove('origine')
      ..remove('precisionOrigine')
      ..remove('donnePar')
      ..remove('duCatalogue')
      ..remove('personnalise');
    return j.toString();
  }

  /// « Butin (gobelin du col) », « Inconnue ».
  String get texteOrigine => precisionOrigine.isEmpty
      ? origine.libelle
      : '${origine.libelle} ($precisionOrigine)';

  static String nouvelId() {
    final t = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final r = Random().nextInt(1000000000).toRadixString(36);
    return 'obj-$t-$r';
  }

  /// Résumé court : « 1d8 tranchant · 2 mains », « 1d6 contondant · tenu à
  /// 1 main », « CA +2 »…
  String get resume {
    final parties = <String>[];
    if (categorie == CategorieObjet.arme) {
      final d = degatsActuels;
      if (d.isNotEmpty) {
        parties.add(
          [
            d,
            if (typeDegats != null) typeDegats,
            if (element.isNotEmpty) element
          ].join(' '),
        );
      }
      if (affliction.isNotEmpty) parties.add(affliction);
      if (distance) parties.add('distance');
      if (polyvalente) {
        parties.add(tenueDeuxMains ? 'tenu à 2 mains' : 'tenu à 1 main');
      } else if (deuxMains) {
        parties.add('2 mains');
      }
    }
    if (categorie == CategorieObjet.bouclier && deuxMains) {
      parties.add('2 mains');
    }
    if (categorie.protection && bonusCA != 0) {
      parties.add('CA ${bonusCA > 0 ? '+' : '−'}${bonusCA.abs()}');
    }
    if (categorie.protection && dexMax != null) {
      parties.add('DEX max ${dexMax! >= 0 ? '+' : '−'}${dexMax!.abs()}');
    }
    return parties.join(' · ');
  }

  Map<String, dynamic> versJson() => {
        'id': id,
        'nom': nom,
        'categorie': categorie.name,
        'quantite': quantite,
        if (groupeArme.isNotEmpty) 'groupeArme': groupeArme,
        if (description.isNotEmpty) 'description': description,
        'equipe': equipe,
        if (degats.isNotEmpty) 'degats': degats,
        if (typeDegats != null) 'typeDegats': typeDegats,
        if (deuxMains) 'deuxMains': true,
        if (polyvalente) 'polyvalente': true,
        if (degatsDeuxMains.isNotEmpty) 'degatsDeuxMains': degatsDeuxMains,
        if (tenueDeuxMains) 'tenueDeuxMains': true,
        if (distance) 'distance': true,
        if (bonusCA != 0) 'bonusCA': bonusCA,
        if (dexMax != null) 'dexMax': dexMax,
        if (origine != OrigineObjet.inconnue) 'origine': origine.name,
        if (precisionOrigine.isNotEmpty) 'precisionOrigine': precisionOrigine,
        if (matiere != MatiereObjet.nonPrecisee) 'matiere': matiere.name,
        if (poidsArmure != PoidsArmure.nonPrecise)
          'poidsArmure': poidsArmure.name,
        if (principale) 'principale': true,
        if (effets.isNotEmpty) 'effets': [for (final e in effets) e.versJson()],
        if (element.isNotEmpty) 'element': element,
        if (affliction.isNotEmpty) 'affliction': affliction,
        if (donnePar.isNotEmpty) 'donnePar': donnePar,
        if (duCatalogue) 'duCatalogue': true,
        if (personnalise) 'personnalise': true,
      };

  factory Objet.depuisJson(Map<String, dynamic> j) => Objet(
        id: j['id'] as String?,
        nom: j['nom'] as String? ?? 'Objet',
        categorie: CategorieObjet.depuisCode(j['categorie'] as String?),
        quantite: (j['quantite'] as num?)?.toInt() ?? 1,
        groupeArme: j['groupeArme'] as String? ?? '',
        description: j['description'] as String? ?? '',
        equipe: j['equipe'] as bool? ?? false,
        degats: j['degats'] as String? ?? '',
        typeDegats: j['typeDegats'] as String?,
        deuxMains: j['deuxMains'] as bool? ?? false,
        polyvalente: j['polyvalente'] as bool? ?? false,
        degatsDeuxMains: j['degatsDeuxMains'] as String? ?? '',
        tenueDeuxMains: j['tenueDeuxMains'] as bool? ?? false,
        distance: j['distance'] as bool? ?? false,
        bonusCA: (j['bonusCA'] as num?)?.toInt() ?? 0,
        dexMax: (j['dexMax'] as num?)?.toInt(),
        origine: OrigineObjet.depuisCode(j['origine'] as String?),
        precisionOrigine: j['precisionOrigine'] as String? ?? '',
        matiere: MatiereObjet.depuisCode(j['matiere'] as String?),
        poidsArmure: PoidsArmure.depuisCode(j['poidsArmure'] as String?),
        principale: j['principale'] as bool? ?? false,
        effets: Effet.listeDepuisJson(j['effets']),
        element: j['element'] as String? ?? '',
        affliction: j['affliction'] as String? ?? '',
        donnePar: j['donnePar'] as String? ?? '',
        duCatalogue: j['duCatalogue'] as bool? ?? false,
        personnalise: j['personnalise'] as bool? ?? false,
      );
}

/// Argent du personnage : pièces d'or, d'argent et de cuivre.
class Bourse {
  Bourse({this.or = 0, this.argent = 0, this.cuivre = 0});

  int or;
  int argent;
  int cuivre;

  bool get vide => or == 0 && argent == 0 && cuivre == 0;

  /// « 10 or, 5 argent » (les montants nuls sont omis).
  String get texte {
    final parties = [
      if (or != 0) '$or or',
      if (argent != 0) '$argent argent',
      if (cuivre != 0) '$cuivre cuivre',
    ];
    return parties.isEmpty ? 'rien' : parties.join(', ');
  }

  Map<String, dynamic> versJson() =>
      {'or': or, 'argent': argent, 'cuivre': cuivre};

  factory Bourse.depuisJson(Object? j) {
    if (j is! Map) return Bourse();
    return Bourse(
      or: (j['or'] as num?)?.toInt() ?? 0,
      argent: (j['argent'] as num?)?.toInt() ?? 0,
      cuivre: (j['cuivre'] as num?)?.toInt() ?? 0,
    );
  }
}
