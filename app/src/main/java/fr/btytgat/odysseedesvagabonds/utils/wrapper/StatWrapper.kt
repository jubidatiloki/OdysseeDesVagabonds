package fr.btytgat.odysseedesvagabonds.utils.wrapper

import fr.btytgat.odysseedesvagabonds.database.entities.Stat

data class StatWrapper(
    var uuid: String? = "",
    var name: String? = "",
    var shortName: String? = "",
    var isInnate: Boolean? = false,
    var haveMod: Boolean? = false,    // pour pouvoir ensuite faire un getter du mod (pour les stats qui en ont un uniquement)
    var description: String? = "",
    var subDescription: String? = ""
) {
    companion object{
        const val keyUuid = "uuid"
        const val keyName = "name"
        const val keyShortName = "shortName"
        const val keyIsInnate = "innate"
        const val keyHaveMod = "haveMod"
        const val keyDescription = "description"
        const val keySubDescription = "subDescription"

        fun toEntity(statWrapper: StatWrapper): Stat {
            return Stat(
                uuid = statWrapper.uuid ?: "",
                name = statWrapper.name ?: "",
                shortName = statWrapper.shortName ?: "",
                isInnate = statWrapper.isInnate ?: false,
                haveMod = statWrapper.haveMod ?: false,
                description = statWrapper.description ?: "",
                subDescription = statWrapper.subDescription ?:""
            )
        }
    }
}