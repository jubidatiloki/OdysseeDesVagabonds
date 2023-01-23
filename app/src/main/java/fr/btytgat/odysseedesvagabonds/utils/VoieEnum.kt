package fr.btytgat.odysseedesvagabonds.utils

import fr.btytgat.odysseedesvagabonds.database.entities.Voie


enum class VoieEnum (var voie: Voie){

    VOIE_DE_LA_BRUTE(
        Voie(
            "VOIE_DE_LA_BRUTE",
            "Voie de la brute",
            listOf("RANG_1_BRUTE", "RANG_2_BRUTE", "RANG_3_BRUTE", "RANG_4_BRUTE", "RANG_5_BRUTE")
        )
    ),
    VOIE_DE_L_ATHLETE(
        Voie(
            "VOIE_DE_L_ATHLETE",
            "Voie de l'athlète",
            listOf("RANG_1_ATHLETE", "RANG_2_ATHLETE", "RANG_3_ATHLETE", "RANG_4_ATHLETE", "RANG_5_ATHLETE")
        )
    ),
    VOIE_DU_SAUVAGE(
        Voie(
            "VOIE_DU_SAUVAGE",
            "Voie du sauvage",
            listOf("RANG_1_SAUVAGE", "RANG_2_SAUVAGE", "RANG_3_SAUVAGE", "RANG_4_SAUVAGE", "RANG_5_SAUVAGE")
        )
    ),
    VOIE_DU_BERZERKER(
        Voie(
           "VOIE_DU_BERZERKER",
            "Voie du berzerker",
            listOf("RANG_1_BERZERKER", "RANG_2_BERZERKER", "RANG_3_BERZERKER", "RANG_4_BERZERKER", "RANG_5_BERZERKER")
        )
    ),


    VOIE_DU_VAGABOND(
        Voie(
            "VOIE_DU_VAGABOND",
            "Voie du vagabond",
            listOf("RANG_1_VAGABOND", "RANG_2_VAGABOND", "RANG_3_VAGABOND", "RANG_4_VAGABOND", "RANG_5_VAGABOND")
        )
    ),
    VOIE_DU_MUSICIEN(
        Voie(
        "VOIE_DU_MUSICIEN",
        "Voie du musicien",
        listOf("RANG_1_MUSICIEN", "RANG_2_MUSICIEN", "RANG_3_MUSICIEN", "RANG_4_MUSICIEN", "RANG_5_MUSICIEN")
        )
    ),
    VOIE_DE_L_ACROBATE(
        Voie(
            "VOIE_DE_L_ACROBATE",
            "Voie de l'acrobate",
            listOf("RANG_1_ACROBATE", "RANG_2_ACROBATE", "RANG_3_ACROBATE", "RANG_4_ACROBATE", "RANG_5_ACROBATE")
        )
    ),
    VOIE_DU_COURTISAN(
        Voie(
            "VOIE_DU_COURTISAN",
            "Voie du courtisan",
            listOf("RANG_1_COURTISAN", "RANG_2_COURTISAN", "RANG_3_COURTISAN", "RANG_4_COURTISAN", "RANG_5_COURTISAN")
        )
    ),


    VOIE_DE_LA_NOBLESSE(
        Voie(
            "VOIE_DE_LA_NOBLESSE",
            "Voie de la noblesse",
            listOf("RANG_1_NOBLESSE", "RANG_2_NOBLESSE", "RANG_3_NOBLESSE", "RANG_4_NOBLESSE", "RANG_5_NOBLESSE")
        )
    ),
    VOIE_DE_LA_CAVALERIE(
        Voie(
            "VOIE_DE_LA_CAVALERIE",
            "Voie de la cavalerie",
            listOf("RANG_1_CAVALERIE", "RANG_2_CAVALERIE", "RANG_3_CAVALERIE", "RANG_4_CAVALERIE", "RANG_5_CAVALERIE")
        )
    ),
    VOIE_DU_DUEL(
        Voie(
            "VOIE_DU_DUEL",
            "Voie du duel",
            listOf("RANG_1_DUEL", "RANG_2_DUEL", "RANG_3_DUEL", "RANG_4_DUEL", "RANG_5_DUEL")
        )
    ),
    VOIE_DU_COMMANDEMENT(
        Voie(
            "VOIE_DU_COMMANDEMENT",
            "Voie du commandement",
            listOf("RANG_1_COMMANDEMENT", "RANG_2_COMMANDEMENT", "RANG_3_COMMANDEMENT", "RANG_4_COMMANDEMENT", "RANG_5_COMMANDEMENT")
        )
    ),


    VOIE_BESTIALE(
        Voie(
            "VOIE_BESTIALE",
            "Voie bestiale",
            listOf(
                RangEnum.RANG_1_BESTIALE.name,
                RangEnum.RANG_2_BESTIALE.name,
                RangEnum.RANG_3_BESTIALE.name,
                RangEnum.RANG_4_BESTIALE.name,
                RangEnum.RANG_5_BESTIALE.name
            )
        )
    ),
    VOIE_DU_PROTECTEUR(
        Voie(
            "VOIE_DU_PROTECTEUR",
            "Voie du protecteur",
            listOf(
                RangEnum.RANG_1_PROTECTEUR.name,
                RangEnum.RANG_2_PROTECTEUR.name,
                RangEnum.RANG_3_PROTECTEUR.name,
                RangEnum.RANG_4_PROTECTEUR.name,
                RangEnum.RANG_5_PROTECTEUR.name
            )
        )
    ),
    VOIE_DE_LA_NATURE(
        Voie(
            "VOIE_DE_LA_NATURE",
            "Voie de la nature",
            listOf(
                RangEnum.RANG_1_NATURE.name,
                RangEnum.RANG_2_NATURE.name,
                RangEnum.RANG_3_NATURE.name,
                RangEnum.RANG_4_NATURE.name,
                RangEnum.RANG_5_NATURE.name
            )
        )
    ),
    VOIE_DES_VEGETAUX(
        Voie(
            "VOIE_DES_VEGETAUX",
            "Voie des végétaux",
            listOf(
                RangEnum.RANG_1_VEGETAUX.name,
                RangEnum.RANG_2_VEGETAUX.name,
                RangEnum.RANG_3_VEGETAUX.name,
                RangEnum.RANG_4_VEGETAUX.name,
                RangEnum.RANG_5_VEGETAUX.name,
            )
        )
    ),


    VOIE_DU_BOUCLIER(
        Voie(
            "VOIE_DU_BOUCLIER",
            "Voie du bouclier",
            listOf("RANG_1_BOUCLIER", "RANG_2_BOUCLIER", "RANG_3_BOUCLIER", "RANG_4_BOUCLIER", "RANG_5_BOUCLIER")
        )
    ),
    VOIE_DE_LA_MELEE(
        Voie(
            "VOIE_DE_LA_MELEE",
            "Voie de la mêlée",
            listOf("RANG_1_MELEE", "RANG_2_MELEE", "RANG_3_MELEE", "RANG_4_MELEE", "RANG_5_MELEE")
        )
    ),
    VOIE_DE_LA_POLYVALENCE(
        Voie(
            "VOIE_DE_LA_POLYVALENCE",
            "Voie de la polyvalence",
            listOf("RANG_1_POLYVALENCE", "RANG_2_POLYVALENCE", "RANG_3_POLYVALENCE", "RANG_4_POLYVALENCE", "RANG_5_POLYVALENCE")
        )
    ),
    VOIE_DE_LA_GUERRE(
        Voie(
            "VOIE_DE_LA_GUERRE",
            "Voie de la guerre",
            listOf("RANG_1_GUERRE", "RANG_2_GUERRE", "RANG_3_GUERRE", "RANG_4_GUERRE", "RANG_5_GUERRE")
        )
    ),


    VOIE_DE_L_ARTILLERIE(
        Voie(
            "VOIE_DE_L_ARTILLERIE",
            "Voie de l'artillerie",
            listOf(
                RangEnum.RANG_1_ARTILLERIE.name,
                RangEnum.RANG_2_ARTILLERIE.name,
                RangEnum.RANG_3_ARTILLERIE.name,
                RangEnum.RANG_4_ARTILLERIE.name,
                RangEnum.RANG_5_ARTILLERIE.name,
            )
        )
    ),
    VOIE_DU_CHIMISTE(
        Voie(
            "VOIE_DU_CHIMISTE",
            "Voie du chimiste",
            listOf(
                RangEnum.RANG_1_CHIMISTE.name,
                RangEnum.RANG_2_CHIMISTE.name,
                RangEnum.RANG_3_CHIMISTE.name,
                RangEnum.RANG_4_CHIMISTE.name,
                RangEnum.RANG_5_CHIMISTE.name
            )
        )
    ),
    VOIE_DU_TIREUR(
        Voie(
            "VOIE_DU_TIREUR",
            "Voie du tireur",
            listOf(
                RangEnum.RANG_1_TIREUR.name,
                RangEnum.RANG_2_TIREUR.name,
                RangEnum.RANG_3_TIREUR.name,
                RangEnum.RANG_4_TIREUR.name,
                RangEnum.RANG_5_TIREUR.name
            )
        )
    ),
    VOIE_DE_LA_MECANIQUE(
        Voie(
            "VOIE_DE_LA_MECANIQUE",
            "Voie de la mécanique",
            listOf(
                RangEnum.RANG_1_MECANIQUE.name,
                RangEnum.RANG_2_MECANIQUE.name,
                RangEnum.RANG_3_MECANIQUE.name,
                RangEnum.RANG_4_MECANIQUE.name,
                RangEnum.RANG_5_MECANIQUE.name
            )
        )
    ),


    VOIE_DU_FEU(
        Voie(
            "VOIE_DU_FEU",
            "Voie du feu",
            listOf(
                RangEnum.RANG_1_FEU.name,
                RangEnum.RANG_2_FEU.name,
                RangEnum.RANG_3_FEU.name,
                RangEnum.RANG_4_FEU.name,
                RangEnum.RANG_5_FEU.name
            ),
            true
        )
    ),
    VOIE_DE_LA_TERRE(
        Voie(
            "VOIE_DE_LA_TERRE",
            "Voie de la terre",
            listOf(
                RangEnum.RANG_1_TERRE.name,
                RangEnum.RANG_2_TERRE.name,
                RangEnum.RANG_3_TERRE.name,
                RangEnum.RANG_4_TERRE.name,
                RangEnum.RANG_5_TERRE.name
            ),
            true
        )
    ),
    VOIE_DE_L_EAU(
        Voie(
            "VOIE_DE_L_EAU",
            "Voie de l'eau",
            listOf(
                RangEnum.RANG_1_EAU.name,
                RangEnum.RANG_2_EAU.name,
                RangEnum.RANG_3_EAU.name,
                RangEnum.RANG_4_EAU.name,
                RangEnum.RANG_5_EAU.name
            ),
            true
        )
    ),
    VOIE_DE_L_AIR(
        Voie(
            "VOIE_DE_L_AIR",
            "Voie de l'air",
            listOf(
                RangEnum.RANG_1_AIR.name,
                RangEnum.RANG_2_AIR.name,
                RangEnum.RANG_3_AIR.name,
                RangEnum.RANG_4_AIR.name,
                RangEnum.RANG_5_AIR.name
            ),
            true
        )
    ),
    VOIE_DES_ARCANES(
        Voie(
            "VOIE_DES_ARCANES",
            "Voie des arcanes",
            listOf(
                RangEnum.RANG_1_ARCANES.name,
                RangEnum.RANG_2_ARCANES.name,
                RangEnum.RANG_3_ARCANES.name,
                RangEnum.RANG_4_ARCANES.name,
                RangEnum.RANG_5_ARCANES.name
            ),
            true
        )
    ),
    VOIE_DE_LA_MAGIE_UNIVERSELLE(
        Voie(
            "VOIE_DE_LA_MAGIE_UNIVERSELLE",
            "Voie de la magie universelle",
            listOf(
                RangEnum.RANG_1_MAGIE_UNIVERSELLE.name,
                RangEnum.RANG_2_MAGIE_UNIVERSELLE.name,
                RangEnum.RANG_3_MAGIE_UNIVERSELLE.name,
                RangEnum.RANG_4_MAGIE_UNIVERSELLE.name,
                RangEnum.RANG_5_MAGIE_UNIVERSELLE.name)
        )
    ),
    VOIE_DE_LA_LUMIERE(
        Voie(
            "VOIE_DE_LA_LUMIERE",
            "Voie de la lumière",
            listOf(
                RangEnum.RANG_1_LUMIERE.name,
                RangEnum.RANG_2_LUMIERE.name,
                RangEnum.RANG_3_LUMIERE.name,
                RangEnum.RANG_4_LUMIERE.name,
                RangEnum.RANG_5_LUMIERE.name
            )
        )
    ),


    VOIE_DU_KI(
        Voie(
            "VOIE_DU_KI",
            "Voie du ki",
            listOf("RANG_1_KI", "RANG_2_KI", "RANG_3_KI", "RANG_4_KI", "RANG_5_KI")
        )
    ),
    VOIE_DES_RUNES(
        Voie(
            "VOIE_DES_RUNES",
            "Voie des runes",
            listOf("RANG_1_RUNES", "RANG_2_RUNES", "RANG_3_RUNES", "RANG_4_RUNES", "RANG_5_RUNES")
        )
    ),
    VOIE_DU_NINJA(
        Voie(
            "VOIE_DU_NINJA",
            "Voie du ninja",
            listOf("RANG_1_NINJA", "RANG_2_NINJA", "RANG_3_NINJA", "RANG_4_NINJA", "RANG_5_NINJA")
        )
    ),
    VOIE_DU_POING(
        Voie(
            "VOIE_DU_POING",
            "Voie du poing",
            listOf("RANG_1_POING", "RANG_2_POING", "RANG_3_POING", "RANG_4_POING", "RANG_5_POING")
        )
    ),


    VOIE_DE_L_INVOCATION(
        Voie(
            "VOIE_DE_L_INVOCATION",
            "Voie de l'invocation",
            listOf("RANG_1_INVOCATION", "RANG_2_INVOCATION", "RANG_3_INVOCATION", "RANG_4_INVOCATION", "RANG_5_INVOCATION")
        )
    ),
    VOIE_DE_LA_MORT(
        Voie(
            "VOIE_DE_LA_MORT",
            "Voie de la mort",
            listOf("RANG_1_MORT", "RANG_2_MORT", "RANG_3_MORT", "RANG_4_MORT", "RANG_5_MORT")
        )
    ),
    VOIE_DES_MORT_VIVANTS(
        Voie(
            "VOIE_DES_MORT_VIVANTS",
            "Voie des mort-vivants",
            listOf("RANG_1_MORT_VIVANTS", "RANG_2_MORT_VIVANTS", "RANG_3_MORT_VIVANTS", "RANG_4_MORT_VIVANTS", "RANG_5_MORT_VIVANTS")
        )
    ),
    VOIE_DES_RITUELS(
        Voie(
            "VOIE_DES_RITUELS",
            "Voie des rituels",
            listOf("RANG_1_RITUELS", "RANG_2_RITUELS", "RANG_3_RITUELS", "RANG_4_RITUELS", "RANG_5_RITUELS")
        )
    ),


    VOIE_DES_SOINS(
        Voie(
            "VOIE_DES_SOINS",
            "Voie des soins",
            listOf("RANG_1_SOINS", "RANG_2_SOINS", "RANG_3_SOINS", "RANG_4_SOINS", "RANG_5_SOINS")
        )
    ),
    VOIE_DU_PALADIN(
        Voie(
            "VOIE_DU_PALADIN",
            "Voie du paladin",
            listOf("RANG_1_PALADIN", "RANG_2_PALADIN", "RANG_3_PALADIN", "RANG_4_PALADIN", "RANG_5_PALADIN")
        )
    ),
    VOIE_DU_DIVIN(
        Voie(
            "VOIE_DU_DIVIN",
            "Voie du divin",
            listOf("RANG_1_DIVIN", "RANG_2_DIVIN", "RANG_3_DIVIN", "RANG_4_DIVIN", "RANG_5_DIVIN")
        )
    ),
    VOIE_DE_L_INQUISITEUR(
        Voie(
            "VOIE_DE_L_INQUISITEUR",
            "Voie de l'inquisiteur",
            listOf("RANG_1_INQUISITEUR", "RANG_2_INQUISITEUR", "RANG_3_INQUISITEUR", "RANG_4_INQUISITEUR", "RANG_5_INQUISITEUR")
        )
    ),


    VOIE_DE_L_ARCHER(
        Voie(
            "VOIE_DE_L_ARCHER",
            "Voie de l'archer",
            listOf("RANG_1_ARCHER", "RANG_2_ARCHER", "RANG_3_ARCHER", "RANG_4_ARCHER", "RANG_5_ARCHER")
        )
    ),
    VOIE_DU_CHASSEUR(
        Voie(
            "VOIE_DU_CHASSEUR",
            "Voie du chasseur",
            listOf("RANG_1_CHASSEUR", "RANG_2_CHASSEUR", "RANG_3_CHASSEUR", "RANG_4_CHASSEUR", "RANG_5_CHASSEUR")
        )
    ),
    VOIE_DU_NOMADE(
        Voie(
            "VOIE_DU_NOMADE",
            "Voie du nomade",
            listOf("RANG_1_NOMADE", "RANG_2_NOMADE", "RANG_3_NOMADE", "RANG_4_NOMADE", "RANG_5_NOMADE")
        )
    ),
    VOIE_DU_TRAPPEUR(
        Voie(
            "VOIE_DU_TRAPPEUR",
            "Voie du trappeur",
            listOf("RANG_1_TRAPPEUR", "RANG_2_TRAPPEUR", "RANG_3_TRAPPEUR", "RANG_4_TRAPPEUR", "RANG_5_TRAPPEUR")
        )
    ),


    VOIE_DU_SEDUCTEUR(
        Voie(
            "VOIE_DU_SEDUCTEUR",
            "Voie du séducteur",
            listOf("RANG_1_SEDUCTEUR", "RANG_2_SEDUCTEUR", "RANG_3_SEDUCTEUR", "RANG_4_SEDUCTEUR", "RANG_5_SEDUCTEUR")
        )
    ),
    VOIE_DE_L_ASSASSIN(
        Voie(
            "VOIE_DE_L_ASSASSIN",
            "Voie de l'assassin",
            listOf("RANG_1_ASSASSIN", "RANG_2_ASSASSIN", "RANG_3_ASSASSIN", "RANG_4_ASSASSIN", "RANG_5_ASSASSIN")
        )
    ),
    VOIE_DU_BRETTEUR(
        Voie(
            "VOIE_DU_BRETTEUR",
            "Voie du bretteur",
            listOf("RANG_1_BRETTEUR", "RANG_2_BRETTEUR", "RANG_3_BRETTEUR", "RANG_4_BRETTEUR", "RANG_5_BRETTEUR")
        )
    ),
    VOIE_DU_ROUBLARD(
        Voie(
            "VOIE_DU_ROUBLARD",
            "Voie du roublard",
            listOf("RANG_1_ROUBLARD", "RANG_2_ROUBLARD", "RANG_3_ROUBLARD", "RANG_4_ROUBLARD", "RANG_5_ROUBLARD")
        )
    ),


    VOIE_DU_DRACONIEN(
        Voie(
            "VOIE_DU_DRACONIEN",
            "Voie du draconien",
            listOf(
                RangEnum.RANG_1_DRACONIEN.name,
                RangEnum.RANG_2_DRACONIEN.name,
                RangEnum.RANG_3_DRACONIEN.name,
                RangEnum.RANG_4_DRACONIEN.name,
                RangEnum.RANG_5_DRACONIEN.name
            )
        )
    ),


    VOIE_DE_L_ELFE_SYLVAIN(
        Voie(
            "VOIE_DE_L_ELFE_SYLVAIN",
            "Voie de l'elfe-sylvain",
            listOf(
                RangEnum.RANG_1_ELFE_SYLVAIN.name,
                RangEnum.RANG_2_ELFE_SYLVAIN.name,
                RangEnum.RANG_3_ELFE_SYLVAIN.name,
                RangEnum.RANG_4_ELFE_SYLVAIN.name,
                RangEnum.RANG_5_ELFE_SYLVAIN.name
            )
        )
    ),


    VOIE_DU_HAUT_ELFE(
        Voie(
            "VOIE_DU_HAUT_ELFE",
            "Voie du haut-elfe",
            listOf(
                RangEnum.RANG_1_HAUT_ELFE.name,
                RangEnum.RANG_2_HAUT_ELFE.name,
                RangEnum.RANG_3_HAUT_ELFE.name,
                RangEnum.RANG_4_HAUT_ELFE.name,
                RangEnum.RANG_5_HAUT_ELFE.name
            )
        )
    ),


    VOIE_DU_GNOME(
        Voie(
            "VOIE_DU_GNOME",
            "Voie du gnome",
            listOf(
                RangEnum.RANG_1_GNOME.name,
                RangEnum.RANG_2_GNOME.name,
                RangEnum.RANG_3_GNOME.name,
                RangEnum.RANG_4_GNOME.name,
                RangEnum.RANG_5_GNOME.name
            )
        )
    ),


    VOIE_DE_L_HUMAIN(
        Voie(
            "VOIE_DE_L_HUMAIN",
            "Voie de l'humain",
            listOf(
                RangEnum.RANG_1_HUMAIN.name,
                RangEnum.RANG_2_HUMAIN.name,
                RangEnum.RANG_3_HUMAIN.name,
                RangEnum.RANG_4_HUMAIN.name,
                RangEnum.RANG_5_HUMAIN.name
            )
        )
    ),


    VOIE_DU_NAIN(
        Voie(
            "VOIE_DU_NAIN",
            "Voie du nain",
            listOf(
                RangEnum.RANG_1_NAIN.name,
                RangEnum.RANG_2_NAIN.name,
                RangEnum.RANG_3_NAIN.name,
                RangEnum.RANG_4_NAIN.name,
                RangEnum.RANG_5_NAIN.name
            )
        )
    ),
}