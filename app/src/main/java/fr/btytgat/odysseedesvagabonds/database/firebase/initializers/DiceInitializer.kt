package fr.btytgat.odysseedesvagabonds.database.firebase.initializers

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils
import fr.btytgat.odysseedesvagabonds.database.wrapper.DiceWrapper
import java.util.*

class DiceInitializer {

    companion object {

        fun populateDices(database: DatabaseReference) {
            dice4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DICES)
                    .child(it.uuid).setValue(it)
            }
            dice6.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DICES)
                    .child(it.uuid).setValue(it)
            }
            dice8.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DICES)
                    .child(it.uuid).setValue(it)
            }
            dice10.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DICES)
                    .child(it.uuid).setValue(it)
            }
            dice12.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DICES)
                    .child(it.uuid).setValue(it)
            }
            dice20.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_DICES)
                    .child(it.uuid).setValue(it)
            }
        }


        val dice4 = DiceWrapper(
            UUID.randomUUID().toString(),
            "D4",
            "dé 4",
            4
        )


        val dice6 = DiceWrapper(
            UUID.randomUUID().toString(),
            "D6",
            "dé 6",
            6
        )


        val dice8 = DiceWrapper(
            UUID.randomUUID().toString(),
            "D8",
            "dé 8",
            8
        )


        val dice10 = DiceWrapper(
            UUID.randomUUID().toString(),
            "D10",
            "dé 10",
            10
        )


        val dice12 = DiceWrapper(
            UUID.randomUUID().toString(),
            "D12",
            "dé 12",
            12
        )


        val dice20 = DiceWrapper(
            UUID.randomUUID().toString(),
            "D20",
            "dé 20",
            20
        )

    }
}