package com.jobloyal.jobber.adapter

import android.graphics.Color
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemMessageTicketBinding
import com.jobloyal.databinding.ItemReportBinding
import com.jobloyal.jobber.model.message.MessageModel
import com.jobloyal.utility.dateToFormat

class MessageAdapter (val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<MessageAdapter.MyViewHolder>() {

    var messages : ArrayList<MessageModel> = arrayListOf()

    fun addMessages(message : List<MessageModel>) {
        this.messages.clear()
        this.messages.addAll(message)
        notifyDataSetChanged()
    }
    fun getMessage (position: Int) = messages.get(position)
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val binding = ItemMessageTicketBinding.inflate(LayoutInflater.from(parent.context),parent, false)
        return MyViewHolder(binding)
    }

    override fun getItemCount(): Int {
        return messages.size
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        holder.binding.subjectTv.text = messages.getOrNull(position)?.subject
        holder.binding.dateTv.text = messages.getOrNull(position)?.createdAt?.dateToFormat("dd-MM-yyyy")
        holder.itemView.setOnClickListener {
            click(position)
        }
    }

    inner class MyViewHolder (val binding: ItemMessageTicketBinding) : RecyclerView.ViewHolder(binding.root)
}