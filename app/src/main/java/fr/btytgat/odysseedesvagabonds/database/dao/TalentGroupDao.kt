package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.TalentGroup

@Dao
interface TalentGroupDao {

    @Query("SELECT * FROM " + TalentGroup.TABLE_NAME)
    fun getAllTalentGroups(): LiveData<List<TalentGroup>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertTalentGroup(talentGroup: TalentGroup): Long

    @Query("SELECT COUNT(*) FROM ${TalentGroup.TABLE_NAME}")
    fun getRowCount(): Int
}