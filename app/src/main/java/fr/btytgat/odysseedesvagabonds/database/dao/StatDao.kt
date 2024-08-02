package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.Stat

@Dao
interface StatDao {

    @Query("SELECT * FROM ${Stat.TABLE_NAME}")
    fun getAllStats(): LiveData<List<Stat>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertStat(stat: Stat): Long

    @Query("SELECT COUNT(*) FROM ${Stat.TABLE_NAME}")
    fun getRowCount(): Int

    @Query("SELECT * FROM ${Stat.TABLE_NAME} WHERE uuid = :id")
    fun getStatById(id: String): Stat
}