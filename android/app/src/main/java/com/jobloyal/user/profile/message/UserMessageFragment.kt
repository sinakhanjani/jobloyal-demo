package com.jobloyal.user.profile.message

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.jobloyal.R
import com.jobloyal.databinding.MessageFragmentBinding
import com.jobloyal.jobber.adapter.MessageAdapter
import com.jobloyal.jobber.profile.message.MessageViewModel
import com.jobloyal.utility.Const.Companion.getIsJobberApp
import com.jobloyal.utility.RxFragment

class UserMessageFragment  : RxFragment<MessageViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
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
                findNavController().navigate(UserMessageFragmentDirections.actionUserMessageFragmentToUserSingleMessageFragment(adapter.getMessage(position = it)))
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
            findNavController().navigate(R.id.action_userMessageFragment_to_sendMessageFragment2)
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