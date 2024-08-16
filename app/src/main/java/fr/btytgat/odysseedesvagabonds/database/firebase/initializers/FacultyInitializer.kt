package fr.btytgat.odysseedesvagabonds.database.firebase.initializers

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils
import fr.btytgat.odysseedesvagabonds.database.wrapper.FacultyWrapper
import fr.btytgat.odysseedesvagabonds.database.wrapper.InfoWrapper
import java.util.*

class FacultyInitializer {

    companion object {

        fun populateFaculties(database: DatabaseReference) {
            testAdC.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            testAdT.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            testFor.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
           testDex.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            testCon.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            testInt.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            testPer.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            testSoc.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            testCha.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            testChan.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }

            axeAttack.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            axeDamage.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            hammerAttack.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            hammerDamage.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            testConBreuvage.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
        }

        val testAdC = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - Aptitude de combat",
                "tests AdC",
            ),
            true,
            true,
            0,
            StatInitializer.getStatAdC()
        )


        val testAdT = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - Aptitude de tir",
                "tests AdT",
            ),
            true,
            true,
            0,
            StatInitializer.getStatAdT()
        )


        val testFor = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - Force",
                "tests FORCE",
            ),
            true,
            true,
            0,
            StatInitializer.getStatFor()
        )


        val testDex = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - Dextérité",
                "tests DEX",
            ),
            true,
            true,
            0,
            StatInitializer.getStatDex()
        )
        val testConBreuvage = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "aux tests de constitution liés aux breuvages",
            ),
            false,
            false,
            0,
            StatInitializer.getStatCon()
        )


        val testCon = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "test de constitution",
                "tests CON",
            ),
            true,
            true,
            0,
            StatInitializer.getStatCon(),
            listOf(
                testConBreuvage
            )
        )


        val testInt = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - Intelligence",
                "tests INT",
            ),
            true,
            true,
            0,
            StatInitializer.getStatInt()
        )


        val testPer = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - Perception",
                "tests PER",
            ),
            true,
            true,
            0,
            StatInitializer.getStatPer()
        )

        val testSoc = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - Social",
                "tests SOC",
            ),
            true,
            true,
            0,
            StatInitializer.getStatSoc()
        )


        val testCha = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - Charisme",
                "tests CHA",
            ),
            true,
            true,
            0,
            StatInitializer.getStatCha()
        )


        val testChan = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - Chance",
                "tests CHAN",
            ),
            true,
            true,
            0,
            StatInitializer.getStatChan()
        )


        val axeAttack = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "avec une hache",
                "AdC",
            ),
            true,
            true,
            -3,
            StatInitializer.getStatAdC()
        )


        val axeDamage = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "avec une hache",
                "DMG PHY",
            ),
            true,
            true,
            -3,
            StatInitializer.getStatFor()
        )


        val hammerAttack = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "avec un marteau",
                "AdC",
            ),
            true,
            true,
            -3,
            StatInitializer.getStatAdC()
        )


        val hammerDamage = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "avec un marteau",
                "DMG PHY",
            ),
            true,
            true,
            -3,
            StatInitializer.getStatFor()
        )




    }
}