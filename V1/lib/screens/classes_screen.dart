import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/classe.dart';
import '../models/equipement.dart';
import '../regles/inventaire.dart';
import '../theme.dart';
import '../widgets/carte_selection.dart';
import '../widgets/consultation.dart';
import '../widgets/liste_detail.dart';
import '../widgets/maitrises_restrictions.dart';
import '../widgets/profil_classe.dart';
import '../widgets/voie_detail.dart';

String _texteModif(ModifDe m) => switch (m) {
      ModifDe.plus => '+ (dé supérieur à celui de la race)',
      ModifDe.moins => '− (dé inférieur à celui de la race)',
      ModifDe.egal => '= (dé de la race inchangé)',
    };

/// Page « Classes » : liste des classes ; sur grand écran, le détail de la
/// classe choisie s'affiche à droite de la liste (voir `ListeDetail`).
class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key, required this.referentiel});

  final Referentiel referentiel;
  @override
  Widget build(BuildContext context) {
    final classes = referentiel.classes;
    return Scaffold(
      // Onglet du Glossaire : titre, menu et onglets sont dans GlossaireScreen.
      body: classes.isEmpty
          ? const Center(child: TexteAVenir('Aucune classe disponible.'))
          : ListeDetail<Classe>(
              elements: classes,
              nom: (c) => c.nom,
              sousTitre: (c) => '${c.profil.libelle} · '
                  'Vie ${c.modifDeVie.symbole} · '
                  '${c.aDuMana ? 'Mana ${c.modifDeMana.symbole}' : 'Sans mana'} · '
                  '${c.aDeLEndurance ? 'Endurance ${c.modifDeEndurance.symbole}' : 'Sans endurance'} · '
                  '${c.voies.length} voies',
              contenu: (c) => InfosClasse(c),
              couleurAvatar: (c) =>
                  couleurProfil(c.profil, Theme.of(context).brightness),
              detail: (c) => ClasseDetail(
                classe: c,
                equipements: referentiel.equipements,
              ),
            ),
    );
  }
}

/// Détail d'une classe : description, dés, maîtrises, restrictions, voies.
class ClasseDetail extends StatelessWidget {
  const ClasseDetail({
    super.key,
    required this.classe,
    this.equipements = const [],
  });

  final Classe classe;

  /// Catalogue, pour nommer les objets de l'inventaire de base.
  final List<Equipement> equipements;

  @override
  Widget build(BuildContext context) {
    final c = classe;
    final inventaire = ObjetDuCatalogue.inventaireBase(c, equipements);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BlocConsultation(
          titre: 'Description',
          icone: Icons.description_outlined,
          children: [
            if (c.description.isNotEmpty)
              Text(c.description)
            else
              const TexteAVenir('Description à venir.'),
            // Lanceurs de sorts : origine du pouvoir, en petit italique.
            if (c.originePouvoir.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      c.originePouvoir,
                      key: const Key('origine-pouvoir'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        BlocConsultation(
          titre: 'Modificateurs',
          icone: Icons.tune,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: EtiquetteProfil(c.profil),
            ),
            const SizedBox(height: 4),
            _LigneDe(
              curseur: CurseurDe(
                icone: Icons.favorite,
                couleur: couleurVie(Theme.of(context).brightness),
                modif: c.modifDeVie,
                nomDe: 'Dé de vie',
              ),
              texte: 'Dé de vie ${_texteModif(c.modifDeVie)}',
            ),
            _LigneDe(
              curseur: curseursRessources(c, Theme.of(context).brightness)[0],
              texte: c.aDuMana
                  ? 'Dé de mana ${_texteModif(c.modifDeMana)}'
                  : 'Pas de dé de mana : pas de PM',
            ),
            _LigneDe(
              curseur: curseursRessources(c, Theme.of(context).brightness)[1],
              texte: c.aDeLEndurance
                  ? "Dé d'endurance ${_texteModif(c.modifDeEndurance)}"
                  : "Pas de dé d'endurance : pas de PE",
            ),
            LigneDetail(
              libelle: 'Overdose magique',
              texte: c.lanceurDeSorts
                  ? 'possible (classe de mage)'
                  : 'non (ne dépend pas du mana)',
            ),
          ],
        ),
        BlocConsultation(
          titre: 'Maîtrises et restrictions',
          icone: Icons.gavel_outlined,
          children: [MaitrisesRestrictions(classe: c)],
        ),
        if (inventaire.isNotEmpty)
          BlocConsultation(
            key: const Key('inventaire-base-classe'),
            titre: 'Inventaire de base',
            icone: Icons.backpack_outlined,
            children: [
              Text(
                'Reçu à la création du personnage (case à cocher du '
                'récapitulatif).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              for (final o in inventaire)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '• ${o.quantite > 1 ? '${o.nom} ×${o.quantite}' : o.nom}',
                  ),
                ),
            ],
          ),
        if (c.note.isNotEmpty)
          BlocConsultation(
            titre: 'À savoir',
            icone: Icons.lightbulb_outline,
            children: [Text(c.note)],
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Text(
            'Compétences (${c.voies.length} voies)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        for (final v in c.voies)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: VoieDetail(voie: v),
          ),
      ],
    );
  }
}

/// Détail en page entière (téléphone, ou ouverture directe).
class ClasseDetailScreen extends StatelessWidget {
  const ClasseDetailScreen({super.key, required this.classe});

  final Classe classe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          classe.nom,
          style: const TextStyle(fontFamily: kPoliceAmbiance),
        ),
      ),
      body: LargeurLimitee(child: ClasseDetail(classe: classe)),
    );
  }
}

/// Ligne « curseur à 3 crans + explication » du détail d'une classe.
class _LigneDe extends StatelessWidget {
  const _LigneDe({required this.curseur, required this.texte});

  final Widget curseur;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          SizedBox(width: 64, child: curseur),
          const SizedBox(width: 8),
          Expanded(child: Text(texte)),
        ],
      ),
    );
  }
}
