package fr.btytgat.odysseedesvagabonds.adapter

import android.content.Context
import android.graphics.Typeface
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.BaseExpandableListAdapter
import android.widget.ListView
import android.widget.TextView
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.database.entities.Race


class RaceExpandableListAdapter internal constructor(
    private val context: Context,
    private val titleList: List<String>,
    private val dataList: HashMap<String, List<Race>>
): BaseExpandableListAdapter() {

    override fun getChild(listPosition: Int, expandedListPosition: Int): Any {
        return this.dataList[this.titleList[listPosition]]!![expandedListPosition]
    }

    override fun getChildId(listPosition: Int, expandandedListPosition: Int): Long {
        return expandandedListPosition.toLong()
    }

    override fun getGroupView(
        listPosition: Int,
        isExpanded: Boolean,
        convertView: View?,
        parent: ViewGroup
    ): View {
        var convertView = convertView
        val listTitle = getGroup(listPosition) as String
        if (convertView == null) {
            val layoutInflater =
                this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
            convertView = layoutInflater.inflate(R.layout.custom_group, null)
        }
        val listTitleTextView = convertView!!.findViewById<TextView>(R.id.tv_group)
        listTitleTextView.setTypeface(null, Typeface.BOLD)
        listTitleTextView.text = listTitle
        return convertView
    }

    override fun getChildView(listPosition: Int, expandedListPosition: Int, isLastChidl: Boolean, convertView: View?, parent: ViewGroup?): View {
        var convertView = convertView
        val race = getChild(listPosition, expandedListPosition) as Race
        if (convertView == null) {
            val layoutInflater =
                this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
            convertView = layoutInflater.inflate(R.layout.custom_item_race, null)
        }

        val tvDescription = convertView!!.findViewById<TextView>(R.id.tv_description)
        val tvDV = convertView!!.findViewById<TextView>(R.id.tv_dv)
        val tvDM = convertView!!.findViewById<TextView>(R.id.tv_dm)
        val lvStats = convertView!!.findViewById<ListView>(R.id.lv_stats)
        val tvVoie = convertView!!.findViewById<TextView>(R.id.tv_voie)
        tvDescription.text = race.description
        tvDV.text = context.getString(R.string.health_dice) + " " + race.healthDice
        tvDM.text = context.getString(R.string.mana_dice) + " "+ race.manaDice
        tvVoie.text = race.uuidVoie

        val listStats = ArrayList<String>()
        for((key, value) in race.statsChange){
            listStats.add(key + " " + value)
        }
        val statAdapter = ArrayAdapter(context, R.layout.custom_stat_item, listStats)
        lvStats.adapter = statAdapter
        lvStats.divider = null

        return convertView
    }

    override fun getChildrenCount(listPosition: Int): Int {
        return this.dataList[this.titleList[listPosition]]!!.size
    }
    override fun getGroup(listPosition: Int): String {
        return this.titleList[listPosition]
    }
    override fun getGroupCount(): Int {
        return this.titleList.size
    }
    override fun getGroupId(listPosition: Int): Long {
        return listPosition.toLong()
    }

    override fun hasStableIds(): Boolean {
        return false
    }
    override fun isChildSelectable(listPosition: Int, expandedListPosition: Int): Boolean {
        return true
    }
}