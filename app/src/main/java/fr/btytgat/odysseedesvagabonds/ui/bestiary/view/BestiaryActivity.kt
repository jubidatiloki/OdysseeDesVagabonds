package fr.btytgat.odysseedesvagabonds.ui.bestiary.view

import android.os.Bundle
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.bestiary.IBestiaryView
import fr.btytgat.odysseedesvagabonds.ui.bestiary.presenter.BestiaryPresenter

class BestiaryActivity: BaseActivity(), IBestiaryView.IActivity {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_bestiary)

        presenter = BestiaryPresenter(this, this)
        presenter.onViewCreated()
    }
}