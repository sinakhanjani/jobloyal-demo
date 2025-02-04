package com.jobloyal.login.intro

import android.content.Context
import android.os.Bundle
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.navigation.fragment.findNavController
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.jobloyal.R
import com.jobloyal.databinding.FragmentIntroBinding
import com.jobloyal.login.intro.slides.SlideIntroFragment
import com.jobloyal.utility.RxFragment

class IntroFragment : RxFragment<Nothing>() {

    private var _binding: FragmentIntroBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        _binding = FragmentIntroBinding.inflate(inflater, container, false)
        val pagerAdapter = ScreenSlidePagerAdapter(requireActivity())
        binding.viewPager2.adapter = pagerAdapter
        binding.dotsIndicator.setViewPager2(binding.viewPager2)

        binding.getStartedButton.setOnClickListener {
            findNavController().navigate(R.id.action_introFragment_to_whoAreYouFragment)
        }
        return binding.root
    }


    private inner class ScreenSlidePagerAdapter(fa: FragmentActivity) : FragmentStateAdapter(fa) {
        override fun getItemCount(): Int = 2

        override fun createFragment(position: Int): Fragment = SlideIntroFragment.newInstance(position )
    }
}