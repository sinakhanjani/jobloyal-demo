package com.jobloyal.user.main.live

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.activity.OnBackPressedCallback
import androidx.navigation.findNavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.fragment.findNavController
import com.bumptech.glide.Glide
import com.jobloyal.R
import com.jobloyal.databinding.JobbersListFragmentBinding
import com.jobloyal.databinding.UserLiveRequestFragmentBinding
import com.jobloyal.user.UserActivity
import com.jobloyal.user.main.UserMainFragmentDirections
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.getFranc
import java.util.*

class UserLiveRequestFragment : RxFragment<UserLiveRequestViewModel>() {

    private var _binding: UserLiveRequestFragmentBinding? = null
    private val binding get() = _binding!!
    lateinit var callback: OnBackPressedCallback

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(UserLiveRequestViewModel::class.java)
        _binding = UserLiveRequestFragmentBinding.inflate(inflater, container, false)

        (activity as? UserActivity)?.viewModel?.lastRequest?.value?.data?.let {
            binding.jobberNameTV.text = "${it.jobber?.name} ${it.jobber?.family}".capitalize(Locale.getDefault())
            binding.tag.text = it.tag
            binding.price.text = it.total_pay.getFranc()
            binding.reservedServiceTV.text = getString(R.string.nRequestedServices, it.service_count)
            Glide.with(requireContext()).load(it.jobber?.avatar).centerCrop().circleCrop().placeholder(R.drawable.ic_camera_profile).into(binding.avatarImage)
            binding.reservedJobber.setOnClickListener { view ->
                activity?.findNavController(R.id.nav_host_fragment)?.navigate(UserMainFragmentDirections.actionUserMainFragmentToJobberPageFragment(jobTitle = it.job_title))
            }
        }

        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        callback =
            object : OnBackPressedCallback(true) {
                override fun handleOnBackPressed() {
                    if ((activity as? UserActivity)?.viewModel?.lastRequest != null) {
                    }
                    else{
                        isEnabled = false
                        requireActivity().onBackPressed()
                        isEnabled = true
                    }
                }
            }
        requireActivity().onBackPressedDispatcher.addCallback(viewLifecycleOwner, callback)
    }

}