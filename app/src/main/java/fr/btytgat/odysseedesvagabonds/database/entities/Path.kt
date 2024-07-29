package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity


data class Path(
    @PrimaryKey(autoGenerate = false) var uuid: String,
    var name: String,
    var uuidTalents: List<String> = emptyList(),
    var info: String?,
): BaseEntity(){
    companion object {
        const val TABLE_NAME = "Path"
    }
}