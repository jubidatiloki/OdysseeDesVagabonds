package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Ignore
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.ResistanceTypeWrapper

@Entity(tableName = ResistanceType.TABLE_NAME,
    foreignKeys = [
        (ForeignKey(
            entity = Info::class,
            childColumns = [("info")],
            parentColumns = [("uuid")],
            onDelete = ForeignKey.CASCADE,
            onUpdate = ForeignKey.CASCADE
        ))]
)
data class ResistanceType(
    @PrimaryKey var uuid: String,
    var info: String,          // name: resistance absolu (réduit tout type de degats), resistance au feu, resistance au dégats percant,  shortName: RES ABSOLU, SHRES FEU, RES PERC
    var statBound: String?,           //  // null pour les dégats de chaos, sinon   l'uuid de la stat correspondante (RD_FEU, RD_PHY, ...)
    /**
     * les resistances s'appliquent en cascade
     * ex: RES ABSOLU = 1, RES PHY = 2, RES PERC = 0
     * RES PERC fait partie des subResistanceTYpe de RES PHY, et ce dernier de RES ABSOLU
     *
     * si le joueur prend une fleche à 10 DMG PERC, le calcul suivant est appliqué:
     * 10 - (0 + 2 + 1) = 7 DMG subits
     *
     */
    var subResistanceTypes: List<String>? = emptyList(),
    @Ignore
    var _statBound: Stat? = null,
    @Ignore
    var _subResistanceTypes: List<ResistanceType>? = null

) : BaseEntity() {

    constructor():this (uuid = "", info = "", statBound = null, subResistanceTypes = null)

    companion object {

        const val TABLE_NAME = "ResistanceType"

        fun getEntityFromWrapper(wrapper: ResistanceTypeWrapper): ResistanceType {

            var subResList = emptyList<String>()
            wrapper.subResistanceTypeWrappers?.map {
                if(it.uuid.isNotEmpty()) {
                    subResList = subResList.plus(it.uuid)
                }
            }
            return ResistanceType(
                uuid = wrapper.uuid,
                info = wrapper.info.uuid,
                statBound = wrapper.statBound?.uuid,
                subResistanceTypes = subResList

            )
        }
    }
}
