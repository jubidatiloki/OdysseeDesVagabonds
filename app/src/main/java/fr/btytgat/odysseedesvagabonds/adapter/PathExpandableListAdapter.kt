package fr.btytgat.odysseedesvagabonds.adapter

import android.content.Context
import android.graphics.Typeface
import android.text.Spannable
import android.text.SpannableString
import android.text.style.ForegroundColorSpan
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseExpandableListAdapter
import android.widget.LinearLayout
import android.widget.TextView
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.database.entities.TalentGroup


class PathExpandableListAdapter internal constructor(
    private val context: Context,
    private val titleList: List<String>,
    private val dataList: HashMap<String, List<TalentGroup>>
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
            convertView = layoutInflater.inflate(R.layout.custom_group_path, null)
        }
        val tvTitle = convertView!!.findViewById<TextView>(R.id.tv_title)
//        val tvTalentType = convertView!!.findViewById<TextView>(R.id.tv_type)

        tvTitle.setTypeface(null, Typeface.BOLD)
        tvTitle.text = listTitle


        return convertView
    }

    override fun getChildView(listPosition: Int, expandedListPosition: Int, isLastChidl: Boolean, convertView: View?, parent: ViewGroup?): View {
        var convertView = convertView
        val talentGroup = getChild(listPosition, expandedListPosition) as TalentGroup
        val layoutInflater = this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater

        if (convertView == null) {
            convertView = layoutInflater.inflate(R.layout.custom_child_path, null)
        }

        val tvDescription = convertView!!.findViewById<TextView>(R.id.tv_description)
        val llTalents = convertView!!.findViewById<LinearLayout>(R.id.ll_talent)


        tvDescription.text = talentGroup.description
        talentGroup._talents?.forEach { talent ->
            talent._attack?.let {
//            TODO
            }
            talent._buffs?.forEach{
                val sign: String
                val color1: Int
                if(it.modifier > 0) {
                    sign = "+"
                    color1 = R.color.buff_positive
                } else{
                    sign = "-"
                    color1 = R.color.buff_negative
                }
                var buffedElement = ""
                it._statBound?.let {
                    buffedElement = it._info?.name.toString()
                }
                it._facultyBound?.let {
                    buffedElement = it._info?.name.toString()
                }
                llTalents.addView(
                    generateTextView(
                        "$sign${it.modifier}",
                        color1,
                        buffedElement,
                        R.color.colorAccent
                    )
                )
            }
            talent._effects?.forEach {
//                TODO
            }
        }

        return convertView
    }

    fun generateTextView(label1: String, color1: Int, label2: String, color2: Int): TextView{
        var textView = TextView(context)
        var text1: Spannable = SpannableString(label1)
        text1.setSpan(ForegroundColorSpan(context.getColor(color1)), 0, text1.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)

        var text2: Spannable = SpannableString(label2)
        text2.setSpan(ForegroundColorSpan(context.getColor(color2)), 0, text1.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)

        textView.setText("$text1 $text2")

        textView.setTextColor(context.getColor(R.color.white))
        return textView
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