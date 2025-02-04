package com.jobloyal.user.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemReservedTicketBinding
import com.jobloyal.databinding.ItemUserCategoryBinding
import com.jobloyal.jobber.model.category.CategoryModel
import com.jobloyal.user.model.profile.reserved.ReservedServicesModel
import com.jobloyal.utility.dateToFormat
import com.jobloyal.utility.toHourAndMin
import java.util.*
import kotlin.collections.ArrayList

class ReservedReportAdapter (val reserved : Boolean) : RecyclerView.Adapter<ReservedReportAdapter.MyViewHolder>() {
    var items : ArrayList<ReservedServicesModel> = arrayListOf()
    fun replace (services : List<ReservedServicesModel>) {
        items.clear()
        items.addAll(services)
        notifyDataSetChanged()
    }
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val binding = ItemReservedTicketBinding.inflate(LayoutInflater.from(parent.context),parent, false)
        return MyViewHolder(binding)
    }

    override fun getItemCount(): Int {
        return items.size
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        val service = items[position]
        holder.binding.byTV.text = if (reserved) service.jobber_name else service.canceled_by
        if (!reserved) holder.binding.titleOfBYTV.text = "canceled by:"
        holder.binding.titleOfService.text = service.title?.capitalize()
        holder.binding.price.text = service.price
        holder.binding.total.text = service.total_price
        holder.binding.reservedDateTV.text = service.reserved_at?.dateToFormat("HH:mm dd/MM/yy")
        holder.binding.unitTv.text = "(${service.unit ?: holder.itemView.context.getString(R.string.hour)})"
        holder.binding.countTV.text = if (service.unit == null) service.count?.toHourAndMin() ?: "0:0" else service.count?.toString()
    }

    inner class MyViewHolder (val binding: ItemReservedTicketBinding) : RecyclerView.ViewHolder(binding.root)
}