package fr.btytgat.odysseedesvagabonds.database.firebase

import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.firebase.initializers.races.RaceNain

class RaceInitializer {

    companion object {
        fun populateRaces(database: DatabaseReference) {
            RaceNain.init(database)
        }

    }

}