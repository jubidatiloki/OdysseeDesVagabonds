package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.Talent

@Dao
interface TalentDao {

    @Query("SELECT * FROM " + Talent.TABLE_NAME)
    fun getAllTalents(): LiveData<List<Talent>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertTalent(talent: Talent): Long

    @Query("SELECT COUNT(*) FROM ${Talent.TABLE_NAME}")
    fun getRowCount(): Int

    @Query("SELECT * FROM ${Talent.TABLE_NAME} WHERE uuid = :id")
    fun getTalentById(id: String): Talent

    @Query("SELECT * FROM ${Talent.TABLE_NAME} WHERE talentGroupUuid = :id")
    fun getTalentsByGroup(id: String): List<Talent>

}