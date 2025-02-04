package com.jobloyal.user.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemCommentBinding
import com.jobloyal.databinding.LoadingItemBinding
import com.jobloyal.jobber.model.report.SingleReportModel
import com.jobloyal.user.model.jobber.page.Comment

class CommentAdapter() : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var items: ArrayList<Comment> = arrayListOf()

    fun replace(comments: List<Comment>) {
        this.items.clear()
        this.items.addAll(comments)
        notifyDataSetChanged()
    }

    fun showLoading() {
        if (items.isNotEmpty() && items.last().service_title != "Loading") {
            items.add(Comment(service_title = "Loading"))
            notifyItemInserted(items.size - 1)
        }
    }

    fun hideLoading() {
        if (items.isNotEmpty() && items.last().service_title == "Loading") {
            items.removeAt(items.size - 1)
            notifyItemRemoved(items.size)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return if (items[position].service_title == "Loading") 1 else 0
    }

    fun append(comments: List<Comment>) {
        this.items.addAll(comments)
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        if (viewType == 0) {
            val binding =
                ItemCommentBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return MyViewHolder(binding)
        } else {
            val binding =
                LoadingItemBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return LoadingHolder(binding)
        }
    }

    override fun getItemCount(): Int {
        return items.size ?: 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is MyViewHolder) {
            val comment = items[position]
            holder.binding.comment.text = comment.comment
            holder.binding.title.text = holder.itemView.context.getString(
                R.string.commentTitle,
                comment.service_title?.capitalize() ?: ""
            )
            holder.binding.ratebar.rating = comment.rate?.toFloat() ?: 0f
        }
    }

    inner class MyViewHolder(val binding: ItemCommentBinding) :
        RecyclerView.ViewHolder(binding.root)
    inner class LoadingHolder (val binding: LoadingItemBinding) : RecyclerView.ViewHolder(binding.root)

}