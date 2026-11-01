import 'package:flutter/material.dart';

import '../theme.dart';

/// Un type de compétence reconnu dans le texte « type » des données
/// (« actif complexe, compétence », « passif + renforcement », « sort »…).
/// Vocabulaire des règles, §4.1 « Types de compétence ».
class TypeCompetence {
  const TypeCompetence(this.libelle, this.icone, this.couleur, this.aide);

  final String libelle;
  final IconData icone;
  final Color couleur;

  /// Explication affichée au survol / appui long.
  final String aide;
}

const _passif = TypeCompetence('Passif', Icons.all_inclusive,
    OdvCouleurs.texteSecondaire, 'Passif : effet permanent');
const _actif = TypeCompetence('Actif', Icons.touch_app_outlined,
    OdvCouleurs.accentClair, 'Actif : à utiliser');
const _sort = TypeCompetence('Sort', Icons.auto_awesome, OdvCouleurs.lightBlue,
    'Sort : consomme du mana');
const _competence = TypeCompetence('Compétence', Icons.fitness_center,
    OdvCouleurs.texteSecondaire, 'Compétence : ne consomme pas de mana');
const _complexe = TypeCompetence('Complexe', Icons.hourglass_bottom,
    OdvCouleurs.lightRed, 'Action complexe : prend tout le tour (3 PA)');
const _gratuite = TypeCompetence('Gratuite', Icons.bolt, OdvCouleurs.or,
    'Action gratuite : ne consomme pas d\'action (0 PA)');
const _mouvement = TypeCompetence('Mouvement', Icons.directions_run,
    OdvCouleurs.texteSecondaire, 'Action de mouvement (1 PA)');
const _renforcement = TypeCompetence('Renforcement', Icons.add_circle_outline,
    OdvCouleurs.lightGreen, 'Renforcement : ajoute un effet à une action');
const _amelioration = TypeCompetence(
    'Amélioration',
    Icons.upgrade,
    OdvCouleurs.lightGreen,
    'Amélioration : améliore une compétence déjà apprise');
const _soutien = TypeCompetence(
    'Soutien',
    Icons.pets_outlined,
    OdvCouleurs.lightGreen,
    'Soutien : donne une monture, un familier ou un objet');
const _maintenu = TypeCompetence('Maintenu', Icons.autorenew,
    OdvCouleurs.lightBlue, 'Maintenu : coûte du mana à chaque tour');
const _objet = TypeCompetence('Objet', Icons.backpack_outlined,
    OdvCouleurs.lightGreen, 'Objet : ajouté à l\'inventaire');
const _fabrication = TypeCompetence('Fabrication', Icons.handyman_outlined,
    OdvCouleurs.or, 'Fabrication : objets à fabriquer depuis l\x27inventaire');
const _usageUnique = TypeCompetence('Usage unique', Icons.looks_one_outlined,
    OdvCouleurs.or, 'Usage unique : ne sert qu\'une fois');

/// Découpe le texte « type » en types reconnus, dans un ordre stable.
List<TypeCompetence> analyserTypeCompetence(String type) {
  final t = type.toLowerCase();
  final res = <TypeCompetence>[];
  if (t.contains('passif')) res.add(_passif);
  if (t.contains('actif') || t.trim() == 'action') res.add(_actif);
  if (RegExp(r'\bsort\b').hasMatch(t)) {
    res.add(_sort);
  } else if (t.contains('compétence')) {
    res.add(_competence);
  }
  if (t.contains('complexe')) res.add(_complexe);
  if (t.contains('gratuit')) res.add(_gratuite);
  if (t.contains('mouvement')) res.add(_mouvement);
  if (t.contains('renforcement')) res.add(_renforcement);
  if (t.contains('amélioration')) res.add(_amelioration);
  if (t.contains('soutien')) res.add(_soutien);
  if (t.contains('maintenu') || t.contains('maintien')) res.add(_maintenu);
  if (RegExp(r'\bobjet\b').hasMatch(t)) res.add(_objet);
  if (t.contains('usage unique')) res.add(_usageUnique);
  if (t.contains('fabrication')) res.add(_fabrication);
  if (t.contains('hors combat')) {
    res.add(const TypeCompetence('Hors combat', Icons.forum_outlined,
        OdvCouleurs.lightBlue, 'À utiliser hors combat'));
  } else if (t.contains('en combat')) {
    res.add(const TypeCompetence('En combat', Icons.sports_martial_arts,
        OdvCouleurs.lightRed, 'À utiliser en combat'));
  }
  // « 1×/jour », « 2×/jour » (rage aux niveaux 2 et 3).
  final limite = RegExp(r'(\d+)×/\s*(\w+)').firstMatch(t);
  if (limite != null) {
    final n = limite.group(1)!;
    res.add(TypeCompetence(
        '$n×/${limite.group(2)}',
        Icons.event_repeat,
        OdvCouleurs.or,
        'Utilisable ${n == '1' ? 'une fois' : '$n fois'} '
            'par ${limite.group(2)}'));
  }
  final cout = RegExp(r'coût rang (\d)').firstMatch(t);
  if (cout != null) {
    res.add(TypeCompetence(
        'Coût rang ${cout.group(1)}',
        Icons.water_drop,
        OdvCouleurs.lightBlue,
        'Coût en mana d\'un sort de rang ${cout.group(1)}'));
  }
  return res;
}

/// Petite étiquette « icône + libellé » d'un type de compétence.
class EtiquetteType extends StatelessWidget {
  const EtiquetteType(this.type, {super.key});

  final TypeCompetence type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sombre = theme.brightness == Brightness.dark;
    // Sur le parchemin, les teintes claires manquent de contraste : on
    // utilise la couleur du texte secondaire pour le libellé.
    final couleur = sombre ? type.couleur : theme.colorScheme.onSurfaceVariant;
    return Tooltip(
      message: type.aide,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: type.couleur.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icone, size: 12, color: type.couleur),
            const SizedBox(width: 3),
            Text(
              type.libelle,
              style: theme.textTheme.labelSmall?.copyWith(color: couleur),
            ),
          ],
        ),
      ),
    );
  }
}
