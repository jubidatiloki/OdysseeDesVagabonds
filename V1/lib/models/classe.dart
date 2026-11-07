import 'univers.dart';
import 'voie.dart';

/// Modification d'un dé (vie, mana ou endurance) par la classe :
/// `+` dé supérieur, `-` dé inférieur, `=` inchangé.
enum ModifDe {
  plus('+'),
  moins('−'),
  egal('=');

  const ModifDe(this.symbole);
  final String symbole;

  static ModifDe depuisSymbole(String? s) {
    switch (s?.trim()) {
      case '+':
        return ModifDe.plus;
      case '-':
      case '−':
        return ModifDe.moins;
      default:
        return ModifDe.egal;
    }
  }
}

/// Profil d'une classe : proportion de magie et de non-magie
/// (physique, lanceur de sorts ou hybride).
enum ProfilClasse {
  physique('physique', 'Physique'),
  lanceur('lanceur', 'Lanceur de sorts'),
  hybride('hybride', 'Hybride');

  const ProfilClasse(this.code, this.libelle);
  final String code;
  final String libelle;

  static ProfilClasse depuisCode(String? code, {bool lanceur = false}) {
    for (final p in values) {
      if (p.code == code) return p;
    }
    return lanceur ? ProfilClasse.lanceur : ProfilClasse.physique;
  }
}

class Classe {
  const Classe({
    required this.id,
    required this.nom,
    required this.modifDeVie,
    required this.modifDeMana,
    this.modifDeEndurance = ModifDe.egal,
    this.lanceurDeSorts = false,
    this.maitrises = '',
    this.restrictionArmure = '',
    this.maitrisesArmes = const [],
    this.armureMax = '',
    this.inventaireBase = const [],
    this.voies = const [],
    this.note = '',
    this.description = '',
    this.originePouvoir = '',
    this.profil = ProfilClasse.physique,
    this.univers = kUniversParDefaut,
  });

  final String id;
  final String nom;
  final ModifDe modifDeVie;
  final ModifDe modifDeMana;

  /// Modification du dé d'endurance (DE) : classes physiques et hybrides.
  final ModifDe modifDeEndurance;

  /// Lanceurs de sorts et hybrides : dé de mana et points de mana (PM).
  /// Les classes physiques n'en ont pas (règle du 03/11/2026).
  bool get aDuMana => lanceurDeSorts || profil != ProfilClasse.physique;

  /// Classes physiques et hybrides : dé d'endurance et points d'endurance
  /// (PE), dépensés par leurs compétences. Les lanceurs n'en ont pas.
  bool get aDeLEndurance => !lanceurDeSorts && profil != ProfilClasse.lanceur;

  /// Druide, magicien, nécromancien, prêtre : lancent des sorts avec mana
  /// et peuvent subir l'overdose magique.
  final bool lanceurDeSorts;

  final String maitrises;
  final String restrictionArmure;

  /// Groupes d'armes maîtrisés (civile, commune, commune-melee,
  /// commune-distance, commune-1-main, poudre, siege) ou mots d'un nom.
  final List<String> maitrisesArmes;

  /// Armure la plus lourde permise : tissu, cuir, mailles ; vide : toutes.
  final String armureMax;

  /// Inventaire proposé à la création : ids du catalogue et quantités.
  final List<({String id, int quantite})> inventaireBase;
  final List<Voie> voies;

  /// Précision de règles propre à la classe (affichée avec les voies).
  final String note;

  /// Présentation de la classe (page Classes).
  final String description;

  /// Lanceurs de sorts : d'où vient leur pouvoir (« Origine du pouvoir :
  /// proximité avec la nature. »), sous la description.
  final String originePouvoir;

  /// Physique, lanceur de sorts ou hybride (affichage).
  final ProfilClasse profil;

  /// Univers de la classe (id, voir `Univers`).
  final String univers;

  Voie? voie(String id) {
    for (final v in voies) {
      if (v.id == id) return v;
    }
    return null;
  }

  factory Classe.depuisJson(Map<String, dynamic> j) => Classe(
        id: j['id'] as String,
        nom: j['nom'] as String,
        modifDeVie: ModifDe.depuisSymbole(j['modifDeVie'] as String?),
        modifDeMana: ModifDe.depuisSymbole(j['modifDeMana'] as String?),
        modifDeEndurance:
            ModifDe.depuisSymbole(j['modifDeEndurance'] as String?),
        lanceurDeSorts: j['lanceurDeSorts'] as bool? ?? false,
        maitrises: j['maitrises'] as String? ?? '',
        restrictionArmure: j['restrictionArmure'] as String? ?? '',
        maitrisesArmes: [
          for (final m in j['maitrisesArmes'] as List? ?? const []) '$m',
        ],
        armureMax: j['armureMax'] as String? ?? '',
        // « "epee-longue" » ou « {"id": "potion", "quantite": 2} ».
        inventaireBase: [
          for (final e in j['inventaireBase'] as List? ?? const [])
            if (e is Map)
              (id: '${e['id']}', quantite: (e['quantite'] as num?)?.toInt() ?? 1)
            else
              (id: '$e', quantite: 1),
        ],
        voies: (j['voies'] as List<dynamic>? ?? const [])
            .map((e) => Voie.depuisJson(e as Map<String, dynamic>))
            .toList(),
        note: j['note'] as String? ?? '',
        description: j['description'] as String? ?? '',
        originePouvoir: j['originePouvoir'] as String? ?? '',
        profil: ProfilClasse.depuisCode(
          j['profil'] as String?,
          lanceur: j['lanceurDeSorts'] as bool? ?? false,
        ),
        univers: universDepuisJson(j['univers']),
      );
}
