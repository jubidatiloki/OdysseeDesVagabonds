package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.Info

@Dao
interface InfoDao {

    @Query("SELECT * FROM info")
    fun getAllInfos(): List<Info>

    @Query("SELECT * FROM info WHERE id = :id")
    fun getInfoById(id: Long?): Info


    @Insert
    fun insertAllInfos(infos: List<Info>)

    @Insert
    fun insertInfo(info: Info): Long



    @Delete
    fun deleteInfo(info: Info)


}