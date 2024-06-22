package fr.btytgat.odysseedesvagabonds.utils.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.entities.Rang
import fr.btytgat.odysseedesvagabonds.database.entities.Voie
import fr.btytgat.odysseedesvagabonds.utils.DatabaseUtils

data class VoieWrapper(
    var uuid: String? = "",
    var name: String? = "",
    var uuidRangs: List<String> = emptyList(),
    var restriction: Boolean? = false
) {
    companion object {
        const val keyUuid = "uuid"
        const val keyName = "name"
        const val keyUuidRangs = "uuidRangs"
        const val keyRestriction = "restriction"


        fun toEntity(voieWrapper: VoieWrapper): Voie {
            val voie = Voie(
                uuid = voieWrapper.uuid ?: "",
                name = voieWrapper.name ?: "",
                restriction = voieWrapper.restriction ?: false
            )
            val rangs = ArrayList<Rang>()
            voieWrapper.uuidRangs.forEach { uuidRang ->
                DatabaseUtils.database.child(DatabaseUtils.KEY_ROOT).child(DatabaseUtils.KEY_RANGS)
                    .child(uuidRang).get().addOnSuccessListener {
                        for (datasnapshot: DataSnapshot in it.children) {
                            rangs.add(RangWrapper.toEntity(DatabaseUtils.retrieveRang(datasnapshot)))
                        }
                    }
            }
            return voie.copy(
                rangs = rangs
            )
        }
    }
}

