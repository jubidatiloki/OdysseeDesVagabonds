package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.DiceWrapper

@Entity(tableName = Dice.TABLE_NAME)
data class Dice(
    @PrimaryKey var uuid: String,
    var code: String,    // D6
    var label: String,   // dé 6
    var value: Long      // 6
) : BaseEntity() {

    companion object {

        const val TABLE_NAME = "Dice"

        fun getEntityFromWrapper(wrapper: DiceWrapper): Dice {
            return Dice(
                uuid = wrapper.uuid,
                code = wrapper.code,
                label = wrapper.label,
                value = wrapper.value
            )
        }
    }
}
