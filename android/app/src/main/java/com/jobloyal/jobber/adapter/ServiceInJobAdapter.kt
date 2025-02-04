package com.jobloyal.jobber.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemJobberServiceInJobBinding
import com.jobloyal.jobber.model.job_page.JobberService
import com.jobloyal.utility.getFranc

class ServiceInJobAdapter (val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<ServiceInJobAdapter.MyViewHolder>() {

    var services : ArrayList<JobberService> = arrayListOf()
    init {

    }
    fun replace (services : List<JobberService>) {
        this.services.clear()
        this.services.addAll(services)
        notifyDataSetChanged()
    }
    fun loadingMode (loading : Boolean, position: Int) {
        services?.get(position)?.loading = loading
        notifyItemChanged(position)
    }
    fun deleteItem (position: Int) {
        services.removeAt(position)
        notifyItemRemoved(position)
        notifyItemRangeChanged(position,services.size);
    }
    fun getID (position: Int) = services?.get(position)?.id
    fun getTitle (position: Int) = services?.get(position)?.title
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val view = ItemJobberServiceInJobBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return MyViewHolder(view)
    }

    override fun getItemCount(): Int {
        return services?.size ?: 0
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        services?.get(position)?.let {
            holder.binding.priceTv.text = it.price?.getFranc()
            holder.binding.titleOfService.text = it.title?.capitalize()
            holder.binding.unitTitle.text = it.unit ?: holder.itemView.context.getString(R.string.hour)
            holder.binding.loadingFlipper.displayedChild = if (!it.loading) 0 else 1
            holder.binding.delButton.setOnClickListener {
                click(position)
            }
        }
    }

    inner class MyViewHolder (val binding: ItemJobberServiceInJobBinding) : RecyclerView.ViewHolder(binding.root)
}