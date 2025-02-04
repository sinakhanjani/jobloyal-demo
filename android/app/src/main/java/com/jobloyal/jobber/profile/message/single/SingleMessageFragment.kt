package com.jobloyal.jobber.profile.message.single

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.jobloyal.R
import com.jobloyal.databinding.MessageFragmentBinding
import com.jobloyal.databinding.SingleMessageFragmentBinding
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.dateToFormat

class SingleMessageFragment : RxFragment<SingleMessageViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private var _binding: SingleMessageFragmentBinding? = null
    private val binding get() = _binding!!
    private val args : SingleMessageFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(SingleMessageViewModel::class.java)
        _binding = SingleMessageFragmentBinding.inflate(inflater, container, false)


        bindViews()
        binding.backBtn.setOnClickListener { findNavController().navigateUp() }
        return binding.root
    }

    fun bindViews () {
        binding.answer.text = args.message?.description
        binding.dateOfQuestionTv.text = args.message?.createdAt?.dateToFormat("MM-dd-yyyy")
        binding.subjectTv.text = args.message?.subject
        binding.descriptionTV.text = args.message?.description
        binding.answer.text = args.message?.reply?.answer
        if (args.message?.reply?.answer?.length ?: 0 < 2) {
            binding.answerBox.visibility = View.GONE
        }
    }
}