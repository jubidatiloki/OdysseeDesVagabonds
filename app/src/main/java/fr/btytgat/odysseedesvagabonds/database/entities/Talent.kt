package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import java.util.*

data class Talent(
    @PrimaryKey(autoGenerate = true) var uuid: String = UUID.randomUUID().toString(),
    var info: String?,
    var type: String,                           // talentType
    var isMagic: Boolean,                       // true = dépense du mana, false = aucun cout
    var complexity: Int?,                       // 0 = gratuit, 1 = simple, 2 = complex, null = osef
    var manaCost: Boolean? = false,             // true = coute du mana à lancer (cf rang), false = ne coute pas de mana,  null = cf cout mana variable / pas lié au rang
    var manaCostOverTime: Boolean = false,       // true = coute du mana, false = ne coute pas de mana
    var isTimeLimited: String? = null           // (1f/jour, 3f/combat, ...)
): BaseEntity(){
    companion object {
        const val TABLE_NAME = "TALENT"
    }
}