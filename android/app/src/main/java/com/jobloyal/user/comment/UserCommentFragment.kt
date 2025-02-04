package com.jobloyal.user.comment

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.jobloyal.R
import com.jobloyal.databinding.UserCommentFragmentBinding
import com.jobloyal.databinding.UserInvoiceFragmentBinding
import com.jobloyal.user.adapter.CommentAdapter
import com.jobloyal.user.adapter.UserInvoiceAdapter
import com.jobloyal.user.invoice.UserInvoiceFragmentArgs
import com.jobloyal.utility.EndlessRecyclerOnScrollListener
import com.jobloyal.utility.RxFragment
import org.w3c.dom.Comment

class UserCommentFragment : RxFragment<UserCommentViewModel>() {

    private var _binding: UserCommentFragmentBinding? = null
    private lateinit var adapter: CommentAdapter
    private val binding get() = _binding!!
    private val args : UserCommentFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        viewModel = ViewModelProvider(this).get(UserCommentViewModel::class.java)
        _binding = UserCommentFragmentBinding.inflate(inflater, container, false)

        Log.i("sdfsdfdsf","jobid: ${args.jobId}   jobberId : ${args.jobberId}")
        viewModel.jobId = args.jobId
        viewModel.jobberId = args.jobberId

        adapter = CommentAdapter()
        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.recyclerView.adapter = adapter
        binding.recyclerView.addOnScrollListener(object: EndlessRecyclerOnScrollListener() {
            override fun onLoadMore() {
                viewModel.page++
                viewModel.getComments()
            }
        })
        binding.backBtn.setOnClickListener { findNavController().popBackStack() }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        addToDisposableBag(viewModel.comments.subscribe {
            if (viewModel.page == 0)
                adapter.replace(it)
        })

        viewModel.waiting.observe(viewLifecycleOwner, {
            if (it) adapter.showLoading() else adapter.hideLoading()
        })

        viewModel.getComments()
    }

}