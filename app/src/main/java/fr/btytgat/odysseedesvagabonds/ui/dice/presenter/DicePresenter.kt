package fr.btytgat.odysseedesvagabonds.ui.dice.presenter

import android.app.Activity
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.presenter.BasePresenter
import fr.btytgat.odysseedesvagabonds.ui.dice.IDiceView

class DicePresenter(activity: Activity, iview: IDiceView.IActivity): BasePresenter(activity, iview) {

    override fun onViewCreated() {
        super.onViewCreated()

        iview.initToolbar(R.string.menu_title_dice)
    }
}