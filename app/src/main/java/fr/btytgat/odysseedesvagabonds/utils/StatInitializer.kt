package fr.btytgat.odysseedesvagabonds.utils

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.entities.Info
import fr.btytgat.odysseedesvagabonds.database.entities.Stat

class StatInitializer {

    companion object {
        fun populateStats(database: DatabaseReference) {
            val infoAdc = Info(
                "INFO_STAT_ADC",
                "Info - Aptitude de combat",
                "Maîtrise du combat au corps à corps, importante pour les guerriers et les chevaliers",
                "permet d’augmenter les chances de toucher au corps à corps (toucher bonus = AdC)permet d’augmenter la défense au corps à corps (défense bonus = AC / 2, arrondi au supérieur)",
                ""
            )
            infoAdc.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }

            val statAdc = Stat(
                "STAT_ADC",
                "Aptitude de combat",
                "AdC",
                true,
                true,
                infoAdc.uuid
            )
            statAdc.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }


            val infoAdt = Info(
                "INFO_STAT_ADT",
                "Info - Aptitude de tir",
                "Maîtrise des armes à distance, importante pour les canonniers et les rôdeurs",
                "permet d’augmenter les chances de toucher à distance (toucher bonus = AT)permet d’augmenter la défense à distance (défense bonus = AT / 2, arrondi au supérieur)",
                ""
            )
            infoAdt.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statAdt = Stat(
                "STAT_ADT",
                "Aptitude de tir",
                "AdT",
                true,
                true,
                infoAdt.uuid
            )
            statAdt.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoCha = Info(
                "INFO_STAT_CHA",
                "Info - Charisme",
                "Représente le courage, la prestance auprès, l'image que l'on donne auprès des autres, important pour les chevaliers et les bardes",
                "résister à la peur (face au danger ou une intimidation), impressionner quelqu’un par sa seul présence",
                ""
            )
            infoCha.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statCha = Stat(
                "STAT_CHA",
                "Charisme",
                "CHA",
                true,
                true,
                infoCha.uuid
            )
            statCha.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoChan = Info(
                "INFO_STAT_CHAN",
                "Info - Chance",
                "Représente la chance naturelle et parfois honteuse que RNG jésus porte pour vous",
                "ce qui ne concerne uniquement la chance et non le talent",
                ""
            )
            infoChan.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statChan = Stat(
                "STAT_CHAN",
                "Chance",
                "CHAN",
                true,
                true,
                infoChan.uuid
            )
            statChan.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoCon = Info(
                "INFO_STAT_CON",
                "Info - Constitution",
                "Représente l’endurance et la résistance, importante pour les barbares et moines",
                "Permet d’augmenter les points de vie (vie bonus = END)résistance au poison, à la fatigue, courir (endurance), retenir son souffle",
                ""
            )
            infoCon.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statCon = Stat(
                "STAT_CON",
                "Constitution",
                "CON",
                true,
                true,
                infoCon.uuid
            )
            statCon.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoDefCac = Info(
                "INFO_STAT_DEF_CAC",
                "Info - Défense au corps à corps",
                "Représente la difficulté à être toucher au corps à corps, notamment à cause d'une armure",
                "défense corps à corps = 10 + AdC/2 + compétences + équipement + autres",
                ""
            )
            infoDefCac.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statDefCac = Stat(
                "STAT_DEF_CAC",
                "Défense au corps à corps",
                "DEF CaC",
                false,
                false,
                infoDefCac.uuid
            )
            statDefCac.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoDefDist = Info(
                "INFO_STAT_DEF_DIST",
                "Info - Défense à distance",
                "Représente la difficulté à être touché par des projectiles non magique",
                "défense distance = 10 + AdT/2 + compétences + équipement + autres",
                ""
            )
            infoDefDist.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statDefDist = Stat(
                "STAT_DEF_DIST",
                "Défense à distance",
                "DEF DIST",
                false,
                false,
                infoDefDist.uuid
            )
            statDefDist.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoDefElem = Info(
                "INFO_STAT_DEF_ELEM",
                "Info - Défense élémentaire",
                "Représente la difficulté à être touché par des attaques élémentaire (de souffle par exemple, comme, au hasard de dragon)",
                "défense élémentaire = 10 + compétences + équipement + autres",
                ""
            )
            infoDefElem.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statDefElem = Stat(
                "STAT_DEF_ELEM",
                "Défense élémentaire",
                "DEF ELEM",
                false,
                false,
                infoDefElem.uuid
            )
            statDefElem.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoDefMag = Info(
                "INFO_STAT_DEF_MAG",
                "Info - Défense magique",
                "Représente la difficulté à être touché par des attaques magiques",
                "défense magique = 10 + INT/2 + compétences + équipement + autres",
                ""
            )
            infoDefMag.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statDefMag = Stat(
                "STAT_DEF_MAG",
                "Défense magique",
                "DEF MAG",
                false,
                false,
                infoDefMag.uuid
            )
            statDefMag.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoDex = Info(
                "INFO_STAT_DEX",
                "Info - Dextérité",
                "Représente l’agilité, ainsi que la précision et la vitesse dans certaines situation, importante pour les voleurs",
                "permet d'augmenter les jets d'initiativeacrobatie, crochetage, désamorçage de piège, escalade, se cacher, se déplacer silencieusement, sauter par dessus un trou, courir (vitesse)",
                ""
            )
            infoDex.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statDex = Stat(
                "STAT_DEX",
                "Dextérité",
                "DEX",
                true,
                true,
                infoDex.uuid
            )
            statDex.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoDm = Info(
                "INFO_STAT_DM",
                "Info - Dé de mana",
                "Représente le gain de point de mana par montée de niveau",
                "Dépend de la race et de la classe du personnage",
                ""
            )
            infoDm.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statDm = Stat(
                "STAT_DM",
                "Dé de mana",
                "DM",
                true,
                false,
                infoDm.uuid
            )
            statDm.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoDv = Info(
                "INFO_STAT_DV",
                "Info - Dé de vie",
                "Représente le gain de point de vie par montée de niveau",
                "Dépend de la race et de la classe du personnage",
                ""
            )
            infoDv.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statDv = Stat(
                "STAT_DV",
                "Dé de vie",
                "DV",
                true,
                false,
                infoDv.uuid
            )
            statDv.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoEsq = Info(
                "INFO_STAT_ESQ",
                "Info - Esquive",
                "Représente la capacité à pouvoir esquiver une attaque, plutôt que l’encaisser",
                "retire l’action de mouvement du prochain tour (peu importe le résultat du test)1 esquive par tour maxcalcul esquive = 10 + DEX/2 + compétences + équipement (bonus et malus d’armure) + autres",
                ""
            )
            infoEsq.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statEsq = Stat(
                "STAT_ESQ",
                "Esquive",
                "ESQ",
                false,
                false,
                infoEsq.uuid
            )
            statEsq.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoFor = Info(
                "INFO_STAT_FOR",
                "Info - Force",
                "Représente la puissance brute / musculaire, importante pour les barbares",
                "permet d’augmenter les dégâts au corps à corps (dégâts bonus = FOR)soulever quelque chose, immobiliser quelqu’un",
                ""
            )
            infoFor.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statFor = Stat(
                "STAT_FOR",
                "Force",
                "FOR",
                true,
                true,
                infoFor.uuid
            )
            statFor.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoInit = Info(
                "INFO_STAT_INIT",
                "Info - Initiative",
                "Représente la vitesse de réaction et permet de définir l'ordre d'agissement dans un combat, par rapport aux autre",
                "initiative = 10 + DEX + compétences + équipement + autres",
                ""
            )
            infoInit.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statInit = Stat(
                "STAT_INIT",
                "Initiative",
                "INIT",
                false,
                false,
                infoInit.uuid
            )
            statInit.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoInt = Info(
                "INFO_STAT_INT",
                "Info - Intelligence",
                "Représente les connaissances, et la maîtrise de la magie chez les druides, les magiciens, les nécromanciens et les prêtres",
                "permet d’augmenter la défense magique (défense bonus = INT / 2, arrondi au supérieur)se souvenir, connaître, apprendre",
                ""
            )
            infoInt.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statInt = Stat(
                "STAT_INT",
                "Intelligence",
                "INT",
                true,
                true,
                infoInt.uuid
            )
            statInt.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoPer = Info(
                "INFO_STAT_PER",
                "Info - Perception",
                "Représente le développement de ses sens (vue et ouie notamment), importante pour les bardes, les rôdeurs et  les moines",
                "détection de piège, détection d’une embuscade, trouver un objet dans une pièce, trouver une personne dans une rue bondée, entendre un bruit dans une forêt, ...",
                ""
            )
            infoPer.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statPer = Stat(
                "STAT_PER",
                "Perception",
                "PER",
                true,
                true,
                infoPer.uuid
            )
            statPer.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoPm = Info(
                "INFO_STAT_PM",
                "Info - Point de mana",
                "Représente la quantité de magie possible d’utiliser afin d'utiliser des sorts",
                "régénération: dé de mana PM par nuit de sommeil (divisé par 2 si demi-nuit de sommeil), point de mana initiale = dé de mana max",
                ""
            )
            infoPm.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statPm = Stat(
                "STAT_PM",
                "Point de mana",
                "PM",
                false,
                false,
                infoPm.uuid
            )
            statPm.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoPv = Info(
                "INFO_STAT_PV",
                "Info - Point de vie",
                "Représente la quantité de coup et de blessure qu’il est possible d’encaisser avant de s’évanouir ou de mourir",
                "régénération: dé de vie PV par nuit de sommeil (divisé par 2 si demi-nuit de sommeil),point de vie = 0 → évanouissement pendant 1d6 heures, point de vie < dé de vie (en négatif)  → mort, point de vie initiale = dé de vie max + dé de vie(lancée)",
                ""
            )
            infoPv.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statPv = Stat(
                "STAT_PV",
                "Point de vie",
                "PV",
                false,
                false,
                infoPv.uuid
            )
            statPv.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoRdFeu = Info(
                "INFO_STAT_RD_FEU",
                "Info - Réduction de dégât de feu",
                "Réduit les dégâts élémentaire de feu subis",
                "0 par défaut",
                ""
            )
            infoRdFeu.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statRdFeu = Stat(
                "STAT_RD_FEU",
                "Réduction de dégât de feu",
                "RD FEU",
                false,
                false,
                infoRdFeu.uuid
            )
            statRdFeu.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }


            val infoRdFoudre = Info(
                "INFO_STAT_RD_FOUDRE",
                "Info - Réduction de dégât de foudre",
                "Réduit les dégâts élémentaire de foudre subis",
                "0 par défaut",
                ""
            )
            infoRdFoudre.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statRdFoudre = Stat(
                "STAT_RD_FOUDRE",
                "Réduction de dégât de foudre",
                "RD FOUDRE",
                false,
                false,
                infoRdFoudre.uuid
            )
            statRdFoudre.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoRdGlace = Info(
                "INFO_STAT_RD_GLACE",
                "Info - Réduction de dégât de glace",
                "Réduit les dégâts élémentaire de glace subis",
                "0 par défaut",
                ""
            )
            infoRdGlace.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statRdGlace = Stat(
                "STAT_RD_GLACE",
                "Réduction de dégât de glace",
                "RD GLACE",
                false,
                false,
                infoRdGlace.uuid
            )
            statRdGlace.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoRdMag = Info(
                "INFO_STAT_RD_MAG",
                "Info - Réduction de dégât magique",
                "Réduit les dégâts magique subis",
                "0 par défaut",
                ""
            )
            infoRdMag.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statRdMag = Stat(
                "STAT_RD_MAG",
                "Réduction de dégât magique",
                "RD MAG",
                false,
                false,
                infoRdMag.uuid
            )
            statRdMag.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }


            val infoRdPhy = Info(
                "INFO_STAT_RD_PHY",
                "Info - Réduction de dégât physique",
                "Réduit les dégâts physique subis (corps à corps ou distant)",
                "0 par défaut",
                ""
            )
            infoRdPhy.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statRdPhy = Stat(
                "STAT_RD_PHY",
                "Réduction de dégât physique",
                "RD PHY",
                false,
                false,
                infoRdPhy.uuid
            )
            statRdPhy.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }

            val infoSoc = Info(
                "INFO_STAT_SOC",
                "Info - Social",
                "Représente l’aisance à communiquer, importante pour les bardes et les voleurs",
                "baratiner, bluffer, convaincre, intimider, distraire, obtenir une information",
                ""
            )
            infoSoc.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_INFOS)
                    .child(it.uuid).setValue(it)
            }
            val statSoc = Stat(
                "STAT_SOC",
                "Social",
                "SOC",
                false,
                false,
                infoSoc.uuid
            )
            statSoc.let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(DatabaseUtils.KEY_SYSTEM).child(DatabaseUtils.KEY_CLASSES)
                    .child(it.uuid).setValue(it)
            }
        }
    }
}