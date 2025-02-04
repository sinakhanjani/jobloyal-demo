package com.jobloyal.user.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemJobberListBinding
import com.jobloyal.databinding.ItemUserCategoryBinding
import com.jobloyal.databinding.LoadingItemBinding
import com.jobloyal.user.model.jobber.NearJobberModel
import com.jobloyal.user.model.jobber.page.Comment
import com.jobloyal.utility.getMeter

class JobbersListAdapter (val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    val items : ArrayList<NearJobberModel> = arrayListOf()

    fun replace (items : List<NearJobberModel>)  {
        this.items.clear()
        this.items.addAll(items)
        notifyDataSetChanged()
    }

    fun getModel(position: Int) = items.get(position)
    fun append (items : List<NearJobberModel>)  {
        this.items.addAll(items)
        notifyDataSetChanged()
    }
    fun showLoading() {
        if (items.isNotEmpty() && items.last().avatar != "Loading") {
            items.add(NearJobberModel(avatar = "Loading"))
            notifyItemInserted(items.size - 1)
        }
    }

    fun hideLoading() {
        if (items.isNotEmpty() && items.last().avatar == "Loading") {
            items.removeAt(items.size - 1)
            notifyItemRemoved(items.size)
        }
    }
    override fun getItemViewType(position: Int): Int {
        return if (items[position].avatar == "Loading") 1 else 0
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        if (viewType == 0) {
            val binding =
                ItemJobberListBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return MyViewHolder(binding)
        }
        else {
            val binding =
                LoadingItemBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return LoadingHolder(binding)
        }
    }

    override fun getItemCount(): Int {
        return items.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is MyViewHolder) {
            val jobber = items.get(position)
            holder.binding.avatar.text = jobber.avatar
            holder.binding.jobberName.text = jobber.identifier
            holder.binding.workCountTv.text = holder.itemView.context.getString(
                R.string.workCount,
                (jobber.work_count ?: 0).toString()
            )
            holder.binding.distance.text = jobber.distance?.getMeter()
            holder.binding.rateTv.text = jobber.rate
            holder.binding.ratebar.rating = jobber.rate?.toFloat() ?: 0f
            holder.itemView.setOnClickListener {
                click(position)
            }
        }
    }

    inner class MyViewHolder (val binding: ItemJobberListBinding) : RecyclerView.ViewHolder(binding.root)
    inner class LoadingHolder (val binding: LoadingItemBinding) : RecyclerView.ViewHolder(binding.root)

}