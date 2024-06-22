package fr.btytgat.odysseedesvagabonds.ui.race.view

import android.app.ActionBar
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.ExpandableListView
import android.widget.Toast
import com.google.firebase.database.DataSnapshot
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.adapter.RaceExpandableListAdapter
import fr.btytgat.odysseedesvagabonds.database.entities.Race
import fr.btytgat.odysseedesvagabonds.database.entities.Stat
import fr.btytgat.odysseedesvagabonds.database.entities.Voie
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.race.IRaceView
import fr.btytgat.odysseedesvagabonds.ui.race.presenter.RacePresenter
import fr.btytgat.odysseedesvagabonds.utils.DatabaseUtils
import fr.btytgat.odysseedesvagabonds.utils.wrapper.RaceWrapper
import fr.btytgat.odysseedesvagabonds.utils.wrapper.StatWrapper
import fr.btytgat.odysseedesvagabonds.utils.wrapper.VoieWrapper


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

        val races = ArrayList<Race>()
        DatabaseUtils.database.child(DatabaseUtils.KEY_ROOT).child(DatabaseUtils.KEY_RACES).get()
            .addOnSuccessListener {
                for (datasnapshot: DataSnapshot in it.children) {
                    val raceWrapper = DatabaseUtils.retrieveRace(datasnapshot)
                    val race = RaceWrapper.toEntity(raceWrapper)
                    var voieRacial = Voie()
                    val statsChange = HashMap<Stat, Long>()

                    raceWrapper.statsChange.keys.forEach { uuidStat ->
                        DatabaseUtils.database.child(DatabaseUtils.KEY_ROOT)
                            .child(DatabaseUtils.KEY_STATS).child(uuidStat).get()
                            .addOnSuccessListener {
                                    statsChange[StatWrapper.toEntity(
                                        DatabaseUtils.retrieveStat(
                                            it
                                        )
                                    )] = raceWrapper.statsChange[uuidStat] ?: 0L

                                DatabaseUtils.database.child(DatabaseUtils.KEY_ROOT)
                                    .child(DatabaseUtils.KEY_VOIES).child(raceWrapper.uuidVoie)
                                    .get()
                                    .addOnSuccessListener {
                                        voieRacial =
                                            VoieWrapper.toEntity(
                                                DatabaseUtils.retrieveVoie(
                                                    it
                                                )
                                            )
                                    }

                            }
                    }

                    races.add(
                        race.copy(
                            statsChange = statsChange,
                            voieRacial = voieRacial
                        )
                    )
                }
                races.forEach {
                    racesDataList[it.name] = listOf(it)
                }
                initRaceList()
            }
            .addOnCanceledListener {
                emptyList<Race>()
            }
            .addOnFailureListener {
                emptyList<Race>()
            }

        Log.i("getAllRaces", "finished raceList size=" + races.size);


    }

}