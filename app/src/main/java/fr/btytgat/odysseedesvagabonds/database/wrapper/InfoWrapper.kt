package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import java.util.*

data class InfoWrapper(
    val uuid: String = UUID.randomUUID().toString(),
    var name: String,
    var shortName: String? = "",
    var description: String? = "",
    var subDescription: String? = "",
    var history: String? = "",
) {
    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): InfoWrapper {
            return InfoWrapper(
                uuid = ds.child("uuid").value as String,
                name = ds.child("name").value as String,
                shortName = ds.child("shortName").value as String?,
                description = ds.child("description").value as String?,
                subDescription = ds.child("subDescription").value as String?,
                history = ds.child("history").value as String?
            )
        }
    }
}