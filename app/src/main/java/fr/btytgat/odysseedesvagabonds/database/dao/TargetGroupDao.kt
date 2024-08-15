package fr.btytgat.odysseedesvagabonds.database.dao

import androidx.room.*
import fr.btytgat.odysseedesvagabonds.database.entities.TargetGroup

@Dao
interface TargetGroupDao {

    @Query("SELECT * FROM TargetGroup")
    fun getAll(): List<TargetGroup>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(targetGroup: TargetGroup)

    @Delete
    fun delete(targetGroup: TargetGroup)

    @Query("SELECT COUNT(*) FROM TargetGroup")
    fun getRowCount(): Int

    @Query("SELECT * FROM ${TargetGroup.TABLE_NAME} WHERE uuid = :id")
    fun getTargetGroupById(id: String): TargetGroup

}