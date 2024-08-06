package fr.btytgat.odysseedesvagabonds.database.enums

import fr.btytgat.odysseedesvagabonds.R

enum class ClasseTagEnum(name: String, color: Int) {
    PHYSICAL("physique", R.color.lightRed),
    MAGIC("magique", R.color.lightBlue),
    SKILL("compétences", R.color.lightGrey),
    SPELL("sorts", R.color.lightGrey),
    UTILITY("utilitaire", R.color.lightGreen),
}