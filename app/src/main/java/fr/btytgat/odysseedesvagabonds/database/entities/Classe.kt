package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.ForeignKey.CASCADE
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import java.util.*


@Entity(
    tableName = Classe.TABLE_NAME,
    foreignKeys = [(ForeignKey(
        entity = Info::class,
        childColumns = [("info")],
        parentColumns = [("uuid")],
        onDelete = CASCADE,
        onUpdate = CASCADE
    ))])
data class Classe(
    @PrimaryKey(autoGenerate = true) var uuid: UUID?,
    var name: String,
    var healthDiceModifier: Int,      // -1: decreased, 0: no change, 1: increased
    var manaDiceModifier: Int,        // -1: decreased, 0: no change, 1: increased
    var info: UUID?,
    var history: String = "",
    var uuidVoies: List<String> = emptyList(),
): BaseEntity(){

    companion object {
        const val TABLE_NAME = "Classe"
    }

}