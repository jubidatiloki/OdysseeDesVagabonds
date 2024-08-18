package fr.btytgat.odysseedesvagabonds.database.firebase.initializers.races

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.enums.PathOriginEnum
import fr.btytgat.odysseedesvagabonds.database.enums.RaceTagEnum
import fr.btytgat.odysseedesvagabonds.database.enums.TalentTypeEnum
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils
import fr.btytgat.odysseedesvagabonds.database.firebase.initializers.StatChangeInitializer
import fr.btytgat.odysseedesvagabonds.database.wrapper.*
import java.util.*

class RaceHautElfe {

    companion object{
        fun init(database: DatabaseReference) {
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Sagesse ancestrale",
                    description = "La longévité des haut-elfes fait qu'ils ont acquis des connaissances dans de nombreux domaines liés à l'histoire des races et du continents",
                ),
                TalentTypeEnum.PASSIF.name,
                false,
                null,
                statChangeGroup = StatChangeInitializer.statChangeGroupHautElfe1
            )

            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "1 - Sagesse ancestrale",
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
                    "Affinité magique",
                    "",
                    "Possède une certaine sensibilité à la magie et aux créatures magiques",
                ),
                TalentTypeEnum.PASSIF.name,
                false,
                null,
                statChangeGroup = StatChangeInitializer.statChangeGroupHautElfe2
            )
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "2 - Affinité magique",
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
                    "Puit d'arcane",
                    description = "une fois par jour, puise dans son être intérieur l'énergie dont il aurait besoin pour lancer des sorts, perd 1d10 PV, pour regagner RANG d6 mana (ne peut pas dépasser son montant de mana max à moins d'avoir le dépassement de mana  (magicien, voie magie universelle, rang 3)",
                ),
                TalentTypeEnum.SPELL.name,
                true,
                1,
            )
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "3 - Puit d'arcane",
                3,
                listOf(talent3),
                types = listOf(TalentTypeEnum.SPELL.name, TalentTypeEnum.UTILITY.name)
            ).apply {
                Log.i("DATABASE", "create talentGroup - $uuid")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(uuid).setValue(this)
            }


            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Visage impensable",
                    description = "une fois par jour, l'elfe peut prendre les traits d'un être monstrueux et dangereux qui a disparus des millénaires plus tôt (cf gandalf chez bilbo), lui donne +10 SOC, +10 CHA pour faire fuir ou convaincre les gens autour de lui",
                ),
                TalentTypeEnum.SPELL.name,
                true,
                1
            )
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "4 - Visage impensable",
                4,
                listOf(talent4),
                types = listOf(
                    TalentTypeEnum.SPELL.name,
                )
            ).apply{
                Log.i("DATABASE", "create talentGroup - $uuid")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(uuid).setValue(this)
            }

            val talent5_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Vitalité elfique",
                    description = "Le haut-elfe est devenu suffisamment ancien pour prendre pleine conscience de ses capacités et de se que sa longévité lui permet.\naugmente son dé de vie au dé 6 (retro actif)"
                ),
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null,
            )
            val talent5_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Vitalité elfique",
                    description = ""
                ),
                TalentTypeEnum.PASSIF.name,
                false,
                null,
                statChangeGroup = StatChangeInitializer.statChangeGroupHautElfe5
            )

            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "5 - Vitalité elfique",
                5,
                listOf(talent5_1, talent5_2),
                types = listOf(
                    TalentTypeEnum.REINFORCEMENT.name,
                    TalentTypeEnum.PASSIF.name
                )
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
                    "Voie du haut-elfe",
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


            RaceWrapper(
                UUID.randomUUID().toString(),
                info = InfoWrapper(
                    UUID.randomUUID().toString(),
                    "Haut-elfe",
                    description = "aime la magie, être hautain et desteste les nains"
                ),
                4,
                8,
                path,
                StatChangeInitializer.statChangeGroupHautElfe,
                listOf(RaceTagEnum.MAGIC.name),
            ).apply {
                Log.i("DATABASE", "create race - $uuid")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RACES)
                    .child(uuid).setValue(this)
            }

        }
    }
}