package com.jobloyal.jobber.profile.message

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.jobloyal.R
import com.jobloyal.databinding.AuthenticationFragmentBinding
import com.jobloyal.databinding.MessageFragmentBinding
import com.jobloyal.jobber.adapter.MessageAdapter
import com.jobloyal.utility.Const.Companion.getIsJobberApp
import com.jobloyal.utility.RxFragment

class MessageFragment : RxFragment<MessageViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private lateinit var adapter: MessageAdapter
    private var _binding: MessageFragmentBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(MessageViewModel::class.java)
        _binding = MessageFragmentBinding.inflate(inflater, container, false)

        adapter = MessageAdapter {
            if (requireActivity().getIsJobberApp() == true) {
                findNavController().navigate(MessageFragmentDirections.actionMessageFragmentToSingleMessageFragment(adapter.getMessage(position = it)))
            }
        }
        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.recyclerView.adapter = adapter

        binding.backButton.setOnClickListener {
            findNavController().navigateUp()
        }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.newTicket.setOnClickListener {
            findNavController().navigate(R.id.action_messageFragment_to_sendMessageFragment)
        }

        addToDisposableBag(viewModel.messages.subscribe {
            if (it.isNotEmpty()) {
                binding.notFoundBox.visibility = View.GONE
                binding.recyclerView.visibility = View.VISIBLE
                adapter.addMessages(it)
            }
        })
        viewModel.getAllMessages()
    }

}