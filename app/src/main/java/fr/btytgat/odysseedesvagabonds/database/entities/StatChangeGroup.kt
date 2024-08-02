package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.StatChangeWrapper
import java.util.*

@Entity(
    tableName = StatChangeGroup.TABLE_NAME
)
data class StatChangeGroup(
    @PrimaryKey(autoGenerate = false) val uuid: String = UUID.randomUUID().toString(),
    var name: String,
    var statChange: HashMap<String, Long>

    ): BaseEntity(){

    companion object {
        const val TABLE_NAME = "StatChangeGroup"

        fun getEntityFromWrapper(wrapper: StatChangeWrapper): StatChangeGroup {
            return StatChangeGroup(
                uuid = wrapper.uuid,
                name = wrapper.name,
                statChange = wrapper.statChange
            )
        }
    }

}