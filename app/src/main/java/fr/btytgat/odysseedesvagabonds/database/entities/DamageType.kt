package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.DamageTypeWrapper

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
    @PrimaryKey var uuid: String,                                   // défini comme les stats  (ex: PHYSICAL, MAGICAL, ELEM)
    var info: String,                              // name:  dégats de chaos(parent de tout le reste), dégat physique, dégats de feu, ...   shortName: DMG CHAOS, DMG PHY, DMG FEU, ...
    var resistanceType: String?,         // null pour les degats de chaos
    var subDamageTypes: List<String>? = null        // pour définir les sous types (PHY_PIERCING, PHY_BLUNT, PHY_SLASH,   ELEM_FIRE, ELEM_ICE, ...)
) : BaseEntity() {

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
