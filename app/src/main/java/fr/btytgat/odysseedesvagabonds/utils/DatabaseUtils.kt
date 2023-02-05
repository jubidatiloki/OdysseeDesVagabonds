package fr.btytgat.odysseedesvagabonds.utils

import android.util.Log
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase
import fr.btytgat.odysseedesvagabonds.database.entities.Race

class DatabaseUtils {


    companion object{
        val database = Firebase.database("https://odysseedesvagabonds-default-rtdb.europe-west1.firebasedatabase.app").reference

        val KEY_ROOT = "root"
        val KEY_CLASSES = "classes"
        val KEY_RACES = "races"
        val KEY_STATS = "stats"
        val KEY_VOIES = "voies"
        val KEY_RANGS = "rangs"

        fun initDatabase(){
            Log.i("DATABASE", "starting creating datas ....")
            createAllClasses()
            createAllRaces()
            createAllVoies()
            createAllRangs()
            createAllStats()
            Log.i("DATABASE", "finished creating datas ....")

        }

        private fun createAllClasses(){
            Log.i("DATABASE", "starting creating classes ....")

            ClasseEnum.values().forEach {
                Log.i("DATABASE", "create classe - ${it.name}")
                database.child(KEY_ROOT).child(KEY_CLASSES).child(it.name).setValue(it.classe)
            }
            Log.i("DATABASE", "finished creating classes ....")
        }

        private fun createAllRaces(){
            Log.i("DATABASE", "starting creating races ....")

            RaceEnum.values().forEach {
                Log.i("DATABASE", "create races - ${it.name}")
                database.child(KEY_ROOT).child(KEY_RACES).child(it.name).setValue(it.race)
            }
            Log.i("DATABASE", "finished creating races ....")

        }

        private fun createAllStats(){
            Log.i("DATABASE", "starting creating stats ....")

            StatEnum.values().forEach {
                Log.i("DATABASE", "create stats - ${it.name}")
                database.child(KEY_ROOT).child(KEY_STATS).child(it.name).setValue(it.stat)
            }
            Log.i("DATABASE", "finished creating stats ....")

        }

        private fun createAllVoies(){
            Log.i("DATABASE", "starting creating voies ....")

            VoieEnum.values().forEach {
                Log.i("DATABASE", "create voies - ${it.name}")
                database.child(KEY_ROOT).child(KEY_VOIES).child(it.name).setValue(it.voie)
            }
            Log.i("DATABASE", "finished creating voies ....")

        }

        private fun createAllRangs(){
            Log.i("DATABASE", "starting creating rangs ....")

            RangEnum.values().forEach {
                Log.i("DATABASE", "create rangs - ${it.name}")
                database.child(KEY_ROOT).child(KEY_RANGS).child(it.name).setValue(it.rang)
            }
            Log.i("DATABASE", "finished creating rangs ....")

        }





        fun retrieveRace(ds: DataSnapshot): Race {
            val race = Race(
                healthDice = ds.child("healthDice").value as Long,
                manaDice = ds.child("manaDice").value as Long,
                name = ds.child("name").value as String,
                description = ds.child("description").value as String,
                uuid = ds.child("uuid").value as String,
                uuidVoie = ds.child("uuidVoie").value as String,
                history = ds.child("history").value as String,
                statsChange = ds.child("statsChange").value as HashMap<String, Long>
            )

            return race
        }
    }

}

