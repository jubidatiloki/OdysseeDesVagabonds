import 'dart:math';

/// Une proposition d'écuyer (Écuyer du chevalier, rang 3).
typedef PropositionEcuyer = ({String nom, String description, String texte});

/// Séparateur entre le nom et la description dans la précision gardée
/// (« Aubin — 14 ans, … »).
const String separateurEcuyer = ' — ';

const _prenomsGarcons = [
  'Aubin',
  'Bertrand',
  'Colin',
  'Denis',
  'Enguerrand',
  'Firmin',
  'Gautier',
  'Hugues',
  'Jehan',
  'Lancelin',
  'Mathurin',
  'Odon',
  'Perceval',
  'Raoul',
  'Thibaut',
  'Yvain',
  'Gaspard',
  'Robin',
  'Tristan',
  'Godric',
];
const _prenomsFilles = [
  'Aliénor',
  'Blanche',
  'Clémence',
  'Douce',
  'Ermengarde',
  'Gisèle',
  'Héloïse',
  'Isaure',
  'Jehanne',
  'Mahaut',
  'Ombeline',
  'Pernelle',
  'Sibylle',
  'Ysolde',
  'Aude',
  'Berthe',
];
const _origines = [
  'du Moulin',
  'de la Forge',
  'des Prés',
  'du Gué',
  'de Bellerive',
  'le Roux',
  'Courtecuisse',
  'de Montclair',
  'Boisvert',
  'de la Tour',
  'Petitpas',
  'Hautecombe',
];
const _cheveux = [
  'cheveux roux en bataille',
  'cheveux blonds coupés au bol',
  'longs cheveux bruns noués',
  'cheveux noirs et bouclés',
  'crâne rasé de près',
  'mèche châtain qui tombe dans les yeux',
  'cheveux paille hirsutes',
];

/// (masculin, féminin).
const _silhouettes = [
  ('maigre et dégingandé', 'maigre et dégingandée'),
  ('petit et trapu', 'petite et trapue'),
  ('grand pour son âge', 'grande pour son âge'),
  ('rond et jovial', 'ronde et joviale'),
  ('vif et nerveux', 'vive et nerveuse'),
  ('robuste, aux larges épaules', 'robuste, aux larges épaules'),
  ('frêle mais endurant', 'frêle mais endurante'),
];
const _signes = [
  'des taches de rousseur plein le visage',
  'une cicatrice au menton',
  'un nez cassé mal remis',
  'des yeux vairons',
  'un sourire édenté',
  'des mains calleuses de paysan',
  'un regard sérieux qui ne cille pas',
  'une voix qui mue encore',
  'une oreille un peu décollée',
];

/// Trois propositions d'écuyer pour le personnage [graine] (son id) :
/// toujours les mêmes pour un même personnage, pour que la liste ne change
/// pas d'un écran à l'autre. Noms et descriptions physiques variés.
List<PropositionEcuyer> propositionsEcuyer(String graine, {int nombre = 3}) {
  var h = 0;
  for (final c in graine.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  final r = Random(h);
  T tirer<T>(List<T> l) => l[r.nextInt(l.length)];
  final res = <PropositionEcuyer>[];
  final noms = <String>{};
  while (res.length < nombre) {
    final fille = r.nextInt(3) == 0;
    final nom =
        '${tirer(fille ? _prenomsFilles : _prenomsGarcons)} ${tirer(_origines)}';
    if (!noms.add(nom)) continue;
    final age = 12 + r.nextInt(6);
    final s = tirer(_silhouettes);
    final silhouette = fille ? s.$2 : s.$1;
    final description = '$age ans, $silhouette, ${tirer(_cheveux)}, '
        '${tirer(_signes)}.';
    res.add((
      nom: nom,
      description: description,
      texte: '$nom$separateurEcuyer$description',
    ));
  }
  return res;
}

/// « Aubin du Moulin — 14 ans, … » → nom et description.
({String nom, String description}) lireEcuyer(String texte) {
  final i = texte.indexOf(separateurEcuyer);
  if (i < 0) return (nom: texte.trim(), description: '');
  return (
    nom: texte.substring(0, i).trim(),
    description: texte.substring(i + separateurEcuyer.length).trim(),
  );
}
