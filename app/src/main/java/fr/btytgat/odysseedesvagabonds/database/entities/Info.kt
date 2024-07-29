package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity


@Entity(tableName = Info.TABLE_NAME)
data class Info(
    @PrimaryKey val uuid: String,
    var title: String = "",
    var description: String? = "",
    var subDescription: String? = "",
    var history: String? = "",

    ): BaseEntity() {

    constructor(): this(uuid = "", title = "", description = "", subDescription = null, history = null)

    companion object{

        const val TABLE_NAME = "Info"
    }
}