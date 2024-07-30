package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import java.util.*

data class TalentGroup(
    @PrimaryKey(autoGenerate = true) var uuid: UUID,
    var name: String,
    var talentIndex: Int,
    var uuidTalents: List<UUID> = emptyList()
): BaseEntity(){
    companion object {
        const val TABLE_NAME = "TALENT"
    }
}