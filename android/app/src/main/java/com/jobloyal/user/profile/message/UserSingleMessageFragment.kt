package com.jobloyal.user.profile.message

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.jobloyal.databinding.SingleMessageFragmentBinding
import com.jobloyal.jobber.profile.message.single.SingleMessageFragmentArgs
import com.jobloyal.jobber.profile.message.single.SingleMessageViewModel
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.dateToFormat
import com.jobloyal.utility.transparentStatusBar

class UserSingleMessageFragment : RxFragment<SingleMessageViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: SingleMessageFragmentBinding? = null
    private val binding get() = _binding!!
    private val args : SingleMessageFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(SingleMessageViewModel::class.java)
        _binding = SingleMessageFragmentBinding.inflate(inflater, container, false)
        activity?.transparentStatusBar(false)

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