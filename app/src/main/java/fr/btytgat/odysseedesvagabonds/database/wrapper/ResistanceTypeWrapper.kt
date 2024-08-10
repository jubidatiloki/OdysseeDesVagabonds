package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.database.BaseEntity

data class ResistanceTypeWrapper(
    var uuid: String,
    var info: InfoWrapper,          // name: resistance absolu (réduit tout type de degats), resistance au feu, resistance au dégats percant,  shortName: RES ABSOLU, SHRES FEU, RES PERC
    var statBound: StatWrapper?,           //  // null pour les dégats de chaos, sinon   l'uuid de la stat correspondante (RD_FEU, RD_PHY, ...)
    /**
     * les resistances s'appliquent en cascade
     * ex: RES ABSOLU = 1, RES PHY = 2, RES PERC = 0
     * RES PERC fait partie des subResistanceTYpe de RES PHY, et ce dernier de RES ABSOLU
     *
     * si le joueur prend une fleche à 10 DMG PERC, le calcul suivant est appliqué:
     * 10 - (0 + 2 + 1) = 7 DMG subits
     *
     */
    var subResistanceTypeWrappers: List<ResistanceTypeWrapper>? = null


) : BaseEntity() {

    companion object {
        fun getWrapperFromDS(ds: DataSnapshot): ResistanceTypeWrapper {
            return ResistanceTypeWrapper(
                uuid = ds.child("uuid").value as String,
                info = InfoWrapper.getWrapperFromDS(ds.child("info")),
                statBound = ds.child("statBound").value?.let {
                    StatWrapper.getWrapperFromDS(
                        ds.child(
                            "statBound"
                        )
                    )
                },
                subResistanceTypeWrappers = ds.child("subResistanceTypes").children.map {
                    getWrapperFromDS(
                        it
                    )
                }
            )
        }
    }
}
