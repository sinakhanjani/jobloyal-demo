package com.jobloyal.user.profile.edit

import android.content.Intent
import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.AutoCompleteTextView
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.google.android.material.datepicker.MaterialDatePicker
import com.jobloyal.MainActivity
import com.jobloyal.R
import com.jobloyal.databinding.UserEditProfileFragmentBinding
import com.jobloyal.databinding.UserProfileFragmentBinding
import com.jobloyal.login.register.jobber.RegisterJobberViewModel
import com.jobloyal.user.UserActivity
import com.jobloyal.utility.*
import java.text.DateFormat
import java.util.*

class UserEditProfileFragment : RxFragment<UserEditProfileViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: UserEditProfileFragmentBinding? = null
    private val binding get() = _binding!!
    val args : UserEditProfileFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(UserEditProfileViewModel::class.java)
        _binding = UserEditProfileFragmentBinding.inflate(inflater, container, false)

        binding.backBtn.setOnClickListener {
            findNavController().popBackStack()
        }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.nameET.editText?.setText(args.profile?.name)
        binding.familyET.editText?.setText(args.profile?.family)
        binding.emailET.editText?.setText(args.profile?.email)
        binding.addressET.editText?.setText(args.profile?.address)
        viewModel.gender = args.profile?.gender
        args.profile?.birthday?.toDate()?.let {
            binding.birthdayET.setText(DateFormat.getDateInstance().format(it))
        }
        binding.genderET.editText?.setText(if (args.profile?.gender == true) getString(R.string.man) else getString(R.string.woman))
        initBirthdayAndGender()

        binding.nextButton.setOnClickListener {
            viewModel.firstName = binding.nameET.editText?.text.toString()
            viewModel.lastName =  binding.familyET.editText?.text.toString()
            viewModel.email =   binding.emailET.editText?.text.toString()
            viewModel.address =   binding.addressET.editText?.text.toString()
            if (viewModel.firstName.isEmpty() || viewModel.lastName.isEmpty() || viewModel.email.isEmpty() || viewModel.address.isEmpty()) {
                activity?.toast(R.string.error_all_field_should_complete)
            }
            else {
                viewModel.save()
            }
        }

        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.nextButton.setWaiting(it)
            binding.nameET.isEnabled = !it
            binding.familyET.isEnabled = !it
            binding.emailET.isEnabled = !it
            binding.addressET.isEnabled = !it
            binding.birthdayET.isEnabled = !it
            binding.genderET.isEnabled = !it
        }

        binding.deleteAccountBtn.setOnClickListener {
            AlertDialogFactory(requireActivity())
                .confirmDialog(R.string.deleteAccount, R.string.deleteAccountSubTitle, R.string.deleteAccountDescription, {
                    viewModel.deleteAccount().subscribe ({
                        Const.resetToken(requireContext())
                        activity?.finish()
                        activity?.startActivity(Intent(requireContext(), MainActivity::class.java))
                    }, {})
                }) {
                    it.dismiss()
                }.show()

        }

        viewModel.navigate.observe(viewLifecycleOwner) {
            when (it) {
                1 -> {
                    findNavController().popBackStack()
                }
            }
        }
    }

    private fun initBirthdayAndGender () {
        val items = listOf(getString(R.string.man), getString(R.string.woman))
        val adapter = ArrayAdapter(requireContext(), R.layout.country_code_item, items)
        (binding.genderET.editText as? AutoCompleteTextView)?.setAdapter(adapter)
        (binding.genderET.editText as? AutoCompleteTextView)?.setOnItemClickListener { adapterView, view, i, l ->
            viewModel.gender = i == 0
        }

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
                    viewModel.birthday = DateFormat.getDateInstance().format(date)
                }
            }
        }
    }



}