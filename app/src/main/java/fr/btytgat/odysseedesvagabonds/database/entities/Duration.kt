package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.DurationWrapper

@Entity(tableName = Duration.TABLE_NAME)
data class Duration(
    @PrimaryKey var uuid: String,
    var dice: String?,
    var durationUnit: String,
    var statModifier: String?,      // ex: 1d6 + INT tours
    var nbDice: Int = 0,
    var flatValue: Int = 0,
): BaseEntity(){

    companion object {

        const val TABLE_NAME = "Duration"

        fun getEntityFromWrapper(wrapper: DurationWrapper): Duration {
            return Duration(
                uuid = wrapper.uuid,
                dice = wrapper.dice?.uuid,
                durationUnit = wrapper.durationUnit.uuid,
                statModifier = wrapper.statModifier?.uuid,
                nbDice = wrapper.nbDice,
                flatValue = wrapper.flatValue
            )
        }
    }

}
