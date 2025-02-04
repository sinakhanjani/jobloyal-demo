package com.jobloyal.jobber.job_page.comment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.jobloyal.databinding.UserCommentFragmentBinding
import com.jobloyal.user.adapter.CommentAdapter
import com.jobloyal.user.comment.UserCommentFragmentArgs
import com.jobloyal.user.comment.UserCommentViewModel
import com.jobloyal.utility.EndlessRecyclerOnScrollListener
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.transparentStatusBar

class JobberCommentFragment  : RxFragment<JobberCommentViewModel>() {

    private var _binding: UserCommentFragmentBinding? = null
    private lateinit var adapter: CommentAdapter
    private val binding get() = _binding!!
    private val args : JobberCommentFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        viewModel = ViewModelProvider(this).get(JobberCommentViewModel::class.java)
        _binding = UserCommentFragmentBinding.inflate(inflater, container, false)
        activity?.transparentStatusBar(false)
        viewModel.jobId = args.jobId

        adapter = CommentAdapter()
        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.recyclerView.adapter = adapter
        binding.backBtn.setOnClickListener { findNavController().popBackStack() }
        binding.recyclerView.addOnScrollListener(object: EndlessRecyclerOnScrollListener() {
            override fun onLoadMore() {
                viewModel.page++
                viewModel.getComments()
            }
        })
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        addToDisposableBag(viewModel.comments.subscribe {
            if (viewModel.page == 0)
                adapter.append(it)
        })

        viewModel.waiting.observe(viewLifecycleOwner, {
            if (it) adapter.showLoading() else adapter.hideLoading()
        })

        viewModel.getComments()
    }

    override fun onStop() {
        super.onStop()
        activity?.transparentStatusBar(true)
    }
}