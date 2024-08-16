package fr.btytgat.odysseedesvagabonds.database.firebase.initializers

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils
import fr.btytgat.odysseedesvagabonds.database.wrapper.InfoWrapper
import fr.btytgat.odysseedesvagabonds.database.wrapper.ResistanceTypeWrapper
import java.util.*

class ResistanceTypeInitializer {

    companion object {

        fun populateResistanceType(database: DatabaseReference) {
            resPhy.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RES_TYPE)
                    .child(it.uuid).setValue(it)
            }
            resPhyTranchant.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RES_TYPE)
                    .child(it.uuid).setValue(it)
            }
            resPhyContondant.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RES_TYPE)
                    .child(it.uuid).setValue(it)
            }
            resPhyPercant.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RES_TYPE)
                    .child(it.uuid).setValue(it)
            }
            resMag.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RES_TYPE)
                    .child(it.uuid).setValue(it)
            }
            resElem.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RES_TYPE)
                    .child(it.uuid).setValue(it)
            }
            resElemFeu.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RES_TYPE)
                    .child(it.uuid).setValue(it)
            }
            resElemGlace.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RES_TYPE)
                    .child(it.uuid).setValue(it)
            }
            resElemFoudre.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RES_TYPE)
                    .child(it.uuid).setValue(it)
            }
        }

        val resPhyTranchant = ResistanceTypeWrapper(
            UUID.randomUUID().toString(),
            InfoWrapper(
                UUID.randomUUID().toString(),
                "Résistance aux dégâts tranchants"
            ),
            null,
        )


        val resPhyContondant = ResistanceTypeWrapper(
            UUID.randomUUID().toString(),
            InfoWrapper(
                UUID.randomUUID().toString(),
                "Résistance aux dégâts contondants"
            ),
            null,
        )


        val resPhyPercant = ResistanceTypeWrapper(
            UUID.randomUUID().toString(),
            InfoWrapper(
                UUID.randomUUID().toString(),
                "Résistance aux dégâts perçants"
            ),
            null,
        )

        val resPhy = ResistanceTypeWrapper(
            UUID.randomUUID().toString(),
            InfoWrapper(
                UUID.randomUUID().toString(),
                "Résistance aux dégâts physique"
            ),
            null,
            listOf(
                resPhyTranchant,
                resPhyContondant,
                resPhyPercant
            )
        )





        val resMag = ResistanceTypeWrapper(
            UUID.randomUUID().toString(),
            InfoWrapper(
                UUID.randomUUID().toString(),
                "Résistance aux dégâts magiques"
            ),
            null,
        )

        val resElemFeu = ResistanceTypeWrapper(
            UUID.randomUUID().toString(),
            InfoWrapper(
                UUID.randomUUID().toString(),
                "Résistance aux dégâts de feu"
            ),
            null,
        )


        val resElemGlace = ResistanceTypeWrapper(
            UUID.randomUUID().toString(),
            InfoWrapper(
                UUID.randomUUID().toString(),
                "Résistance aux dégâts de glace"
            ),
            null,
        )


        val resElemFoudre = ResistanceTypeWrapper(
            UUID.randomUUID().toString(),
            InfoWrapper(
                UUID.randomUUID().toString(),
                "Résistance aux dégâts de foudre"
            ),
            null,
        )

        val resElem = ResistanceTypeWrapper(
            UUID.randomUUID().toString(),
            InfoWrapper(
                UUID.randomUUID().toString(),
                "Résistance aux dégâts élémentaires"
            ),
            null,
            listOf(
                resElemFeu,
                resElemGlace,
                resElemFoudre,
            )
        )





    }
}
