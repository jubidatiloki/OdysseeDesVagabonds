# Règles du système

> Version des règles : brouillon V1.0.0, avec les décisions du 19 et du 20/10/2026.

## Dés et principes de base

- **Système à d20** : un test = 1d20 + bonus.
- Un **20** naturel est une **réussite critique**, un **1** naturel un **échec critique**. (La rune de précision du moine modifie ces seuils.)
- **Avantage** : on lance 2 dés et on garde le meilleur. **Désavantage** : 2 dés, on garde le pire.
- Toutes les races et toutes les classes sont compatibles entre elles.
- **Niveaux** : de 1 à 10.
- **Langues** : un personnage ne parle que la langue de sa race (sauf l'humain, et le demi-elfe d'origine humaine).
- **Lire et écrire** n'est pas inné si l'INT est inférieure à 10.

## Dés de vie, de mana et d'endurance

- Le **dé de vie (DV)**, le **dé de mana (DM)** et le **dé d'endurance (DE)** sont fixés par la race, puis modifiés par la classe : `+` dé supérieur, `−` dé inférieur, `=` inchangé.
- **Mana ou endurance selon la classe** : les classes **physiques** n'ont pas de mana (ni DM ni PM) mais de l'**endurance** (DE, PE) ; les **lanceurs de sorts** ont du mana mais pas d'endurance ; les **hybrides** ont les deux (PM + PE).
- DE des races : **d4** pour le gnome ; **d6** pour toutes les autres. Aucune classe ne modifie le DE (`=`).
- Dé minimum : **d4**.
- Exemple : draconien (DV 8 / DM 4) + magicien (DV −, DM +) → DV 6 / DM 6.
- À la création, le DV compte pour sa **valeur maximale**. Ensuite (montée de niveau, repos), on **lance** le dé.

## Statistiques principales

| Abr. | Nom | Rôle | Effets |
|---|---|---|---|
| AdC | Aptitude de combat | Corps à corps | Toucher CaC |
| AdT | Aptitude de tir | Distance | Toucher à distance |
| AdM | Aptitude magique | Sorts | Toucher des sorts |
| FOR | Force | Puissance musculaire | Dégâts CaC ; soulever, immobiliser |
| DEX | Dextérité | Agilité, précision, vitesse | Initiative, esquive, CA ; acrobatie, crochetage, discrétion, escalade, saut, course |
| CON | Constitution | Endurance | PV ; résistance au poison et à la fatigue, apnée |
| INT | Intelligence | Connaissances | Se souvenir, connaître, apprendre |
| PER | Perception | Percevoir | Détecter un piège ou une embuscade, trouver un objet ou une personne |
| SOC | Social | Communiquer | Baratiner, bluffer, convaincre, mentir, distraire |
| MEN | Mental | Force mentale, conviction | Résister à l'intimidation, aux contrôles mentaux et à la peur |
| CHAN | Chance | Hasard pur | Non lancée, **10 par défaut** |

### Création des statistiques

- Toutes les statistiques démarrent à **10**. Le joueur répartit **12 points**.
- Maximum **16** dans une statistique, à la création seulement.
- La **CHAN** n'est pas modifiable, et on ne peut pas baisser une statistique sous 10.
- Les modificateurs de race (et d'origine) s'appliquent **à la fin** et peuvent faire dépasser 16.

### Modificateur

- À partir de 10, **2 points = 1 de bonus ou de malus** : 8 → −1, 10 → +0, 12 → +1, 14 → +2, 16 → +3.
- Valeurs impaires arrondies à l'inférieur : 7 → −2, 9 → −1, 11 → +0, 13 → +1.
- Formule : `modificateur = ⌊(valeur − 10) / 2⌋`.
- Dans une règle, **« une stat » désigne son modificateur**, sauf mention contraire (y compris pour les attaques).
- Les « /2 » sont **arrondis au supérieur** (↑).

## Statistiques calculées

`mod(X)` = modificateur de la statistique X. « bonus » = compétences, équipement…

| Statistique | Formule |
|---|---|
| PV max (niveau 1) | DV max + mod(CON) |
| PV max (niveaux suivants) | + 1 jet de DV par niveau |
| PM max (niveau 1) | DM max |
| PM max (niveaux suivants) | + 1 jet de DM par niveau |
| PE max (niveau 1) | DE max (classes physiques et hybrides) |
| PE max (niveaux suivants) | + 1 jet de DE par niveau |
| Initiative | **valeur** de DEX + bonus d'initiative (pas de jet ; pas de limite liée à l'armure) |
| Toucher au corps à corps | 1d20 + mod(AdC) + bonus |
| Toucher à distance | 1d20 + mod(AdT) + bonus |
| Toucher magique | 1d20 + mod(AdM) + bonus |
| Classe d'armure (CA) | 10 + CA d'armure (armure, bouclier, casque) + mod(DEX) **dans la limite de l'armure** + bonus |
| Jet d'esquive | **1d20** + mod(DEX) **dans la limite de l'armure** + bonus d'esquive (un jet, pas de valeur fixe) |
| Dégâts au corps à corps | + mod(FOR) |
| Dégâts à distance | + mod(DEX) |
| Dégâts magiques | + mod(INT) |

### Réductions de dégâts

- RD physique, magique, feu, glace, foudre : `0 + compétences + équipement + autres`.
- Tout dégât est **physique** sauf indication contraire ; la RD du type de dégâts se retire du total (minimum 0).
- Il n'existe **pas de RD chaos** : le chaos ignore toute réduction de dégâts.

## Vie, mana, endurance et repos

- À **0 PV** : évanouissement pendant 1d6 heures. En dessous de **−DV** : mort.
- **Nuit de sommeil** : rend 1 jet de DV + mod(CON) PV, **DM** PM et **DE** PE.
- **Demi-nuit** : rend 1 jet de DV en PV (sans la CON), **DM ÷ 2** PM et **DE ÷ 2** PE.
- **Points d'endurance (PE)** : dépensés par les compétences des classes physiques et hybrides (coût indiqué sur la compétence : « Moulinet : 2 PE ») ; impossible d'utiliser la compétence sans assez de PE.
- **Sorts raciaux d'une classe physique** (sans mana) : payés en **PE**, au même coût (Cri sauvage : 3 PE).
- Impossible de dépasser son mana maximum (sauf « transfert de mana » du magicien).

## Combat

### Actions

- **3 points d'action (PA)** par tour, mais **2 actions de mouvement au maximum**.
- Action **gratuite** : 0 PA · action de **mouvement** : 1 PA · action **simple** : 2 PA · action **complexe** : 3 PA (tout le tour).
- Une **action de mouvement** permet de se **déplacer de 10 mètres** par défaut (certaines compétences augmentent cette distance).
- Une attaque est une action simple, sauf mention « complexe ».
- **Sprint** : utiliser ses 2 actions de mouvement dans le même tour.

### Attaques et défenses

- **Attaques** : physique (corps à corps ou distance), magique, feu, glace, foudre, **chaos** (ignore toute RD).
- **Défenses** : la **CA** contre tout ce qui a un **jet d'attaque** (corps à corps, distance, sort) ; l'**esquive** contre ce qui n'en a pas (souffle, trait des arcanes…). Certaines compétences donnent de la CA contre un seul type d'attaque (« +2 CA contre les sorts »).
- **Types de dégâts d'arme** : tranchant, contondant, perçant.
- **Attaque à mains nues** : **1d4** dégâts physiques + FOR (sauf indication contraire).
- Une attaque *efficace* peut « percer » une RD (contondant contre une grosse armure, feu contre un ent…).

### Armures

| Armure | CA | DEX max |
|---|---|---|
| Tissu | +0 | sans limite |
| Cuir | +1 | +3 |
| Cotte de mailles | +3 | +2 |
| Plaques | +6 | +1 |

Le bonus de DEX à la CA et à l'esquive ne dépasse pas la limite de l'armure portée (un malus de DEX compte en entier). Casque et bouclier ajoutent leur CA sans limiter la DEX.

### Esquive

- Contre ce qui n'a **pas de jet d'attaque** : la cible fait un **jet d'esquive** = 1d20 + mod(DEX) (limitée par l'armure) + bonus d'esquive, contre la difficulté de l'effet.
- Réussite : **annule complètement** les dégâts ou l'effet (sauf mention contraire).
- **1 esquive par tour** au maximum (sauf mention contraire).
- **Contrecoup** : pas d'action de mouvement au tour suivant, quel que soit le résultat. Certaines compétences l'annulent en cas de réussite (voleur, barde, moine).

### Armes à poudre

- Rechargement d'une arme **accrochée / légère** : gratuit.
- Arme à **une main** : une action de mouvement.
- Arme à **deux mains** : une action complexe.

### Crochetage

- Test de **DEX**. Avec des outils : pas de malus. Sans outils : **−10**.
- Échec critique : les outils cassent (sauf voleur, voie du roublard rang 2).

## Afflictions

| Affliction | Effet |
|---|---|
| Ralenti | 1 seule action simple **ou** de mouvement par tour (déplacement divisé par 2) |
| Aveuglement léger | −5 à tout ce qui touche à la vue (viser, toucher, observer…) |
| Aveuglement grave | −10 à tout ce qui touche à la vue |
| Étourdi | Aucune action ; défense réduite à 5 |
| Immobilisation | Action de mouvement impossible |
| Réduit au silence | Incapable de produire un son |
| Réduit au silence magique | Incapable de lancer un sort |

## Tailles de créatures

| Taille | Mesure |
|---|---|
| Minuscule | moins de 30 cm |
| Petite | 30 cm à 1,20 m |
| Standard (moyenne) | 1,20 m à 1,80 m |
| Grande | 1,80 m à 3-4 m |
| Très grande | 3-4 m à 10 m |
| Gigantesque | 10 m à 25 m |
| Titanesque | plus de 25 m |

## Magie

### Types de compétence

- **Fonctionnement** : *passif* (permanent) ou *actif* (à utiliser).
- **Complexité** : *simple* (une action), *complexe* (tout le tour), *gratuite* (ne consomme pas d'action).
- **Type** : *sort* (consomme du mana) ou *compétence* (sans mana).
- **Catégories d'effet** : *renforcement* (ajoute un effet à une action), *amélioration* (améliore une compétence apprise), *soutien* (monture, familier, objet).
- **Portée** : soi-même, toucher, corps à corps, distance.
- **Durées** : `T` tour, `m` minute, `H` heure, `J` jour (ex. 2T, 1D4T).

### Coût en mana

| Rang du sort | Activation | Maintien (par tour) |
|---|---|---|
| 0 | 0 PM | impossible |
| 1 | 1 PM | 1 PM |
| 2 | 3 PM | 2 PM |
| 3 | 6 PM | 3 PM |
| 4 | 10 PM | 4 PM |
| 5 | 15 PM | 5 PM |

**Sorts de rang 0** : petits sorts des classes magiques et hybrides, appris comme une aptitude (**1 point de compétence**) ; **0 PM**, **une fois par tour**, **pas de maintien** ; dégâts et soins au **d4** au plus, sans bonus de caractéristique. Liste dans le Glossaire, onglet Compétences, filtre « Sorts mineurs ».

### Overdose magique

- Dépasser son mana maximum inflige **excédent × 2** dégâts de **chaos** et détruit le mana en trop.
- Seules les classes de mages (druide, magicien, nécromancien, prêtre) peuvent subir une overdose.

### Origine du pouvoir

- Barde et voleur : appât du gain, spectacles, aide d'un mage.
- Druide : nature. Magicien : connaissance et apprentissage.
- Nécromancien : connaissance et expérience. Prêtre : divinité et croyance.

### Parchemins de magie

- Chaque lecture lance le sort et **efface une ligne** ; ne consomme pas de mana.
- Seul moyen de lancer un sort pour les non-mages.
- Écriture : matériel d'écriture (**10 pa**), connaître le sort, dépenser son mana pour l'infuser.

### Invocations et transformations

- Chaque créature invoquée ou compagnon a sa **fiche** (bouton « Statistiques » de la compétence). Les compagnons non combattants n'ont que des **PV**.
- Compagnons du druide et du rôdeur : attaque **1d20 + RANG + AdC du maître**. Créatures invoquées par un sort : leur propre toucher.
- Durée d'une invocation sans durée écrite : **INT + 1d6 tours**.
- **Transformation** : une forme à la fois ; ses bonus comptent tant qu'elle est active (forme activée sur la fiche ou la page dé).
- **Agrandissement** : taille +1 catégorie, **+4 FOR, +4 CON, −2 DEX** pendant INT tours. Lancé sur un allié : il le coche dans **« Effets reçus »** sur sa fiche.

## Progression

### Points de compétence

| Niveau | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Points gagnés | 3 | 2 | 2 | 2 | 3 | 2 | 2 | 2 | 2 | 4 |

- Total au niveau 10 : **24 points** (+1 au départ pour l'humain).
- Pas d'obligation de tout dépenser : les points restants sont conservés.

### Voies

| Rang | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Coût | 1 | 1 | 2 | 2 | 3 |

- Une voie complète coûte 9 points. Les rangs se prennent **dans l'ordre**, et **rang ≤ niveau**.
- **Voie raciale** : rangs offerts gratuitement aux niveaux impairs (1, 3, 5, 7, 9).

### Aptitudes et connaissances (1 point chacune)

- Natation, équitation, maîtrise d'une arme ou d'un instrument, nouvelle langue, lire et écrire.
- **Instrument** : non maîtrisé → **échec automatique** ; maîtrisé → **+0** (test 1d20 + DEX).
- Connaissance d'un domaine : **+5** aux tests liés (géologie, cartographie…).
- Autre, avec l'accord du MJ.

### Savoirs

| Famille | Sous-type | Sans la maîtrise | Exemples |
|---|---|---|---|
| Connaissances | Basiques | pas de malus | cartographie, flore, faune, architecture |
| Connaissances | Complexes | −5 | géologie, littérature, histoire du continent |
| Aptitudes | Basiques | pas de malus | escalade, crochetage (malus sans équipement) |
| Aptitudes | Complexes | −5 | équitation, natation, navigation, maîtrise d'arme, lecture |

## Objets et potions

### Emplacements d'équipement

- Casque (1), armure (1), bijoux ou accessoires (2).
- Boucliers : limités seulement par les mains (deux boucliers à une main possibles).
- **Deux mains** : une arme ou un bouclier à une main dans chaque main, **ou** une seule arme ou un seul bouclier à deux mains. Une arme utilisable à une ou deux mains (bâton) occupe une ou deux mains selon la prise.
- Poids : illimité en V1.

### Utiliser une potion

- **Boire** (soi-même) ou **appliquer** (sur une arme, un objet).
- **Jeter** sur une cible ou à ses pieds : action d'attaque, test de DEX.
- **Jeter au sol** : l'effet dépend de la potion (santé inutile, brume efficace).
- La liste des potions est dans la page **Équipements**.
