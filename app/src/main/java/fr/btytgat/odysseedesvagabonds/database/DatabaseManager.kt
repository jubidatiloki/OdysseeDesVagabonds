package fr.btytgat.odysseedesvagabonds.database

import android.content.Context
import fr.btytgat.odysseedesvagabonds.database.entities.*

class DatabaseManager(private val context: Context, private val db: mDatabase) {


    fun getRaceWitHDetails(uuid: String): Race {

        val race = db.raceDao().getRaceById(uuid)

        race.apply {
            _info = db.infoDao().getInfoById(info)
            _path = getPathWithDetails(path)
            _statChange = statsChange?.let { db.statChangeGroupDao().getStatChangeGroupById(it) }
            _specialStatChange = specialStatChange?.map { it?.let { it1 -> db.statChangeGroupDao().getStatChangeGroupById(it1) }}
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
        talent.apply {
            _buffs = buffs?.map { getBuffWithDetails(it) }
            _attack = attack?.let { getAttackWithDetails(it) }
            _effects = effects?.map { getEffectWithDetails(it) }
        }
        return talent
    }


    fun getBuffWithDetails(uuid: String): Buff {

        val buff = db.buffDao().getBuffById(uuid)

        buff.apply {
            _statBound = statBound?.let { getStatWithDetails(it) }
            _facultyBound = facultyBound?.let { getFacultyWithDetails(it) }
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

    fun getFacultyWithDetails(uuid: String): Faculty {

        val faculty = db.facultyDao().getFacultyById(uuid)
        faculty.apply {
            _info = db.infoDao().getInfoById(info)
            _statBound = statBound?.let { getStatWithDetails(it) }
            _subFaculties = subFaculties?.map { getFacultyWithDetails(it)}
        }
        return faculty
    }


    fun getResistanceTypeWithDetails(uuid: String): ResistanceType {

        val resistanceType = db.resistanceTypeDao().getResistanceTypeById(uuid)
        resistanceType.apply {
            _statBound = statBound?.let { getStatWithDetails(it) }
            _subResistanceTypes = subResistanceTypes?.map { getResistanceTypeWithDetails(it) }
        }
        return resistanceType
    }

    fun getDamageTypeWithDetails(uuid: String): DamageType {

        val damageType = db.damageTypeDao().getDamageTypeById(uuid)
        damageType.apply {
            _resistanceType = resistanceType?.let { getResistanceTypeWithDetails(it) }
            _subResistanceTypes = subDamageTypes?.map { getResistanceTypeWithDetails(it) }

        }
        return damageType
    }





    fun getDamageWithDetails(uuid: String): Damage {

        val damage = db.damageDao().getDamageById(uuid)
        damage.apply {
            _damageType = getDamageTypeWithDetails(damageType)
            _dice = db.diceDao().getDiceById(dice)
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

}