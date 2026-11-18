import '../regles/des.dart';
import 'seance.dart';
import 'carac.dart';

/// Jets sur lesquels porte un bonus de séance.
enum PorteeBonus {
  attaque('Jets d\'attaque', 'aux attaques'),
  tous('Tous les jets à 1d20', 'à tous les jets'),
  initiative('Initiative', 'à l\'initiative'),
  carac('Tests d\'une caractéristique', 'aux tests'),
  degats('Dégâts', 'aux dégâts');

  const PorteeBonus(this.libelle, this.suffixe);

  final String libelle;

  /// Fin de phrase : « +2 aux attaques ».
  final String suffixe;

  static PorteeBonus depuisCode(Object? code) => PorteeBonus.values
      .firstWhere((p) => p.name == code, orElse: () => PorteeBonus.tous);
}

/// Durée d'un bonus de séance, choisie par celui qui le donne (selon sa
/// compétence ou son sort).
enum DureeBonus {
  finCombat('Jusqu\'à la fin du combat', 'fin du combat'),
  tours('Pendant quelques tours', 'tours'),
  actions('Pendant quelques actions', 'actions'),
  minutes('Pendant quelques minutes', 'minutes'),
  heures('Pendant quelques heures', 'heures'),
  jours('Pendant quelques jours', 'jours'),
  finSeance('Jusqu\'à la fin de la séance', 'fin de la séance'),
  retrait('Jusqu\'à ce qu\'on le retire', 'jusqu\'au retrait');

  const DureeBonus(this.libelle, this.court);

  final String libelle;
  final String court;

  static DureeBonus depuisCode(Object? code) => DureeBonus.values
      .firstWhere((d) => d.name == code, orElse: () => DureeBonus.retrait);
}

/// Bonus ou malus donné pendant une séance à un ou plusieurs personnages
/// (musique vivifiante du barde, embuscade, sort qui affaiblit…), le
/// 18/11/2026. Il s'ajoute tout seul à leurs jets, comme une situation
/// cochée, mais eux ne peuvent pas le retirer : seuls celui qui l'a donné et
/// le MJ le peuvent.
class BonusSeance {
  const BonusSeance({
    this.id = '',
    required this.nom,
    required this.valeur,
    required this.portee,
    this.carac,
    required this.cibles,
    required this.auteur,
    required this.auteurNom,
    required this.duree,
    this.toursRestants,
    required this.seance,
    required this.date,
  });

  final String id;
  final String nom;

  /// Positif : bonus ; négatif : malus.
  final int valeur;
  final PorteeBonus portee;

  /// Caractéristique visée ([PorteeBonus.carac]).
  final Carac? carac;

  /// uid des joueurs qui le reçoivent.
  final List<String> cibles;

  /// uid de celui qui l'a donné (joueur ou MJ) et son nom affiché.
  final String auteur;
  final String auteurNom;
  final DureeBonus duree;

  /// [DureeBonus.tours] : tours restants (un de moins à chaque manche) ;
  /// [DureeBonus.actions] : jets restants (un de moins à chaque jet où il
  /// compte) ; [DureeBonus.jours] : jours (retiré par son auteur ou le MJ).
  final int? toursRestants;

  /// Numéro de la séance où il a été donné.
  final int seance;
  final DateTime date;

  String get _valeurTexte => valeur >= 0 ? '+$valeur' : '−${-valeur}';

  /// « +2 aux attaques », « −1 aux tests de FOR ».
  String get effet => portee == PorteeBonus.carac && carac != null
      ? '$_valeurTexte aux tests de ${carac!.abrev}'
      : '$_valeurTexte ${portee.suffixe}';

  /// « fin du combat », « 3 tours », « jusqu'au retrait ».
  String get dureeTexte {
    final n = toursRestants ?? 0;
    final s = n > 1 ? 's' : '';
    return switch (duree) {
      DureeBonus.tours => '$n tour$s',
      DureeBonus.actions => '$n action$s',
      DureeBonus.minutes => '$n minute$s',
      DureeBonus.heures => '$n heure$s',
      DureeBonus.jours => '$n jour$s',
      _ => duree.court,
    };
  }

  /// Ce bonus compte-t-il pour ce jet ?
  bool compte({
    required GenreJet genre,
    required bool d20,
    required bool degats,
    Carac? carac,
    bool initiative = false,
  }) =>
      switch (portee) {
        PorteeBonus.attaque => genre == GenreJet.attaque,
        PorteeBonus.tous => d20 && !degats,
        PorteeBonus.initiative => initiative,
        PorteeBonus.carac => d20 && carac != null && carac == this.carac,
        PorteeBonus.degats => degats,
      };

  /// Bonus d'une liste qui comptent pour un jet de [cible] ; deux bonus du
  /// même nom ne se cumulent pas, seul le plus fort compte (règle validée le
  /// 18/11/2026).
  static List<BonusSituation> applicables(
    Iterable<BonusSeance> tous,
    String cible, {
    required GenreJet genre,
    required bool d20,
    required bool degats,
    Carac? carac,
    bool initiative = false,
  }) =>
      [
        for (final b in retenus(
          tous,
          cible,
          genre: genre,
          d20: d20,
          degats: degats,
          carac: carac,
          initiative: initiative,
        ))
          (nom: b.nom, valeur: b.valeur),
      ];

  /// Les bonus retenus pour ce jet (le plus fort par nom).
  static List<BonusSeance> retenus(
    Iterable<BonusSeance> tous,
    String cible, {
    required GenreJet genre,
    required bool d20,
    required bool degats,
    Carac? carac,
    bool initiative = false,
  }) {
    final parNom = <String, BonusSeance>{};
    for (final b in tous) {
      if (!b.cibles.contains(cible) ||
          !b.compte(
            genre: genre,
            d20: d20,
            degats: degats,
            carac: carac,
            initiative: initiative,
          )) {
        continue;
      }
      final cle = b.nom.trim().toLowerCase();
      final deja = parNom[cle];
      if (deja == null || b.valeur.abs() > deja.valeur.abs()) parNom[cle] = b;
    }
    return parNom.values.toList();
  }

  BonusSeance copie({String? id, int? toursRestants}) => BonusSeance(
        id: id ?? this.id,
        nom: nom,
        valeur: valeur,
        portee: portee,
        carac: carac,
        cibles: cibles,
        auteur: auteur,
        auteurNom: auteurNom,
        duree: duree,
        toursRestants: toursRestants ?? this.toursRestants,
        seance: seance,
        date: date,
      );

  Map<String, dynamic> versJson() => {
        'nom': nom,
        'valeur': valeur,
        'portee': portee.name,
        if (carac != null) 'carac': carac!.code,
        'cibles': cibles,
        'auteur': auteur,
        'auteurNom': auteurNom,
        'duree': duree.name,
        if (toursRestants != null) 'toursRestants': toursRestants,
        'seance': seance,
        'date': date.toIso8601String(),
      };

  factory BonusSeance.depuisJson(String id, Map<String, dynamic> j) =>
      BonusSeance(
        id: id,
        nom: j['nom'] as String? ?? 'Bonus',
        valeur: (j['valeur'] as num?)?.toInt() ?? 0,
        portee: PorteeBonus.depuisCode(j['portee']),
        carac: Carac.depuisCode(j['carac'] as String? ?? ''),
        cibles: [for (final c in j['cibles'] as List? ?? const []) '$c'],
        auteur: j['auteur'] as String? ?? '',
        auteurNom: j['auteurNom'] as String? ?? '',
        duree: DureeBonus.depuisCode(j['duree']),
        toursRestants: (j['toursRestants'] as num?)?.toInt(),
        seance: (j['seance'] as num?)?.toInt() ?? 0,
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime(2026),
      );
}
