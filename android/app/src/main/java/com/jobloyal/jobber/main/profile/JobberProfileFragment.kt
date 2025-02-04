package com.jobloyal.jobber.main.profile

import android.content.Intent
import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.telephony.PhoneNumberUtils
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.jobloyal.MainActivity
import com.jobloyal.R
import com.jobloyal.databinding.JobberProfileFragmentBinding
import com.jobloyal.databinding.JobberReportFragmentBinding
import com.jobloyal.jobber.adapter.ProfileAdapter
import com.jobloyal.jobber.main.JobberMainFragmentDirections
import com.jobloyal.utility.*

class JobberProfileFragment : RxFragment<JobberProfileViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private var _binding: JobberProfileFragmentBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(JobberProfileViewModel::class.java)
        _binding = JobberProfileFragmentBinding.inflate(inflater, container, false)
        activity?.transparentStatusBar(true)

        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        val options = resources.getStringArray(R.array.profileOptions).toList()
        binding.recyclerView.adapter = ProfileAdapter(options) {
            val nav = activity?.findNavController(R.id.nav_host_fragment)
            when (it) {
                0 -> {nav?.navigate(JobberMainFragmentDirections.actionMainJobberFragmentToJobberPaymentFragment(viewModel.profile.value?.statics))}
                1 -> {nav?.navigate(JobberMainFragmentDirections.actionMainJobberFragmentToJobberSettingNotification(viewModel.profile.value?.statics))}
                2 -> {
                    nav?.navigate(JobberMainFragmentDirections.actionMainJobberFragmentToJobberCompleteProfile(false , viewModel.profile.value?.email, viewModel.profile.value?.address, viewModel.profile.value?.about_us))
                }
                3 -> {nav?.navigate(R.id.action_mainJobberFragment_to_turnoverFragment)}
                4 -> {nav?.navigate(R.id.action_mainJobberFragment_to_messageFragment)}
                5 -> {nav?.navigate(R.id.action_mainJobberFragment_to_termsFragment)}
                6 -> {nav?.navigate(R.id.action_mainJobberFragment_to_aboutUsFragment)}
                7 -> {
                    AlertDialogFactory(requireActivity())
                        .confirmDialog(R.string.exit, R.string.exitSubTitle, R.string.exitDescription, {
                            viewModel.deleteDevice().subscribe ({
                                Const.resetToken(requireContext())
                                activity?.finish()
                                activity?.startActivity(Intent(requireContext(), MainActivity::class.java))
                            }, {})
                        }) {
                            it.dismiss()
                        }.show()
                }
            }
        }

        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.uploadDocumentBtn.setOnClickListener {
            activity?.findNavController(R.id.nav_host_fragment)?.navigate(R.id.action_mainJobberFragment_to_authenticationFragment)
        }
        binding.uploadProfileAgainBtn.setOnClickListener {
            activity?.findNavController(R.id.nav_host_fragment)?.navigate(R.id.action_mainJobberFragment_to_authenticationFragment)
        }
        binding.completeProfileBtn.setOnClickListener {
            activity?.findNavController(R.id.nav_host_fragment)?.navigate(JobberMainFragmentDirections.actionMainJobberFragmentToJobberCompleteProfile(true , viewModel.profile.value?.email, viewModel.profile.value?.address, viewModel.profile.value?.about_us))
        }
        addToDisposableBag(viewModel.profile.subscribe {
            binding.viewFlipper.displayedChild =
                if (it.authority?.code ?: 0 in 0..3) it.authority?.code ?: 0 else 4
            Glide.with(requireContext()).load(it.avatar).centerCrop().placeholder(R.drawable.ic_camera_profile).into(binding.avatarImageView)
            binding.username.text = "${it.name ?: ""}  ${it.family ?: ""}"
            it.phone_number?.let { binding.phoneNumber.text = PhoneNumberUtils.formatNumber(it, "CH"); }
            binding.identifier.text = it.identifier
            binding.creditTV.text = it.credit.getFranc()
            binding.viewFlipper.visibility = View.VISIBLE
            binding.roundedImageView.displayedChild = 1
        })

        viewModel.getProfile()
    }
}