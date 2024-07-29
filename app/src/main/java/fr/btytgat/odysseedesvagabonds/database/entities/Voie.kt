package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import java.util.*


data class Voie(
    @PrimaryKey(autoGenerate = false) var uuid: UUID,
    var name: String,
    var uuidRangs: List<String> = emptyList(),
    var restriction: Boolean = false
): BaseEntity(){
    companion object {
        const val TABLE_NAME = "Voie"
    }
}