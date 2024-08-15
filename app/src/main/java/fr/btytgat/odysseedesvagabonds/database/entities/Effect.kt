package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.Ignore
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.EffectWrapper
import java.util.UUID

@Entity(tableName = Effect.TABLE_NAME)
data class Effect(
    @PrimaryKey var uuid: String = UUID.randomUUID().toString(),
    var effectType: String,
    var targets: String,
    var permanent: Boolean,
    var duration: String?,
    @Ignore
    var _effectType: EffectType? = null,
    @Ignore
    var _targets: TargetGroup? = null,
    @Ignore
    var _duration: Duration? = null
) : BaseEntity() {

    constructor(): this(effectType = "", targets = "", permanent = false, duration = null)

    companion object {

        const val TABLE_NAME = "Effect"

        fun getEntityFromWrapper(wrapper: EffectWrapper): Effect {
            return Effect(
                uuid = wrapper.uuid,
                effectType = wrapper.effectType.uuid,
                targets = wrapper.targets.uuid,
                permanent = wrapper.isPermanent,
                duration = wrapper.duration?.uuid
            )
        }
    }
}
