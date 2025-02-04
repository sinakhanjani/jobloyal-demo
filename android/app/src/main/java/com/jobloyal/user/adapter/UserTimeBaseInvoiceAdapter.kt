package com.jobloyal.user.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.databinding.ItemUserCategoryBinding
import com.jobloyal.databinding.UserTimeBaseInvoiceBinding
import com.jobloyal.jobber.model.category.CategoryModel
import com.jobloyal.user.model.jobber.page.JobPageService
import com.jobloyal.utility.getFranc
import java.util.*

class UserTimeBaseInvoiceAdapter (val items : Array<JobPageService>?) : RecyclerView.Adapter<UserTimeBaseInvoiceAdapter.MyViewHolder>() {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val binding = UserTimeBaseInvoiceBinding.inflate(LayoutInflater.from(parent.context),parent, false)
        return MyViewHolder(binding)
    }

    override fun getItemCount(): Int {
        return items?.size ?: 0
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {

        holder.binding.titleOfService.text = items?.get(position)?.title?.capitalize(Locale.getDefault())
        holder.binding.price.text = "${items?.get(position)?.price.getFranc()} CHF"
        holder.binding.price.isSelected = true
    }

    inner class MyViewHolder (val binding: UserTimeBaseInvoiceBinding) : RecyclerView.ViewHolder(binding.root)
}