package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.Ignore
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.StatChangeWrapper

@Entity(tableName = StatChange.TABLE_NAME)
data class StatChange(
    @PrimaryKey var uuid: String,
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

    constructor(): this(uuid = "",isPositive = false, modifier = 0, statBound = null, facultyBound = null, gainAdvantage = null, gainDisadvantage = null)

    companion object {

        const val TABLE_NAME = "StatChange"

        fun getEntityFromWrapper(wrapper: StatChangeWrapper): StatChange {
            return StatChange(
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
