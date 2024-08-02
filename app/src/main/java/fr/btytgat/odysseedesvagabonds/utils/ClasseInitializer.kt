package fr.btytgat.odysseedesvagabonds.utils

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.wrapper.*
import fr.btytgat.odysseedesvagabonds.utils.FirebaseUtils.Companion.KEY_CLASSES
import fr.btytgat.odysseedesvagabonds.utils.FirebaseUtils.Companion.KEY_INFOS
import fr.btytgat.odysseedesvagabonds.utils.FirebaseUtils.Companion.KEY_SYSTEM
import java.util.*

class ClasseInitializer {

    companion object {
        fun populateClasses(database: DatabaseReference) {
            druide(database)
            ingenieur(database)
            magicien(database)

        }

        fun druide(database: DatabaseReference){
            val info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Druide",
                "fait des chose aux arbres et aux animaux pour ... la communion avec la nature",
                "",
                ""
            )
            info.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(KEY_SYSTEM).child(KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val classe = ClasseWrapper(
                UUID.randomUUID().toString(),
                "Druide",
                0,
                1,
                info,
                listOf(
                    VoieInitializer.voieBestiale(database),
                    VoieInitializer.voieProtecteur(database),
                    VoieInitializer.voieNature(database),
                    VoieInitializer.voieVegetaux(database)
                )
            )
            classe.let {
                Log.i("DATABASE", "create classe - ${it.uuid.toString()}")
                database.child(KEY_SYSTEM).child(KEY_CLASSES)
                    .child(it.uuid.toString()).setValue(it)
            }
        }

        fun ingenieur(database: DatabaseReference){
            val info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Ingénieur",
                "sait lire, écrire, compter, faire des calcul et utiliser une baliste d'une demi-tonne",
                "",
                ""
            )
            info.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(KEY_SYSTEM).child(KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val classe = ClasseWrapper(
                UUID.randomUUID().toString(),
                "Ingénieur",
                1,
                -1,
                info,
                listOf(
                    VoieInitializer.voieArtillerie(database),
                    VoieInitializer.voieChimiste(database),
                    VoieInitializer.voieTireur(database),
                    VoieInitializer.voieMecanismes(database)
                )
            )
            classe.let {
                Log.i("DATABASE", "create classe - ${it.uuid.toString()}")
                database.child(KEY_SYSTEM).child(KEY_CLASSES)
                    .child(it.uuid.toString()).setValue(it)
            }
        }

        fun magicien(database: DatabaseReference) {
            val info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Magicien",
                "est capable d'épater la gallerie avec la magie",
                "",
                ""
            )
            info.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(KEY_SYSTEM).child(KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val classe = ClasseWrapper(
                UUID.randomUUID().toString(),
                "Magicien",
                -1,
                1,
                info,
                listOf(
                    VoieInitializer.voieFeu(database),
                    VoieInitializer.voieTerre(database),
                    VoieInitializer.voieEau(database),
                    VoieInitializer.voieAir(database),
                    VoieInitializer.voieArcane(database),
                    VoieInitializer.voieMagieUniverselle(database),
                    VoieInitializer.voieLumiere(database),
                )
            )
            classe.let {
                Log.i("DATABASE", "create classe - ${it.uuid.toString()}")
                database.child(KEY_SYSTEM).child(KEY_CLASSES)
                    .child(it.uuid.toString()).setValue(it)
            }
        }
    }




}