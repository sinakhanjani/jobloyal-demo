package com.jobloyal.jobber.adapter

import android.app.Activity
import android.content.Context
import android.graphics.Point
import android.util.DisplayMetrics
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemJobberJobsBinding
import com.jobloyal.databinding.ItemJobberServiceInJobBinding
import com.jobloyal.jobber.model.MyJobModel
import com.jobloyal.utility.dateToFormat
import com.jobloyal.utility.dp
import com.jobloyal.utility.px


class JobberJobAdapter(context : Context, val click: ((position: Int, online: Boolean?) -> Unit)) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private var itemWidth = 0
    var jobs: List<MyJobModel>? = null
    private var activeColor : Int
    private var inactiveColor : Int
    init {
        activeColor = ContextCompat.getColor(context,R.color.blue_700)
        inactiveColor = ContextCompat.getColor(context,R.color.offlineButton)
    }
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == 0) {
            MyViewHolder(ItemJobberJobsBinding.inflate(LayoutInflater.from(parent.context), parent, false))
        } else {
            val view =
                LayoutInflater.from(parent.context).inflate(R.layout.item_add_job, parent, false)
            AddNewJobViewHolder(view)
        }
    }

    override fun getItemCount(): Int {
        return (jobs?.size ?: 0) + 1
    }

    fun addCardPosition () = (jobs?.size ?: 0)
    fun getIdOfJob (position : Int) = jobs?.getOrNull(position)?.job_id
    fun getModelOfJob (position : Int) = jobs?.getOrNull(position)
    fun getTitleOfJob (position : Int) = jobs?.getOrNull(position)?.title
    fun insertJobs (newJobs : List<MyJobModel>) {
        jobs = newJobs
        notifyDataSetChanged()
    }

    override fun onAttachedToRecyclerView(recyclerView: RecyclerView) {
        super.onAttachedToRecyclerView(recyclerView)
        val context = recyclerView.context as Activity
        val outMetrics = DisplayMetrics()
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            val display = context.display
            display?.getRealMetrics(outMetrics)
        } else {
            @Suppress("DEPRECATION")
            val display = context.windowManager.defaultDisplay
            @Suppress("DEPRECATION")
            display.getMetrics(outMetrics)
        }
        itemWidth = outMetrics.widthPixels - 40.px
    }


    override fun getItemViewType(position: Int): Int {
        return if (position == jobs?.size ?: 0) 1 else 0
    }
    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val params = ViewGroup.LayoutParams(
            itemWidth,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        holder.itemView.layoutParams = params

        if (getItemViewType(position) == 0) {
            (holder as? MyViewHolder)?.apply {

                fun switchButton (online : Boolean) {
                    if (online) {
                        binding.avilableTag.visibility = View.VISIBLE
                        binding.offlineBtn.apply {
                            alpha = 1f
                            isEnabled = true
                        }
                        binding.onlineBtn.apply {
                            alpha = 0.6f
                            isEnabled = false
                        }
                    }
                    else {
                        binding.avilableTag.visibility = View.INVISIBLE
                        binding.onlineBtn.apply {
                            alpha = 1f
                            isEnabled = true
                        }
                        binding.offlineBtn.apply {
                            alpha = 0.6f
                            isEnabled = false
                        }
                    }
                }
                val job = jobs?.getOrNull(position)
                holder.itemView.setOnClickListener {
                    click(position, null)
                }
                binding.onlineBtn.setOnClickListener {
                    if (job?.status == null || job.status == "offline")
                        click(position, true)
                }
                binding.offlineBtn.setOnClickListener {
                    if (job?.status != null && job.status == "online")
                        click(position, false)
                }
                binding.jobTitleTv.text = job?.title
                binding.serviceCountTV.text = itemView.context.getString(R.string.nServices, job?.service_conut ?: "0")
                if (job?.status == null) {
                    binding.timeline.setText(R.string.notBeenOnlineToday)
                    switchButton(false)
                }
                else {
                    if (job.status == "online") {
                        binding.timeline.text = itemView.context.getString(R.string.todayOnlineAt , job.status_created_time?.dateToFormat("HH:mm"))
                        switchButton(true)
                    }
                     else {
                        binding.timeline.text = itemView.context.getString(R.string.lastOnlineAt , job.status_created_time?.dateToFormat("HH:mm"))
                        switchButton(false)
                    }
                }


            }
        }
    }

    inner class MyViewHolder(val binding: ItemJobberJobsBinding) : RecyclerView.ViewHolder(binding.root)

    inner class AddNewJobViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

        init {
            itemView.setOnClickListener {
                click(adapterPosition, false)
            }
        }
    }
}