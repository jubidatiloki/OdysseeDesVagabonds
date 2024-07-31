package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import java.util.*


data class Path(
    @PrimaryKey(autoGenerate = true) val uuid: String = UUID.randomUUID().toString(),
    var name: String,
    var uuidTalentGroups: List<String> = emptyList(),
    var info: String?,
    var category: String? = null,
    var maxTaken: Int = 1         // nb max de voies pouvant être prises pour la catégorie choisie
): BaseEntity(){
    companion object {
        const val TABLE_NAME = "Path"
    }
}