import '../models/classe.dart';
import '../models/creature.dart';
import '../models/race.dart';
import '../models/voie.dart';

/// Mots qui signalent une affliction dans le texte d'une compétence ou d'une
/// attaque de créature (sans accents, en minuscules).
const Map<String, List<String>> _motsAffliction = {
  'Ralenti': ['ralenti'],
  'Aveuglement léger': ['aveugl'],
  'Aveuglement grave': ['aveugl'],
  'Étourdi': ['etourdi'],
  'Immobilisation': ['immobilis'],
  'Réduit au silence': ['reduit au silence', 'silence'],
  'Réduit au silence magique': ['silence magique', 'lancer de sort'],
  'Empoisonné': ['empoisonn', 'poison'],
  'En feu': ['enflamm', 'en feu', 'brulure'],
  'Saignement': ['saign'],
  'Effrayé': ['effray', 'terreur', 'peur'],
  'À terre': ['a terre', 'renvers', 'au sol'],
  'Assourdi': ['assourd'],
  'Endormi': ['endorm', 'sommeil'],
  'Paralysé': ['paralys'],
  'Affaibli': ['affaibli'],
  'Charmé': ['charm'],
};

/// Le mot est présent, et pas juste après « insensible », « immunisé » ou
/// « résiste », « libéré », « débloque » dans la même phrase (une protection
/// ou une fabrication, pas une cause).
bool _present(String t, String mot) {
  var i = t.indexOf(mot);
  while (i >= 0) {
    // Même phrase : depuis le dernier point ou point-virgule.
    final debut = [t.lastIndexOf('.', i), t.lastIndexOf(';', i)]
            .reduce((a, b) => a > b ? a : b) +
        1;
    final avant = t.substring(debut, i);
    if (!const ['insensible', 'immun', 'resist', 'libere', 'debloque']
        .any(avant.contains)) {
      return true;
    }
    i = t.indexOf(mot, i + mot.length);
  }
  return false;
}

String _norm(String t) {
  const accents = {
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'ô': 'o',
    'ö': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
  };
  final b = StringBuffer();
  for (final r in t.toLowerCase().runes) {
    final ch = String.fromCharCode(r);
    b.write(accents[ch] ?? ch);
  }
  return b.toString();
}

/// Ce qui peut causer chaque affliction, d'après le texte des compétences
/// (classes, voies raciales) et des attaques du bestiaire : « Barde · Chant
/// envoûtant », « Harpie (Chant envoûtant) ». Recherche par mots-clés : une
/// indication, pas une règle.
Map<String, List<String>> causesAfflictions({
  required List<Classe> classes,
  required List<Race> races,
  required List<Creature> creatures,
}) {
  final res = {for (final a in _motsAffliction.keys) a: <String>[]};
  void chercher(String texte, String source) {
    final t = _norm(texte);
    for (final e in _motsAffliction.entries) {
      if (e.value.any((m) => _present(t, m)) && !res[e.key]!.contains(source)) {
        res[e.key]!.add(source);
      }
    }
  }

  String texteCompetence(Competence c) => [
        c.effet,
        for (final e in c.effets) e.libelle,
      ].join(' ');

  for (final c in classes) {
    for (final v in c.voies) {
      for (final k in v.competences) {
        chercher(texteCompetence(k), '${c.nom} · ${k.nom}');
      }
    }
  }
  for (final r in races) {
    for (final k in r.voieRaciale?.competences ?? const <Competence>[]) {
      chercher(texteCompetence(k), '${r.nom} · ${k.nom}');
    }
  }
  for (final c in creatures) {
    for (final a in c.attaques) {
      chercher('${a.nom} ${a.note}', '${c.nom} (${a.nom})');
    }
  }
  return res;
}
