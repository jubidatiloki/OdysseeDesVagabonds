package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.Talent

@Dao
interface RangDao {

    @Query("SELECT * FROM rang")
    fun getAllRangs(): List<Talent>

    @Query("SELECT * FROM rang WHERE id_voie = :idVoie")
    fun getAllRangsByRang(idVoie: Long?): List<Talent>



    @Insert
    fun insertAllRangs(rangs: List<Talent>)

    @Insert
    fun insertRang(rang: Talent): Long



    @Delete
    fun deleteRang(talent: Talent)
}
