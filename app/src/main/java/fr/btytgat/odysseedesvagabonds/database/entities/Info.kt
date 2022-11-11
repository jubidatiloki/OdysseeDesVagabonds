package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.EntityEnum


@Entity(tableName = "info")
data class Info(
    @PrimaryKey(autoGenerate = true) var id: Long?,
    var name: String,
    var entity: String,
    var description: String? = "",
    var history: String? = "",

) {

    constructor(): this(id = null, name = "", entity = "", description = null, history = null)

    companion object{

        fun populate(): List<Info>{
            return listOf(
                Info(id = null, name = "Guerier", entity = EntityEnum.CLASSE.name, description = "desc guerrier", history = "history guerrier"),
                Info(id = null, name = "magicien", entity = EntityEnum.CLASSE.name, description = "desc magicien", history = "history magicien"),
                Info(id = null, name = "druide", entity = EntityEnum.CLASSE.name, description = "desc druide", history = "history druide"),

                Info(id = null, name = "nain", entity = EntityEnum.RACE.name, description = "desc nain", history = "history nain"),
                Info(id = null, name = "draconien", entity = EntityEnum.RACE.name, description = "desc draconien", history = "history draconien"),
                Info(id = null, name = "humain", entity = EntityEnum.RACE.name, description = "desc humain", history = "history humain"),


                Info(id = null, name = "voie bestiale", entity = EntityEnum.VOIE.name, description = "desc voie bestiale", history = ""),
                Info(id = null, name = "animal de compagnie", entity = EntityEnum.RANG.name, description = "desc animal de compagnie", history = ""),
                Info(id = null, name = "transformation minime", entity = EntityEnum.RANG.name, description = "desc transformation minime", history = ""),
                Info(id = null, name = "mutation partielle", entity = EntityEnum.RANG.name, description = "desc mutation partielle", history = ""),
                Info(id = null, name = "animal de combat", entity = EntityEnum.RANG.name, description = "desc animal de combat", history = ""),
                Info(id = null, name = "transformation majeure", entity = EntityEnum.RANG.name, description = "desc transformation majeure", history = ""),

                Info(id = null, name = "voie du protecteur", entity = EntityEnum.VOIE.name, description = "desc voie du protecteur", history = ""),
                Info(id = null, name = "voie de la nature", entity = EntityEnum.VOIE.name, description = "desc voie de la nature", history = ""),

            )
        }
    }
}