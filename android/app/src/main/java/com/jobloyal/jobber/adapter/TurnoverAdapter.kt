package com.jobloyal.jobber.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemSearchServiceBinding
import com.jobloyal.databinding.ItemTurnoverBinding
import com.jobloyal.jobber.model.turnover.TurnoverModel
import com.jobloyal.utility.dateToFormat

class TurnoverAdapter  (val items : List<TurnoverModel>,val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<TurnoverAdapter.MyViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val binding = ItemTurnoverBinding.inflate(LayoutInflater.from(parent.context),parent, false)
        return MyViewHolder(binding)
    }

    override fun getItemCount(): Int {
        return items.size
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        val item = items[position]
        holder.binding.amount.text = item.amount
        holder.binding.date.text = item.createdAt?.dateToFormat("MM/dd/YY")
        holder.binding.statusImage.setImageResource(if (item.status == "pending" || item.status == "created") R.drawable.ic_turnover_pending_status else if(item.status == "success") R.drawable.ic_turnover_status_success else R.drawable.ic_turnover_failed_status)
    }

    inner class MyViewHolder (val binding: ItemTurnoverBinding) : RecyclerView.ViewHolder(binding.root)
}