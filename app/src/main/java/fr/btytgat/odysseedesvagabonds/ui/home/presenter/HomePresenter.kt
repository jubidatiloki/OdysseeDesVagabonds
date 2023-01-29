package fr.btytgat.odysseedesvagabonds.ui.home.presenter

import android.app.Activity
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.presenter.BasePresenter
import fr.btytgat.odysseedesvagabonds.ui.home.IHomeView

class HomePresenter(activity: Activity, iview: IHomeView.IActivity): BasePresenter(activity, iview) {



    override fun onViewCreated() {
        super.onViewCreated()

        iview.initToolbar(R.string.menu_title_home)
        (iview as IHomeView.IActivity).updateDataFields()

    }
}