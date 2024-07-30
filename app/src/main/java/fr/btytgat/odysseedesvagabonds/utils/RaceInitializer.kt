package fr.btytgat.odysseedesvagabonds.utils

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.entities.*
import java.util.*

class RaceInitializer {

    companion object {
        fun populateRaces(database: DatabaseReference) {
            nain(database)
            gnome(database)
            hautElfe(database)
            elfeSylvain(database)
        }

        fun nain(database: DatabaseReference) {
            val infoTalent1 = Info(
                UUID.randomUUID(),
                "Info - Outils de nain",
                "Maitrise de la hache et du marteau, si c'était déjà le cas, donne +1 AdC et +1 DMG avec ces armes à la place",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = Talent(
                UUID.randomUUID(),
                infoTalent1.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val talentGroup1 = TalentGroup(
                UUID.randomUUID(),
                "#1 - Outils de nain",
                1,
                listOf(talent1.uuid)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent2 = Info(
                UUID.randomUUID(),
                "Info - Ivresse naine",
                "bonus de +5 au tests de CON et peut refaire un jet en cas d'échec (hors échec critique) à un test de CON liés aux breuvages (poison compris)",
                "\"ca tient chaud dans les profondeurs de la terre\"",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = Talent(
                UUID.randomUUID(),
                infoTalent2.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroup(
                UUID.randomUUID(),
                "#2 - Ivresse naine",
                2,
                listOf(talent2.uuid)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent3 = Info(
                UUID.randomUUID(),
                "Info - Tête de fer",
                "donne une attaque gratuite de coup de tête une fois par tour, 1D6 + CON DMG",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = Talent(
                UUID.randomUUID(),
                infoTalent3.uuid,
                TalentType.ACTIF.name,
                false,
                0
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroup(
                UUID.randomUUID(),
                "#3 - Tête de fer",
                3,
                listOf(talent3.uuid)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4 = Info(
                UUID.randomUUID(),
                "Info - Acolyte des montagnes",
                "dompte un bouquetin pouvant lui servir de monture (pas de compétence particulier pour le combat et panique si n'a pas la voie du cavalier de chevalier), mais a un bonus de +10 d'escalade avec celui-ci et galope à la même vitesse qu'un cheval",
                "",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = Talent(
                UUID.randomUUID(),
                infoTalent4.uuid,
                TalentType.SUPPORT.name,
                false,
                null
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroup(
                UUID.randomUUID(),
                "#4 - Acolyte des montagnes",
                4,
                listOf(talent4.uuid)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5 = Info(
                UUID.randomUUID(),
                "Info - Ténacité",
                "+2 CON, +2 RD physique, +2 RD magique, +2 RD dans un élément (élément au choix)",
                "",
                ""
            )
            infoTalent5.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5 = Talent(
                UUID.randomUUID(),
                infoTalent5.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent5.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroup(
                UUID.randomUUID(),
                "#5 - Ténacité",
                5,
                listOf(talent5.uuid)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoPath = Info(
                UUID.randomUUID(),
                "Info - Voie du nain",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = Path(
                UUID.randomUUID(),
                "Voie du nain",
                listOf(
                    talentGroup1.uuid,
                    talentGroup2.uuid,
                    talentGroup3.uuid,
                    talentGroup4.uuid,
                    talentGroup5.uuid
                ),
                infoPath.uuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }


            var hashMapNain = java.util.HashMap<String, Int>()
            hashMapNain["STAT_CON"] = 2
            hashMapNain["STAT_DEX"] = -2
            val statChange = StatChangeGroup(
                "STAT_CHANGE_NAIN",
                "Stat raciale - nain",
                null,
                hashMapNain
            )
            statChange.let {
                Log.i("DATABASE", "create statChange - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_STAT_CHANGES)
                    .child(it.uuid.toString()).setValue(it)
            }


            val info = Info(
                UUID.randomUUID(),
                "Info - nain",
                "se reconnait à  leurs petites tailles, leurs barbes, leur pioches, leurs air raleurs et désagréable, leur addiction pour l'alcool, .... ah et ils aiment pas les elfes aussi",
                "",
                ""
            )

            info.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val race = Race(
                UUID.randomUUID(),
                "Nain",
                8,
                4,
                info.uuid,
                path.uuid,
                statChange.uuid,
                null
            )
            race.let {
                Log.i("DATABASE", "create race - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_RACES)
                    .child(it.uuid.toString()).setValue(it)
            }

        }

        fun gnome(database: DatabaseReference) {
            val infoTalent1_1 = Info(
                UUID.randomUUID(),
                "Info - Accessoire vraisemblablement indispensable",
                "Maitrise d'une arme ou d'un instrument de musique au choix, si choix d'une arme/instrument déjà maitrisé, donne +1 AdC/+1AdT et +1 DMG avec cette arme à la place (si instrument déja maitrisé, +2 pour un instrument)",
                "",
                ""
            )
            infoTalent1_1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1_1 = Talent(
                UUID.randomUUID(),
                infoTalent1_1.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent1_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent1_2 = Info(
                UUID.randomUUID(),
                "Info - Accessoire vraisemblablement indispensable",
                "possède un porte bonheur (petit objet) qui lui donne +1 CHAN tant qu'il l'a sur lui",
                "",
                ""
            )
            infoTalent1_2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1_2 = Talent(
                UUID.randomUUID(),
                infoTalent1_1.uuid,
                TalentType.SUPPORT.name,
                false,
                null
            )
            talent1_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val talentGroup1 = TalentGroup(
                UUID.randomUUID(),
                "#1 - Accessoire vraisemblablement indispensable",
                1,
                listOf(talent1_1.uuid, talent1_2.uuid)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = Info(
                UUID.randomUUID(),
                "Info - Discussion insensée mais soit disant pertinente",
                "une fois par combat, si la cible du gnome est humanoïde et comprend sa langue, le gnome peut raconter sa vie au milieu du combat afin de perturber sa cible, test de SOC du gnome en opposition à un test de CHA de la cible. Si réussite, -3 dans toutes les DEF de la cible jusqu'au prochain tour + perte de son action d'attaque pour ce tour si elle joue après le gnome",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = Talent(
                UUID.randomUUID(),
                infoTalent2.uuid,
                TalentType.ACTIF.name,
                false,
                2
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroup(
                UUID.randomUUID(),
                "#2 - Discussion insensée mais soit disant pertinente",
                2,
                listOf(talent2.uuid)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3 = Info(
                UUID.randomUUID(),
                "Info - Dans ma sacoche j'ai ...",
                "retrouve, trouve, achète (à avoir avec le MJ) une petite sacoche qui peut contenir jusqu'à 50kg d'objets en tout genre (non vivant uniquement, la nourriture ne se conserve pas mieux qu'en dehors) (le sac ne pèse rien pour le gnome)",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = Talent(
                UUID.randomUUID(),
                infoTalent3.uuid,
                TalentType.SUPPORT.name,
                false,
                null
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroup(
                UUID.randomUUID(),
                "#3 - Dans ma sacoche j'ai ...",
                3,
                listOf(talent3.uuid)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent4 = Info(
                UUID.randomUUID(),
                "Info - P'tit bonhomme",
                "+3 DEF contre les ennemis de grandes tailles, +6 DEF contre les ennemis plus grands encore",
                "s'ils n'exprimaient pas aussi souvent leurs idées farfelues, les gnomes seraient les meilleurs ninjas qui existent",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = Talent(
                UUID.randomUUID(),
                infoTalent4.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroup(
                UUID.randomUUID(),
                "#4 - P'tit bonhomme",
                4,
                listOf(talent4.uuid)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5_1 = Info(
                UUID.randomUUID(),
                "Info - Chanceux",
                "+2 CHAN",
                "",
                ""
            )
            infoTalent5_1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_1 = Talent(
                UUID.randomUUID(),
                infoTalent5_1.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent5_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_2 = Info(
                UUID.randomUUID(),
                "Info - Chanceux",
                "une fois par aventure, si doit subir des dégâts mortels d'une attaque, ne meurt pas et regagne 2d6 PV et son porte bonheur est détruit (perd donc son +1 CHAN)",
                "",
                ""
            )
            infoTalent5_2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_2 = Talent(
                UUID.randomUUID(),
                infoTalent5_1.uuid,
                TalentType.PASSIF.name,
                true,
                null
            )
            talent5_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroup(
                UUID.randomUUID(),
                "#5 - Chanceux",
                5,
                listOf(talent5_1.uuid, talent5_2.uuid)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoPath = Info(
                UUID.randomUUID(),
                "Info - Voie du gnome",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = Path(
                UUID.randomUUID(),
                "Voie du gnome",
                listOf(
                    talentGroup1.uuid,
                    talentGroup2.uuid,
                    talentGroup3.uuid,
                    talentGroup4.uuid,
                    talentGroup5.uuid
                ),
                infoPath.uuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }


            var hashMap = java.util.HashMap<String, Int>()
            hashMap["STAT_SOC"] = 2
            hashMap["STAT_CHAN"] = 2
            hashMap["STAT_FOR"] = -2
            hashMap["STAT_CHA"] = -2
            val statChange = StatChangeGroup(
                "STAT_CHANGE_GNOME",
                "Stat raciale - gnome",
                null,
                hashMap
            )
            statChange.let {
                Log.i("DATABASE", "create statChange - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_STAT_CHANGES)
                    .child(it.uuid.toString()).setValue(it)
            }


            val info = Info(
                UUID.randomUUID(),
                "Info - gnome",
                "petit, bavard, curieux et pas toujours mignon",
                "",
                "vivent entre eux généralement"
            )

            info.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val race = Race(
                UUID.randomUUID(),
                "Gnome",
                6,
                6,
                info.uuid,
                path.uuid,
                statChange.uuid,
                null
            )
            race.let {
                Log.i("DATABASE", "create race - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_RACES)
                    .child(it.uuid.toString()).setValue(it)
            }

        }

        fun hautElfe(database: DatabaseReference) {
            val infoTalent1 = Info(
                UUID.randomUUID(),
                "Info - Sagesse ancestrale",
                " +5 tests liés aux tests sur les différentes races du continents et sur des évènements historiques passés",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = Talent(
                UUID.randomUUID(),
                infoTalent1.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val talentGroup1 = TalentGroup(
                UUID.randomUUID(),
                "#1 - Sagesse ancestrale",
                1,
                listOf(talent1.uuid)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent2 = Info(
                UUID.randomUUID(),
                "Info - Affinité magique",
                " +5 SOC pour parler une créature magique et +5 INT pour comprendre une créature magiqu",
                "ca tient chaud dans les profondeurs de la terre",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = Talent(
                UUID.randomUUID(),
                infoTalent2.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroup(
                UUID.randomUUID(),
                "#2 - Affinité magique",
                2,
                listOf(talent2.uuid)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent3 = Info(
                UUID.randomUUID(),
                "Info - Puit d'arcane",
                "une fois par jour, puise dans son être intérieur l'énergie dont il aurait besoin pour lancer des sorts, perd 1d10 PV, pour regagner RANG d6 mana  ",
                "(ne peut pas dépasser son montant de mana max à moins d'avoir le dépassement de mana  (magicien, voie magie universelle, rang 3)",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = Talent(
                UUID.randomUUID(),
                infoTalent3.uuid,
                TalentType.ACTIF.name,
                false,
                1
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroup(
                UUID.randomUUID(),
                "#3 - Puit d'arcane",
                3,
                listOf(talent3.uuid)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4 = Info(
                UUID.randomUUID(),
                "Info - Visage impensable",
                "une fois par jour, l'elfe peut prendre les traits d'un être monstrueux et dangereux qui a disparus des millénaires plus tôt (cf gandalf chez bilbo), lui donne +10 SOC, +10 CHA pour faire fuir ou convaincre les gens autour de lui",
                "",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = Talent(
                UUID.randomUUID(),
                infoTalent4.uuid,
                TalentType.ACTIF.name,
                false,
                null
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroup(
                UUID.randomUUID(),
                "#4 - Visage impensable",
                4,
                listOf(talent4.uuid)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5_1 = Info(
                UUID.randomUUID(),
                "Info - Vitalité elfique",
                "augmente son dé de vie au dé 6 ",
                "retro actif",
                ""
            )
            infoTalent5_1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_1 = Talent(
                UUID.randomUUID(),
                infoTalent5_1.uuid,
                TalentType.REINFORCEMENT.name,
                false,
                null
            )
            talent5_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_2 = Info(
                UUID.randomUUID(),
                "Info - Vitalité elfique",
                "peut lancer 2 dé aux tests de CON (et prendre le meilleur résultat) ",
                "",
                ""
            )
            infoTalent5_2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_2 = Talent(
                UUID.randomUUID(),
                infoTalent5_1.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent5_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val talentGroup5 = TalentGroup(
                UUID.randomUUID(),
                "#5 - Vitalité elfique",
                5,
                listOf(talent5_1.uuid, talent5_2.uuid)
            )

            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoPath = Info(
                UUID.randomUUID(),
                "Info - Voie du haut-elfe",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = Path(
                UUID.randomUUID(),
                "Voie du haut-elfe",
                listOf(
                    talentGroup1.uuid,
                    talentGroup2.uuid,
                    talentGroup3.uuid,
                    talentGroup4.uuid,
                    talentGroup5.uuid
                ),
                infoPath.uuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }


            var hashMapNain = java.util.HashMap<String, Int>()
            hashMapNain["STAT_DEX"] = 2
            hashMapNain["STAT_INT"] = 2
            hashMapNain["STAT_FOR"] = -2
            hashMapNain["STAT_SOC"] = -2
            val statChange = StatChangeGroup(
                "STAT_CHANGE_HAUT_ELFE",
                "Stat raciale - haut-elfe",
                null,
                hashMapNain
            )
            statChange.let {
                Log.i("DATABASE", "create statChange - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_STAT_CHANGES)
                    .child(it.uuid.toString()).setValue(it)
            }


            val info = Info(
                UUID.randomUUID(),
                "Info - haut-elfe",
                "aime la magie, être hautain et desteste les nains",
                "",
                ""
            )

            info.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val race = Race(
                UUID.randomUUID(),
                "Haut-elfe",
                4,
                8,
                info.uuid,
                path.uuid,
                statChange.uuid,
                null
            )
            race.let {
                Log.i("DATABASE", "create race - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_RACES)
                    .child(it.uuid.toString()).setValue(it)
            }

        }

        fun elfeSylvain(database: DatabaseReference) {
            val infoTalent1 = Info(
                UUID.randomUUID(),
                "Info - Nature primordiale",
                "+5 INT aux tests liés à la connaissance d'une plante, d'un arbre ou d'un animal",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = Talent(
                UUID.randomUUID(),
                infoTalent1.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val talentGroup1 = TalentGroup(
                UUID.randomUUID(),
                "#1 - Nature primordiale",
                1,
                listOf(talent1.uuid)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent2 = Info(
                UUID.randomUUID(),
                "Info - Cri sauvage",
                "test difficulté 10 pour imiter le cri / bruit, d'un animal qu'il connait",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = Talent(
                UUID.randomUUID(),
                infoTalent2.uuid,
                TalentType.ACTIF.name,
                false,
                1
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroup(
                UUID.randomUUID(),
                "#2 - Cri sauvage",
                2,
                listOf(talent2.uuid)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent3 = Info(
                UUID.randomUUID(),
                "Info - Amis de la forêt",
                "une fois par jour, en pleine nature (ou il y a de la vie), l'elfe sylvain pousse un puissant cri, qui appelle des animaux proches qui attaquent des ennemis au hasard",
                " test de CON pour définir les dégâts :\n" +
                        "1-5: 1d6 DMG\n" +
                        "6-10: 2x 1d6 DMG\n" +
                        "11-15: 3x 1d6 DMG\n" +
                        "16-19: 4x 1d6 DMG\n" +
                        "20: 5x 1d6 DMG ",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = Talent(
                UUID.randomUUID(),
                infoTalent3.uuid,
                TalentType.ACTIF.name,
                false,
                2
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroup(
                UUID.randomUUID(),
                "#3 - Amis de la forêt",
                3,
                listOf(talent3.uuid)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4_1 = Info(
                UUID.randomUUID(),
                "Info - Équipement naturel",
                "ajoute 1d6 à ses armes et +2 DEF à ses armures qui ne contiennent pas de métal",
                "",
                ""
            )
            infoTalent4_1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_1 = Talent(
                UUID.randomUUID(),
                infoTalent4_1.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent4_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent4_2 = Info(
                    UUID.randomUUID(),
            "Info - Équipement naturel",
            "n'a plus de malus de DEX lié) à la DEF  si celle-ci n'est pas métallique",
            "",
            ""
            )
            infoTalent4_2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_2 = Talent(
                UUID.randomUUID(),
                infoTalent4_1.uuid,
                TalentType.REINFORCEMENT.name,
                false,
                null
            )
            talent4_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val talentGroup4 = TalentGroup(
                UUID.randomUUID(),
                "#4 - Équipement naturel",
                4,
                listOf(talent4_1.uuid, talent4_2.uuid)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5_1 = Info(
                UUID.randomUUID(),
                "Info - Harmonie avec la nature",
                "+1 DEX et +1 CON",
                "",
                ""
            )
            infoTalent5_1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_1 = Talent(
                UUID.randomUUID(),
                infoTalent5_1.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent5_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_2 = Info(
                UUID.randomUUID(),
                "Info - Harmonie avec la nature",
                "avantage sur le jet de CON de la compétence de niveau 3 amis de la forêt",
                "",
                ""
            )
            infoTalent5_2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_2 = Talent(
                UUID.randomUUID(),
                infoTalent5_1.uuid,
                TalentType.REINFORCEMENT.name,
                false,
                null
            )
            talent5_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val talentGroup5 = TalentGroup(
                UUID.randomUUID(),
                "#5 - Harmonie avec la forêt",
                5,
                listOf(talent5_1.uuid, talent5_2.uuid)
            )

            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoPath = Info(
                UUID.randomUUID(),
                "Info - Voie de l'elfe sylvain",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = Path(
                UUID.randomUUID(),
                "Voie de l'elfe-sylvain",
                listOf(
                    talentGroup1.uuid,
                    talentGroup2.uuid,
                    talentGroup3.uuid,
                    talentGroup4.uuid,
                    talentGroup5.uuid
                ),
                infoPath.uuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }


            var hashMapNain = java.util.HashMap<String, Int>()
            hashMapNain["STAT_DEX"] = 2
            hashMapNain["STAT_FOR"] = -1
            val statChange = StatChangeGroup(
                "STAT_CHANGE_ELFE_SYLVAIN",
                "Stat raciale - elfe-sylvain",
                null,
                hashMapNain
            )
            statChange.let {
                Log.i("DATABASE", "create statChange - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_STAT_CHANGES)
                    .child(it.uuid.toString()).setValue(it)
            }


            val info = Info(
                UUID.randomUUID(),
                "Info - elfe-sylvain",
                "probablement né dans la foret",
                "aime faire des choses avec les abres, ou comme ils aiment l'appeller 'entrer en communion avec la nature'",
                ""
            )

            info.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val race = Race(
                UUID.randomUUID(),
                "Elfe-sylvain",
                8,
                6,
                info.uuid,
                path.uuid,
                statChange.uuid,
                null
            )
            race.let {
                Log.i("DATABASE", "create race - ${it.uuid.toString()}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_RACES)
                    .child(it.uuid.toString()).setValue(it)
            }

        }
    }
}