package fr.btytgat.odysseedesvagabonds.utils

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.wrapper.InfoWrapper
import fr.btytgat.odysseedesvagabonds.database.wrapper.StatWrapper
import java.util.*

class StatInitializer {

    companion object {
        fun populateStats(database: DatabaseReference) {
            val infoAdc = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Aptitude de combat",
                "Maîtrise du combat au corps à corps, importante pour les guerriers et les chevaliers",
                "permet d’augmenter les chances de toucher au corps à corps (toucher bonus = AdC)permet d’augmenter la défense au corps à corps (défense bonus = AC / 2, arrondi au supérieur)",
                ""
            )
            infoAdc.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString().toString()).setValue(it)
            }

            val statAdc = StatWrapper(
                "STAT_ADC",
                "Aptitude de combat",
                "AdC",
                true,
                true,
                infoAdc
            )
            statAdc.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoAdt = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Aptitude de tir",
                "Maîtrise des armes à distance, importante pour les canonniers et les rôdeurs",
                "permet d’augmenter les chances de toucher à distance (toucher bonus = AT)permet d’augmenter la défense à distance (défense bonus = AT / 2, arrondi au supérieur)",
                ""
            )
            infoAdt.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statAdt = StatWrapper(
                "STAT_ADT",
                "Aptitude de tir",
                "AdT",
                true,
                true,
                infoAdt
            )
            statAdt.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoCha = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Charisme",
                "Représente le courage, la prestance auprès, l'image que l'on donne auprès des autres, important pour les chevaliers et les bardes",
                "résister à la peur (face au danger ou une intimidation), impressionner quelqu’un par sa seul présence",
                ""
            )
            infoCha.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statCha = StatWrapper(
                "STAT_CHA",
                "Charisme",
                "CHA",
                true,
                true,
                infoCha
            )
            statCha.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoChan = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Chance",
                "Représente la chance naturelle et parfois honteuse que RNG jésus porte pour vous",
                "ce qui ne concerne uniquement la chance et non le talent",
                ""
            )
            infoChan.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statChan = StatWrapper(
                "STAT_CHAN",
                "Chance",
                "CHAN",
                true,
                true,
                infoChan
            )
            statChan.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoCon = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Constitution",
                "Représente l’endurance et la résistance, importante pour les barbares et moines",
                "Permet d’augmenter les points de vie (vie bonus = END)résistance au poison, à la fatigue, courir (endurance), retenir son souffle",
                ""
            )
            infoCon.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statCon = StatWrapper(
                "STAT_CON",
                "Constitution",
                "CON",
                true,
                true,
                infoCon
            )
            statCon.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoDefCac = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Défense au corps à corps",
                "Représente la difficulté à être toucher au corps à corps, notamment à cause d'une armure",
                "défense corps à corps = 10 + AdC/2 + compétences + équipement + autres",
                ""
            )
            infoDefCac.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statDefCac = StatWrapper(
                "STAT_DEF_CAC",
                "Défense au corps à corps",
                "DEF CaC",
                false,
                false,
                infoDefCac
            )
            statDefCac.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoDefDist = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Défense à distance",
                "Représente la difficulté à être touché par des projectiles non magique",
                "défense distance = 10 + AdT/2 + compétences + équipement + autres",
                ""
            )
            infoDefDist.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statDefDist = StatWrapper(
                "STAT_DEF_DIST",
                "Défense à distance",
                "DEF DIST",
                false,
                false,
                infoDefDist
            )
            statDefDist.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoDefElem = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Défense élémentaire",
                "Représente la difficulté à être touché par des attaques élémentaire (de souffle par exemple, comme, au hasard de dragon)",
                "défense élémentaire = 10 + compétences + équipement + autres",
                ""
            )
            infoDefElem.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statDefElem = StatWrapper(
                "STAT_DEF_ELEM",
                "Défense élémentaire",
                "DEF ELEM",
                false,
                false,
                infoDefElem
            )
            statDefElem.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoDefMag = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Défense magique",
                "Représente la difficulté à être touché par des attaques magiques",
                "défense magique = 10 + INT/2 + compétences + équipement + autres",
                ""
            )
            infoDefMag.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statDefMag = StatWrapper(
                "STAT_DEF_MAG",
                "Défense magique",
                "DEF MAG",
                false,
                false,
                infoDefMag
            )
            statDefMag.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoDex = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Dextérité",
                "Représente l’agilité, ainsi que la précision et la vitesse dans certaines situation, importante pour les voleurs",
                "permet d'augmenter les jets d'initiativeacrobatie, crochetage, désamorçage de piège, escalade, se cacher, se déplacer silencieusement, sauter par dessus un trou, courir (vitesse)",
                ""
            )
            infoDex.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statDex = StatWrapper(
                "STAT_DEX",
                "Dextérité",
                "DEX",
                true,
                true,
                infoDex
            )
            statDex.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoDm = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Dé de mana",
                "Représente le gain de point de mana par montée de niveau",
                "Dépend de la race et de la classe du personnage",
                ""
            )
            infoDm.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statDm = StatWrapper(
                "STAT_DM",
                "Dé de mana",
                "DM",
                true,
                false,
                infoDm
            )
            statDm.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoDv = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Dé de vie",
                "Représente le gain de point de vie par montée de niveau",
                "Dépend de la race et de la classe du personnage",
                ""
            )
            infoDv.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statDv = StatWrapper(
                "STAT_DV",
                "Dé de vie",
                "DV",
                true,
                false,
                infoDv
            )
            statDv.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoEsq = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Esquive",
                "Représente la capacité à pouvoir esquiver une attaque, plutôt que l’encaisser",
                "retire l’action de mouvement du prochain tour (peu importe le résultat du test)1 esquive par tour maxcalcul esquive = 10 + DEX/2 + compétences + équipement (bonus et malus d’armure) + autres",
                ""
            )
            infoEsq.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statEsq = StatWrapper(
                "STAT_ESQ",
                "Esquive",
                "ESQ",
                false,
                false,
                infoEsq
            )
            statEsq.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoFor = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Force",
                "Représente la puissance brute / musculaire, importante pour les barbares",
                "permet d’augmenter les dégâts au corps à corps (dégâts bonus = FOR)soulever quelque chose, immobiliser quelqu’un",
                ""
            )
            infoFor.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statFor = StatWrapper(
                "STAT_FOR",
                "Force",
                "FOR",
                true,
                true,
                infoFor
            )
            statFor.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoInit = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Initiative",
                "Représente la vitesse de réaction et permet de définir l'ordre d'agissement dans un combat, par rapport aux autre",
                "initiative = 10 + DEX + compétences + équipement + autres",
                ""
            )
            infoInit.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statInit = StatWrapper(
                "STAT_INIT",
                "Initiative",
                "INIT",
                false,
                false,
                infoInit
            )
            statInit.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoInt = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Intelligence",
                "Représente les connaissances, et la maîtrise de la magie chez les druides, les magiciens, les nécromanciens et les prêtres",
                "permet d’augmenter la défense magique (défense bonus = INT / 2, arrondi au supérieur)se souvenir, connaître, apprendre",
                ""
            )
            infoInt.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statInt = StatWrapper(
                "STAT_INT",
                "Intelligence",
                "INT",
                true,
                true,
                infoInt
            )
            statInt.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoPer = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Perception",
                "Représente le développement de ses sens (vue et ouie notamment), importante pour les bardes, les rôdeurs et  les moines",
                "détection de piège, détection d’une embuscade, trouver un objet dans une pièce, trouver une personne dans une rue bondée, entendre un bruit dans une forêt, ...",
                ""
            )
            infoPer.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statPer = StatWrapper(
                "STAT_PER",
                "Perception",
                "PER",
                true,
                true,
                infoPer
            )
            statPer.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoPm = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Point de mana",
                "Représente la quantité de magie possible d’utiliser afin d'utiliser des sorts",
                "régénération: dé de mana PM par nuit de sommeil (divisé par 2 si demi-nuit de sommeil), point de mana initiale = dé de mana max",
                ""
            )
            infoPm.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statPm = StatWrapper(
                "STAT_PM",
                "Point de mana",
                "PM",
                false,
                false,
                infoPm
            )
            statPm.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoPv = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Point de vie",
                "Représente la quantité de coup et de blessure qu’il est possible d’encaisser avant de s’évanouir ou de mourir",
                "régénération: dé de vie PV par nuit de sommeil (divisé par 2 si demi-nuit de sommeil),point de vie = 0 → évanouissement pendant 1d6 heures, point de vie < dé de vie (en négatif)  → mort, point de vie initiale = dé de vie max + dé de vie(lancée)",
                ""
            )
            infoPv.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statPv = StatWrapper(
                "STAT_PV",
                "Point de vie",
                "PV",
                false,
                false,
                infoPv
            )
            statPv.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoRdFeu = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Réduction de dégât de feu",
                "Réduit les dégâts élémentaire de feu subis",
                "0 par défaut",
                ""
            )
            infoRdFeu.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statRdFeu = StatWrapper(
                "STAT_RD_FEU",
                "Réduction de dégât de feu",
                "RD FEU",
                false,
                false,
                infoRdFeu
            )
            statRdFeu.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoRdFoudre = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Réduction de dégât de foudre",
                "Réduit les dégâts élémentaire de foudre subis",
                "0 par défaut",
                ""
            )
            infoRdFoudre.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statRdFoudre = StatWrapper(
                "STAT_RD_FOUDRE",
                "Réduction de dégât de foudre",
                "RD FOUDRE",
                false,
                false,
                infoRdFoudre
            )
            statRdFoudre.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoRdGlace = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Réduction de dégât de glace",
                "Réduit les dégâts élémentaire de glace subis",
                "0 par défaut",
                ""
            )
            infoRdGlace.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statRdGlace = StatWrapper(
                "STAT_RD_GLACE",
                "Réduction de dégât de glace",
                "RD GLACE",
                false,
                false,
                infoRdGlace
            )
            statRdGlace.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoRdMag = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Réduction de dégât magique",
                "Réduit les dégâts magique subis",
                "0 par défaut",
                ""
            )
            infoRdMag.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statRdMag = StatWrapper(
                "STAT_RD_MAG",
                "Réduction de dégât magique",
                "RD MAG",
                false,
                false,
                infoRdMag
            )
            statRdMag.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoRdPhy = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Réduction de dégât physique",
                "Réduit les dégâts physique subis (corps à corps ou distant)",
                "0 par défaut",
                ""
            )
            infoRdPhy.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statRdPhy = StatWrapper(
                "STAT_RD_PHY",
                "Réduction de dégât physique",
                "RD PHY",
                false,
                false,
                infoRdPhy
            )
            statRdPhy.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoSoc = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Social",
                "Représente l’aisance à communiquer, importante pour les bardes et les voleurs",
                "baratiner, bluffer, convaincre, intimider, distraire, obtenir une information",
                ""
            )
            infoSoc.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val statSoc = StatWrapper(
                "STAT_SOC",
                "Social",
                "SOC",
                false,
                false,
                infoSoc
            )
            statSoc.let {
                Log.i("DATABASE", "create stat - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
        }
    }
}