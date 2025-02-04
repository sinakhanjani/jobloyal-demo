package com.jobloyal.jobber.adapter

import android.graphics.Color
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemReportBinding
import com.jobloyal.databinding.ItemSearchServiceBinding
import com.jobloyal.databinding.LoadingItemBinding
import com.jobloyal.jobber.model.report.SingleReportModel
import com.jobloyal.utility.dateToFormat

class JobberReportAdapter (val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    val services = arrayListOf<SingleReportModel>()

    fun append (service : List<SingleReportModel>) {
        this.services.addAll(service)
        notifyDataSetChanged()
    }

    fun showLoading() {
        if (services.isNotEmpty() && services.last().id != "Loading") {
            services.add(SingleReportModel("Loading"))
            notifyItemInserted(services.size - 1)
        }
    }

    fun hideLoading() {
        if (services.isNotEmpty() && services.last().address == "Loading") {
            services.removeAt(services.size - 1)
            notifyItemRemoved(services.size)
        }
    }

    fun getService (position: Int) = services.getOrNull(position)

    override fun getItemViewType(position: Int): Int {
        return if (services[position].address == "Loading") 1 else 0
    }
    private val secondColor = Color.parseColor("#2BD7D7D7")

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        if (viewType == 0) {
            val binding =
                ItemReportBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return MyViewHolder(binding)
        }
        else {
            val binding =
                LoadingItemBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return LoadingHolder(binding)
        }
    }

    override fun getItemCount(): Int {
        return services.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is MyViewHolder) {
            holder.itemView.setOnClickListener {
                click(position)
            }
            val service = services.getOrNull(position) ?: return

            holder.itemView.setBackgroundColor(if (position % 2 == 0) Color.TRANSPARENT else secondColor)
            holder.binding.tag.delegate.setBackgroundColor(
                ContextCompat.getColor(
                    holder.itemView.context,
                    if (service.tag == "accepted") R.color.blue_700 else R.color.grayBlack
                )
            )
            if (service.tag == "accepted") holder.binding.tag.setText(R.string.accepted)
            else holder.binding.tag.text = service.tag
            holder.binding.address.text = service.address
            holder.binding.titleOfJob.text = service.job_title?.capitalize()
            holder.binding.date.text = service.created_at?.dateToFormat("yy/MM/dd HH:mm")
        }
    }

    inner class MyViewHolder (val binding: ItemReportBinding) : RecyclerView.ViewHolder(binding.root)
    inner class LoadingHolder (val binding: LoadingItemBinding) : RecyclerView.ViewHolder(binding.root)
}