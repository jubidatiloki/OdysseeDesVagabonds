package fr.btytgat.odysseedesvagabonds.utils

import fr.btytgat.odysseedesvagabonds.database.entities.Stat

enum class StatEnum (var stat: Stat){
    STAT_ADC(
        Stat(
            "STAT_ADC",
            "Aptitude de combat",
            "AdC",
            true,
            true,
            "Maîtrise du combat au corps à corps, importante pour les guerriers et les chevaliers",
            "permet d’augmenter les chances de toucher au corps à corps (toucher bonus = AdC)\n" +
                    "permet d’augmenter la défense au corps à corps (défense bonus = AC / 2, arrondi au supérieur)"
        )
    ),
    STAT_ADT(
        Stat(
            "STAT_ADT",
            "Aptitude de tir",
            "AdT",
            true,
            true,
            "Maîtrise des armes à distance, importante pour les canonniers et les rôdeurs",
            "permet d’augmenter les chances de toucher à distance (toucher bonus = AT)\n" +
                    "permet d’augmenter la défense à distance (défense bonus = AT / 2, arrondi au supérieur)"
        )
    ),
    STAT_CHA(
        Stat(
            "STAT_CHA",
            "Charisme",
            "CHA",
            true,
            true,
            "Représente le courage, la prestance auprès, l'image que l'on donne auprès des autres, important pour les chevaliers et les bardes",
            "résister à la peur (face au danger ou une intimidation), impressionner quelqu’un par sa seul présence"
        )
    ),
    STAT_CHAN(
        Stat(
            "STAT_CHAN",
            "Chance",
            "CHAN",
            true,
            true,
            "Représente la chance naturelle et honteuse que RNG jésus porte pour une personne",
            " ce qui ne concerne uniquement la chance et non les compétences"
        )
    ),
    STAT_CON(
        Stat(
            "STAT_CON",
            "Constitution",
            "CON",
            true,
            true,
            "Représente l’endurance et la résistance, importante pour les barbares et moines",
            "Permet d’augmenter les points de vie (vie bonus = END)\n" +
                    "résistance au poison, à la fatigue, courir (endurance), retenir son souffle"
        )
    ),
    STAT_DEF_CAC(
        Stat(
            "STAT_DEF_CAC",
            "Défense au corps à corps",
            "DEF CaC",
            false,
            false,
            "Représente la difficulté à être toucher au corps à corps, notamment à cause d'une armure",
            "défense corps à corps = 10 + AdC/2 + compétences + équipement + autres"
        )
    ),
    STAT_DEF_DIST(
        Stat(
            "STAT_DEF_DIST",
            "Défense à distance",
            "DEF DIST",
            false,
            false,
            "Représente la difficulté à être touché par des projectiles non magique",
            "défense distance = 10 + AdT/2 + compétences + équipement + autres"
        )
    ),
    STAT_DEF_ELEM(
        Stat(
            "STAT_DEF_ELEM",
            "Défense élémentaire",
            "DEF ELEM",
            false,
            false,
            "Représente la difficulté à être touché par des attaques élémentaire",
            "défense élémentaire = 10 + compétences + équipement + autres"
        )
    ),
    STAT_DEF_MAG(
        Stat(
            "STAT_DEF_MAG",
            "Défense magique",
            "DEF MAG",
            false,
            false,
            "Représente la difficulté à être touché par des attaques magiques",
            "défense magique = 10 + INT/2 + compétences + équipement + autres"
        )
    ),
    STAT_DEX(
        Stat(
            "STAT_DEX",
            "Dextérité",
            "DEX",
            true,
            true,
            "Représente l’agilité, ainsi que la précision et la vitesse dans certaines situation, importante pour les voleurs",
            "permet d'augmenter les jets d'initiative\n" +
                    "acrobatie, crochetage, désamorçage de piège, escalade, se cacher, se déplacer silencieusement, sauter par dessus un trou, courir (vitesse)"
        )
    ),
    STAT_DV(
        Stat(
            "STAT_DV",
            "Dé de vie",
            "DV",
            true,
            false,
            "Représente le gain de point de vie par montée de niveau, ainsi que la quantité limite encaissable avant de mourir",
            "Dépend de la race et de la classe du personnage"
        )
    ),
    STAT_DM(
        Stat(
            "STAT_DM",
            "Dé de mana",
            "DM",
            true,
            false,
            "Représente le gain de point de mana par montée de niveau",
            "Dépend de la race et de la classe du personnage"
        )
    ),
    STAT_ESQ(
        Stat(
            "STAT_ESQ",
            "Esquive",
            "ESQ",
            false,
            false,
            "Représente la capacité à pouvoir esquiver une attaque, plutôt que l’encaisser",
            "retire l’action de mouvement du prochain tour (peu importe le résultat du test)\n" +
                    "1 esquive par tour max\n" +
                    "calcul esquive = 10 + DEX/2 + compétences + équipement (bonus et malus d’armure) + autres"
        )
    ),
    STAT_FOR(
        Stat(
            "STAT_FOR",
            "Force",
            "FOR",
            true,
            true,
            "Représente la puissance brute / musculaire, importante pour les barbares",
            "permet d’augmenter les dégâts au corps à corps (dégâts bonus = FOR)\n" +
                    "soulever quelque chose, immobiliser quelqu’un"
        )
    ),
    STAT_INIT(
        Stat(
            "STAT_INIT",
            "Initiative",
            "INIT",
            false,
            false,
            "Représente la vitesse de réaction et permet d’agir avant ses adversaires en combat",
            "initiative = 10 + DEX + compétences + équipement + autres"
        )
    ),
    STAT_INT(
        Stat(
            "STAT_INT",
            "Intelligence",
            "INT",
            true,
            true,
            "Représente les connaissances, et la maîtrise de la magie chez les druides, les magiciens, les nécromanciens et les prêtres",
            "permet d’augmenter la défense magique (défense bonus = INT / 2, arrondi au supérieur)\n" +
                    "se souvenir, connaître, apprendre"
        )
    ),
    STAT_PER(
        Stat(
            "STAT_PER",
            "Perception",
            "PER",
            true,
            true,
            "Représente la capacité à percevoir certaines choses, importante pour les bardes, les rôdeurs et  les moines",
            "détection de piège, détection d’une embuscade, trouver un objet dans une pièce, trouver une personne dans une rue bondée"
        )
    ),
    STAT_PV(
        Stat(
            "STAT_PV",
            "Point de vie",
            "PV",
            false,
            false,
            "Représente la quantité de coup et de blessure qu’il est possible d’encaisser avant de s’évanouir ou de mourir",
            "point de vie = 0 → évanouissement pendant 1d6 heures\n" +
                    "point de vie < dé de vie (en négatif)  → mort\n" +
                    "point de vie initiale = dé de vie max + dé de vie(lancée)"
        )
    ),
    STAT_PM(
        Stat(
            "STAT_PM",
            "Point de mana",
            "PM",
            false,
            false,
            "Représente la quantité de magie possible d’utiliser",
            "régénération: dé de mana PM par nuit de sommeil (divisé par 2 si demi-nuit de sommeil)\n" +
                    "point de mana initiale = dé de mana max"
        )
    ),
    STAT_SOC(
        Stat(
            "STAT_SOC",
            "Social",
            "SOC",
            true,
            true,
            "Représente l’aisance à communiquer, importante pour les bardes et les voleurs",
            "baratiner, bluffer, convaincre, intimider, distraire, obtenir une information"
        )
    ),
    STAT_RD_PHY(
        Stat(
            "STAT_RD_PHY",
            "Réduction de dégât physique",
            "RD PHY",
            false,
            false,
            "Réduit les dégâts physique subis",
            "0 par défaut"
        )
    ),
    STAT_RD_MAG(
        Stat(
            "STAT_RD_MAG",
            "Réduction de dégât magique",
            "RD MAG",
            false,
            false,
            "Réduit les dégâts magique subis",
            "0 par défaut"
        )
    ),
    STAT_RD_FEU(
        Stat(
            "STAT_RD_FEU",
            "Réduction de dégât de feu",
            "RD FEU",
            false,
            false,
            "Réduit les dégâts élémentaire de feu subis",
            "0 par défaut"
        )
    ),
    STAT_RD_GLACE(
        Stat(
            "STAT_RD_GLACE",
            "Réduction de dégât de glace",
            "RD GLACE",
            false,
            false,
            "Réduit les dégâts élémentaire de glace/froid subis",
            "0 par défaut"
        )
    ),
    STAT_RD_FOUDRE(
        Stat(
            "STAT_RD_FOUDRE",
            "Réduction de dégât de foudre",
            "RD FOUDRE",
            false,
            false,
            "Réduit les dégâts élémentaire de foudre subis",
            "0 par défaut"
        )
    ),
}