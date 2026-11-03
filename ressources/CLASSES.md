# Classes — L'odyssée des vagabonds

> Source : SYSTEME.drawio, page CLASSES. Règles communes (rangs, coûts, mana, actions) : voir `01_REGLES_GENERALES.md`.
> Marqueurs : ❌ TODO / vide dans la source · ⚠️ incohérence ou ambiguïté · 🆕 proposition ajoutée (à relire / valider) · *(avancement)* = compétences définies sur 20 (4 voies × 5 rangs).

## Règles communes aux classes

- **Dés** : `+` = dé de vie ou de mana supérieur à celui de la race, `-` = inférieur, `=` = inchangé (minimum d4).
- **Voie** = suite de 5 rangs, coût cumulé 1/1/2/2/3 points ; rang ≤ niveau du personnage.
- Notation des compétences : *(passif)*, *(actif)*, *(gratuit)*, *(complexe)*, *(sort)*, *(compétence)*, *(renforcement)*, *(amélioration)*, *(soutien)* — définitions dans les règles générales.
- **Seules 4 classes lancent des sorts avec mana et subissent l'overdose** : druide, magicien, nécromancien, prêtre. Barde et voleur ont un pouvoir d'origine « mineure ».
- Une classe de **code couleur** (physique / lanceur de sort / physique avec lanceur mineur / hybride) est indiquée dans le schéma ; l'attribution couleur ↔ classe n'a pas pu être extraite du fichier.
- Icônes : barbare (hache à double tranchant) · barde (guitare/luth/lyre) · chevalier (bouclier) · druide (chouette) · guerrier (épée) · ingénieur (engrenage/pistolet) · magicien (bâton) · moine (bandeau/poing) · nécromancien (crâne) · prêtre (croix) · rôdeur (arc) · voleur (dague).

### 🆕 Repères d'équilibrage par rang

| Rang | Puissance visée |
|---|---|
| 1 | Passif +1/rang ou petit utilitaire |
| 2 | Premier actif : ≈ +1d6 DMG, +2/+3 à un test |
| 3 | ≈ 2d6 ou contrôle court |
| 4 | Renforcement marqué ou effet fort, souvent limité (1×/combat) |
| 5 | Capstone : généralement +2 dans 1-2 stats + amélioration d'une compétence antérieure |

## Tableau récapitulatif

| Classe | DV | DM | Maîtrises d'armes | Restriction d'armure | Voies | Avancement |
|---|---|---|---|---|---|---|
| Barbare | + | − | civiles ; mêlée communes (hors poudre) | pas de plaques | brute, athlète, sauvage, berzerker | 20/20 |
| Barde | = | = | civiles ; 1 main communes | pas de plaques | vagabond, musicien, acrobate, courtisan | 20/20 |
| Chevalier | + | − | civiles ; mêlée communes (hors poudre) | aucune | noblesse, cavalerie, duel, commandement | 20/20 |
| Druide | = | + | civiles ; communes | pas de plaques | bestiale, protecteur, nature, végétaux | 20/20 |
| Guerrier | + | − | civiles ; communes | aucune | bouclier, mêlée, guerre, polyvalence | 20/20 |
| Ingénieur | + | − | civiles ; mêlée communes ; poudre ; siège | pas de plaques | artillerie, chimiste, tireur, mécanismes | 20/20 |
| Magicien | − | + | civiles | cuir max | universelle, élément(s), lumière, arcanes | 32/32 |
| Moine | = | = | civiles ; mêlée communes | cuir max | ki, runes, ninja, poing | 20/20 |
| Nécromancien | − | + | civiles | cuir max | mort, morts-vivants, invocation, rituels | 16/20 |
| Prêtre | - | + | civiles ; mêlée communes | cotte de mailles max | soins, paladin, divin, inquisiteur | 20/20 |
| Rôdeur | = | = | civiles ; communes ; distance (hors poudre) | cuir max | archer, chasseur, animaux, trappeur | 20/20 |
| Voleur | = | = | civiles ; communes | cuir max | assassin, bretteur, roublard, séducteur | 20/20 |

« Inventaire de base » : bloc présent pour chaque classe mais **vide** ❌.

---

## Barbare — *Dé de vie +, dé de mana −*

Maîtrises : armes de mêlée civiles et communes (hors poudre). Restriction : pas d'armure de plaques.

### Voie de la brute
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Force de la nature *(passif)* | Peut utiliser CON **ou** FOR pour le gain de PV à chaque niveau. À la prise : ajoute sa FOR à ses PV max. |
| 2 | Brutalité *(actif complexe, compétence)* | Nécessite une arme à 2 mains ; coup puissant : +RANG×2 aux dégâts. |
| 3 | Style barbaresque *(renforcement + passif)* | Ajoute FOR et CON à ses PV gagnés par niveau. Ajoute son mod. de FOR à ses tests de MEN (et à ceux des alliés au contact) pour négocier, persuader, intimider. |
| 4 | Armement barbare *(passif)* | Peut manier une arme à 2 mains dans chaque main : 2 attaques par tour (d12 pour la 2ᵉ), pas d'action de mouvement s'il fait 2 attaques. +5 MEN avec 2 armes à 2 mains équipées. |
| 5 | Légende brutale *(passif + renforcement)* | +2 FOR. Armes à 2 mains dans chaque main **en gardant** son action de mouvement (toujours d12 pour la 2ᵉ attaque). |

### Voie de l'athlète
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Exercices journaliers *(passif)* | 5 min d'exercice le matin : +1 aux tests de FOR, DEX, CON pour la journée. |
| 2 | Moulinet *(actif complexe, compétence)* | Avec une arme à 2 mains, fend l'air devant lui : dégâts −1 par ennemi touché pour le suivant ; défense −2 jusqu'au prochain tour. |
| 3 | Athlétique *(renforcement + passif)* | Bonus des exercices journaliers → +2. +5 aux tests de course, escalade, saut et attaques de lancer (javelot, dague…). |
| 4 | Moulinet mortel *(renforcement)* | Le moulinet n'a plus de dégâts réduits par cible touchée ; 🆕 malus de défense réduit à −1. |
| 5 | 🆕 Colosse infatigable *(passif + renforcement)* | +1 FOR, +1 DEX, +1 CON ; exercices journaliers → +3 ; action de mouvement → 15 m. 🆕 Immunisé à la fatigue liée à la marche et à la course. |

### Voie du sauvage
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Légèreté animale *(passif)* | Armure de cuir (ou moins) : gagne RANG en CA. |
| 2 | Charge bestiale *(actif, compétence)* | Une arme dans chaque main ou une à 2 mains ; charge de 20 m en criant : 1ʳᵉ attaque +3 AdC et +1d6 DMG. |
| 3 | Assaut *(passif)* | Fabrique des armes de siège rudimentaires (bélier en tronc, échelle). +5 aux tests d'attaque et aux dégâts contre bâtiments et structures. |
| 4 | Survivant *(passif)* | 1×/jour, regagne 1d6 PV en tombant à 0 PV. |
| 5 | Prédateur *(passif)* | +1 CON, +1 FOR ; +5 MEN pour effrayer/faire fuir/intimider ; poings létaux (1d4 + FOR + CON) et +3 AdC aux poings. |

### Voie du berzerker
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Rage berzerker *(gratuit, compétence)* | 1×/jour, durée 1D4 + CON tours. **+** : +1d6 DMG par attaque ; insensible aux entraves non magiques (désarmement, assommement, mise au sol…). **−** : −3 CA DIST/MAG/ELEM ; −3 ESQ ; −2 aux tests d'attaque ; n'a pas de distinction ami/ennemi (attaque le plus proche) ; arrêt prématuré = test de CON diff. 15. |
| 2 | Frénésie *(action complexe, compétence)* | Attaque frénétique +1D6 DMG ; sur un 6, relance le dé et cumule. |
| 3 | Rage contrôlée *(renforcement)* | 2×/jour ; durée 1d6 + CON ; +1d8 DMG ; distingue amis/ennemis ; arrêt = CON diff. 12. |
| 4 | Déchaînement *(renforcement)* | La frénésie inflige 2D6 + FOR DMG (relance des 6 toujours possible). |
| 5 | Rage maîtrisée *(passif + renforcement)* | +2 FOR, +2 CON. 3×/jour ; durée 1d6 + FOR + CON ; +1d10 DMG ; plus de malus d'attaque ; arrêt = CON diff. 10. |

---

## Barde — *Dé de vie =, dé de mana =*

Maîtrises : armes civiles, armes à 1 main communes. Restriction : pas de plaques. Origine du pouvoir : appât du gain, spectacles, aide d'un mage.

### Voie du vagabond
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Grand pas *(passif)* | +5 aux tests de CON liés à la marche et à la course. |
| 2 | Légendes et rumeurs *(passif)* | +2/rang aux tests d'INT sur une rumeur entendue en taverne/marché ou sur les légendes anciennes. |
| 3 | Grandes poches *(soutien)* | Sac adapté aux voyages : +10 FOR virtuelle pour le calcul du poids. |
| 4 | Diversité culturelle | Peut prendre une compétence de rang 3 d'une autre classe. |
| 5 | Vagabond *(passif)* | +1 dans chaque stat (« voyager, ça fait grandir »). |

### Voie du musicien
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Début artistique *(soutien)* | Dispose d'un instrument (lyre, flûte, oud, banjo…) ; +2/rang aux tests d'interprétation. |
| 2 | Musique vivifiante *(actif complexe)* | En combat : +2 aux jets d'attaque des alliés à portée d'écoute jusqu'à la fin du combat. |
| 3 | Musicien en herbe *(soutien)* | Gagne 1d20 + CHAN pièces de cuivre (marché/place) ou repas + chambre à l'auberge en jouant (test diff. 10 min., sinon échec). |
| 4 | Artiste *(sort, coût rang 1)* | Petits sorts d'illusion, flammèches… (inefficaces en combat) ; test d'INT diff. 14 pour ne pas être impressionné/distrait. |
| 5 | Musicien renommé *(passif + renforcement)* | Musicien connu, peut être engagé par un noble. Gains = 1d20 + CHAN pièces d'argent. 2 jets pour jouer de son instrument. |

### Voie de l'acrobate
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Début acrobatique *(passif)* | +2/rang aux tests de DEX d'acrobatie, sauts, pirouettes. |
| 2 | Attaque sautée *(actif, compétence)* | +3 AdC et +1d6 DMG, mais ne peut pas se déplacer au tour suivant ; si l'attaque échoue, test de DEX diff. 10 pour ne pas tomber. |
| 3 | 🆕 Voltige *(gratuit)* | 1×/tour, peut traverser ou sauter par-dessus un ennemi ou un obstacle pendant son déplacement sans test. S'il s'est déplacé ce tour : +2 CA CaC jusqu'à son prochain tour. |
| 4 | 🆕 Bond du chat *(renforcement)* | Attaque sautée : plus de malus de déplacement au tour suivant. 🆕 Aucun dégât de chute jusqu'à RANG × 3 m. |
| 5 | Insaisissable *(passif + renforcement)* | +2 DEX ; +1 esquive par tour et pas de contrecoup si esquive réussie. |

### 🆕 Voie du courtisan
| Rang | Compétence | Effet |
|---|---|---|
| 1 | 🆕 Bonnes manières *(passif)* | +1/rang aux tests de SOC en milieu noble ou pour respecter l'étiquette. |
| 2 | 🆕 Mot d'esprit *(actif, compétence)* | Raillerie sur une cible humanoïde qui comprend sa langue : test d'INT diff. 10 + RANG ; en cas d'échec, −2 à ses tests d'attaque jusqu'à la fin de son prochain tour. |
| 3 | 🆕 Mécène *(soutien)* | Un noble le protège : logement en ville, lettres de recommandation, 1d6 pièces d'argent par semaine passée en ville. |
| 4 | 🆕 Charme mineur *(sort, coût rang 2)* | Hors combat. Une cible humanoïde fait un test d'INT diff. 12 + RANG ; en cas d'échec, elle considère le barde comme un ami pendant INT × 10 min. Elle se souvient de tout ensuite. |
| 5 | 🆕 Éminence grise *(passif + renforcement)* | +4 SOC. Le mot d'esprit touche 2 cibles. Le charme mineur dure INT heures. |

---

## Chevalier — *Dé de vie +, dé de mana −*

Maîtrises : armes de mêlée civiles et communes (hors poudre). Restriction : aucune.

### Voie de la noblesse
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Éducation *(passif)* | 🆕 Une connaissance au choix (liste des savoirs) : +1 par rang aux tests liés à cette connaissance. |
| 2 | Arme familiale *(soutien)* | 🆕 Arme de CaC maîtrisée au blason de la maison : arme de maître (+1 AdC), incassable, +5 contre le désarmement, +2 SOC face aux nobles qui connaissent la maison. **Trait de lignée** au choix (niveau I ; II au rang 3, III au rang 5) : *Lignée guerrière* (+1 DMG · 1×/combat relancer les dégâts · +1d6 DMG sur critique) ; *Garde du roi* (+1 CA CaC arme en main · parade 1×/tour −1d6 DMG reçus · +2 CA à un allié au contact) ; *Lame consacrée* (luit 10 m · +1d4 DMG morts-vivants/démons · +2d6) ; *Maison diplomate* (+2 SOC arme visible · +2 MEN intimidation · sauf-conduit 1×/aventure) ; *Héritage élémentaire* feu/glace/foudre (insensible à la chaleur/au froid/aux décharges · +1d4 DMG de l'élément · déchaînement 2d6 au contact 1×/combat) ; *Serment de vengeance* (+1 AdC contre qui a blessé un allié · +2 AdC et +1 DMG · +1d6 DMG à la 1re attaque réussie). |
| 3 | 🆕 Écuyer *(soutien)* | À la prise du rang, trois jeunes gens se présentent (nom et description physique tirés au sort) : le joueur choisit son écuyer, ajouté à l'inventaire comme compagnon. Écuyer PNJ non combattant : porte jusqu'à 30 kg et aide à revêtir l'armure en deux fois moins de temps. Armure entretenue chaque jour : +1 CA. Il entretient l'arme familiale : trait de lignée niveau II. |
| 4 | 🆕 Droit du sang *(passif + renforcement)* | +3 aux tests de SOC face aux autorités. RANG fois par aventure, peut faire jouer son titre de noblesse pour obtenir un logement ou un service (audience, réquisition de chevaux…), à voir avec le MJ. L'arme familiale gagne +1 AdC et +1 DMG. |
| 5 | Titre de noblesse *(passif)* | +2 INT, +2 SOC, renommée ; titre au choix : comte / comtesse, baron / baronne, duc / duchesse (forme selon le sexe du personnage) ; +5 aux tests de SOC face aux personnes un minimum éduquées mais de rang de noblesse inférieur. 🆕 Arme familiale légendaire : nommée, critique sur 19-20, trait de lignée niveau III. |

### Voie de la cavalerie
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Cheval de guerre *(soutien)* | Cheval de bataille et lance d'arçon (1d8, une main) ; sait monter (équitation offerte : maîtrisée). |
| 2 | Charge *(actif)* | 🆕 Monté, après au moins 10 m en ligne droite : +2 AdC et +1d6 DMG (+2d6 à la lance), puis −2 CA jusqu'au prochain tour. |
| 3 | Cavalier émérite *(passif)* | Monté : +2 CA CaC, +3 AdC (+5 AdC au total en charge, avec le +2 de la charge). |
| 4 | 🆕 Piétinement *(gratuit)* | Monté, 1×/tour, la monture frappe une cible de taille moyenne ou moins au contact : 1d8 DMG ; test de FOR diff. 12 ou mise au sol. |
| 5 | Chevalier dragon *(soutien + passif)* | 🆕 +2 SOC. Un drake rejoint le chevalier comme monture (en plus du cheval) (créature volante de grande taille, à négocier avec le MJ) : vole, porte le chevalier + 1 personne, attaque 2d6. Charge en piqué : +3d6 DMG. Les bonus de cavalier émérite s'appliquent en vol. |

### Voie du duel
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Entraînement à la parade *(passif)* | +1 CA CaC par rang **ou** +1 CA DIST par rang. |
| 2 | Ouverture *(passif)* | +2 en attaque pour toucher une cible en armure. |
| 3 | Feinte *(action complexe)* | Attaque normale ; au tour suivant, attaque normale à +5 et +2D6 DMG. |
| 4 | Dehors les importuns ! *(passif + renforcement)* | Contre des groupes de petite/minuscule taille ou de niveau < moitié du sien : +2D6 DMG et +5 CA. Renforcement : ouverture → +4. |
| 5 | Duelliste *(passif)* | En 1 contre 1 clairement identifié : +3 CA, +3 AdC, +1d6 DMG au CaC. |

### Voie du commandement
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Meneur *(passif)* | +1/rang aux tests de SOC pour convaincre/encourager à le suivre. |
| 2 | Montrer l'exemple | 1ʳᵉ fois dans un combat qu'il tue une créature de taille moyenne ou plus : alliés proches +5 à leur prochain jet. |
| 3 | 🆕 Cri de ralliement *(actif)* | 1×/combat : les alliés à portée de voix sont libérés de la peur non magique, gagnent +2 CA jusqu'à la fin du tour et 1d4 + SOC PV temporaires. |
| 4 | 🆕 Ordres tactiques *(action de mouvement)* | 1×/tour, un allié qui l'entend peut faire immédiatement une action de mouvement. À la place, 2×/combat : cet allié fait une attaque avec un d12. |
| 5 | Général des armées | +2 SOC, peut prendre la tête d'une armée, +5 aux tests de SOC pour mener au combat ; +2 AdC, +1D6 DMG, +3 CA aux côtés de soldats sous ses ordres. |

---

## Druide — *Dé de vie =, dé de mana +*

Maîtrises : armes civiles, armes communes. Restriction : pas de plaques. Origine : nature.

### Voie bestiale
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Animal de compagnie *(soutien)* | 🆕 Au choix : jeune ours (FOR), panthère (DEX), sanglier (CON), chouette (INT), aigle (PER), chien (SOC), loup (MEN), lièvre (CHAN) : **+2 aux tests** de cette caractéristique (pas à la caractéristique elle-même : la FOR n'augmente pas les dégâts) ; +4 au rang 3. L'animal suit le druide comme compagnon. |
| 2 | Transformation minime *(sort)* | Se transforme (soi seul) en animal minuscule (souris, chat, moineau, poisson rouge) pendant 1d6 min. |
| 3 | Animal de combat *(passif + renforcement)* | L'animal attaque au tour de son compagnon : +RANG AdC, 1d8 DMG. Renforcement : le bonus aux tests de l'animal de compagnie (rang 1) passe à +4. |
| 4 | Mutation partielle *(sort)* | Change une partie du corps (aile, branchies, patte de lézard pour grimper, patte d'araignée, bras de gorille). |
| 5 | Transformation majeure *(sort)* | Se transforme en grand animal (gorille, loup, lion, requin, aigle royal) ; utilisable sur une autre cible consentante. |

### Voie du protecteur
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Peau d'écorce *(passif)* | +1 CA CaC, +1 CA distance ; +2 au rang 3. |
| 2 | Écorces partagées *(sort)* | Partage le bonus avec ses alliés pendant INT tours. |
| 3 | Brume *(sort)* | Brouillard dense autour du groupe, 1d6 + INT tours : +5 discrétion, −5 AdC, −5 AdT, −5 attaque magique. |
| 4 | Instinct de survie *(passif)* | Frisson à l'approche d'un danger (test PER caché diff. 18 pour savoir s'il est mortel). |
| 5 | Pissenlit protecteur *(sort)* | Pissenlit géant protégeant jusqu'à INT personnes : absorbe jusqu'à 4 × NIVEAU × INT dégâts pendant 2d6 + INT tours. |

### Voie de la nature
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Enfant de la nature *(passif)* | +2/rang aux tests de déplacement (Escalade, Natation, Acrobatie) et de Survie en milieu difficile (collines, montagnes, neige…). |
| 2 | Calme animal *(passif)* | +2/rang aux tests de SOC pour calmer/comprendre les émotions des animaux. |
| 3 | Fruit de la vie *(sort)* | Petit arbre fruitier avec RANG fruits magiques rendant chacun 1d6 + INT PV (1 jour max ; en pleine nature). |
| 4 | Invocation animal *(sort)* | Invoque un animal magique de taille moyenne à ses côtés. |
| 5 | Tempête menaçante *(passif + sort)* | +2 CON. Tempête de bourrasques, éclairs et grêle : 4D6 sur une zone de 20 m de diamètre. |

### Voie des végétaux
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Vie sylvestre *(passif)* | +3 INIT et +2 PER entouré de végétation. |
| 2 | Se fondre dans la nature *(sort pour les alliés)* | +5 discrétion en nature ; (actif) applicable aux alliés. |
| 3 | Lianes immobilisantes *(sort)* | Lianes aux pieds des ennemis : immobilisés 1d6/2 tours (réduit de moitié sur grandes créatures et plus). |
| 4 | Arbrification *(sort)* | Transforme quelqu'un (ou soi) en arbre : ne peut ni agir ni bouger, +10 RD physique, régénère 1d6 PV/tour, durée INT tours ; annulable par le lanceur ; sur autrui : test de CON en opposition. |
| 5 | Plante carnivore *(sort)* | Fait surgir une très grande plante carnivore qui obéit au druide ou attaque les ennemis à portée. |

---

## Guerrier — *Dé de vie +, dé de mana −*

Maîtrises : armes civiles, armes communes. Restriction : aucune. (Posture classique par défaut : sans bonus ni malus.)

### Voie du bouclier
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Formation *(passif)* | Le bouclier n'applique pas d'encombrement de CA. |
| 2 | À couvert *(actif)* | Lève son bouclier pour se déplacer (ou non) à couvert : +3 CA. |
| 3 | Protection *(renforcement)* | S'il ne s'est pas déplacé, fait profiter un allié de sa défense pour intercepter un coup à sa place. |
| 4 | 🆕 Rempart arcanique *(passif)* | Avec un bouclier équipé : +2 CA MAG et +2 CA ELEM. 1×/combat, bloque entièrement un sort d'attaque de rang ≤ 2 visant le guerrier (jet d'AdC contre le jet d'AdM du lanceur). |
| 5 | Égide *(passif + renforcement)* | 🆕 +2 CON. « À couvert » → +5, et les alliés au contact derrière lui gagnent +3. « Protection » utilisable même après un déplacement, jusqu'à 2×/tour. |

### Voie de la mêlée
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Entraînement martial *(passif)* | +1 AdC par rang (au toucher seulement). |
| 2 | Frappe de précision *(actif)* | Attaque avec un d12 ; si touche, +2D6 DMG. |
| 3 | Coup de boucher *(action complexe)* | Attaque brutale : DMG ÷2 (arrondi à l'inférieur), mais sur un d6 de 5-6 le membre est tranché/entaillé (lâche l'arme). |
| 4 | Arme de prédilection *(passif)* | Choisit un type d'arme : +1d4 DMG et +2 AdC (changeable via un maître d'armes). |
| 5 | Ambidextrie *(renforcement)* | 2ᵉ arme à 1 main équipée (épée + pistolet possible) ; attaque avec, au d20, pour une action de mouvement. Coup de boucher : membre tranché sur 4-6 ; critique = membre tranché + dégâts non réduits. |

### Voie de la guerre
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Rangs serrés *(passif)* | +1 CA CaC par allié au contact (max +3). |
| 2 | Contre-attaque *(passif)* | Si une attaque de contact contre lui rate d'au moins 5 sous sa CA : attaque gratuite avec un d12 (1×/tour max). |
| 3 | Contre-attaque améliorée *(renforcement)* | Idem avec un d20, jusqu'à 2×/tour. |
| 4 | Tenir une position *(actif)* | 🆕 Sans déplacement ce tour : +3 CA CaC, +2 AdC, insensible aux repoussements et mises au sol. Un ennemi qui tente de le dépasser au contact subit une attaque gratuite avec un d12. |
| 5 | 🆕 Vétéran des champs de bataille *(passif + renforcement)* | +2 FOR ou +2 CON. Rangs serrés : max +5, et les alliés au contact gagnent +1 CA. Contre-attaque déclenchée par n'importe quelle attaque ratée (toujours 2×/tour). |

### Voie de la polyvalence
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Archerie *(passif)* | Maîtrise de toutes les armes à distance hors siège (arcs, arbalètes, pistolet, mousquet…). |
| 2 | Posture défensive *(gratuit)* | 1×/tour : +3 CA mais pas de sprint (pas 2 actions de mouvement). |
| 3 | Jonglage d'armes *(passif)* | Changer d'arme passe d'action simple à gratuite. |
| 4 | Posture offensive *(gratuit)* | 1×/tour : +3 AdC et +1d6 DMG, mais −3 CA. |
| 5 | Imprévisible *(passif)* | 1×/tour, changer d'arme donne +3 AdC et +3 AdT. |

---

## Ingénieur — *Dé de vie +, dé de mana −*

Maîtrises : armes civiles, mêlée communes, **poudre**, **siège**. Restriction : pas de plaques. Les armes à poudre : voir règles de rechargement.

### Voie de l'artillerie
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Apprenti artilleur | +2/rang aux tests pour maîtriser/utiliser/comprendre une arme de siège ; maîtrise des armes à poudre et de siège. |
| 2 | Canon à mains | Obtient (avec le MJ) un petit canon à mains : boulet, portée 50 m, 3D10 DMG, deux mains, rechargement = action complexe (le rechargement rapide ne marche pas). |
| 3 | Artilleur confirmé *(renforcement)* | Rechargement de canon à 2 mains = action de mouvement ; +2 DMG armes à poudre légères (pétoire, pistolet), +5 DMG lourdes (mousquet, canon). |
| 4 | Médecin de campagne *(complexe)* | Stabilise une personne blessée physiquement et lui rend 4D4 PV. |
| 5 | Artilleur vétéran | Peut commander une unité de siège (légitimité) ; +10 aux attaques contre une structure (arme de siège ou à poudre) ; +5 contre une créature (+10 si grande ou plus, ou très grand groupe). |

### Voie du chimiste
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Chimiste en herbe | +2/rang pour fabriquer poudre ou potions (jets d'Alchimie) ; max RANG×2 potions/jour (bouton « Nouveau jour »), 10 min chacune. Débloque : potion de santé. |
| 2 | Expertise de la poudre | Ajoute sa DEX aux dégâts d'une arme à feu (sans elle, les armes à feu n'ont pas la DEX aux dégâts). Débloque : potion de fer. |
| 3 | Projectile explosif | Petit projectile explosant sur 3-4 m : 2D6 DMG ; fabrication 1 h ; test d'attaque/lancer de DEX. Débloque : potion de poison. |
| 4 | Démolisseur | Charge d'explosif perçant mur, structure ou coffre ; pose 2 tours, fabrication 3 h. Débloque : potion de réussite. |
| 5 | Sapeur | Projectile explosif : rayon 4-6 m, 4d6 dégâts ; améliore démolisseur ; débloque les potions magiques (avec l'aide d'un magicien). |

### Voie du tireur
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Entraînement au tir *(passif)* | +1 AdT par rang avec les armes à feu. |
| 2 | Tenir en joue | Action de mouvement : la cible subit une attaque gratuite de l'ingénieur si elle se déplace. |
| 3 | Pistoléro | Deux armes à feu à une main avec un d12 au lieu du d20 ; 2 tirs possibles comme une action d'attaque (un seul tir : d20 et +2). |
| 4 | Rechargement rapide | Rechargement gratuit après avoir tiré (pas avec 2 armes). Tenir en joue : jusqu'à 3 cibles (une seule réaction de tir par tour). |
| 5 | As de la gâchette | Pistoléro avec d20 (2 armes) ; +2D10 dégâts avec 1 seule arme ; rechargement rapide fonctionne avec 2 armes. |

### Voie des mécanismes
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Mécanicien | +2/rang aux tests de mécanique et de compréhension d'un mécanisme (jets d'Ingénierie et mécanismes). |
| 2 | Physique appliquée | +5 aux tests de FOR ou DEX optimisables par la physique (levier…), applicable au lancer de projectile explosif. |
| 3 | Automate | Fabrique un petit automate d'engrenages et de métal (porte du matériel ou se vend aux riches). |
| 4 | Bidouillage | Améliore une arme à poudre (≈ 10 pa de pièces), une seule amélioration par arme (remplaçable, 10 pa à chaque fois) : crosse modifiée +3 AdT ; canon vissé +1D6 DMG ; chargeur +2 balles sans recharger (augmente d'autant les réactions de « tenir en joue »). |
| 5 | Golem | Construit un golem (un seul à la fois) avec jusqu'à 2 modules : artilleur (canon d'épaule), protecteur (bouclier), mobile (allégé), combattant (armes CaC), mule (buste de rangement). |

🆕 **Statistiques du golem**
- **PV** : 20 + 4 × niveau de l'ingénieur.
- **Défense** : CA CaC/DIST 14, RD physique 3.
- **Attaque** : AdC de l'ingénieur, 1d8 + 2 DMG. Agit à l'initiative de l'ingénieur.
- **Réparation** : 1 h rend 2d6 PV. Vulnérable à la foudre (dégâts ×2).
- **Modules** : *artilleur* canon 2d10, portée 30 m · *protecteur* +3 CA et peut intercepter un coup · *mobile* déplacement ×2, −1 RD · *combattant* 2d6 DMG · *mule* porte 100 kg.

---

## Magicien — *Dé de vie −, dé de mana +*

Maîtrises : armes civiles. Restriction : armure de cuir max. Origine : connaissance et apprentissage. ⚠️ **Pas de sort d'attaque au rang 1.** Le magicien accède aux sorts de rang 0.

Le magicien a une voie universelle et des **voies élémentaires** (« Voie de [élément choisi] » étant un gabarit). Chaque voie élémentaire contient un passif « esprit de … » donnant +1 RD de l'élément par rang.

### Voie de la magie universelle
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Savoir magique *(passif)* | +1/rang aux tests de savoirs occultes/magiques ; accès aux sorts de rang 0. |
| 2 | Cercle de protection *(sort)* | Cercle pour jusqu'à INT personnes : +3 CA MAG aux alliés ; dure INT + 1d4 tours ; brisé si le magicien en sort. Au rang 4 : peut intercepter les sorts visant ses alliés et utiliser sa défense magique. |
| 3 | Transfert de mana *(renforcement + passif)* | Transfère du mana d'une personne à une autre (consentante : action simple ; sinon : attaque magique), débit = DM du magicien par action. Permet de dépasser son mana max sans overdose pendant INT × 2 min. |
| 4 | Téléportation *(sort)* | Téléporte le magicien (+ alliés) sur une grande distance ; coût en mana = N (personnes) × D (km). |
| 5 | Archimage | Titre, +2 INT, +2 AdM ; peut lancer 2 sorts dans un même tour (d12 pour les sorts d'attaque magique, effets ÷2 pour les autres, pas de déplacement). |

### Voie du feu
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Boule de feu *(sort)* | Projetée jusqu'à 20 m : 1d6 DM FEU (modulable aux rangs suivants : [RAND]d6 avec coût de mana adapté). |
| 2 | Esprit du Phénix *(passif)* | Tatouages rouges ; +1 RD feu par rang. |
| 3 | Mur de flamme *(sort)* | Mur large de 1d8 + INT m pendant 1d6 + INT tours ; 3d6 de feu à qui le traverse. |
| 4 | Contrôle du feu *(renforcement)* | Intensifier, éteindre, donner une forme (contrôle minimal au coût d'un rang 1). |
| 5 | Élémentaire de feu *(sort)* | Invoquer ou se transformer en élémentaire. |

### Voie de la terre
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Poing de pierre *(complexe)* | Bras en pierre : 2d6 DM PHY. |
| 2 | Esprit de Gaïa *(passif)* | Tatouages verts ; +1 RD physique par rang. |
| 3 | Prison terrestre *(sort)* | Le sol s'ouvre sous une cible (taille moyenne max ; grande au rang 4). |
| 4 | Sens tellurique *(renforcement)* | Détecte tout mouvement sur/sous le sol : 20 m par minute de concentration. |
| 5 | Élémentaire de pierre *(sort)* | Invoquer ou se transformer en élémentaire. |

### Voie de l'eau
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Lance de givre *(sort)* | Lance de glace : 1d6 DM GLACE. |
| 2 | Esprit de Neptune *(passif)* | Tatouages bleus ; +1 RD glace par rang. |
| 3 | Soutien marin | Respire sous l'eau 10 min sans gêne ; (actif) peut en faire profiter autrui par un sort. |
| 4 | Prison aqueuse *(sort maintenu + renforcement)* | Sphère d'eau autour d'une cible pour la noyer/blesser (2d6 par tour tant que le sort est maintenu), ou la vider de son eau. Renforcement : la lance de givre peut transpercer sa cible et toucher une 2ᵉ cible derrière elle. |
| 5 | Élémentaire de glace *(sort)* | Invoquer ou se transformer en élémentaire. |

### Voie de l'air
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Bourrasque *(sort)* | Repousse jusqu'à RANG + AdM cibles sur RANG × 2 m max. |
| 2 | Esprit de Zéphyr *(passif)* | Tatouages blancs ; +1 RD foudre par rang. |
| 3 | Mur d'air *(sort)* | Dévie les projectiles vers le mage et ses alliés proches : +10 CA contre projectiles (magiques ou physiques). |
| 4 | Chaîne d'éclairs *(sort)* | Éclair sur un ennemi rebondissant sur jusqu'à 3 autres cibles : 3d6 foudre (attaques magiques avec −3 par rebond, dégâts −2 par nouvelle cible). |
| 5 | Élémentaire d'air *(sort)* | Invoquer ou se transformer en élémentaire. |

### Voie des arcanes
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Éclat des arcanes *(sort)* | Éclat de magie pure inesquivable : 1d4 DM MAG ; renforcé aux rangs 3 et 5. |
| 2 | Esprit arcanique *(passif)* | Tatouages violets ; +1 RD magique par rang. |
| 3 | Agrandissement *(sort)* | Accroît la taille d'un allié (ou soi) ; renforcement éclat des arcanes : 2D4 DM. |
| 4 | Artéfact magique *(renforcement)* | 🆕 Lie un focaliseur (bâton, anneau ou orbe) : +2 AdM ; −1 mana sur les sorts des arcanes (min. 1). 1×/jour, stocke un sort de rang ≤ 2 et le libère sans action. L'éclat des arcanes peut toucher une 2ᵉ cible. |
| 5 | Déchaînement des arcanes *(sort)* | Explosion désintégrante : 5d6 + INT DMG ; renforcement éclat des arcanes : 3d4 + INT DM magiques. |

### Voie de la lumière
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Orbe de lumière *(sort)* | Orbe lumineux flottant pendant INT tours. |
| 2 | Lueur scintillante *(sort)* | Aveugle ou dissipe des ténèbres. |
| 3 | Perception vitale *(sort)* | Perçoit nombre et direction approximative des êtres vivants jusqu'à RANG × 10 m. |
| 4 | Armure du zénith *(sort)* | Orbe de lumière dure INT + RANG tours. 🆕 1×/combat, l'orbe se change en bouclier sur soi ou un allié : absorbe 10 + INT × 2 dégâts ; tout ennemi qui le frappe au CaC est ébloui (−2 AdC à son tour suivant). *(Ancienne valeur « 20 + INT × RANG » jugée trop forte pour un rang 4.)* |
| 5 | Bannissement | +2 INT, +2 AdM ; lève l'invocation d'une entité (coût = coût du rang du sort d'invocation). |

---

## Moine — *Dé de vie =, dé de mana =*

Maîtrises : armes civiles, mêlée communes. Restriction : armure de cuir max.

### Voie du ki
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Frappe de ki *(renforcement d'attaque, sort)* | Lancé avant l'attaque (sort de rang 1) : ajoute 1 dé de mana aux dégâts de l'attaque suivante. Ajoute son dé de mana aux dégâts de ses attaques. |
| 2 | Méditation *(complexe)* | Médite une petite heure pour regagner 1 DM de mana (le dé est ajouté aux PM, sans dépasser le maximum). |
| 3 | Projection mentale *(actif, sort, maintenu)* | Projette son esprit en boule de lumière intangible (2× plus rapide, distance illimitée mais limitée par le mana) ; voit à travers. Dégâts magiques déduits du mana, surplus ×2 sur ses PV. |
| 4 | Kenn-do-ha *(complexe, sort)* | Attaque magique : boule de ki en ligne droite, 4 DM + INT (dé de mana) ; peut transpercer en perdant 1 DM par cible. |
| 5 | Mental d'acier | Augmente le dé de mana ; immunisé aux attaques magiques de l'esprit/des sens (contrôle mental, peur magique). |

### Voie des runes
Peut activer **1 rune** (2 au rang 4). Activer/désactiver demande 5 min de concentration. Inspiré des formes d'Udyr.
| Rang | Rune | Effet |
|---|---|---|
| 1 | Rune d'aptitude (bras) | Au choix : +1 AdC/rang, ou +1 AdT/rang, ou +1 AdM/rang (au toucher seulement). |
| 2 | Rune de défense (dos) | +1 classe d'armure par rang. |
| 3 | Rune de précision (mains/poignets) | Critique +2 **et** échec critique sur 2 (1 ou 2 = échec critique ; réussite critique par défaut sur 18-19-20). |
| 4 | Rune de vitesse (jambes) | +5 initiative, +5 aux tests de vitesse et dextérité (course, nage…), **−3 aux tests de CON**. |
| 5 | Rune du berzerker (épaules) | 1 attaque supplémentaire par tour, mais −3 CA (−1 CA avec la rune de défense) tant qu'active (avec la rune de défense : +2 CA pour les deux). |

### Voie du ninja
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Mouvement de shinobi *(passif)* | +3 initiative ; +1d6 DMG si attaque sa cible avant qu'elle agisse. |
| 2 | L'art du camouflage *(passif)* | +5 discrétion, camouflage, déplacement silencieux. |
| 3 | Lancer de shuriken *(gratuit)* | 1×/tour, shuriken à 10 m (pas au CaC) : 1d4 + DEX ; bonus d'initiative → +5. |
| 4 | Déplacement rapide *(renforcement)* | Action de mouvement → 15 m ; peut courir sur les murs jusqu'à 15 m. |
| 5 | Assaillant fantôme *(actif)* | 2×/combat, attaque presque intangible traversant résistances et armure ; jusqu'à 2 shurikens par tour ; plus de contrecoup d'esquive. |

### Voie du poing
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Pugilat *(amélioration + passif)* | Coups de poing létaux au choix ; dégâts 1d4 + FOR → 1d6 + FOR ; +RANG AdC à mains nues. |
| 2 | Déferlement de coups *(complexe)* | RANG coups de poing sur une cible (FOR non appliquée, 1 jet d'attaque par coup). |
| 3 | Uppercut *(actif)* | 2D6 + FOR×2. |
| 4 | Lutte *(actif)* | Attrape et immobilise : attaque +5 ; chaque tour, test de FOR +5 contre le test de FOR de la cible. |
| 5 | Poing de fer *(renforcement)* | Poing 1d8 + FOR ; déferlement 1d8 ; uppercut 3d6. |

---

## Nécromancien — *Dé de vie −, dé de mana +*

Maîtrises : armes civiles. Restriction : armure de cuir max. Origine : connaissance et expérience. Citation d'ambiance : « il n'y a pas d'innocent, simplement des degrés de culpabilité » (voir prêtre).

### Voie de la mort
| Rang | Compétence | Effet |
|---|---|---|
| 1 | 🆕 Toucher nécrotique *(actif, sort)* | Attaque magique au contact : 1d6 DM ; la cible ne peut pas regagner de PV jusqu'à la fin de son prochain tour. |
| 2 | Siphon d'âme *(renforcement)* | Quand une créature meurt près de lui, son âme est visible ; une action de mouvement pour l'absorber et se soigner (soin selon la taille : petite 1d4, moyenne 1d6, grande 2d6). |
| 3 | Récits du passé *(actif + maintien)* | Appelle un fantôme depuis un cadavre pour lui parler. |
| 4 | Afflux mortuaire | Vague d'énergie funèbre : rend 3D6 + INT à un être non vivant ou démoniaque, ou inflige 3D6 + INT à une créature vivante non démoniaque. |
| 5 | Présage de mort *(actif complexe)* | 🆕 +2 INT. 1×/jour, attaque magique marquant une cible vivante pendant INT tours : tous les dégâts qu'elle subit gagnent +1d6. Si elle tombe à 2 × NIVEAU PV ou moins : test de CON diff. 15 + INT, sinon elle meurt. Créatures uniques / boss immunisés à la mort (mais pas au bonus de dégâts). |

### Voie des morts-vivants
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Perception nécrotique | Perçoit nombre et direction grossière des créatures mortes jusqu'à RANG × 10 m. |
| 2 | Fidèle serviteur *(actif)* | Relève un cadavre de taille moyenne (temporaire). |
| 3 | 🆕 Maître des cadavres *(renforcement)* | « Fidèle serviteur » relève jusqu'à 2 cadavres moyens ; les serviteurs gagnent +2 AdC et +5 PV. |
| 4 | Fidèle et puissant serviteur *(actif)* | Relève un cadavre de grande taille (temporaire). **Serviteur permanent** : en sacrifiant 1d4 PV max, relève de façon permanente un serviteur plus grand et plus fort. Un seul serviteur permanent à la fois ; s'il est tué, le nécromancien récupère les PV max sacrifiés. |
| 5 | Requiem *(complexe)* | Chant ramenant les morts : petite armée de morts-vivants. |

### Voie de l'invocation
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Familier *(soutien)* | 🆕 Petit esprit ou créature au choix (corbeau, rat, chat noir, crâne flottant) : +2 PER ; avec concentration, voit par ses yeux jusqu'à 50 m ; porte de petits objets. Détruit : réinvocable après 1 jour. |
| 2 | Ténèbres | Brouillard de ténèbres qui aveugle tous (sauf le lanceur) ou dissipe une lumière magique. |
| 3 | 🆕 Diablotin *(actif, sort)* | Invoque un diablotin volant pendant INT + 1d4 tours : attaque 1d6 feu infernal ; se dissipe à 0 PV. |
| 4 | 🆕 Molosse des abysses *(actif, sort)* | Invoque un chien infernal de taille moyenne pendant INT + 1d6 tours : attaque 2d6, perçoit les créatures invisibles. |
| 5 | Démon | Invoque un démon. |

### Voie des rituels
Rituels hors combat.
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Rituel du sang *(actif)* | Dépense 1d4 PV (au lieu de mana) : invoque une épée sanguine d'outre-tombe, 1d6 + INT, reste 1 jour. |
| 2 | Rituel des os *(actif)* | Os humains/animaux renforçant une personne ou créature : +2 RD physique pour la journée. |
| 3 | Rituel sanguinaire *(actif)* | Dépense 1d10 PV : marque de sang sur une arme ; la prochaine attaque explose en 2d6 + INT DMG magique (+1d6 sur l'épée sanguine). |
| 4 | Rituel de la lune *(actif)* | De nuit en extérieur, coûte du mana : surface réfléchissante pour trouver une personne/objet, test d'AdM diff. 10 à 30 (selon le MJ). |
| 5 | Rituel abominable | Invoque une abomination à partir de cadavres. |

> Avancement 16/20 : les rangs « Démon » (invocation 5), « Requiem » (morts-vivants 5) et « Rituel abominable » (rituels 5) ont un titre mais pas encore de chiffrage.

---

## Prêtre — *Dé de vie −, dé de mana +*

Maîtrises : armes civiles, mêlée communes. Restriction : cotte de mailles max. Origine : divinité et croyance.

### Voie des soins
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Soin léger *(actif, sort)* | Soigne une cible au contact de 1D6 PV. |
| 2 | Soin modéré *(actif, sort)* | Soigne une cible jusqu'à RANG × 10 m de 2D6 PV. |
| 3 | Soin de groupe *(actif, sort)* | Soigne jusqu'à INT+1 cibles à 20 m autour du prêtre de 2D6 PV. |
| 4 | Guérison *(actif, sort)* | Soigne 5D6 PV une cible au contact et guérit les maladies non magiques et magiques mineures. |
| 5 | Résurrection *(complexe)* | Ranime une créature morte. |

### Voie du paladin
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Bénédiction *(actif)* | Pour la journée, au choix : arme +1 DMG et +1 AdC/AdT ; armure +1 CA ; personne : bloque le prochain sort d'attaque direct de rang 1. |
| 2 | Délivrance *(actif)* | Attaque magique opposée à un jet précédent pour arrêter l'effet d'un sort durable. |
| 3 | Lien vital *(actif + renforcement)* | Lie un allié au prêtre : le prêtre prend ses dégâts, INT tours. Renforcement bénédiction : +2 et sort de rang 2. |
| 4 | Glas de soutien *(actif, sort)* | Soigne jusqu'à INT+1 cibles à 20 m de 1D10 PV (maintenable pour soigner chaque tour). |
| 5 | 🆕 Martyr *(renforcement)* | Lien vital utilisable dans l'autre sens (test d'attaque magique si lancé sur un ennemi). 🆕 +2 CON ; la bénédiction peut viser 2 cibles. |

### Voie du divin
| Rang | Compétence | Effet |
|---|---|---|
| 1 | 🆕 Foi *(passif)* | +1 CA MAG par rang et +1/rang aux tests de connaissance religieuse. |
| 2 | 🆕 Lumière sacrée *(actif, sort)* | Attaque magique à 20 m : 1d8 dégâts de chaos, doublés contre morts-vivants et démons. |
| 3 | 🆕 Sanctuaire *(actif, sort)* | Zone de 5 m autour du prêtre pendant INT tours : morts-vivants et démons doivent réussir un test de MEN diff. 10 + INT pour y entrer ; les alliés à l'intérieur gagnent +2 CA MAG. |
| 4 | Courroux céleste *(actif, sort)* | Éclair divin : attaque magique, 4D6 dégâts de chaos ; si esquivé, dégâts ÷2 (« personne n'échappe à la colère divine »). |
| 5 | Justice divine *(soutien)* | Arme d'énergie divine pure d'un autre plan (la saisir/ranger = action de mouvement) : 2D6 + FOR + INT de chaos, 5 mana par attaque ; quiconque d'autre la touche subit 1D6 chaos ; sans mana suffisant elle repart. |

### Voie de l'inquisiteur
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Prémices de l'inquisition *(passif)* | +2 AdC et +2 tests d'attaque magique contre morts-vivants et démons. |
| 2 | Paroles impies *(actif)* | Sermon interdit immobilisant INT ennemis dans 10 m jusqu'au prochain tour (test de CON diff. 10 + INT pour s'en libérer). |
| 3 | Dissipation *(actif, sort)* | Dissipe un sort ou une transformation mineure (sorts de rang ≤ 3) ; coût = coût du sort. |
| 4 | Consumation *(actif)* | Attaque magique : retire 3D6 mana à la cible (inutile contre les non-lanceurs). |
| 5 | Inquisition *(passif + renforcement)* | +2 INT ; paroles impies diff. 15 + INT ; dissipation possible sur les sorts de rang 4 et 5. |

---

## Rôdeur — *Dé de vie =, dé de mana =*

Maîtrises : armes civiles, communes, armes à distance (hors poudre). Restriction : armure de cuir max.

### Voie de l'archer
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Précision *(passif)* | +1 AdT par rang. |
| 2 | Visée *(complexe)* | Sans action de mouvement ce tour : avantage à son test d'attaque à distance. |
| 3 | Fuite stratégique *(gratuit)* | 1×/combat, action de mouvement supplémentaire pour fuir. |
| 4 | Flèches multiples *(complexe)* | Au choix : 3 flèches sur 3 cibles différentes, ou 2 flèches sur la même cible. |
| 5 | Points vitaux *(renforcement + complexe)* | +2 PER ; vise les points vitaux : ajoute la PER aux DMG + 1d6. |

### Voie du chasseur
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Pistage *(passif)* | +2/rang aux tests de PER pour pister/suivre des traces, et aux tests d'INT pour interpréter les traces. |
| 2 | Proie favorite *(passif)* | +2 AdC, +2 AdT, +1d4 DM contre une proie définie à la prise. |
| 3 | Armement *(renforcement)* | Maîtrise de l'arbalète et du fusil (mousquet). |
| 4 | Chasseur expérimenté *(renforcement)* | Proie favorite : 2 proies ; +4 et +1d6 DM. |
| 5 | Chasseur de gros gibier | +2D6 DMG contre les ennemis de grande taille ou plus. |

### Voie des animaux
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Compagnon animal *(passif + soutien)* | +5 tests de PER ; animal terrestre (taille max : loup). |
| 2 | Communication avec les animaux *(passif)* | +2/rang aux tests de SOC/INT pour les comprendre, et de SOC pour se faire comprendre/obtenir leur aide. |
| 3 | Compagnon adulte *(renforcement)* | Buff + peut attaquer. 🆕 Attaque : +RANG AdC, 1d6 DMG (volontairement sous l'animal de combat du druide, 1d8). |
| 4 | 🆕 Chasse en meute *(passif)* | Si le rôdeur et son compagnon attaquent la même cible dans le tour : +2 AdC pour les deux et −2 CA pour la cible jusqu'au prochain tour. 1×/combat, le compagnon peut intercepter un coup destiné au rôdeur. |
| 5 | Compagnon géant *(renforcement)* | Buff + peut servir de monture. |

### Voie du trappeur
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Dépeçage *(renforcement)* | +2/rang pour dépecer correctement peau et viande (revente possible). |
| 2 | Piège *(actif)* | 🆕 Pose un collet ou un piège à mâchoires (1 min hors combat, ou action complexe). La victime fait un test de PER diff. 10 + RANG pour le repérer ; sinon 1d6 + RANG DMG et immobilisée (test de FOR diff. 12 pour se libérer). Max RANG pièges posés. |
| 3 | 🆕 Affût *(passif)* | +5 discrétion en nature s'il reste immobile ; sa première attaque depuis l'affût gagne +1d6 DMG. |
| 4 | Survivaliste *(passif)* | Maîtrise de la Survie et avantage à ses jets de Survie (abri de fortune, nourriture). |
| 5 | 🆕 Maître trappeur *(passif + renforcement)* | +2 PER. Pièges : 2d6 + RANG, posables en combat avec une action de mouvement, peuvent être enduits de poison ou piégés avec un explosif d'ingénieur. Max RANG × 2 pièges. |

---

## Voleur — *Dé de vie =, dé de mana =*

Maîtrises : armes civiles, communes. Restriction : armure de cuir max. Origine du pouvoir : appât du gain, spectacles, aide d'un mage.

### Voie de l'assassin
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Attaque dans le dos *(renforcement)* | +1D4/rang DMG sur une attaque dans le dos. |
| 2 | Fourberie *(renforcement)* | Test de discrétion pour se cacher (pénombre, recoin, pilier) : l'ennemi perd sa trace et doit réussir un test de PER (ne fonctionne que si le voleur n'est pas sa seule cible). |
| 3 | Coupe-jarret *(action)* | Attaque d12 : la cible n'a pas d'action de mouvement au prochain tour (à faire 2× sur un quadrupède ou une grande créature+). |
| 4 | 🆕 Embuscade *(passif)* | Au 1er tour d'un combat où il n'a pas été repéré : +5 AdC et +2d6 DMG ; l'attaque dans le dos s'applique quelle que soit sa position. |
| 5 | Dague de verre pourpre *(complexe)* | Au prix de 5 DV, imprègne une dague de son envie de tuer (maniable seulement par son créateur, sinon elle se brise) : +5 AdC ; se brise dans la cible et les éclats gagnent son cœur : 1 DMG chaos au 1ᵉʳ tour, doublé chaque tour jusqu'à l'arrêt du cœur. Seuls un prêtre et un ingénieur combinés peuvent l'arrêter ; la cible reste soignable. |

### Voie du bretteur
| Rang | Compétence | Effet |
|---|---|---|
| 1 | 🆕 Escrime *(passif)* | +1 AdC/rang avec une arme légère à une main (rapière, dague, épée courte), si la main secondaire est libre ou tient une dague. |
| 2 | 🆕 Riposte *(passif)* | Après une attaque ratée contre le voleur : attaque gratuite avec un d12, 1×/tour. |
| 3 | Appui solide *(renforcement)* | +1 esquive par tour ; pas de contrecoup d'esquive si l'esquive réussit. |
| 4 | 🆕 Désarmement *(actif + renforcement)* | Attaque d12 contre l'arme de la cible ; si elle touche, test de DEX du voleur contre FOR ou DEX de la cible : l'arme est projetée à 1d6 m. Riposte désormais avec un d20. |
| 5 | Botte secrète *(complexe)* | 🆕 +2 DEX. 1×/combat, attaque inesquivable : +5 AdC et +3d6 DMG ; sur un critique, la cible perd son prochain tour. |

### Voie du roublard
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Vol à la tire *(passif)* | +1/rang (test de DEX). |
| 2 | Crochetage *(passif)* | +1/rang pour crocheter + kit de crochetage ; les outils ne cassent plus sur échec critique. |
| 3 | Sprint *(gratuit)* | 1×/combat, au choix : +1 action de mouvement ce tour, ou +2 actions de mouvement (mais aucune au tour suivant). |
| 4 | Comme chez soi *(passif)* | +5 en DEX, FOR et discrétion pour entrer/sortir d'un bâtiment non autorisé (le voleur + son groupe après un briefing). |
| 5 | Le roi des roublards *(passif + renforcement)* | 2d20 au vol à la tire (garde le meilleur) ; sprint : peut distraire un ennemi pour faire profiter ses alliés ciblés des mêmes bonus de mouvement. |

### Voie du séducteur
| Rang | Compétence | Effet |
|---|---|---|
| 1 | Beau parleur *(passif)* | +1/rang aux tests de SOC pour baratiner, mentir. |
| 2 | 🆕 Faux-semblants *(passif + soutien)* | Kit de déguisement ; +2/rang aux tests de déguisement et d'imitation de voix ou d'accent. |
| 3 | Distraction charnelle | Sur cible humanoïde. **Combat** (1×/combat/cible, action de mouvement, compétence) : test d'INT de la cible diff. 10 + RANG, échec = perd son tour. **Hors combat** (1×/cible) : test d'INT diff. 10 + RANG ; échec = +5 SOC du voleur contre son admirateur ; réussite = nouveau test pour comprendre la manœuvre, si réussi : −5 SOC et −5 MEN du voleur contre cette personne. |
| 4 | Réseau d'information *(passif + renforcement)* | +5 pour obtenir des informations en ville/village. Distraction charnelle : combat → diff. 10 + SOC + RANG ; hors combat : pas de bonus de SOC mais 2 jets d'INT (garde le pire). |
| 5 | 🆕 Irrésistible *(passif + renforcement)* | +4 SOC. Distraction charnelle en combat : 2 cibles. 1×/aventure, une cible qui rate la distraction hors combat devient un allié dévoué tant que le voleur ne la trahit pas ouvertement. |
