package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.TargetGroupWrapper

@Entity(tableName = TargetGroup.TABLE_NAME)
data class TargetGroup(
    @PrimaryKey var uuid: String,
    var selftOnly: Boolean,                 // true = soi uniquement, tout le reste est null, sinon a voir ally et enemy
    var flatValue: Int = 1,
    var enemyTargetable: Boolean?,          // si true = enemis peuvent etre visé (si ally = false, les attributs global et ally sont null)
    var allyTargetable: Boolean?,           // si true = alliés peuvent etre visé (si enemy = false, les attributs global et enemy sont null)
    var nbDice: Int?,
    var dice: String?
) : BaseEntity() {
    companion object {

        const val TABLE_NAME = "TargetGroup"

        fun getEntityFromWrapper(wrapper: TargetGroupWrapper): TargetGroup {
            return TargetGroup(
                uuid = wrapper.uuid,
                selftOnly = wrapper.selftOnly,
                flatValue = wrapper.flatValue,
                enemyTargetable = wrapper.enemyTargetable,
                allyTargetable = wrapper.allyTargetable,
                nbDice = wrapper.nbDice,
                dice = wrapper.dice?.uuid
            )
        }
    }
}
