package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
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
    @PrimaryKey(autoGenerate = false) val uuid: String = UUID.randomUUID().toString(),
    var name: String,
    var info: String?,
    var category: String? = null,
    var maxTaken: Long = 1         // nb max de voies pouvant être prises pour la catégorie choisie
) : BaseEntity() {
    companion object {
        const val TABLE_NAME = "Path"


        fun getEntityFromWrapper(wrapper: PathWrapper): Path {
            return Path(
                uuid = wrapper.uuid,
                name = wrapper.name,
                info = wrapper.info?.uuid,
                category = wrapper.category,
                maxTaken = wrapper.maxTaken
            )
        }
    }
}