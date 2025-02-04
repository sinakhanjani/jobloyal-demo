package com.jobloyal.jobber.profile.complete

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.os.Environment
import android.os.Parcelable
import android.provider.MediaStore
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.AutoCompleteTextView
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.google.android.material.datepicker.MaterialDatePicker
import com.jobloyal.BuildConfig
import com.jobloyal.MainActivity
import com.jobloyal.R
import com.jobloyal.databinding.AuthenticationFragmentBinding
import com.jobloyal.databinding.JobberCompleteProfileFragmentBinding
import com.jobloyal.databinding.JobberProfileFragmentBinding
import com.jobloyal.utility.*
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.File
import java.text.DateFormat
import java.util.*

class JobberCompleteProfile : RxFragment<JobberCompleteProfileViewModel>(), PhotoPickerUtilDelegate {

    private var _binding: JobberCompleteProfileFragmentBinding? = null
    private val binding get() = _binding!!
    val args: JobberCompleteProfileArgs by navArgs()
    var imagePicker = PhotoPickerUtil(this).initForFragment(this)

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(JobberCompleteProfileViewModel::class.java)
        _binding = JobberCompleteProfileFragmentBinding.inflate(inflater, container, false)

        if (!args.isCompletePage) {
            binding.titleOfView.text = "EDIT PROFILE"
            binding.uploadAvatarButton.text = "Update Your Avatar"
            binding.completeElements.visibility = View.GONE
            binding.deleteAccountBtn.visibility = View.VISIBLE
        } else {
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
                    }
                }
            }
        }
        bindViews()

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
        binding.backBtn.setOnClickListener { findNavController().popBackStack() }
        binding.uploadAvatarButton.setOnClickListener {
            imagePicker.pick(requireContext())
        }

        return binding.root
    }


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.nextButton.setOnClickListener {
            viewModel.aboutUs = binding.aboutYou.editText?.text?.toString()
            viewModel.email = binding.emailET.editText?.text?.toString()
            viewModel.address = binding.addressET.editText?.text?.toString()
            viewModel.birthday = binding.birthdayET.text?.toString()
            if (!args.isCompletePage) {
                if (viewModel.aboutUs?.isNotEmpty() == true &&
                    viewModel.email?.isNotEmpty() == true &&
                    viewModel.address?.isNotEmpty() == true)
                        viewModel.updateProfile()
                else activity?.toast(R.string.pleaseComplete)
            } else {
                if (viewModel.aboutUs?.isNotEmpty() == true &&
                    viewModel.email?.isNotEmpty() == true &&
                    viewModel.address?.isNotEmpty() == true &&
                    viewModel.birthday?.isNotEmpty() == true &&
                    viewModel.gender != null) {
                        if (viewModel.avatar == null)
                            activity?.toast(R.string.selectAvatar)
                        else viewModel.completeProfile()
                }
                else activity?.toast(R.string.pleaseComplete)
            }
        }

        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.nextButton.setWaiting(it)
        }
        viewModel.navigate.observe(viewLifecycleOwner) {
            if (it == 1) {
                if (viewModel.avatar != null) {
                    viewModel.uploadAvatar()
                }
                else {
                    findNavController().navigateUp()
                }
            }
            else if (it == 3) {

            }
            else {
                findNavController().navigateUp()
            }
        }

    }

    private fun bindViews () {
        binding.aboutYou.editText?.setText(args.aboutUs)
        binding.emailET.editText?.setText(args.email)
        binding.addressET.editText?.setText(args.address)
    }

    override fun onResume() {
        super.onResume()
        activity?.transparentStatusBar(false)
    }

    override fun onStop() {
        super.onStop()
        activity?.transparentStatusBar(true)
    }

    override fun showProgress() {
        binding.progressBar.visibility = View.VISIBLE
    }

    override fun dismissProgress() {
        binding.progressBar.visibility = View.GONE
    }

    override fun onReadyImage(queryImageUrl: String) {
        binding.avatarImageView.visibility = View.VISIBLE
        binding.uploadAvatarButton.visibility = View.GONE
        Glide.with(requireActivity())
                    .asBitmap()
                    .diskCacheStrategy(DiskCacheStrategy.NONE)
                    .skipMemoryCache(true)
                    .load(queryImageUrl)
                    .centerCrop()
                    .circleCrop()
                    .into(binding.avatarImageView)

        viewModel.avatar = File(queryImageUrl)
    }

}