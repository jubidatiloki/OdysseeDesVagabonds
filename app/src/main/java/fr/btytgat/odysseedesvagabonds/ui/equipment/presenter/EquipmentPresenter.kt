package fr.btytgat.odysseedesvagabonds.ui.equipment.presenter

import android.app.Activity
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.presenter.BasePresenter
import fr.btytgat.odysseedesvagabonds.ui.equipment.IEquipementView

class EquipmentPresenter(activity: Activity, iview: IEquipementView.IActivity): BasePresenter(activity, iview) {

    override fun onViewCreated() {
        super.onViewCreated()

        iview.initToolbar(R.string.menu_title_equipment)
    }
}