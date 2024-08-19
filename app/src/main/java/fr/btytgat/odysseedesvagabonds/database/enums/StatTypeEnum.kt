package fr.btytgat.odysseedesvagabonds.database.enums

enum class StatTypeEnum(val label: String) {
    LIFE("Vitalité"),                   // DV, currentPv, maxPv
    MANA("Magie"),                      // DM, currentPm, maxPm
    MAIN("Principal"),                  // AC, AT, AM, FOR, DEX, CON, CHA, INIT ...
    SECONDARY("Secondaire")             // ESQ_CAC, RD_FEU,  ...
}