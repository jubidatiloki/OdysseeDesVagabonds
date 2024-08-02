package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.Race

@Dao
interface RaceDao {

    @Query("SELECT * FROM " + Race.TABLE_NAME)
    fun getAllRaces(): LiveData<List<Race>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertRace(race: Race): Long

    @Query("SELECT COUNT(*) FROM ${Race.TABLE_NAME}")
    fun getRowCount(): Int
}