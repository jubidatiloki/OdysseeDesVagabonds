package fr.btytgat.odysseedesvagabonds.database.entities


data class Classe(
    var uuid: String,
    var name: String,
    var healthDiceModifier: Int,      // -1: decreased, 0: no change, 1: increased
    var manaDiceModifier: Int,        // -1: decreased, 0: no change, 1: increased
    var description: String = "",
    var history: String = "",
    var uuidVoies: List<String> = emptyList(),
)