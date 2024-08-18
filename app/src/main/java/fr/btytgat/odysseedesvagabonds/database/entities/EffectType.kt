package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Ignore
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.EffectTypeWrapper

@Entity(tableName = EffectType.TABLE_NAME,
    foreignKeys = [
        (ForeignKey(
            entity = Info::class,
            childColumns = [("info")],
            parentColumns = [("uuid")],
            onDelete = ForeignKey.CASCADE,
            onUpdate = ForeignKey.CASCADE
        ))]
)
data class EffectType(
    @PrimaryKey var uuid: String,
    var info: String,                   // ex: aveuglement
    var statChangeGroup: String,               // "buff" de PER -5, AdT -5
    @Ignore
    var _info: Info? = null,
    @Ignore
    var _statChangeGroup: StatChangeGroup? = null
) : BaseEntity() {

    constructor(): this(uuid = "", info = "", statChangeGroup = "")

    companion object {

        const val TABLE_NAME = "EffectType"

        fun getEntityFromWrapper(wrapper: EffectTypeWrapper): EffectType {
            return EffectType(
                uuid = wrapper.uuid,
                info = wrapper.info.uuid,
                statChangeGroup = wrapper.statChangeGroup.uuid
            )
        }

    }
}
