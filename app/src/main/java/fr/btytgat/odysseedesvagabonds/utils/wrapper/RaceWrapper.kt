package fr.btytgat.odysseedesvagabonds.utils.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.entities.Race
import fr.btytgat.odysseedesvagabonds.database.entities.Stat
import fr.btytgat.odysseedesvagabonds.database.entities.Voie
import fr.btytgat.odysseedesvagabonds.utils.DatabaseUtils

data class RaceWrapper(
    var uuid: String,
    var name: String = "",
    var healthDice: Long,
    var manaDice: Long,
    var description: String = "",
    var history: String = "",
    var uuidVoie: String,
    var statsChange: HashMap<String, Long>
) {
    companion object{
        const val keyUuid = "uuid"
        const val keyName = "name"
        const val keyHealthDice = "healthDice"
        const val keyManaDice = "manaDice"
        const val keyDescription = "description"
        const val keyHistory = "history"
        const val keyUuidVoie = "uuidVoie"
        const val keyStatsChange = "statsChange"

        fun toEntity(raceWrapper: RaceWrapper): Race {
            val race = Race(
                uuid = raceWrapper.uuid,
                name = raceWrapper.name,
                healthDice = raceWrapper.healthDice,
                manaDice = raceWrapper.manaDice,
                description = raceWrapper.description,
                history = raceWrapper.history,
                Voie(),
                hashMapOf()
            )

            return race
        }
    }
}