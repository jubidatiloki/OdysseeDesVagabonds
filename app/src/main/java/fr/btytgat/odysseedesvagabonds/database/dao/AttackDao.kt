package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.Attack

@Dao
interface AttackDao {

    @Query("SELECT * FROM Attack")
    fun getAll(): List<Attack>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(attack: Attack)

    @Delete
    fun delete(attack: Attack)

    @Query("SELECT COUNT(*) FROM Attack")
    fun getRowCount(): Int

    @Query("SELECT * FROM ${Attack.TABLE_NAME} WHERE uuid = :id")
    fun getAttackById(id: String): Attack
    
}