package com.jobloyal.user.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.databinding.ItemUserSearchServiceBinding
import com.jobloyal.user.model.service.SearchServiceModel

class UserSearchServiceResultAdapter (val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<UserSearchServiceResultAdapter.MyViewHolder>() {
    var items : List<SearchServiceModel> = listOf()

    fun replace (services : List<SearchServiceModel>) {
        items = services
        notifyDataSetChanged()
    }
    fun getModel (position: Int) = items.get(position)
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val binding = ItemUserSearchServiceBinding.inflate(LayoutInflater.from(parent.context),parent, false)
        return MyViewHolder(binding)
    }

    override fun getItemCount(): Int {
        return items.size
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        val service = items.get(position)
        holder.binding.serviceTitleTV.text = service.service_title?.capitalize()
        holder.binding.routeTV.text = "${service.category_title?.capitalize()} -> ${service.job_title?.capitalize()}"
        holder.itemView.setOnClickListener {
            click(position)
        }
    }

    inner class MyViewHolder (val binding: ItemUserSearchServiceBinding) : RecyclerView.ViewHolder(binding.root)
}