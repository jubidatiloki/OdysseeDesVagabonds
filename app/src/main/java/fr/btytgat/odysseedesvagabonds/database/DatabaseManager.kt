package fr.btytgat.odysseedesvagabonds.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import androidx.sqlite.db.SupportSQLiteDatabase
import androidx.viewbinding.BuildConfig
import fr.btytgat.odysseedesvagabonds.database.dao.*
import fr.btytgat.odysseedesvagabonds.database.entities.*

@Database(entities = [Creature::class, Info::class, Classe::class, Voie::class, Rang::class, Stat::class, Race::class], version = 1, exportSchema = false)
@TypeConverters(Converters::class)
abstract class DatabaseManager : RoomDatabase() {

    abstract fun creatureDao(): CreatureDao
    abstract fun infoDao(): InfoDao
    abstract fun classeDao(): ClasseDao
    abstract fun voieDao(): VoieDao
    abstract fun rangDao(): RangDao
    abstract fun statDao(): StatDao
    abstract fun raceDao(): RaceDao

companion object{
    private const val DATABASE_NAME = "MAKIDOO_PROJECT_DB"

    private var sInstance: DatabaseManager? = null


//    private val MIGRATION_1_2 = object : Migration(1, 2) {
//        override fun migrate(database: SupportSQLiteDatabase) {
//            database.execSQL("ALTER TABLE ${ProjectEntity.TABLE_NAME} ADD COLUMN userId INTEGER NOT NULL DEFAULT 0")
//        }
//    }
//
//    private val MIGRATION_2_3 = object : Migration(2, 3) {
//        override fun migrate(database: SupportSQLiteDatabase) {
//            database.execSQL("ALTER TABLE ${ScriptStoryEntity.TABLE_NAME} ADD COLUMN nextTransitionDurationInMs INTEGER NOT NULL DEFAULT 0")
//            database.execSQL("ALTER TABLE ${ScriptStoryEntity.TABLE_NAME} ADD COLUMN nextTransition VARCHAR(30) NOT NULL DEFAULT 'NONE'")
//        }
//    }


    @Synchronized
    fun getInstance(context: Context): DatabaseManager {
        if (sInstance == null) {
            var databaseBuilder = Room
                .databaseBuilder(context.applicationContext, DatabaseManager::class.java, DATABASE_NAME)
                .allowMainThreadQueries()
                .openHelperFactory(sInstance as Nothing?)
                .addCallback(object : RoomDatabase.Callback() {
                    override fun onCreate(db: SupportSQLiteDatabase) {
                        super.onCreate(db)

                    }
                })

            if (BuildConfig.DEBUG) {
                databaseBuilder = databaseBuilder
                    .setJournalMode(JournalMode.TRUNCATE)
            }

//            databaseBuilder.addMigrations(MIGRATION_1_2, MIGRATION_2_3)


            sInstance = databaseBuilder
                .build()
        }
        return sInstance!!
    }

    fun initDatabase(databaseManager: DatabaseManager) {
        with(databaseManager){
           infoDao().insertAllInfos(Info.populate())
            val infos =infoDao().getAllInfos()

            val mainStatGuerrier = statDao().insertStat(Stat.populateOneStat("FOR", 0))
            val classeGuerrier = classeDao().insertClasse(Classe.populateOneClasse(infos.first { info -> info.name == "Guerier" }.id, mainStatGuerrier, 2, -2))

            val mainStatDruide = statDao().insertStat(Stat.populateOneStat("INT", 0))
            val classeDruide = classeDao().insertClasse(Classe.populateOneClasse(infos.first { info -> info.name == "druide" }.id, mainStatDruide, 0, 2))
            val voieDruideBestiale = voieDao().insertVoie(Voie.populateOneVoie(infos.first { info -> info.name == "voie bestiale" }.id, classeDruide))
            rangDao().insertRang(Rang.populateOneRang(infos.first { info -> info.name == "animal de compagnie" }.id, voieDruideBestiale))
            rangDao().insertRang(Rang.populateOneRang(infos.first { info -> info.name == "transformation minime" }.id, voieDruideBestiale))
            rangDao().insertRang(Rang.populateOneRang(infos.first { info -> info.name == "mutation partielle" }.id, voieDruideBestiale))
            rangDao().insertRang(Rang.populateOneRang(infos.first { info -> info.name == "animal de combat" }.id, voieDruideBestiale))
            rangDao().insertRang(Rang.populateOneRang(infos.first { info -> info.name == "transformation majeure" }.id, voieDruideBestiale))

            val voieDruideProtecteur = voieDao().insertVoie(Voie.populateOneVoie(infos.first { info -> info.name.equals("voie du protecteur") }.id, classeDruide))
            val voieDruideNature = voieDao().insertVoie(Voie.populateOneVoie(infos.first { info -> info.name.equals("voie de la nature") }.id, classeDruide))

            raceDao().insertRace(Race.populateOneRace(infos.first { info -> info.name.equals("nain") }.id))
            raceDao().insertRace(Race.populateOneRace(infos.first { info -> info.name.equals("draconien") }.id))
            raceDao().insertRace(Race.populateOneRace(infos.first { info -> info.name.equals("humain") }.id))
        }

    }
}

}