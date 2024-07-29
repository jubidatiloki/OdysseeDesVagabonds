package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.Path

@Dao
interface VoieDao {

    @Query("SELECT * FROM voie")
    fun getAllVoies(): List<Path>

    @Query("SELECT * FROM voie WHERE id_classe = :idClasse")
    fun getAllVoiesByClasse(idClasse: Long?): List<Path>


    @Insert
    fun insertAllVoies(voies: List<Path>)

    @Insert
    fun insertVoie(voie: Path): Long



    @Delete
    fun deleteVoie(path: Path)
}
