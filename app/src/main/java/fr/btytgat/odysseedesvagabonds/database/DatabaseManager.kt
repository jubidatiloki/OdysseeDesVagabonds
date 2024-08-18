package fr.btytgat.odysseedesvagabonds.database

import android.content.Context
import fr.btytgat.odysseedesvagabonds.database.entities.*

class DatabaseManager(private val context: Context, private val db: MyDatabase) {


    fun getRaceWitHDetails(uuid: String): Race {

        val race = db.raceDao().getRaceById(uuid)
        var specialStatChangeGroup = emptyList<StatChangeGroup>()
        race.specialStatChange?.forEach {
            if(it?.isNotEmpty() == true){
                specialStatChangeGroup = specialStatChangeGroup.plus(getStatChangeGroupWithDetails(it))
            }
        }

        race.apply {
            _info = db.infoDao().getInfoById(info)
            _path = getPathWithDetails(path)
            _statChange = statsChange?.let { getStatChangeGroupWithDetails(it) }
            _specialStatChange = specialStatChangeGroup
        }
        return race
    }

    fun getPathWithDetails(uuid: String): Path {

        val path = db.pathDao().getPathById(uuid)
        val talentGroups = db.talentGroupDao().getTalentGroupsByPath(uuid)
        path.apply {
            _info = db.infoDao().getInfoById(info)
            _talentGroups = talentGroups.map { getTalentGroupWithDetails(it.uuid) }

        }
        return path
    }



    fun getTalentGroupWithDetails(uuid: String): TalentGroup {

        val talentGroup = db.talentGroupDao().getTalentGroupById(uuid)
        val talents = db.talentDao().getTalentsByGroup(uuid)
        talentGroup.apply {
            _talents = talents.map { getTalentWithDetails(it.uuid) }
        }
        return talentGroup
    }

    fun getTalentWithDetails(uuid: String): Talent {

        val talent = db.talentDao().getTalentById(uuid)
        var effectList = emptyList<Effect>()
        talent.effects?.forEach {
            if(it.isNotEmpty()){
                effectList = effectList.plus(getEffectWithDetails(it))
            }
        }
        var buffList = emptyList<Buff>()
        talent.buffs.forEach {
            if(it.isNotEmpty()){
                buffList = buffList.plus(getBuffWithDetails(it))
            }
        }

        talent.apply {
            _info = info?.let { db.infoDao().getInfoById(it) }
            _buffs = buffList
            _attack = attack?.let { getAttackWithDetails(it) }
            _effects = effectList
        }
        return talent
    }


    fun getBuffWithDetails(uuid: String): Buff {

        val buff = db.buffDao().getBuffById(uuid)

        buff.apply {
            _statBound = statBound?.let { it?.let{getStatWithDetails(it) }}
            _facultyBound = facultyBound?.let { it?.let { getFacultyWithDetails(it)} }
        }
        return buff
    }

    fun getAttackWithDetails(uuid: String): Attack {

        val attack = db.attackDao().getAttackById(uuid)
        attack.apply {
            _info = info?.let { db.infoDao().getInfoById(it) }
            _damage = getDamageWithDetails(damage)
            _duration = duration?.let { db.durationDao().getDurationById(it) }

        }
        return attack
    }

    fun getStatWithDetails(uuid: String): Stat {

        val stat = db.statDao().getStatById(uuid)
        stat.apply {
            _info = db.infoDao().getInfoById(info)
        }
        return stat
    }

    fun getFacultyWithDetails(uuid: String): Faculty? {

        val faculty = db.facultyDao().getFacultyById(uuid)
        var list = emptyList<Faculty>()
        faculty?.subFaculties?.forEach {
            getFacultyWithDetails(it)?.let {
                list = list.plus(it)
            }
        }
        faculty?.apply {
            _info = db.infoDao().getInfoById(info)
            _statBound = statBound?.let { getStatWithDetails(it) }
            _subFaculties = list
        }
        return faculty
    }


    fun getResistanceTypeWithDetails(uuid: String): ResistanceType {

        val resistanceType = db.resistanceTypeDao().getResistanceTypeById(uuid)
        var subResList: List<ResistanceType> = emptyList()
        resistanceType.subResistanceTypes?.forEach {
            if(it.isNotEmpty()){
                subResList = subResList.plus(getResistanceTypeWithDetails(it))
            }
        }
        resistanceType.apply {
            _statBound = statBound?.let { getStatWithDetails(it) }
            _subResistanceTypes = subResList
        }
        return resistanceType
    }

    fun getDamageTypeWithDetails(uuid: String): DamageType {

        val damageType = db.damageTypeDao().getDamageTypeById(uuid)
        var subDmgList = emptyList<DamageType>()
        damageType.subDamageTypes?.map {
            if(it.isNotEmpty()) {
                subDmgList = subDmgList.plus(getDamageTypeWithDetails(it))
            }
        }
        var resType: ResistanceType? = null
        damageType.resistanceType?.let {
            if(it.isNotEmpty()){
                resType = getResistanceTypeWithDetails(it)
            }
        }
        damageType.apply {
            _info = db.infoDao().getInfoById(info)
            _resistanceType = resType
            _subDamageTypes = subDmgList

        }
        return damageType
    }





    fun getDamageWithDetails(uuid: String): Damage {

        val damage = db.damageDao().getDamageById(uuid)
        damage.apply {
            _damageType = getDamageTypeWithDetails(damageType)
            _dice = db.diceDao().getDiceById(dice)
            _statBound = statBound?.let { getStatWithDetails(it) }
        }
        return damage

    }


    fun getEffectWithDetails (uuid: String): Effect{

        val effect = db.effectDao().getEffectById(uuid)

        effect.apply {
            _effectType = getEffectTypeWithDetails(effectType)
            _targets = getTargetGroupWithDetails(targets)
            _duration = duration?.let { db.durationDao().getDurationById(it) }
        }
        return effect

    }


    fun getEffectTypeWithDetails(uuid: String): EffectType {
        val effectType = db.effectTypeDao().getEffectTypeById(uuid)
        effectType.apply {
            _info = db.infoDao().getInfoById(info)
            _buff = getBuffWithDetails(buff)
        }
        return effectType
    }

    fun getTargetGroupWithDetails (uuid: String): TargetGroup {

        val targetGroup = db.targetGroupDao().getTargetGroupById(uuid)
        targetGroup.apply {
            _dice = dice?.let { db.diceDao().getDiceById(it) }
        }
        return targetGroup
    }

    fun getStatChangeGroupWithDetails (uuid: String): StatChangeGroup {

        val statChangeGroup = db.statChangeGroupDao().getStatChangeGroupById(uuid)
        var buffList = emptyList<Buff>()
        statChangeGroup.buffs.forEach {
            if(it.isNotEmpty()){
                buffList = buffList.plus(getBuffWithDetails(it))
            }
        }
        statChangeGroup.apply {
            _info = db.infoDao().getInfoById(info)
            _buffs = buffList
        }
        return statChangeGroup
    }

}