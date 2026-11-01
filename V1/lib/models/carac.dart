/// Caractéristiques principales (stats innées).
/// Source : ressources/stats.txt et ressources/01_REGLES_GENERALES.md §2.1.
enum Carac {
  adc('ADC', 'AdC', 'Aptitude de combat'),
  adt('ADT', 'AdT', 'Aptitude de tir'),
  adm('ADM', 'AdM', 'Aptitude magique'),
  force('FOR', 'FOR', 'Force'),
  dex('DEX', 'DEX', 'Dextérité'),
  con('CON', 'CON', 'Constitution'),
  intel('INT', 'INT', 'Intelligence'),
  per('PER', 'PER', 'Perception'),
  soc('SOC', 'SOC', 'Social'),
  // Ancien Charisme (CHA), renommé le 29/10/2026 : force mentale,
  // conviction, résistance à l'intimidation, aux contrôles mentaux et à la
  // peur.
  men('MEN', 'MEN', 'Mental'),
  chan('CHAN', 'CHAN', 'Chance');

  const Carac(this.code, this.abrev, this.nom);

  /// Clé utilisée dans les fichiers JSON (assets et sauvegardes).
  final String code;

  /// Abréviation affichée à l'écran.
  final String abrev;

  /// Nom complet.
  final String nom;

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
