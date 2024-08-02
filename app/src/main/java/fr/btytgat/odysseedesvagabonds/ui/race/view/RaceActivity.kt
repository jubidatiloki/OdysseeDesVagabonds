package fr.btytgat.odysseedesvagabonds.ui.race.view

import android.os.Bundle
import android.util.Log
import android.widget.ExpandableListView
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.adapter.RaceExpandableListAdapter
import fr.btytgat.odysseedesvagabonds.database.DatabaseManager
import fr.btytgat.odysseedesvagabonds.database.entities.Race
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.race.IRaceView
import fr.btytgat.odysseedesvagabonds.ui.race.presenter.RacePresenter


class RaceActivity : BaseActivity(), IRaceView.IActivity {


    private var racesTitleList: List<String> = emptyList()
    private var racesDataList: HashMap<String, List<Race>> = HashMap()
    private var adapter: RaceExpandableListAdapter? = null

    private var listRace: List<Race> = emptyList()
    private lateinit var expandableListView: ExpandableListView

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

        adapter = RaceExpandableListAdapter(this, racesTitleList, racesDataList)
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
        var localDB = DatabaseManager.getInstance(this)

        val races = localDB.raceDao().getAllRaces()

        races.forEach { race ->
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

            racesDataList[race.name] = listOf(race)
        }

        initRaceList()

        Log.i("getAllRaces", "finished raceList size=" + races.size);


    }

}