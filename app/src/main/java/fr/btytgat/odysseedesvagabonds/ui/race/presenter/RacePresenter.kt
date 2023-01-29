package fr.btytgat.odysseedesvagabonds.ui.race.presenter

import android.app.Activity
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.presenter.BasePresenter
import fr.btytgat.odysseedesvagabonds.ui.classe.IRaceView

class RacePresenter(activity: Activity, iview: IRaceView.IActivity) :
    BasePresenter(activity, iview) {

    override fun onViewCreated() {
        super.onViewCreated()

        iview.initToolbar(R.string.menu_title_race)
    }


}