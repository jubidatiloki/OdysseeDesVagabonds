package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.Ignore
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.StatChangeGroupWrapper

@Entity(
    tableName = StatChangeGroup.TABLE_NAME
)
data class StatChangeGroup(
    @PrimaryKey var uuid: String,
    var info: String,
    var buffs: List<String> = emptyList(),
    @Ignore
    var _info: Info? = null,
    @Ignore
    var _buffs: List<Buff>? = emptyList()

    ): BaseEntity(){

    constructor(): this(uuid = "", info = "")

    companion object {
        const val TABLE_NAME = "StatChangeGroup"

        fun getEntityFromWrapper(wrapper: StatChangeGroupWrapper): StatChangeGroup {
            return StatChangeGroup(
                uuid = wrapper.uuid,
                info = wrapper.info.uuid,
                buffs = wrapper.buffs.map { it.uuid }
            )
        }
    }

}