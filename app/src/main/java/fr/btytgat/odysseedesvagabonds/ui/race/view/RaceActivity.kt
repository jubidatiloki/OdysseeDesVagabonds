package fr.btytgat.odysseedesvagabonds.ui.race.view

import android.os.Bundle
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.classe.IRaceView
import fr.btytgat.odysseedesvagabonds.ui.race.presenter.RacePresenter

class RaceActivity: BaseActivity(), IRaceView.IActivity {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_race)

        presenter = RacePresenter(this, this)
        presenter.onViewCreated()
    }
}