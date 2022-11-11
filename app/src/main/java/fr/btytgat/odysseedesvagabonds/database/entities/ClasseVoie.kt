package fr.btytgat.odysseedesvagabonds.database.entities


data class ClasseVoie(
//    @Embedded
//    val classe: Classe,
//    @Relation(
//        parentColumn = "id",
//        entityColumn = "classe"
//    )
    val voies: List<Voie>
) {
}