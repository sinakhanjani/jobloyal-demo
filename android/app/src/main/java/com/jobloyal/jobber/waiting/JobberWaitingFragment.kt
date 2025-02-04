package com.jobloyal.jobber.waiting

import android.content.ContextWrapper
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.os.CountDownTimer
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.findNavController
import com.jobloyal.R
import com.jobloyal.databinding.JobberRequestsFragmentBinding
import com.jobloyal.databinding.JobberWaitingPageBinding
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.jobber.adapter.JobberAcceptedServices
import com.jobloyal.jobber.detail.RequestDetailFragment
import com.jobloyal.jobber.main.requests.JobberRequestsFragment
import com.jobloyal.utility.*
import java.util.*

class JobberWaitingFragment : RxFragment<JobberWaitingViewModel>() {


    private var _binding: JobberWaitingPageBinding? = null
    private val binding get() = _binding!!
    var countDownTimer : CountDownTimer? = null

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(JobberWaitingViewModel::class.java)
        _binding = JobberWaitingPageBinding.inflate(inflater, container, false)

        binding.cancelButton.setOnLongClickListener {
            viewModel.cancel()
            binding.viewFlipper.displayedChild = 1
            true
        }
        binding.cancelButton.setOnClickListener {
            activity?.toast(R.string.holdToCancel)
        }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        bindViews()
        viewModel.navigate.observe(viewLifecycleOwner) {
            if (it == 1) {
                findNavController().navigateUp()
                (activity as? JobberActivity)?.viewModel?.getLastRequestDetail()
            }
        }
    }

    private fun bindViews () {
        (activity as? JobberActivity)?.viewModel?.lastRequest?.value?.data?.let {
            binding.price.text = it.total
            if (it.remaining_time_to_pay ?: 0 > 1) {
                startTimer(time = it.remaining_time_to_pay ?: 0)
            }
            else {
                switchCancelButtonToActive()
            }
        }
    }
    private fun startTimer (time : Int) {
        countDownTimer?.cancel()
        countDownTimer = null
        countDownTimer = object : CountDownTimer(((time - 1) * 1000).toLong(), 1000) {
            override fun onTick(millisUntilFinished: Long) {
                binding.cancelButton.text = getString(R.string.cancelWithTimer, (millisUntilFinished / 1000).toInt().toHourAndMin())
            }
            override fun onFinish() {
                switchCancelButtonToActive()
            }
        }
        countDownTimer?.start()
    }

    fun switchCancelButtonToActive () {
        binding.cancelButton.setText(R.string.cancel)
        binding.cancelButton.isEnabled = true
        binding.cancelButton.delegate.setBackgroundColor(Color.parseColor("#3C3C3C"))
    }

    override fun onDestroy() {
        super.onDestroy()
        countDownTimer?.cancel()
    }
}