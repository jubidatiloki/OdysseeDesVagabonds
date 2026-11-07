/// Caractéristiques principales (stats innées).
/// Source : ressources/stats.txt et ressources/01_REGLES_GENERALES.md §2.1.
enum Carac {
  adc('ADC', 'AdC', 'Aptitude de combat',
      'Maîtrise du combat rapproché : augmente les chances de toucher au corps à corps.'),
  adt('ADT', 'AdT', 'Aptitude de tir',
      'Maîtrise des armes à distance : augmente les chances de toucher à distance.'),
  adm('ADM', 'AdM', 'Aptitude magique',
      'Maîtrise des sorts et de la magie : augmente les chances de toucher avec les sorts.'),
  force('FOR', 'FOR', 'Force',
      'Puissance musculaire : augmente les dégâts au corps à corps, sert à soulever ou immobiliser.'),
  dex('DEX', 'DEX', 'Dextérité',
      'Agilité, précision et vitesse : donne l\'initiative, sert aux acrobaties, au crochetage et à la discrétion.'),
  con('CON', 'CON', 'Constitution',
      'Endurance et résistance : augmente les points de vie, sert contre le poison et la fatigue.'),
  intel('INT', 'INT', 'Intelligence',
      'Connaissances et maîtrise de la magie : sert à se souvenir, à connaître et à apprendre.'),
  per('PER', 'PER', 'Perception',
      'Capacité à percevoir : sert à détecter pièges et embuscades, à trouver un objet ou une personne.'),
  soc('SOC', 'SOC', 'Social',
      'Aisance à communiquer : sert à baratiner, bluffer, convaincre, mentir ou obtenir une information.'),
  // Ancien Charisme (CHA), renommé le 29/10/2026 : force mentale,
  // conviction, résistance à l'intimidation, aux contrôles mentaux et à la
  // peur.
  men('MEN', 'MEN', 'Mental',
      'Force mentale et conviction : sert à résister à l\'intimidation, aux contrôles mentaux et à la peur.'),
  chan('CHAN', 'CHAN', 'Chance',
      'Hasard pur, hors compétences : cette statistique n\'est pas lancée et vaut 10 par défaut.');

  const Carac(this.code, this.abrev, this.nom, this.description);

  /// Clé utilisée dans les fichiers JSON (assets et sauvegardes).
  final String code;

  /// Abréviation affichée à l'écran.
  final String abrev;

  /// Nom complet.
  final String nom;

  /// Une phrase d'explication (source : ressources/stats.txt).
  final String description;

  /// « CHA » (ancien Charisme) est lu comme MEN : anciennes sauvegardes.
  static Carac? depuisCode(String code) {
    var c = code.toUpperCase();
    if (c == 'CHA') c = 'MEN';
    for (final v in values) {
      if (v.code == c) return v;
    }
    return null;
  }
}

/// Valeur par défaut d'une caractéristique (la CHAN n'est pas lancée : 10).
const int kValeurCaracParDefaut = 10;

Map<Carac, int> caracMapDepuisJson(Object? json) {
  final res = <Carac, int>{};
  if (json is! Map) return res;
  json.forEach((k, v) {
    final c = Carac.depuisCode(k.toString());
    if (c != null && v is num) res[c] = v.toInt();
  });
  return res;
}

Map<String, int> caracMapVersJson(Map<Carac, int> m) => {
      for (final e in m.entries) e.key.code: e.value,
    };
