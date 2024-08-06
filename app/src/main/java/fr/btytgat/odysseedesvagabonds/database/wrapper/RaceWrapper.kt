package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot

data class RaceWrapper(
    var uuid: String,
    var name: String = "",
    var healthDice: Long,
    var manaDice: Long,
    var info: InfoWrapper?,
    var path: PathWrapper,
    var statsChangeGroup: StatChangeWrapper?,
    var tags: List<String>,
    var specialStatChangeGroups: List<StatChangeWrapper?>? = null
) {
    companion object{

        fun getWrapperFromDS(ds: DataSnapshot): RaceWrapper {
            return RaceWrapper(
                uuid = ds.child("uuid").value as String,
                name = ds.child("name").value as String,
                healthDice = ds.child("healthDice").value as Long,
                manaDice = ds.child("manaDice").value as Long,
                info = InfoWrapper.getWrapperFromDS(ds.child("info")),
                path = PathWrapper.getWrapperFromDS(ds.child("path")),
                statsChangeGroup = StatChangeWrapper.getWrapperFromDS(ds.child("statsChangeGroup")),
                tags = ds.child("tags").children.map { it.value as String },
                specialStatChangeGroups = ds.child("specialStatChangeGroups").children.map { StatChangeWrapper.getWrapperFromDS(it)}
            )
        }
    }
}