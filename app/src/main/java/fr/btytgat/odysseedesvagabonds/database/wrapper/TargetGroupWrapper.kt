package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity

data class TargetGroupWrapper(
    var uuid: String,
    var selftOnly: Boolean,                 // true = soi uniquement, tout le reste est null, sinon a voir ally et enemy
    var flatValue: Int = 1,
    var enemyTargetable: Boolean?,          // si true = enemis peuvent etre visé (si ally = false, les attributs global et ally sont null)
    var allyTargetable: Boolean?,           // si true = alliés peuvent etre visé (si enemy = false, les attributs global et enemy sont null)
    var nbDice: Int?,
    var dice: DiceWrapper?
) : BaseEntity() {
    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): TargetGroupWrapper {
            return TargetGroupWrapper(
                uuid = ds.child("uuid").value as String,
                selftOnly = ds.child("selfOnly").value as Boolean,
                flatValue = ds.child("flatValue").value as Int,
                enemyTargetable = ds.child("enemyTargetable").value as Boolean?,
                allyTargetable = ds.child("allyTargetable").value as Boolean?,
                nbDice = ds.child("nbDice").value as Int?,
                dice = ds.child("dice").value?.let { DiceWrapper.getWrapperFromDS(ds.child("dice")) }
            )
        }
    }
}
