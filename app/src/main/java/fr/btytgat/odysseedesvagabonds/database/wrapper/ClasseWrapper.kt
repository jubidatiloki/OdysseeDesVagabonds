package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity


data class ClasseWrapper(
     var uuid: String,
    var name: String,
    var healthDiceModifier: Long,      // -1: decreased, 0: no change, 1: increased
    var manaDiceModifier: Long,        // -1: decreased, 0: no change, 1: increased
    var info: InfoWrapper?,
    var paths: List<PathWrapper> = emptyList(),
    var maxPathsTaken: Long = 3
): BaseEntity(){

    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): ClasseWrapper {
            return ClasseWrapper(
                uuid = ds.child("uuid").value as String,
                name = ds.child("name").value as String,
                healthDiceModifier = ds.child("healthDiceModifier").value as Long,
                manaDiceModifier = ds.child("manaDiceModifier").value as Long,
                info = InfoWrapper.getWrapperFromDS(ds.child("info")),
                paths = ds.child("paths").children.map { PathWrapper.getWrapperFromDS(it) },
                maxPathsTaken = ds.child("maxPathsTaken").value as Long
            )
        }
    }

}