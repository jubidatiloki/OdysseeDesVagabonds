package fr.btytgat.odysseedesvagabonds.utils

enum class RaceEnum(val label: String, val description: String?, val history: String?) {
    DEMI_ELFE("Demi-elfe", "né de parents humains et elfes, leur conviction et leur nature dépend beaucoup d'où ils ont été élevé", "PEGI 18"),
    DEMI_ORQUE("Demi-orque", "mi-orque, mi-humain, et re mi-orque derriere", "PEGI 18"),
    DRACONIEN("Draconien", "des mecs pas assez cools pour être comme des dragons, mais suffisamment badass pour casser la gueule à tout le monde", "dragon > draconien"),
    ELFE_SYLVAIN("Elfe-sylvain", "des elfes des bois", "probablement né dans la foret"),
    HAUT_ELFE("Haut-elfe", "des elfes grands", "aime la magie, être hautain et desteste les nains"),
    GNOME("Gnome", "petit et pas toujours mignon, bavard et curieux", "vivent entre eux généralement"),
    HUMAIN("Humain", "péon quelconque", "vis puis meurt"),
    NAIN("Nain", "petit et poilu", "vis dans la montagne et deteste les elfes")
}