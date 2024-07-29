package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.Dao
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.Classe

@Dao
interface ClasseDao {

    @Query("SELECT * FROM Classe")
    fun getAllClasses(): List<Classe>


//   @Transaction
//   @Query("SELECT * FROM  classe WHERE uuid = :idClasse")
//   suspend fun getAllVoiesByClasse(idClasse: UUID): List<ClasseVoie>
//
//
//   @Query("SELECT * FROM classe " +
//           " JOIN voie ON classe.uuid = voie.id_classe")
//   fun getAllVoies(): Map<Classe, List<Voie>>
//
//
//   @Insert
//   fun insertClasse(classe: Classe): Long

}