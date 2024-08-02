package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import java.util.*

data class TalentGroupWrapper (
    var uuid: String = UUID.randomUUID().toString(),
    var name: String,
    var talentIndex: Long,
    var talents: List<TalentWrapper> = emptyList(),
    var description: String? = null,
){
    companion object{
        fun getWrapperFromDS(ds: DataSnapshot): TalentGroupWrapper {
            return TalentGroupWrapper(
                uuid = ds.child("uuid").value as String,
                name = ds.child("name").value as String,
                talentIndex = ds.child("talentIndex").value as Long,
                talents = ds.child("talents").children.map{ TalentWrapper.getWrapperFromDS(it) },
                description = ds.child("description").value as String?
            )
        }
    }
}