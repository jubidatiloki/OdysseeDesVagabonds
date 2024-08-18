package fr.btytgat.odysseedesvagabonds.ui.home.view

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.database.MyDatabase
import fr.btytgat.odysseedesvagabonds.database.firebase.FirebaseUtils
import fr.btytgat.odysseedesvagabonds.database.wrapper.*
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.home.IHomeView
import fr.btytgat.odysseedesvagabonds.ui.home.presenter.HomePresenter

class HomeActivity : BaseActivity(), IHomeView.IActivity {

    lateinit var btReset: Button
    lateinit var btRefreshData: Button
    lateinit var btRetrieveData: Button

    lateinit var tvClasse: TextView
    lateinit var tvRace: TextView
    lateinit var tvVoie: TextView
    lateinit var tvRang: TextView
    lateinit var tvStats: TextView
    lateinit var tvInfos: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_home)

        btReset = findViewById(R.id.bt_reset)
        btRefreshData = findViewById(R.id.bt_update_data)
        btRetrieveData = findViewById(R.id.bt_retrieve_data)

        tvClasse = findViewById(R.id.tv_classe)
        tvRace = findViewById(R.id.tv_race)
        tvVoie = findViewById(R.id.tv_voie)
        tvRang = findViewById(R.id.tv_rang)
        tvStats = findViewById(R.id.tv_stats)
        tvInfos = findViewById(R.id.tv_infos)

        btReset.setOnClickListener {
            FirebaseUtils.initDatabase()
        }
        btRefreshData.setOnClickListener {
            updateDataFields()
        }
        btRetrieveData.setOnClickListener {
            retrieveDatas()
        }

        presenter = HomePresenter(this, this)
        presenter.onViewCreated()
    }

    override fun updateDataFields() {
        val nb_max_classe = 12
        val nb_max_race = 8
        val nb_max_voie = 8 + 11 * 4 + 7
        val nb_max_rang = nb_max_voie * 5
        val nb_max_stat = 25


        with(FirebaseUtils) {
            database.child(KEY_SYSTEM).child(KEY_CLASSES).get().addOnSuccessListener {
                tvClasse.text = "nb classes: \n${it.childrenCount} / $nb_max_classe"
            }
            database.child(KEY_SYSTEM).child(KEY_RACES).get().addOnSuccessListener {
                tvRace.text = "nb races: \n${it.childrenCount} / $nb_max_race"
            }
            database.child(KEY_SYSTEM).child(KEY_PATHS).get().addOnSuccessListener {
                tvVoie.text = "nb voies: \n${it.childrenCount} / $nb_max_voie"
            }
            database.child(KEY_SYSTEM).child(KEY_TALENT_GROUPS).get().addOnSuccessListener {
                tvRang.text = "nb talents: \n${it.childrenCount} / $nb_max_rang"
            }
            database.child(KEY_SYSTEM).child(KEY_STATS).get().addOnSuccessListener {
                tvStats.text = "nb stats: \n${it.childrenCount} / $nb_max_stat"
            }
            database.child(KEY_SYSTEM).child(KEY_INFOS).get().addOnSuccessListener {
                tvInfos.text = "nb infos: \n${it.childrenCount}"
            }
        }
    }

    fun retrieveDatas() {
        val db = MyDatabase.getInstance(application)

        with(FirebaseUtils) {
            database.child(KEY_SYSTEM).child(KEY_RACES)
                .addValueEventListener(object : ValueEventListener {
                    override fun onDataChange(snapshot: DataSnapshot) {
                        for (datasnapshot: DataSnapshot in snapshot.children) {
                            retrieveRace(this@HomeActivity, RaceWrapper.getWrapperFromDS(datasnapshot))
                        }
                    }

                    override fun onCancelled(error: DatabaseError) {
                        TODO("Not yet implemented")
                    }

                })
            database.child(KEY_SYSTEM).child(KEY_STATS)
                .addValueEventListener(object : ValueEventListener {
                    override fun onDataChange(snapshot: DataSnapshot) {
                        for (datasnapshot: DataSnapshot in snapshot.children) {
                            retriveStat(this@HomeActivity, StatWrapper.getWrapperFromDS(datasnapshot))
                        }
                    }
                    override fun onCancelled(error: DatabaseError) {
                        TODO("Not yet implemented")
                    }
                })

            database.child(KEY_SYSTEM).child(KEY_FACULTIES)
                .addValueEventListener(object : ValueEventListener {
                    override fun onDataChange(snapshot: DataSnapshot) {
                        for (datasnapshot: DataSnapshot in snapshot.children) {
                            retrieveFaculties(this@HomeActivity, FacultyWrapper.getWrapperFromDS(datasnapshot))
                        }
                    }
                    override fun onCancelled(error: DatabaseError) {
                        TODO("Not yet implemented")
                    }
                })
            database.child(KEY_SYSTEM).child(KEY_DICES)
                .addValueEventListener(object : ValueEventListener {
                    override fun onDataChange(snapshot: DataSnapshot) {
                        for (datasnapshot: DataSnapshot in snapshot.children) {
                            retrieveDice(this@HomeActivity, DiceWrapper.getWrapperFromDS(datasnapshot))
                        }
                    }
                    override fun onCancelled(error: DatabaseError) {
                        TODO("Not yet implemented")
                    }
                })
            database.child(KEY_SYSTEM).child(KEY_RES_TYPE)
                .addValueEventListener(object : ValueEventListener {
                    override fun onDataChange(snapshot: DataSnapshot) {
                        for (datasnapshot: DataSnapshot in snapshot.children) {
                            retrieveResistanceType(this@HomeActivity, ResistanceTypeWrapper.getWrapperFromDS(datasnapshot))
                        }
                    }
                    override fun onCancelled(error: DatabaseError) {
                        TODO("Not yet implemented")
                    }
                })
            database.child(KEY_SYSTEM).child(KEY_STAT_CHANGE_GROUPS)
                .addValueEventListener(object : ValueEventListener {
                    override fun onDataChange(snapshot: DataSnapshot) {
                        for (datasnapshot: DataSnapshot in snapshot.children) {
                            retrieveStatChangeGroups(this@HomeActivity, StatChangeGroupWrapper.getWrapperFromDS(datasnapshot))
                        }
                    }
                    override fun onCancelled(error: DatabaseError) {
                        TODO("Not yet implemented")
                    }
                })

            database.child(KEY_SYSTEM).child(KEY_DAMAGE_TYPE)
                .addValueEventListener(object : ValueEventListener {
                    override fun onDataChange(snapshot: DataSnapshot) {
                        for (datasnapshot: DataSnapshot in snapshot.children) {
                            retrieveDamageType(this@HomeActivity, DamageTypeWrapper.getWrapperFromDS(datasnapshot))
                        }
                    }
                    override fun onCancelled(error: DatabaseError) {
                        TODO("Not yet implemented")
                    }
                })


        }
    }

}