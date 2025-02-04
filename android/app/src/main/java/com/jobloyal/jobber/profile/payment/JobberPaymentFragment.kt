package com.jobloyal.jobber.profile.payment

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.jobloyal.R
import com.jobloyal.databinding.JobberPaymentFragmentBinding
import com.jobloyal.databinding.JobberSettingNotificationFragmentBinding
import com.jobloyal.jobber.profile.notification.JobberSettingNotificationViewModel
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.toast

class JobberPaymentFragment : RxFragment<JobberPaymentViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private var _binding: JobberPaymentFragmentBinding? = null
    private val binding get() = _binding!!
    val arg : JobberPaymentFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(JobberPaymentViewModel::class.java)
        _binding = JobberPaymentFragmentBinding.inflate(inflater, container, false)

        binding.segmentPeriod.setText(0, getString(R.string.daily))
        binding.segmentPeriod.setText(1, getString(R.string.weekly))
        binding.segmentPeriod.setText(2, getString(R.string.monthly))

        handleSwitch(arg.jobberStatics?.pony_period ?: 0)
        if (arg.jobberStatics?.card_number?.length ?: 0 > 4)
            binding.ibanET.isEnabled = false
        binding.ibanET.editText?.setText(arg.jobberStatics?.card_number)
        binding.saveButton.setOnClickListener {
            if (binding.ibanET.editText?.text?.length ?: 0 < 7) {
                activity?.toast(R.string.wrongIBAN)
            }
            else {
                viewModel.save(mapIndexToPeriod(binding.segmentPeriod.selectedIndex), binding.ibanET.editText?.text?.toString() ?: "")
            }
        }

        binding.backBtn.setOnClickListener {
            findNavController().popBackStack()
        }

        return binding.root
    }

    private fun handleSwitch (period: Int) {
        var index = 0;
        when (period) {
            1 -> index = 0;
            7  -> index = 1;
            30 -> index = 2;
        }
        binding.segmentPeriod.selectedIndex = index
    }
    private fun mapIndexToPeriod (index : Int) = when (index) {
        0 -> 1
        1 -> 7
        2 -> 30
        else -> 1
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.waitingFlipper.displayedChild = if(it) 1 else 0
            binding.ibanET.isEnabled = if (arg.jobberStatics?.card_number?.length ?: 0 > 4) false else !it
            binding.segmentPeriod.isEnabled = !it
        }

        viewModel.navigate.observe(viewLifecycleOwner) {
            if (it == 1) {
                findNavController().navigateUp()
            }
        }

    }
}