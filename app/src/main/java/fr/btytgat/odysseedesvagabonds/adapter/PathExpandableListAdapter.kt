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
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.database.entities.TalentGroup
import fr.btytgat.odysseedesvagabonds.database.enums.TalentTypeEnum


class PathExpandableListAdapter(
    private val context: Context,
    private val titleList: List<TalentGroup>,
    private val dataList: HashMap<TalentGroup, List<TalentGroup>>
) : BaseExpandableListAdapter() {

    override fun getChild(listPosition: Int, expandedListPosition: Int): TalentGroup {
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
        val talentGroup = getGroup(listPosition)
        if (convertView == null) {
            val layoutInflater =
                this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
            convertView = layoutInflater.inflate(R.layout.custom_group_path, null)
        }
        val tvTitle = convertView!!.findViewById<TextView>(R.id.tv_title)
        val llTalentType = convertView!!.findViewById<LinearLayout>(R.id.ll_type)
        val ivArrow = convertView!!.findViewById<ImageView>(R.id.iv_arrow)

        tvTitle.setTypeface(null, Typeface.BOLD)
        tvTitle.text = talentGroup.name
        llTalentType.removeAllViews()
        talentGroup.types.forEach { generateIconType(llTalentType, TalentTypeEnum.valueOf(it).icon) }

        if(isExpanded){
            ivArrow.setImageResource(R.drawable.ic_arrow_right)
        }else{
            ivArrow.setImageResource(R.drawable.ic_arrow_bottom)
        }

        return convertView
    }

    fun generateIconType(layout: LinearLayout, icon: Int) {
        val imageView = ImageView(context)
        imageView.setImageResource(icon) // Replace with your drawable resource

        val scale: Float = context.resources.displayMetrics.density
        val dpAsPixels = (20 * scale + 0.5f)
        val layoutParams = LinearLayout.LayoutParams(
            dpAsPixels.toInt(),
            dpAsPixels.toInt()
        )
        imageView.layoutParams = layoutParams

        val params = imageView.layoutParams as ViewGroup.MarginLayoutParams
        layoutParams.setMargins(5, 0,0,0)
        imageView.layoutParams = params
        layout.addView(imageView)
    }

    override fun getChildView(
        listPosition: Int,
        expandedListPosition: Int,
        isLastChidl: Boolean,
        convertView: View?,
        parent: ViewGroup?
    ): View {
        var convertView = convertView
        val talentGroup = getChild(listPosition, expandedListPosition)
        val layoutInflater =
            this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater

        if (convertView == null) {
            convertView = layoutInflater.inflate(R.layout.custom_child_path, null)
        }

        val tvDescription = convertView!!.findViewById<TextView>(R.id.tv_description)
        val llTalents = convertView!!.findViewById<LinearLayout>(R.id.ll_talent)
        llTalents.removeAllViews()

        if(talentGroup._talents?.isNotEmpty() == true) {
            tvDescription.text = talentGroup._talents?.get(0)?._info?.description
        }
        talentGroup._talents?.filter { !it.choice }?.forEach { talent ->
            talent._attack?.let { attack ->
                var color1: Int
                var label1 = ""
                var label2 = ""
                if (talent.magic) {
                    color1 = R.color.lightBlue
                } else {
                    color1 = R.color.lightRed
                }
                attack._damage?.let {
                    label1 += "${it.nbDice}${it._dice?.code}"
                    it._statBound?.let {
                        label1 += " + ${it._info?.shortName}"
                    }
                    it._damageType?.let {
                        label2 += " ${it._info?.name}"
                    }
                }
                llTalents.addView(
                    generateTextView(
                        label1,
                        color1,
                        "$label1 $label2",
                        R.color.white
                    )
                )

            }
            talent._buffs.forEach {
                val color1: Int
                var label1 = ""
                if (it.modifier > 0) {
                    color1 = R.color.buff_positive
                    label1 = "+ ${it.modifier} "
                } else {
                    color1 = R.color.buff_negative
                    label1 = "${it.modifier} "
                }
                if(it.gainAdvantage == true){
                    if(label1.isNotEmpty()) {
                        label1 += " et "
                    }
                    label1 += "avantage "
                }

                var text = ""
                it._statBound?.let {
                    label1 += it._info?.shortName
                }
                it._facultyBound?.let {
                    label1 += it._info?.shortName
                    text = it._info?.name.toString()
                }
                llTalents.addView(
                    generateTextView(
                        label1,
                        color1,
                        "$label1 $text",
                        R.color.white
                    )
                )
            }
            talent._effects?.forEach {
//                TODO
            }
        }
        talentGroup._talents?.filter { it.choice }?.groupBy { it.category }?.forEach { map ->
            if(map.value.isNotEmpty()) {
                var label = "et ${map.value.get(0).maxTaken} au choix : "
                llTalents.addView(
                    generateTextView(
                        null,
                        null,
                        label,
                        R.color.lightBlue
                    )
                )
            }
            map.value.forEach { talent ->
                talent._buffs.forEach {
                    val color1: Int
                    var label1 = "\t\t"
                    if (it.modifier > 0) {
                        color1 = R.color.buff_positive
                        label1 += "+ ${it.modifier} "
                    } else {
                        color1 = R.color.buff_negative
                        label1 += "${it.modifier} "
                    }
                    var buffedElement = ""
                    it._statBound?.let {
                        label1 += it._info?.shortName

                    }
                    it._facultyBound?.let {
                        label1 += it._info?.shortName
                        buffedElement = it._info?.name.toString()
                    }
                    llTalents.addView(
                        generateTextView(
                            label1,
                            color1,
                            "$label1 $buffedElement",
                            R.color.white
                        )
                    )
                }
            }



        }

        return convertView
    }

    fun generateTextView(label1: String?, color1: Int?, wholeLabel: String, color2: Int): TextView {
        var textView = TextView(context)
        var spanString: Spannable = SpannableString(wholeLabel)
        if(label1 != null && color1 != null) {
            spanString.setSpan(
                ForegroundColorSpan(context.resources.getColor(color1, null)),
                0,
                label1.length,
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
            )
            spanString.setSpan(
                ForegroundColorSpan(context.resources.getColor(color2, null)),
                label1.length + 1,
                wholeLabel.length,
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
            )
        }else{
            spanString.setSpan(
                ForegroundColorSpan(context.resources.getColor(color2, null)),
                0,
                wholeLabel.length,
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
            )
        }
        textView.text = spanString

        return textView
    }


    override fun getChildrenCount(listPosition: Int): Int {
        return this.dataList[this.titleList[listPosition]]!!.size
    }

    override fun getGroup(listPosition: Int): TalentGroup {
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