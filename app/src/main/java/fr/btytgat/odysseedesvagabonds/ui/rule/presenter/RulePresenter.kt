package fr.btytgat.odysseedesvagabonds.ui.rule.presenter

import android.app.Activity
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.presenter.BasePresenter
import fr.btytgat.odysseedesvagabonds.ui.rule.IRuleView

class RulePresenter(activity: Activity, iview: IRuleView.IActivity): BasePresenter(activity, iview) {

    override fun onViewCreated() {
        super.onViewCreated()

        iview.initToolbar(R.string.menu_title_rules)
    }
}