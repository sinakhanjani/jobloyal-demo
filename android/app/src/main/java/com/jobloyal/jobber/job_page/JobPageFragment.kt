package com.jobloyal.jobber.job_page

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.activity.OnBackPressedCallback
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.findNavController
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.jobloyal.R
import com.jobloyal.databinding.JobPageFragmentBinding
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.jobber.adapter.ServiceInJobAdapter
import com.jobloyal.utility.AlertDialogFactory
import com.jobloyal.utility.RxFragment


class JobPageFragment : RxFragment<JobPageViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private var _binding: JobPageFragmentBinding? = null
    private val binding get() = _binding!!
    lateinit var adapter: ServiceInJobAdapter
    private val args: JobPageFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(JobPageViewModel::class.java)
        _binding = JobPageFragmentBinding.inflate(inflater, container, false)

        binding.jobTitleTv.text = args.jobTitle?.toUpperCase()
        viewModel.isNewJob = true
        viewModel.jobId = args.jobId
        switchToEmptyPageMode(true)
        adapter = ServiceInJobAdapter {
            handleDeleteDialog(it)
        }
        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.recyclerView.adapter = adapter
        binding.backBtn.setOnClickListener { findNavController().popBackStack() }
        return binding.root
    }

    private fun switchToEmptyPageMode(emptyPage: Boolean) {
        if (emptyPage) {
            binding.commentButton.visibility = View.INVISIBLE
            binding.descriptionAddService.visibility = View.VISIBLE
        } else {
            binding.commentButton.visibility = View.VISIBLE
            binding.descriptionAddService.visibility = View.GONE
        }
    }

    fun handleDeleteDialog(position: Int) {
        AlertDialogFactory(requireActivity())
            .confirmDialog(
                getString(R.string.delete),
                getString(R.string.deleteServiceInJobSubtitle, adapter.getTitle(position)),
                getString(R.string.deleteServiceInJobDescription),
                {
                    it.dismiss()
                    adapter.loadingMode(true, position)
                    viewModel.deleteService(adapter.getID(position))
                        .subscribe({
                            if (!it) adapter.loadingMode(false, position)
                            else adapter.deleteItem(position)
                        }, {
                            adapter.loadingMode(false, position)
                        })
                }) {
                it.dismiss()
            }.show()
    }


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.viewFlipper.displayedChild = if (it) 0 else 1
        }
        binding.commentButton.setOnClickListener {
            findNavController().navigate(
                JobPageFragmentDirections.actionJobPageFragmentToJobberCommentFragment(
                    args.jobId
                )
            )
        }
        binding.addService.setOnClickListener {
            if (viewModel.first) {
                (activity as? JobberActivity)?.viewModel?.state = "back_to_jobs_tab";
                viewModel.first = false;
            }
            findNavController().navigate(
                JobPageFragmentDirections.actionJobPageFragmentToSearchToAddServiceFragment(
                    args.jobId,
                    viewModel.isNewJob ?: false
                )
            )
        }
        viewModel.getAllServices()
        addToDisposableBag(viewModel.jobPage.subscribe {
            switchToEmptyPageMode(false)
            viewModel.isNewJob = it.request_count == null
            it.services?.let { adapter.replace(it) }
            binding.totalIncomeTv.text = it.total_income ?: "0"
            binding.doneJobsCountTv.text = it.work_count?.toString() ?: "0"
            binding.allRequestCountTv.text = it.request_count?.toString() ?: "0"
            binding.avgCommentTv.text = it.rate ?: "0.0"
            binding.raitingBar.rating = it.rate?.toFloat() ?: 0f
            binding.allCommentCountTv.text =
                getString(R.string.fromNComment, it.total_comments ?: "0")
        })

    }
}