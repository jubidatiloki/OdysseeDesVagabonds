package fr.btytgat.odysseedesvagabonds.database.enums

import fr.btytgat.odysseedesvagabonds.R

enum class RaceTagEnum(name: String, color: Int) {
    PHYSICAL("physique", R.color.lightRed),
    BALANCED("équilibré", R.color.lightGreen),
    MAGIC("magique", R.color.lightBlue)
}