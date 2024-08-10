package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.DamageType

@Dao
interface DamageTypeDao {

    @Query("SELECT * FROM DamageType")
    fun getAll(): List<DamageType>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(damageType: DamageType)

    @Delete
    fun delete(damageType: DamageType)

    @Query("SELECT COUNT(*) FROM DamageType")
    fun getRowCount(): Int

}