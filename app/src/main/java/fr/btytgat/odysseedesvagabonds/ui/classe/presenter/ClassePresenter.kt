package fr.btytgat.odysseedesvagabonds.ui.classe.presenter

import android.app.Activity
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.presenter.BasePresenter
import fr.btytgat.odysseedesvagabonds.ui.classe.IClasseView

class ClassePresenter(activity: Activity, iview: IClasseView.IActivity): BasePresenter(activity, iview) {

    override fun onViewCreated() {
        super.onViewCreated()

        iview.initToolbar(R.string.menu_title_classe)
    }


}