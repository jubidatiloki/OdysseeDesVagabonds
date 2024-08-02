package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import java.util.*

data class InfoWrapper (
    val uuid: String = UUID.randomUUID().toString(),
    var title: String = "",
    var description: String? = "",
    var subDescription: String? = "",
    var history: String? = "",
){
    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): InfoWrapper {
            return InfoWrapper(
                uuid = ds.child("uuid").value as String,
                title = ds.child("title").value as String,
                description = ds.child("description").value as String?,
                subDescription = ds.child("subDescription").value as String?,
                history = ds.child("history").value as String?
            )
        }
    }
}