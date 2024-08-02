package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.StatWrapper
import java.util.*

@Entity(
    tableName = Stat.TABLE_NAME,
    foreignKeys = [(ForeignKey(
        entity = Info::class,
        childColumns = [("info")],
        parentColumns = [("uuid")],
        onDelete = ForeignKey.CASCADE,
        onUpdate = ForeignKey.CASCADE
    ))])
data class Stat(
    @PrimaryKey var uuid: String = UUID.randomUUID().toString(),
    var name: String,
    var shortName: String,
    var isInnate: Boolean,  // true si stat d'une creature, false si c'est un buff externe (equipement, potion, temporaire)
    var haveMod: Boolean,    // pour pouvoir ensuite faire un getter du mod (pour les stats qui en ont un uniquement)
    var info: String?,

    ): BaseEntity(){

    companion object {
        const val TABLE_NAME = "Stat"

        fun getEntityFromWrapper(wrapper: StatWrapper): Stat {
            val stat = Stat(
                uuid = wrapper.uuid,
                name = wrapper.name,
                shortName = wrapper.shortName,
                isInnate = wrapper.isInnate,
                haveMod = wrapper.haveMod,
                info = wrapper.info?.uuid
            )
            return stat
        }
    }

}