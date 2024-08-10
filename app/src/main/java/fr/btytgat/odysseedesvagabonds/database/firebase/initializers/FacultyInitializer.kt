package fr.btytgat.odysseedesvagabonds.database.firebase.initializers

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils
import fr.btytgat.odysseedesvagabonds.database.wrapper.FacultyWrapper
import fr.btytgat.odysseedesvagabonds.database.wrapper.InfoWrapper
import java.util.*

class FacultyInitializer {

    companion object{

        fun populateFaculties(database: DatabaseReference) {
            getTestAdC().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            getTestAdT().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            getTestFor().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            getTestDex().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            getTestCon().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            getTestInt().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            getTestPer().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            getTestSoc().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            getTestCha().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            getTestChan().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }

            getHacheAttack().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            getHacheDamage().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            getMarteauAttack().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            getMarteauDamage().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
            getTestConBreuvage().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_FACULTIES)
                    .child(it.uuid).setValue(it)
            }
        }


        fun getTestAdC(): FacultyWrapper{
            return FacultyWrapper(
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
        }

        fun getTestAdT(): FacultyWrapper{
            return FacultyWrapper(
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
        }

        fun getTestFor(): FacultyWrapper{
            return FacultyWrapper(
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
        }

        fun getTestDex(): FacultyWrapper{
            return FacultyWrapper(
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
        }

        fun getTestCon(): FacultyWrapper{
            return FacultyWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Test - Constitution",
                    "tests CON",
                ),
                true,
                true,
                0,
                StatInitializer.getStatCon(),
                listOf(
                    getTestConBreuvage()
                )
            )
        }

        fun getTestInt(): FacultyWrapper{
            return FacultyWrapper(
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
        }

        fun getTestPer(): FacultyWrapper{
            return FacultyWrapper(
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
        }

        fun getTestSoc(): FacultyWrapper{
            return FacultyWrapper(
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
        }

        fun getTestCha(): FacultyWrapper{
            return FacultyWrapper(
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
        }

        fun getTestChan(): FacultyWrapper{
            return FacultyWrapper(
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
        }

        fun getHacheAttack(): FacultyWrapper {
            return FacultyWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Hache - attaque",
                    null,
                ),
                true,
                true,
                -3,
                StatInitializer.getStatAdC()
            )
        }

        fun getHacheDamage(): FacultyWrapper{
            return FacultyWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Hache - dégât",
                    null,
                ),
                true,
                true,
                -3,
                StatInitializer.getStatFor()
            )
        }

        fun getMarteauAttack(): FacultyWrapper {
            return FacultyWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Marteau - attaque",
                    null,
                ),
                true,
                true,
                -3,
                StatInitializer.getStatAdC()
            )
        }

        fun getMarteauDamage(): FacultyWrapper{
            return FacultyWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Marteau - dégât",
                    null,
                ),
                true,
                true,
                -3,
                StatInitializer.getStatFor()
            )
        }


        fun getTestConBreuvage(): FacultyWrapper {
            return FacultyWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Breuvages",
                    "tests CON liés aux breuvages",
                ),
                false,
                false,
                0,
                StatInitializer.getStatCon()
            )
        }
    }
}