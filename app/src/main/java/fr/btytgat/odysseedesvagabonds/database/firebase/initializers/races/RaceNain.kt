package fr.btytgat.odysseedesvagabonds.database.firebase.initializers.races

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.enums.PathOriginEnum
import fr.btytgat.odysseedesvagabonds.database.enums.RaceTagEnum
import fr.btytgat.odysseedesvagabonds.database.enums.TalentTypeEnum
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils
import fr.btytgat.odysseedesvagabonds.database.firebase.initializers.DamageTypeInitializer
import fr.btytgat.odysseedesvagabonds.database.firebase.initializers.DiceInitializer
import fr.btytgat.odysseedesvagabonds.database.firebase.initializers.StatChangeInitializer
import fr.btytgat.odysseedesvagabonds.database.firebase.initializers.StatInitializer
import fr.btytgat.odysseedesvagabonds.database.wrapper.*
import java.util.*

class RaceNain {

    companion object{
        fun init(database: DatabaseReference) {
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Outils de nain",
                    "",
                    "Maitrise de la hache et du marteau, si c'était déjà le cas, donne +1 AdC et +1 DMG avec ces armes à la place",
                    "",
                    ""
                ),
                TalentTypeEnum.PASSIF.name,
                false,
                null,
                buffs = StatChangeInitializer.buffNain1()
            )

            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "1 - Outils de nain",
                1,
                listOf(talent1),
                types = listOf(TalentTypeEnum.PASSIF.name)
            ).apply {
                Log.i("DATABASE", "create talentGroup - $uuid")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(uuid).setValue(this)
            }

            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Ivresse naine",
                    "",
                    "bonus de +5 au tests de CON et peut refaire un jet en cas d'échec (hors échec critique) à un test de CON liés aux breuvages (poison compris)",
                    "\"ca tient chaud dans les profondeurs de la terre\"",
                    ""
                ),
                TalentTypeEnum.PASSIF.name,
                false,
                null,
                buffs = StatChangeInitializer.buffNain2()
            )
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "2 - Ivresse naine",
                2,
                listOf(talent2),
                types = listOf(TalentTypeEnum.PASSIF.name)
            ).apply {
                Log.i("DATABASE", "create talentGroup - $uuid")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(uuid).setValue(this)
            }



            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Tête de fer",
                    "",
                    "donne une attaque gratuite de coup de tête une fois par tour, 1D6 + CON DMG",
                    "",
                    ""
                ),
                TalentTypeEnum.ATTACK.name,
                false,
                0,
                attack = AttackWrapper(
                    UUID.randomUUID().toString(),
                    DamageWrapper(
                        UUID.randomUUID().toString(),
                        0,
                        1,
                        DiceInitializer.dice6,
                        DamageTypeInitializer.dmgPhyContondant,
                        StatInitializer.getStatCon()
                    )
                )
            )
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "3 - Tête de fer",
                3,
                listOf(talent3),
                types = listOf(TalentTypeEnum.ATTACK.name)
            ).apply {
                Log.i("DATABASE", "create talentGroup - $uuid")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(uuid).setValue(this)
            }


            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Acolyte des montagnes",
                    "",
                    "dompte un bouquetin pouvant lui servir de monture (pas de compétence particulier pour le combat et panique si n'a pas la voie du cavalier de chevalier), mais a un bonus de +10 d'escalade avec celui-ci et galope à la même vitesse qu'un cheval",
                    "",
                    ""
                ),
                TalentTypeEnum.COMPANION.name,
                false,
                null
            )
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "4 - Acolyte des montagnes",
                4,
                listOf(talent4),
                types = listOf(
                    TalentTypeEnum.COMPANION.name,
                    TalentTypeEnum.UTILITY.name
                )
            ).apply{
                Log.i("DATABASE", "create talentGroup - $uuid")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(uuid).setValue(this)
            }

            val categoryTalent5 = "categoryTalent5"
            val talent5_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Ténacité",
                    description = "Le nain est devenu au fil du temps aussi résistant que la roche"
                ),
                TalentTypeEnum.PASSIF.name,
                false,
                null,
                buffs = StatChangeInitializer.buffNain5_1()
            )
            val talent5_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Ténacité",
                    description = "Le nain est devenu au fil du temps aussi résistant que la roche"
                ),
                TalentTypeEnum.PASSIF.name,
                false,
                null,
                isChoice = true,
                category = categoryTalent5,
                buffs = StatChangeInitializer.buffNain5_2()
            )
            val talent5_3 = TalentWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Ténacité",
                    description = "Le nain est devenu au fil du temps aussi résistant que la roche"
                ),
                TalentTypeEnum.PASSIF.name,
                false,
                null,
                isChoice = true,
                category = categoryTalent5,
                buffs = StatChangeInitializer.buffNain5_3()
            )
            val talent5_4 = TalentWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Ténacité",
                    description = "Le nain est devenu au fil du temps aussi résistant que la roche"
                ),
                TalentTypeEnum.PASSIF.name,
                false,
                null,
                isChoice = true,
                category = categoryTalent5,
                buffs = StatChangeInitializer.buffNain5_4()
            )
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "5 - Ténacité",
                5,
                listOf(talent5_1, talent5_2, talent5_3, talent5_4),
                types = listOf(TalentTypeEnum.PASSIF.name)
            ).apply{
                Log.i("DATABASE", "create talentGroup - ${uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(uuid).setValue(this)
            }


            val raceUuid = UUID.randomUUID().toString();
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Voie du nain",
                ),
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.RACE.name,
                raceUuid
            ).apply {
                Log.i("DATABASE", "create path - $uuid")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(uuid).setValue(this)
            }

            val buff1 = StatChangeWrapper(
                UUID.randomUUID().toString(),
                true,
                modifier = 2,
                statBound = StatInitializer.getStatCon()
            ).apply {
                Log.i("DATABASE", "create path - $uuid")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STAT_CHANGES)
                    .child(uuid).setValue(this)
            }
            val buff2 = StatChangeWrapper(
                UUID.randomUUID().toString(),
                false,
                modifier = -2,
                statBound = StatInitializer.getStatDex()
            ).apply {
                Log.i("DATABASE", "create path - $uuid")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STAT_CHANGES)
                    .child(uuid).setValue(this)
            }

            val statChangeGroup = StatChangeGroupWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Attribut de race - Nain"
                ),
                listOf(
                    buff1,
                    buff2
                )
            ).apply {
                Log.i("DATABASE", "create path - $uuid")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STAT_CHANGE_GROUPS)
                    .child(uuid).setValue(this)
            }

            RaceWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Nain",
                    description = "se reconnait à  leurs petites tailles, leurs barbes, leur pioches, leurs air raleurs et désagréable, leur addiction pour l'alcool, .... ah et ils aiment pas les elfes aussi"
                ),
                8,
                4,
                path,
                statChangeGroup,
                listOf(RaceTagEnum.PHYSICAL.name),
            ).apply {
                Log.i("DATABASE", "create race - $uuid")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RACES)
                    .child(uuid).setValue(this)
            }

        }
    }
}