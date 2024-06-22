package fr.btytgat.odysseedesvagabonds.utils

import android.util.Log
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase
import fr.btytgat.odysseedesvagabonds.database.entities.Race
import fr.btytgat.odysseedesvagabonds.database.entities.Stat
import fr.btytgat.odysseedesvagabonds.utils.wrapper.RaceWrapper
import fr.btytgat.odysseedesvagabonds.utils.wrapper.RangWrapper
import fr.btytgat.odysseedesvagabonds.utils.wrapper.StatWrapper
import fr.btytgat.odysseedesvagabonds.utils.wrapper.VoieWrapper

class DatabaseUtils {


    companion object {
        val database =
            Firebase.database("https://odysseedesvagabonds-default-rtdb.europe-west1.firebasedatabase.app").reference

        val KEY_ROOT = "root"
        val KEY_CLASSES = "classes"
        val KEY_RACES = "races"
        val KEY_STATS = "stats"
        val KEY_VOIES = "voies"
        val KEY_RANGS = "rangs"

        fun initDatabase() {
            Log.i("DATABASE", "starting creating datas ....")
            createAllClasses()
            createAllRaces()
            createAllVoies()
            createAllRangs()
            createAllStats()
            Log.i("DATABASE", "finished creating datas ....")

        }

        private fun createAllClasses() {
            Log.i("DATABASE", "starting creating classes ....")

            ClasseEnum.values().forEach {
                Log.i("DATABASE", "create classe - ${it.name}")
                database.child(KEY_ROOT).child(KEY_CLASSES).child(it.name).setValue(it.classe)
            }
            Log.i("DATABASE", "finished creating classes ....")
        }

        private fun createAllRaces() {
            Log.i("DATABASE", "starting creating races ....")

            RaceEnum.values().forEach {
                Log.i("DATABASE", "create races - ${it.name}")
                database.child(KEY_ROOT).child(KEY_RACES).child(it.name).setValue(it.race)
            }
            Log.i("DATABASE", "finished creating races ....")

        }

        private fun createAllStats() {
            Log.i("DATABASE", "starting creating stats ....")

            StatEnum.values().forEach {
                Log.i("DATABASE", "create stats - ${it.name}")
                database.child(KEY_ROOT).child(KEY_STATS).child(it.name).setValue(it.stat)
            }
            Log.i("DATABASE", "finished creating stats ....")

        }

        private fun createAllVoies() {
            Log.i("DATABASE", "starting creating voies ....")

            VoieEnum.values().forEach {
                Log.i("DATABASE", "create voies - ${it.name}")
                database.child(KEY_ROOT).child(KEY_VOIES).child(it.name).setValue(it.voie)
            }
            Log.i("DATABASE", "finished creating voies ....")

        }

        private fun createAllRangs() {
            Log.i("DATABASE", "starting creating rangs ....")

            RangEnum.values().forEach {
                Log.i("DATABASE", "create rangs - ${it.name}")
                database.child(KEY_ROOT).child(KEY_RANGS).child(it.name).setValue(it.rang)
            }
            Log.i("DATABASE", "finished creating rangs ....")

        }




        fun retrieveRace(ds: DataSnapshot): RaceWrapper {
            Log.i("retrieveRace", "key=" + ds.key);
            val raceWrapper = RaceWrapper(
                healthDice = ds.child(RaceWrapper.keyHealthDice).value as Long,
                manaDice = ds.child(RaceWrapper.keyManaDice).value as Long,
                name = ds.child(RaceWrapper.keyName).value as String,
                description = ds.child(RaceWrapper.keyDescription).value as String,
                uuid = ds.child(RaceWrapper.keyUuid).value as String,
                uuidVoie = ds.child(RaceWrapper.keyUuidVoie).value as String,
                history = ds.child(RaceWrapper.keyHistory).value as String,
                statsChange = ds.child(RaceWrapper.keyStatsChange).value as HashMap<String, Long>
            )
            Log.i("retrieveRace", "raceWrapper=" + raceWrapper)
            return raceWrapper
        }

        fun retrieveVoie(ds: DataSnapshot): VoieWrapper {
            Log.i("retrieveVoie", "key=" + ds.key);

            val voieWrapper = VoieWrapper(
                uuid = ds.child(VoieWrapper.keyUuid).value as String?,
                name = ds.child(VoieWrapper.keyName).value as String?,
                uuidRangs = if(ds.child(VoieWrapper.keyUuidRangs).value == null) emptyList() else ds.child(VoieWrapper.keyUuidRangs).value as List<String>,
                restriction = ds.child(VoieWrapper.keyRestriction).value as Boolean?
            )
            Log.i("retrieveVoie", "value=$voieWrapper")
            return voieWrapper
        }


        fun retrieveRang(ds: DataSnapshot): RangWrapper {
            Log.i("retrieveRang", "key=" + ds.key);

            return RangWrapper(
                uuid = ds.child(RangWrapper.keyUuid).value as String?,
                name = ds.child(RangWrapper.keyName).value as String?,
                rangNumber = ds.child(RangWrapper.keyRangNumber).value as Int?,
                description = ds.child(RangWrapper.keyDescription).value as String?
            )
        }

        fun retrieveStat(ds: DataSnapshot): StatWrapper {

            val statWrapper = StatWrapper(
                uuid = ds.child(StatWrapper.keyUuid).value as String?,
                description = ds.child(StatWrapper.keyDescription).value as String?,
                haveMod = ds.child(StatWrapper.keyHaveMod).value as Boolean?,
                isInnate = ds.child(StatWrapper.keyIsInnate).value as Boolean?,
                name = ds.child(StatWrapper.keyName).value as String?,
                shortName = ds.child(StatWrapper.keyShortName).value as String?,
                subDescription = ds.child(StatWrapper.keySubDescription).value as String?
            )
            Log.i("retrieveStat", "value=$statWrapper");
            return statWrapper
        }
    }

}

