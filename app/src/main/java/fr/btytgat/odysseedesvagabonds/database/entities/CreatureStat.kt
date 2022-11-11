package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Embedded
import androidx.room.Entity
import androidx.room.Relation


@Entity
data class StatsCreature(
    @Embedded
    val creature: Creature,
    @Relation(
        parentColumn = "id",
        entityColumn = "creature"
    )
    val stats: List<Stat>,
){

}