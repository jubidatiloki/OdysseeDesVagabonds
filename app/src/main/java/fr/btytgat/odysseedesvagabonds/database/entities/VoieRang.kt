package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Embedded
import androidx.room.Relation


data class VoieRang(
    @Embedded
    val voie: Voie,
    @Relation(
        parentColumn = "id",
        entityColumn = "voie"
    )
    val rangs: List<Rang>
) {
}