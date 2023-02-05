package fr.btytgat.odysseedesvagabonds.database.entities


data class Race(
    var uuid: String,
    var name: String = "",
    var healthDice: Long,
    var manaDice: Long,
    var description: String = "",
    var history: String = "",
    var uuidVoie: String,
    var statsChange: HashMap<String, Long>
)