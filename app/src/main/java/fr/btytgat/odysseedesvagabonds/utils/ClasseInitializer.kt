package fr.btytgat.odysseedesvagabonds.utils

import fr.btytgat.odysseedesvagabonds.database.DatabaseManager
import fr.btytgat.odysseedesvagabonds.database.entities.Classe
import fr.btytgat.odysseedesvagabonds.database.entities.Info
import java.util.*

class ClasseInitializer {

    companion object {
        fun populateClasses(databaseManager: DatabaseManager) {
            val infoBarbare = Info(
                "INFO_CLASSE_BARBARE",
                "Classe barbare",
                "aime se battre, beaucoup et vraiment tout le temps, pour tout",
                "",
                "sait généralement ni lire, ni écrire, ... donc niveau histoire ..."
            )
            val classeBarbare = Classe(
                UUID.fromString("CLASSE_BARBARE"),
                "Barbare",
                1,
                -1,
                infoBarbare.uuid,
            )
        }
    }

}