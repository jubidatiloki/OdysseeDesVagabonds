package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.*


@Entity(
    tableName = "voie",
    foreignKeys = [
        ForeignKey(
            entity = Info::class,
            parentColumns = arrayOf("id"),
            childColumns = arrayOf("id_info")
        ),
        ForeignKey(
            entity = Classe::class,
            parentColumns = arrayOf("id"),
            childColumns = arrayOf("id_classe"),
            onDelete = ForeignKey.CASCADE
        ),
    ]
)
data class Voie(
    @PrimaryKey(autoGenerate = true) var id: Long?,
    @ColumnInfo(
        index = true,
        name = "id_info") var idInfo: Long?,
    @ColumnInfo(
        index = true,
        name = "id_classe") var idCLasse: Long?,
    @Ignore
    var rangs: List<Rang> = emptyList(),
    @Ignore
    var info: Info? = null,
) {

    constructor(): this(null, null, null)


    companion object{

        fun populateOneVoie(idInfo: Long?, idCLasse: Long?): Voie{
            return Voie(null, idInfo, idCLasse)
        }
    }
}