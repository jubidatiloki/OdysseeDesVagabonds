package fr.btytgat.odysseedesvagabonds.ui.equipment.view

import android.os.Bundle
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.equipment.IEquipementView
import fr.btytgat.odysseedesvagabonds.ui.equipment.presenter.EquipmentPresenter

class EquipmentActivity: BaseActivity(), IEquipementView.IActivity {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_equipement)

        presenter = EquipmentPresenter(this, this)
        presenter.onViewCreated()
    }
}