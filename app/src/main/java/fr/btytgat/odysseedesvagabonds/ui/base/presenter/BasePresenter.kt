package fr.btytgat.odysseedesvagabonds.ui.base.presenter

import android.app.Activity
import android.content.Intent
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.IBaseView
import fr.btytgat.odysseedesvagabonds.ui.bestiary.view.BestiaryActivity
import fr.btytgat.odysseedesvagabonds.ui.character.view.CharacterActivity
import fr.btytgat.odysseedesvagabonds.ui.classe.view.ClasseActivity
import fr.btytgat.odysseedesvagabonds.ui.dice.view.DiceActivity
import fr.btytgat.odysseedesvagabonds.ui.equipment.view.EquipmentActivity
import fr.btytgat.odysseedesvagabonds.ui.home.view.HomeActivity
import fr.btytgat.odysseedesvagabonds.ui.race.view.RaceActivity
import fr.btytgat.odysseedesvagabonds.ui.rule.view.RuleActivity

open class BasePresenter(var activity: Activity, var iview: IBaseView.IActivity): IBaseView.IPresenter {


    override fun onViewCreated() {
        iview.initNavigationView(R.id.navigation_view, R.id.drawer_layout)
        iview.setNavigationViewMenuHeader(R.layout.menu_header);
        iview.setNavigationViewMenu(R.menu.activity_main_drawer);
    }

    override fun startHomeActivity() {
        iview.startActivity(Intent(activity, HomeActivity::class.java))
    }

    override fun startCharacterActivity() {
        iview.startActivity(Intent(activity, CharacterActivity::class.java))
    }

    override fun startDiceActivity() {
        iview.startActivity(Intent(activity, DiceActivity::class.java))
    }

    override fun startClasseActivity() {
        iview.startActivity(Intent(activity, ClasseActivity::class.java))
    }

    override fun startRaceActivity() {
        iview.startActivity(Intent(activity, RaceActivity::class.java))
    }

    override fun startEquipementActivity() {
        iview.startActivity(Intent(activity, EquipmentActivity::class.java))
    }

    override fun startBestiaryActivity() {
        iview.startActivity(Intent(activity, BestiaryActivity::class.java))
    }

    override fun startRulesActivity() {
        iview.startActivity(Intent(activity, RuleActivity::class.java))    }

    override fun startAnnexActivity() {
        TODO("Not yet implemented")
    }


}