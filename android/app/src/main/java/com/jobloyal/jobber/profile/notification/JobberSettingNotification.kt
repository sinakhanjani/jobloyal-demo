
package com.jobloyal.jobber.profile.notification

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.jobloyal.R
import com.jobloyal.databinding.JobberCompleteProfileFragmentBinding
import com.jobloyal.databinding.JobberSettingNotificationFragmentBinding
import com.jobloyal.jobber.profile.complete.JobberCompleteProfileViewModel
import com.jobloyal.utility.RxFragment

class JobberSettingNotification : RxFragment<JobberSettingNotificationViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private var _binding: JobberSettingNotificationFragmentBinding? = null
    private val binding get() = _binding!!
    private val args : JobberSettingNotificationArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(JobberSettingNotificationViewModel::class.java)
        _binding = JobberSettingNotificationFragmentBinding.inflate(inflater, container, false)

        binding.smsSwitch.isChecked = args.jobberStatics?.sms_enabled ?: false
        binding.localNotificationSwitch.isChecked = viewModel.isAlarmEnabled()
        binding.notificationSwitch.isChecked = args.jobberStatics?.notification_enabled ?: true

        binding.saveButton.setOnClickListener {
            viewModel.saveAlarmState(binding.localNotificationSwitch.isChecked)
            viewModel.save(binding.smsSwitch.isChecked, binding.notificationSwitch.isChecked)
        }
        binding.backBtn.setOnClickListener { findNavController().popBackStack() }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.notifNotificationSwitchLayout.setOnClickListener {
            binding.notificationSwitch.toggle(true)
        }
        binding.localNotificationNotificationSwitchLayout.setOnClickListener {
            binding.localNotificationSwitch.toggle(true)
        }
        binding.smsNotificationSwitchLayout.setOnClickListener {
            binding.smsSwitch.toggle(true)
        }
        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.waitingFlipper.displayedChild = if(it) 1 else 0
            binding.smsSwitch.isEnabled = !it
            binding.notificationSwitch.isEnabled = !it
        }

        viewModel.navigate.observe(viewLifecycleOwner) {
            if (it == 1) {
                findNavController().navigateUp()
            }
        }
    }

}