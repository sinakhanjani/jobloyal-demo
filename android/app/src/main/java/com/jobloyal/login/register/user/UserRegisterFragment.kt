package com.jobloyal.login.register.user

import android.content.Context
import android.content.Intent
import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import android.widget.ArrayAdapter
import android.widget.AutoCompleteTextView
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.google.android.material.datepicker.MaterialDatePicker
import com.jobloyal.R
import com.jobloyal.databinding.LoginVerificationFragmentBinding
import com.jobloyal.databinding.UserRegisterFragmentBinding
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.login.register.jobber.RegisterJobberFragmentArgs
import com.jobloyal.login.register.jobber.RegisterJobberViewModel
import com.jobloyal.login.verification.LoginVerificationViewModel
import com.jobloyal.user.UserActivity
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.toast
import com.jobloyal.utility.transparentStatusBar
import java.text.DateFormat
import java.util.*

class UserRegisterFragment : RxFragment<UserRegisterViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: UserRegisterFragmentBinding? = null
    private val binding get() = _binding!!
    val args by navArgs<UserRegisterFragmentArgs>()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(UserRegisterViewModel::class.java)
        _binding = UserRegisterFragmentBinding.inflate(inflater, container, false)
        requireActivity().transparentStatusBar(false)
        viewModel.token = args.token

        val items = listOf(getString(R.string.man), getString(R.string.woman))
        val adapter = ArrayAdapter(requireContext(), R.layout.country_code_item, items)
        (binding.genderET.editText as? AutoCompleteTextView)?.setAdapter(adapter)
        (binding.genderET.editText as? AutoCompleteTextView)?.setOnItemClickListener { adapterView, view, i, l ->
            viewModel.gender = i == 0
        }
        viewModelToView()
        binding.birthdayET.setOnClickListener {}
        binding.birthdayET.setOnFocusChangeListener { view, b ->
            if (b) {
                val datePicker =
                    MaterialDatePicker.Builder.datePicker()
                        .setTitleText(R.string.selectBirthday)
                        .build()
                datePicker.show(parentFragmentManager, "")
                datePicker.addOnPositiveButtonClickListener {
                    val date = Date(it)
                    binding.birthdayET.setText(DateFormat.getDateInstance().format(date))
                }
            }
        }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.nextButton.setWaiting(it)
            binding.nameET.isEnabled       = !it
            binding.familyET.isEnabled     = !it
            binding.emailET.isEnabled      = !it
            binding.addressET.isEnabled    = !it
            binding.birthdayET.isEnabled   = !it
            binding.genderET.isEnabled     = !it
            binding.switchButton.isEnabled = !it
        }

        binding.termAndConditionCheck.setOnClickListener {
            binding.switchButton.toggle(true)
        }
        binding.termAndCondition.setOnClickListener {
            findNavController().navigate(R.id.termsFragment3)
        }

        viewModel.navigate.observe(viewLifecycleOwner) {
            when (it) {
                RegisterJobberViewModel.NavigateRegisterJobberViewModel.NextToApp.ordinal -> {
                    val intent = Intent(requireActivity(), UserActivity::class.java )
                    startActivity(intent)
                    activity?.finish()
                }
            }
        }

        binding.nextButton.setOnClickListener {
            viewToViewModel()
            if (viewModel.firstName.isEmpty() || viewModel.lastName.isEmpty() || viewModel.email.isEmpty() || viewModel.address.isEmpty() || viewModel.birthday?.isEmpty() == true || viewModel.gender == null) {
                activity?.toast(R.string.error_all_field_should_complete)
            }
            else if (!binding.switchButton.isChecked) {
                activity?.toast(R.string.error_accept_terms)
            }
            else {
                viewModel.register()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        binding.nameET.post {
            binding.nameET.requestFocus()
            val imgr: InputMethodManager =
                requireActivity().getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imgr.toggleSoftInput(
                InputMethodManager.SHOW_FORCED,
                InputMethodManager.HIDE_IMPLICIT_ONLY
            );
            imgr.showSoftInput(binding.nameET, InputMethodManager.SHOW_IMPLICIT)
        }
    }

    private fun viewToViewModel () {
        viewModel.firstName = binding.nameET.editText?.text.toString()
        viewModel.lastName  = binding.familyET.editText?.text.toString()
        viewModel.email     = binding.emailET.editText?.text.toString()
        viewModel.address   = binding.addressET.editText?.text.toString()
        viewModel.birthday  = binding.birthdayET.text?.toString()
    }
    private fun viewModelToView () {
        binding.nameET.editText?.setText(viewModel.firstName)
        binding.familyET.editText?.setText(viewModel.lastName)
        binding.emailET.editText?.setText(viewModel.email)
        binding.addressET.editText?.setText(viewModel.address)
        binding.birthdayET.setText(viewModel.birthday)
}

    override fun onDestroy() {
        super.onDestroy()
        requireActivity().transparentStatusBar(true)
    }

}