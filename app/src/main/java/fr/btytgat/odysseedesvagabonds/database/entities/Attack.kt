package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Ignore
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.AttackWrapper

@Entity(tableName = Attack.TABLE_NAME,
    foreignKeys = [
        (ForeignKey(
            entity = Info::class,
            childColumns = [("info")],
            parentColumns = [("uuid")],
            onDelete = ForeignKey.CASCADE,
            onUpdate = ForeignKey.CASCADE
        ))]
)
data class Attack(
    @PrimaryKey var uuid: String,
    var damage: String,
    var info: String? = null,
    var damageOverTime: Boolean = false,
    var duration: String? = null,
    @Ignore
    var _damage: Damage? = null,
    @Ignore
    var _info: Info? = null,
    @Ignore
    var _duration: Duration? = null
) : BaseEntity() {

    constructor(): this(uuid = "", damage = "", info = null, damageOverTime = false, duration = null)

    companion object {

        const val TABLE_NAME = "Attack"

        fun getEntityFromWrapper(wrapper: AttackWrapper): Attack {
            return Attack(
                uuid = wrapper.uuid,
                damage = wrapper.damage.uuid,
                info = wrapper.info?.uuid,
                damageOverTime = wrapper.damageOverTime,
                duration = wrapper.duration?.uuid
            )
        }
    }
}