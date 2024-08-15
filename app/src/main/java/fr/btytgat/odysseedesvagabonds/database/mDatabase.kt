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

@Database(
    entities = [
        Info::class,
        Classe::class,
        Race::class,
        Path::class,
        Talent::class,
        TalentGroup::class,
        Stat::class,
        StatChangeGroup::class,
        Attack::class,
        Buff::class,
        Damage::class,
        DamageType::class,
        Dice::class,
        Duration::class,
        DurationUnit::class,
        Effect::class,
        EffectType::class,
        Faculty::class,
        ResistanceType::class,
        TargetGroup::class
    ],
    version = 1,
    exportSchema = false
)
@TypeConverters(DBConverters::class)
abstract class mDatabase : RoomDatabase() {

    abstract fun infoDao(): InfoDao
    abstract fun classeDao(): ClasseDao
    abstract fun raceDao(): RaceDao
    abstract fun pathDao(): PathDao
    abstract fun talentDao(): TalentDao
    abstract fun talentGroupDao(): TalentGroupDao
    abstract fun statDao(): StatDao
    abstract fun statChangeGroupDao(): StatChangeGroupDao
    abstract fun attackDao(): AttackDao
    abstract fun buffDao(): BuffDao
    abstract fun damageDao(): DamageDao
    abstract fun damageTypeDao(): DamageTypeDao
    abstract fun diceDao(): DiceDao
    abstract fun durationDao(): DurationDao
    abstract fun durationUnitDao(): DurationUnitDao
    abstract fun effectDao(): EffectDao
    abstract fun effectTypeDao(): EffectTypeDao
    abstract fun facultyDao(): FacultyDao
    abstract fun resistanceTypeDao(): ResistanceTypeDao
    abstract fun targetGroupDao(): TargetGroupDao

    companion object {
        const val DATABASE_NAME = "ODYSSEE_PROJECT_DB"

        private var sInstance: mDatabase? = null


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
        fun getInstance(context: Context): mDatabase {
            if (sInstance == null) {
                var databaseBuilder = Room
                    .databaseBuilder(
                        context.applicationContext,
                        mDatabase::class.java,
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