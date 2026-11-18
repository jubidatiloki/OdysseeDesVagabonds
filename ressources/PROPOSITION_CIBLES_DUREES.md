# Proposition : cible et durée des compétences et sorts

Rédigée le 19/11/2026. **Validée et versée dans les données le 19/11/2026** (`classes.json`, `races.json`, `sorts_rang0.json`), avec les réponses ci-dessous.

## Comment lire

- **Cible** :
  - **Soi** ;
  - **Une** (une cible) ;
  - **Plusieurs** (plusieurs cibles au choix) ;
  - **Alliés+** (alliés, lanceur compris) ;
  - **Alliés** (alliés, sans le lanceur).
- **Durée** :
  - **—** : aucune (effet immédiat, rien d'affiché) ;
  - **N actions** ;
  - **N tours** ;
  - **N jours** ;
  - **Fin du combat** ;
  - **Indéfinie**.
- La colonne **« ? »** signale un point à trancher. Il y en a trois sortes :
  - un texte ambigu ;
  - une durée en **minutes ou en heures** : il n'existe pas d'unité pour ça (voir les questions en bas) ;
  - un effet de **zone** : il n'existe pas de cible « zone », je propose « Plusieurs ».
- **Passifs** (123 compétences, non listés) : cible **Soi**, durée **—**. Ils agissent en permanence, rien n'est affiché.
- **Renforcements sans effet propre** (« Rage contrôlée », « Déchaînement »…) : ils reprennent la cible et la durée de la compétence qu'ils améliorent.
- Déjà renseignée : **Musique vivifiante** (Alliés, Fin du combat, +2 aux attaques si le test réussit). Je l'ai mise à « sans le lanceur » en attendant ta décision.

## Barbare

| Compétence | Cible | Durée | ? |
|---|---|---|---|
| Brutalité | Une | — | |
| Moulinet (niveau 1) | Plusieurs | — | le −2 CA dure-t-il jusqu'au prochain tour ? |
| Charge bestiale | Une | — | |
| Survivant | Une | — | |
| Rage berzerker (niveau 1) | Soi | 1d4 + CON tours | « CON » = modificateur ? |
| Frénésie (niveau 1) | Une | — | |

## Barde

| Compétence | Cible | Durée | ? |
|---|---|---|---|
| Musique vivifiante | Alliés (ou Alliés+ ?) | Fin du combat | le barde en profite-t-il ? |
| Musicien en herbe | Soi | — | |
| Artiste | Une | Indéfinie | illusions hors combat |
| Attaque sautée | Une | — | « ne peut pas se déplacer au tour suivant » : 1 tour pour soi |
| Voltige | Soi | 1 tour | +2 CA jusqu'à son prochain tour |
| Mot d'esprit | Une | 1 tour | −2 aux attaques jusqu'à la fin de son prochain tour (cible ennemie) |
| Charme mineur | Une | Indéfinie | « INT × 10 min » : minutes |

## Chevalier

| Compétence | Cible | Durée | ? |
|---|---|---|---|
| Charge | Une | — | puis −2 CA pour soi jusqu'au prochain tour (1 tour) |
| Piétinement | Une | — | |
| Feinte | Une | 1 action | bonus sur l'attaque du tour suivant |
| Cri de ralliement | Alliés+ ? | 1 tour | +2 CA jusqu'à la fin du tour (bonus de CA pas encore géré) |
| Ordres tactiques | Une | — | un allié |

## Druide

| Compétence | Cible | Durée | ? |
|---|---|---|---|
| Transformation minime | Soi | Indéfinie | « 1d6 min » : minutes |
| Mutation partielle | Soi | Indéfinie | jusqu'à ce qu'il l'annule ? |
| Transformation majeure | Une | Indéfinie | soi ou une cible consentante ; durée non précisée |
| Écorces partagées | Alliés | INT tours | « avec ses alliés » : lanceur déjà protégé par Peau d'écorce |
| Brume | Plusieurs | 1d6 + INT tours | zone autour du groupe |
| Pissenlit protecteur | Plusieurs | 2d6 + INT tours | jusqu'à INT personnes |
| Fruit de la vie | Plusieurs | 1 jour | fruits gardés 1 jour |
| Invocation animal | Soi | Indéfinie | durée de l'invocation non précisée |
| Tempête menaçante | Plusieurs | — | zone de 20 m |
| Se fondre dans la nature | Alliés+ | Indéfinie | **durée non précisée** |
| Lianes immobilisantes | Plusieurs | 1d6/2 tours | ennemis |
| Arbrification | Une | INT tours | soi ou autrui |
| Plante carnivore | Soi | Indéfinie | durée non précisée |

## Guerrier

| Compétence | Cible | Durée | ? |
|---|---|---|---|
| À couvert | Soi | 1 tour | tant qu'il garde le bouclier levé ? |
| Protection | Une | 1 action | intercepte un coup |
| Frappe de précision | Une | — | |
| Coup de boucher | Une | — | |
| Tenir une position | Soi | 1 tour | |
| Posture défensive | Soi | 1 tour | |
| Posture offensive | Soi | 1 tour | |

## Ingénieur

| Compétence | Cible | Durée | ? |
|---|---|---|---|
| Médecin de campagne | Une | — | |
| Projectile explosif | Plusieurs | — | zone de 3-4 m |
| Démolisseur | Une | — | pose : 2 tours |
| Tenir en joue | Une | 1 tour | |
| Pistoléro | Plusieurs | — | 2 tirs |

## Magicien

| Compétence | Cible | Durée | ? |
|---|---|---|---|
| Cercle de protection | Plusieurs | INT + 1d4 tours | jusqu'à INT personnes |
| Téléportation | Plusieurs | — | |
| Boule de feu | Plusieurs | — | zone |
| Mur de flamme | Plusieurs | 1d6 + INT tours | zone |
| Contrôle du feu | Une | — | |
| Élémentaire de feu / pierre / glace / air | Soi | Indéfinie | **durée de l'invocation ou de la forme non précisée** |
| Poing de pierre | Une | — | |
| Prison terrestre | Une | Indéfinie | **durée non précisée** |
| Lance de givre | Une | — | |
| Soutien marin | Une | Indéfinie | « 10 min » : minutes |
| Prison aqueuse | Une | Indéfinie | tant que le sort est maintenu |
| Bourrasque | Plusieurs | — | |
| Mur d'air | Alliés+ | Indéfinie | **durée non précisée** (bonus de CA pas encore géré) |
| Chaîne d'éclairs | Plusieurs | — | |
| Éclat des arcanes | Une | — | |
| Agrandissement | Une | INT tours | un allié ou soi |
| Déchaînement des arcanes | Une | — | zone ? |
| Orbe de lumière | Soi | INT tours | |
| Lueur scintillante | Une | Indéfinie | **durée de l'aveuglement non précisée** |
| Perception vitale | Soi | — | |
| Armure du zénith | Une | INT + RANG tours | bouclier : soi ou un allié |
| Bannissement | Une | — | |

## Moine

| Compétence | Cible | Durée | ? |
|---|---|---|---|
| Frappe de ki | Soi | 1 action | l'attaque suivante |
| Méditation | Soi | — | |
| Projection mentale | Soi | Indéfinie | tant qu'il est maintenu |
| Kenn-do-ha | Plusieurs | — | en ligne droite |
| Rune du berzerker | Soi | Indéfinie | tant qu'active |
| Lancer de shuriken | Une | — | |
| Assaillant fantôme | Une | — | |
| Déferlement de coups | Une | — | |
| Uppercut | Une | — | |
| Lutte | Une | Indéfinie | jusqu'à ce que la cible se libère |

## Nécromancien

| Compétence | Cible | Durée | ? |
|---|---|---|---|
| Toucher nécrotique | Une | 1 tour | nécrose jusqu'à la fin de son prochain tour |
| Récits du passé | Une | Indéfinie | maintenu |
| Afflux mortuaire | Une | — | |
| Présage de mort | Une | INT tours | |
| Fidèle serviteur | Soi | Indéfinie | « temporaire » : **durée non précisée** |
| Fidèle et puissant serviteur | Soi | Indéfinie | idem |
| Serviteur permanent | Soi | Indéfinie | |
| Requiem | Plusieurs | Indéfinie | durée des morts-vivants relevés ? |
| Ténèbres | Plusieurs | Indéfinie | **durée non précisée** |
| Diablotin | Soi | INT + 1d4 tours | |
| Molosse des abysses | Soi | INT + 1d6 tours | |
| Démon | Soi | Indéfinie | **durée non précisée** |
| Rituel du sang | Soi | 1 jour | |
| Rituel des os | Une | 1 jour | « pour la journée » |
| Rituel sanguinaire | Soi | 1 action | la prochaine attaque |
| Rituel de la lune | Soi | — | |
| Rituel abominable | Soi | Indéfinie | **durée non précisée** |

## Prêtre

| Compétence | Cible | Durée | ? |
|---|---|---|---|
| Soin léger | Une | — | |
| Soin modéré | Une | — | |
| Soin de groupe | Plusieurs | — | jusqu'à INT + 1 cibles |
| Guérison | Une | — | |
| Résurrection | Une | — | |
| Bénédiction | Une | 1 jour | arme, armure ou personne ; 2 cibles avec Martyr |
| Délivrance | Une | — | |
| Lien vital | Une | INT tours | |
| Glas de soutien | Plusieurs | Indéfinie | maintenu |
| Lumière sacrée | Une | — | |
| Sanctuaire | Alliés+ | INT tours | zone de 5 m |
| Courroux céleste | Une | — | |
| Justice divine | Soi | Indéfinie | tant qu'il a du mana |
| Paroles impies | Plusieurs | 1 tour | INT ennemis |
| Dissipation | Une | — | |
| Consumation | Une | — | |

## Rôdeur

| Compétence | Cible | Durée | ? |
|---|---|---|---|
| Visée | Une | 1 action | |
| Fuite stratégique | Soi | — | |
| Flèches multiples | Plusieurs | — | |
| Points vitaux | Une | — | |
| Piège | Une | Indéfinie | jusqu'à ce qu'il se déclenche |

## Voleur

| Compétence | Cible | Durée | ? |
|---|---|---|---|
| Coupe-jarret | Une | 1 tour | |
| Dague de verre pourpre | Une | — | |
| Désarmement | Une | — | |
| Botte secrète | Une | — | |
| Sprint | Soi | 1 tour | |
| Distraction charnelle | Une | 1 tour | « perd son tour » ; 2 cibles avec Irrésistible |
| Comme chez soi | Alliés+ | Indéfinie | **durée non précisée** (le temps d'entrer et de sortir) |
| Le roi des roublards | Plusieurs | 1 tour | **durée non précisée** |

## Voies raciales

| Race · Compétence | Cible | Durée | ? |
|---|---|---|---|
| Demi-elfe · Médiateur | Une | 1d4 tours | conflit retardé |
| Demi-elfe · Adaptabilité | Soi | — | |
| Demi-orque · Furie sanguinaire | Une | — | |
| Draconien · Griffes et crocs | Une | — | |
| Draconien · Coup de queue | Une | — | |
| Draconien · Souffle (accroissement) | Plusieurs | 1d6 tours | brûlure, ralentissement : sur la cible |
| Elfe sylvain · Cri sauvage | Soi | — | |
| Elfe sylvain · Amis de la forêt | Plusieurs | — | |
| Haut-elfe · Puits d'arcane | Soi | — | |
| Haut-elfe · Visage impensable | Soi | Indéfinie | **durée non précisée** |
| Gnome · Discussion insensée (combat) | Une | 1 tour | |
| Gnome · Discussion insensée (hors combat) | Une | — | |
| Nain · Tête de fer | Une | — | |

## Sorts de rang 0

| Sort | Cible | Durée | ? |
|---|---|---|---|
| Étincelle, Décharge, Frisson nécrotique, Épine | Une | — | |
| Éclat de givre | Une | 1 tour | |
| Stabilisation | Une | 1 tour | |
| Petit soin | Une | — | |
| Bouclier mineur | Soi | 1 tour | |
| Bénédiction mineure | Une | 1 action | +1 au prochain test |
| Lumière | Une | Indéfinie | « 1 h » : heures |
| Main de mage, Prestidigitation, Ouverture, Pousse | Une | — | |
| Détection de la magie, Langage des bêtes | Soi | — | |
| Murmure | Une | — | |
| Illusion sonore | Une | 1 tour | |
| Charme fugace | Soi | 1 action | +2 au prochain test de SOC |
| Regard troublant | Une | 1 action | −1 au prochain jet d'attaque |
| Souffle de ki | Soi | 1 action | +1 au prochain test de CON ou de DEX |
| Pas léger | Soi | 1 tour | |

## Réponses (19/11/2026)

1. Minutes et heures : **unités ajoutées** (Charme mineur : INT × 10 minutes ; Transformation minime : 1d6 minutes ; Soutien marin : 10 minutes ; Lumière : 1 heure).
2. Pas de cible « zone » : les zones sont **Plusieurs**.
3. Durées non précisées : **Indéfinie**.
4. Une caractéristique dans une durée : **son modificateur**.
5. Musique vivifiante : **alliés, sans le lanceur**.

## Questions posées

1. **Minutes et heures** (Charme mineur, Transformation minime, Soutien marin, Lumière) : ajouter une unité « minutes / heures » ? Sinon, je les mets en « Indéfinie ».
2. **Zones** (Boule de feu, Brume, Tempête, Sanctuaire…) : ajouter une cible « Zone » ? Sinon, « Plusieurs ».
3. **Durées non précisées**, en gras dans les tableaux : élémentaires, invocations « temporaires », Démon, Rituel abominable, Prison terrestre, Lueur scintillante, Ténèbres, Mur d'air, Se fondre dans la nature, Comme chez soi, Le roi des roublards, Visage impensable. Je propose « Indéfinie » (retirée par le joueur ou le MJ), sauf si tu préfères une durée.
4. **« INT », « CON » dans une durée** : le **modificateur** de la caractéristique, 1 au moins (« INT tours » donne 3 tours avec INT 16) ?
5. **Musique vivifiante** : Alliés+ (le barde en profite) ou Alliés (sans lui) ?
