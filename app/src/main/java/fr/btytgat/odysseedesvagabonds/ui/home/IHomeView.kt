package fr.btytgat.odysseedesvagabonds.ui.home

import fr.btytgat.odysseedesvagabonds.ui.base.IBaseView

interface IHomeView {

    interface IActivity: IBaseView.IActivity{
        fun updateDataFields()

    }

    interface IPresenter: IBaseView.IPresenter {

    }
}
