package fr.btytgat.odysseedesvagabonds.database.firebase

import android.content.Context
import android.util.Log
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase
import fr.btytgat.odysseedesvagabonds.database.DatabaseManager
import fr.btytgat.odysseedesvagabonds.database.entities.*
import fr.btytgat.odysseedesvagabonds.database.firebase.initializers.*
import fr.btytgat.odysseedesvagabonds.database.firebase.initializers.races.RaceNain
import fr.btytgat.odysseedesvagabonds.database.wrapper.*

class FirebaseUtils {


    companion object {
        val database =
            Firebase.database("https://odysseedesvagabonds-default-rtdb.europe-west1.firebasedatabase.app").reference
        var localDB: DatabaseManager? = null

        val KEY_SYSTEM = "SYSTEM_2"
        val KEY_USERS = "USERS"

        val KEY_CLASSES = "CLASSES"
        val KEY_RACES = "RACES"
        val KEY_STATS = "STATS"
        val KEY_PATHS = "PATHS"
        val KEY_INFOS = "INFOS"
        val KEY_TALENTS = "TALENTS"
        val KEY_TALENT_GROUPS = "TALENT_GROUPS"
        val KEY_STAT_CHANGES = "STAT_CHANGES"
        val KEY_BUFFS = "BUFFS"
        val KEY_FACULTIES = "FACULTIES"
        val KEY_RES_TYPE = "RESISTANCE_TYPE"
        val KEY_DAMAGE_TYPE = "DAMAGE_TYPE"
        val KEY_DICES = "DICES"

        fun initDatabase() {
            Log.i("DATABASE", "starting creating datas ....")
            database.child(KEY_SYSTEM).removeValue()
            StatInitializer.populateStats(database)
            BuffInitializer.populateBuffs(database)
            FacultyInitializer.populateFaculties(database)
            DamageTypeInitializer.populateDamageTypes(database)
            ResistanceTypeInitializer.populateResistanceType(database)
            DiceInitializer.populateDices(database)
            RaceNain.nain(database)

            RaceInitializer.populateRaces(database)
            ClasseInitializer.populateClasses(database)

            Log.i("DATABASE", "finished creation datas")

        }


        fun retriveStat(context: Context, statWrapper: StatWrapper) {
            localDB = DatabaseManager.getInstance(context)

            statWrapper.info.let {
                localDB?.infoDao()?.insertInfo(Info.getEntityFromWrapper(it))
            }
            localDB?.statDao()?.insertStat(Stat.getEntityFromWrapper(statWrapper))

            Log.i("retriveStat", "infoCount=" + localDB?.infoDao()?.getRowCount())
            Log.i("retriveStat", "statCount=" + localDB?.statDao()?.getRowCount())


        }

        fun retrieveFaculties(context: Context, facultyWrapper: FacultyWrapper) {
            localDB = DatabaseManager.getInstance(context)


            facultyWrapper.info.let {
                localDB?.infoDao()?.insertInfo(Info.getEntityFromWrapper(it))
            }
            facultyWrapper.statBound?.let {
                retriveStat(context, it)
            }
            facultyWrapper.subFaculties?.forEach { subFaculty ->
                retrieveFaculties(context, subFaculty)
            }

            localDB?.facultyDao()?.insert(Faculty.getEntityFromWrapper(facultyWrapper))
        }

        fun retrieveDice(context: Context, diceWrapper: DiceWrapper) {

            localDB = DatabaseManager.getInstance(context)

            localDB?.diceDao()?.insert(Dice.getEntityFromWrapper(diceWrapper))
        }

        fun retrieveResistanceType(context: Context, resistanceTypeWrapper: ResistanceTypeWrapper) {
            localDB = DatabaseManager.getInstance(context)

            resistanceTypeWrapper.info.let {
                localDB?.infoDao()?.insertInfo(Info.getEntityFromWrapper(it))
            }

            localDB?.resistanceTypeDao()
                ?.insert(ResistanceType.getEntityFromWrapper(resistanceTypeWrapper))
        }

        fun retrieveDamageType(context: Context, damageTypeWrapper: DamageTypeWrapper) {
            localDB = DatabaseManager.getInstance(context)


            damageTypeWrapper.info.let {
                localDB?.infoDao()?.insertInfo(Info.getEntityFromWrapper(it))
            }
            damageTypeWrapper.resistanceType?.let {
//                already saved
            }
            damageTypeWrapper.subDamageTypes?.forEach { subDamageType ->
                retrieveDamageType(context, subDamageType)
            }

            localDB?.damageTypeDao()?.insert(DamageType.getEntityFromWrapper(damageTypeWrapper))

        }


        fun retrieveRace(context: Context, raceWrapper: RaceWrapper) {
            localDB = DatabaseManager.getInstance(context)

            localDB?.let { localDB ->
                raceWrapper.info.let {
                    localDB.infoDao().insertInfo(Info.getEntityFromWrapper(it))
                }
                raceWrapper.path.let { path ->
                    path.info.let {
                        localDB.infoDao().insertInfo(Info.getEntityFromWrapper(it))
                    }
                    localDB.pathDao().insertPath(Path.getEntityFromWrapper(path))

                    path.talentGroups.forEach { talentGroup ->
                        localDB.talentGroupDao().insertTalentGroup(
                            TalentGroup.getEntityFromWrapper(
                                talentGroup,
                                path.uuid
                            )
                        )

                        talentGroup.talents.forEach {
                            it.info?.let {
                                localDB.infoDao().insertInfo(Info.getEntityFromWrapper(it))
                            }
                            localDB.talentDao()
                                .insertTalent(Talent.getEntityFromWrapper(it, talentGroup.uuid))
                        }
                    }
                }
                raceWrapper.statsChangeGroup?.let {
                    localDB.statChangeGroupDao()
                        .insertStatChangeGroup(StatChangeGroup.getEntityFromWrapper(it))
                }
                raceWrapper.specialStatChangeGroups?.forEach {
                    it?.let {
                        localDB.statChangeGroupDao()
                            .insertStatChangeGroup(StatChangeGroup.getEntityFromWrapper(it))
                    }
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
    }
}

