package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.InfoWrapper
import java.util.*


@Entity(tableName = Info.TABLE_NAME)
data class Info(
    @PrimaryKey var uuid: String = UUID.randomUUID().toString(),
    var title: String = "",
    var description: String? = "",
    var subDescription: String? = "",
    var history: String? = "",

    ): BaseEntity() {

    constructor(): this(title = "", description = "", subDescription = null, history = null)

    companion object{

        const val TABLE_NAME = "Info"

        fun getEntityFromWrapper(wrapper: InfoWrapper): Info {
            val info = Info(
                uuid = wrapper.uuid,
                title = wrapper.title,
                description = wrapper.description,
                subDescription = wrapper.subDescription,
                history = wrapper.history
            )
            return info
        }
    }
}