package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity

data class Talent(
    @PrimaryKey(autoGenerate = false) var uuid: String,
    var name: String,
    var talentIndex: Int,
    var info: String?,
    var type: String,       // talentType
    var isMagic: Boolean,
    var complexity: Int?,       // 0 = gratuit, 1 = simple, 2 = complex, null = osef
): BaseEntity(){
    companion object {
        const val TABLE_NAME = "TALENT"
    }
}