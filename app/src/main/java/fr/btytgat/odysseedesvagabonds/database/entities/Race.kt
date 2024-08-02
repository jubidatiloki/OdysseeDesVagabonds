package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Ignore
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
    @PrimaryKey var uuid: String = UUID.randomUUID().toString(),
    var name: String = "",
    var healthDice: Long,
    var manaDice: Long,
    var info: String?,
    var path: String,
    var statsChange: String?,
    var specialStatChange: List<String?>? = null,     // à utiliser si statChangeUuid est null, pour gérer le cas du démi-elfe et de l'humain
    @Ignore
    var _info: Info? = null,
    @Ignore
    var _path: Path? = null,
    @Ignore
    var _statChange: StatChangeGroup? = null,
    @Ignore
    var _specialStatChange: List<StatChangeGroup?>? = null
): BaseEntity() {
    constructor():this(name = "", healthDice = 0, manaDice = 0, info = null, path = "", statsChange = null)

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