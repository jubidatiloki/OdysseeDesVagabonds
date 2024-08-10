package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import java.util.*

data class StatChangeWrapper(
    val uuid: String = UUID.randomUUID().toString(),
    var name: String,
    var statChange: HashMap<String, Long>
) {
    companion object {

        fun getWrapperFromDS(ds: DataSnapshot?): StatChangeWrapper? {
            if (ds == null)
                return null
            val statChange: kotlin.collections.HashMap<String, Long> = hashMapOf()
            ds.child("statChange").children.forEach {
                statChange[it.key as String] = it.value as Long
            }
            return StatChangeWrapper(
                uuid = ds.child("uuid").value as String,
                name = ds.child("name").value as String,
                statChange = statChange
            )
        }
    }
}