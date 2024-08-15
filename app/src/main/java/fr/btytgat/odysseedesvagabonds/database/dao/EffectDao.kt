package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.Effect

@Dao
interface EffectDao {

    @Query("SELECT * FROM Effect")
    fun getAll(): List<Effect>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(effect: Effect)

    @Delete
    fun delete(effect: Effect)

    @Query("SELECT COUNT(*) FROM Effect")
    fun getRowCount(): Int

    @Query("SELECT * FROM ${Effect.TABLE_NAME} WHERE uuid = :id")
    fun getEffectById(id: String): Effect
}