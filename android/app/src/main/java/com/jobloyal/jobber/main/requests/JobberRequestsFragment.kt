package com.jobloyal.jobber.main.requests

import android.content.res.Resources
import android.os.Bundle
import android.os.CountDownTimer
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import com.google.android.gms.maps.*
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MapStyleOptions
import com.jobloyal.R
import com.jobloyal.databinding.JobberRequestsFragmentBinding
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.jobber.adapter.JobberRequestAdapter
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.startAlphaAnimation
import com.jobloyal.utility.toast
import com.yarolegovich.discretescrollview.transform.Pivot
import com.yarolegovich.discretescrollview.transform.ScaleTransformer
import io.reactivex.subjects.PublishSubject


class JobberRequestsFragment : RxFragment<JobberRequestsViewModel>(), OnMapReadyCallback {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private lateinit var adapter : JobberRequestAdapter
    private var _binding: JobberRequestsFragmentBinding? = null
    var googleMap: GoogleMap? = null
    var mMapView: SupportMapFragment? = null
    private val binding get() = _binding!!
    var countDownTimer : CountDownTimer? = null
    companion object {
        var subscription : PublishSubject<Int>? = PublishSubject.create()
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(JobberRequestsViewModel::class.java)
        _binding = JobberRequestsFragmentBinding.inflate(inflater, container, false)

        adapter = JobberRequestAdapter(requireActivity()) { position, accept ->
            if (accept) {
                adapter.getRequest(position)?.let {
                    val acceptedServices = it.services?.filter { it.selected }
                    if (acceptedServices?.size ?: 0 == 0 && it.services?.getOrNull(0)?.unit != null) {
                        activity?.toast(R.string.atLeastOneSelection)
                        return@JobberRequestAdapter
                    }
                    else {
                        val dir = JobberRequestsFragmentDirections.actionNavigationRequestsToEstimatedArrivalTimeFragment(
                            it
                        )
                        findNavController().navigate(dir)
                    }
                }
            }
            else {
                val id = adapter.getId(position)
                id?.let { id -> addToDisposableBag(viewModel.rejectRequest(id).subscribe({
                    adapter.remove(id)
                }, {}))}
            }
        }

        binding.jobPicker.setOffscreenItems(1)
        binding.jobPicker.setHasFixedSize(true)
        binding.jobPicker.setItemTransformer(
            ScaleTransformer.Builder()
                .setMaxScale(1f)
                .setMinScale(0.95f)
                .setPivotX(Pivot.X.CENTER)
                .setPivotY(Pivot.Y.BOTTOM)
                .build()
        );
        binding.jobPicker.adapter = adapter
        binding.jobPicker.setSlideOnFling(true);
        return binding.root
    }

    var spentSecondFromRequest : Int? = null;
    private fun startTimer(time: Int) {
        countDownTimer?.cancel()
        countDownTimer = null
        countDownTimer = object : CountDownTimer(((time - 1) * 1000).toLong(), 1000) {
            override fun onTick(millisUntilFinished: Long) {
                spentSecondFromRequest = millisUntilFinished.toInt() / 1000
                subscription?.onNext(spentSecondFromRequest!!)
            }

            override fun onFinish() {
                countDownTimer?.cancel()
                countDownTimer = null
                viewModel.getAllLiveRequests()
            }
        }
        countDownTimer?.start()
    }

    override fun onDestroy() {
        super.onDestroy()
        countDownTimer?.cancel()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        if (JobberRequestsViewModel.backgroundImageMap == null) JobberRequestsViewModel.loadImage(
            requireContext(),
            JobberRequestsViewModel.currentJobberLocation != null
        )
        if (JobberRequestsViewModel.backgroundImageMap != null) {
            binding.backgroundMapIamge.setImageBitmap(JobberRequestsViewModel.backgroundImageMap)
            binding.progress.visibility = View.GONE
        }
        else {
            Thread {
                try {
                    val options = GoogleMapOptions()
                        .liteMode(true)
                    mMapView = SupportMapFragment.newInstance(options)
                    childFragmentManager.beginTransaction()
                        .add(R.id.map, mMapView!!)
                        .commit()
                    activity?.runOnUiThread {
                        mMapView?.getMapAsync(this)
                    }
                } catch (ignored: Exception) {
                    Log.i("ExceptionError", ignored.localizedMessage)
                }
            }.start()
        }
        addToDisposableBag(viewModel.requests.subscribe {
            if (it.isEmpty() && adapter.getCountItem() == 0) {
                binding.flipper.displayedChild = 2
            } else {
                binding.flipper.displayedChild = 1
            }
            it.firstOrNull()?.request_life_time?.let {
                Log.i("dsfsdfsdfsdf","i: " + it)
                viewModel.requestLifeTime = it
            }
            it.forEach { element -> element.remaining_time = (element.remaining_time ?: 0.0) + (viewModel.requestLifeTime - (spentSecondFromRequest ?: viewModel.requestLifeTime).toDouble()) }
            adapter.requestLifeTime = viewModel.requestLifeTime
            if (countDownTimer == null)
                startTimer(viewModel.requestLifeTime)
            if (viewModel.referesh) adapter.insert(it)
            else adapter.append(it)
        })
        if (!viewModel.loaded || (activity as? JobberActivity)?.viewModel?.state == "back_and_refresh") {
            viewModel.referesh = true
            viewModel.getAllLiveRequests()
            (activity as? JobberActivity)?.viewModel?.state = null
        }

        addToDisposableBag((activity as? JobberActivity)?.viewModel?.pushedRequest?.subscribe {
            activity?.runOnUiThread {
                viewModel.requests.onNext(listOf(it))
            }
        })
        addToDisposableBag((activity as? JobberActivity)?.viewModel?.canceledRequest?.subscribe {
            activity?.runOnUiThread {
                it.request_id?.let {
                    adapter.remove(it)
                }
            }
        })

    }

    override fun onDestroyView() {
        googleMap?.clear()
        mMapView?.onDestroy()
        mMapView = null
        super.onDestroyView()

    }

    override fun onMapReady(googleMap: GoogleMap) {
        this.googleMap = googleMap
        googleMap.setOnMapLoadedCallback {
            googleMap.snapshot {
                JobberRequestsViewModel.backgroundImageMap = it
                viewModel.saveMap()
            }
            binding.progress.startAlphaAnimation(1f, 0f, 0, 400)
        }
        try {
            val success: Boolean = googleMap.setMapStyle(
                MapStyleOptions.loadRawResourceStyle(
                    requireContext(), R.raw.style_json
                )
            )
            googleMap.uiSettings.isCompassEnabled = false;
            googleMap.uiSettings.isMyLocationButtonEnabled = false;
            googleMap.uiSettings.isScrollGesturesEnabled = false;
            googleMap.uiSettings.isZoomGesturesEnabled = false;
            googleMap.uiSettings.isMapToolbarEnabled = false
            googleMap.uiSettings.isZoomControlsEnabled = false
        } catch (e: Resources.NotFoundException) {
            Log.e("TAG", "Can't find style. Error: ", e)
        }
        googleMap.moveCamera(
            CameraUpdateFactory.newLatLngZoom(
                LatLng(
                    JobberRequestsViewModel.currentJobberLocation?.latitude ?: 47.3767594,
                    JobberRequestsViewModel.currentJobberLocation?.longitude ?: 8.5339181
                ), 15f
            )
        )
    }

}