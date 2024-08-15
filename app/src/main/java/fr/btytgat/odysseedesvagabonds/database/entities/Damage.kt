package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.Ignore
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.DamageWrapper

@Entity(tableName = Damage.TABLE_NAME)
data class Damage(
    @PrimaryKey var uuid: String,
    var flatValue: Long,
    var nbDice: Long,
    var dice: String,
    var damageType: String,
    @Ignore
    var _dice: Dice? = null,
    @Ignore
    var _damageType: DamageType? = null
) : BaseEntity() {

    companion object {

        const val TABLE_NAME = "Damage"

        fun getEntityFromWrapper(wrapper: DamageWrapper): Damage {
            return Damage(
                uuid = wrapper.uuid,
                flatValue = wrapper.flatValue,
                nbDice = wrapper.nbDice,
                dice = wrapper.dice.uuid,
                damageType = wrapper.damageType.uuid
            )
        }
    }
}
