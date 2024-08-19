package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Ignore
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.StatWrapper

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
    @PrimaryKey var uuid: String,
    var info: String,
    var innate: Boolean,  // true si stat d'une creature, false si c'est un buff externe (equipement, potion, temporaire)
    var haveMod: Boolean,    // pour pouvoir ensuite faire un getter du mod (pour les stats qui en ont un uniquement)
    var type: String,
    @Ignore
    var _info: Info? = null
): BaseEntity(){

    constructor(): this(uuid = "", info = "", innate = false, haveMod = false, type = "")

    companion object {
        const val TABLE_NAME = "Stat"

        fun getEntityFromWrapper(wrapper: StatWrapper): Stat {
            val stat = Stat(
                uuid = wrapper.uuid,
                info = wrapper.info.uuid,
                innate = wrapper.isInnate,
                haveMod = wrapper.haveMod,
                type = wrapper.type
            )
            return stat
        }
    }

}