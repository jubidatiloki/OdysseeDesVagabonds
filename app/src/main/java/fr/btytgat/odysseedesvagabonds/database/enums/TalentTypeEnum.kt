package fr.btytgat.odysseedesvagabonds.database.enums

enum class TalentTypeEnum(title: String, description: String, subDescription: String) {
    PASSIF("Passif", "actif en permanence", "sauf mention contraire"),
    REINFORCEMENT("Renforcement", "amélioration d'un autre talent", ""),
    SUPPORT("Soutien", "Compagnion, familier, monture, invocation, ...", ""),
    ACTIF("Talent actif", "Talent qui nécessite d'être utilisé pour faire effet", "peut être magique ou non et complexe ou simple")
}