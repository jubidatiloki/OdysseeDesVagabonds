package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity

data class DurationWrapper(
    var uuid: String,
    var dice: DiceWrapper?,
    var durationUnit: DurationUnitWrapper,
    var statModifier: StatWrapper?,      // ex: 1d6 + INT tours
    var nbDice: Int = 0,
    var flatValue: Int = 0,
) : BaseEntity() {

    companion object {
        fun getWrapperFromDS(ds: DataSnapshot): DurationWrapper {
            return DurationWrapper(
                uuid = ds.child("uuid").value as String,
                dice = ds.child("dice").value?.let { DiceWrapper.getWrapperFromDS(ds.child("dice")) },
                durationUnit = DurationUnitWrapper.getWrapperFromDS(ds.child("durationUnit")),
                statModifier = ds.child("statModifier").value?.let {
                    StatWrapper.getWrapperFromDS(
                        ds.child(
                            "statModifier"
                        )
                    )
                },
                nbDice = ds.child("nbDice").value as Int,
                flatValue = ds.child("flatValue").value as Int
            )
        }
    }

}
