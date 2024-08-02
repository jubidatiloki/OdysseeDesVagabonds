# OdysseeDesVagabonds

Application de gestion de personnage pour jeu de rôle

Le systèmee utilisé est un système perso, médieval high-fantasy, assez classique mais que j'avais envie de créer moi-même avec toutes les idées que j'ai eut au cours de mes sessions de JDR avec des amis.


TODO
- races
  - demi-elfe
  - demi-orque
  - draconien
  - humain
  - passif racial + gestions bonus/malus
  - maitrise (armes, armures)
  - restrictions (port d'armes, d'armures)
- talent
  - gestion dynamique des changements de stats liés aux passif (TODO: utiliser les StatsChanges)
  - ajouter un boolean isChoice? (pour évo souffle draconien)
  - ajouter un boolean isPassifRequire (null ou uuid du passif) // pour le passif du draconien
  - ajouter un statChangeRequire String (pour l'humain, rang 2)


INDEX
code            |       libellés        |   deprecated
Profile 				classe				classe
path					voie				voie
talent					talent				~rang
spell					sort				talent magique
skill					compétence			talent non magique



