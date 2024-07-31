package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import java.util.*


data class Path(
    @PrimaryKey(autoGenerate = true) var uuid: String = UUID.randomUUID().toString(),
    var name: String,
    var uuidTalentGroups: List<String> = emptyList(),
    var info: String?,
): BaseEntity(){
    companion object {
        const val TABLE_NAME = "Path"
    }
}