package fr.btytgat.odysseedesvagabonds.ui.home.view

import android.os.Bundle
import android.widget.TextView
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseDrawerActivity
import fr.btytgat.odysseedesvagabonds.ui.home.IHomeView
import fr.btytgat.odysseedesvagabonds.ui.home.presenter.HomePresenter
import fr.btytgat.odysseedesvagabonds.utils.DatabaseUtils

class HomeActivity: BaseDrawerActivity(), IHomeView.IActivity {

    lateinit var tvClasse: TextView
    lateinit var tvRace: TextView
    lateinit var tvVoie: TextView
    lateinit var tvRang: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.home_activity)

        tvClasse = findViewById(R.id.tv_classe)
        tvRace = findViewById(R.id.tv_race)
        tvVoie = findViewById(R.id.tv_voie)
        tvRang = findViewById(R.id.tv_rang)

        presenter = HomePresenter(this, this)
        presenter.onViewCreated()
    }

    override fun updateDataFields(){
        val nb_max_classe = 12
        val nb_max_race = 8
        val nb_max_voie = 8 + 11 * 4 + 7
        val nb_max_rang = nb_max_voie * 5

        with(DatabaseUtils){
            database.child(KEY_CLASSES).get().addOnSuccessListener {
                tvClasse.setText("nb classes: \n${it.childrenCount} / $nb_max_classe")
            }
            database.child(KEY_RACES).get().addOnSuccessListener {
                tvRace.setText("nb races: \n${it.childrenCount} / $nb_max_race")
            }
            database.child(KEY_VOIES).get().addOnSuccessListener {
                tvVoie.setText("nb voies: \n${it.childrenCount} / $nb_max_voie")
            }
            database.child(KEY_RANGS).get().addOnSuccessListener {
                tvRang.setText("nb rangs: \n${it.childrenCount} / $nb_max_rang")
            }
        }
    }
}