package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.Rang

@Dao
interface RangDao {

    @Query("SELECT * FROM rang")
    fun getAllRangs(): List<Rang>

    @Query("SELECT * FROM rang WHERE id_voie = :idVoie")
    fun getAllRangsByRang(idVoie: Long?): List<Rang>



    @Insert
    fun insertAllRangs(rangs: List<Rang>)

    @Insert
    fun insertRang(rang: Rang): Long



    @Delete
    fun deleteRang(rang: Rang)
}
