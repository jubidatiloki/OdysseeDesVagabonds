package fr.btytgat.odysseedesvagabonds.database.enums

import fr.btytgat.odysseedesvagabonds.R

enum class RaceTagEnum(label: String, color: Int) {
    PHYSICAL("physique", R.color.lightRed),
    BALANCED("équilibré", R.color.lightGreen),
    MAGIC("magique", R.color.lightBlue);


    val label: String = label
    val color: Int = color
}