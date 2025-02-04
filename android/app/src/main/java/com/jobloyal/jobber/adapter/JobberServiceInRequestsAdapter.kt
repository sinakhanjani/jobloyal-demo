package com.jobloyal.jobber.adapter

import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemJobberRequestBinding
import com.jobloyal.databinding.ItemJobberRequestServiceCheckBinding
import com.jobloyal.jobber.main.requests.JobberRequestsFragment
import com.jobloyal.jobber.model.request.Service
import com.jobloyal.utility.getFranc
import com.jobloyal.utility.getMeter

class JobberServiceInRequestsAdapter (val services : List<Service>?,val click : ((position: Int) -> Unit)) : RecyclerView.Adapter<JobberServiceInRequestsAdapter.ItemViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemViewHolder {
        return ItemViewHolder(ItemCell(parent.context).apply { inflate() })
    }

    override fun getItemCount(): Int {
        return services?.size ?: 0
    }


    override fun onBindViewHolder(holder: ItemViewHolder, position: Int) {
        setUpSmallViewHolder(holder,position)
    }
    inner class ItemViewHolder internal constructor(view: ViewGroup) :
        RecyclerView.ViewHolder(view)

    private inner class ItemCell(context: Context) : AsyncCell(context, LayoutParams.WRAP_CONTENT) {
        var binding: ItemJobberRequestServiceCheckBinding? = null
        override val layoutId = R.layout.item_jobber_request_service_check
        override fun createDataBindingView(view: View): View? {
            binding = ItemJobberRequestServiceCheckBinding.bind(view)
            return binding?.root
        }
    }

    private fun setUpSmallViewHolder(
        holder: JobberServiceInRequestsAdapter.ItemViewHolder,
        position: Int
    ) {
        (holder.itemView as JobberServiceInRequestsAdapter.ItemCell).bindWhenInflated {
            val service = services!!.get(index = position)
            holder.itemView.binding?.check?.setImageResource(if (service.selected) R.drawable.ic_checked else R.drawable.ic_unchecked)
            holder.itemView.binding?.unitOfService?.text = service.unit ?: holder.itemView.context.getString(R.string.hour)
            holder.itemView.binding?.priceOfService?.text = service.price.getFranc()
            holder.itemView.binding?.titleOfService?.text = service.title?.capitalize()
            if (service.unit != null) {
                holder.itemView.binding?.countTv?.text =  service.count?.toString()
                holder.itemView.setOnClickListener {
                    service.selected = !service.selected
                    holder.itemView.binding?.check?.setImageResource(if (service.selected) R.drawable.ic_checked else R.drawable.ic_unchecked)
                    click(position)
                    //notifyItemChanged(position)
                }
            }
            else {
                holder.itemView.binding?.check?.visibility = View.GONE
            }
        }
    }

    inner class MyViewHolder (itemView: View) : RecyclerView.ViewHolder(itemView)
}