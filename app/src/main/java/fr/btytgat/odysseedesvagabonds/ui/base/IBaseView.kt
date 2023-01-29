package fr.btytgat.odysseedesvagabonds.ui.base

import android.content.Context
import android.content.Intent

interface IBaseView {

    interface IActivity {

        fun startActivity(intent: Intent)

        fun getContext(): Context

        fun initNavigationView(navigationLayoutId: Int, drawerLayoutId: Int)

        fun setNavigationViewMenuHeader(menuHeaderId: Int)

        fun setNavigationViewMenu(menuLayoutId: Int)

        fun initToolbar(titleId: Int)

    }

    interface IPresenter {
        fun onViewCreated()

        fun startHomeActivity()

        fun startCharacterActivity()

        fun startDiceActivity()

        fun startClasseActivity()

        fun startRaceActivity()

        fun startEquipementActivity()

        fun startBestiaryActivity()

        fun startRulesActivity()

        fun startAnnexActivity()

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