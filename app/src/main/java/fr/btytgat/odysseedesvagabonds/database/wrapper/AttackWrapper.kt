package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity

data class AttackWrapper(
    var uuid: String,
    var damage: DamageWrapper,
    var info: InfoWrapper? = null,
    var damageOverTime: Boolean = false,
    var duration: DurationWrapper? = null,
): BaseEntity() {

    companion object {
        fun getWrapperFromDS(ds: DataSnapshot): AttackWrapper {
            return AttackWrapper(
                uuid = ds.child("uuid").value as String,
                damage = DamageWrapper.getWrapperFromDS(ds.child("damage")),
                info = ds.child("info").value?.let { InfoWrapper.getWrapperFromDS(ds.child("info")) },
                damageOverTime = ds.child("damageOverTime").value as Boolean,
                duration = ds.child("duration").value?.let { DurationWrapper.getWrapperFromDS(ds.child("duration")) }
            )
        }
    }
}