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
            testConBrewery.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            testIntRaces.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            testIntHistoricalEvents.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            testIntMagicalCreature.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            testSocMagicalCreature.let {
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
                subDescription = "aux tests d'attaques au corp à corps"
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
                subDescription = "aux tests d'attaques à distance (arcs, frondes, ...)"
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
                subDescription = "aux tests de force"
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
                subDescription = "aux tests de dextérité"
            ),
            true,
            true,
            0,
            StatInitializer.getStatDex()
        )
        val testConBrewery = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - breuvages",
                subDescription = "aux tests de constitution liés aux breuvages",
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
                subDescription = "aux tests de consitution"
            ),
            true,
            true,
            0,
            StatInitializer.getStatCon(),
            listOf(
                testConBrewery
            )
        )

        val testIntRaces = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - connaissances des races",
                subDescription = "aux tests d'intelligence sur la connaissance des races",
            ),
            false,
            false,
            0,
            StatInitializer.getStatInt()
        )

        val testIntHistoricalEvents = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - connaissances des évenments historiques",
                subDescription = "aux tests d'intelligence sur les évenements historiques passés",
            ),
            false,
            false,
            0,
            StatInitializer.getStatInt()
        )

        val testIntMagicalCreature = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - connaissances des créatures magiques",
                subDescription = "aux tests d'intelligence liés aux connaissances sur les créatures magiques ",
            ),
            false,
            false,
            0,
            StatInitializer.getStatInt()
        )


        val testInt = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - Intelligence",
                subDescription = "aux tests d'intelligence"
            ),
            true,
            true,
            0,
            StatInitializer.getStatInt(),
            listOf(
                testIntRaces,
                testIntHistoricalEvents,
                testIntMagicalCreature
            )
        )


        val testPer = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - Perception",
                subDescription = "aux tests de perception"
            ),
            true,
            true,
            0,
            StatInitializer.getStatPer()
        )

        val testSocMagicalCreature = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - communication avec les créatures magiques",
                subDescription = "aux tests de social afin de communiquer avec les créatures magiques ",
            ),
            false,
            false,
            0,
            StatInitializer.getStatSoc()
        )


        val testSoc = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - Social",
                subDescription = "aux tests de social"
            ),
            true,
            true,
            0,
            StatInitializer.getStatSoc(),
            listOf(
                testSocMagicalCreature
            )
        )


        val testCha = FacultyWrapper(
            UUID.randomUUID().toString(),
            info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Test - Charisme",
                subDescription = "aux tests de charisme"
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
                subDescription = "aux tests de chance"
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
                "Attaque - hache",
                subDescription = "avec une hache"
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
                "Dégât - hache",
                subDescription = "avec une hache"
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
                "Attaque - marteau",
                subDescription = "avec un marteau"
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
                "Dégât - marteau",
                subDescription = "avec un marteau"
            ),
            true,
            true,
            -3,
            StatInitializer.getStatFor()
        )




    }
}