package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.Damage

@Dao
interface DamageDao {

    @Query("SELECT * FROM Damage")
    fun getAll(): List<Damage>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(damage: Damage)

    @Delete
    fun delete(damage: Damage)

    @Query("SELECT COUNT(*) FROM Damage")
    fun getRowCount(): Int

    @Query("SELECT * FROM ${Damage.TABLE_NAME} WHERE uuid = :id")
    fun getDamageById(id: String): Damage

}