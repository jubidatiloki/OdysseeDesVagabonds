package fr.btytgat.odysseedesvagabonds.database.firebase.initializers

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils
import fr.btytgat.odysseedesvagabonds.database.wrapper.DiceWrapper
import java.util.*

class DiceInitializer {

    companion object {

        fun populateDices(database: DatabaseReference) {
            getDice4().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DICES)
                    .child(it.uuid).setValue(it)
            }
            getDice6().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DICES)
                    .child(it.uuid).setValue(it)
            }
            getDice8().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DICES)
                    .child(it.uuid).setValue(it)
            }
            getDice10().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DICES)
                    .child(it.uuid).setValue(it)
            }
            getDice12().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DICES)
                    .child(it.uuid).setValue(it)
            }
            getDice20().let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DICES)
                    .child(it.uuid).setValue(it)
            }
        }


        fun getDice4(): DiceWrapper {
            return DiceWrapper(
                UUID.randomUUID().toString(),
                "D4",
                "dé 4",
                4
            )
        }

        fun getDice6(): DiceWrapper {
            return DiceWrapper(
                UUID.randomUUID().toString(),
                "D6",
                "dé 6",
                6
            )
        }

        fun getDice8(): DiceWrapper {
            return DiceWrapper(
                UUID.randomUUID().toString(),
                "D8",
                "dé 8",
                8
            )
        }

        fun getDice10(): DiceWrapper {
            return DiceWrapper(
                UUID.randomUUID().toString(),
                "D10",
                "dé 10",
                10
            )
        }

        fun getDice12(): DiceWrapper {
            return DiceWrapper(
                UUID.randomUUID().toString(),
                "D12",
                "dé 12",
                12
            )
        }

        fun getDice20(): DiceWrapper {
            return DiceWrapper(
                UUID.randomUUID().toString(),
                "D20",
                "dé 20",
                20
            )
        }
    }
}