package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity

data class DurationUnitWrapper(
    var uuid: String,
    var code: String,       // SECOND / TURN / MINUTE / HOUR ...
    var label: String       // seconde / tour / minutes / heure ...
) : BaseEntity() {

    companion object {
        fun getWrapperFromDS(ds: DataSnapshot): DurationUnitWrapper {
            return DurationUnitWrapper(
                uuid = ds.child("uuid").value as String,
                code = ds.child("code").value as String,
                label = ds.child("label").value as String
            )
        }
    }
}
