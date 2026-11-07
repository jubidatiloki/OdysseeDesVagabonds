/// Journal des versions (écran « Nouveautés »), la plus récente d'abord :
/// une ligne courte par modification. À compléter à chaque changement de
/// version (voir `version.dart` et CLAUDE.md).
library;

/// Nature d'une modification.
enum TypeChangement {
  ajout('Ajout'),
  amelioration('Amélioration'),
  correction('Correction');

  const TypeChangement(this.libelle);
  final String libelle;
}

/// Une modification : sa nature et son résumé.
typedef Changement = ({TypeChangement type, String texte});

/// Une version : numéro, date (jj/mm/aaaa), modifications.
typedef VersionChangelog = ({
  String version,
  String date,
  List<Changement> changements,
});

const _a = TypeChangement.ajout;
const _m = TypeChangement.amelioration;
const _c = TypeChangement.correction;

const List<VersionChangelog> kChangelog = [
  (
    version: '0.38.0',
    date: '08/11/2026',
    changements: [
      (
        type: _m,
        texte: 'Séance : PV des joueurs envoyés en 2 s en combat, 15 s en '
            'exploration.',
      ),
      (
        type: _m,
        texte: 'Séance : présence signalée toutes les 3 min ; un jet de dés '
            'récent compte aussi.',
      ),
      (
        type: _m,
        texte: 'Séance : seuls les 50 derniers jets et les messages de la '
            'séance sont suivis en direct.',
      ),
      (
        type: _a,
        texte: 'Messages : bouton « Messages des séances précédentes ».',
      ),
      (
        type: _m,
        texte: 'Séance : un changement de PV n\'écrit plus que les PV '
            '(moins d\'appels à Firebase).',
      ),
    ],
  ),
  (
    version: '0.37.0',
    date: '08/11/2026',
    changements: [
      (type: _a, texte: 'Catalogue : la rapière.'),
      (
        type: _a,
        texte: 'Catalogue : 26 objets de marchand (lanterne, torche, tente, '
            'rations, grappin, munitions…).',
      ),
      (
        type: _c,
        texte: 'Séance : le lieu est gardé d\'une séance à la suivante.',
      ),
    ],
  ),
  (
    version: '0.36.0',
    date: '07/11/2026',
    changements: [
      (
        type: _a,
        texte: 'Catalogue : 13 armes (dague, lance, hallebarde, arbalètes, '
            'tromblon…).',
      ),
      (
        type: _a,
        texte: 'Catalogue : 8 armures (matelassée, cuir clouté, écailles, '
            'demi-plaque, heaume, écu, pavois…).',
      ),
    ],
  ),
  (
    version: '0.35.1',
    date: '07/11/2026',
    changements: [
      (
        type: _c,
        texte: 'Séance : la pastille des messages non lus se voit aussi sur '
            'téléphone (onglet Dés).',
      ),
      (
        type: _c,
        texte:
            'Séance : seule la conversation affichée est marquée lue ; le MJ '
            'voit les non-lus de chaque joueur.',
      ),
    ],
  ),
  (
    version: '0.35.0',
    date: '07/11/2026',
    changements: [
      (
        type: _a,
        texte: 'Création : un inventaire de base pour chaque classe, que le '
            'joueur peut refuser.',
      ),
    ],
  ),
  (
    version: '0.34.0',
    date: '07/11/2026',
    changements: [
      (
        type: _m,
        texte: 'Maîtrises et restrictions plus lisibles (armes, armures, '
            'interdits, malus) sur la fiche, le glossaire et la création.',
      ),
      (
        type: _m,
        texte: 'Maîtrises : le survol d\'un groupe montre les armes du '
            'catalogue concernées.',
      ),
    ],
  ),
  (
    version: '0.33.0',
    date: '07/11/2026',
    changements: [
      (
        type: _a,
        texte: 'Maîtrises d\'armes selon la classe et la race : −5 au toucher '
            'avec une arme non maîtrisée.',
      ),
      (
        type: _a,
        texte: 'Restrictions : armure ou arme interdite par la classe ou la '
            'race, équipement refusé.',
      ),
      (
        type: _a,
        texte: 'Création : inventaire de base de la classe, à remplir dans '
            'classes.json.',
      ),
      (
        type: _a,
        texte: 'Butin : curseurs pour choisir l\'argent et la quantité '
            'd\'objets à prendre.',
      ),
      (
        type: _c,
        texte: 'Savoirs : les maîtrises données par les compétences comptent '
            'aux jets.',
      ),
    ],
  ),
  (
    version: '0.32.0',
    date: '07/11/2026',
    changements: [
      (
        type: _a,
        texte: 'Séance : butins créés par le MJ dans le menu de gauche, où '
            'les PJ prennent argent et objets.',
      ),
      (
        type: _a,
        texte: 'Séance : un PJ envoie un objet non équipé à un autre PJ, '
            'discrètement s\'il le veut.',
      ),
      (
        type: _a,
        texte: 'Séance : le MJ donne un nom à une séance (Séance 3 - Nom).',
      ),
      (
        type: _a,
        texte: 'Séance : groupes Sorts et Compétences dans les jets, avec '
            'le détail de chaque compétence.',
      ),
      (
        type: _m,
        texte: 'Séance : toucher raté, la CA de la cible reste cachée.',
      ),
      (
        type: _m,
        texte: 'Écritures espacées : 10 secondes pour un PJ, 3 secondes '
            'pour le MJ.',
      ),
    ],
  ),
  (
    version: '0.31.0',
    date: '07/11/2026',
    changements: [
      (
        type: _a,
        texte: 'Compétences : chaque voie et chaque groupe se réduit en '
            'touchant son en-tête.',
      ),
      (
        type: _a,
        texte: 'Séance : le MJ choisit la puissance de l\'objet aléatoire.',
      ),
      (
        type: _a,
        texte: 'Notes de séances : date de chaque séance, modifiable par '
            'le MJ.',
      ),
      (
        type: _m,
        texte: 'Notes de séances : interface revue, séances passées '
            'réduites, bouton Enregistrer plus clair.',
      ),
      (
        type: _m,
        texte: 'Glossaire : voies des classes, races et créatures au style '
            'de la répartition des points.',
      ),
      (
        type: _c,
        texte: 'Séance : la CA des PJ et des anciennes créatures est '
            'connue pour comparer les attaques.',
      ),
      (
        type: _c,
        texte: 'Séance : une attaque non comparée dit pourquoi (sans cible, '
            'CA inconnue).',
      ),
    ],
  ),
  (
    version: '0.30.0',
    date: '07/11/2026',
    changements: [
      (
        type: _a,
        texte: 'Glossaire : texte copiable et onglet Afflictions & effets.',
      ),
      (
        type: _a,
        texte: 'Armes personnalisées : élément des dégâts (feu, glace…) '
            'et affliction.',
      ),
      (
        type: _a,
        texte: 'Campagne : les PJ lisent les récapitulatifs des séances '
            'écrits par le MJ.',
      ),
      (
        type: _a,
        texte: 'Séance : lieu défini par le MJ, mode bien visible dans '
            'l\'en-tête.',
      ),
      (
        type: _a,
        texte: 'Séance : attaque comparée à la CA de la cible (touché ou '
            'raté) et alerte à la 2e attaque du tour.',
      ),
      (
        type: _a,
        texte: 'Séance : montée de niveau sur autorisation du MJ.',
      ),
      (
        type: _a,
        texte: 'Séance : le MJ peut tirer un objet aléatoire et le donner '
            'à un PJ.',
      ),
      (
        type: _m,
        texte: 'Séance : logs séparés par combat et exploration, avec '
            'l\'heure de chaque lancer.',
      ),
      (
        type: _m,
        texte: 'Séance : boutons de dés regroupés (combat, statistiques, '
            'aptitudes), jets libres réservés au MJ.',
      ),
      (
        type: _m,
        texte: 'Séance : menu de droite plus visible (titre, icônes, '
            'filet or).',
      ),
      (
        type: _m,
        texte: 'Compétences : aptitudes à droite des voies sur grand écran, '
            '« Déjà acquis » plus aéré.',
      ),
      (
        type: _c,
        texte: 'Création : {precision} remplacé par la sélection.',
      ),
    ],
  ),
  (
    version: '0.29.0',
    date: '07/11/2026',
    changements: [
      (
        type: _a,
        texte: 'Fiche : petite fenêtre au survol de chaque statistique, '
            'aux couleurs de la charte.',
      ),
      (
        type: _a,
        texte: 'Création : une phrase d\'explication pour chaque '
            'caractéristique.',
      ),
      (
        type: _a,
        texte: 'Compétences : panneau « Déjà acquis » avec tout ce que '
            'le personnage possède.',
      ),
      (
        type: _a,
        texte: 'Choix d\'une arme ou d\'un instrument : ses statistiques '
            'sont affichées (ex. Outils de nain).',
      ),
      (
        type: _m,
        texte: 'Compétences : voie raciale et voies de classe bien '
            'séparées, avec des en-têtes colorés.',
      ),
      (
        type: _m,
        texte: 'Séance : l\'onglet Historique devient Logs, avec une icône '
            'par type de lancer.',
      ),
      (
        type: _m,
        texte: 'Séance : résultat final mis en avant, bonus et malus '
            'en couleur dans les logs.',
      ),
      (
        type: _m,
        texte: 'Séance : les créatures ont l\'icône de leur famille, '
            'comme dans le bestiaire.',
      ),
    ],
  ),
  (
    version: '0.28.0',
    date: '04/11/2026',
    changements: [
      (
        type: _a,
        texte: 'Hors connexion : personnages, dés et glossaire utilisables '
            'sans internet (campagnes en ligne seulement).',
      ),
      (
        type: _a,
        texte: 'Séance : onglets Glossaire et Séances précédentes pour le MJ.',
      ),
      (
        type: _a,
        texte: 'Séance : messagerie privée entre le MJ et chaque PJ.',
      ),
      (
        type: _a,
        texte: 'Dégâts : type précisé (physique par défaut), RD de la cible '
            'retirée.',
      ),
      (
        type: _m,
        texte: 'Séance : liseré rouge en combat, vert en exploration.',
      ),
      (
        type: _m,
        texte: 'Taille des menus de la séance : Étroit, Normal ou Large.',
      ),
      (
        type: _m,
        texte: 'Hors séance : inventaire et compétences restent consultables '
            'si le MJ verrouille les modifications.',
      ),
      (
        type: _m,
        texte: 'Campagnes : menu latéral gardé, paramètres visibles des PJ, '
            'bouton pour copier le code, niveau de départ retiré.',
      ),
      (
        type: _m,
        texte: 'Inventaire : Plastron 0/1, Casque 0/1, Bijoux 0/2.',
      ),
      (
        type: _c,
        texte: 'Le message de séance se ferme quand on rejoint la séance.',
      ),
    ],
  ),
  (
    version: '0.27.0',
    date: '04/11/2026',
    changements: [
      (
        type: _a,
        texte: 'Séance : icône sur la carte d\'un joueur pas connecté ou pas '
            'dans la séance.',
      ),
    ],
  ),
  (
    version: '0.26.0',
    date: '04/11/2026',
    changements: [
      (
        type: _a,
        texte: 'Séance : les dégâts lancés sont retirés des PV de la cible.',
      ),
      (
        type: _m,
        texte: 'Cible par défaut : la première créature pour un PJ, le '
            'premier PJ pour une créature.',
      ),
      (
        type: _c,
        texte: 'Cartes de la séance : PV, PM et PE à jour en direct.',
      ),
    ],
  ),
  (
    version: '0.25.0',
    date: '03/11/2026',
    changements: [
      (
        type: _c,
        texte: 'Fiche : plus de rectangle gris en revenant sur l\'onglet Fiche '
            'après avoir défilé.',
      ),
      (
        type: _m,
        texte: 'Séance : bouton pour clôturer ou quitter en haut à droite.',
      ),
      (
        type: _a,
        texte: 'Séance : choix de la cible des attaques et des sorts, notée '
            'dans l\'historique.',
      ),
      (
        type: _a,
        texte: 'Séance : sorts dans le lancer de dés (coût dépensé, dés '
            'lancés).',
      ),
    ],
  ),
  (
    version: '0.24.2',
    date: '03/11/2026',
    changements: [
      (
        type: _c,
        texte: 'Version web des releases : la connexion au compte fonctionne.',
      ),
    ],
  ),
  (
    version: '0.24.1',
    date: '03/11/2026',
    changements: [
      (
        type: _m,
        texte: 'Séance : la carte de celui dont c\'est le tour ressort en or.',
      ),
      (
        type: _m,
        texte: 'Historique : jets au nom de la créature ou du personnage, '
            'sans révéler un nom caché.',
      ),
    ],
  ),
  (
    version: '0.24.0',
    date: '03/11/2026',
    changements: [
      (
        type: _m,
        texte: 'Séance : les onglets s\'ouvrent au centre, cartes et dés '
            'restent visibles ; Créatures = bestiaire complet.',
      ),
      (
        type: _a,
        texte: 'Séance : fiche complète au centre (compétences, sorts, '
            'inventaire, points restants).',
      ),
      (
        type: _a,
        texte: 'MJ : modifier la fiche et l\'inventaire d\'un personnage '
            'pendant la séance.',
      ),
      (
        type: _a,
        texte: 'Dés : jets d\'attaque du personnage ou de la créature '
            'sélectionnée.',
      ),
      (
        type: _m,
        texte: 'Cartes : PV, PM et PE avec icônes et couleurs, initiative '
            'en combat.',
      ),
      (
        type: _a,
        texte: 'Paramètres : permissions des PJ et taille de chaque portion.',
      ),
    ],
  ),
  (
    version: '0.23.0',
    date: '03/11/2026',
    changements: [
      (
        type: _a,
        texte: 'Séance : tableau de bord en 3 portions (cartes, détail, dés), '
            'Créatures, Règles système, Paramètres.',
      ),
      (
        type: _a,
        texte: 'Combat : tours par initiative, passer son tour, tour '
            'précédent (MJ) ; mode exploration sans tours.',
      ),
      (
        type: _a,
        texte: 'MJ : créatures ajoutées à la partie, carte ou nom cachés aux '
            'PJ, suivi de leurs PV.',
      ),
      (
        type: _a,
        texte: 'Jets de séance : pour tous, pour un seul PJ, cachés aux '
            'autres ou même à soi (MJ seul).',
      ),
      (
        type: _a,
        texte: 'PJ : notes personnelles pour la séance.',
      ),
    ],
  ),
  (
    version: '0.22.0',
    date: '03/11/2026',
    changements: [
      (
        type: _a,
        texte: 'Campagnes : parties à plusieurs menées par un maître du jeu '
            '(compte requis).',
      ),
      (
        type: _a,
        texte: 'MJ : création en 4 étapes (nom, script importable, notes, '
            'paramètres) et page à onglets.',
      ),
      (
        type: _a,
        texte: 'Invitation par code (LOUP-4827) : le joueur choisit son '
            'personnage, le MJ accepte sa demande.',
      ),
      (
        type: _a,
        texte: 'Séances : le MJ démarre la séance, les joueurs sont '
            "avertis dans l'app.",
      ),
      (
        type: _a,
        texte: 'Fiches des joueurs visibles par le MJ (et entre joueurs '
            'selon les paramètres).',
      ),
    ],
  ),
  (
    version: '0.21.3',
    date: '03/11/2026',
    changements: [
      (
        type: _m,
        texte: 'Synchronisation : envois automatiques espacés de 5 secondes, '
            'modifications regroupées entre deux envois.',
      ),
    ],
  ),
  (
    version: '0.21.2',
    date: '03/11/2026',
    changements: [
      (
        type: _m,
        texte:
            "Dé d'endurance du demi-orque, du draconien et du nain : d8 → d6.",
      ),
    ],
  ),
  (
    version: '0.21.1',
    date: '03/11/2026',
    changements: [
      (
        type: _m,
        texte: 'Sorts raciaux des classes physiques (Cri sauvage, Visage '
            'impensable) payés en PE au même coût.',
      ),
    ],
  ),
  (
    version: '0.21.0',
    date: '03/11/2026',
    changements: [
      (
        type: _a,
        texte: "Endurance : dé d'endurance (DE) et points d'endurance (PE) "
            'pour les classes physiques et hybrides.',
      ),
      (
        type: _m,
        texte: 'Classes physiques sans mana, lanceurs de sorts sans endurance '
            '(croix sur le dé absent) ; hybrides : PM + PE.',
      ),
      (
        type: _a,
        texte: "Races : dé d'endurance (d8 demi-orque, draconien, nain ; "
            'd4 gnome ; d6 les autres).',
      ),
      (
        type: _a,
        texte: 'Coûts en PE de 38 compétences ; section Endurance sur la '
            'page Lancer de dé.',
      ),
      (
        type: _a,
        texte: 'Fiche : jauge des PE, repos et montée de niveau avec le dé '
            "d'endurance.",
      ),
      (
        type: _m,
        texte: "Puits d'arcane (haut-elfe) selon la classe : PM pour les "
            'lanceurs, PV pour les physiques, au choix pour les hybrides.',
      ),
    ],
  ),
  (
    version: '0.20.0',
    date: '03/11/2026',
    changements: [
      (
        type: _a,
        texte: 'Univers : personnages, classes, races et voies rattachés au '
            "médiéval fantastique, en vue d'autres univers."
      ),
    ],
  ),
  (
    version: '0.19.2',
    date: '03/11/2026',
    changements: [
      (type: _m, texte: "Moine : dé de vie inchangé (au lieu d'augmenté)."),
      (
        type: _m,
        texte:
            "Prêtre : lanceur de sorts (au lieu d'hybride), dé de vie diminué."
      ),
      (
        type: _m,
        texte:
            'Chevalier, Duelliste et guerrier, À couvert : un seul bonus de CA (+3, +5 avec Égide).'
      ),
      (
        type: _m,
        texte: 'Voleur, Riposte : après une attaque ratée contre le voleur.'
      ),
    ],
  ),
  (
    version: '0.19.1',
    date: '02/11/2026',
    changements: [
      (
        type: _m,
        texte:
            'Historique : 100 lancers de dés gardés au plus par personnage (les plus anciens sont effacés).'
      ),
    ],
  ),
  (
    version: '0.19.0',
    date: '02/11/2026',
    changements: [
      (
        type: _a,
        texte:
            'Compte : bloc Synchronisation avec la date de la dernière synchronisation.'
      ),
      (
        type: _a,
        texte:
            'Méthode de sauvegarde : automatique (à chaque modification, à chaque lancer de dé) ou manuelle.'
      ),
      (
        type: _a,
        texte:
            "Modifications en attente gardées sur l'appareil, envoyées par « Synchroniser maintenant »."
      ),
    ],
  ),
  (
    version: '0.18.0',
    date: '02/11/2026',
    changements: [
      (
        type: _a,
        texte:
            'Compte (menu) : connexion par e-mail ou Google, mot de passe oublié, suppression du compte.'
      ),
      (
        type: _a,
        texte:
            'Sauvegarde en ligne : personnages retrouvés sur tous tes appareils, mis à jour en direct.',
      ),
      (
        type: _a,
        texte:
            "Sans compte, rien ne change ; à la connexion, les fiches de l'appareil sont envoyées sur le compte.",
      ),
      (
        type: _a,
        texte:
            'Menu : état de la synchronisation sous le nombre de personnages.'
      ),
    ],
  ),
  (
    version: '0.17.1',
    date: '02/11/2026',
    changements: [
      (
        type: _c,
        texte:
            'Téléphone : la cible, les flèches et les épées du cadre guerrier sont retirées (elles cachaient les infos).'
      ),
    ],
  ),
  (
    version: '0.17.0',
    date: '01/11/2026',
    changements: [
      (
        type: _a,
        texte:
            'Invocations et compagnons : bouton « Statistiques » vers leur fiche (PV seuls pour les non-combattants).'
      ),
      (
        type: _a,
        texte:
            'Transformations : formes au choix du druide et des élémentaires, avec bonus temporaires et attaques sur la page dé.'
      ),
      (
        type: _a,
        texte:
            'Agrandissement : +4 FOR, +4 CON, −2 DEX ; section « Effets reçus » pour les sorts lancés par un allié.'
      ),
      (
        type: _m,
        texte:
            'Invocations : durée INT + 1d6 tours, requiem INT + 1d4 morts-vivants, compagnon géant du rôdeur 1d8.'
      ),
      (
        type: _m,
        texte:
            "Bestiaire : 51 fiches d'invocations et de compagnons, élémentaire de glace, statistiques du zombie."
      ),
    ],
  ),
  (
    version: '0.16.0',
    date: '30/10/2026',
    changements: [
      (
        type: _m,
        texte:
            'Inventaire : objet du catalogue ou donné verrouillé (seuls origine, précision et quantité changent).'
      ),
      (
        type: _a,
        texte:
            "Inventaire : bouton « Éditer l'objet » ; un objet édité devient personnalisé (clé à molette)."
      ),
      (
        type: _a,
        texte:
            "Bourse : commentaire sur les paiements, recettes et corrections (noté dans l'historique)."
      ),
      (
        type: _m,
        texte:
            'Répartition des points : compteur fixé en haut, toujours visible.'
      ),
      (
        type: _m,
        texte:
            'Répartition des points : connaissances, aptitudes, maîtrises et sorts dans des cadres séparés.'
      ),
      (
        type: _m,
        texte:
            'Préférences par défaut : menu latéral ouvert (grand écran), connaissances et aptitudes cachées sur la page dé.'
      ),
      (
        type: _a,
        texte:
            'Bestiaire : statistiques (CA, PV, initiative, modificateurs, attaques) ; loup, loup alpha, ours noir, ours-hibou.'
      ),
      (
        type: _a,
        texte:
            'Bestiaire : ours brun complété ; dragon juvénile, jeune dragon, dragon adulte et dragon ancien (souffle, coup de queue).'
      ),
      (
        type: _c,
        texte:
            'Bestiaire : morsure du dragon adulte à +12 ; dragon générique retiré.'
      ),
      (
        type: _m,
        texte:
            "Règle : l'initiative = valeur de DEX + bonus d'initiative ; plus de jet à lancer."
      ),
      (
        type: _a,
        texte:
            'Bestiaire : 28 créatures (gobelins, bandits, fées, élémentaires, golem, géant, manticore…).'
      ),
    ],
  ),
  (
    version: '0.15.0',
    date: '29/10/2026',
    changements: [
      (
        type: _m,
        texte:
            "Refonte de la défense : CA = 10 + armure + DEX (limitée par l'armure), une seule esquive."
      ),
      (
        type: _a,
        texte:
            'Armures : limite de DEX (cuir +3, cotte de mailles +2, plaques +1) ; 3 armures au catalogue.'
      ),
      (
        type: _a,
        texte:
            "Page dé : jet d'esquive (contre ce qui n'a pas de jet d'attaque)."
      ),
      (
        type: _m,
        texte:
            "Fiche : CA et les 5 résistances ; l'esquive est un jet (1d20 + DEX limitée + bonus)."
      ),
      (
        type: _m,
        texte:
            'Règles particulières : seul le niveau le plus élevé est affiché (Style barbaresque).'
      ),
      (
        type: _m,
        texte:
            "Bonus d'esquive CaC / distance / magie devenus de la CA contre ce type d'attaque."
      ),
      (
        type: _c,
        texte:
            'Draconien : le cuir de dragon donne sa RD (feu, glace ou foudre), +2 puis +4.'
      ),
    ],
  ),
  (
    version: '0.14.0',
    date: '29/10/2026',
    changements: [
      (
        type: _m,
        texte:
            'Statistique Charisme (CHA) renommée Mental (MEN) : force mentale, conviction, résistance à la peur.'
      ),
      (
        type: _m,
        texte: 'Personnages existants : leur CHA est repris tel quel en MEN.'
      ),
      (
        type: _m,
        texte:
            'Persuasion, commandement et séduction passent en SOC (meneur, général, noblesse, charme, troubadour…).'
      ),
    ],
  ),
  (
    version: '0.13.0',
    date: '28/10/2026',
    changements: [
      (
        type: _a,
        texte:
            'Nécromancien : 4 voies adaptées (mort, morts-vivants, invocation, rituels).'
      ),
      (
        type: _a,
        texte:
            'Rituels du sang : PV dépensés retirés au lancement, épée sanguine (1d6 + INT).'
      ),
      (
        type: _a,
        texte: 'Marque de sang : +2d6 + INT ajoutés au prochain jet de dégâts.'
      ),
      (
        type: _c,
        texte:
            'Diablotin et molosse : dégâts de la créature sans l\'INT, et jet de durée.'
      ),
    ],
  ),
  (
    version: '0.12.0',
    date: '28/10/2026',
    changements: [
      (
        type: _a,
        texte:
            'Voleur : 4 voies adaptées (assassin, bretteur, roublard, séducteur).'
      ),
      (
        type: _a,
        texte:
            'Voleur : attaques de compétence (coupe-jarret, riposte, botte secrète, dague de verre).'
      ),
      (
        type: _a,
        texte:
            'Voleur : outils de crochetage et kit de déguisement ajoutés à l\'inventaire.'
      ),
    ],
  ),
  (
    version: '0.11.0',
    date: '28/10/2026',
    changements: [
      (
        type: _a,
        texte:
            'Rôdeur : 4 voies adaptées (archer, chasseur, animaux, trappeur).'
      ),
      (
        type: _a,
        texte:
            'Page dé : groupe « Dégâts à distance » (proie favorite, gros gibier, affût).'
      ),
      (
        type: _a,
        texte:
            'Savoirs : avantage donné par une compétence (Survivaliste : Survie).'
      ),
      (
        type: _a,
        texte: 'Points vitaux : attaque à distance avec +1d6 + PER aux dégâts.'
      ),
    ],
  ),
  (
    version: '0.10.0',
    date: '28/10/2026',
    changements: [
      (
        type: _a,
        texte: 'Prêtre : 4 voies adaptées (soins, paladin, divin, inquisiteur).'
      ),
      (
        type: _a,
        texte:
            'Bénédiction : 3 états au choix (arme, armure, personne), +2 avec Lien vital.'
      ),
      (
        type: _a,
        texte:
            'Sorts : boutons de dégâts ×2 (Lumière sacrée) et ÷2 si esquivé (Courroux céleste).'
      ),
      (
        type: _a,
        texte:
            "Justice divine : attaque de l'arme divine, 5 PM retirés à chaque attaque."
      ),
    ],
  ),
  (
    version: '0.9.0',
    date: '28/10/2026',
    changements: [
      (type: _a, texte: 'Moine : 4 voies adaptées (ki, runes, ninja, poing).'),
      (
        type: _a,
        texte:
            'Attaques à mains nues : Déferlement de coups, Uppercut et Lutte sans arme.'
      ),
      (
        type: _a,
        texte:
            'Dé de mana dans les jets : Frappe de ki, Méditation (ajoutée aux PM), Kenn-do-ha.'
      ),
      (
        type: _a,
        texte:
            'Rune de précision : critique sur 18-20 et échec critique sur 1-2 pour les attaques.'
      ),
      (
        type: _m,
        texte:
            'Lancer un sort qui a un état l\'active tout seul (Frappe de ki, Mur d\'air).'
      ),
      (
        type: _m,
        texte:
            'Mains nues : dé de 1d6 (Pugilat) puis 1d8 (Poing de fer), +RANG au toucher.'
      ),
    ],
  ),
  (
    version: '0.8.2',
    date: '27/10/2026',
    changements: [
      (
        type: _m,
        texte:
            'Lancer de dé : le niveau du personnage s\'affiche dans la liste (après la classe).'
      ),
    ],
  ),
  (
    version: '0.8.1',
    date: '26/10/2026',
    changements: [
      (
        type: _m,
        texte:
            'Éclat des arcanes, niveau 3 (rang 5) : 3d4 + INT dégâts magiques (au lieu de + AdM).'
      ),
    ],
  ),
  (
    version: '0.8.0',
    date: '26/10/2026',
    changements: [
      (
        type: _a,
        texte:
            'Magicien : 7 voies adaptées, 25 sorts typés avec coût en mana et jet d\'attaque magique.'
      ),
      (
        type: _a,
        texte:
            'Boule de feu modulable : une carte par puissance (1d6 à 5d6, coût du rang choisi).'
      ),
      (
        type: _a,
        texte:
            'Fiche : ligne « Résistances » (RD physique, magique, feu, glace, foudre).'
      ),
      (
        type: _a,
        texte:
            'Magicien : focaliseur au choix (−1 PM sur les sorts des arcanes, sort stocké 1×/jour).'
      ),
      (
        type: _a,
        texte:
            'Magicien : Archimage (+2 INT, +2 AdM, titre), élémentaires, mur d\'air, cercle de protection.'
      ),
      (
        type: _m,
        texte:
            'Éclat des arcanes : dégâts qui grandissent avec le rang (1d4, 2d4, 3d4 + AdM).'
      ),
    ],
  ),
  (
    version: '0.7.1',
    date: '26/10/2026',
    changements: [
      (
        type: _m,
        texte:
            'Types ajoutés aux sorts des races : Cri sauvage (illusion), Visage impensable (transformation, contrôle mental).'
      ),
    ],
  ),
  (
    version: '0.7.0',
    date: '26/10/2026',
    changements: [
      (
        type: _a,
        texte:
            'Sorts : 8 types (offensif, support, transformation, invocation, illusion, contrôle physique, contrôle mental, utilitaire).'
      ),
      (
        type: _a,
        texte:
            'Étiquette colorée du type sur chaque sort (fiche, page dé, Glossaire, création).'
      ),
      (
        type: _a,
        texte:
            'Glossaire › Compétences : filtre par type de sort, cumulable avec les autres.'
      ),
      (
        type: _m,
        texte:
            'Ingénieur, Bidouillage : l\'amélioration d\'une arme peut être changée (10 pa).'
      ),
    ],
  ),
  (
    version: '0.6.1',
    date: '26/10/2026',
    changements: [
      (
        type: _m,
        texte: 'Ingénieur, Bidouillage : une seule amélioration par arme.'
      ),
      (
        type: _m,
        texte:
            'Glossaire › Compétences : les catégories cochées se cumulent (ex. Sorts + Dégâts).'
      ),
      (type: _c, texte: 'Menu fixe : plus de blanc dans les coins arrondis.'),
    ],
  ),
  (
    version: '0.6.0',
    date: '26/10/2026',
    changements: [
      (
        type: _a,
        texte:
            'Écran « Nouveautés » : liste des versions et de leurs modifications.'
      ),
      (
        type: _m,
        texte: 'Le numéro de version en bas du menu ouvre les nouveautés.'
      ),
    ],
  ),
  (
    version: '0.5.0',
    date: '26/10/2026',
    changements: [
      (
        type: _a,
        texte: 'Descriptions d\'ambiance des 8 races (Glossaire › Races).'
      ),
      (
        type: _m,
        texte:
            'Draconiens : histoire précisée (anciens esclaves des dragons, libérés depuis quelques siècles).'
      ),
    ],
  ),
  (
    version: '0.4.0',
    date: '26/10/2026',
    changements: [
      (
        type: _a,
        texte: 'Descriptions d\'ambiance des 12 classes (Glossaire › Classes).'
      ),
      (
        type: _a,
        texte:
            'Origine du pouvoir affichée pour les 6 classes de lanceurs de sorts.'
      ),
      (
        type: _m,
        texte:
            'Anciennes notes et citations retirées des descriptions de classes.'
      ),
    ],
  ),
  (
    version: '0.3.0',
    date: '26/10/2026',
    changements: [
      (
        type: _a,
        texte: 'Fiche : icône sur les cartes PV (cœur) et PM (goutte).'
      ),
      (
        type: _a,
        texte:
            'Fiche : commentaire facultatif sur une dépense ou un gain de PV / PM, noté dans l\'historique.'
      ),
      (
        type: _m,
        texte:
            'Fiche : boutons de dépense (rouge) et de gain (vert / bleu) colorés, avec icône.'
      ),
    ],
  ),
  (
    version: '0.2.0',
    date: '25/10/2026',
    changements: [
      // 25/10
      (
        type: _a,
        texte: 'Numéro de version en bas du menu latéral et dans À propos.'
      ),
      (type: _a, texte: 'Icône « pistolet » pour les armes à poudre.'),
      (type: _a, texte: 'Canon à mains au catalogue (3d10, 50 m, 50 pa).'),
      (
        type: _a,
        texte:
            'Ingénieur : 4 voies adaptées (potions du jour, Bidouiller, Pistoléro, golem…).'
      ),
      (
        type: _m,
        texte:
            'Armes à feu : pas de DEX aux dégâts, sauf avec Expertise de la poudre.'
      ),
      (
        type: _a,
        texte:
            'Guerrier : 4 voies adaptées (À couvert, postures, Coup de boucher, Ambidextrie…).'
      ),
      (
        type: _a,
        texte:
            'Druide : 4 voies adaptées (animal de compagnie, 13 sorts, peau d\'écorce…).'
      ),
      (
        type: _a,
        texte:
            'Chevalier : arme familiale, écuyer, titre de noblesse, cavalerie, duel, commandement.'
      ),
      (
        type: _m,
        texte:
            '« DEF » remplacé par « CA » dans les classes, les races et les règles.'
      ),
      (
        type: _a,
        texte:
            'Usages limités (par combat, par jour, par aventure) avec boutons de remise à zéro.'
      ),
      (
        type: _a,
        texte:
            'Préférences : dé par défaut et affichage des groupes de la page dé.'
      ),
      (
        type: _a,
        texte:
            'Glossaire : onglet « Connaissances & Aptitudes », filtres par famille et par stat.'
      ),
      (
        type: _a,
        texte:
            '59 savoirs et savoir-faire (une connaissance par race, un savoir-faire par artisanat).'
      ),
      (
        type: _a,
        texte:
            'Page dé : catégories Combat, Connaissances, Aptitudes ; jets de savoirs (+5 / −5).'
      ),
      (
        type: _m,
        texte:
            'Page dé : groupes repliables, textes longs sur plusieurs lignes, situations à gauche.'
      ),
      (
        type: _c,
        texte:
            'Choix multiples (golem, Vagabond) : les options cochées s\'affichent de nouveau.'
      ),
      (
        type: _c,
        texte:
            'Choix multiples : plantage du calcul des objets à recevoir corrigé.'
      ),
      // 24/10
      (
        type: _a,
        texte:
            'Dé libre au choix (D4 à D100), avantage / désavantage pour tous les dés.'
      ),
      (
        type: _a,
        texte:
            'Équipements : catégorie « Instruments » et 5 instruments de musique.'
      ),
      (
        type: _a,
        texte:
            'Glossaire : Classes, Races, Compétences, Équipements et Bestiaire en onglets.'
      ),
      (
        type: _a,
        texte: '22 sorts mineurs (rang 0), achetés comme une aptitude.'
      ),
      (
        type: _a,
        texte:
            'Déplacement : 10 m par action de mouvement, affiché sur la fiche.'
      ),
      (
        type: _a,
        texte:
            'Barbare et barde adaptés (rage, Vagabond, musique, acrobaties…).'
      ),
      (
        type: _a,
        texte:
            'Sorts : étiquettes mana, dégâts, soin, effet, et jet de réussite.'
      ),
      (
        type: _a,
        texte: 'Cadres de personnage décorés et animés selon la classe.'
      ),
      (
        type: _a,
        texte: 'Emblème de la race dans le cercle des cartes de personnage.'
      ),
      (
        type: _a,
        texte:
            'Icônes dessinées pour les équipements (épée, arc, pioche, plastron…).'
      ),
      (
        type: _m,
        texte:
            'Attaques de compétence : jet d\'attaque et jet de dégâts séparés.'
      ),
      (
        type: _m,
        texte:
            'Polyvalence de l\'humain : choix des rangs d\'autres classes refait.'
      ),
      (
        type: _c,
        texte:
            'Demi-elfe, Polyglotte : la langue apprise est maintenant demandée.'
      ),
      // 23/10
      (
        type: _a,
        texte:
            'Langues : liste du monde, langue de chaque race, langues apprises.'
      ),
      (
        type: _a,
        texte:
            'Compétences raciales : choix, jets avec difficulté, paliers et états.'
      ),
      (
        type: _a,
        texte:
            'Page dé : bandeau Réussite / Échec et provenance de chaque bonus.'
      ),
      (
        type: _a,
        texte:
            'Gnome : arme, instrument et porte-bonheur choisis à la création.'
      ),
      (
        type: _m,
        texte:
            'Données des races et des équipements mises à jour (effets détaillés).'
      ),
      (type: _c, texte: 'Gnome : écran rouge au rang 2 corrigé.'),
      // 22/10
      (
        type: _a,
        texte: 'Personnage actif et jets du personnage sur la page dé.'
      ),
      (
        type: _a,
        texte:
            'Page dé : modificateur libre, avantage et désavantage en couleur.'
      ),
      (
        type: _a,
        texte:
            'Inventaire : ajout depuis le catalogue, armes à une ou deux mains.'
      ),
      (
        type: _a,
        texte:
            'Fiche : dégâts selon l\'arme équipée, avec le détail de leur origine.'
      ),
      (
        type: _a,
        texte: 'Règle des deux mains à l\'équipement des armes et boucliers.'
      ),
      (type: _a, texte: 'Menu latéral qui peut rester ouvert sur grand écran.'),
      (
        type: _m,
        texte: 'Création sur grand écran : race et classe sur la même étape.'
      ),
      (type: _m, texte: 'Fiche réorganisée en colonnes, onglets agrandis.'),
      // 21/10
      (
        type: _a,
        texte:
            'Menu latéral, lancer de d20, pages Classes, Races, Équipements, Bestiaire.'
      ),
      (
        type: _a,
        texte:
            'Charte graphique « Taverne » : thèmes sombre et parchemin, Cinzel, logo.'
      ),
      (
        type: _a,
        texte:
            'Profils physique / lanceur / hybride et jauges de vie et de mana.'
      ),
      (
        type: _a,
        texte: 'Versions à emporter : web (zip), Windows et Android (APK).'
      ),
      // 20/10
      (type: _a, texte: 'Historique daté des modifications, avec filtres.'),
      (
        type: _a,
        texte:
            'Montée de niveau : jets de vie et de mana, compétences, récapitulatif.'
      ),
      (type: _a, texte: 'Règles particulières automatiques avec leur origine.'),
      (type: _a, texte: 'Export et import des personnages (fichier ou texte).'),
      (type: _a, texte: 'Initiative, toucher, esquives et CA calculés.'),
    ],
  ),
  (
    version: '0.1.0',
    date: '19/10/2026',
    changements: [
      (
        type: _a,
        texte:
            'Première version : création de personnage en étapes (race, classe, caractéristiques, compétences).'
      ),
      (
        type: _a,
        texte:
            'Fiche du personnage : PV / PM, repos, statistiques, compétences, notes, inventaire.'
      ),
      (type: _a, texte: 'Sauvegarde des personnages sur l\'appareil.'),
    ],
  ),
];
