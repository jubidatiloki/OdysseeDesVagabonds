package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.ForeignKey.CASCADE
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity


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
    @PrimaryKey(autoGenerate = false) var uuid: String,
    var name: String,
    var healthDiceModifier: Int,      // -1: decreased, 0: no change, 1: increased
    var manaDiceModifier: Int,        // -1: decreased, 0: no change, 1: increased
    var info: String?,
    var paths: List<String> = emptyList(),
    var maxPathsTaken: Int = 3
): BaseEntity(){

    companion object {
        const val TABLE_NAME = "Classe"
    }

}