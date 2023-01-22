package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.*

@Entity(
    tableName = "classe",
    foreignKeys = [
        ForeignKey(
        entity = Info::class,
        parentColumns = arrayOf("id"),
        childColumns = arrayOf("id_info")
    )
    ]
)
data class Classe(
    @PrimaryKey(autoGenerate = true) var id: Long?,
    @ColumnInfo(
        index = true,
        name = "id_info") var idInfo: Long?,
    var healthDiceModifier: Int,      // -1: decreased, 0: no change, 1: increased
    var manaDiceModifier: Int,        // -1: decreased, 0: no change, 1: increased
    @Ignore
    var voies: List<Voie> = emptyList(),
    @Ignore
    var info: Info? = null,
) {

    constructor(): this(null, null, 0, 0)

    companion object{

        fun populateOneClasse(idInfo: Long?, healthDiceModifier: Int, manaDiceModifier: Int):Classe{
            return Classe(null, idInfo, healthDiceModifier, manaDiceModifier)
        }
    }
}