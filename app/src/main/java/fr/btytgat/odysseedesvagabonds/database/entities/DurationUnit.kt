package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.DurationUnitWrapper

@Entity(tableName = DurationUnit.TABLE_NAME)
data class DurationUnit(
    @PrimaryKey var uuid: String,
    var code: String,
    var label: String
): BaseEntity(){

    companion object {

        const val TABLE_NAME = "DurationUnit"

        fun getEntityFromWrapper(wrapper: DurationUnitWrapper): DurationUnit {
            return DurationUnit(
                uuid = wrapper.uuid,
                code = wrapper.code,
                label = wrapper.label,
            )
        }
    }
}
