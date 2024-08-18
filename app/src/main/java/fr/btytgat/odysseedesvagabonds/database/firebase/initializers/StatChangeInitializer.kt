package fr.btytgat.odysseedesvagabonds.database.firebase.initializers

import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.wrapper.StatChangeWrapper
import java.util.*

class StatChangeInitializer {

    companion object {


        fun populateBuffs(database: DatabaseReference) {

//           populate buffs from effects
        }

        fun buffNain1(): List<StatChangeWrapper> {
            val buff1 = StatChangeWrapper(
                UUID.randomUUID().toString(),
                true,
                1,
                facultyBound = FacultyInitializer.axeAttack
            )
            val buff2 = StatChangeWrapper(
                UUID.randomUUID().toString(),
                true,
                1,
                facultyBound = FacultyInitializer.axeDamage
            )
            val buff3 = StatChangeWrapper(
                UUID.randomUUID().toString(),
                true,
                1,
                facultyBound = FacultyInitializer.hammerAttack
            )
            val buff4 = StatChangeWrapper(
                UUID.randomUUID().toString(),
                true,
                1,
                facultyBound = FacultyInitializer.hammerDamage
            )
            return listOf(buff1, buff2, buff3, buff4)
        }


        fun buffNain2(): List<StatChangeWrapper> {
            val buff = StatChangeWrapper(
                UUID.randomUUID().toString(),
                true,
                5,
                facultyBound = FacultyInitializer.testConBreuvage,
                gainAdvantage = true
            )
            return listOf(buff)
        }

        fun buffNain5_1(): List<StatChangeWrapper> {
            val buff1 = StatChangeWrapper(
                UUID.randomUUID().toString(),
                true,
                2,
                statBound = StatInitializer.getStatCon(),
            )
            val buff2 = StatChangeWrapper(
                UUID.randomUUID().toString(),
                true,
                2,
                statBound = StatInitializer.getStatRdPhy(),
            )
            val buff3 = StatChangeWrapper(
                UUID.randomUUID().toString(),
                true,
                2,
                statBound = StatInitializer.getStatRdMag(),
            )
            return listOf(buff1, buff2, buff3)
        }

        fun buffNain5_2(): List<StatChangeWrapper> {
            val buff = StatChangeWrapper(
                UUID.randomUUID().toString(),
                true,
                2,
                statBound = StatInitializer.getStatRdFeu(),
            )
            return listOf(buff)
        }

        fun buffNain5_3(): List<StatChangeWrapper> {
            val buff = StatChangeWrapper(
                UUID.randomUUID().toString(),
                true,
                2,
                statBound = StatInitializer.getStatRdGlace(),
            )
            return listOf(buff)
        }

        fun buffNain5_4(): List<StatChangeWrapper> {
            val buff = StatChangeWrapper(
                UUID.randomUUID().toString(),
                true,
                2,
                statBound = StatInitializer.getStatRdFoudre(),
            )
            return listOf(buff)
        }

    }
}