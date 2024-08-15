package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.Buff

@Dao
interface BuffDao {

    @Query("SELECT * FROM Buff")
    fun getAll(): List<Buff>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(buff: Buff)

    @Delete
    fun delete(buff: Buff)

    @Query("SELECT COUNT(*) FROM Buff")
    fun getRowCount(): Int

    @Query("SELECT * FROM ${Buff.TABLE_NAME} WHERE uuid = :id")
    fun getBuffById(id: String): Buff
}