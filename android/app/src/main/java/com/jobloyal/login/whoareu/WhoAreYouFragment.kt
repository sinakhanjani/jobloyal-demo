package com.jobloyal.login.whoareu

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.navigation.fragment.findNavController
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.jobloyal.R
import com.jobloyal.databinding.FragmentIntroBinding
import com.jobloyal.databinding.FragmentWhoAreYouBinding
import com.jobloyal.login.intro.slides.SlideIntroFragment
import com.jobloyal.utility.RxFragment


class WhoAreYouFragment : RxFragment<Nothing>() {

    private var _binding: FragmentWhoAreYouBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        _binding = FragmentWhoAreYouBinding.inflate(inflater,container,false)
        binding.userBtn.setOnClickListener {
            val navigateDirection = WhoAreYouFragmentDirections.actionWhoAreYouFragmentToPhoneNumberFragment(false)
            findNavController().navigate(navigateDirection)
        }
        binding.jobberBtn.setOnClickListener {
            val navigateDirection = WhoAreYouFragmentDirections.actionWhoAreYouFragmentToPhoneNumberFragment(true)
            findNavController().navigate(navigateDirection)
        }
        return binding.root
    }
}