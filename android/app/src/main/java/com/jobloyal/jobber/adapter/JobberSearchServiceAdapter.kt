package com.jobloyal.jobber.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.databinding.ItemSearchServiceBinding
import com.jobloyal.jobber.model.addservice.SearchServiceModel
import java.util.*

class JobberSearchServiceAdapter (val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<JobberSearchServiceAdapter.MyViewHolder>() {

    var services : List<SearchServiceModel>? = null
    var search : String? = null

    fun replaceServices (services : List<SearchServiceModel>, search : String? = null) {
        this.services = services
        this.search = search
        notifyDataSetChanged()
    }

    fun addSearchWordToEndList (search : String) {
        this.search = search
        notifyDataSetChanged()
    }
    fun getService (position: Int) =  services?.getOrNull(position)
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val binding = ItemSearchServiceBinding.inflate(LayoutInflater.from(parent.context),parent, false)
        return MyViewHolder(binding)
    }

    override fun getItemCount(): Int {
        return (services?.size ?: 0) + (if (search == null || search?.isEmpty() == true) 0 else 1)
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        holder.itemView.setOnClickListener {
            click(position)
        }
        if (position == services?.size ?: 0) {
            holder.binding.addIcon.visibility = View.VISIBLE
            holder.binding.titleOfService.text = search?.toLowerCase(Locale.getDefault())?.capitalize()
        }
        else {
            holder.binding.addIcon.visibility = View.GONE
            services?.get(position)?.let {
                holder.binding.titleOfService.text = it.title?.toLowerCase(Locale.getDefault())?.capitalize()
            }
        }
    }

    inner class MyViewHolder (val binding: ItemSearchServiceBinding) : RecyclerView.ViewHolder(binding.root)
}