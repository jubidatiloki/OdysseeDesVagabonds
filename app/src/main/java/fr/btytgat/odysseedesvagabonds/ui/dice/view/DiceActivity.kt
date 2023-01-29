package fr.btytgat.odysseedesvagabonds.ui.dice.view

import android.os.Bundle
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.dice.IDiceView
import fr.btytgat.odysseedesvagabonds.ui.dice.presenter.DicePresenter

class DiceActivity: BaseActivity(), IDiceView.IActivity  {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_dice)

        presenter = DicePresenter(this, this)
        presenter.onViewCreated()
    }
}