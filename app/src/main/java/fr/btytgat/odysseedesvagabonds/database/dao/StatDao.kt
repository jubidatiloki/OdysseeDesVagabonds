package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.Stat

@Dao
interface StatDao {

    @Query("SELECT * FROM stat")
    fun getAllStats(): List<Stat>



    @Insert
    fun insertAllStats(stat: List<Stat>)

    @Insert
    fun insertStat(stat: Stat): Long



    @Delete
    fun deleteStat(stat: Stat)
}