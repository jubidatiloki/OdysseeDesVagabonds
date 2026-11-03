# 01 — Règles générales du système

> Source : SYSTEME.drawio (pages SYSTEME, STATS, SAVOIRS, IDEES) + SYSTEME.pdf. Version de règles : brouillon V1.0.0.
> Légende des marqueurs : ✅ défini · 🟡 partiel / ambigu · ❌ TODO dans la source · ⚠️ incohérence ou point à trancher (voir `00_README_PROJET.md` §5).

## 1. Principes de base

- **Système à d20.** Jet de test = d20 + bonus. `1` naturel = **échec critique**, `20` naturel = **réussite critique**. (La rune de précision du moine modifie ces seuils, voir classes.)
- **Avantage** : on lance 2 dés, on garde le meilleur. **Désavantage** : 2 dés, on garde le pire.
- **Toutes les races et classes sont compatibles entre elles.** Les couleurs du schéma (physique / magique / hybride) ne servent qu'à indiquer la proportion magie / non-magie.
- **Dés de vie (DV) et de mana (DM)** : fixés par la race, puis modifiés par la classe (`+` = dé supérieur, `-` = dé inférieur, `=` = inchangé). **Dé minimum : d4.** Exemple de la source : draconien (DV 8 / DM 4) + magicien (DV `-`, DM `+`) → DV 6 / DM 6.
- **Dé d'endurance (DE)** (03/11/2026) : fixé par la race (d4 gnome ; d6 sinon), inchangé par la classe. Classes physiques : PE sans PM ; lanceurs de sorts : PM sans PE ; hybrides : PM + PE.
- **Niveaux** : de 1 à 10 (la table de points de compétence s'arrête au niveau 10).
- **Langues** : un personnage ne parle que la langue de sa race (sauf humain, et demi-elfe d'origine humaine). 🟡
- **Lire/écrire** : non « inné » si INT < 10.

## 2. Statistiques

### 2.1 Statistiques principales (innées)

| Abr. | Nom | Rôle | Effets mécaniques explicites |
|---|---|---|---|
| AC / AdC | Aptitude de combat | Corps à corps (clé : guerrier, chevalier) | Toucher CaC +AdC (ne défend plus depuis le 29/10/2026) |
| AT / AdT | Aptitude de tir | Distance (clé : ingénieur, rôdeur) | Toucher distance +AdT (ne défend plus depuis le 29/10/2026) |
| AM / AdM | Aptitude magique | Sorts (clé : druide, magicien, nécromancien) | Toucher sorts +AdM (ne défend plus depuis le 29/10/2026) |
| FOR | Force | Puissance musculaire (clé : barbare) | Dégâts CaC +FOR · soulever, immobiliser |
| DEX | Dextérité | Agilité, précision, vitesse (clé : voleur) | Initiative · acrobatie, crochetage, désamorçage de piège, escalade, discrétion, saut, course (vitesse) |
| CON | Constitution | Endurance (clé : barbare, moine) | PV bonus · résistance poison/fatigue, course (endurance), apnée |
| INT | Intelligence | Connaissances, magie des lanceurs (druide, magicien, nécromancien, prêtre) | Défense magique +INT/2 (arrondi sup.) · se souvenir, connaître, apprendre |
| PER | Perception | Percevoir (clé : barde, rôdeur, moine) | Détection de piège/embuscade, trouver objet/personne |
| SOC | Social | Aisance à communiquer (clé : barde, voleur) | Baratiner, bluffer, convaincre, mentir, distraire, obtenir une info |
| MEN | Mental (ancien Charisme, CHA) | Force mentale, conviction | Résister à l'intimidation, aux contrôles mentaux et à la peur |
| CHAN | Chance | Hasard pur, hors compétences | Statistique **non lancée**, valeur **10 par défaut** |

Notes de la source : « renommer CHA → courage ? mental ? » (fait le 29/10/2026 : **MEN, Mental**) ; CHAN est décrite avec humour (« RNG jésus »).
Page STATS : les stats principales sont les entrées de la matrice du §2.4.

### 2.2 Statistiques secondaires (calculées)

| Stat | Formule / règle |
|---|---|
| **PV** (points de vie) | Initial = DV max + DV lancé. À 0 PV → évanouissement 1d6 heures. PV < −DV (en négatif) → mort. Gain par niveau : DV (+ bonus CON). |
| **PM** (points de mana) | Initial = DM max. Régénération = DM PM par nuit de sommeil (÷2 pour une demi-nuit). |
| **PE** (points d'endurance) | Initial = DE max ; + 1 jet de DE par niveau. Régénération = DE PE par nuit de sommeil (÷2 pour une demi-nuit). Dépensés par les compétences. |
| **ESQ** (esquive) | **jet** `1d20 + mod DEX (dans la limite de l'armure) + bonus d'esquive` (refonte du 29/10/2026) ; une seule esquive, pas de valeur fixe. |
| **INIT** (initiative) | `valeur de DEX + bonus d'initiative (compétences, équipement, autres)` (règle du 31/10/2026) : une valeur, **pas de jet**, pas de limite de DEX liée à l'armure. |
| **CA** (classe d'armure) | `10 + CA d'armure + mod DEX (dans la limite de l'armure) + compétences` (refonte du 29/10/2026). Armures : tissu +0 (sans limite), cuir +1 (DEX max +3), cotte de mailles +3 (DEX max +2), plaques +6 (DEX max +1) ; casque et bouclier sans limite de DEX. |

### 2.3 Statistiques tertiaires (brutes)

Réductions de dégâts (RD) : `RD PHY`, `RD MAG`, `RD FEU`, `RD GLACE`, `RD FOUDRE`. Formule commune : `0 + compétence + équipement + autre`.
La RD **chaos est inexistante** : le chaos ignore toute RD.

### 2.4 Matrice « quelle stat influence quoi » (page STATS)

> ⚠️ Historique : depuis la refonte du 29/10/2026, les colonnes ESQ CaC / DIST / MAG / ELEM sont remplacées par **une seule esquive** et la **CA**, qui ne dépendent que de la DEX (limitée par l'armure) ; AdC / AdT / AdM et INT ne défendent plus.

Vert = oui, orange = « ça peut » (idée à valider), rouge/absent = non.

| Stat \ Dérivée | PV | INIT | ESQ CaC | ESQ DIST | ESQ MAG | ESQ ELEM | DMG CaC | PREC CaC | DMG DIST | PREC DIST | DMG MAG | PREC MAG |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| AdC | | | ✅ | | | | | ✅ | | | | |
| AdT | | | | ✅ | | | | | | ✅ | | |
| AdM | | | | | ✅ | | | | | | | ✅ |
| FOR | 🟠 (barbare : « force de la nature ») | | | | | | ✅ | | | | | |
| DEX | | ✅ | ✅ | ✅ | ✅ | ✅ | | | ✅ | | | |
| CON | ✅ | | | | | | 🟠 « frappe lourde ? » | | | | | |
| INT | | | | | | | | | | | 🟠 « dépend du sort » | |
| PER | | | | | | | | | 🟠 « points vitaux » | 🟠 « œil de lynx ? » | | |
| SOC, MEN, CHAN | aucune dérivée de combat | | | | | | | | | | | |

⚠️ La matrice n'indique pas INT → ESQ MAG, alors que la fiche INT dit « défense magique +INT/2 ». À trancher.

## 3. Combat

### 3.1 Économie d'actions

- **3 PA par tour.** Coûts : action gratuite = 0 · action de **mouvement** = 1 · action **simple** = 2 · action **complexe** = 3 (tout le tour).
- **Action de mouvement : déplacement de 10 m** par défaut (règle du 24/10/2026 ; certaines compétences l'augmentent, ex. Colosse infatigable du barbare : +5 m).
- Combinaisons de tour listées : 2 actions de mouvement · 1 mouvement + 1 simple · 1 complexe · + 1 action gratuite en plus de n'importe quelle combinaison. ⚠️ (le total PA autoriserait 3 mouvements)
- Une action d'attaque est une action simple (sauf mention « complexe »).
- Le moule de « sprint » = utiliser ses 2 actions de mouvement dans le même tour.

### 3.2 Types d'attaque et de défense

- **Attaques** : physique (corps à corps / distance) · magique · élémentaire feu · élémentaire glace · élémentaire foudre · **chaos** (ignore toute RD).
- **Défenses** (refonte du 29/10/2026) : la **CA** contre tout ce qui a un jet d'attaque (corps à corps, distance, sort) ; l'**esquive** contre ce qui n'en a pas (souffle, trait des arcanes). Bonus possibles de CA contre un seul type d'attaque (« +2 CA contre les sorts »).
- **Réductions de dégâts** : physique (CaC/distance) · magique · feu · glace · foudre.
- Schéma « défense / esquive / résistance » : *pas de défense* → *donne de la RD* → on peut « percer la RD » avec une attaque *efficace* (contondant contre grosse armure, feu contre un ent…).
- **Types de dégâts d'arme** : tranchant · contondant · perçant.

### 3.3 Esquive (règle détaillée)

- Contre ce qui n'a **pas de jet d'attaque** : **jet d'esquive** de la cible = `1d20 + mod DEX (limitée par l'armure) + bonus d'esquive` contre la difficulté de l'effet (refonte du 29/10/2026).
- Réussite = **annule complètement** les dégâts ou l'effet (**sauf mention contraire** : le *courroux céleste* esquivé fait encore ÷2).
- **1 esquive par tour** (max, sauf mention contraire).
- **Contrecoup** (malus) : pas d'action de mouvement au prochain tour, *quel que soit le résultat du test*.
- Annulation du contrecoup si esquive réussie : voleur (voie du bretteur, rang 3 « appui solide »), barde (voie de l'acrobate, rang 5 « insaisissable »), moine (voie du ninja, rang 5 — ⚠️ non retrouvé dans les compétences ninja listées).

### 3.4 Afflictions

| Affliction | Effet |
|---|---|
| Ralenti | 1 seule action simple **ou** de mouvement par tour (déplacement divisé par 2) |
| Aveuglement léger | −5 à tout ce qui touche à la vue (viser, toucher, observer…) |
| Aveuglement grave | −10 idem |
| Étourdi | Aucune action ; défense réduite à 5 |
| Immobilisation | Action de mouvement impossible |
| Réduit au silence | Incapable de produire un son |
| Réduit au silence magique | Incapable de lancer un sort |

### 3.5 Tailles de créatures

minuscule < 30 cm · petite 30 cm–1,20 m · moyenne 1,20–1,80 m · grande 1,80 m–3/4 m · très grande 3/4–10 m · gigantesque 10–25 m · titanesque > 25 m.
Un « tableau de créatures » (taille × archétype : rapide, puissant…) est annoncé mais **vide** ❌.

### 3.6 Armes à poudre / à feu

Rechargement par défaut : arme **accrochée** = gratuit · **1 main** = action de mouvement · **2 mains** = action complexe.

**Dégâts** (décision du 25/10/2026) : les armes à feu **n'ajoutent pas la DEX** à leurs dégâts, sauf avec *Expertise de la poudre* (ingénieur, voie du chimiste, rang 2). Légères : pétoire, pistolet ; lourdes : mousquet, canon à mains.

### 3.7 Crochetage

Test de DEX. Avec outils : pas de malus. Sans : −10. Échec critique : les outils cassent (sauf voleur, voie du roublard rang 2).

## 4. Magie

### 4.1 Types de compétence

- **Fonctionnement** : *passif* (permanent) · *actif* (à utiliser).
- **Complexité** : *simple* (≈ une action, mouvement possible) · *complexe* (tout le tour) · *gratuite* (ne consomme pas d'action).
- **Type** : *sort* (consomme du mana) · *compétence* (pas de mana).
- **Catégories d'effet** : *renforcement* (ajoute un effet à une action d'attaque/mouvement… ex. frappe de ki, déplacement rapide) · *amélioration* (améliore une compétence déjà apprise) · *soutien* (donne une monture, un familier, un objet).
- **Portée** : soi-même · toucher · corps-à-corps · distance.
- **Durée** (notation) : `T` tour (2T, 1D4T) · `m` minute · `H` heure · `J` jour.

### 4.2 Coût en mana (par rang du sort)

| Rang | Activation | Maintien (par tour) |
|---|---|---|
| 0 | 0 | impossible |
| 1 | 1 | 1 |
| 2 | 3 | 2 |
| 3 | 6 | 3 |
| 4 | 10 | 4 |
| 5 | 15 | 5 |

**Sorts de rang 0** (règle du 24/10/2026) : classes lanceuses de sorts ou hybrides seulement (Druide, Magicien, Nécromancien, Barde, Moine, Prêtre, Voleur), certains réservés à quelques classes ; appris comme une aptitude (1 point de compétence) ; 0 PM ; une fois par tour ; pas de maintien ; dégâts / soins au d4 au plus, sans bonus de caractéristique. Liste : `V1/assets/data/sorts_rang0.json` (22 sorts).

### 4.3 Dépassement de mana / overdose

- Dépasser son mana max n'est **pas possible**, sauf avec la compétence « transfert de mana » du magicien.
- **Overdose magique** : inflige *excédent de mana × 2* en dégâts de **chaos** et détruit le mana en excès.
- Seules les classes de mages (**druide, magicien, nécromancien, prêtre**) peuvent subir une overdose (les autres ne dépendent pas du mana).

### 4.4 Origine du pouvoir

barde / voleur : appât du gain, spectacles, aide d'un mage · druide : nature · magicien : connaissance et apprentissage · nécromancien : connaissance et expérience · prêtre : divinité et croyance.

### 4.5 Parchemins de magie

- Parchemin portant une formule écrite 1+ fois ; **chaque lecture lance le sort et efface une ligne**.
- Seul moyen de lancer de la magie pour les non-mages ; **ne consomme pas de mana** ; 1 ligne = 1 utilisation.
- Nombre de lignes possibles = fonction de la qualité et de la taille du parchemin.
- **Écriture** : matériel d'écriture (parchemin, encre, encrier) valant **10 pa** · connaître le sort · dépenser le mana du sort pour l'infuser.

## 5. Progression

### 5.1 Points de compétence

| Niveau | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Points gagnés | 3 | 2 | 2 | 2 | 3 | 2 | 2 | 2 | 2 | 4 |

Total niveau 10 : **24 points** (l'humain en reçoit 1 de plus au départ).

### 5.2 Coût des rangs d'une voie

| Rang | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Coût | 1 | 1 | 2 | 2 | 3 |

(Une voie complète coûte 9 points.) **Règle de plafond : rang pris ≤ niveau du joueur** (pas de rang 3 au niveau 2).

### 5.3 Voies raciales

Les rangs de la voie raciale sont **débloqués gratuitement aux niveaux impairs** (1, 3, 5, 7, 9 → rangs 1 à 5). 🟡 (interprétation : rang n au niveau 2n−1)

### 5.4 Aptitudes / connaissances apprenables (coût 1 pt chacune)

natation · équitation · maîtrise d'une nouvelle arme · maîtrise d'un instrument · nouvelle langue · connaissance d'un domaine (+5 aux tests liés : géologie, cartographie…) · lire et écrire · autres (accord ou « soudoiement » du MJ).

### 5.5 Savoirs (page SAVOIRS)

| Famille | Sous-type | Règle | Exemples |
|---|---|---|---|
| Connaissances | Basiques | pas de malus sans la maîtrise | cartographie, flore, faune, architecture, une race |
| Connaissances | Complexes | **−5** sans la maîtrise du savoir | géologie, littérature, histoire du continent |
| Aptitudes | Basiques | pas de malus sans la maîtrise | escalade, crochetage (mais malus sans équipement) |
| Aptitudes | Complexes | **−5** sans la maîtrise du savoir-faire | équitation, natation, navigation, maîtrise d'arme, lecture/écriture |
| Instrument | — | **échec automatique** sans la maîtrise ; maîtrisé : **+0** (test 1d20 + DEX) — règle du 23/10/2026 | jouer d'un instrument |

**Attaque à mains nues** (23/10/2026) : **1d4** dégâts physiques + FOR, sauf indication contraire.

Innées : connaissance de sa propre race ; aptitudes : course (vitesse → DEX), course (durée → CON).

## 6. Objets et consommables (règles)

### 6.1 Emplacements d'équipement

casque (1 max) · armure (1 max) · bijou/accessoire (2 max) · boucliers limités seulement par les mains (deux boucliers à une main autorisés, décision du 22/10/2026).
**Mains (22/10/2026)** : un personnage a 2 mains → 1 arme/bouclier à une main **et** 1 arme/bouclier à une main, **ou** 1 arme/bouclier à deux mains. Une arme utilisable à une ou deux mains (bâton) occupe 1 ou 2 mains selon la prise. ⚠️ la page « catégories d'objet » regroupe en plastron / bouclier / accessoires et ne cite pas de casque.

### 6.2 Potions

| Potion | Effet |
|---|---|
| Fer | +5 CA pendant 1D6 heures |
| Feu grégeois | 2D6 de feu sur 3 m |
| Glace condensée | 1D6 de glace sur 3 m + ralenti 1D6 tours |
| Santé | rend 1D8 PV |
| Éclair canalisé | 1D6 de dégâts sur 5 m |
| Réussite | +3 aux prochains jets pendant 5 min |
| Poison | +1D6 DMG de chaos à l'impact + test de CON diff. 15 pour résister (1D6 pendant 1D6 tours) |
| Potions magiques (avec l'aide d'un magicien connaissant le sort) | respiration aquatique, agrandissement, lumière, brume, bannissement |

**Usage** : *boire* (soi-même) · *appliquer* (arme/objet) · *jeter sur une cible ou à ses pieds* (action d'attaque, test de DEX de lancer) · *jeter au sol* (effet selon la potion : santé inutile, brume efficace).
Questions ouvertes : niveau de potion (1–3, peu → très efficace) ; limite de potions portées ; poids (« POIDS : TODO »).
Déblocage des potions par l'ingénieur : santé (chimiste R1), fer (R2), poison (R3), réussite (R4), magiques (R5).

## 7. Idées et TODO globaux (page IDEES)

- Limiter armes et armures selon les races (ex. gnome : armes < d10 de dégâts ; haut-elfe : pas de plaques).
- Faire une **liste de sorts de niveau 0** (accessible aux lanceurs de sorts et classes hybrides).
- Poids/encombrement à définir ; stats du golem ; tableau des créatures ; niveaux de potion.