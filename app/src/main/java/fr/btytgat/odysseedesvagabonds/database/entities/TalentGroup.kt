package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import java.util.*

data class TalentGroup(
    @PrimaryKey(autoGenerate = true) var uuid: String = UUID.randomUUID().toString(),
    var name: String,
    var talentIndex: Int,
    var uuidTalents: List<String> = emptyList(),
    var description: String? = null,
    ): BaseEntity(){
    companion object {
        const val TABLE_NAME = "TALENT"
    }
}