package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity

data class DiceWrapper(
    var uuid: String,
    var code: String,    // D6
    var label: String,   // dé 6
    var value: Long      // 6
) : BaseEntity() {

    companion object {
        fun getWrapperFromDS(ds: DataSnapshot): DiceWrapper {
            return DiceWrapper(
                uuid = ds.child("uuid").value as String,
                code = ds.child("code").value as String,
                label = ds.child("label").value as String,
                value = ds.child("value").value as Long
            )
        }
    }
}
