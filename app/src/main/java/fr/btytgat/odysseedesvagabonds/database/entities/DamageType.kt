package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Ignore
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.DamageTypeWrapper
import java.util.UUID

@Entity(tableName = DamageType.TABLE_NAME,
    foreignKeys = [
        (ForeignKey(
            entity = Info::class,
            childColumns = [("info")],
            parentColumns = [("uuid")],
            onDelete = ForeignKey.CASCADE,
            onUpdate = ForeignKey.CASCADE
        ))]
)
data class DamageType(
    @PrimaryKey var uuid: String = UUID.randomUUID().toString(),                                   // défini comme les stats  (ex: PHYSICAL, MAGICAL, ELEM)
    var info: String,                              // name:  dégats de chaos(parent de tout le reste), dégat physique, dégats de feu, ...   shortName: DMG CHAOS, DMG PHY, DMG FEU, ...
    var resistanceType: String?,         // null pour les degats de chaos
    var subDamageTypes: List<String>? = null,        // pour définir les sous types (PHY_PIERCING, PHY_BLUNT, PHY_SLASH,   ELEM_FIRE, ELEM_ICE, ...)
    @Ignore
    var _resistanceType: ResistanceType? = null,
    @Ignore
    var _subResistanceTypes: List<ResistanceType>? = null
) : BaseEntity() {

    constructor():this(info = "", resistanceType = null, subDamageTypes = null)

    companion object {

        const val TABLE_NAME = "DamageType"

        fun getEntityFromWrapper(wrapper: DamageTypeWrapper): DamageType {
            return DamageType(
                uuid = wrapper.uuid,
                info = wrapper.info.uuid,
                resistanceType = wrapper.resistanceType?.uuid,
                subDamageTypes = wrapper.subDamageTypes?.map { it.uuid }
            )
        }
    }

}
