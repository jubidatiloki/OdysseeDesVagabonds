package fr.btytgat.odysseedesvagabonds.database.firebase

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils.Companion.KEY_CLASSES
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils.Companion.KEY_INFOS
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils.Companion.KEY_SYSTEM
import fr.btytgat.odysseedesvagabonds.database.wrapper.ClasseWrapper
import fr.btytgat.odysseedesvagabonds.database.wrapper.InfoWrapper
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
                    PathInitializer.voieBestiale(database),
                    PathInitializer.voieProtecteur(database),
                    PathInitializer.voieNature(database),
                    PathInitializer.voieVegetaux(database)
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
                    PathInitializer.voieArtillerie(database),
                    PathInitializer.voieChimiste(database),
                    PathInitializer.voieTireur(database),
                    PathInitializer.voieMecanismes(database)
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
                    PathInitializer.voieFeu(database),
                    PathInitializer.voieTerre(database),
                    PathInitializer.voieEau(database),
                    PathInitializer.voieAir(database),
                    PathInitializer.voieArcane(database),
                    PathInitializer.voieMagieUniverselle(database),
                    PathInitializer.voieLumiere(database),
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