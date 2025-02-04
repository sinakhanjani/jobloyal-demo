package com.jobloyal.jobber.detail

import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.LatLng
import com.jobloyal.R
import com.jobloyal.databinding.RequestDetailFragmentBinding
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.jobber.adapter.JobberAcceptedServices
import com.jobloyal.jobber.main.requests.JobberRequestsViewModel
import com.jobloyal.utility.*
import java.util.*

class RequestDetailFragment : RxFragment<RequestDetailViewModel>(), OnMapReadyCallback {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private var _binding: RequestDetailFragmentBinding? = null
    private val binding get() = _binding!!
    private var _status = 0
    data class LocationCamera(val lat: Double, val long: Double)
    var locationCamera : LocationCamera? = null
    var status
    set(value) {
        _status = value;
        setStatus()
    }
    get() = _status


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(RequestDetailViewModel::class.java)
        _binding = RequestDetailFragmentBinding.inflate(inflater, container, false)

        if (JobberRequestsViewModel.backgroundImageMap == null) JobberRequestsViewModel.loadImage(
            requireContext(),
            false
        )
        binding.backgroundMap.setImageBitmap(JobberRequestsViewModel.backgroundImageMap)

        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.recyclerView.isNestedScrollingEnabled = false

        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.mainButtonFlipper.displayedChild = if (it) 1 else 0
        }

        viewModel.navigate.observe(viewLifecycleOwner) {
            (activity as? JobberActivity)?.viewModel?.getLastRequestDetail()
        }
        bindViews()
        binding.mainButton.setOnClickListener {
            when (status) {
                0 -> {
                    viewModel.arrive()
                }
                1 -> {
                    viewModel.start()
                }
                2 -> {
                    viewModel.finish()
                }
            }
        }
        binding.cancelButton.setOnLongClickListener {
            viewModel.cancel()
            true
        }
        binding.cancelButton.setOnClickListener {
            activity?.toast(R.string.holdToCancel, Toast.LENGTH_LONG)
        }

        return binding.root
    }

    fun bindViews () {
        (activity as? JobberActivity)?.viewModel?.lastRequest?.value?.data?.let {
            val state = viewModel.getEnumOfStatus(it.status ?: "accepted")
            binding.recyclerView.adapter  = JobberAcceptedServices(
                it.services,
                it.time_base == false
            ) {}
            if (state.getStepNumber() == 0) {
                locationCamera = LocationCamera(it.latitude ?: 0.0, it.longitude ?: 0.0)
            }
            it.status?.let {
                status = state.getStepNumber()
            }
            if (status == 0) {
                binding.timeTV.text = it.arrival_time?.dateToFormat("HH:mm")
            }
            else {
                binding.timeTV.text = it.updated_at?.dateToFormat("HH:mm")
            }
            binding.timeBaseViewFlipper.displayedChild = if (it.time_base == true) 0 else 1
            binding.priceTV.text = it.total
            binding.username.text = it.user?.name?.capitalize()
            binding.address.text = it.address
            binding.distance.text = it.distance?.getMeter()
            binding.askTitleTv.text = getString(
                R.string.askMr,
                it.user?.name?.toLowerCase()?.capitalize(Locale.getDefault())
            )
            binding.askContentTv.text = getString(
                R.string.askMrContent,
                it.user?.name?.toLowerCase()?.capitalize(Locale.getDefault())
            )
            binding.totalTime.text = it.total_time_interval?.toHourAndMin()
            binding.totalIncome.text = it.total
            binding.callButton.setOnClickListener {view ->
                val intent = Intent(Intent.ACTION_DIAL, Uri.fromParts("tel", it.user?.phone, null))
                startActivity(intent)
            }

        }
    }

    private fun setStatus () {
        binding.askText.visibility = View.GONE
        binding.customerName.visibility = View.VISIBLE
        binding.locationBox.visibility = View.VISIBLE
        binding.finishBox.visibility = View.GONE
        if (status == 0) {
            showMap()
        }
        when (status) {
            1 -> {
                binding.label.setText(R.string.arrivedTime)
                binding.locationBox.visibility = View.GONE
                binding.mainButton.setText(R.string.startService)
            }
            2 -> {
                binding.label.setText(R.string.startedTime)
                binding.locationBox.visibility = View.GONE
                binding.callButton.visibility = View.GONE
                binding.mainButton.setText(R.string.finishService)
                binding.mainButton.delegate.setBackgroundColor(Color.parseColor("#20A613"))
                binding.mainButton.delegate.setBackgroundPressColor(Color.parseColor("#118006"))
            }
            3 -> {
                binding.askText.visibility = View.VISIBLE
                binding.finishBox.visibility = View.VISIBLE
                binding.mainButtonFlipper.visibility = View.GONE
                binding.customerName.visibility = View.GONE
                binding.locationBox.visibility = View.GONE
                binding.staticsBox.visibility = View.GONE

            }
        }

    }

    private fun showMap () {
        binding.mapClicked.setOnClickListener {
            val gmmIntentUri = Uri.parse("geo:${locationCamera!!.lat},${locationCamera!!.long}");
            val mapIntent =  Intent(Intent.ACTION_VIEW, gmmIntentUri);
            startActivity(mapIntent)
        }
        Thread {
            try {
                val mf = SupportMapFragment.newInstance()
                childFragmentManager.beginTransaction()
                    .add(R.id.map, mf)
                    .commit()
                activity?.runOnUiThread {
                    mf.getMapAsync(this)
                }
            } catch (ignored: Exception) {
                Log.i("Ecexption", ignored.localizedMessage)
            }
        }.start()
    }

    override fun onMapReady(googleMap: GoogleMap) {
        googleMap.setOnMapLoadedCallback {

        }
        googleMap.uiSettings.isCompassEnabled = false;
        googleMap.uiSettings.isScrollGesturesEnabled = false;
        googleMap.uiSettings.isZoomGesturesEnabled = false;
        if (locationCamera != null) {
            googleMap.moveCamera(
                CameraUpdateFactory.newLatLngZoom(
                    LatLng(
                        locationCamera!!.lat,
                        locationCamera!!.long
                    ), 16f
                )
            )
        }

    }

}