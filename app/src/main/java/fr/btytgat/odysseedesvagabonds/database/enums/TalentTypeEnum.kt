package fr.btytgat.odysseedesvagabonds.database.enums

import fr.btytgat.odysseedesvagabonds.R

enum class TalentTypeEnum(val title: String, val description: String, val subDescription: String, val icon: Int) {
    PASSIF("Passif", "actif en permanence", "sauf mention contraire", R.drawable.ic_infinity),
    ATTACK("Attaque", "TODO","TODO", R.drawable.ic_sword),
    SPELL("Sort", "TODO", "TODO", R.drawable.ic_staff),
    COMPANION("Compagnon", "TODO", "TODO", R.drawable.ic_animal_track),
    UTILITY("Utilitaire", "TODO", "TODO", R.drawable.ic_bagpack),
    REINFORCEMENT("Renforcement", "amélioration d'un autre talent", "", R.drawable.ic_upgrade),
    DEBUFF("Debuff", "TODO", "TODO", R.drawable.ic_weakness)
}