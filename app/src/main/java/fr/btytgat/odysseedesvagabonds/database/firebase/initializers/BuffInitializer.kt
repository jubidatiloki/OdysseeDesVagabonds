package fr.btytgat.odysseedesvagabonds.database.firebase.initializers

import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.wrapper.BuffWrapper
import java.util.*

class BuffInitializer {

    companion object {


        fun populateBuffs(database: DatabaseReference) {

//           populate buffs from effects
        }

        fun buffNain1(): List<BuffWrapper> {
            val buff1 = BuffWrapper(
                UUID.randomUUID().toString(),
                true,
                1,
                facultyBound = FacultyInitializer.getHacheAttack()
            )
            val buff2 = BuffWrapper(
                UUID.randomUUID().toString(),
                true,
                1,
                facultyBound = FacultyInitializer.getHacheDamage()
            )
            val buff3 = BuffWrapper(
                UUID.randomUUID().toString(),
                true,
                1,
                facultyBound = FacultyInitializer.getMarteauAttack()
            )
            val buff4 = BuffWrapper(
                UUID.randomUUID().toString(),
                true,
                1,
                facultyBound = FacultyInitializer.getMarteauDamage()
            )
            return listOf(buff1, buff2, buff3, buff4)
        }

        fun buffNain2(): List<BuffWrapper> {
            val buff = BuffWrapper(
                UUID.randomUUID().toString(),
                true,
                5,
                facultyBound = FacultyInitializer.getTestConBreuvage(),
                gainAdvantage = true
            )
            return listOf(buff)
        }

        fun buffNain5_1(): List<BuffWrapper> {
            val buff1 = BuffWrapper(
                UUID.randomUUID().toString(),
                true,
                2,
                statBound = StatInitializer.getStatCon(),
            )
            val buff2 = BuffWrapper(
                UUID.randomUUID().toString(),
                true,
                2,
                statBound = StatInitializer.getStatRdPhy(),
            )
            val buff3 = BuffWrapper(
                UUID.randomUUID().toString(),
                true,
                2,
                statBound = StatInitializer.getStatRdMag(),
            )
            return listOf(buff1, buff2, buff3)
        }

        fun buffNain5_2(): List<BuffWrapper> {
            val buff = BuffWrapper(
                UUID.randomUUID().toString(),
                true,
                2,
                statBound = StatInitializer.getStatRdFeu(),
            )
            return listOf(buff)
        }

        fun buffNain5_3(): List<BuffWrapper> {
            val buff = BuffWrapper(
                UUID.randomUUID().toString(),
                true,
                2,
                statBound = StatInitializer.getStatRdGlace(),
            )
            return listOf(buff)
        }

        fun buffNain5_4(): List<BuffWrapper> {
            val buff = BuffWrapper(
                UUID.randomUUID().toString(),
                true,
                2,
                statBound = StatInitializer.getStatRdFoudre(),
            )
            return listOf(buff)
        }

    }
}