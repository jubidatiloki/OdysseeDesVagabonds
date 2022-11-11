package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey

@Entity(
    foreignKeys = [
        ForeignKey(
        entity = Info::class,
        parentColumns = arrayOf("id"),
        childColumns = arrayOf("id_info")
    ),
    ]
)
data class Race(
    @PrimaryKey(autoGenerate = true) var id: Long?,
    @ColumnInfo(
        index = true,
        name = "id_info") var idInfo: Long?,
) {

    constructor(): this(null, null)


    companion object{
        const val TABLE_NAME = "race"

        fun populateOneRace(idInfo: Long?): Race{
            return Race(null, idInfo)
        }
    }
}