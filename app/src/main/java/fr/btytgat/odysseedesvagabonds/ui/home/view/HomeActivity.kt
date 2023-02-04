package fr.btytgat.odysseedesvagabonds.ui.home.view

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.home.IHomeView
import fr.btytgat.odysseedesvagabonds.ui.home.presenter.HomePresenter
import fr.btytgat.odysseedesvagabonds.utils.DatabaseUtils

class HomeActivity: BaseActivity(), IHomeView.IActivity {

    lateinit var btReset: Button
    lateinit var btRefreshData: Button

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

        tvClasse = findViewById(R.id.tv_classe)
        tvRace = findViewById(R.id.tv_race)
        tvVoie = findViewById(R.id.tv_voie)
        tvRang = findViewById(R.id.tv_rang)
        tvStats = findViewById(R.id.tv_stats)
        tvInfos = findViewById(R.id.tv_infos)

        btReset.setOnClickListener {
            DatabaseUtils.initDatabase()
        }
        btRefreshData.setOnClickListener{
            updateDataFields()
        }

        presenter = HomePresenter(this, this)
        presenter.onViewCreated()
    }

    override fun updateDataFields(){
        val nb_max_classe = 12
        val nb_max_race = 8
        val nb_max_voie = 8 + 11 * 4 + 7
        val nb_max_rang = nb_max_voie * 5
        val nb_max_stat = 25

        with(DatabaseUtils){
            database.child(KEY_SYSTEM).child(KEY_CLASSES).get().addOnSuccessListener {
                tvClasse.text = "nb classes: \n${it.childrenCount} / $nb_max_classe"
            }
            database.child(KEY_SYSTEM).child(KEY_RACES).get().addOnSuccessListener {
                tvRace.text = "nb races: \n${it.childrenCount} / $nb_max_race"
            }
            database.child(KEY_SYSTEM).child(KEY_VOIES).get().addOnSuccessListener {
                tvVoie.text = "nb voies: \n${it.childrenCount} / $nb_max_voie"
            }
            database.child(KEY_SYSTEM).child(KEY_RANGS).get().addOnSuccessListener {
                tvRang.text = "nb rangs: \n${it.childrenCount} / $nb_max_rang"
            }
            database.child(KEY_SYSTEM).child(KEY_STATS).get().addOnSuccessListener {
                tvStats.text = "nb stats: \n${it.childrenCount} / $nb_max_stat"
            }
            database.child(KEY_SYSTEM).child(KEY_INFOS).get().addOnSuccessListener {
                tvInfos.text = "nb infos: \n${it.childrenCount}"
            }
        }
    }




}