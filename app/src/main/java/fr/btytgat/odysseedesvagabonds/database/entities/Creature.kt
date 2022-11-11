package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
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
    @PrimaryKey(autoGenerate = true) val id: Long?,
    @ColumnInfo(
        index = true,
        name = "id_info"
    ) val idInfo: Long?,
    val creationDate: Date?,
    val lastUpdate: Date?
)