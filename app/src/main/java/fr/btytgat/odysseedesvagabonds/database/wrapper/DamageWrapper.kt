package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity

data class DamageWrapper(
    var uuid: String,
    var flatValue: Long,
    var nbDice: Long,
    var dice: DiceWrapper,
    var damageType: DamageTypeWrapper,
    var statBound: StatWrapper? = null,
    ) : BaseEntity() {

    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): DamageWrapper {
            return DamageWrapper(
                uuid = ds.child("uuid").value as String,
                flatValue = ds.child("flatValue").value as Long,
                nbDice = ds.child("nbDice").value as Long,
                dice = DiceWrapper.getWrapperFromDS(ds.child("dice")),
                damageType = DamageTypeWrapper.getWrapperFromDS(ds.child("damageType")),
                statBound = ds.child("statBound").value?.let { StatWrapper.getWrapperFromDS(ds.child("statBound")) }
            )
        }
    }
}
