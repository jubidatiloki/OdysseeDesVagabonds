package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Embedded
import androidx.room.Entity
import androidx.room.Relation

@Entity
data class RaceStat(
    @Embedded
    val race: Race,
    @Relation(
        parentColumn = "id",
        entityColumn = "race"
    )
    val statsModifier: List<Stat>,
) {
}