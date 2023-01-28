package fr.btytgat.odysseedesvagabonds.ui.base

import android.app.Activity

interface IBaseView {

    interface IActivity {

    }

    interface IPresenter {
        fun onViewCreated()

//        fun onStart()
//
//        fun onResume()
//
//        fun onStop()
//
//        fun onDestroy()
//
//        fun onPause()
    }
}