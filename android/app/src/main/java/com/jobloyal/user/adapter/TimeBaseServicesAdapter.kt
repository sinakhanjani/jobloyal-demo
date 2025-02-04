package com.jobloyal.user.adapter

import android.graphics.Color
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.databinding.ItemUserNumericServiceSelectionBinding
import com.jobloyal.databinding.ItemUserTimeBaseServiceBinding
import com.jobloyal.user.model.jobber.page.JobPageService
import com.jobloyal.utility.getFranc

class TimeBaseServicesAdapter(val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<TimeBaseServicesAdapter.MyViewHolder>() {

    var items : List<JobPageService>? = null
    fun replace (items : List<JobPageService>) {
       this.items = items
        notifyDataSetChanged()
    }
    fun getModel (position: Int) = items?.get(position)
    private val gray = Color.parseColor("#FAFAFA")
    private val white = Color.parseColor("#FFFFFF")
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val binding = ItemUserTimeBaseServiceBinding.inflate(LayoutInflater.from(parent.context),parent, false)
        return MyViewHolder(binding)
    }

    override fun getItemCount(): Int {
        return items?.size ?: 0
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        val service = items?.get(position)!!
        holder.binding.title.text = service.title?.capitalize()
        holder.binding.price.text = service.price.getFranc()
        holder.binding.background.setBackgroundColor(if (position % 2 == 0) white else gray)
        holder.itemView.setOnClickListener {
            click(position)
        }
    }

    inner class MyViewHolder (val binding: ItemUserTimeBaseServiceBinding) : RecyclerView.ViewHolder(binding.root)
}