package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.RaceWrapper
import java.util.*


@Entity(
    tableName = Race.TABLE_NAME,
    foreignKeys = [(ForeignKey(
        entity = Info::class,
        childColumns = [("info")],
        parentColumns = [("uuid")],
        onDelete = ForeignKey.CASCADE,
        onUpdate = ForeignKey.CASCADE
    ))])
data class Race(
    @PrimaryKey(autoGenerate = false) val uuid: String = UUID.randomUUID().toString(),
    var name: String = "",
    var healthDice: Long,
    var manaDice: Long,
    var info: String?,
    var path: String,
    var statsChange: String?,
    var specialStatChange: List<String?>?     // à utiliser si statChangeUuid est null, pour gérer le cas du démi-elfe et de l'humain
): BaseEntity() {
    companion object {
        const val TABLE_NAME = "Race"

        fun getEntityFromWrapper(wrapper: RaceWrapper): Race {
            return Race(
                uuid = wrapper.uuid,
                name = wrapper.name,
                healthDice = wrapper.healthDice,
                manaDice = wrapper.manaDice,
                info = wrapper.info?.uuid,
                path = wrapper.path.uuid,
                statsChange = wrapper.statsChangeGroup?.uuid,
                specialStatChange = wrapper.specialStatChangeGroups?.map { it?.uuid }
            )
        }
    }
}