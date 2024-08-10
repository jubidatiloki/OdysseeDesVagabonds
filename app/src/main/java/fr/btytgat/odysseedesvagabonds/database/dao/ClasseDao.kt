package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.Classe

@Dao
interface ClasseDao {

    @Query("SELECT * FROM Classe")
    fun getAll(): List<Classe>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(classe: Classe)

    @Delete
    fun delete(classe: Classe)

    @Query("SELECT COUNT(*) FROM ${Classe.TABLE_NAME}")
    fun getRowCount(): Int

}