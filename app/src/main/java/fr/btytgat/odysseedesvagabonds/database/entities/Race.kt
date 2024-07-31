package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import java.util.*


@Entity(
    tableName = Race.TABLE_NAME,
    foreignKeys = [(ForeignKey(
        entity = Info::class,
        childColumns = [("info")],
        parentColumns = [("uuid")],
        onDelete = ForeignKey.CASCADE,
        onUpdate = ForeignKey.CASCADE
    ))])
data class Race(
    @PrimaryKey(autoGenerate = false) val uuid: String = UUID.randomUUID().toString(),
    var name: String = "",
    var healthDice: Int,
    var manaDice: Int,
    var info: String?,
    var pathUuid: String,
    var statsChangeUuid: String?,
    var specialStatChangeUuid: List<String>?     // à utiliser si statChangeUuid est null, pour gérer le cas du démi-elfe et de l'humain
): BaseEntity() {
    companion object {
        const val TABLE_NAME = "Race"
    }
}