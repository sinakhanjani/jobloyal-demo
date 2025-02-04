package com.jobloyal.user.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.databinding.ItemMessageTicketBinding
import com.jobloyal.databinding.ItemUserCategoryBinding
import com.jobloyal.jobber.model.category.CategoryModel
import java.util.*

class UserCategoryAdapter (val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<UserCategoryAdapter.MyViewHolder>() {
    var items : List<CategoryModel>? = null
    fun replace (categories : List<CategoryModel>) {
        items = categories
        notifyDataSetChanged()
    }
    fun getChildOf(position: Int) = items?.getOrNull(position)?.children
    fun getTitleOf(position: Int) = items?.getOrNull(position)?.title
    fun getIdOf(position: Int) = items?.getOrNull(position)?.id
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val binding = ItemUserCategoryBinding.inflate(LayoutInflater.from(parent.context),parent, false)
        return MyViewHolder(binding)
    }

    override fun getItemCount(): Int {
        return items?.size ?: 0
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {

        holder.binding.title.text = items?.get(position)?.title?.capitalize(Locale.getDefault())
        holder.itemView.setOnClickListener {
            click(position)
        }
    }

    inner class MyViewHolder (val binding: ItemUserCategoryBinding) : RecyclerView.ViewHolder(binding.root)
}