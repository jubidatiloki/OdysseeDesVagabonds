package fr.btytgat.odysseedesvagabonds.utils

enum class StatEnum(val label: String, val description: String?) {
    ADC("Aptitude de combat", null),
    ADT("Aptitude de tir", null),
    CHA("Charisme", null),
    CHAN("Chance", null),
    CON("Constitution", null),
    DEF_CAC("Défense corps-à-coprs", null),
    DEF_DIST("Défense distance", null),
    DEF_ELEM("Défense élémentaire", null),
    DEF_MAG("Défense magique", null),
    DEX("Dextérité", null),
    DV("Dé de vie", null),
    DM("Dé de mana", null),
    ESQ("Esquive", null),
    FOR("Force", null),
    INIT("Initiative", null),
    INT("Intelligence", null),
    PER("Perception", null),
    PV("Point de vie", null),
    PM("Point de mana", null),
    RD_FEU("Réduction de dégât de feu", null),
    RD_FOUDRE("Réduction de dégât de foudre", null),
    RD_GLACE("Réduction de dégât de glace", null),
    RD_MAG("Réduction de dégât magique", null),
    RD_PHY("Réduction de dégât physique", null),
    SOC("Social", null),

}

//val codeRes: Int, val nameRes: val descriptionRes: Int