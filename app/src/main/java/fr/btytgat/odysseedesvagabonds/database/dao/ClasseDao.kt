package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import fr.btytgat.odysseedesvagabonds.database.entities.Classe
import fr.btytgat.odysseedesvagabonds.database.entities.Voie

@Dao
interface ClasseDao {

//    @Query("SELECT * FROM classe")
//    fun getAllClasses(): List<Classe>
//
//
//   @Transaction
//   @Query("SELECT * FROM  classe WHERE id = :idClasse")
//   suspend fun getAllVoiesByClasse(idClasse: Long): List<ClasseVoie>
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