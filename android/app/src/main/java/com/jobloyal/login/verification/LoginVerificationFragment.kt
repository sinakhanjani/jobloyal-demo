package com.jobloyal.login.verification

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.os.CountDownTimer
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.jobloyal.R
import com.jobloyal.databinding.LoginVerificationFragmentBinding
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.login.phonenumber.PhoneNumberFragmentArgs
import com.jobloyal.user.UserActivity
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.toast

class LoginVerificationFragment : RxFragment<LoginVerificationViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: LoginVerificationFragmentBinding? = null
    private val binding get() = _binding!!
    lateinit var timer : CountDownTimer
    val args: LoginVerificationFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(LoginVerificationViewModel::class.java)
        _binding = LoginVerificationFragmentBinding.inflate(inflater, container, false)
        viewModel.isJobberApp = args.isJobberApp
        viewModel.phoneNumber = args.phoneNumber
        binding.phoneNumberTV.text = args.phoneNumber
        setTimer()
        binding.nextButton.isEnabled = false
        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.nextButton.setWaiting(it)
        }
        binding.nextButton.setOnClickListener {
            viewModel.checkOTP(binding.otpView.text.toString())
        }
        binding.changeNumberTV.setOnClickListener { findNavController().popBackStack() }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.otpView.setOtpCompletionListener {
            viewModel.checkOTP(it)
        }

        binding.resendBtn.setOnClickListener {
            disableResendButton()
            viewModel.resendOTP()
        }

        viewModel.navigate.observe(viewLifecycleOwner) {
            when (it) {
                LoginVerificationViewModel.NavigateLoginVerificationViewModel.NextToApp.ordinal -> {
                    val imm = requireActivity().getSystemService(Activity.INPUT_METHOD_SERVICE) as InputMethodManager
                    var view = requireActivity().currentFocus
                    if (view == null) {
                        view = View(activity)
                    }
                    imm.hideSoftInputFromWindow(view.windowToken, 0)

                    val intent = Intent(requireActivity(), if (viewModel.isJobberApp) JobberActivity::class.java else UserActivity::class.java)
                    startActivity(intent)
                    activity?.finish()
                    viewModel.navigate.value = -1
                }
                LoginVerificationViewModel.NavigateLoginVerificationViewModel.NextToRegister.ordinal -> {
                    var directions  =
                    if (viewModel.isJobberApp) LoginVerificationFragmentDirections.actionLoginVerificationFragmentToRegisterJobberFragment(viewModel.token ?: "")
                    else LoginVerificationFragmentDirections.actionLoginVerificationFragmentToUserRegisterFragment(viewModel.token ?: "")
                    findNavController().navigate(directions)
                    viewModel.navigate.value = -1
                }
                LoginVerificationViewModel.NavigateLoginVerificationViewModel.WrongCode.ordinal -> {
                    activity?.toast(R.string.error_code_103)
                }
                LoginVerificationViewModel.NavigateLoginVerificationViewModel.ResetTimer.ordinal -> {
                    setTimer()
                }
                else -> {

                }
            }
        }
    }
    override fun onResume() {
        super.onResume()
        binding.otpView.post {
            binding.otpView.requestFocus()
            val imgr: InputMethodManager =
                requireActivity().getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imgr.toggleSoftInput(InputMethodManager.SHOW_FORCED, InputMethodManager.HIDE_IMPLICIT_ONLY);
            imgr.showSoftInput(binding.otpView, InputMethodManager.SHOW_IMPLICIT)
        }
    }

    private fun setTimer () {
        disableResendButton()
        timer = object: CountDownTimer(120000, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                binding.resendBtn.text =
                    String.format(resources.getString(R.string.resendWithTimer), millisUntilFinished/1000)
            }

            override fun onFinish() {
                binding.resendBtn.setTextColor(ContextCompat.getColor(requireContext(),R.color.blue_button))
                binding.resendBtn.text = resources.getString(R.string.resend)
                binding.resendBtn.isEnabled = true
            }
        }
        timer.start()
    }

    private fun disableResendButton () {
        binding.resendBtn.setTextColor(ContextCompat.getColor(requireContext(),R.color.disabled_button_background))
        binding.resendBtn.isEnabled = false
    }

    override fun onDestroyView() {
        super.onDestroyView()
        timer.cancel()
    }
}