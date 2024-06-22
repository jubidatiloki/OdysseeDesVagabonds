package fr.btytgat.odysseedesvagabonds.database.entities


data class Voie(
    var uuid: String,
    var name: String,
    var rangs: List<Rang> = emptyList(),
    var restriction: Boolean = false
) {
    constructor(): this("", "", emptyList(), false)
}