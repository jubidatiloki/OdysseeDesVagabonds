package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity

data class DamageTypeWrapper(
    var uuid: String,                                   // défini comme les stats  (ex: PHYSICAL, MAGICAL, ELEM)
    var info: InfoWrapper,                              // name:  dégats de chaos(parent de tout le reste), dégat physique, dégats de feu, ...   shortName: DMG CHAOS, DMG PHY, DMG FEU, ...
    var resistanceType: ResistanceTypeWrapper?,         // null pour les degats de chaos
    var subDamageTypes: List<DamageTypeWrapper>? = null        // pour définir les sous types (PHY_PIERCING, PHY_BLUNT, PHY_SLASH,   ELEM_FIRE, ELEM_ICE, ...)
) : BaseEntity() {

    companion object {
        fun getWrapperFromDS(ds: DataSnapshot): DamageTypeWrapper {
            return DamageTypeWrapper(
                uuid = ds.child("uuid").value as String,
                info = InfoWrapper.getWrapperFromDS(ds.child("info")),
                resistanceType = ds.child("resistanceType").value?.let {
                    ResistanceTypeWrapper.getWrapperFromDS(
                        ds.child("resistanceType")
                    )
                },
                subDamageTypes = ds.child("subDamageTypes").children.map { getWrapperFromDS(it) }
            )
        }
    }
}
