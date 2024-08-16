package fr.btytgat.odysseedesvagabonds.ui.race.view

import android.os.Bundle
import android.view.View
import android.widget.ExpandableListView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.adapter.PathExpandableListAdapter
import fr.btytgat.odysseedesvagabonds.adapter.RecyclerViewAdapter
import fr.btytgat.odysseedesvagabonds.database.MyDatabase
import fr.btytgat.odysseedesvagabonds.database.entities.Race
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.race.IRaceView
import fr.btytgat.odysseedesvagabonds.ui.race.presenter.RacePresenter


class RaceActivity : BaseActivity(), IRaceView.IActivity {


    private var racesTitleList: List<String> = emptyList()
    private var racesDataList: HashMap<String, List<Race>> = HashMap()
    private var adapter: PathExpandableListAdapter? = null

    private var listRace: List<Race> = emptyList()
    private lateinit var expandableListView: ExpandableListView
    private lateinit var rvRaces: RecyclerView

    private var fragment = RaceFragment()


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_race)
        getAllRaces()


        presenter = RacePresenter(this, this)
        presenter.onViewCreated()

    }

    fun initRaceList() {
        expandableListView = findViewById(R.id.elv_races)

        racesTitleList = ArrayList(racesDataList.keys)

//        adapter = PathExpandableListAdapter(this, racesTitleList, racesDataList)
        expandableListView.setAdapter(adapter)
        adapter?.notifyDataSetChanged()

        expandableListView.setOnGroupExpandListener { groupPosition ->
//            Toast.makeText(
//                applicationContext,
//                (racesTitleList as ArrayList<String>)[groupPosition] + " List Expanded.",
//                Toast.LENGTH_SHORT
//            ).show()
        }
        expandableListView!!.setOnGroupCollapseListener { groupPosition ->
//            Toast.makeText(
//                applicationContext,
//                (racesTitleList as ArrayList<String>)[groupPosition] + " List Collapsed.",
//                Toast.LENGTH_SHORT
//            ).show()
        }
        expandableListView!!.setOnChildClickListener { _, _, groupPosition, childPosition, _ ->
//            Toast.makeText(
//                applicationContext,
//                "Clicked: " + (racesTitleList as ArrayList<String>)[groupPosition] + " -> " + racesDataList[(
//                        racesDataList as
//                                ArrayList<String>
//                        )
//                        [groupPosition]]!!.get(
//                    childPosition
//                ),
//                Toast.LENGTH_SHORT
//            ).show()
            false
        }
    }

    override fun getAllRaces() {
        val localDB = MyDatabase.getInstance(this)

        listRace = localDB.raceDao().getAllRaces()

        listRace.forEach { race ->
            race.info.let {
                race._info = localDB.infoDao().getInfoById(it)
            }
        }

        initAdapter()

    }

    fun initAdapter(){
        rvRaces = findViewById(R.id.rv_race)
        rvRaces.layoutManager = LinearLayoutManager(this)
        var adapter = RecyclerViewAdapter(this, listRace, R.layout.custom_card_race)
        adapter.onItemClick = { race ->
            fragment = RaceFragment.newInstance((race as Race).uuid)
            supportFragmentManager.beginTransaction()
                .add(R.id.framelayout, fragment)
                .show(fragment)
                .commit()
            rvRaces.visibility = View.GONE
        }

        rvRaces.adapter = adapter
    }

    override fun onBackPressed() {
        if(fragment.isAdded && fragment.isVisible){
            supportFragmentManager.beginTransaction()
                .hide(fragment)
                .commit()
            rvRaces.visibility = View.VISIBLE
        }else {
            super.onBackPressed()
        }
    }
}