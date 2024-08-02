package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.Info

@Dao
interface InfoDao {

    @Query("SELECT * FROM info")
    fun getAllInfos(): List<Info>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertInfo(info: Info)

    @Insert
    fun insertAllInfos(infos: List<Info>)

    @Delete
    fun deleteInfo(info: Info)

    @Query("SELECT COUNT(*) FROM ${Info.TABLE_NAME}")
    fun getRowCount(): Int

//    @Query("SELECT * FROM info WHERE id = :id")
//    fun getInfoById(id: Long?): Info
//
//
//    @Insert
//    fun insertAllInfos(infos: List<Info>)
//
//    @Insert
//    fun insertInfo(info: Info): Long
//
//
//
//    @Delete
//    fun deleteInfo(info: Info)


}