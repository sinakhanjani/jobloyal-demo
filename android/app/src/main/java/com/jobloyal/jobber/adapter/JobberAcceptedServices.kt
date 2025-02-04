package com.jobloyal.jobber.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemAcceptedServiceBinding
import com.jobloyal.jobber.model.request.Service
import com.jobloyal.utility.getFranc
import com.jobloyal.utility.getMeter

class JobberAcceptedServices (val services : List<Service>?, val hasCount : Boolean = false, val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<JobberAcceptedServices.MyViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        return MyViewHolder(ItemAcceptedServiceBinding.inflate(LayoutInflater.from(parent.context), parent, false ))
    }

    override fun getItemCount(): Int {
        return services?.size ?: 0
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        val service = services?.getOrNull(position)
        service?.let {
            holder.binding.titleTV.text = it.title?.capitalize()
            holder.binding.unitTitle.text = if (hasCount && it.unit == null) holder.itemView.context.getString(R.string.mins) else  it.unit ?: holder.itemView.context.getString(R.string.hour)
            holder.binding.priceTV.text = (it.price ?: it.total_price).getFranc()
            if (hasCount) {
                holder.binding.count.text = it.count?.toString()
            }
        }

    }

    inner class MyViewHolder (val binding : ItemAcceptedServiceBinding) : RecyclerView.ViewHolder(binding.root)
}