package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.BaseEntity
import fr.btytgat.odysseedesvagabonds.database.wrapper.TalentWrapper
import java.util.*

@Entity(
    tableName = Talent.TABLE_NAME,
    foreignKeys = [
        (ForeignKey(
            entity = TalentGroup::class,
            childColumns = [("talentGroupUuid")],
            parentColumns = [("uuid")],
            onDelete = ForeignKey.CASCADE,
            onUpdate = ForeignKey.CASCADE
        )
                )]
)
data class Talent(
    @PrimaryKey(autoGenerate = false) var uuid: String = UUID.randomUUID().toString(),
    var info: String?,
    var talentGroupUuid: String,
    var type: String,                           // talentType
    var isMagic: Boolean,                       // true = dépense du mana, false = aucun cout
    var complexity: Long?,                       // 0 = gratuit, 1 = simple, 2 = complexe, 3 = action de mouvement, null = osef
    var manaCost: Boolean? = false,             // true = coute du mana à lancer (cf rang), false = ne coute pas de mana,  null = cf cout mana variable / pas lié au rang
    var manaCostOverTime: Boolean = false,       // true = coute du mana, false = ne coute pas de mana
    var isTimeLimited: String? = null,           // (1f/jour, 3f/combat, ...)
    var isChoice: Boolean = false,               // true = choix parmi les talents du talentGroup avec la meme category
    var category: String? = null,                // permet de regrouper les choix
    var maxTaken: Long = 1
) : BaseEntity() {
    companion object {
        const val TABLE_NAME = "Talent"

        fun getEntityFromWrapper(wrapper: TalentWrapper, talentGroupUuid: String): Talent {
            return Talent(
                uuid = wrapper.uuid,
                info = wrapper.info?.uuid,
                talentGroupUuid = talentGroupUuid,
                type = wrapper.type,
                isMagic = wrapper.isMagic,
                complexity = wrapper.complexity,
                manaCost = wrapper.manaCost,
                manaCostOverTime = wrapper.manaCostOverTime,
                isTimeLimited = wrapper.isTimeLimited,
                isChoice = wrapper.isChoice,
                category = wrapper.category,
                maxTaken = wrapper.maxTaken
            )
        }

    }
}