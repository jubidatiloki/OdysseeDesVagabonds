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
];

const List<EntreeEffet> kEffetsDegats = [
  (
    nom: 'Physique',
    effet: 'Type par défaut : tout dégât est physique sauf indication '
        'contraire. Corps à corps et distance, armes tranchantes, contondantes '
        'ou perçantes. La RD physique se retire du total (minimum 0).',
  ),
  (
    nom: 'Magique',
    effet: 'Attaque magique. La RD magique se retire du total (minimum 0).',
  ),
  (
    nom: 'Feu',
    effet: 'Attaque élémentaire de feu. La RD feu se retire du total '
        '(minimum 0).',
  ),
  (
    nom: 'Glace',
    effet: 'Attaque élémentaire de glace. La RD glace se retire du total '
        '(minimum 0).',
  ),
  (
    nom: 'Foudre',
    effet: 'Attaque élémentaire de foudre. La RD foudre se retire du total '
        '(minimum 0).',
  ),
  (
    nom: 'Chaos',
    effet: 'Ignore toute RD : les dégâts sont subis en entier.',
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
