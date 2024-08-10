package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.ResistanceType

@Dao
interface ResistanceTypeDao {

    @Query("SELECT * FROM ResistanceType")
    fun getAll(): List<ResistanceType>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(resistanceType: ResistanceType)

    @Delete
    fun delete(resistanceType: ResistanceType)

    @Query("SELECT COUNT(*) FROM ResistanceType")
    fun getRowCount(): Int
    
}