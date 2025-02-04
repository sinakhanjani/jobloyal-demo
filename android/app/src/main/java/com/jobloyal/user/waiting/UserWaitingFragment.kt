package com.jobloyal.user.waiting

import android.graphics.Color
import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.os.CountDownTimer
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController
import com.jobloyal.R
import com.jobloyal.databinding.UserInvoiceFragmentBinding
import com.jobloyal.databinding.UserWaitingFragmentBinding
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.user.UserActivity
import com.jobloyal.utility.*

class UserWaitingFragment : RxFragment<UserWaitingViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: UserWaitingFragmentBinding? = null
    private val binding get() = _binding!!
    var countDownTimer : CountDownTimer? = null

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(UserWaitingViewModel::class.java)
        _binding = UserWaitingFragmentBinding.inflate(inflater, container, false)
        activity?.updateStatusBarColor(Color.WHITE)
        bindViews()
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
        viewModel.navigate.observe(viewLifecycleOwner) {
            if (it == 1) {
                findNavController().navigateUp()
                (activity as? UserActivity)?.viewModel?.getLastRequestDetail()
            }
        }
    }

    private fun bindViews () {
        (activity as? UserActivity)?.viewModel?.lastRequest?.value?.data?.let {
            binding.jobberIdentifier.text = it.jobber?.identifier
            if (it.remaining_time ?: 0 > 1) {
                startTimer(time = it.remaining_time ?: 0)
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
                binding.momentTV.text = (millisUntilFinished / 1000).toInt().toHourAndMin()
            }
            override fun onFinish() {
                switchCancelButtonToActive()
            }
        }
        countDownTimer?.start()
    }

    fun switchCancelButtonToActive () {
//        AlertDialogFactory(requireActivity()).warningDialog("Canceled", "jobber not any response to your request", {it.dismiss()}).show()
    }

    override fun onDestroy() {
        super.onDestroy()
        countDownTimer?.cancel()
        countDownTimer = null
    }

}