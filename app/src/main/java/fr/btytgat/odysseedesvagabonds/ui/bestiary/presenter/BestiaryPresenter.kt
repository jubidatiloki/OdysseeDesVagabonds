package fr.btytgat.odysseedesvagabonds.ui.bestiary.presenter

import android.app.Activity
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.presenter.BasePresenter
import fr.btytgat.odysseedesvagabonds.ui.bestiary.IBestiaryView

class BestiaryPresenter(activity: Activity, iview: IBestiaryView.IActivity): BasePresenter(activity, iview) {

    override fun onViewCreated() {
        super.onViewCreated()

        iview.initToolbar(R.string.menu_title_bestiary)
    }
}