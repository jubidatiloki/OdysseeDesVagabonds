package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.EffectWrapper

@Entity(tableName = Effect.TABLE_NAME)
data class Effect(
    @PrimaryKey var uuid: String,
    var effectType: String,
    var targets: String,
    var isPermanent: Boolean,
    var duration: String?,
) : BaseEntity() {

    companion object {

        const val TABLE_NAME = "Effect"

        fun getEntityFromWrapper(wrapper: EffectWrapper): Effect {
            return Effect(
                uuid = wrapper.uuid,
                effectType = wrapper.effectType.uuid,
                targets = wrapper.targets.uuid,
                isPermanent = wrapper.isPermanent,
                duration = wrapper.duration?.uuid
            )
        }
    }
}
