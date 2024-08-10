package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity

data class EffectWrapper(
    var uuid: String,
    var effectType: EffectTypeWrapper,
    var targets: TargetGroupWrapper,
    var isPermanent: Boolean,
    var duration: DurationWrapper?,
) : BaseEntity() {

    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): EffectWrapper {
            return EffectWrapper(
                uuid = ds.child("uuid").value as String,
                effectType = EffectTypeWrapper.getWrapperFromDS(ds.child("effectType")),
                targets = TargetGroupWrapper.getWrapperFromDS(ds.child("targets")),
                isPermanent = ds.child("permanent").value as Boolean,
                duration = ds.child("duration").value?.let {
                    DurationWrapper.getWrapperFromDS(
                        ds.child(
                            "duration"
                        )
                    )
                }
            )
        }
    }
}
