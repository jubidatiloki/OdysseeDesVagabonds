/// Afflictions et types de dégâts (règles §3.2 et §3.4), affichés dans le
/// Glossaire et proposés pour les armes personnalisées.
typedef EntreeEffet = ({String nom, String effet});

const List<EntreeEffet> kAfflictions = [
  (
    nom: 'Ralenti',
    effet: '1 seule action simple ou de mouvement par tour '
        '(déplacement divisé par 2).',
  ),
  (
    nom: 'Aveuglement léger',
    effet: '−5 à tout ce qui touche à la vue (viser, toucher, observer…).',
  ),
  (nom: 'Aveuglement grave', effet: '−10 à tout ce qui touche à la vue.'),
  (nom: 'Étourdi', effet: 'Aucune action ; défense réduite à 5.'),
  (nom: 'Immobilisation', effet: 'Action de mouvement impossible.'),
  (nom: 'Réduit au silence', effet: 'Incapable de produire un son.'),
  (
    nom: 'Réduit au silence magique',
    effet: 'Incapable de lancer un sort.',
  ),
  // Ajoutées le 09/11/2026 (proposées et validées).
  (
    nom: 'Empoisonné',
    effet:
        'Perd 1D4 PV au début de chaque tour ; test de CON (diff. 12) pour s\'en défaire.',
  ),
  (
    nom: 'En feu',
    effet: '1D6 dégâts de feu par tour ; une action pour l\'éteindre.',
  ),
  (
    nom: 'Saignement',
    effet: 'Perd 1 PV par tour jusqu\'à des soins.',
  ),
  (
    nom: 'Effrayé',
    effet:
        '−2 à tous les jets ; ne peut pas s\'approcher de la source de sa peur.',
  ),
  (
    nom: 'À terre',
    effet:
        '−5 au toucher au contact ; +5 pour les attaques au contact contre lui ; se relever = action de mouvement.',
  ),
  (
    nom: 'Assourdi',
    effet: 'N\'entend rien ; −5 aux tests liés à l\'ouïe.',
  ),
  (
    nom: 'Endormi',
    effet: 'Aucune action ; se réveille s\'il subit des dégâts.',
  ),
  (
    nom: 'Paralysé',
    effet: 'Aucune action ni mouvement ; défense réduite à 5.',
  ),
  (
    nom: 'Affaibli',
    effet: 'Dégâts infligés divisés par 2.',
  ),
  (
    nom: 'Charmé',
    effet: 'Ne peut pas attaquer celui qui l\'a charmé.',
  ),
  // Ajoutée le 11/11/2026 (Toucher nécrotique du nécromancien).
  (
    nom: 'Nécrose',
    effet: 'Ne peut pas regagner de PV (soins, potions, repos) pendant la '
        'durée indiquée par ce qui l\'a causée.',
  ),
];

/// Explication générale des jets d'attaque, en tête des types de dégâts.
const String kIntroDegats =
    'Une attaque demande par défaut un jet d\'attaque (pour toucher) : on '
    'lance un dé pour savoir si le personnage atteint ou non sa cible. Le '
    'résultat est comparé à la Classe d\'Armure (CA) de la cible. Certaines '
    'attaques ne demandent pas de jet, principalement les attaques de zone : '
    'la ou les cibles font alors un jet d\'esquive pour ne subir, par défaut, '
    'que la moitié des dégâts.';

const List<EntreeEffet> kEffetsDegats = [
  (
    nom: 'Physique',
    effet: 'Dégâts « naturels », sans magie ni élément. Un jet d\'attaque '
        'physique est comparé à la Classe d\'Armure (CA) de la cible (sauf '
        'mention contraire). Ces dégâts sont réduits par la résistance '
        'physique (RD physique) de la cible. C\'est le type de dégâts le plus '
        'courant pour les classes physiques et hybrides. Ils peuvent être :\n'
        '• tranchants (épée, dague…) ;\n'
        '• contondants (marteau, mains nues…) ;\n'
        '• perçants (lance, flèches…).',
  ),
  (
    nom: 'Magique',
    effet: 'Dégâts d\'arcanes purs. La plupart des sorts des lanceurs de sorts '
        'causent des dégâts magiques (sauf mention contraire). Un jet '
        'd\'attaque magique est comparé à la Classe d\'Armure (CA) de la cible '
        '(sauf mention contraire). Ces dégâts sont réduits par la résistance '
        'magique (RD magique) de la cible. C\'est le type de dégâts le plus '
        'courant pour les lanceurs de sorts (sauf le magicien, qui peut se '
        'spécialiser dans un élément).',
  ),
  (
    nom: 'Élémentaire',
    effet: 'Dégâts liés aux éléments, magiques ou non (ex. : sort de boule de '
        'feu ou torche). Les dégâts de souffle élémentaire ne sont pas '
        'comparés à la Classe d\'Armure (CA) de la cible : elle fait un jet '
        'd\'esquive pour les diminuer ou les annuler. Il existe 3 éléments :\n'
        '• feu, réduits par la résistance au feu (RD feu) ;\n'
        '• glace, réduits par la résistance à la glace (RD glace) ;\n'
        '• foudre, réduits par la résistance à la foudre (RD foudre).',
  ),
  (
    nom: 'Chaos',
    effet: 'Dégâts impossibles à arrêter : il n\'existe aucune résistance '
        'contre eux.',
  ),
];

/// Éléments possibles pour les dégâts d'une arme (vide : physiques).
const List<String> kElementsDegats = [
  'magique',
  'feu',
  'glace',
  'foudre',
  'chaos',
];
