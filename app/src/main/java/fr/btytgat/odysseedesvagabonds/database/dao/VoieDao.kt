package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.Voie

@Dao
interface VoieDao {

    @Query("SELECT * FROM voie")
    fun getAllVoies(): List<Voie>

    @Query("SELECT * FROM voie WHERE id_classe = :idClasse")
    fun getAllVoiesByClasse(idClasse: Long?): List<Voie>


    @Insert
    fun insertAllVoies(voies: List<Voie>)

    @Insert
    fun insertVoie(voie: Voie): Long



    @Delete
    fun deleteVoie(voie: Voie)
}
