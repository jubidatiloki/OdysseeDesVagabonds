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
];

const List<EntreeEffet> kEffetsDegats = [
  (
    nom: 'Physique',
    effet: 'Corps à corps et distance ; réduits par la RD physique.'
  ),
  (nom: 'Magique', effet: 'Réduits par la RD magique.'),
  (nom: 'Feu', effet: 'Attaque élémentaire ; réduits par la RD feu.'),
  (nom: 'Glace', effet: 'Attaque élémentaire ; réduits par la RD glace.'),
  (nom: 'Foudre', effet: 'Attaque élémentaire ; réduits par la RD foudre.'),
  (nom: 'Chaos', effet: 'Ignore toute RD.'),
];

/// Éléments possibles pour les dégâts d'une arme (vide : physiques).
const List<String> kElementsDegats = [
  'magique',
  'feu',
  'glace',
  'foudre',
  'chaos',
];
