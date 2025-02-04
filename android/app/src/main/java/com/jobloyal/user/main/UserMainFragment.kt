package com.jobloyal.user.main

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Resources
import android.graphics.Color
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.RelativeLayout
import androidx.activity.OnBackPressedCallback
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.checkSelfPermission
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.fragment.findNavController
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MapStyleOptions
import com.jobloyal.R
import com.jobloyal.databinding.UserMainFragmentBinding
import com.jobloyal.user.UserActivity
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.px
import com.jobloyal.utility.updateStatusBarColor


class UserMainFragment : RxFragment<UserMainViewModel>(), OnMapReadyCallback {

    private var map: GoogleMap? = null
    private var mapView: View? = null
    override val invalidateStatusBarHeight: Boolean
        get() = false
    var cameraPosition : LatLng? = null
    private var _binding: UserMainFragmentBinding? = null
    private val binding get() = _binding!!
    lateinit var callback: OnBackPressedCallback

    @SuppressLint("MissingPermission")
    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(UserMainViewModel::class.java)
        _binding = UserMainFragmentBinding.inflate(inflater, container, false)
        activity?.updateStatusBarColor(Color.parseColor("#f5f5f5"))
        binding.findMyJobButton.setOnClickListener {
            binding.viewFlipper.displayedChild = 1
            viewModel.displayedChild = 1
            cameraPosition = map?.cameraPosition?.target
            viewModel.location = cameraPosition
            viewModel.saveLocationToSharedPreferences()
            viewModel.zoom = map?.cameraPosition?.zoom
            map?.isMyLocationEnabled = false
        }
        binding.profileButton.setOnClickListener {
            findNavController().navigate(R.id.action_userMainFragment_to_userProfileFragment)
        }
        viewModel.readLastLocation()
        cameraPosition = viewModel.location
        binding.viewFlipper.displayedChild = viewModel.displayedChild
        callback =
            object : OnBackPressedCallback(true) {
                override fun handleOnBackPressed() {
                    if (binding.viewFlipper.displayedChild  == 1 && (childFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment).navController.currentDestination?.id == R.id.userCategoryFragment) {
                        binding.viewFlipper.displayedChild = 0
                        map?.isMyLocationEnabled = true
                        showToolbar()
                    }
                    else{
                        isEnabled = false
                        requireActivity().onBackPressed()
                        isEnabled = true
                    }
                }
            }
        requireActivity().onBackPressedDispatcher.addCallback(viewLifecycleOwner, callback)
        initializeSuspending()
        initializeLiveRequest()

        return binding.root
    }


    private fun initializeSuspending () {
        addToDisposableBag((activity as? UserActivity)?.viewModel?.suspendStatus?.subscribe {
            if (it) {
                callback.isEnabled = false
                val navHost =
                    (childFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment).navController
                navHost.navigate(R.id.userSuspendFragment)
                binding.viewFlipper.displayedChild = 1
                binding.profileButton.visibility = View.INVISIBLE
            }
        })
    }

    private fun initializeLiveRequest () {
        addToDisposableBag((activity as? UserActivity)?.viewModel?.lastRequest?.subscribe {
            val navHost =
                (childFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment).navController
            if (it.data != null && it.data?.status != "created" && it.data?.status != "verified") {
                map?.animateCamera(
                    CameraUpdateFactory.newLatLngZoom(
                        LatLng(
                            it.data?.latitude ?: 35.706897, it.data?.longitude ?: 51.393435
                        ), 15f
                    )
                )
                navHost.popBackStack(R.id.userCategoryFragment, false)
                navHost.navigate(
                    R.id.userLiveRequestFragment
                )
                binding.viewFlipper.displayedChild = 1
            } else {
                if (navHost.currentDestination?.id == R.id.userLiveRequestFragment) {
                    navHost.popBackStack(R.id.userCategoryFragment, false)
                }
            }
        })
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val mapFragment = childFragmentManager
            .findFragmentById(R.id.map) as? SupportMapFragment
        mapView = mapFragment?.view
        mapFragment?.getMapAsync(this)

        isLocationPermissionGranted()
    }

    fun hideToolbar () {
        binding.toolbar.visibility = View.INVISIBLE
    }
    fun showToolbar () {
        binding.toolbar.visibility = View.VISIBLE
    }

    override fun onMapReady(googleMap: GoogleMap) {
        try {
            val success: Boolean = googleMap.setMapStyle(
                MapStyleOptions.loadRawResourceStyle(
                    requireContext(), R.raw.style_json
                )
            )
            googleMap.uiSettings.isCompassEnabled = false
            googleMap.uiSettings.isMyLocationButtonEnabled = true
            googleMap.uiSettings.isRotateGesturesEnabled = false

            this.map = googleMap

            if (checkSelfPermission(
                    requireContext(),
                    Manifest.permission.ACCESS_FINE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED && checkSelfPermission(
                    requireContext(),
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED
            )  {
                handleMyLocationButton()
            }
        } catch (e: Resources.NotFoundException) {

        }
        googleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(cameraPosition ?: LatLng(47.3767594, 8.5339181), viewModel.zoom ?: 15f))
    }

    @SuppressLint("MissingPermission")
    fun handleMyLocationButton () {
        map?.let { googleMap ->
            googleMap.isMyLocationEnabled = true
            val locationButton =
                (mapView?.findViewById<View>(Integer.parseInt("1"))?.parent as? View)?.findViewById<View>(
                    Integer.parseInt(
                        "2"
                    )
                )
            (locationButton as? ImageView)?.setImageResource(R.drawable.mylocation)
            val layoutParams =
                locationButton!!.layoutParams as RelativeLayout.LayoutParams
            layoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP, 0)
            layoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.TRUE)
            layoutParams.setMargins(0, 100.px, 180.px, 20.px)
            layoutParams.height = 62.px
            layoutParams.width = 62.px
            googleMap.setOnMyLocationButtonClickListener {
                val mgr =
                    requireContext().getSystemService(Context.LOCATION_SERVICE) as LocationManager?
                if (!mgr!!.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                    buildAlertMessageNoGps()
                }
                false
            }
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


    @SuppressLint("MissingPermission")
    private val requestPermission = registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()){
        var allPermissionGranted = true
        for (a in it.values) {
            if (!a) allPermissionGranted = false
        }
        if (allPermissionGranted){
            handleMyLocationButton()
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
                    arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                    )
                )
                false
            }
        } else {
            true
        }
    }



}