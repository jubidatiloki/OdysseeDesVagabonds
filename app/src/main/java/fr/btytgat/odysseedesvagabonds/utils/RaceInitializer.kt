package fr.btytgat.odysseedesvagabonds.utils

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.entities.*

class RaceInitializer {

    companion object {
        fun populateRaces(database: DatabaseReference) {
            nain(database)

        }

        fun nain(database: DatabaseReference) {
            val infoTalent1 = Info(
                "INFO_TALENT_NAIN_1",
                "Info - Outils de nain",
                "Maitrise de la hache et du marteau, si c'était déjà le cas, donne +1 AdC et +1 DMG avec ces armes à la place",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val talent1 = Talent(
                "TALENT_NAIN_1",
                "#1 - Outils de nain",
                1,
                infoTalent1.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid).setValue(it)
            }

            val infoTalent2 = Info(
                "INFO_TALENT_NAIN_2",
                "Info - Ivresse naine",
                "bonus de +5 au tests de CON et peut refaire un jet en cas d'échec (hors échec critique) à un test de CON liés aux breuvages (poison compris)",
                "\"ca tient chaud dans les profondeurs de la terre\"",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val talent2 = Talent(
                "TALENT_NAIN_2",
                "#2 - Ivresse naine",
                2,
                infoTalent2.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid).setValue(it)
            }


            val infoTalent3 = Info(
                "INFO_TALENT_NAIN_3",
                "Info - Tête de fer",
                "donne une attaque gratuite de coup de tête une fois par tour, 1D6 + CON DMG",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val talent3 = Talent(
                "TALENT_NAIN_3",
                "#3 - Tête de fer",
                3,
                infoTalent3.uuid,
                TalentType.ACTIF.name,
                false,
                0
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid).setValue(it)
            }


            val infoTalent4 = Info(
                "INFO_TALENT_NAIN_4",
                "Info - Acolyte des montagnes",
                "dompte un bouquetin pouvant lui servir de monture (pas de compétence particulier pour le combat et panique si n'a pas la voie du cavalier de chevalier), mais a un bonus de +10 d'escalade avec celui-ci et galope à la même vitesse qu'un cheval",
                "",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val talent4 = Talent(
                "TALENT_NAIN_4",
                "#4 - Acolyte des montagnes",
                4,
                infoTalent4.uuid,
                TalentType.SUPPORT.name,
                false,
                null
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid).setValue(it)
            }



            val infoTalent5 = Info(
                "INFO_TALENT_NAIN_5",
                "Info - Ténacité",
                "+2 CON, +2 RD physique, +2 RD magique, +2 RD dans un élément (élément au choix)",
                "",
                ""
            )
            infoTalent5.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val talent5 = Talent(
                "TALENT_NAIN_5",
                "#5 - Ténacité",
                5,
                infoTalent5.uuid,
                TalentType.PASSIF.name,
                false,
                null
            )
            talent5.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_TALENTS)
                    .child(it.uuid).setValue(it)
            }


            val infoPath = Info(
                "INFO_PATH_NAIN",
                "Info - Voie du nain",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val path = Path(
                "PATH_NAIN",
                "Voie du nain",
                listOf(talent1.uuid, talent2.uuid, talent3.uuid, talent4.uuid, talent5.uuid),
                infoPath.uuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_PATHS)
                    .child(it.uuid).setValue(it)
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
                Log.i("DATABASE", "create statChange - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_STAT_CHANGES)
                    .child(it.uuid).setValue(it)
            }


            val info = Info(
                "INFO_RACE_NAIN",
                "Info - nain",
                "se reconnait à  leurs petites tailles, leurs barbes, leur pioches, leurs air raleurs et désagréable, leur addiction pour l'alcool, .... ah et ils aiment pas les elfes aussi",
                "",
                ""
            )

            info.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }

            val race = Race(
                "RACE_NAIN",
                "Nain",
                8,
                4,
                info.uuid,
                path.uuid,
                statChange.uuid,
                null
            )
            race.let {
                Log.i("DATABASE", "create race - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_RACES)
                    .child(it.uuid).setValue(it)
            }

        }
    }
}