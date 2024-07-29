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

@Database(entities = [Info::class, Classe::class, Race::class], version = 1, exportSchema = false)
@TypeConverters(DBConverters::class)
abstract class DatabaseManager : RoomDatabase() {

    abstract fun infoDao(): InfoDao
    abstract fun classeDao(): ClasseDao
    abstract fun raceDao(): RaceDao

    companion object {
        const val DATABASE_NAME = "ODYSSEE_PROJECT_DB"

        private var sInstance: DatabaseManager? = null


//    private val MIGRATION_1_2 = object : Migration(1, 2) {
//        override fun migrate(database: SupportSQLiteDatabase) {
//            add table Voie
//            add table Rang
//            add table classeVoie
//            add table raceVoie
//            add table voieRang
//        }
//    }

//    private val MIGRATION_2_3 = object : Migration(2, 3) {
//        override fun migrate(database: SupportSQLiteDatabase) {
//            add table Stat

//        }
//    }


//    private val MIGRATION_3_4 = object : Migration(3, 4) {
//        override fun migrate(database: SupportSQLiteDatabase) {
//            add table Topic
//            add table TopicInfo
//        }
//    }


        @Synchronized
        fun getInstance(context: Context): DatabaseManager {
            if (sInstance == null) {
                var databaseBuilder = Room
                    .databaseBuilder(
                        context.applicationContext,
                        DatabaseManager::class.java,
                        DATABASE_NAME
                    )
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