package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.EffectType

@Dao
interface EffectTypeDao {

    @Query("SELECT * FROM EffectType")
    fun getAll(): List<EffectType>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(effectType: EffectType)

    @Delete
    fun delete(effectType: EffectType)

    @Query("SELECT COUNT(*) FROM EffectType")
    fun getRowCount(): Int

    @Query("SELECT * FROM ${EffectType.TABLE_NAME} WHERE uuid = :id")
    fun getEffectTypeById(id: String): EffectType
}