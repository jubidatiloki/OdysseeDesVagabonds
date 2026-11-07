import 'dart:math';

import '../models/affliction.dart';
import '../models/effet.dart';
import '../models/equipement.dart';
import '../models/objet.dart';
import 'inventaire.dart';

/// Objet personnalisé tiré par le MJ (règle du 07/11/2026) : une arme, une
/// armure ou un bouclier du [catalogue], avec un bonus au hasard. Armes :
/// toucher ou dégâts de +1 à +3, dégâts de feu, glace ou foudre, ou une
/// affliction. Protections : CA de +1 à +3. `null` : rien à tirer.
Objet? tirerObjetAleatoire(List<Equipement> catalogue, Random aleatoire) {
  final objets = [
    for (final e in catalogue)
      if (ObjetDuCatalogue.depuis(e) case final o
          when o.categorie == CategorieObjet.arme || o.categorie.protection)
        o,
  ];
  if (objets.isEmpty) return null;
  final o = objets[aleatoire.nextInt(objets.length)]
    ..duCatalogue = false
    ..personnalise = true;
  final bonus = 1 + aleatoire.nextInt(3);
  if (o.categorie.protection) {
    o
      ..bonusCA += bonus
      ..nom = '${o.nom} +$bonus';
    return o;
  }
  switch (aleatoire.nextInt(4)) {
    case 0:
      o
        ..effets = [...o.effets, Effet(type: 'toucher', valeur: '$bonus')]
        ..nom = '${o.nom} de précision +$bonus';
    case 1:
      o
        ..effets = [...o.effets, Effet(type: 'degats', valeur: '$bonus')]
        ..nom = '${o.nom} de puissance +$bonus';
    case 2:
      const elements = ['feu', 'glace', 'foudre'];
      o
        ..element = elements[aleatoire.nextInt(elements.length)]
        ..nom = '${o.nom} de ${o.element}';
    default:
      final a = kAfflictions[aleatoire.nextInt(kAfflictions.length)];
      o
        ..affliction = a.nom
        ..nom = '${o.nom} (${a.nom})';
  }
  return o;
}
