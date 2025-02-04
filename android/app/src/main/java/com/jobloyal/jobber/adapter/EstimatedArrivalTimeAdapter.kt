package com.jobloyal.jobber.adapter

import android.graphics.Color
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemEstimatedTimeBinding
import com.jobloyal.utility.dp
import com.jobloyal.utility.getWidowsPhoneSize
import com.jobloyal.utility.px


class EstimatedArrivalTimeAdapter(activity: FragmentActivity, val click: ((time: Int) -> Unit)) : RecyclerView.Adapter<EstimatedArrivalTimeAdapter.MyViewHolder>() {

    val times = listOf(5, 10, 15, 30, 45, 60)
    var active = -1;
    var width = -1;
    init {
        width = (activity.getWidowsPhoneSize().widthPixels - 30.px) / times.size
    }
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        val v: View = inflater.inflate(R.layout.item_estimated_time, parent, false)
        val params = ViewGroup.LayoutParams(
            width,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        v.layoutParams = params

        val binding = ItemEstimatedTimeBinding.bind(v)
        return MyViewHolder(binding)
    }

    override fun getItemCount(): Int {
        return times.size
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        holder.itemView.layoutParams
        holder.binding.text.text = times[position].toString()
        if (position == active) {
            holder.binding.text.setTextSize(TypedValue.COMPLEX_UNIT_SP, 35f)
            holder.binding.text.setTextColor(
                ContextCompat.getColor(
                    holder.itemView.context,
                    R.color.blue_700
                )
            )
        }
        else {
            holder.binding.text.setTextSize(TypedValue.COMPLEX_UNIT_SP, 25f)
            holder.binding.text.setTextColor(Color.parseColor("#4E4E4E"))

        }
        holder.itemView.setOnClickListener {
            active = position
            click(times[position])
            notifyDataSetChanged()
        }
    }

    inner class MyViewHolder(val binding: ItemEstimatedTimeBinding) : RecyclerView.ViewHolder(
        binding.root
    )
}