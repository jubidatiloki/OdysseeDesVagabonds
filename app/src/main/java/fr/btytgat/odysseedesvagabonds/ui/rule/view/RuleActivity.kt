package fr.btytgat.odysseedesvagabonds.ui.rule.view

import android.os.Bundle
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.rule.IRuleView
import fr.btytgat.odysseedesvagabonds.ui.rule.presenter.RulePresenter

class RuleActivity: BaseActivity(), IRuleView.IActivity {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_rules)

        presenter = RulePresenter(this, this)
        presenter.onViewCreated()
    }
}