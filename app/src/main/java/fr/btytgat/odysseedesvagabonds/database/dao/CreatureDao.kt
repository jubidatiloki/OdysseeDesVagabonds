package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.Creature

@Dao
interface CreatureDao {

    @Query("SELECT * FROM creature ORDER BY lastUpdate ASC")
    fun getAllCreatures(): List<Creature>

    @Query("SELECT * FROM creature WHERE id = :id")
    fun getCreatureById(id: Long): Creature




    @Insert(    onConflict = OnConflictStrategy.REPLACE)
    fun insertAllCreature(vararg creatures: Creature)

    @Insert
    fun insertCreature(creature: Creature)



    @Delete
    fun deleteCreature(creature: Creature)
}