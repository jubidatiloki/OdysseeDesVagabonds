package fr.btytgat.odysseedesvagabonds.ui.character.view

import android.content.Context
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import fr.btytgat.odysseedesvagabonds.R

class StepperAdapter(fragmentManager: FragmentManager) : FragmentPagerAdapter(fragmentManager) {

    private var context: Context? = null

    override fun getItem(position: Int): Fragment {
        return when (position) {
            0 -> CharacterOneFragment()
            1 -> CharacterSecondFragment()
            2 -> CharacterThirdFragment()
            3 -> CharacterFourthFragment()
            4 -> CharacterFifthFragment()
            else -> CharacterOneFragment()
        }
    }

    fun setContext(context: Context) {
        this.context = context
    }

    override fun getCount(): Int {
        return 5
    }

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position) {
            0 -> context?.getString(R.string.title_stepper_one)
            1 -> context?.getString(R.string.title_stepper_second)
            2 -> context?.getString(R.string.title_stepper_third)
            3 -> context?.getString(R.string.title_stepper_fourth)
            4 -> context?.getString(R.string.title_stepper_fifth)
            else -> null
        }
    }
}
