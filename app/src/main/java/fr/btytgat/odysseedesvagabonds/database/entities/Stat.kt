package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(
    tableName = "stat"
)
data class Stat(
    @PrimaryKey(autoGenerate = true) var id: Long?,
    var code: String,
    var value: Int,

) {

    constructor(): this(null, "", 0)


    companion object{

        fun populateOneStat(code: String, value: Int): Stat{
            return Stat(null, code, value)
        }
    }
}