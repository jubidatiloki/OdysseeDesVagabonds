package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity

data class EffectTypeWrapper(
    var uuid: String,
    var info: InfoWrapper,                   // ex: aveuglement
    var statChangeGroup: StatChangeGroupWrapper               // "buff" de PER -5, AdT -5
) : BaseEntity() {
    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): EffectTypeWrapper {
            return EffectTypeWrapper(
                uuid = ds.child("uuid").value as String,
                info = InfoWrapper.getWrapperFromDS(ds.child("info")),
                statChangeGroup = StatChangeGroupWrapper.getWrapperFromDS(ds.child("statChangeGroup"))
            )
        }
    }
}
