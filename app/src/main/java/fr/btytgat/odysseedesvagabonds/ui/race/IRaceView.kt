package fr.btytgat.odysseedesvagabonds.ui.race

import fr.btytgat.odysseedesvagabonds.ui.base.IBaseView

interface IRaceView {

    interface IActivity: IBaseView.IActivity{
        fun getAllRaces()
    }

    interface IPresenter: IBaseView.IPresenter {

    }
}