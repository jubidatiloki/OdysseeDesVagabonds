package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.StatChangeGroup

@Dao
interface StatChangeGroupDao {

    @Query("SELECT * FROM " + StatChangeGroup.TABLE_NAME)
    fun getAllStatChangeGroups(): LiveData<List<StatChangeGroup>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertStatChangeGroup(talent: StatChangeGroup): Long

    @Query("SELECT COUNT(*) FROM ${StatChangeGroup.TABLE_NAME}")
    fun getRowCount(): Int
}