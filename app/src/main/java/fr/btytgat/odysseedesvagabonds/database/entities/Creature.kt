package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import java.util.*

@Entity(
    tableName = "creature",
    foreignKeys = [
        ForeignKey(
            entity = Info::class,
            parentColumns = arrayOf("id"),
            childColumns = arrayOf("id_info")
        ),
    ]
)
data class Creature(
    @PrimaryKey val uuid: UUID = UUID.randomUUID(),
    @ColumnInfo(
        index = true,
        name = "id_info"
    ) val idInfo: Long?,
    val creationDate: Date?,
    val lastUpdate: Date?
): BaseEntity(){
    companion object {
        const val TABLE_NAME = "Creature"
    }
}