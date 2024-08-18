package fr.btytgat.odysseedesvagabonds.database.firebase.initializers

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils
import fr.btytgat.odysseedesvagabonds.database.wrapper.InfoWrapper
import fr.btytgat.odysseedesvagabonds.database.wrapper.StatChangeGroupWrapper
import fr.btytgat.odysseedesvagabonds.database.wrapper.StatChangeWrapper
import java.util.*

class StatChangeInitializer {

    companion object {


        fun populateStatChangeGroups(database: DatabaseReference) {

            statChangeGroupNain.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STAT_CHANGE_GROUPS)
                    .child(it.uuid).setValue(it)
            }
            statChangeGroupNain1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STAT_CHANGE_GROUPS)
                    .child(it.uuid).setValue(it)
            }
            statChangeGroupNain2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STAT_CHANGE_GROUPS)
                    .child(it.uuid).setValue(it)
            }
            statChangeGroupNain5_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STAT_CHANGE_GROUPS)
                    .child(it.uuid).setValue(it)
            }
            statChangeGroupNain5_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STAT_CHANGE_GROUPS)
                    .child(it.uuid).setValue(it)
            }
            statChangeGroupNain5_3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STAT_CHANGE_GROUPS)
                    .child(it.uuid).setValue(it)
            }
            statChangeGroupNain5_4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STAT_CHANGE_GROUPS)
                    .child(it.uuid).setValue(it)
            }
        }

        val statChangeGroupNain = StatChangeGroupWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Attribut de race - Nain"
            ),
            listOf(
                StatChangeWrapper(
                    UUID.randomUUID().toString(),
                    true,
                    modifier = 2,
                    statBound = StatInitializer.getStatCon()
                ),
                StatChangeWrapper(
                    UUID.randomUUID().toString(),
                    false,
                    modifier = -2,
                    statBound = StatInitializer.getStatDex()
                )
            )
        )


        val statChangeGroupNain1 = StatChangeGroupWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Nain - talent 1",
            ),
            listOf(
                StatChangeWrapper(
                    UUID.randomUUID().toString(),
                    true,
                    1,
                    facultyBound = FacultyInitializer.axeAttack
                ),
                StatChangeWrapper(
                    UUID.randomUUID().toString(),
                    true,
                    1,
                    facultyBound = FacultyInitializer.axeDamage
                ),
                StatChangeWrapper(
                    UUID.randomUUID().toString(),
                    true,
                    1,
                    facultyBound = FacultyInitializer.hammerAttack
                ),
                StatChangeWrapper(
                    UUID.randomUUID().toString(),
                    true,
                    1,
                    facultyBound = FacultyInitializer.hammerDamage
                )
            ),
        )


        val statChangeGroupNain2 = StatChangeGroupWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Nain - talent 2",
            ),
            listOf(
                StatChangeWrapper(
                    UUID.randomUUID().toString(),
                    true,
                    5,
                    facultyBound = FacultyInitializer.testConBreuvage,
                    gainAdvantage = true
                )
            )
        )


        val statChangeGroupNain5_1 = StatChangeGroupWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Nain - talent 5"
            ),
            listOf(
                StatChangeWrapper(
                    UUID.randomUUID().toString(),
                    true,
                    2,
                    statBound = StatInitializer.getStatCon(),
                ),
                StatChangeWrapper(
                    UUID.randomUUID().toString(),
                    true,
                    2,
                    statBound = StatInitializer.getStatRdPhy(),
                ),
                StatChangeWrapper(
                    UUID.randomUUID().toString(),
                    true,
                    2,
                    statBound = StatInitializer.getStatRdMag(),
                )
            )
        )

        val statChangeGroupNain5_2 = StatChangeGroupWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Nain - talent 5"
            ),
            listOf(
                StatChangeWrapper(
                    UUID.randomUUID().toString(),
                    true,
                    2,
                    statBound = StatInitializer.getStatRdFeu(),
                )
            )
        )

        val statChangeGroupNain5_3 = StatChangeGroupWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Nain - talent 5"
            ),
            listOf(
                StatChangeWrapper(
                    UUID.randomUUID().toString(),
                    true,
                    2,
                    statBound = StatInitializer.getStatRdGlace(),
                )
            )
        )


        val statChangeGroupNain5_4 = StatChangeGroupWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Nain - talent 5"
            ),
            listOf(
                StatChangeWrapper(
                    UUID.randomUUID().toString(),
                    true,
                    2,
                    statBound = StatInitializer.getStatRdFoudre(),
                )
            )
        )



    }
}