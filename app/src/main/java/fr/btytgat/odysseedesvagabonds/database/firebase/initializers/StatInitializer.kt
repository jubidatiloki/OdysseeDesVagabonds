package fr.btytgat.odysseedesvagabonds.database.firebase.initializers

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils
import fr.btytgat.odysseedesvagabonds.database.wrapper.InfoWrapper
import fr.btytgat.odysseedesvagabonds.database.wrapper.StatWrapper

class StatInitializer {

    companion object {


        fun populateStats(database: DatabaseReference) {
            getStatAdC().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatAdT().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatCha().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatChan().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatCon().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatDefCac().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatDefDist().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatDefElem().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatDefMag().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatDex().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatDm().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatDv().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatEsq().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatFor().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatInit().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatInt().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatPer().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatPm().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatPv().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatRdFeu().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatRdFoudre().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatRdGlace().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatRdMag().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatRdPhy().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
            getStatSoc().let {
                Log.i("DATABASE", "create stat - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STATS)
                    .child(it.uuid.toString()).setValue(it)
            }
        }


        fun getStatAdC(): StatWrapper {
            val statAdc = StatWrapper(
                "STAT_ADC",
                InfoWrapper(
                    "INFO-STAT_ADC",
                    "Aptitude de combat",
                    "AdC",
                    "Maîtrise du combat au corps à corps, importante pour les guerriers et les chevaliers",
                    "permet d’augmenter les chances de toucher au corps à corps (toucher bonus = AdC)permet d’augmenter la défense au corps à corps (défense bonus = AC / 2, arrondi au supérieur)",
                    ""
                ),
                true,
                true,
            )

            return statAdc
        }

        fun getStatAdT(): StatWrapper {
            val statAdt = StatWrapper(
                "STAT_ADT",
                InfoWrapper(
                    "INFO-STAT_ADT",
                    "Aptitude de tir",
                    "AdT",
                    "Maîtrise des armes à distance, importante pour les canonniers et les rôdeurs",
                    "permet d’augmenter les chances de toucher à distance (toucher bonus = AT)permet d’augmenter la défense à distance (défense bonus = AT / 2, arrondi au supérieur)",
                    ""
                ),
                true,
                true,
            )
            return statAdt
        }

        fun getStatCha(): StatWrapper {

            val statCha = StatWrapper(
                "STAT_CHA",
                InfoWrapper(
                    "INFO-STAT_CHA",
                    "Charisme",
                    "CHA",
                    "Représente le courage, la prestance auprès, l'image que l'on donne auprès des autres, important pour les chevaliers et les bardes",
                    "résister à la peur (face au danger ou une intimidation), impressionner quelqu’un par sa seul présence",
                    ""
                ),
                true,
                true,
            )

            return statCha

        }

        fun getStatChan(): StatWrapper {

            val statChan = StatWrapper(
                "STAT_CHAN",
                InfoWrapper(
                    "INFO-STAT_CHAN",
                    "Chance",
                    "CHAN",
                    "Représente la chance naturelle et parfois honteuse que RNG jésus porte pour vous",
                    "ce qui ne concerne uniquement la chance et non le talent",
                    ""
                ),
                true,
                true,
            )
            return statChan
        }

        fun getStatCon(): StatWrapper {

            val statCon = StatWrapper(
                "STAT_CON",
                InfoWrapper(
                    "INFO-STAT_CON",
                    "Constitution",
                    "CON",
                    "Représente l’endurance et la résistance, importante pour les barbares et moines",
                    "Permet d’augmenter les points de vie (vie bonus = END)résistance au poison, à la fatigue, courir (endurance), retenir son souffle",
                    ""
                ),
                true,
                true,
            )

            return statCon
        }

        fun getStatDefCac(): StatWrapper {
            val statDefCac = StatWrapper(
                "STAT_DEF_CAC",
                InfoWrapper(
                    "INFO-STAT_DEF_CAC",
                    "Défense au corps à corps",
                    "DEF CaC",
                    "Représente la difficulté à être toucher au corps à corps, notamment à cause d'une armure",
                    "défense corps à corps = 10 + AdC/2 + compétences + équipement + autres",
                    ""
                ),
                false,
                false,
            )
            return statDefCac
        }

        fun getStatDefDist(): StatWrapper {
            val statDefDist = StatWrapper(
                "STAT_DEF_DIST",
                InfoWrapper(
                    "INFO-STAT_DEF_DIST",
                    "Défense à distance",
                    "DEF DIST",
                    "Représente la difficulté à être touché par des projectiles non magique",
                    "défense distance = 10 + AdT/2 + compétences + équipement + autres",
                    ""
                ),
                false,
                false,

                )

            return statDefDist
        }

        fun getStatDefElem(): StatWrapper {
            val statDefElem = StatWrapper(
                "STAT_DEF_ELEM",
                InfoWrapper(
                    "INFO-STAT_DEF_ELEM",
                    "Défense élémentaire",
                    "DEF ELEM",
                    "Représente la difficulté à être touché par des attaques élémentaire (de souffle par exemple, comme, au hasard de dragon)",
                    "défense élémentaire = 10 + compétences + équipement + autres",
                    ""
                ),
                false,
                false,
            )
            return statDefElem
        }

        fun getStatDefMag(): StatWrapper {
            val statDefMag = StatWrapper(
                "STAT_DEF_MAG",
                InfoWrapper(
                    "INFO-STAT_DEF_MAG",
                    "Défense magique",
                    "DEF MAG",
                    "Représente la difficulté à être touché par des attaques magiques",
                    "défense magique = 10 + INT/2 + compétences + équipement + autres",
                    ""
                ),
                false,
                false,
            )
            return statDefMag
        }

        fun getStatDex(): StatWrapper {
            val statDex = StatWrapper(
                "STAT_DEX",
                InfoWrapper(
                    "INFO-STAT_DEX",
                    "Dextérité",
                    "DEX",
                    "Représente l’agilité, ainsi que la précision et la vitesse dans certaines situation, importante pour les voleurs",
                    "permet d'augmenter les jets d'initiativeacrobatie, crochetage, désamorçage de piège, escalade, se cacher, se déplacer silencieusement, sauter par dessus un trou, courir (vitesse)",
                    ""
                ),
                true,
                true,
            )
            return statDex
        }

        fun getStatDm(): StatWrapper {
            val statDm = StatWrapper(
                "STAT_DM",
                InfoWrapper(
                    "INFO-STAT_DM",
                    "Dé de mana",
                    "DM",
                    "Représente le gain de point de mana par montée de niveau",
                    "Dépend de la race et de la classe du personnage",
                    ""
                ),
                true,
                false,
            )
            return statDm
        }

        fun getStatDv(): StatWrapper {
            val statDv = StatWrapper(
                "STAT_DV",
                InfoWrapper(
                    "INFO-STAT_DV",
                    "Dé de vie",
                    "DV",
                    "Représente le gain de point de vie par montée de niveau",
                    "Dépend de la race et de la classe du personnage",
                    ""
                ),
                true,
                false,
            )
            return statDv
        }

        fun getStatEsq(): StatWrapper {
            val statEsq = StatWrapper(
                "STAT_ESQ",
                InfoWrapper(
                    "INFO-STAT_ESQ",
                    "Esquive",
                    "ESQ",
                    "Représente la capacité à pouvoir esquiver une attaque, plutôt que l’encaisser",
                    "retire l’action de mouvement du prochain tour (peu importe le résultat du test)1 esquive par tour maxcalcul esquive = 10 + DEX/2 + compétences + équipement (bonus et malus d’armure) + autres",
                    ""
                ),
                false,
                false,

                )
            return statEsq
        }

        fun getStatFor(): StatWrapper {
            val statFor = StatWrapper(
                "STAT_FOR",
                InfoWrapper(
                    "INFO-STAT_FOR",
                    "Force",
                    "FOR",
                    "Représente la puissance brute / musculaire, importante pour les barbares",
                    "permet d’augmenter les dégâts au corps à corps (dégâts bonus = FOR)soulever quelque chose, immobiliser quelqu’un",
                    ""
                ),
                true,
                true,

                )
            return statFor
        }

        fun getStatInit(): StatWrapper {
            val statInit = StatWrapper(
                "STAT_INIT",
                InfoWrapper(
                    "INFO-STAT_INIT",
                    "Initiative",
                    "INIT",
                    "Représente la vitesse de réaction et permet de définir l'ordre d'agissement dans un combat, par rapport aux autre",
                    "initiative = 10 + DEX + compétences + équipement + autres",
                    ""
                ),
                false,
                false,

                )
            return statInit
        }

        fun getStatInt(): StatWrapper {
            val statInt = StatWrapper(
                "STAT_INT",
                InfoWrapper(
                    "INFO-STAT_INT",
                    "Intelligence",
                    "INT",
                    "Représente les connaissances, et la maîtrise de la magie chez les druides, les magiciens, les nécromanciens et les prêtres",
                    "permet d’augmenter la défense magique (défense bonus = INT / 2, arrondi au supérieur)se souvenir, connaître, apprendre",
                    ""
                ),
                true,
                true,
            )
            return statInt
        }

        fun getStatPer(): StatWrapper {
            val statPer = StatWrapper(
                "STAT_PER",
                InfoWrapper(
                    "INFO-STAT_PER",
                    "Perception",
                    "PER",
                    "Représente le développement de ses sens (vue et ouie notamment), importante pour les bardes, les rôdeurs et  les moines",
                    "détection de piège, détection d’une embuscade, trouver un objet dans une pièce, trouver une personne dans une rue bondée, entendre un bruit dans une forêt, ...",
                    ""
                ),
                true,
                true,

                )
            return statPer
        }

        fun getStatPm(): StatWrapper {
            val statPm = StatWrapper(
                "STAT_PM",
                InfoWrapper(
                    "INFO-STAT_PM",
                    "Info - Point de mana",
                    "Représente la quantité de magie possible d’utiliser afin d'utiliser des sorts",
                    "régénération: dé de mana PM par nuit de sommeil (divisé par 2 si demi-nuit de sommeil), point de mana initiale = dé de mana max",
                    ""
                ),
                false,
                false,
            )
            return statPm
        }

        fun getStatPv(): StatWrapper {
            val statPv = StatWrapper(
                "STAT_PV",
                InfoWrapper(
                    "INFO-STAT_PV",
                    "Point de vie",
                    "PV",
                    "Représente la quantité de coup et de blessure qu’il est possible d’encaisser avant de s’évanouir ou de mourir",
                    "régénération: dé de vie PV par nuit de sommeil (divisé par 2 si demi-nuit de sommeil),point de vie = 0 → évanouissement pendant 1d6 heures, point de vie < dé de vie (en négatif)  → mort, point de vie initiale = dé de vie max + dé de vie(lancée)",
                    ""
                ),
                false,
                false,
            )
            return statPv
        }

        fun getStatRdFeu(): StatWrapper {
            val statRdFeu = StatWrapper(
                "STAT_RD_FEU",
                InfoWrapper(
                    "INFO-STAT_RD_FEU",
                    "Réduction de dégât de feu",
                    "RD FEU",
                    "Réduit les dégâts élémentaire de feu subis",
                    "0 par défaut",
                    ""
                ),
                false,
                false,
            )
            return statRdFeu
        }

        fun getStatRdFoudre(): StatWrapper {
            val statRdFoudre = StatWrapper(
                "STAT_RD_FOUDRE",
                InfoWrapper(
                    "INFO-STAT_RD_FOUDRE",
                    "Réduction de dégât de foudre",
                    "RD FOUDRE",
                    "Réduit les dégâts élémentaire de foudre subis",
                    "0 par défaut",
                    ""
                ),
                false,
                false,

                )
            return statRdFoudre
        }

        fun getStatRdGlace(): StatWrapper {
            val statRdGlace = StatWrapper(
                "STAT_RD_GLACE",
                InfoWrapper(
                    "INFO-STAT_RD_GLACE",
                    "Réduction de dégât de glace",
                    "RD GLACE",
                    "Réduit les dégâts élémentaire de glace subis",
                    "0 par défaut",
                    ""
                ),
                false,
                false,

                )
            return statRdGlace
        }

        fun getStatRdMag(): StatWrapper {
            val statRdMag = StatWrapper(
                "STAT_RD_MAG",
                InfoWrapper(
                    "INFO-STAT_RD_MAG",
                    "Réduction de dégât magique",
                    "RD MAG",
                    "Réduit les dégâts magique subis",
                    "0 par défaut",
                    ""
                ),
                false,
                false,
            )
            return statRdMag
        }

        fun getStatRdPhy(): StatWrapper {
            val statRdPhy = StatWrapper(
                "STAT_RD_PHY",
                InfoWrapper(
                    "INFO-STAT_RD_PHY",
                    "Réduction de dégât physique",
                    "RD PHY",
                    "Réduit les dégâts physique subis (corps à corps ou distant)",
                    "0 par défaut",
                    ""
                ),
                false,
                false,

                )
            return statRdPhy
        }

        fun getStatSoc(): StatWrapper {
            val statSoc = StatWrapper(
                "STAT_SOC",
                InfoWrapper(
                    "INFO-STAT_SOC",
                    "Social",
                    "SOC",
                    "Représente l’aisance à communiquer, importante pour les bardes et les voleurs",
                    "baratiner, bluffer, convaincre, intimider, distraire, obtenir une information",
                    ""
                ),
                false,
                false,

                )
            return statSoc
        }
    }
}