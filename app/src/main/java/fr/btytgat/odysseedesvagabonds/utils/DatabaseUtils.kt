package fr.btytgat.odysseedesvagabonds.utils

import android.util.Log
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase

class DatabaseUtils {


    companion object {
        val database =
            Firebase.database("https://odysseedesvagabonds-default-rtdb.europe-west1.firebasedatabase.app").reference
        val KEY_SYSTEM = "SYSTEM"
        val KEY_CLASSES = "CLASSES"
        val KEY_RACES = "RACES"
        val KEY_STATS = "STATS"
        val KEY_PATHS = "PATHS"
        val KEY_INFOS = "INFOS"
        val KEY_TALENTS = "TALENTS"
        val KEY_TALENT_GROUPS = "TALENT_GROUPS"
        val KEY_STAT_CHANGES = "STAT_CHANGES"

        fun initDatabase() {
            Log.i("DATABASE", "starting creating datas ....")
            StatInitializer.populateStats(database)
            RaceInitializer.populateRaces(database)
            ClasseInitializer.populateClasses(database)

            Log.i("DATABASE", "finished creation datas")

        }

    }
}

