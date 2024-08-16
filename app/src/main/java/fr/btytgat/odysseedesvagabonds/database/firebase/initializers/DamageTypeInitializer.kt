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
            dmgPhy.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DAMAGE_TYPE)
                    .child(it.uuid).setValue(it)
            }
            dmgPhyTranchant.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DAMAGE_TYPE)
                    .child(it.uuid).setValue(it)
            }
            dmgPhyContondant.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DAMAGE_TYPE)
                    .child(it.uuid).setValue(it)
            }
            dmgPhyPercant.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DAMAGE_TYPE)
                    .child(it.uuid).setValue(it)
            }
            dmgMag.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DAMAGE_TYPE)
                    .child(it.uuid).setValue(it)
            }
            dmgElem.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DAMAGE_TYPE)
                    .child(it.uuid).setValue(it)
            }
            dmgElemFeu.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DAMAGE_TYPE)
                    .child(it.uuid).setValue(it)
            }
            dmgElemGlace.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DAMAGE_TYPE)
                    .child(it.uuid).setValue(it)
            }
            dmgElemFoudre.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DAMAGE_TYPE)
                    .child(it.uuid).setValue(it)
            }
        }

        val dmgPhyTranchant = DamageTypeWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Dégât physique tranchant"
            ),
            ResistanceTypeInitializer.resPhyTranchant,
        )


        val dmgPhyContondant = DamageTypeWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Dégât physique contondant"
            ),
            ResistanceTypeInitializer.resPhyContondant,
        )


        val dmgPhyPercant = DamageTypeWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Dégât physique perçant"
            ),
            ResistanceTypeInitializer.resPhyPercant,
        )

        val dmgPhy = DamageTypeWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Dégât physique",
            ),
            ResistanceTypeInitializer.resPhy,
            listOf(
                dmgPhyTranchant,
                dmgPhyContondant,
                dmgPhyPercant
            )
        )


        val dmgMag = DamageTypeWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Dégât magique",
            ),
            ResistanceTypeInitializer.resMag,
        )

        val dmgElemFeu = DamageTypeWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Dégât élémentaire de feu"
            ),
            ResistanceTypeInitializer.resElemFeu,
        )


        val dmgElemGlace = DamageTypeWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Dégât élémentaire de glace"
            ),
            ResistanceTypeInitializer.resElemGlace,
        )


        val dmgElemFoudre = DamageTypeWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Dégât élémentaire de foudre"
            ),
            ResistanceTypeInitializer.resElemFoudre,
        )

        val dmgElem = DamageTypeWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Dégât élémentaire",
            ),
            ResistanceTypeInitializer.resElem,
            listOf(
                dmgElemFeu,
                dmgElemGlace,
                dmgElemFoudre
            )
        )




    }
}