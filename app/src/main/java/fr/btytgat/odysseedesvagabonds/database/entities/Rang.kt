package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.*


@Entity(
    tableName = "rang",
    foreignKeys = [
        ForeignKey(
            entity = Info::class,
            parentColumns = arrayOf("id"),
            childColumns = arrayOf("id_info")
        ),
        ForeignKey(
            entity = Voie::class,
            parentColumns = arrayOf("id"),
            childColumns = arrayOf("id_voie"),
            onDelete = ForeignKey.CASCADE
        ),
//        ForeignKey(
//            entity = Competence::class,
//            parentColumns = arrayOf("id"),
//            childColumns = arrayOf("competence"),
//            onDelete = ForeignKey.CASCADE
//        ),
    ]
)
data class Rang(
    @PrimaryKey(autoGenerate = true) var id: Long?,
    @ColumnInfo(
        index = true,
        name = "id_info"
    ) var idInfo: Long?,
    @ColumnInfo(
        index = true,
        name = "id_voie"
    ) var idVoie: Long?,
    @Ignore
    var info: Info? = null,
//    @ColumnInfo(
//        index = true,
//        name = "id_competence"
//    ) val idCompetence: Int?,
) {

    constructor(): this(null, null, null)


    companion object{

        fun populateOneRang(idInfo: Long?, idVoie: Long?): Rang{
            return Rang(null, idInfo, idVoie)
        }
    }
}