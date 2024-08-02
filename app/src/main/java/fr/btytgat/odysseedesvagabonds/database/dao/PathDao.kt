package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.Path

@Dao
interface PathDao {

    @Query("SELECT * FROM " + Path.TABLE_NAME)
    fun getAllPaths(): LiveData<List<Path>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertPath(path: Path): Long

    @Query("SELECT COUNT(*) FROM ${Path.TABLE_NAME}")
    fun getRowCount(): Int

    @Query("SELECT * FROM ${Path.TABLE_NAME} WHERE uuid = :id")
    fun getPathById(id: String): Path
}