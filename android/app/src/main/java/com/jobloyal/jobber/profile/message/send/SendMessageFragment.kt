package com.jobloyal.jobber.profile.message.send

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController
import com.jobloyal.R
import com.jobloyal.databinding.MessageFragmentBinding
import com.jobloyal.databinding.SendMessageFragmentBinding
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.toast
import com.jobloyal.utility.transparentStatusBar

class SendMessageFragment : RxFragment<SendMessageViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private var _binding: SendMessageFragmentBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(SendMessageViewModel::class.java)
        activity?.transparentStatusBar(false)
        _binding = SendMessageFragmentBinding.inflate(inflater, container, false)

        binding.backBtn.setOnClickListener {
            findNavController().popBackStack()
        }
        return binding.root
    }

    override fun onDestroy() {
        super.onDestroy()
        activity?.transparentStatusBar(true)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.navigate.observe(viewLifecycleOwner) {
            if (it == 1) {
                findNavController().popBackStack()
            }
        }
        binding.nextButton.setOnClickListener {
            if (binding.subjectET.editText?.text.toString().isNotEmpty() && binding.descriptionET.editText?.text.toString().isNotEmpty()) {
                viewModel.sendNewMessage(
                    binding.subjectET.editText?.text.toString(),
                    binding.descriptionET.editText?.text.toString()
                )
            }
            else {
                activity?.toast(R.string.pleaseComplete)
            }
        }

        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.nextButton.setWaiting(it)
        }
    }

}