package fr.btytgat.odysseedesvagabonds.database.wrapper

import com.google.firebase.database.DataSnapshot
import java.util.*

data class TalentWrapper(
    var uuid: String = UUID.randomUUID().toString(),
    var info: InfoWrapper?,
    var type: String,                           // talentType
    var isMagic: Boolean,                       // true = dépense du mana, false = aucun cout
    var complexity: Long?,                       // 0 = gratuit, 1 = action de mouvement, 2 = simple, 3 = complexe
    var manaCost: Boolean? = false,             // true = coute du mana à lancer (cf rang), false = ne coute pas de mana,  null = cf cout mana variable / pas lié au rang
    var manaCostOverTime: Boolean = false,       // true = coute du mana, false = ne coute pas de mana
    var isTimeLimited: String? = null,           // (1f/jour, 3f/combat, ...)
    var isChoice: Boolean = false,               // true = choix parmi les talents du talentGroup avec la meme category
    var category: String? = null,                // permet de regrouper les choix
    var statChangeGroup: StatChangeGroupWrapper? = null,
    var attack: AttackWrapper? = null,
    var effects: List<EffectWrapper> = emptyList(),
    var maxTaken: Long = 1,
) {
    companion object {

        fun getWrapperFromDS(ds: DataSnapshot): TalentWrapper {
            return TalentWrapper(
                uuid = ds.child("uuid").value as String,
                info = InfoWrapper.getWrapperFromDS(ds.child("info")),
                type = ds.child("type").value as String,
                isMagic = ds.child("magic").value as Boolean,
                complexity = ds.child("complexity").value as Long?,
                manaCost = ds.child("manaCost").value as Boolean?,
                manaCostOverTime = ds.child("manaCostOverTime").value as Boolean,
                isTimeLimited = ds.child("timeLimited").value as String?,
                isChoice = ds.child("choice").value as Boolean,
                category = ds.child("category").value as String?,
                statChangeGroup = ds.child("statChangeGroup").value?.let { StatChangeGroupWrapper.getWrapperFromDS(ds.child("statChangeGroup")) },
                attack = ds.child("attack").value?.let { AttackWrapper.getWrapperFromDS(ds.child("attack")) },
                effects = ds.child("effects").children.map { EffectWrapper.getWrapperFromDS(it) },
                maxTaken = ds.child("maxTaken").value as Long,
            )
        }
    }
}