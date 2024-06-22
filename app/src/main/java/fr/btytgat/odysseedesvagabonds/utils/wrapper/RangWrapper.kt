package fr.btytgat.odysseedesvagabonds.utils.wrapper

import fr.btytgat.odysseedesvagabonds.database.entities.Rang

data class RangWrapper (
    var uuid: String?,
    var name: String?,
    var rangNumber: Int?,
    var description: String?,
) {
    companion object {
        const val keyUuid = "uuid"
        const val keyName = "name"
        const val keyRangNumber = "rangNumber"
        const val keyDescription = "description"

        fun toEntity(rangWrapper: RangWrapper): Rang {
            return Rang(
                uuid = rangWrapper.uuid ?: "",
                name = rangWrapper.name ?: "",
                rangNumber = rangWrapper.rangNumber ?: 0,
                description = rangWrapper.description ?: ""
            )
        }
    }
}