package fr.btytgat.odysseedesvagabonds.utils

import fr.btytgat.odysseedesvagabonds.database.entities.Classe

enum class ClasseEnum(val classe: Classe) {
    CLASSE_BARBARE(
        Classe("CLASSE_BARBARE",
            "Barbare",
            -1,
            -1,
            "aime se battre, beaucoup et vraiment tout le temps, pour tout",
            "homme de cromagnon enragé en quelque sorte",
            listOf(
                VoieEnum.VOIE_DE_LA_BRUTE.name,
                VoieEnum.VOIE_DE_L_ATHLETE.name,
                VoieEnum.VOIE_DU_SAUVAGE.name,
                VoieEnum.VOIE_DU_BERZERKER.name
            )
        )
    ),
    CLASSE_BARDE(
        Classe("CLASSE_BARDE",
            "Barde",
            0,
            0,
            "aime faire de la musique",
            "a commencer lorsque les gens s'ennuyaient",
            listOf(
                VoieEnum.VOIE_DU_VAGABOND.name,
                VoieEnum.VOIE_DU_MUSICIEN.name,
                VoieEnum.VOIE_DE_L_ACROBATE.name,
                VoieEnum.VOIE_DU_COURTISAN.name
            )
        )
    ),
    CLASSE_CHEVALIER(
        Classe("CLASSE_CHEVALIER",
            "Chevalier",
            1,
            -1,
            "aime les belles armures",
            "vis dans un chateau",
            listOf(
               VoieEnum.VOIE_DE_LA_NOBLESSE.name,
                VoieEnum.VOIE_DE_LA_CAVALERIE.name,
                VoieEnum.VOIE_DU_DUEL.name,
                VoieEnum.VOIE_DU_COMMANDEMENT.name
            )
        )
    ),
    CLASSE_DRUIDE(
        Classe("CLASSE_DRUIDE",
            "Druide",
            0,
            1,
            "baise des arbres et des animaux de façon RP",
            "PEGI 18",
            listOf(
               VoieEnum.VOIE_BESTIALE.name,
                VoieEnum.VOIE_DU_PROTECTEUR.name,
                VoieEnum.VOIE_DE_LA_NATURE.name,
                VoieEnum.VOIE_DES_VEGETAUX.name
            )
        )
    ),
    CLASSE_GUERRIER(
        Classe("CLASSE_GUERRIER",
            "Guerrier",
            1,
            -1,
            "est capable de se battre avec tout, genre un crayon, ou katana",
            "",
            listOf(
                VoieEnum.VOIE_DU_BOUCLIER.name,
                VoieEnum.VOIE_DE_LA_MELEE.name,
                VoieEnum.VOIE_DE_LA_POLYVALENCE.name,
                VoieEnum.VOIE_DE_LA_GUERRE.name
            )
        )
    ),
    CLASSE_INGENIEUR(
        Classe("CLASSE_INGENIEUR",
            "Ingénieur",
            1,
            -1,
            "sait lire, écrire, compter, faire des calcul et utiliser une baliste d'une demi-tonne",
            "trust me i'm an engineer",
            listOf(
                VoieEnum.VOIE_DE_L_ARTILLERIE.name,
                VoieEnum.VOIE_DU_CHIMISTE.name,
                VoieEnum.VOIE_DU_TIREUR.name,
                VoieEnum.VOIE_DE_LA_MECANIQUE.name
            )
        )
    ),
    CLASSE_MAGICIEN(
        Classe("CLASSE_MAGICIEN",
            "Magicien",
            -1,
            1,
            "est capable d'épater la gallerie avec la magie",
            "rat de bibliothèque",
            listOf(
                VoieEnum.VOIE_DU_FEU.name,
                VoieEnum.VOIE_DE_LA_TERRE.name,
                VoieEnum.VOIE_DE_L_EAU.name,
                VoieEnum.VOIE_DE_L_AIR.name,
                VoieEnum.VOIE_DES_ARCANES.name,
                VoieEnum.VOIE_DE_LA_MAGIE_UNIVERSELLE.name,
                VoieEnum.VOIE_DE_LA_LUMIERE.name
            )
        )
    ),
    CLASSE_MOINE(
        Classe("CLASSE_MOINE",
            "Moine",
            1,
            0,
            "savait marcher sur l'eau avant que ca devienne à la mode",
            "vis nu la plupart du temps et \"médite\" souvent les lendemain de cuite",
            listOf(
                VoieEnum.VOIE_DU_KI.name,
                VoieEnum.VOIE_DES_RUNES.name,
                VoieEnum.VOIE_DU_NINJA.name,
                VoieEnum.VOIE_DU_POING.name
            )
        )
    ),
    CLASSE_NECROMANCIEN(
        Classe("CLASSE_NECROMANCIEN",
            "Nécromancien",
            -1,
            1,
            "fait revivre les morts",
            "vis dans un cimetière par soucis de transport de matière première",
            listOf(
                VoieEnum.VOIE_DE_L_INVOCATION.name,
                VoieEnum.VOIE_DE_LA_MORT.name,
                VoieEnum.VOIE_DES_MORT_VIVANTS.name,
                VoieEnum.VOIE_DES_RITUELS.name
            )
        )
    ),
    CLASSE_PRETRE(
        Classe("CLASSE_PRETRE",
            "Prêtre",
            0,
            1,
            "est schyzophrene et fait croire a tout le monde que c'est son dieu qui lui parle",
            "s'est trouvé un ami imaginaire",
            listOf(
                VoieEnum.VOIE_DES_SOINS.name,
                VoieEnum.VOIE_DU_PALADIN.name,
                VoieEnum.VOIE_DU_DIVIN.name,
                VoieEnum.VOIE_DE_L_INQUISITEUR.name
            )
        )
    ),
    CLASSE_RODEUR(
        Classe("CLASSE_RODEUR",
            "Rodeur",
            0,
            0,
            "braconnier qui se donne des air cool",
            "alors, il y a le bon rodeur et le mauvais rodeur, ...",
            listOf(
                VoieEnum.VOIE_DE_L_ARCHER.name,
                VoieEnum.VOIE_DU_CHASSEUR.name,
                VoieEnum.VOIE_DU_NOMADE.name,
                VoieEnum.VOIE_DU_TRAPPEUR.name
            )
        )
    ),
    CLASSE_VOLEUR(
        Classe("CLASSE_VOLEUR",
            "Voleur",
            0,
            0,
            "petite tendance cleptomane",
            "est-ce un oiseau? est-ce un super héros? eh non, c'est un voleur",
            listOf(
                VoieEnum.VOIE_DU_SEDUCTEUR.name,
                VoieEnum.VOIE_DE_L_ASSASSIN.name,
                VoieEnum.VOIE_DU_BRETTEUR.name,
                VoieEnum.VOIE_DU_ROUBLARD.name
            )
        )
    )
}