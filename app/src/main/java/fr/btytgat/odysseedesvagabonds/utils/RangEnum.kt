package fr.btytgat.odysseedesvagabonds.utils

import fr.btytgat.odysseedesvagabonds.database.entities.Rang

enum class RangEnum (var rang: Rang) {
    RANG_1_BESTIALE(
        Rang(
            "RANG_1_BESTIALE",
            "Animal de compagnie",
            1,
            "(soutien) au choix:\n" +
                    "panthère: +2 tests DEX \n" +
                    "loup: +2 tests CHA \n" +
                    "aigle: +2 tests PER\n" +
                    "autres? (négociation avec le MJ)"
        )
    ),
    RANG_2_BESTIALE(
        Rang(
            "RANG_2_BESTIALE",
            "Transformation minime",
            2,
            "transformation (pour soi uniquement) en un animal minuscule, souris, chat, moineau, poisson rouge"
        )
    ),
    RANG_3_BESTIALE(
        Rang(
            "RANG_3_BESTIALE",
            "Mutation partielle",
            3,
            "change une partie du corps (aile, branchies, patte de lézard pour escalader, patte d'araignées, bras de gorille)"
        )
    ),
    RANG_4_BESTIALE(
        Rang(
            "RANG_4_BESTIALE",
            "Animal de combat",
            4,
            "buff de l'animal de compagnie"
        )
    ),
    RANG_5_BESTIALE(
        Rang(
            "RANG_5_BESTIALE",
            "Transformation majeure",
            5,
            "transformation en grand animal (gorille, loup, lion, requin, aigle royal) + utilisable sur une autre cible consentante"
        )
    ),


    RANG_1_PROTECTEUR(
        Rang(
            "RANG_1_PROTECTEUR",
            "Peau d'écorces",
            1,
            "(passif) +1 DEF CaC, +1 DEF distance. passe à +3 au rang 3"
        )
    ),
    RANG_2_PROTECTEUR(
        Rang(
            "RANG_2_PROTECTEUR",
            "Ecorces partagés",
            2,
            "(actif) possibilité de partagés le bonus avec ses alliés pour INT tours"
        )
    ),
    RANG_3_PROTECTEUR(
        Rang(
            "RANG_3_PROTECTEUR",
            "Brume",
            3,
            "(actif) invoque un brouillard dense autour du groupe pendant 1d6 + INT tours, +5 discrétion, -5 AdC, -5 AdT, -5 tests d'attaque magique"
        )
    ),
    RANG_4_PROTECTEUR(
        Rang(
            "RANG_4_PROTECTEUR",
            "Instinct de survie",
            4,
            "(passif) frisson lorsqu'un danger approche (test diff 18 de PER (caché) pour savoir s'il est mortel ou non)"
        )
    ),
    RANG_5_PROTECTEUR(
        Rang(
            "RANG_5_PROTECTEUR",
            "Pissenlit protecteur",
            5,
            "(actif) un pissenlit géant pousse autour du lanceur (ou d'une cible) afin de protéger de dégâts extérieurs max INT personnes,  jusqu'à 4 x NIVEAU x INT DMG pendant 2d6 + INT tours"
        )
    ),


    RANG_1_NATURE(
        Rang(
            "RANG_1_NATURE",
            "Enfant de la nature",
            1,
            "(passif) +2 / rang aux tests de déplacements et de survies en environnement difficiles (collines, montagnes, neiges, ... )"
        )
    ),
    RANG_2_NATURE(
        Rang(
            "RANG_2_NATURE",
            "Calme animal",
            2,
            "(passif) +2 / rang aux tests de SOC pour calmer et comprendre les émotions des animaux (faim, peur, curiosité, ...)"
        )
    ),
    RANG_3_NATURE(
        Rang(
            "RANG_3_NATURE",
            "Fruit de la vie",
            3,
            "(actif) fait pousser un petits arbres fruitiers contenant RANG fruits magique qui rendent chacun 1d6 + INT PV (se conserve 1 journée max, nécessite d'être dans la nature, entouré de végétation)\n" +
                    "au rang 5, possibilité de soigner le poison"
        )
    ),
    RANG_4_NATURE(
        Rang(
            "RANG_4_NATURE",
            "Invocation animale",
            4,
            "(actif) invoque un animal magique de taille moyenne au côté du joueur "
        )
    ),
    RANG_5_NATURE(
        Rang(
            "RANG_5_NATURE",
            "Tempête menaçante",
            5,
            "(passif) +2 CON\n" +
                    "(complexe) Le druide prépare une tempête faite de bourrasque et d'éclairs et de grêle, représente la colère et la puissance de la nature, inflige 4D6 sur une zone de 20m de diamètre"
        )
    ),


    RANG_1_VEGETAUX(
        Rang(
            "RANG_1_VEGETAUX",
            "Vie sylvestre",
            1,
            "(passif) +3 INIT et +2 tests de PER si entouré de végétation"
        )
    ),
    RANG_2_VEGETAUX(
        Rang(
            "RANG_2_VEGETAUX",
            "Se fondre dans la nature",
            2,
            "(passif) +5 discrétion pour se fondre dans la nature, peut l'appliquer à ses alliés "
        )
    ),
    RANG_3_VEGETAUX(
        Rang(
            "RANG_3_VEGETAUX",
            "Lianes immobilisantes",
            3,
            "(actif) fait pousser des lianes très rapidement aux pieds de ses énemis les empechant de bouger pendant 1d6 / 2 tours (réduits par 2 sur les grandes et+ créatures) "
        )
    ),
    RANG_4_VEGETAUX(
        Rang(
            "RANG_4_VEGETAUX",
            "Arbrification",
            4,
            "(actif) transformation qn ou soi meme en arbre, l'empêchant d'agir ou de bouger, gagne 10 de RD physique, régénère 1d6 PV par tour, peut être annulé par le lanceur,  si c'est qn d'autre test d'opposition de CON  et dure INT tours. "
        )
    ),
    RANG_5_VEGETAUX(
        Rang(
            "RANG_5_VEGETAUX",
            "Plante carnivore",
            5,
            "(actif) fait sortir de sol une très grandes plantes carnivores qui obéit au druide ou attaque les ennemis à portée"
        )
    ),


    RANG_1_ARTILLERIE(
        Rang(
            "RANG_1_ARTILLERIE",
            "Apprenti artilleur",
            1,
            "+2 / rang au test liés au fait de maitriser, utiliser et comprendre le fonctionnement d'une arme de siège"
        )
    ),
    RANG_2_ARTILLERIE(
        Rang(
            "RANG_2_ARTILLERIE",
            "Canon à mains",
            2,
            "obtient à canon à main qui peut tirer un boulet, portée 40m, 3D10 DMG,  (rechargement rapide ne marche pas sur ce canon)"
        )
    ),
    RANG_3_ARTILLERIE(
        Rang(
            "RANG_3_ARTILLERIE",
            "Artilleur confirmé",
            3,
            "(renforcement) rechargement canon à 2 mains = action de mouvement\n" +
                    "+2 DMG avec des armes à poudre légères\n" +
                    "+5 DMG avec des armes à poudres lourdes"
        )
    ),
    RANG_4_ARTILLERIE(
        Rang(
            "RANG_4_ARTILLERIE",
            "Médecin de campagne",
            4,
            "(complexe) peut stabiliser une personne blessé physiquement et lui rend 3D4 PV"
        )
    ),
    RANG_5_ARTILLERIE(
        Rang(
            "RANG_5_ARTILLERIE",
            "Artilleur vétéran",
            5,
            "peut prendre la tête d'une unité de siège (légitimité / pas de négociation à faire)\n" +
                    "+10 tests d'attaque pour toucher un batiment avec une arme de siège ou à poudre\n" +
                    "+5 tests d'attaque pour toucher une créatures"
        )
    ),


    RANG_1_CHIMISTE(
        Rang(
            "RANG_1_CHIMISTE",
            "Chimiste en herbe",
            1,
            "+2 / rang au test pour réaliser de la poudre à canon, pour les armes à feu ou pour réaliser des potions, fabrication max RANG potions par jour, 10min de préparation pour chaque\n" +
                    "+ déblocage: potion de santé"
        )
    ),
    RANG_2_CHIMISTE(
        Rang(
            "RANG_2_CHIMISTE",
            "Expertise de la poudre",
            2,
            "ajoute sa DEX au dégâts d'une arme à feu\n" +
                    "+ déblocage: potion de fer "
        )
    ),
    RANG_3_CHIMISTE(
        Rang(
            "RANG_3_CHIMISTE",
            "Projectile explosif",
            3,
            "permet de fabriquer un petit projectile qui explose à l'impact sur un rayon de 3-4m, en infligeant 2D6 DMG, temps de fabrication d'un projectile = 1h, test d'attaque / lancer de DEX\n" +
                    "+ déblocage: potion de feu poison (utilisable par les alliés)"
        )
    ),
    RANG_4_CHIMISTE(
        Rang(
            "RANG_4_CHIMISTE",
            "Démolisseur",
            4,
            "permet de fabriquer une charge d'explosif permettant de percer un mur, une structure ou un coffre,  temps d'installation d'une charge = 2 tours, temps de fabrication d'une charge = 3h\n" +
                    "+ déblocage: potion de réussite"
        )
    ),
    RANG_5_CHIMISTE(
        Rang(
            "RANG_5_CHIMISTE",
            "Sapeur",
            5,
            "amélioration projectile explosif: le rayon passe à 4-6m, les dégats passe à 4d6\n" +
                    "+ amélioration démolisseur\n" +
                    "+ déblocage: potions magiques (nécessite l'aide d'un magicien connaissant le sort)"
        )
    ),


    RANG_1_TIREUR(
        Rang(
            "RANG_1_TIREUR",
            "Entraînement au tir",
            1,
            "+1 AdT / rang avec des armes à feu"
        )
    ),
    RANG_2_TIREUR(
        Rang(
            "RANG_2_TIREUR",
            "Tenir en joue",
            2,
            "action de mouvement: tient en joue une cible, qui subit une attaque gratuite de l'ingénieur s'il se déplace"
        )
    ),
    RANG_3_TIREUR(
        Rang(
            "RANG_3_TIREUR",
            "Pistoléro",
            3,
            "peut utiliser deux armes à feu à une main en même temps en utilisant un D12 au lieu d'un D20 pour toucher sa cible, 2 tirs possibles dans le tour comme une action d'attaque (si un seul tir --> D20 et un bonus supplémentaire de +2)"
        )
    ),
    RANG_4_TIREUR(
        Rang(
            "RANG_4_TIREUR",
            "Rechargement rapide",
            4,
            "rechargement gratuit après avoir tiré (ne marche pas avec 2 armes équipés)\n" +
                    "+ amélioration tenir en joue: peut tenir 3 cibles proches en joue (ne peut tirer qu'une fois en réaction dans un tour)"
        )
    ),
    RANG_5_TIREUR(
        Rang(
            "RANG_5_TIREUR",
            "As de la gâchette",
            5,
            "amélioration pistoléro: utilise des D20 (avec 2 armes équipés) et ajoute 2D10 dégâts avec 1 seule arme équipé \n" +
                    "+ amélioration rechargement rapide: marche dorénavant avec 2 armes équipés"
        )
    ),


    RANG_1_MECANIQUE(
        Rang(
            "RANG_1_MECANIQUE",
            "Mécanicien",
            1,
            "+2 / rang aux tests liés à la mécanique et à la compréhension d'un mécanisme (engrenage, piston, marchines, ...)"
        )
    ),
    RANG_2_MECANIQUE(
        Rang(
            "RANG_2_MECANIQUE",
            "Physique appliquée",
            2,
            "+5 aux tests de FOR ou DEX  / pouvant être optimisé par des connaissances physique poussées (utiliser un levier pour soulever qch de lourd, peut s'appliquer au lancer de projectile explosif)"
        )
    ),
    RANG_3_MECANIQUE(
        Rang(
            "RANG_3_MECANIQUE",
            "Automate",
            3,
            "permet de fabriquer un petit automate d'engrenage et de métal qui peut porter du matériel ou tout simplement être vendu à des riches "
        )
    ),
    RANG_4_MECANIQUE(
        Rang(
            "RANG_4_MECANIQUE",
            "Bidouillage",
            4,
            "peut améliorer une arme à poudre pour l'équivalent de 10pa de pièces) :\n" +
                    "crosse modifiée : +3AdT\n" +
                    "canon vissé: +1D6 DMG\n" +
                    "chargeur: peut tirer 2 balles de plus sans recharger (augmente d'autant le nombre de réaction avec tenir en joue dans un même tour)"
        )
    ),
    RANG_5_MECANIQUE(
        Rang(
            "RANG_5_MECANIQUE",
            "Golem",
            5,
            "l'ingénieur peut se construire une golem et lui installer un module permettant de le spécialiser :\n" +
                    "- artilleur -> canon sur l'épaule\n" +
                    "- protecteur -> bouclier sur le bras\n" +
                    "- mobile -> allégement de la structure, moins encombrant et moins gêné par les endroit exigus\n" +
                    "- combattant -> armes de CaC ou mains faite pour se battre\n" +
                    "- mûle -> buste ouvrable faisant office de rangement"
        )
    ),


    RANG_1_FEU(
        Rang(
            "RANG_1_FEU",
            "Esprit du Phoenix",
            1,
            "(passif) Le mage gagne petit à petit une résistance au dégâts de feu, cela s'illustre par des tatouages magiques rouge sur son corps. +1 RD feu / rang"
        )
    ),
    RANG_2_FEU(
        Rang(
            "RANG_2_FEU",
            "Boule de feu",
            2,
            "(actif) boule de feu qui fait plus de dégat au rang 4"
        )
    ),
    RANG_3_FEU(
        Rang(
            "RANG_3_FEU",
            "Mur de flamme",
            3,
            "(actif) crée un mur de flamme jusqu'à 1d8 + INT mètres de large pendant 1d6 + INT tours, qui inflige 3d6 de feu à ceux qui veulent le traverser"
        )
    ),
    RANG_4_FEU(
        Rang(
            "RANG_4_FEU",
            "Contrôle du feu",
            4,
            "(renforcement) pour intensifier, éteindre, donner une forme (controle minimal (cf doigt briquet, a le cout en mana d'un rang 1) permet de donner une forme au mur de flamme\n"
        )
    ),
    RANG_5_FEU(
        Rang(
            "RANG_5_FEU",
            "Elémentaire de feu",
            5,
            "(actif) invoquer ou se transformer en élémentaire"
        )
    ),


    RANG_1_TERRE(
        Rang(
            "RANG_1_TERRE",
            "Esprit de Gaia",
            1,
            "(passif) Le mage gagne petit à petit une résistance au dégâts physique, cela s'illustre par des tatouages magiques vert sur son corps. +1 RD physique / rang"
        )
    ),
    RANG_2_TERRE(
        Rang(
            "RANG_2_TERRE",
            "Prison terrestre",
            2,
            "(actif) ouvre le sol sous les pieds d'une cible pour l'emprisonner (taille moyenne max, rang 4 taille grande max)"
        )
    ),
    RANG_3_TERRE(
        Rang(
            "RANG_3_TERRE",
            "Poing de pierre",
            3,
            "(actif) poing de pierre qui sort du sol pour frapper une cible"
        )
    ),
    RANG_4_TERRE(
        Rang(
            "RANG_4_TERRE",
            "Sens tellurique",
            4,
            "(renforcement) permet de détecter tout mouvement sur et sous le sol, détection sur 100m / min passé à se concentrer dessus"
        )
    ),
    RANG_5_TERRE(
        Rang(
            "RANG_5_TERRE",
            "Elémentaire de pierre",
            5,
            "(actif) invoquer ou se transformer en élémentaire"
        )
    ),


    RANG_1_EAU(
        Rang(
            "RANG_1_EAU",
            "Esprit de Neptune",
            1,
            "(passif) Le mage gagne petit à petit une résistance au dégâts de glace, cela s'illustre par des tatouages magiques bleus sur son corps. +1 RD glace / rang"
        )
    ),
    RANG_2_EAU(
        Rang(
            "RANG_2_EAU",
            "Lance de givre",
            2,
            "(actif) lance de givre, qui peut transpercer une cible au rang 4 (et toucher 2 cibles du coup)"
        )
    ),
    RANG_3_EAU(
        Rang(
            "RANG_3_EAU",
            "Soutien marin",
            3,
            "(passif) peut respirer sous l'eau 10min sans gêne (puis applique la gestion de la respiration sous l'eau normalement)\n" +
                    "(actif) peut, en lançant un sort, permettre à lui-même ou qn d'autre d'en profiter"
        )
    ),
    RANG_4_EAU(
        Rang(
            "RANG_4_EAU",
            "Prison aqueuse",
            4,
            "(actif) créer une sphère d'eau autour d'une cible afin de la blesser/noyer"
        )
    ),
    RANG_5_EAU(
        Rang(
            "RANG_5_EAU",
            "Elémentaire de glace",
            5,
            "(actif) invoquer ou se transformer en élémentaire"
        )
    ),


    RANG_1_AIR(
        Rang(
            "RANG_1_AIR",
            "Esprit de Zephyr",
            1,
            "(passif) Le mage gagne petit à petit une résistance au dégâts de foudre, cela s'illustre par des tatouages magiques blancs sur son corps. +1 RD foudre / rang"
        )
    ),
    RANG_2_AIR(
        Rang(
            "RANG_2_AIR",
            "Murmures du vent",
            2,
            "TODO"
        )
    ),
    RANG_3_AIR(
        Rang(
            "RANG_3_AIR",
            "Mur d'air",
            3,
            "(actif) dévie les projectiles qui arrive dans la direction du mage et de ses alliés proches de lui, +10 de DEF contre les projectiles\n" +
                    "au rang 5, le mur d'air donne également +5 DEF élémentaire"
        )
    ),
    RANG_4_AIR(
        Rang(
            "RANG_4_AIR",
            "Chaine d'éclairs",
            4,
            "(actif) projette un éclair sur un ennemi, qui peut se projeter sur jusqu'à 3 autres cibles (jet d'attaques magiques pour les suivants avec malus de -3 à chaque rebond et dégats réduits de 2 par nouvelles cibles)"
        )
    ),
    RANG_5_AIR(
        Rang(
            "RANG_5_AIR",
            "Elémentaire d'air",
            5,
            "(actif) invoquer ou se transformer en élémentaire"
        )
    ),


    RANG_1_ARCANES(
        Rang(
            "RANG_1_ARCANES",
            "Esprit arcanique",
            1,
            "(passif) Le mage gagne petit à petit une résistance au dégâts à la magie, cela s'illustre par des tatouages magiques violets sur son corps. +1 RD magique/ rang (non élémentaire)"
        )
    ),
    RANG_2_ARCANES(
        Rang(
            "RANG_2_ARCANES",
            "Eclat des arcanes",
            2,
            "(actif) tire un éclat de magie pure qui ne peut être esquivé, renforcé au rang 4"
        )
    ),
    RANG_3_ARCANES(
        Rang(
            "RANG_3_ARCANES",
            "Esprit arcanique",
            3,
            "(actif) accroit la taille d'un allié (ou lui-même)"
        )
    ),
    RANG_4_ARCANES(
        Rang(
            "RANG_4_ARCANES",
            "Artéfact magique",
            4,
            "TODO"
        )
    ),
    RANG_5_ARCANES(
        Rang(
            "RANG_5_ARCANES",
            "Déchainement des arcanes",
            5,
            "(actif) déchainement de puissance arcanique qui provoque une explosion désintégrant ce qu'elle touche, 5d6 + INT DMG"
        )
    ),


    RANG_1_MAGIE_UNIVERSELLE(
        Rang(
            "RANG_1_MAGIE_UNIVERSELLE",
            "Savoir magique",
            1,
            "(passif) +1 / RANG aux tests liés aux connaissance et savoirs occultes ou liés à la magie"
        )
    ),
    RANG_2_MAGIE_UNIVERSELLE(
        Rang(
            "RANG_2_MAGIE_UNIVERSELLE",
            "Cercle protection",
            2,
            "(actif) créer un cercle pouvant contenir jusqu'à INT personnes, pour qui il donne +3 à la DEF MAG aux autres joueurs, le cercle dure INT + 1d4 tours et le sort est brisé si le magicien en sort. au rang 4, le mage peut intercepter les sorts adverses (visant ses alliés dans le cercle), et utiliser sa défense magique en conséquence"
        )
    ),
    RANG_3_MAGIE_UNIVERSELLE(
        Rang(
            "RANG_3_MAGIE_UNIVERSELLE",
            "Transfert de mana",
            3,
            "(renforcement) permet de transférer le mana d'une personne à une autre, si consentante: action simple, sinon : action d'attaque magique, débit de transfert: DM du magicien par action \n" +
                    "(passif) permet de dépasser son maximum de mana pendant une faible période de temps, sans subir d'overdose magique (moins de INT * 2 min) "
        )
    ),
    RANG_4_MAGIE_UNIVERSELLE(
        Rang(
            "RANG_4_MAGIE_UNIVERSELLE",
            "Téléportation",
            4,
            "(actif) permet de téléporter, le magicien (+ des alliés) sur une grande distance, cout en mana très élevé. \n" +
                    "cout en mana = N * D\n" +
                    "N = nombre de personnes\n" +
                    "D = distance (km) "
        )
    ),
    RANG_5_MAGIE_UNIVERSELLE(
        Rang(
            "RANG_5_MAGIE_UNIVERSELLE",
            "Archimage",
            5,
            "(passif) titre d'archimage, +2 INT\n" +
                    "(renforcement) possibilité de lancer 2 sorts dans un même tour (1d12 pour des sorts d'attaque magique et effets / 2 pour les autres sorts, déplacement dans ce tour impossible)"
        )
    ),


    RANG_1_LUMIERE(
        Rang(
            "RANG_1_LUMIERE",
            "Orbe de lumière",
            1,
            "(actif) crée un orbe de lumière qui flotte près du magicien pendant INT tours"
        )
    ),
    RANG_2_LUMIERE(
        Rang(
            "RANG_2_LUMIERE",
            "Lueur scintillante",
            2,
            "(actif) aveugler ou dissiper des ténèbres"
        )
    ),
    RANG_3_LUMIERE(
        Rang(
            "RANG_3_LUMIERE",
            "Perception vitale",
            3,
            "(actif) permet de percevoir le nombre et une direction approximative des entités vivantes autour du mage (jusqu'à max RANG * 10 mètres)"
        )
    ),
    RANG_4_LUMIERE(
        Rang(
            "RANG_4_LUMIERE",
            "Armure du zénith",
            4,
            "(renforcement) l'orbe de lumière dure maintenant INT + RANG tours\n" +
                    "(actif) bouclier TODO"
        )
    ),
    RANG_5_LUMIERE(
        Rang(
            "RANG_5_LUMIERE",
            "Bannissement",
            5,
            "(passif) +2 INT\n" +
                    "(actif)  lève la conjuration d'une entité invoqué (cout = cout du rang du sort d'invocation)"
        )
    ),


    RANG_1_DRACONIEN(
        Rang(
            "RANG_1_DRACONIEN",
            "Griffes et crocs",
            1,
            "le draconien, doté de pattes puissante et d'une grande mâchoire peut mordre ou griffer au prix d'une action d'attaque, 1D6 + FOR DMG "
        )
    ),
    RANG_2_DRACONIEN(
        Rang(
            "RANG_2_DRACONIEN",
            "Cuir de dragon",
            2,
            "gagne +2 RD élémentaire (dans son élément ou choisi à ce rang) "
        )
    ),
    RANG_3_DRACONIEN(
        Rang(
            "RANG_3_DRACONIEN",
            "Coup de queue",
            3,
            "Une fois par tour pour une action gratuite, le draconien peut effectuer un coup de queue à une cible à son contact, ce qui inflige 1D6 dégâts physique et nécessite un test de FOR difficulté 10 pour ne pas tomber "
        )
    ),
    RANG_4_DRACONIEN(
        Rang(
            "RANG_4_DRACONIEN",
            "Libération",
            4,
            "Le draconien n'a plus l'impression de subir les malheurs de ses ancêtres et se sens plus en forme. +2 CHAN (annule le malus de stat) et le bonus de RD élémentaire du cuir de dragon passe à +4"
        )
    ),
    RANG_5_DRACONIEN(
        Rang(
            "RANG_5_DRACONIEN",
            "Accroissance draconique",
            5,
            "amélioration du passif racial choisi: \n" +
                    "souffle: croissance des cornes, le souffle inflige désormais 2D6 DMG et gagne un effet :\n" +
                    "- feu: brulure 1D6 DM pendant 1d6 tours (ne se cumule pas)\n" +
                    "- glace: ralenti la cible et la limite à une action par tour (attaque ou mouvement) pendant 1d6 tours\n" +
                    "- foudre: réduit la mana de la cible de DMG / 2\n" +
                    "ailes: plus grandes ailes (ne sont plus abîmés), plus de limite de durée de vol, peut maintenant porter une créature de taille moyenne pendant FOR tours, peut maintenant se battre dans les airs"
        )
    ),


    RANG_1_ELFE_SYLVAIN(
        Rang(
            "RANG_1_ELFE_SYLVAIN",
            "Nature primordiale",
            1,
            "(passif) +5 INT aux tests liés à la connaissance d'une plante, d'un arbre ou d'un animal"
        )
    ),
    RANG_2_ELFE_SYLVAIN(
        Rang(
            "RANG_2_ELFE_SYLVAIN",
            "Cri sauvage",
            2,
            "(actif) test difficulté 10 pour imiter le cri / bruit, d'un animal qu'il connait"
        )
    ),
    RANG_3_ELFE_SYLVAIN(
        Rang(
            "RANG_3_ELFE_SYLVAIN",
            "Amis de la forêt",
            3,
            "(actif)  une fois par jour, en pleine nature, l'elfe sylvain pousse un puissant cri, qui appelle des animaux proches qui attaquent des ennemis au hasard, test de CON et selon résultat :\n" +
                    "1-5: 1d6 DMG\n" +
                    "6-10: 2x 1d6 DMG\n" +
                    "11-15: 3x 1d6 DMG\n" +
                    "16-19: 4x 1d6 DMG\n" +
                    "20: 5x 1d6 DMG "
        )
    ),
    RANG_4_ELFE_SYLVAIN(
        Rang(
            "RANG_4_ELFE_SYLVAIN",
            "Equipement naturel",
            4,
            "(passif) ajoute 1d6 à ses armes et +2 DEF à ses armures qui ne contiennent pas de métal\n" +
                    "(passif) n'a plus de malus de DEX lié) à la DEF  "
        )
    ),
    RANG_5_ELFE_SYLVAIN(
        Rang(
            "RANG_5_ELFE_SYLVAIN",
            "TODO",
            5,
            "TODO"
        )
    ),


    RANG_1_HAUT_ELFE(
        Rang(
            "RANG_1_HAUT_ELFE",
            "Sagesse ancestrale",
            1,
            "(passif) +5 tests liés aux tests sur les différentes races du continents et sur des évènements historiques passés"
        )
    ),
    RANG_2_HAUT_ELFE(
        Rang(
            "RANG_2_HAUT_ELFE",
            "Affinité magique",
            2,
            "(passif) +5 SOC pour parler une créature magique et +5 INT pour comprendre une créature magique"
        )
    ),
    RANG_3_HAUT_ELFE(
        Rang(
            "RANG_3_HAUT_ELFE",
            "Puit d'arcane",
            3,
            "(actif) une fois par jour, puise dans son être intérieur l'énergie dont il aurait besoin pour lancer des sorts, perd 1d10 PV, pour regagner RANG d6 mana (ne peut pas dépasser son montant de mana max à moins d'avoir le dépassement de mana  (magicien, voie magie universelle, rang 3) "
        )
    ),
    RANG_4_HAUT_ELFE(
        Rang(
            "RANG_4_HAUT_ELFE",
            "Visage immémorable",
            4,
            "(actif) une fois par jour, l'elfe peut prendre les traits d'un être monstrueux et dangereux qui a disparus des millénaires plus tôt (cf gandalf chez bilbo), lui donne +10 SOC, +10 CHA pour faire fuir ou convaincre les gens autour de lui\n"
        )
    ),
    RANG_5_HAUT_ELFE(
        Rang(
            "RANG_5_HAUT_ELFE",
            "Vitalité elfique",
            5,
            "(renforcement) augmente son dé de vie au dé 6\n" +
                    "(passif) peut lancer 2 dé aux tests de CON (et prendre le meilleur résultat) "
        )
    ),


    RANG_1_GNOME(
        Rang(
            "RANG_1_GNOME",
            "Accessoire vraisemblablement indispensable",
            1,
            "(passif)Maitrise d'une arme ou d'un instrument de musique au choix, si choix d'une arme/instrument déjà maitrisé, donne +1 AdC/+1AdT et +1 DMG avec cette arme à la place (si instrument déja maitrisé, +2 pour un instrument)\n" +
                    "(soutien) possède un porte bonheur (petit objet) qui lui donne +1 CHAN tant qu'il l'a sur lui"
        )
    ),
    RANG_2_GNOME(
        Rang(
            "RANG_2_GNOME",
            "Discussion insensée mais soit disant pertinente",
            2,
            "(actif) une fois par combat, si la cible du gnome est humanoïde et comprend sa langue, le gnome peut raconter sa vie au milieu du combat afin de perturber sa cible, test de SOC du gnome en opposition à un test de CHA de la cible. Si réussite, -3 dans toutes les DEF de la cible jusqu'au prochain tour + perte de son action d'attaque pour ce tour si elle joue après le gnome"
        )
    ),
    RANG_3_GNOME(
        Rang(
            "RANG_3_GNOME",
            "Dans ma sacoche, j'ai ...",
            3,
            "(passif) retrouve, trouve, achète (à avoir avec le MJ) une petite sacoche qui peut contenir jusqu'à 50kg d'objets en tout genre (non vivant uniquement, la nourriture ne se conserve pas mieux qu'en dehors) (le sac pourrait ne peser rien pour le gnome)"
        )
    ),
    RANG_4_GNOME(
        Rang(
            "RANG_4_GNOME",
            "P'tit bonhomme",
            4,
            "(passif) +3 DEF contre les ennemis de grandes tailles, +6 DEF contre les ennemis plus grands encore"
        )
    ),
    RANG_5_GNOME(
        Rang(
            "RANG_5_GNOME",
            "Chanceux",
            5,
            "(passif) 2 jets aux test CHAN\n" +
                    "(passif) une fois par aventure, si doit subir des dégâts mortels, est téléporter dans un endroit proche en sécurité et regagne 2d6 PV et son porte bonheur est détruit (perd donc son +1 CHAN)"
        )
    ),


    RANG_1_HUMAIN(
        Rang(
            "RANG_1_HUMAIN",
            "Polyglotte",
            1,
            "(passif) l'humain peut parler 2 langues en plus du commun"
        )
    ),
    RANG_2_HUMAIN(
        Rang(
            "RANG_2_HUMAIN",
            "Origines marquées",
            2,
            "Selon origine :\n" +
                    "Campagnard: +5 aux tests de SOC dans les campagnes et les villages\n" +
                    "Orfèvre: connaissance de géologie gratuite, +5 aux tests permettant d'identifier un métal ou une pierre précieuse\n" +
                    "Marin: connaissance natation et cartographie, +5 aux tests liés à la navigation\n" +
                    "Erudit:  +5 aux tests d'INT liés à une connaissance au choix\n" +
                    "Garde: +5 aux tests de CON lié à la fatigue\n" +
                    "Marchand: +5 en SOC pour négocier avec d'autres marchands\n" +
                    "Troubadour: maitrise d'un instrument, sait le jouer, mais n'a pas de bonus si n'a pas la voie du musicien du barde)"
        )
    ),
    RANG_3_HUMAIN(
        Rang(
            "RANG_3_HUMAIN",
            "Charme",
            3,
            "(passif) +5 aux tests de SOC et CHA contre les cibles du sexe opposé (ou non, selon les affinités de l'humain ...)"
        )
    ),
    RANG_4_HUMAIN(
        Rang(
            "RANG_4_HUMAIN",
            "Polyvalence",
            4,
            "(passif) gagne 2 rangs 1 ou 2 d'une autre classe "
        )
    ),
    RANG_5_HUMAIN(
        Rang(
            "RANG_5_HUMAIN",
            "Perfectionnement",
            5,
            "+2 dans la plus faible stat et dans une autre au choix"
        )
    ),


    RANG_1_NAIN(
        Rang(
            "RANG_1_NAIN",
            "Outils de nain",
            1,
            "(passif)Maitrise de la hache et du marteau, si c'était déjà le cas, donne +1 AdC et +1 DMG avec ces armes à la place"
        )
    ),
    RANG_2_NAIN(
        Rang(
            "RANG_2_NAIN",
            "Ivresse naine",
            2,
            "(passif) Suite à leur style de vie arrosé, bonus de +5 au tests de CON et peut refaire un jet en cas d'échec (hors échec critique) à un test de CON liés aux breuvages (poison compris)"
        )
    ),
    RANG_3_NAIN(
        Rang(
            "RANG_3_NAIN",
            "Tête de fer",
            3,
            "(gratuit) donne une attaque gratuite de coup de tête une fois par tour, 1D6 + CON DMG"
        )
    ),
    RANG_4_NAIN(
        Rang(
            "RANG_4_NAIN",
            "Acolyte des montagnes",
            4,
            "(soutien) dompte un bouquetin pouvant lui servir de monture (pas de compétence particulier pour le combat et panique si n'a pas la voie du cavalier de chevalier), mais a un bonus de +10 d'escalade avec celui-ci et galope à la même vitesse qu'un cheval"
        )
    ),
    RANG_5_NAIN(
        Rang(
            "RANG_5_NAIN",
            "Ténacité",
            5,
            "(passif) +2 CON, +2 RD physique, +2 RD magique, +2 RD dans un élément (au choix)"
        )
    ),
}