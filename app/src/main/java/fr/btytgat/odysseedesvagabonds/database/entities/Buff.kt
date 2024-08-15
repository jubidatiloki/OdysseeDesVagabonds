package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.Ignore
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.BuffWrapper
import java.util.UUID

@Entity(tableName = Buff.TABLE_NAME)
data class Buff(
    @PrimaryKey var uuid: String = UUID.randomUUID().toString(),
    var isPositive: Boolean,        // pour pouvoir filtrer plus facilement si besoin
    var modifier: Long,
    var statBound: String? = null,
    var facultyBound: String? = null,
    var gainAdvantage: Boolean? = null,
    var gainDisadvantage: Boolean? = null,
    @Ignore
    var _statBound: Stat? = null,
    @Ignore
    var _facultyBound: Faculty? = null
) : BaseEntity() {

    constructor(): this(isPositive = false, modifier = 0, statBound = null, facultyBound = null, gainAdvantage = null, gainDisadvantage = null)

    companion object {

        const val TABLE_NAME = "Buff"

        fun getEntityFromWrapper(wrapper: BuffWrapper): Buff {
            return Buff(
                uuid = wrapper.uuid,
                isPositive = wrapper.isPositive,
                modifier = wrapper.modifier,
                statBound = wrapper.statBound?.uuid,
                facultyBound = wrapper.facultyBound?.uuid,
                gainAdvantage = wrapper.gainAdvantage,
                gainDisadvantage = wrapper.gainDisadvantage
            )
        }
    }
}
