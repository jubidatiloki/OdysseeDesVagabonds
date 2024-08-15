package fr.btytgat.odysseedesvagabonds.ui.race.view

import android.os.Bundle
import android.util.Log
import android.widget.ExpandableListView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.adapter.PathExpandableListAdapter
import fr.btytgat.odysseedesvagabonds.adapter.RecyclerViewAdapter
import fr.btytgat.odysseedesvagabonds.database.entities.Race
import fr.btytgat.odysseedesvagabonds.database.mDatabase
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
        Log.i("getAllRaces", "starting ...");
        var localDB = mDatabase.getInstance(this)

        listRace = localDB.raceDao().getAllRaces()

        listRace.forEach { race ->
            race.info?.let {
                race._info = localDB.infoDao().getInfoById(it)
            }
            race._path = localDB.pathDao().getPathById(race.path)
            race.statsChange?.let {
                race._statChange = localDB.statChangeGroupDao().getStatChangeGroupById(it)
            }
            race.specialStatChange?.let {
                race._specialStatChange = it.map { it?.let { localDB.statChangeGroupDao().getStatChangeGroupById(it)} }
            }

//            racesDataList[race.name] = listOf(race)
        }

        initAdapter()

//        initRaceList()

        Log.i("getAllRaces", "finished raceList size=" + listRace.size);
    }

    fun initAdapter(){
        rvRaces = findViewById(R.id.rv_race)
        rvRaces.layoutManager = LinearLayoutManager(this)
        rvRaces.adapter = RecyclerViewAdapter(this, listRace, R.layout.custom_card_race)

    }

}