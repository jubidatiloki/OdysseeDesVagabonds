package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.ForeignKey.CASCADE
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.ClasseWrapper


@Entity(
    tableName = Classe.TABLE_NAME,
    foreignKeys = [(ForeignKey(
        entity = Info::class,
        childColumns = [("info")],
        parentColumns = [("uuid")],
        onDelete = CASCADE,
        onUpdate = CASCADE
    ))])
data class Classe(
    @PrimaryKey(autoGenerate = false) var uuid: String,
    var info: String,
    var healthDiceModifier: Long,      // -1: decreased, 0: no change, 1: increased
    var manaDiceModifier: Long,        // -1: decreased, 0: no change, 1: increased
    var paths: List<String> = emptyList(),
    var tags: List<String> = emptyList(),
    var maxPathsTaken: Long = 3
): BaseEntity(){

    companion object {
        const val TABLE_NAME = "Classe"

        fun getEntityFromWrapper(wrapper: ClasseWrapper): Classe {
            return Classe(
                uuid = wrapper.uuid,
                info = wrapper.info.uuid,
                healthDiceModifier = wrapper.healthDiceModifier,
                manaDiceModifier = wrapper.manaDiceModifier,
                paths = wrapper.paths.map { it.uuid },
                tags = wrapper.tags,
                maxPathsTaken = wrapper.maxPathsTaken
            )
        }
    }

}