package com.jobloyal.aboutus

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController
import com.jobloyal.R
import com.jobloyal.databinding.AboutUsFragmentBinding
import com.jobloyal.databinding.MessageFragmentBinding
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.transparentStatusBar

class AboutUsFragment : RxFragment<AboutUsViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: AboutUsFragmentBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(AboutUsViewModel::class.java)
        _binding = AboutUsFragmentBinding.inflate(inflater, container, false)
        activity?.transparentStatusBar(false)

        binding.backBtn.setOnClickListener {
            findNavController().popBackStack()
        }
        return binding.root
    }

}