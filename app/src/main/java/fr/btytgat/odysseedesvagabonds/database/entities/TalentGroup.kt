package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Ignore
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.TalentGroupWrapper


@Entity(
    tableName = TalentGroup.TABLE_NAME,
    foreignKeys = [
        (ForeignKey(
            entity = Path::class,
            childColumns = [("pathUuid")],
            parentColumns = [("uuid")],
            onDelete = ForeignKey.CASCADE,
            onUpdate = ForeignKey.CASCADE
        )
                )]
)
data class TalentGroup(
    @PrimaryKey var uuid: String,
    var name: String,
    var talentIndex: Long,
    var pathUuid: String,
    var description: String? = null,
    var type: String,                           // talentType
    @Ignore
    var _talents: List<Talent>? = emptyList(),
): BaseEntity(){

    constructor():this (uuid = "", name = "", talentIndex = 0, pathUuid = "", description = "", type = "")

    companion object {

        const val TABLE_NAME = "TalentGroup"

        fun getEntityFromWrapper(wrapper: TalentGroupWrapper, pathUuid: String): TalentGroup {
            return TalentGroup(
                uuid = wrapper.uuid,
                name = wrapper.name,
                talentIndex = wrapper.talentIndex,
                pathUuid = pathUuid,
                description = wrapper.description,
                type = wrapper.type
            )
        }
    }
}