package com.jobloyal.jobber.adapter

import android.graphics.Color
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemProfileBinding
import com.jobloyal.databinding.ItemReportBinding

class ProfileAdapter (val list : List<String>,val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<ProfileAdapter.MyViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val binding = ItemProfileBinding.inflate(LayoutInflater.from(parent.context),parent, false)
        return MyViewHolder(binding)
    }

    override fun getItemCount(): Int {
        return list.size
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        holder.itemView.setOnClickListener {
            click(position)
        }
        holder.binding.title.text = list[position]
    }

    inner class MyViewHolder (val binding: ItemProfileBinding) : RecyclerView.ViewHolder(binding.root)
}