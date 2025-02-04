package com.jobloyal.jobber.adapter

import android.app.Activity
import android.graphics.Point
import android.util.DisplayMetrics
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.jobloyal.R
import com.jobloyal.databinding.ItemJobberCategoryBinding
import com.jobloyal.databinding.ItemUserInvoiceBinding
import com.jobloyal.jobber.model.category.CategoryModel
import com.jobloyal.utility.px
import java.util.*

class JobberCategoryAdapter (val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<JobberCategoryAdapter.MyViewHolder>() {

    var cats : List<CategoryModel>? = null

    fun replaceCategories (cats : List<CategoryModel>) {
        this.cats = cats
        notifyDataSetChanged()
    }

    fun replaceCategories (cats : Array<CategoryModel>) {
        this.cats = cats.toList()
        notifyDataSetChanged()
    }

    fun getChildOf (position: Int) : Array<CategoryModel>? {
        return cats?.get(position)?.children
    }

    fun getIdentifierOf (position: Int) = cats?.get(position)?.id

    fun getTitleOf (position: Int) = cats?.get(position)?.title

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        return MyViewHolder(ItemJobberCategoryBinding.inflate(LayoutInflater.from(parent.context), parent, false))
    }

    override fun getItemCount(): Int {
        return cats?.size ?: 0
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        holder.binding.titleTV.text = cats?.get(position)?.title?.capitalize(Locale.getDefault())
        holder.itemView.setOnClickListener {
            click(position)
        }
    }

    inner class MyViewHolder (val binding: ItemJobberCategoryBinding) : RecyclerView.ViewHolder(binding.root)
}