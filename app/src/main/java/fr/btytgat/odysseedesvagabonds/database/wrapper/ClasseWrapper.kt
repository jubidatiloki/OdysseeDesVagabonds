package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity


data class ClasseWrapper(
    var uuid: String,
    var info: InfoWrapper,
    var healthDiceModifier: Long,      // -1: decreased, 0: no change, 1: increased
    var manaDiceModifier: Long,        // -1: decreased, 0: no change, 1: increased
    var paths: List<PathWrapper> = emptyList(),
    var tags: List<String>,
    var maxPathsTaken: Long = 3
) : BaseEntity() {

    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): ClasseWrapper {
            return ClasseWrapper(
                uuid = ds.child("uuid").value as String,
                info = InfoWrapper.getWrapperFromDS(ds.child("info")),
                healthDiceModifier = ds.child("healthDiceModifier").value as Long,
                manaDiceModifier = ds.child("manaDiceModifier").value as Long,
                paths = ds.child("paths").children.map { PathWrapper.getWrapperFromDS(it) },
                tags = ds.child("tags").children.map { it.value as String },
                maxPathsTaken = ds.child("maxPathsTaken").value as Long
            )
        }
    }

}