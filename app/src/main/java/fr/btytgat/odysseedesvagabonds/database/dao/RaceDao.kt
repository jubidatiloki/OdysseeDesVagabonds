package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.Race

@Dao
interface RaceDao {

    @Query("SELECT * FROM " + Race.TABLE_NAME)
    fun getAllRaces(): List<Race>

    @Insert
    fun insertRace(race: Race): Long
}