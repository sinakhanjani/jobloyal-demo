package com.jobloyal.jobber.estimate

import android.annotation.SuppressLint
import android.content.Intent
import android.content.res.Resources
import android.net.Uri
import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.findNavController
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MapStyleOptions
import com.jobloyal.R
import com.jobloyal.databinding.EstimateErivalTimeFragmentBinding
import com.jobloyal.databinding.JobPageFragmentBinding
import com.jobloyal.databinding.JobberRequestsFragmentBinding
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.jobber.adapter.EstimatedArrivalTimeAdapter
import com.jobloyal.jobber.adapter.JobberAcceptedServices
import com.jobloyal.utility.*

class EstimatedArrivalTimeFragment : RxFragment<EstimateErivalTimeViewModel>(), OnMapReadyCallback {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private var _binding: EstimateErivalTimeFragmentBinding? = null
    private val binding get() = _binding!!
    private val args : EstimatedArrivalTimeFragmentArgs by navArgs()

    @SuppressLint("SetTextI18n")
    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(EstimateErivalTimeViewModel::class.java)
        _binding = EstimateErivalTimeFragmentBinding.inflate(inflater, container, false)

        val isTimeBase = args.request?.services?.getOrNull(0)?.unit == null
        viewModel.requestID = args.request?.id
        val accepted = if (isTimeBase) args.request?.services else args.request?.services?.filter { it.selected }
        viewModel.acceptedIds = accepted?.map { it.id ?: 0 }
        binding.jobTitle.text = args.request?.job_title
        val totalAccepted = accepted?.sumByDouble { it.price ?: 0.0 }
        binding.viewFlipperOfTimeBase.displayedChild = if (isTimeBase) 0 else 1

        binding.totalPrice.text = totalAccepted.getFranc().replace(',', '.').split(".")[0]
        binding.totalCentPrice.text = "." + totalAccepted.getFranc().replace(',', '.').split(".")[1]
        binding.address.text = args.request?.address
        binding.distance.text = args.request?.distance?.getMeter()
        binding.routing.text = getString(R.string.routingTO, args.request?.address)
        binding.acceptedServicesRecyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.acceptedServicesRecyclerView.adapter = JobberAcceptedServices(accepted, !isTimeBase) {}
        binding.acceptedServicesRecyclerView.isNestedScrollingEnabled = false

        binding.estimatedRecyclerView.layoutManager = LinearLayoutManager(requireContext(), RecyclerView.HORIZONTAL, false)
        binding.estimatedRecyclerView.adapter = EstimatedArrivalTimeAdapter(requireActivity()) {
            viewModel.arrivalTime = it
        }
        binding.estimatedRecyclerView.isNestedScrollingEnabled = false

        binding.backBtn.setOnClickListener { findNavController().popBackStack() }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel.getLocationOfRequest()
        addToDisposableBag(viewModel.location.subscribe {
            binding.mapClicked.setOnClickListener {view ->
                val gmmIntentUri = Uri.parse("geo:${it.latitude},${it.longitude}");
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
        })

        viewModel.navigate.observe(viewLifecycleOwner) {
            if (it == 1) {
//                addToDisposableBag((activity as? JobberActivity)?.viewModel?.lastRequest?.subscribe { if (it.data != null) findNavController().navigateUp() })
                (activity as? JobberActivity)?.viewModel?.getLastRequestDetail()
                viewModel.navigate.value = 0
            }
        }

        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.viewFlipper.displayedChild = if (it) 1 else 0
        }

        binding.sendButton.setOnClickListener {
            if (viewModel.arrivalTime != null) {
                viewModel.accept()
            }
            else {
                activity?.toast(R.string.chooseArrivalTime)
            }
        }
    }

    override fun onMapReady(googleMap: GoogleMap) {
        googleMap.setOnMapLoadedCallback {

        }
        googleMap.uiSettings.isCompassEnabled = false;
        googleMap.uiSettings.isScrollGesturesEnabled = false;
        googleMap.uiSettings.isZoomGesturesEnabled = false;
        if (viewModel.location.value?.latitude != null && viewModel.location.value?.longitude != null) {
            googleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(viewModel.location.value!!.latitude!!, viewModel.location.value!!.longitude!!), 15f))
        }

    }

}