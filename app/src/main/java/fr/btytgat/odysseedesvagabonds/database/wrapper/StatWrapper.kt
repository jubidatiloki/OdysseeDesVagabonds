package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import java.util.*

data class StatWrapper(
    val uuid: String = UUID.randomUUID().toString(),
    var info: InfoWrapper,
    var isInnate: Boolean,  // true si stat d'une creature, false si c'est un buff externe (equipement, potion, temporaire)
    var haveMod: Boolean,    // pour pouvoir ensuite faire un getter du mod (pour les stats qui en ont un uniquement)
    var type: String
) {
    companion object {
        fun getWrapperFromDS(ds: DataSnapshot): StatWrapper {
            val stat = StatWrapper(
                uuid = ds.child("uuid").value as String,
                info = InfoWrapper.getWrapperFromDS(ds.child("info")),
                isInnate = ds.child("innate").value as Boolean,
                haveMod = ds.child("haveMod").value as Boolean,
                type = ds.child("type").value as String
            )
            return stat
        }
    }
}