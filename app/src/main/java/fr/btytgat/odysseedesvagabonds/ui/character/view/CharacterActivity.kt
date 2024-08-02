package fr.btytgat.odysseedesvagabonds.ui.character.view

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.viewpager.widget.ViewPager
import com.google.android.material.tabs.TabLayout
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.character.ICharacterView
import fr.btytgat.odysseedesvagabonds.ui.character.presenter.CharacterPresenter


class CharacterActivity: BaseActivity(), ICharacterView.IActivity {

    private lateinit var viewPager: ViewPager
    private lateinit var tabLayout: TabLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_character)

        presenter = CharacterPresenter(this, this)
        presenter.onViewCreated()

        viewPager = findViewById(R.id.viewPager)
        tabLayout = findViewById(R.id.tabLayout)

        val adapter = StepperAdapter(supportFragmentManager)
        viewPager.adapter = adapter
        tabLayout.setupWithViewPager(viewPager)

        setupTabIcons()


        viewPager.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {}
            override fun onPageSelected(position: Int) {
            }
            override fun onPageScrollStateChanged(state: Int) {}
        })

    }

    private fun setupTabIcons() {
        val tabIcons = listOf(R.drawable.logo, R.drawable.logo, R.drawable.logo, R.drawable.logo, R.drawable.logo)
        val tabTitles = listOf(
            getString(R.string.title_stepper_one),
            getString(R.string.title_stepper_second),
            getString(R.string.title_stepper_third),
            getString(R.string.title_stepper_fourth),
            getString(R.string.title_stepper_fifth),
        )

        for (i in tabTitles.indices) {
            val tab = tabLayout.getTabAt(i)
            tab?.customView = getTabView(i, tabIcons[i], tabTitles[i])
        }
    }

    private fun getTabView(position: Int, iconResId: Int, title: String): View {
        val view = LayoutInflater.from(this).inflate(R.layout.custom_tab, null)
        val tabIcon = view.findViewById<ImageView>(R.id.tabIcon)
        val tabText = view.findViewById<TextView>(R.id.tabText)
        tabIcon.setImageResource(iconResId)
        tabText.text = title
        return view
    }
}