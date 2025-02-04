package com.jobloyal.jobber.main.jobs

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.getSystemService
import androidx.core.view.isNotEmpty
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.findNavController
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager.widget.ViewPager
import com.jobloyal.R
import com.jobloyal.databinding.JobsFragmentBinding
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.jobber.adapter.JobberJobAdapter
import com.jobloyal.jobber.main.JobberMainFragment
import com.jobloyal.jobber.main.JobberMainFragmentDirections
import com.jobloyal.utility.*
import com.tbuonomo.viewpagerdotsindicator.BaseDotsIndicator
import com.tbuonomo.viewpagerdotsindicator.OnPageChangeListenerHelper
import com.yarolegovich.discretescrollview.DiscreteScrollView
import com.yarolegovich.discretescrollview.transform.Pivot
import com.yarolegovich.discretescrollview.transform.ScaleTransformer
import java.lang.Exception


class JobsFragment : RxFragment<JobsViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private var _binding: JobsFragmentBinding? = null
    private val binding get() = _binding!!
    lateinit var adapter: JobberJobAdapter

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(JobsViewModel::class.java)
        _binding = JobsFragmentBinding.inflate(inflater, container, false)

        binding.dateTV.text = viewModel.getToday()
        binding.jobPicker.setHasFixedSize(true)
        binding.jobPicker.setOffscreenItems(3)
        binding.jobPicker.setItemTransformer(
            ScaleTransformer.Builder()
                .setMaxScale(1f)
                .setMinScale(0.95f)
                .setPivotX(Pivot.X.CENTER)
                .setPivotY(Pivot.Y.BOTTOM)
                .build()
        );

        adapter = JobberJobAdapter(requireContext()) { position, online ->
            if (position == adapter.addCardPosition()) {
                findNavController().navigate(R.id.action_navigation_jobs_to_categoryFragment)
            }
            else {
                if (online == null) {
                    val dir = JobberMainFragmentDirections.actionMainJobberFragmentToJobPageFragment(adapter.getIdOfJob(position), false, adapter.getTitleOfJob(position))
                    activity?.findNavController(R.id.nav_host_fragment)?.navigate(dir)
                }
                else {
                    adapter.getModelOfJob(position)?.let {
                        viewModel.changeStateOfJob(online, it).subscribe({
                               adapter.notifyItemChanged(position)
                        },{})
                    }
                }
            }
        }
        binding.jobPicker.adapter = adapter
        binding.jobPicker.setSlideOnFling(true);
        setPagerToDot()
        return binding.root
    }

    private fun pagingArrowAnimation (id : String) {
        binding.swipeHelper.visibility = View.VISIBLE
        binding.swipeHelper.startAlphaAnimation(0f, 1f,0, 1000) {
            binding.swipeHelper.startAlphaAnimation(1f, 0f,1000, 1000) {
//                binding.swipeHelper.visibility = View.INVISIBLE
                alertOnlineJob(id,false)
            }
        }
    }
    private fun setPagerToDot () {
        binding.springDotsIndicator.pager = object : BaseDotsIndicator.Pager {
            var onPageChangeListener: DiscreteScrollView.OnItemChangedListener<RecyclerView.ViewHolder>? = null

            override val isNotEmpty: Boolean
                get() = true
            override val currentItem: Int
                get() = binding.jobPicker.currentItem
            override val isEmpty: Boolean
                get() = false
            override val count: Int
                get() = adapter.itemCount

            override fun setCurrentItem(item: Int, smoothScroll: Boolean) {
                binding.jobPicker.smoothScrollToPosition(item)
            }

            override fun removeOnPageChangeListener() {
                onPageChangeListener?.let {
                    binding.jobPicker.removeItemChangedListener(it)
                }
            }

            override fun addOnPageChangeListener(onPageChangeListenerHelper: OnPageChangeListenerHelper) {
                onPageChangeListener = DiscreteScrollView.OnItemChangedListener<RecyclerView.ViewHolder> { viewHolder, adapterPosition ->
                    onPageChangeListenerHelper.onPageScrolled(adapterPosition, 0f)
                }
                binding.jobPicker.addOnItemChangedListener(onPageChangeListener!!)
            }
        }
        binding.jobPicker.addOnItemChangedListener { viewHolder, adapterPosition ->
            binding.springDotsIndicator.refreshDots()
        }
        binding.springDotsIndicator.refreshDots()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.getLastLocation()

        viewModel.waitingForUpdateLocation.observe(viewLifecycleOwner) {
            binding.updatLoading.displayedChild = if (it) 1 else 0
        }

        addToDisposableBag(viewModel.location.subscribe { model ->
            if (model.id == null) {
                binding.addressTV.setText(R.string.updateYourLocation)
            }
            else {
                binding.addressTV.text = model.address
                binding.lastUpdateTV.text = getString(
                    R.string.lastUpdatedAt,
                    model.createdAt?.dateToFormat("HH:mm") ?: "00:00"
                )
            }
        })

        binding.updateLocationBtn.setOnClickListener {
            if (isLocationPermissionGranted()) {
                updateLocation()
            }
        }

        addToDisposableBag(viewModel.allMyJobs.subscribe {
            adapter.insertJobs(it)


            //Alerts
            val state = (activity as? JobberActivity)?.viewModel?.state
            if (state?.split("|")?.size == 2) {
                val currentState = state.split("|")[0]
                val id = state.split("|")[1]
                if (currentState == "add_job") {
                    pagingArrowAnimation(id)
                }
                else {
                    alertOnlineJob(id,true)
                }
                (activity as? JobberActivity)?.viewModel?.state = null
            }

        })

        viewModel.getMyJobs()
    }

    private fun alertOnlineJob (id : String,isServiceAdded : Boolean) {
        viewModel.allMyJobs.value?.let { list ->
            list.indexOfFirst { it.job_id == id }.let {
                if (it >= 0) {
                    binding.jobPicker.smoothScrollToPosition(it)
                    if (list[it].status != "online") {
                        AlertDialogFactory(requireActivity()).warningDialog(getString(if (isServiceAdded) R.string.add_new_service_please_be_online_title else R.string.add_new_job_please_be_online_title),
                            getString(if (isServiceAdded) R.string.add_new_service_please_be_online_content else R.string.add_new_job_please_be_online_content, list[it].title)) {
                            it.dismiss()
                        }.show()
                    }
                }
            }
        }
    }
    @SuppressLint("MissingPermission")
    private fun updateLocation () {
        binding.updatLoading.displayedChild = 1
        val lm: LocationManager =
            requireContext().getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val location: Location? = lm.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)
        Log.i("SDFsdfsdf", "sdfdsf: ${location}")
        if (location != null) {
            val longitude = location.longitude
            val latitude = location.latitude
            viewModel.updateLocation(latitude, longitude)
        } else {
            lm.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 0f, object : LocationListener {
                override fun onLocationChanged(loc: Location) {
                    val longitude = loc.longitude
                    val latitude = loc.latitude
                    viewModel.updateLocation(latitude, longitude)
                    lm.removeUpdates(this);
                }
                override fun onProviderEnabled(provider: String) {
                }

                override fun onProviderDisabled(provider: String) {
                    binding.updatLoading.displayedChild = 0
                    lm.removeUpdates(this);
                    buildAlertMessageNoGps()
                }
            })
        }
    }

    private fun buildAlertMessageNoGps() {
        val builder: AlertDialog.Builder = AlertDialog.Builder(requireContext())
        builder.setMessage(R.string.turnOnYourGPS)
            .setCancelable(false)
            .setPositiveButton(R.string.yes) { dialog, id -> startActivity(Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)) }
            .setNegativeButton(R.string.no) { dialog, id -> dialog.cancel() }
        val alert: AlertDialog = builder.create()
        alert.show()
    }

    private val requestPermission = registerForActivityResult(ActivityResultContracts.RequestPermission()){
        if (it) {
            updateLocation()
        }
    }

    private fun isLocationPermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(
                    requireContext(),
                    Manifest.permission.ACCESS_FINE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED) {
                true
            } else {
                requestPermission.launch(
                    Manifest.permission.ACCESS_FINE_LOCATION
                )
                false
            }
        } else {
            true
        }
    }
}