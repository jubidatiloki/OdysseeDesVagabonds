package fr.btytgat.odysseedesvagabonds.ui.home.presenter

import android.app.Activity
import fr.btytgat.odysseedesvagabonds.ui.base.presenter.AbstractBasePresenter
import fr.btytgat.odysseedesvagabonds.ui.home.IHomeView

class HomePresenter(val activity: Activity, val iview: IHomeView.IActivity): AbstractBasePresenter() {



    override fun onViewCreated() {
        super.onViewCreated()
        iview.updateDataFields()

    }
}