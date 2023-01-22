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


}

}