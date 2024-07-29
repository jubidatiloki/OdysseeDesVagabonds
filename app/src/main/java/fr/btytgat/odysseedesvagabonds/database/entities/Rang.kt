package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import java.util.*

data class Rang(
    @PrimaryKey(autoGenerate = false) var uuid: UUID,
    var name: String,
    var rangNumber: Int,
    var description: String,
): BaseEntity(){
    companion object {
        const val TABLE_NAME = "Rang"
    }
}