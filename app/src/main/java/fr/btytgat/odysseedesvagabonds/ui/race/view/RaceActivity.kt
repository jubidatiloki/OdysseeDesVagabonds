package fr.btytgat.odysseedesvagabonds.ui.race.view

import android.os.Bundle
import android.widget.ExpandableListView
import android.widget.Toast
import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.adapter.RaceExpandableListAdapter
import fr.btytgat.odysseedesvagabonds.database.entities.Race
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.race.IRaceView
import fr.btytgat.odysseedesvagabonds.ui.race.presenter.RacePresenter
import fr.btytgat.odysseedesvagabonds.utils.DatabaseUtils

class RaceActivity: BaseActivity(), IRaceView.IActivity {


    private var racesTitleList: List<String> = emptyList()
    private var racesDataList: HashMap<String, List<Race>> = HashMap()
    private var adapter: RaceExpandableListAdapter? = null

    private lateinit var expandableListView: ExpandableListView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_race)
        getAllRaces()


        presenter = RacePresenter(this, this)
        presenter.onViewCreated()




    }

    fun initRaceList(){
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

    override fun getAllRaces(){
        DatabaseUtils.database.child(DatabaseUtils.KEY_ROOT).child(DatabaseUtils.KEY_RACES).get().addOnSuccessListener {
            for(datasnapshot: DataSnapshot in it.children){
                val listRace = ArrayList<Race>()
                listRace.add(DatabaseUtils.retrieveRace(datasnapshot))
                racesDataList[datasnapshot.key!!] = listRace
            }
            initRaceList()
        }
    }
}