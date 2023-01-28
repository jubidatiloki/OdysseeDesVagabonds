package fr.btytgat.odysseedesvagabonds.ui.base.view

import android.os.Bundle
import android.view.MenuItem
import androidx.appcompat.app.ActionBarDrawerToggle
import androidx.core.view.GravityCompat
import androidx.drawerlayout.widget.DrawerLayout
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.IBaseView
import fr.btytgat.odysseedesvagabonds.ui.base.presenter.AbstractBasePresenter

open class BaseDrawerActivity: AbstractBaseActivity() {
    protected lateinit var presenter: IBaseView.IPresenter

    protected lateinit var drawerLayout: DrawerLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        drawerLayout = findViewById(R.id.drawer_layout)

        // setup the navigation drawer
        val toggle = ActionBarDrawerToggle(
            this, drawerLayout, R.string.navigation_drawer_open, R.string.navigation_drawer_close
        )
        drawerLayout.addDrawerListener(toggle)
        toggle.syncState()

        presenter.onViewCreated()
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        // handle the navigation drawer toggle button click
        if (item.itemId == android.R.id.home) {
            drawerLayout.openDrawer(GravityCompat.START)
            return true
        }
        return super.onOptionsItemSelected(item)
    }
}