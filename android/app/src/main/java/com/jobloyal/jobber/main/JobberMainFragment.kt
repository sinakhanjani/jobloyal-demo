package com.jobloyal.jobber.main

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.NavController
import androidx.navigation.Navigation
import androidx.navigation.Navigation.findNavController
import androidx.navigation.findNavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.setupWithNavController
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.jobloyal.R
import com.jobloyal.databinding.FragmentJobberMainBinding
import com.jobloyal.databinding.JobberActivityBinding
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.utility.RxFragment

class JobberMainFragment : RxFragment<Nothing>() {

    companion object {
        var currentDestination = 0;
    }
    private var _binding: FragmentJobberMainBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        _binding = FragmentJobberMainBinding.inflate(inflater, container, false)
        binding.bottomNavigationView.setupWithNavController((childFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment).navController)

        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        (childFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment).navController.addOnDestinationChangedListener { controller, destination, arguments ->
            currentDestination = destination.id
        }

        val status = (activity as? JobberActivity)?.viewModel?.state;
        when  {
            status == "back_and_refresh" -> {
                (childFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment).navController.navigate(R.id.navigation_requests)
            }
            status == "back_to_jobs_tab" ||
            status?.startsWith("add_job") == true ||
            status?.startsWith("add_service") == true -> {
                (childFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment).navController.popBackStack(R.id.navigation_jobs, false)
            }
        }
    }

}