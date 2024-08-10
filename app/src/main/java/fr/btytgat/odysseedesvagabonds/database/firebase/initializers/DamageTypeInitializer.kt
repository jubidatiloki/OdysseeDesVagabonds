package fr.btytgat.odysseedesvagabonds.database.firebase.initializers

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils
import fr.btytgat.odysseedesvagabonds.database.wrapper.DamageTypeWrapper
import fr.btytgat.odysseedesvagabonds.database.wrapper.InfoWrapper
import java.util.*

class DamageTypeInitializer {

    companion object {

        fun populateDamageTypes(database: DatabaseReference) {
            getDmgPhy().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DAMAGE_TYPE)
                    .child(it.uuid).setValue(it)
            }
            getDmgMag().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DAMAGE_TYPE)
                    .child(it.uuid).setValue(it)
            }
            getDmgElem().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DAMAGE_TYPE)
                    .child(it.uuid).setValue(it)
            }
        }

        fun getDmgPhy(): DamageTypeWrapper {
            return DamageTypeWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Dégât physique",
                ),
                ResistanceTypeInitializer.getResPhy(),
                listOf(
                    getDmgTranchant(),
                    getDmgContondant(),
                    getDmgPercant()
                )
            )
        }

        fun getDmgTranchant(): DamageTypeWrapper {
            return DamageTypeWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Dégât tranchant"
                ),
                ResistanceTypeInitializer.getResTranchant(),
            )
        }

        fun getDmgContondant(): DamageTypeWrapper {
            return DamageTypeWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Dégât contondant"
                ),
                ResistanceTypeInitializer.getResContondant(),
            )
        }

        fun getDmgPercant(): DamageTypeWrapper {
            return DamageTypeWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Dégât perçant"
                ),
                ResistanceTypeInitializer.getResPercant(),
            )
        }


        fun getDmgMag(): DamageTypeWrapper {
            return DamageTypeWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Dégât magique",
                ),
                ResistanceTypeInitializer.getResMag(),
            )
        }

        fun getDmgElem(): DamageTypeWrapper {
            return DamageTypeWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Dégât élémentaire",
                ),
                ResistanceTypeInitializer.getResElem(),
                listOf(
                    getDmgElemFeu(),
                    getDmgElemGlace(),
                    getDmgElemFoudre()
                )
            )
        }

        fun getDmgElemFeu(): DamageTypeWrapper {
            return DamageTypeWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Dégât élémentaire de feu"
                ),
                ResistanceTypeInitializer.getResElemFeu(),
            )
        }

        fun getDmgElemGlace(): DamageTypeWrapper {
            return DamageTypeWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Dégât élémentaire de glace"
                ),
                ResistanceTypeInitializer.getResElemGlace(),
            )
        }

        fun getDmgElemFoudre(): DamageTypeWrapper {
            return DamageTypeWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Dégât élémentaire de foudre"
                ),
                ResistanceTypeInitializer.getResElemFoudre(),
            )
        }
    }
}