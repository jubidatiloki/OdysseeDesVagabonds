package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Ignore
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.PathWrapper
import java.util.*

@Entity(
    tableName = Path.TABLE_NAME,
    foreignKeys = [
        (ForeignKey(
            entity = Info::class,
            childColumns = [("info")],
            parentColumns = [("uuid")],
            onDelete = ForeignKey.CASCADE,
            onUpdate = ForeignKey.CASCADE
        ))]
)
data class Path(
    @PrimaryKey var uuid: String = UUID.randomUUID().toString(),
    var info: String,
    var category: String? = null,
    var originType: String,
    var originUuid: String,
    var maxTaken: Long = 1,         // nb max de voies pouvant être prises pour la catégorie choisie
    @Ignore
    var _info: Info? = null,
) : BaseEntity() {
    constructor():this(info = "", originType = "", originUuid = "")


    companion object {
        const val TABLE_NAME = "Path"


        fun getEntityFromWrapper(wrapper: PathWrapper): Path {
            return Path(
                uuid = wrapper.uuid,
                info = wrapper.info.uuid,
                category = wrapper.category,
                originType = wrapper.originType,
                originUuid = wrapper.originUuid,
                maxTaken = wrapper.maxTaken
            )
        }
    }
}