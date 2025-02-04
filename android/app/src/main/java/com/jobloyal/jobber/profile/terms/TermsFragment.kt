package com.jobloyal.jobber.profile.terms

import android.annotation.SuppressLint
import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController
import com.jobloyal.R
import com.jobloyal.databinding.JobberCompleteProfileFragmentBinding
import com.jobloyal.databinding.MessageFragmentBinding
import com.jobloyal.databinding.TermsFragmentBinding
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.transparentStatusBar

class TermsFragment : RxFragment<TermsViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: TermsFragmentBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(TermsViewModel::class.java)
        _binding = TermsFragmentBinding.inflate(inflater, container, false)
        activity?.transparentStatusBar(false)

        binding.backBtn.setOnClickListener {
            findNavController().popBackStack()
        }

        return binding.root
    }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.webView.settings.javaScriptEnabled = true;
        binding.webView.loadUrl("https://api.jobloyal.com/app/terms");
    }

}