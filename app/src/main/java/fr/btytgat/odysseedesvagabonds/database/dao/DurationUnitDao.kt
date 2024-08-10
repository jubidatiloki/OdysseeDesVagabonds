package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.DurationUnit

@Dao
interface DurationUnitDao {

    @Query("SELECT * FROM DurationUnit")
    fun getAll(): List<DurationUnit>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(durationUnit: DurationUnit)

    @Delete
    fun delete(durationUnit: DurationUnit)

    @Query("SELECT COUNT(*) FROM DurationUnit")
    fun getRowCount(): Int
    
}