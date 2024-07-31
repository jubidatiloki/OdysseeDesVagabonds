package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import java.util.*

@Entity(
    tableName = Classe.TABLE_NAME,
    foreignKeys = [(ForeignKey(
        entity = Info::class,
        childColumns = [("info")],
        parentColumns = [("uuid")],
        onDelete = ForeignKey.CASCADE,
        onUpdate = ForeignKey.CASCADE
    ))])
data class StatChangeGroup(
    @PrimaryKey(autoGenerate = false) val uuid: String = UUID.randomUUID().toString(),
    var name: String,
    var info: String?,
    var statChange: HashMap<String, Int>

    ): BaseEntity(){

    companion object {
        const val TABLE_NAME = "Stat"
    }

}