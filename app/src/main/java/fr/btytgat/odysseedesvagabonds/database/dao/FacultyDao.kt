package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.Faculty

@Dao
interface FacultyDao {

    @Query("SELECT * FROM Faculty")
    fun getAll(): List<Faculty>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(faculty: Faculty)

    @Delete
    fun delete(faculty: Faculty)

    @Query("SELECT COUNT(*) FROM Faculty")
    fun getRowCount(): Int

    @Query("SELECT * FROM ${Faculty.TABLE_NAME} WHERE uuid = :id")
    fun getFacultyById(id: String): Faculty?
}