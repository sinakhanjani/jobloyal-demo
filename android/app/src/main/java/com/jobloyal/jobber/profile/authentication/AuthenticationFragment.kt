package com.jobloyal.jobber.profile.authentication

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.load.resource.bitmap.CenterCrop
import com.bumptech.glide.load.resource.bitmap.CenterInside
import com.bumptech.glide.load.resource.bitmap.GranularRoundedCorners
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.bumptech.glide.request.RequestOptions
import com.jobloyal.databinding.AuthenticationFragmentBinding
import com.jobloyal.utility.PhotoPickerUtil
import com.jobloyal.utility.PhotoPickerUtilDelegate
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.px
import java.io.File


class AuthenticationFragment : RxFragment<AuthentictionViewModel>(), PhotoPickerUtilDelegate {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private var _binding: AuthenticationFragmentBinding? = null
    private val binding get() = _binding!!
    var imagePicker = PhotoPickerUtil(this, true).initForFragment(this)

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(AuthentictionViewModel::class.java)
        _binding = AuthenticationFragmentBinding.inflate(inflater, container, false)

        binding.takePictureBtn.setOnClickListener {
            imagePicker.onlyCamera = true
            imagePicker.cameraNeeded = true
            imagePicker.pick(requireContext())
        }
        binding.uploadFromGalleryBtn.setOnClickListener {
            imagePicker.onlyCamera = false
            imagePicker.cameraNeeded = false
            imagePicker.pick(requireContext())
        }
        binding.uploadBtn.setOnClickListener {
            if (viewModel.document != null)
                viewModel.uploadDocument()
        }
        binding.cancelBtn.setOnClickListener {
            binding.viewFlipper.displayedChild = 0
        }
        binding.backBtn.setOnClickListener {
            findNavController().popBackStack()
        }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.loadingFlipper.displayedChild = if (it) 1 else 0
        }
        viewModel.navigate.observe(viewLifecycleOwner){
            if (it == 1) {
                findNavController().navigateUp()
            }
        }
    }

    override fun showProgress() {
        binding.viewFlipper.displayedChild = 2
    }

    override fun dismissProgress() {
//        binding.viewFlipper.displayedChild = 2
    }

    override fun onReadyImage(queryImageUrl: String) {
        binding.viewFlipper.displayedChild = 1
        val requestOptions = RequestOptions()
        val a = requestOptions.centerInside().transform( CenterInside(), GranularRoundedCorners(10.px.toFloat(), 10.px.toFloat(), 0f, 0f))

        Glide.with(requireActivity())
            .asBitmap()
            .diskCacheStrategy(DiskCacheStrategy.NONE)
            .skipMemoryCache(true)
            .load(queryImageUrl)
            .apply(a)
            .into(binding.imageView)
        val f = File(queryImageUrl)
        viewModel.document = f
    }

}