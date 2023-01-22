package fr.btytgat.odysseedesvagabonds.utils

import fr.btytgat.odysseedesvagabonds.database.entities.Race

enum class RaceEnum(val race: Race) {
    RACE_DEMI_ELFE(
        Race(
            "RACE_DEMI_ELFE",
            "Demi-elfe",
            4,
            8,
            "né de parents humains et elfes, leur conviction et leur nature dépend beaucoup d'où ils ont été élevé",
            "PEGI 18",
            "VOIE_DU_DEMI_ELFE",
            hashMapOf()
        )
    ),
    RACE_DEMI_ORQUE(
        Race(
            "RACE_DEMI_ORQUE",
            "Demi-orque",
            10,
            4,
            "mi-orque, mi-humain, et re mi-orque derriere",
            "PEGI 18",
            "VOIE_DU_DEMI_ORQUE",
            hashMapOf("STAT_FOR" to 3, "STAT_INT" to -2, "STAT_SOC" to -2)
        )
    ),
    RACE_DRACONIEN(
        Race(
            "RACE_DRACONIEN",
            "Draconien",
            8,
            4,
            "des mecs pas assez cools pour être comme des dragons, mais suffisamment badass pour casser la gueule à tout le monde",
            "dragon > draconien",
            "VOIE_DU_DRACONIEN",
            hashMapOf("STAT_CON" to 2, "STAT_DEX" to -2, "STAT_CHAN" to -2)
        )
    ),
    RACE_ELFE_SYLVAIN(
        Race(
            "RACE_ELFE_SYLVAIN",
            "Elfe-sylvain",
            8,
            6,
            "des elfes des bois",
            "probablement né dans la foret",
            "VOIE_DE_L_ELFE_SYLVAIN",
            hashMapOf("STAT_DEX" to 2, "STAT_FOR" to -1)
        )
    ),
    RACE_HAUT_ELFE(
        Race(
            "RACE_HAUT_ELFE",
            "Haut-elfe",
            6,
            8,
            "des elfes grands",
            "aime la magie, être hautain et desteste les nains",
            "VOIE_DU_HAUT_ELFE",
            hashMapOf("STAT_DEX" to 2, "STAT_INT" to 2, "STAT_FOR" to -2, "STAT_SOC" to -2)
        )
    ),
    RACE_GNOME(
        Race(
            "RACE_GNOME",
            "Gnome",
            6,
            6,
            "petit et pas toujours mignon, bavard et curieux",
            "vivent entre eux généralement",
            "VOIE_DU_GNOME",
            hashMapOf("STAT_SOC" to 2, "STAT_CHAN" to 2, "STAT_FOR" to -2, "STAT_CHA" to -2)
        )
    ),
    RACE_HUMAIN(
        Race(
            "RACE_HUMAIN",
            "Humain",
            6,
            6,
            "péon quelconque",
            "vis puis meurt en ayant fait des trucs entre deux",
            "VOIE_DE_L_HUMAIN",
            hashMapOf("STAT_FOR" to 2, "STAT_INT" to -2)
        )
    ),
    RACE_NAIN(
        Race(
            "RACE_NAIN",
            "Nain",
            8,
            4,
            "petit et barbu",
            "aime l'alcool, forger et déteste les elfes",
            "VOIE_DU_NAIN",
            hashMapOf("STAT_CON" to 2, "STAT_DEX" to -2)
        )
    )
}