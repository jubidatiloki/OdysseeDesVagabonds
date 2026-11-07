import 'dart:math';

import '../models/affliction.dart';
import '../models/effet.dart';
import '../models/equipement.dart';
import '../models/objet.dart';
import 'inventaire.dart';

/// Puissance voulue par le MJ (règle du 07/11/2026). Son palier donne le
/// bonus : +1, +2 ou +3.
enum PuissanceObjet {
  hasard('Au hasard', 0),
  faible('Faible', 1),
  moyen('Moyen', 2),
  fort('Fort', 3);

  const PuissanceObjet(this.libelle, this.palier);
  final String libelle;
  final int palier;
}

/// Objet personnalisé tiré par le MJ (règles du 07/11/2026) : une arme, une
/// armure ou un bouclier du [catalogue], avec un bonus selon la [puissance].
/// Protections : CA +1, +2 ou +3. Armes : faible, toucher ou dégâts +1 ;
/// moyen, toucher ou dégâts +2, ou dégâts de feu, glace ou foudre ; fort,
/// toucher ou dégâts +3, ou une affliction. `null` : rien à tirer.
Objet? tirerObjetAleatoire(
  List<Equipement> catalogue,
  Random aleatoire, {
  PuissanceObjet puissance = PuissanceObjet.hasard,
}) {
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
  final palier = puissance == PuissanceObjet.hasard
      ? 1 + aleatoire.nextInt(3)
      : puissance.palier;
  if (o.categorie.protection) {
    o
      ..bonusCA += palier
      ..nom = '${o.nom} +$palier';
    return o;
  }
  // Toucher, dégâts, puis l'effet réservé au palier (aucun au palier 1).
  switch (aleatoire.nextInt(palier == 1 ? 2 : 3)) {
    case 0:
      o
        ..effets = [...o.effets, Effet(type: 'toucher', valeur: '$palier')]
        ..nom = '${o.nom} de précision +$palier';
    case 1:
      o
        ..effets = [...o.effets, Effet(type: 'degats', valeur: '$palier')]
        ..nom = '${o.nom} de puissance +$palier';
    default:
      if (palier == 2) {
        const elements = ['feu', 'glace', 'foudre'];
        o
          ..element = elements[aleatoire.nextInt(elements.length)]
          ..nom = '${o.nom} de ${o.element}';
      } else {
        final a = kAfflictions[aleatoire.nextInt(kAfflictions.length)];
        o
          ..affliction = a.nom
          ..nom = '${o.nom} (${a.nom})';
      }
  }
  return o;
}
