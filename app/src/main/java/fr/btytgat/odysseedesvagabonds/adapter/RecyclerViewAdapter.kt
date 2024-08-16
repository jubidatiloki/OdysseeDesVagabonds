package fr.btytgat.odysseedesvagabonds.adapter

import android.app.Activity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.view.setPadding
import androidx.recyclerview.widget.RecyclerView
import com.google.android.flexbox.AlignSelf
import com.google.android.flexbox.FlexboxLayout
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.database.entities.Race
import fr.btytgat.odysseedesvagabonds.database.enums.RaceTagEnum

class RecyclerViewAdapter(private val activity: Activity, private val itemList: List<Any>, private val layout: Int) : RecyclerView.Adapter<RecyclerViewAdapter.MyViewHolder>() {


    var onItemClick: ((Any) -> Unit)? = null


    inner class MyViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val ivIcon: ImageView = itemView.findViewById(R.id.iv_icon)
        val tvTitle: TextView = itemView.findViewById(R.id.tv_title)
        val tvDescription: TextView = itemView.findViewById(R.id.tv_description)
        val llDv: LinearLayout = itemView.findViewById(R.id.ll_dv)
        val llDm: LinearLayout = itemView.findViewById(R.id.ll_dm)
        val tvDv: TextView = itemView.findViewById(R.id.tv_dv)
        val tvDm: TextView = itemView.findViewById(R.id.tv_dm)
        val fblTags: FlexboxLayout = itemView.findViewById(R.id.fbl_tags)

        init {
            itemView.setOnClickListener{
                onItemClick?.invoke(itemList[adapterPosition])
            }
        }

    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(layout, parent, false)
        return MyViewHolder(view)
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        val item = itemList[position]
        if(item is Race){
            item.let {
                holder.ivIcon.setImageResource(R.drawable.ic_nain)
                holder.tvTitle.text = it._info?.name
                holder.tvDescription.text = it._info?.description
                holder.fblTags.removeAllViews()
                it.tags.forEach {
                    val tagEnum = RaceTagEnum.valueOf(it)
                    val tagView = TextView(activity).apply {
                        text = tagEnum.label
                        background = activity.resources.getDrawable(R.drawable.card_rounded, null)
                        backgroundTintList = activity.resources.getColorStateList(tagEnum.color, null)
                    }
                    tagView.setTextColor(activity.getColor(R.color.white))
                    val scale: Float = activity.resources.displayMetrics.density
                    val dpAsPixels = (5 * scale + 0.5f) as Float
                    tagView.setPadding(dpAsPixels.toInt())
                    val params = FlexboxLayout.LayoutParams(
                        FlexboxLayout.LayoutParams.WRAP_CONTENT,
                        FlexboxLayout.LayoutParams.WRAP_CONTENT
                    ).apply {
                        alignSelf = AlignSelf.CENTER
                    }
                    tagView.layoutParams = params
                    holder.fblTags.addView(tagView)

                }

            }

        }
    }

    override fun getItemCount() = itemList.size
}
