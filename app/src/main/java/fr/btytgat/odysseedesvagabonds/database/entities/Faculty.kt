package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.FacultyWrapper

@Entity(tableName = Faculty.TABLE_NAME,
    foreignKeys = [
        (ForeignKey(
            entity = Info::class,
            childColumns = [("info")],
            parentColumns = [("uuid")],
            onDelete = ForeignKey.CASCADE,
            onUpdate = ForeignKey.CASCADE
        ))]
)
data class Faculty(
    @PrimaryKey var uuid: String,
    var info: String,
    var isInnate: Boolean,      // si inné, +0  sinon regarder canBeUsedWithoutMastery et si oui utiliser le malusWithoutMastery
    var canBeUsedWithoutMastery: Boolean,
    var malusWithoutMastery: Long,
    var statBound: String? = null,
    var subFaculties: List<String>? = null
): BaseEntity() {

    companion object {

        const val TABLE_NAME = "Faculty"

        fun getEntityFromWrapper(wrapper: FacultyWrapper): Faculty {
            return Faculty(
                uuid = wrapper.uuid,
                info = wrapper.info.uuid,
                isInnate = wrapper.isInnate,
                canBeUsedWithoutMastery = wrapper.canBeUsedWithoutMastery,
                malusWithoutMastery = wrapper.malusWithoutMastery,
                statBound = wrapper.statBound?.uuid,
                subFaculties = wrapper.subFaculties?.map { it.uuid }
            )
        }
    }
}
