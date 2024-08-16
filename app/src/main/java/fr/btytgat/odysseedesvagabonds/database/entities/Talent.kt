package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Ignore
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
    @PrimaryKey var uuid: String = UUID.randomUUID().toString(),
    var info: String?,
    var talentGroupUuid: String,
    var type: String,                           // talentType
    var magic: Boolean,                       // true = dépense du mana, false = aucun cout
    var complexity: Long?,                       // 0 = gratuit, 1 = simple, 2 = complexe, 3 = action de mouvement, null = osef
    var manaCost: Boolean? = false,             // true = coute du mana à lancer (cf rang), false = ne coute pas de mana,  null = cf cout mana variable / pas lié au rang
    var manaCostOverTime: Boolean = false,       // true = coute du mana, false = ne coute pas de mana
    var timeLimited: String? = null,           // (1f/jour, 3f/combat, ...)
    var choice: Boolean = false,               // true = choix parmi les talents du talentGroup avec la meme category
    var category: String? = null,                // permet de regrouper les choix
    var buffs: List<String> = emptyList(),
    var attack: String? = null,
    var effects: List<String>? = null,
    var maxTaken: Long = 1,
    @Ignore
    var _info: Info? = null,
    @Ignore
    var _buffs: List<Buff> = emptyList(),
    @Ignore
    var _attack: Attack? = null,
    @Ignore
    var _effects: List<Effect> = emptyList(),
) : BaseEntity() {

    constructor():this(info = "", talentGroupUuid = "", type = "", magic = false, complexity = null, manaCost = null, manaCostOverTime = false, timeLimited = null, choice = false)

    companion object {
        const val TABLE_NAME = "Talent"

        fun getEntityFromWrapper(wrapper: TalentWrapper, talentGroupUuid: String): Talent {
            var buffList = emptyList<String>()
            wrapper.buffs.map {
                if(it.uuid.isNotEmpty()) {
                    buffList = buffList.plus(it.uuid)
                }
            }
            return Talent(
                uuid = wrapper.uuid,
                info = wrapper.info?.uuid,
                talentGroupUuid = talentGroupUuid,
                type = wrapper.type,
                magic = wrapper.isMagic,
                complexity = wrapper.complexity,
                manaCost = wrapper.manaCost,
                manaCostOverTime = wrapper.manaCostOverTime,
                timeLimited = wrapper.isTimeLimited,
                choice = wrapper.isChoice,
                category = wrapper.category,
                buffs = buffList,
                attack = wrapper.attack?.uuid,
                effects = wrapper.effects.map { it.uuid },
                maxTaken = wrapper.maxTaken
            )
        }

    }
}