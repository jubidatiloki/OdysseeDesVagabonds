package fr.btytgat.odysseedesvagabonds.ui.base.view

import android.content.Context
import android.os.Handler
import android.view.*
import android.widget.ImageButton
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.GravityCompat
import androidx.drawerlayout.widget.DrawerLayout
import com.google.android.material.navigation.NavigationView
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.components.AnimationUtils
import fr.btytgat.odysseedesvagabonds.ui.base.IBaseView
import fr.btytgat.odysseedesvagabonds.ui.home.view.HomeActivity

open class BaseActivity: AppCompatActivity(), IBaseView.IActivity,
    NavigationView.OnNavigationItemSelectedListener {
    protected lateinit var presenter: IBaseView.IPresenter

    protected lateinit var drawerLayout: DrawerLayout
    protected lateinit var navigationView: NavigationView



    override fun initNavigationView(navigationViewRessource: Int, drawerLayoutRessource: Int) {
        if (navigationViewRessource != 0) {
            this.navigationView = findViewById<View>(navigationViewRessource) as NavigationView
            this.navigationView!!.setNavigationItemSelectedListener(this)
        }
        if (drawerLayoutRessource != 0) {
            this.drawerLayout = findViewById<View>(drawerLayoutRessource) as DrawerLayout
        }
    }

    override fun setNavigationViewMenuHeader(menu_header: Int) {
        try {
            val actual_header = navigationView!!.getHeaderView(0)
            navigationView.removeHeaderView(actual_header)
            val nav_header = LayoutInflater.from(this).inflate(menu_header, null as ViewGroup?)
            navigationView.addHeaderView(nav_header)
        } catch (var4: java.lang.Exception) {
            var4.printStackTrace()
        }
    }

    override fun setNavigationViewMenu(menu: Int) {
        try {
            navigationView.menu.clear()
            navigationView.inflateMenu(menu)
        } catch (var3: Exception) {
            var3.printStackTrace()
        }
    }



    override fun initToolbar(titleId: Int) {
        findViewById<TextView>(R.id.tv_toolbar).setText(titleId)
        findViewById<ImageButton>(R.id.burger_menu).setOnClickListener { v ->
            AnimationUtils.buttonAnimation(v)
            if (drawerLayout.isDrawerOpen(GravityCompat.START)) {
                drawerLayout.closeDrawer(Gravity.START) //CLOSE Nav Drawer!
            } else {
                drawerLayout.openDrawer(Gravity.START) //OPEN Nav Drawer!
            }
        }
    }

    override fun getContext(): Context {
        return this.getContext()
    }

    override fun onNavigationItemSelected(item: MenuItem): Boolean {
        val id = item.itemId

        // handle the navigation drawer toggle button click
        if (item.itemId == android.R.id.home) {
            drawerLayout.openDrawer(GravityCompat.START)
            return true
        }

        when(id) {
            R.id.nav_home -> {
                if(this !is HomeActivity)
                    finish()
                presenter.startHomeActivity()
            }
            R.id.nav_character -> {
                if(this !is HomeActivity)
                    finish()
                presenter.startCharacterActivity()
            }
            R.id.nav_dice -> {
                if(this !is HomeActivity)
                    finish()
                presenter.startDiceActivity()
            }
            R.id.nav_classe -> {
                if(this !is HomeActivity)
                    finish()
                presenter.startClasseActivity()
            }
            R.id.nav_race -> {
                if(this !is HomeActivity)
                    finish()
                presenter.startRaceActivity()
            }
            R.id.nav_equipment -> {
                if(this !is HomeActivity)
                    finish()
                presenter.startEquipementActivity()
            }
            R.id.nav_bestiaire -> {
                if(this !is HomeActivity)
                    finish()
                presenter.startBestiaryActivity()
            }
            R.id.nav_rules -> {
                if(this !is HomeActivity)
                    finish()
                presenter.startRulesActivity()
            }
            R.id.nav_annex -> {
                if(this !is HomeActivity)
                    finish()
                presenter.startAnnexActivity()
            }
        }
        val handler = Handler()
        handler.postDelayed({ drawerLayout.closeDrawer(Gravity.START) }, 1000)
        return false
    }
}