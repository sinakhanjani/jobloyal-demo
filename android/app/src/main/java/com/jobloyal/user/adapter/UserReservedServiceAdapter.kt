package com.jobloyal.user.adapter

import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemReservedServiceBinding
import com.jobloyal.user.model.jobber.page.request.RequestedService
import com.jobloyal.utility.getFranc

class UserReservedServiceAdapter(val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<UserReservedServiceAdapter.MyViewHolder>() {

    var items : List<RequestedService> = listOf()
    fun replace (items : List<RequestedService>) {
        this.items = items
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val binding = ItemReservedServiceBinding.inflate(LayoutInflater.from(parent.context),parent, false)
        return MyViewHolder(binding)
    }

    override fun getItemCount(): Int {
        return items.size
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        val service = items.get(position)
        holder.binding.titleOfService.text = service.title?.capitalize()
        holder.binding.price.text = service.price.getFranc()
        holder.binding.total.text = service.total_price.getFranc()
        holder.binding.countTV.text = (service.count ?: 0).toString()
        holder.binding.unitTv.text = "(${service.unit})"
        holder.binding.paid.visibility = if (service.is_paid == true) View.VISIBLE else View.GONE
        holder.binding.tag.text = if (service.accepted == true) "Accepted" else "Rejected"
        holder.binding.tag.delegate.setBackgroundColor(if (service.accepted == true) ContextCompat.getColor(holder.itemView.context,  R.color.blue_500) else ContextCompat.getColor(holder.itemView.context,  R.color.error))
        if (service.unit == null) {
            holder.binding.countTV.text = service.price.getFranc()
            holder.binding.unitTv.text ="(CHF per hour)"
            holder.binding.totalBox.visibility = View.GONE
        }
    }

    inner class MyViewHolder (val binding: ItemReservedServiceBinding) : RecyclerView.ViewHolder(binding.root)
}