package fr.btytgat.odysseedesvagabonds.utils

import android.util.Log
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase

class DatabaseUtils {


    companion object{
        private val database = Firebase.database("https://odysseedesvagabonds-default-rtdb.europe-west1.firebasedatabase.app").reference

        val KEY_CLASSES = "CLASSES"
        val KEY_RACES = "RACES"
        val KEY_STATS = "STATS"
        val KEY_VOIES = "VOIES"
        val KEY_RANGS = "RANGS"

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
                database.child(KEY_CLASSES).child(it.name).setValue(it.classe)
            }
            Log.i("DATABASE", "finished creating classes ....")
        }

        private fun createAllRaces(){
            Log.i("DATABASE", "starting creating races ....")

            RaceEnum.values().forEach {
                Log.i("DATABASE", "create races - ${it.name}")
                database.child(KEY_RACES).child(it.name).setValue(it.race)
            }
            Log.i("DATABASE", "finished creating races ....")

        }

        private fun createAllStats(){
            Log.i("DATABASE", "starting creating stats ....")

            StatEnum.values().forEach {
                Log.i("DATABASE", "create stats - ${it.name}")
                database.child(KEY_STATS).child(it.name).setValue(it.stat)
            }
            Log.i("DATABASE", "finished creating stats ....")

        }

        private fun createAllVoies(){
            Log.i("DATABASE", "starting creating voies ....")

            VoieEnum.values().forEach {
                Log.i("DATABASE", "create voies - ${it.name}")
                database.child(KEY_VOIES).child(it.name).setValue(it.voie)
            }
            Log.i("DATABASE", "finished creating voies ....")

        }

        private fun createAllRangs(){
            Log.i("DATABASE", "starting creating rangs ....")

            RangEnum.values().forEach {
                Log.i("DATABASE", "create rangs - ${it.name}")
                database.child(KEY_RANGS).child(it.name).setValue(it.rang)
            }
            Log.i("DATABASE", "finished creating rangs ....")

        }
    }

}
