package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity

data class FacultyWrapper(
    var uuid: String,
    var info: InfoWrapper,
    var isInnate: Boolean,      // si inné, +0  sinon regarder canBeUsedWithoutMastery et si oui utiliser le malusWithoutMastery
    var canBeUsedWithoutMastery: Boolean,
    var malusWithoutMastery: Long,
    var statBound: StatWrapper? = null,
    var subFaculties: List<FacultyWrapper>? = null
) : BaseEntity() {

    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): FacultyWrapper {
            return FacultyWrapper(
                uuid = ds.child("uuid").value as String,
                info = InfoWrapper.getWrapperFromDS(ds.child("info")),
                isInnate = ds.child("innate").value as Boolean,
                canBeUsedWithoutMastery = ds.child("canBeUsedWithoutMastery").value as Boolean,
                malusWithoutMastery = ds.child("malusWithoutMastery").value as Long,
                statBound = ds.child("statBound").value?.let {
                    StatWrapper.getWrapperFromDS(
                        ds.child(
                            "statBound"
                        )
                    )
                },
                subFaculties = ds.child("subFaculties").children.map { getWrapperFromDS(it) }
            )
        }
    }
}
