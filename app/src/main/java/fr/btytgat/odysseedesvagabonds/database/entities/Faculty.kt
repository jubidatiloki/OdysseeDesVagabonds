package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Ignore
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.FacultyWrapper
import java.util.UUID

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
    @PrimaryKey var uuid: String = UUID.randomUUID().toString(),
    var info: String,
    var innate: Boolean,      // si inné, +0  sinon regarder canBeUsedWithoutMastery et si oui utiliser le malusWithoutMastery
    var canBeUsedWithoutMastery: Boolean,
    var malusWithoutMastery: Long,
    var statBound: String? = null,
    var subFaculties: List<String>? = null,
    @Ignore
    var _info: Info? = null,
    @Ignore
    var _statBound: Stat? = null,
    @Ignore
    var _subFaculties: List<Faculty>? = null
): BaseEntity() {

    constructor():this (info = "", innate = false, canBeUsedWithoutMastery = false, malusWithoutMastery = 0L, statBound = null, subFaculties = null)

    companion object {

        const val TABLE_NAME = "Faculty"

        fun getEntityFromWrapper(wrapper: FacultyWrapper): Faculty {
            return Faculty(
                uuid = wrapper.uuid,
                info = wrapper.info.uuid,
                innate = wrapper.isInnate,
                canBeUsedWithoutMastery = wrapper.canBeUsedWithoutMastery,
                malusWithoutMastery = wrapper.malusWithoutMastery,
                statBound = wrapper.statBound?.uuid,
                subFaculties = wrapper.subFaculties?.map { it.uuid }
            )
        }
    }
}
