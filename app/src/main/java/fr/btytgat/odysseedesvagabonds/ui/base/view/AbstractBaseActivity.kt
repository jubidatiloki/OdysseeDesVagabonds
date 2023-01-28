package fr.btytgat.odysseedesvagabonds.ui.base.view

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import fr.btytgat.odysseedesvagabonds.ui.base.IBaseView

abstract class AbstractBaseActivity: AppCompatActivity(), IBaseView {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

//        presenter.attachView(this as V)
    }

//    override fun onDestroy() {
//        super.onDestroy()
//        presenter.detachView()
//    }



}