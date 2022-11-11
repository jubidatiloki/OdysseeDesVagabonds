package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey


@Entity(
    tableName = "competence",
    foreignKeys = [
        ForeignKey(
            entity = Info::class,
            parentColumns = arrayOf("id"),
            childColumns = arrayOf("info")
        ),
    ]
)
data class Competence(
    @PrimaryKey val id: Int,
    @ColumnInfo(
        index = true,
        name = "id_info"
    ) val idInfo: Int?,
) {
}