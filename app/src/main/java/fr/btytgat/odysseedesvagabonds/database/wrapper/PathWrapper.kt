package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot

data class PathWrapper(
    val uuid: String,
    var name: String,
    var info: InfoWrapper?,
    var talentGroups: List<TalentGroupWrapper> = emptyList(),
    var originType: String,
    var originUuid: String,
    var category: String? = null,
    var maxTaken: Long = 1,
){
    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): PathWrapper {
            return PathWrapper(
                uuid = ds.child("uuid").value as String,
                name = ds.child("name").value as String,
                info = InfoWrapper.getWrapperFromDS(ds.child("info")),
                talentGroups = ds.child("talentGroups").children.map { TalentGroupWrapper.getWrapperFromDS(it) },
                category = ds.child("category").value as String?,
                originType = ds.child("originType").value as String,
                originUuid = ds.child("originUuid").value as String,
                maxTaken = ds.child("maxTaken").value as Long
            )
        }
    }
}
