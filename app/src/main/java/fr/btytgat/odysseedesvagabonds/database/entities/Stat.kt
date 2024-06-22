package fr.btytgat.odysseedesvagabonds.database.entities


data class Stat(
    var uuid: String,
    var name: String,
    var shortName: String,
    var isInnate: Boolean,  // true si stat d'une creature, false si c'est un buff externe (equipement, potion, temporaire)
    var haveMod: Boolean,    // pour pouvoir ensuite faire un getter du mod (pour les stats qui en ont un uniquement)
    var description: String = "",
    var subDescription: String = ""

)