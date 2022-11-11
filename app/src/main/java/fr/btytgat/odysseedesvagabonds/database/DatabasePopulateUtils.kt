package fr.btytgat.odysseedesvagabonds.database

import fr.btytgat.odysseedesvagabonds.database.entities.Info

class DatabasePopulateUtils {

    companion object{

        fun populate(){
            val infoGuerrier = Info(id = null, name = "Guerier", entity = EntityEnum.CLASSE.name, description = "desc guerrier", history = "history guerrier")

        }

        fun populateInfo(){
            val infoGuerrier = Info(id = null, name = "Guerier", entity = EntityEnum.CLASSE.name, description = "desc guerrier", history = "history guerrier")
        }

        fun populateClasses(){
//            val guerrier = Classe()
        }

    }
}