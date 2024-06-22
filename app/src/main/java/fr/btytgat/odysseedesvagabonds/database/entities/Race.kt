package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import java.util.*
import kotlin.collections.HashMap


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
    @PrimaryKey(autoGenerate = true) var uuid: UUID?,
    var name: String = "",
    var healthDice: Int,
    var manaDice: Int,
    var info: UUID?,
    var uuidVoie: String,
    var statsChange: HashMap<String, Int>
): BaseEntity() {
    companion object {
        const val TABLE_NAME = "Race"
    }
}