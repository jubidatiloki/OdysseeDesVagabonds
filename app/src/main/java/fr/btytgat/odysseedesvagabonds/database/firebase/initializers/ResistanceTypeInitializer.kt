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
            getResPhy().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RES_TYPE)
                    .child(it.uuid).setValue(it)
            }
            getResMag().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RES_TYPE)
                    .child(it.uuid).setValue(it)
            }
            getResElem().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RES_TYPE)
                    .child(it.uuid).setValue(it)
            }
        }

        fun getResPhy(): ResistanceTypeWrapper {
            return ResistanceTypeWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Résistance aux dégâts physique"
                ),
                null,
                listOf(
                    getResTranchant(),
                    getResContondant(),
                    getResPercant()
                )
            )
        }

        fun getResTranchant(): ResistanceTypeWrapper {
            return ResistanceTypeWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Résistance aux dégâts tranchants"
                ),
                null,
            )
        }

        fun getResContondant(): ResistanceTypeWrapper {
            return ResistanceTypeWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Résistance aux dégâts contondants"
                ),
                null,
            )
        }

        fun getResPercant(): ResistanceTypeWrapper {
            return ResistanceTypeWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Résistance aux dégâts perçants"
                ),
                null,
            )
        }

        fun getResMag(): ResistanceTypeWrapper {
            return ResistanceTypeWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Résistance aux dégâts magiques"
                ),
                null,
            )
        }

        fun getResElem(): ResistanceTypeWrapper {
            return ResistanceTypeWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Résistance aux dégâts élémentaires"
                ),
                null,
                listOf(
                    getResElemFeu(),
                    getResElemGlace(),
                    getResElemFoudre(),
                )
            )
        }

        fun getResElemFeu(): ResistanceTypeWrapper {
            return ResistanceTypeWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Résistance aux dégâts de feu"
                ),
                null,
            )
        }

        fun getResElemGlace(): ResistanceTypeWrapper {
            return ResistanceTypeWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Résistance aux dégâts de glace"
                ),
                null,
            )
        }

        fun getResElemFoudre(): ResistanceTypeWrapper {
            return ResistanceTypeWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Résistance aux dégâts de foudre"
                ),
                null,
            )
        }


    }
}
