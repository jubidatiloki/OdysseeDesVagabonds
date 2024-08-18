package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import java.util.*

data class StatChangeGroupWrapper(
    val uuid: String = UUID.randomUUID().toString(),
    var info: InfoWrapper,
    var buffs: List<BuffWrapper>
) {
    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): StatChangeGroupWrapper {
            return StatChangeGroupWrapper(
                uuid = ds.child("uuid").value as String,
                info = InfoWrapper.getWrapperFromDS(ds.child("info")),
                buffs = ds.child("buffs").children.map { BuffWrapper.getWrapperFromDS(it) },
            )
        }
    }
}