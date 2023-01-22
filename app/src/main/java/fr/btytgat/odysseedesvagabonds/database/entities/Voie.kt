package fr.btytgat.odysseedesvagabonds.database.entities


data class Voie(
    var uuid: String,
    var name: String,
    var uuidRangs: List<String> = emptyList(),
    var restriction: Boolean = false
)