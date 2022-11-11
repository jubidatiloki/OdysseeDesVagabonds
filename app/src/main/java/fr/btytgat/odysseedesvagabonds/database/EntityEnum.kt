package fr.btytgat.odysseedesvagabonds.database

import fr.btytgat.odysseedesvagabonds.R

enum class EntityEnum(val nameRes: Int, val descriptionRes: Int) {
    RACE(0,0),
    CLASSE(0, 0),
    VOIE(0, 0),
    RANG(0, 0),
    COMPETENCE(0, 0),
    CREATURE(R.string.entity_name_creature, R.string.entity_description_creature),
    BUILDING(R.string.entity_name_building, R.string.entity_description_building),
    ARMOR(R.string.entity_name_armor, R.string.entity_description_armor),
    WEAPON(R.string.entity_name_weapon, R.string.entity_description_weapon),
    CONSUMABLE(R.string.entity_name_consumable, R.string.entity_description_consumable),
    OBJECT(R.string.entity_name_object, R.string.entity_description_object)
}