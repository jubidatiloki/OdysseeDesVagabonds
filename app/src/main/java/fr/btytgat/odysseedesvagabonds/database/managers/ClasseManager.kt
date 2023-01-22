package fr.btytgat.odysseedesvagabonds.database.managers

import android.content.Context
import fr.btytgat.odysseedesvagabonds.database.DatabaseManager
import fr.btytgat.odysseedesvagabonds.database.entities.Classe

class ClasseManager(val context: Context) {
//
//    fun loadClasses(): List<Classe>{
//        val database = DatabaseManager.getInstance(context)
//        val classes = database.classeDao().getAllClasses()
//
//
//        classes.forEach { classe ->
//            classe.info = database.infoDao().getInfoById(classe.idInfo)
//
//            val voies = database.voieDao().getAllVoiesByClasse(classe.id)
//
//            voies.forEach { voie ->
//                voie.info = database.infoDao().getInfoById(voie.idInfo)
//                voie.rangs = database.rangDao().getAllRangsByRang(voie.id)
//
//                voie.rangs.forEach { rang ->
//                    rang.info = database.infoDao().getInfoById(rang.idInfo)
//                }
//            }
//            classe.voies = voies
//        }
//
//        return classes
//    }

}