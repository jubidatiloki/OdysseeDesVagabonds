package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import java.util.*

data class Talent(
    @PrimaryKey(autoGenerate = true) var uuid: String = UUID.randomUUID().toString(),
    var info: String?,
    var type: String,       // talentType
    var isMagic: Boolean,       // true = dépense du mana, false = aucun cout
    var complexity: Int?,       // 0 = gratuit, 1 = simple, 2 = complex, null = osef
): BaseEntity(){
    companion object {
        const val TABLE_NAME = "TALENT"
    }
}