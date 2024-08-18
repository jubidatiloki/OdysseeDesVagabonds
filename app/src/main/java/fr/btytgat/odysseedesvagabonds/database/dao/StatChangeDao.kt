package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.StatChange

@Dao
interface StatChangeDao {

    @Query("SELECT * FROM StatChange")
    fun getAll(): List<StatChange>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(statChange: StatChange)

    @Delete
    fun delete(statChange: StatChange)

    @Query("SELECT COUNT(*) FROM StatChange")
    fun getRowCount(): Int

    @Query("SELECT * FROM ${StatChange.TABLE_NAME} WHERE uuid = :id")
    fun getStatChangeById(id: String): StatChange
}