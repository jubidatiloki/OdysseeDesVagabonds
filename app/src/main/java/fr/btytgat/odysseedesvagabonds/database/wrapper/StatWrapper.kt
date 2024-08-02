package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import java.util.*

data class StatWrapper(
    val uuid: String = UUID.randomUUID().toString(),
    var name: String,
    var shortName: String,
    var isInnate: Boolean,  // true si stat d'une creature, false si c'est un buff externe (equipement, potion, temporaire)
    var haveMod: Boolean,    // pour pouvoir ensuite faire un getter du mod (pour les stats qui en ont un uniquement)
    var info: InfoWrapper?,
){
    companion object {
        fun getWrapperFromDS(ds: DataSnapshot): StatWrapper {
            val stat = StatWrapper(
                uuid = ds.child("uuid").value as String,
                name = ds.child("name").value as String,
                shortName = ds.child("shortName").value as String,
                isInnate = ds.child("innate").value as Boolean,
                haveMod = ds.child("haveMod").value as Boolean,
                info = InfoWrapper.getWrapperFromDS(ds.child("info"))
            )
            return stat
        }
    }
}