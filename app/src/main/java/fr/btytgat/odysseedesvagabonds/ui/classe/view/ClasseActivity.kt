package fr.btytgat.odysseedesvagabonds.ui.classe.view

import android.os.Bundle
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.classe.IClasseView
import fr.btytgat.odysseedesvagabonds.ui.classe.presenter.ClassePresenter

class ClasseActivity: BaseActivity(), IClasseView.IActivity {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_classe)

        presenter = ClassePresenter(this, this)
        presenter.onViewCreated()
    }
}