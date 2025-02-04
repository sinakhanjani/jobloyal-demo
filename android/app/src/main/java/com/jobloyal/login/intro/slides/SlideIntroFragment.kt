package com.jobloyal.login.intro.slides

import android.R.attr.subtitle
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.jobloyal.R
import com.jobloyal.databinding.FragmentIntroBinding
import com.jobloyal.databinding.FrgamentSlide1Binding
import com.jobloyal.utility.RxFragment


class SlideIntroFragment: RxFragment<Nothing>() {

    private var _binding: FrgamentSlide1Binding? = null
    private val binding get() = _binding!!
    var position: Int = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (arguments != null) {
            position = arguments?.getInt("position") ?: 0
        }
    }
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        _binding = FrgamentSlide1Binding.inflate(inflater, container, false)
        binding.imageView.setImageResource(if (position == 0) R.drawable.intro1 else R.drawable.ic_workers_intro)
        binding.title.text = resources.getStringArray(R.array.titleOfIntros)[position]
        binding.content.text = resources.getStringArray(R.array.contentOfIntros)[position]
        return binding.root
    }

    companion object {
        fun newInstance(position: Int) : SlideIntroFragment {
            val fragment = SlideIntroFragment()
            val args = Bundle()
            args.putInt("position", position)
            fragment.arguments = args
            return fragment
        }

    }

}