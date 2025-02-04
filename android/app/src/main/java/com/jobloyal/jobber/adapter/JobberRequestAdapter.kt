package com.jobloyal.jobber.adapter

import android.app.Activity
import android.content.Context
import android.graphics.Point
import android.util.DisplayMetrics
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.progressindicator.LinearProgressIndicator
import com.jobloyal.R
import com.jobloyal.databinding.ItemJobberRequestBinding
import com.jobloyal.jobber.main.requests.JobberRequestsFragment
import com.jobloyal.jobber.model.request.RequestModel
import com.jobloyal.utility.*
import com.vks.RoundButton
import io.reactivex.disposables.Disposable
import java.util.concurrent.TimeUnit


class JobberRequestAdapter(val context : FragmentActivity, val click: ((position: Int, accept : Boolean) -> Unit)) : RecyclerView.Adapter<JobberRequestAdapter.ItemViewHolder>() {

    val requests = arrayListOf<RequestModel>()
    var requestLifeTime = 0
    fun append (request : RequestModel) {
        this.requests.add(request)
        notifyItemInserted(this.requests.size - 1)
    }
    fun append (request : List<RequestModel>) {
        if (request.size == 1) {
            append(request.first())
            return ;
        }
        this.requests.addAll(request)
        notifyItemInserted(this.requests.size - 1)
    }
    fun insert (requests : List<RequestModel>) {
        this.requests.clear()
        this.requests.addAll(requests)
        notifyDataSetChanged()
    }
    fun getCountItem() = requests.size
    fun remove (id : String) {
        val indexDelete = requests.indexOfFirst { it.id == id }
        requests.removeAt(indexDelete)
        notifyItemRemoved(indexDelete)
    }
    fun getId (position: Int) = requests.getOrNull(position)?.id
    fun getRequest (position: Int) = requests.getOrNull(position)
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): JobberRequestAdapter.ItemViewHolder {
        return ItemViewHolder(ItemCell(parent.context).apply { inflate() })
    }

    override fun getItemCount(): Int {
        return requests.size
    }

    override fun onViewRecycled(holder: ItemViewHolder) {
        super.onViewRecycled(holder)
        (holder.itemView as ItemCell).disposable?.dispose()
    }

    override fun onBindViewHolder(holder: JobberRequestAdapter.ItemViewHolder, position: Int) {
        setUpSmallViewHolder(holder,position)
    }

    inner class ItemViewHolder internal constructor(view: ViewGroup) :
        RecyclerView.ViewHolder(view)

    private inner class ItemCell(context: Context) : AsyncCell(context, LayoutParams.MATCH_PARENT) {
        var disposable : Disposable? = null
        var binding: ItemJobberRequestBinding? = null
        override val layoutId = R.layout.item_jobber_request

        override fun createDataBindingView(view: View): View? {
            binding = ItemJobberRequestBinding.bind(view)
            return binding?.root
        }
    }

    private fun setUpSmallViewHolder(
        holder: ItemViewHolder,
        position: Int
    ) {
        (holder.itemView as ItemCell).bindWhenInflated {
            val req = requests[position]
            holder.itemView.binding?.requestTitleTV?.text = req.job_title
            holder.itemView.binding?.distanceTV?.text = req.distance.getMeter()
            holder.itemView.binding?.addressTv?.text = req.address
            holder.itemView.binding?.viewFlipper?.displayedChild = if (req.services?.getOrNull(0)?.unit == null) 0 else 1
            holder.itemView.binding?.totalPrice?.text = req.price?.replace(',', '.')?.split(".")?.getOrNull(0).toString()
            val cent = req.price?.replace(',', '.')?.split(".")?.getOrNull(1).toString()
            holder.itemView.binding?.totalCentPrice?.text = ".$cent"

            holder.itemView.binding?.acceptBtn?.setOnClickListener { click(position, true) }
            holder.itemView.binding?.rejectBtn?.setOnClickListener { click(position, false) }

            holder.itemView.binding?.recyclerView?.layoutManager = LinearLayoutManager(holder.itemView.context)
            holder.itemView.binding?.acceptBtn?.text = context.resources.getString(R.string.next)
            holder.itemView.binding?.recyclerView?.adapter = JobberServiceInRequestsAdapter(req.services) {
                holder.itemView.binding?.acceptBtn?.text = context.resources.getString(R.string.acceptWithPrice, req.services?.filter { it.selected }?.sumByDouble { it.price ?: 0.0 }?.toString())
            }
            val past = requestLifeTime - (req.remaining_time?.toInt() ?: 0)
            fun setTime (time : Int) {
                if ((time - past) <= 1) {
                    holder.itemView.disposable?.dispose()
                    remove(req.id!!)
                }
                holder.itemView.binding?.rejectBtn?.text = String.format(context.resources.getString(R.string.rejectWithTimer), (time - past).toHourAndMin())
                holder.itemView.binding?.progressTime?.progress = ((time - past) * 1000)/(requestLifeTime)
            }
            holder.itemView.binding?.rejectBtn?.setText(R.string.reject)
            holder.itemView.disposable = JobberRequestsFragment.subscription?.subscribe ({
                setTime(it)

            }, {
                Log.i("ERRORRRR", "message: ${it.message}")
            })
        }
    }


}