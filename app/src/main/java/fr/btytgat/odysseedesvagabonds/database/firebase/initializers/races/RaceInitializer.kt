package fr.btytgat.odysseedesvagabonds.database.firebase.initializers.races

import com.google.firebase.database.DatabaseReference

class RaceInitializer {

    companion object {
        fun populateRaces(database: DatabaseReference) {
            RaceNain.init(database)
            RaceHautElfe.init(database)
        }

    }

}