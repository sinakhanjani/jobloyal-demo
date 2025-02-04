package com.jobloyal.user.adapter

import android.graphics.Color
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemUserNumericServiceSelectionBinding
import com.jobloyal.databinding.ItemUserSearchServiceBinding
import com.jobloyal.user.model.jobber.page.JobPageService
import com.jobloyal.utility.getFranc

class NumericServicesAdapter (val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<NumericServicesAdapter.MyViewHolder>() {

    var items : List<JobPageService>? = null
    fun replace (items : List<JobPageService>) {
        this.items = items
        notifyDataSetChanged()
    }
    fun getAllSelectedServices () =
        items?.filter { it.selected }

    fun getModel (position: Int) = items?.get(position)
    private val gray = Color.parseColor("#FAFAFA")
    private val white = Color.parseColor("#FFFFFF")

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val binding = ItemUserNumericServiceSelectionBinding.inflate(LayoutInflater.from(parent.context),parent, false)
        return MyViewHolder(binding)
    }

    override fun getItemCount(): Int {
        return items?.size ?: 0
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        val service = items?.get(position)!!
        holder.binding.background.setBackgroundColor(if (position % 2 == 0) white else gray)
        holder.binding.price.text = service.price.getFranc()
        holder.binding.title.text = "${service.title?.capitalize()} (per ${service.unit?.trim()})"
        holder.binding.check.setImageResource(if (!service.selected) R.drawable.ic_unchecked else R.drawable.ic_checked)
        holder.itemView.setOnClickListener {
            service.selected = !service.selected
            notifyItemChanged(position)
            click(position)
        }
    }

    inner class MyViewHolder (val binding: ItemUserNumericServiceSelectionBinding) : RecyclerView.ViewHolder(binding.root)
}