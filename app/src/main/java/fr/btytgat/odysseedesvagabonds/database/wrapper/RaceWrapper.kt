package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot

data class RaceWrapper(
    var uuid: String,
    var info: InfoWrapper,
    var healthDice: Long,
    var manaDice: Long,
    var path: PathWrapper,
    var statsChangeGroup: StatChangeGroupWrapper?,
    var tags: List<String>,
    var specialStatChangeGroups: List<StatChangeGroupWrapper?>? = null
) {
    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): RaceWrapper {
            return RaceWrapper(
                uuid = ds.child("uuid").value as String,
                info = InfoWrapper.getWrapperFromDS(ds.child("info")),
                healthDice = ds.child("healthDice").value as Long,
                manaDice = ds.child("manaDice").value as Long,
                path = PathWrapper.getWrapperFromDS(ds.child("path")),
                statsChangeGroup = StatChangeGroupWrapper.getWrapperFromDS(ds.child("statsChangeGroup")),
                tags = ds.child("tags").children.map { it.value as String },
                specialStatChangeGroups = ds.child("specialStatChangeGroups").children.map {
                    StatChangeGroupWrapper.getWrapperFromDS(
                        it
                    )
                }
            )
        }
    }
}