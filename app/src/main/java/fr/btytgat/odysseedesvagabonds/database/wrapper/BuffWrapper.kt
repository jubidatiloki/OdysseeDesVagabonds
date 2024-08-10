package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity

data class BuffWrapper(
    var uuid: String,
    var isPositive: Boolean,        // pour pouvoir filtrer plus facilement si besoin
    var modifier: Long,
    var statBound: StatWrapper? = null,
    var facultyBound: FacultyWrapper? = null,
    var gainAdvantage: Boolean? = null,
    var gainDisadvantage: Boolean? = null,
) : BaseEntity() {

    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): BuffWrapper {
            return BuffWrapper(
                uuid = ds.child("uuid").value as String,
                isPositive = ds.child("positive").value as Boolean,
                modifier = ds.child("modifier").value as Long,
                statBound = ds.child("statBound").value?.let {
                    StatWrapper.getWrapperFromDS(
                        ds.child(
                            "statBound"
                        )
                    )
                },
                facultyBound = ds.child("facultyBound").value?.let {
                    FacultyWrapper.getWrapperFromDS(
                        ds.child("facultyBound")
                    )
                },
                gainAdvantage = ds.child("gainAdvantage").value as Boolean?,
                gainDisadvantage = ds.child("gainDisadvantage").value as Boolean?,
            )
        }
    }
}
