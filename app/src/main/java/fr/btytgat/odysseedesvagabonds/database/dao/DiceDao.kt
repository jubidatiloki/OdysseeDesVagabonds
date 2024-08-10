package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.Dice

@Dao
interface DiceDao {

    @Query("SELECT * FROM Dice")
    fun getAll(): List<Dice>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(dice: Dice)

    @Delete
    fun delete(dice: Dice)

    @Query("SELECT COUNT(*) FROM Dice")
    fun getRowCount(): Int
    
}