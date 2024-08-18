package fr.btytgat.odysseedesvagabonds.ui.race.view

import android.os.Bundle
import android.view.View
import android.widget.ExpandableListView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.fragment.app.Fragment
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.adapter.PathExpandableListAdapter
import fr.btytgat.odysseedesvagabonds.database.DatabaseManager
import fr.btytgat.odysseedesvagabonds.database.MyDatabase
import fr.btytgat.odysseedesvagabonds.database.entities.Race
import fr.btytgat.odysseedesvagabonds.database.entities.TalentGroup

class RaceFragment : Fragment(R.layout.fragment_race) {

    private lateinit var race: Race
    private lateinit var databaseManager: DatabaseManager

    private lateinit var tvTitle: TextView
    private lateinit var tvDescription: TextView
    private lateinit var tvDv: TextView
    private lateinit var tvDm: TextView
    private lateinit var llPositive: LinearLayout
    private lateinit var llNegative: LinearLayout
    private lateinit var tvPath: TextView
    private lateinit var elvPath: ExpandableListView
    private var groupList: List<TalentGroup> = emptyList()
    private var wholeList: HashMap<TalentGroup, List<TalentGroup>> = HashMap()


    companion object {
        private const val RACE_KEY = "RACE_KEY"

        fun newInstance(param: String): RaceFragment {
            val fragment = RaceFragment()
            val args = Bundle()
            args.putString(RACE_KEY, param)
            fragment.arguments = args
            return fragment
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val raceUuid = arguments?.getString(RACE_KEY)

        initField(view)

        databaseManager = DatabaseManager(activity!!, MyDatabase.getInstance(activity!!))

        raceUuid?.let {
            race = databaseManager.getRaceWitHDetails(it)
            setInfo(race)
        }
    }

    fun initField(view: View) {
        tvTitle = view.findViewById(R.id.tv_title)
        tvDescription = view.findViewById(R.id.tv_description)
        tvDv = view.findViewById(R.id.tv_dv)
        tvDm = view.findViewById(R.id.tv_dm)
        llPositive = view.findViewById(R.id.ll_positive)
        llNegative = view.findViewById(R.id.ll_negative)
        tvPath = view.findViewById(R.id.tv_path)
        elvPath = view.findViewById(R.id.elv_path)
    }

    fun setInfo(race: Race) {
        tvTitle.text = race._info?.name
        tvDescription.text = race._info?.description
        tvDv.text = race.healthDice.toString()
        tvDm.text = race.manaDice.toString()
        setStatChangeView(race)
        tvPath.text = race._path?._info?.name
        initAdapter(race)
    }

    fun setStatChangeView(race: Race) {
        race._statChange?._statChanges?.forEach {
            var label = ""
            if (it.isPositive) {
                label = "+${it.modifier} ${it._statBound?._info?.shortName}"
            } else {
                label = "${it.modifier} ${it._statBound?._info?.shortName}"
            }
            val statView = TextView(activity).apply {
                text = label

            }
            if (it.isPositive) {
                statView.setTextColor(activity!!.getColor(R.color.buff_positive))
                llPositive.addView(statView)
            } else {
                statView.setTextColor(activity!!.getColor(R.color.buff_negative))
                llNegative.addView(statView)
            }
        }
    }

    fun initAdapter(race: Race){
        race._path?._talentGroups?.forEach { talentGroup ->
            talentGroup._talents?.let {
                groupList  = groupList.plus(talentGroup)
                wholeList[talentGroup] = listOf(talentGroup)
            }

        }

        val adapter = PathExpandableListAdapter(activity!!, groupList, wholeList)
        elvPath.setAdapter(adapter)
        adapter.notifyDataSetChanged()

        elvPath.setOnGroupExpandListener { groupPosition ->


//            Toast.makeText(
//                activity,
//                (wholeList as ArrayList<String>)[groupPosition] + " List Expanded.",
//                Toast.LENGTH_SHORT
//            ).show()
        }
        elvPath.setOnGroupCollapseListener { groupPosition ->
//            Toast.makeText(
//                activity,
//                (wholeList as ArrayList<String>)[groupPosition] + " List Collapsed.",
//                Toast.LENGTH_SHORT
//            ).show()
        }
        elvPath.setOnChildClickListener { _, _, groupPosition, childPosition, _ ->
//            Toast.makeText(
//                activity,
//                "Clicked: " + (wholeList as ArrayList<String>)[groupPosition] + " -> " + wholeList[(
//                        wholeList as
//                                ArrayList<String>
//                        )
//                        [groupPosition]]!!.get(
//                    childPosition
//                ),
//                Toast.LENGTH_SHORT
//            ).show()
            true
        }
    }

}