package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.Duration

@Dao
interface DurationDao {

    @Query("SELECT * FROM Duration")
    fun getAll(): List<Duration>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(duration: Duration)

    @Delete
    fun delete(duration: Duration)

    @Query("SELECT COUNT(*) FROM Duration")
    fun getRowCount(): Int
    
}