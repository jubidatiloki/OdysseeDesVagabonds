package fr.btytgat.odysseedesvagabonds.utils

import android.content.Context
import android.util.Log
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase
import fr.btytgat.odysseedesvagabonds.database.DatabaseManager
import fr.btytgat.odysseedesvagabonds.database.entities.*
import fr.btytgat.odysseedesvagabonds.database.wrapper.RaceWrapper
import fr.btytgat.odysseedesvagabonds.database.wrapper.StatWrapper

class FirebaseUtils {


    companion object {
        val database = Firebase.database("https://odysseedesvagabonds-default-rtdb.europe-west1.firebasedatabase.app").reference
        var localDB: DatabaseManager? = null

        val KEY_SYSTEM = "SYSTEM"
        val KEY_USERS = "USERS"

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
            database.child(KEY_SYSTEM).removeValue()
            StatInitializer.populateStats(database)
            RaceInitializer.populateRaces(database)
            ClasseInitializer.populateClasses(database)

            Log.i("DATABASE", "finished creation datas")

        }

        fun retrieveRace(context: Context, ds: DataSnapshot) {
            localDB = DatabaseManager.getInstance(context)

            val raceWrapper = RaceWrapper.getWrapperFromDS(ds)
            raceWrapper.info?.let {
                localDB?.infoDao()?.insertInfo(Info.getEntityFromWrapper(it))
            }
            raceWrapper.path.let { path ->
                path.info?.let {
                    localDB?.infoDao()?.insertInfo(Info.getEntityFromWrapper(it))
                }
                localDB?.pathDao()?.insertPath(Path.getEntityFromWrapper(path))

                path.talentGroups.forEach{ talentGroup ->
                    localDB?.talentGroupDao()?.insertTalentGroup(TalentGroup.getEntityFromWrapper(talentGroup, path.uuid))

                    talentGroup.talents.forEach {
                        it.info?.let {
                            localDB?.infoDao()?.insertInfo(Info.getEntityFromWrapper(it))
                        }
                        localDB?.talentDao()?.insertTalent(Talent.getEntityFromWrapper(it, talentGroup.uuid))
                    }
                }
            }
            raceWrapper.statsChangeGroup?.let {
                localDB?.statChangeGroupDao()?.insertStatChangeGroup(StatChangeGroup.getEntityFromWrapper(it))
            }
            raceWrapper.specialStatChangeGroups?.forEach {
                it?.let {
                    localDB?.statChangeGroupDao()?.insertStatChangeGroup(StatChangeGroup.getEntityFromWrapper(it))
                }
            }

            localDB?.raceDao()?.insertRace(Race.getEntityFromWrapper(raceWrapper))
            Log.i("retrieveRace", "path=" + localDB?.pathDao()?.getRowCount())
            Log.i("retrieveRace", "talentGroup=" + localDB?.talentGroupDao()?.getRowCount())
            Log.i("retrieveRace", "talent=" + localDB?.talentDao()?.getRowCount())
            Log.i("retrieveRace", "statChange=" + localDB?.statChangeGroupDao()?.getRowCount())
            Log.i("retrieveRace", "race=" + localDB?.raceDao()?.getRowCount())
            Log.i("retrieveRace", "infoCount=" + localDB?.infoDao()?.getRowCount())

        }

        fun retriveStat(context: Context, ds: DataSnapshot) {
            localDB = DatabaseManager.getInstance(context)

            val statWrapper = StatWrapper.getWrapperFromDS(ds)
            statWrapper.info?.let {
                localDB?.infoDao()?.insertInfo(Info.getEntityFromWrapper(it))
            }
            localDB?.statDao()?.insertStat(Stat.getEntityFromWrapper(statWrapper))

            Log.i("retriveStat", "infoCount=" + localDB?.infoDao()?.getRowCount())
            Log.i("retriveStat", "statCount=" + localDB?.statDao()?.getRowCount())


        }

    }
}

