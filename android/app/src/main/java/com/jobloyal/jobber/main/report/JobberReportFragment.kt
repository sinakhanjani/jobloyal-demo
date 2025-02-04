package com.jobloyal.jobber.main.report

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.jobloyal.R
import com.jobloyal.databinding.JobberReportFragmentBinding
import com.jobloyal.databinding.JobberRequestsFragmentBinding
import com.jobloyal.jobber.adapter.JobberReportAdapter
import com.jobloyal.utility.EndlessRecyclerOnScrollListener
import com.jobloyal.utility.RxFragment

class JobberReportFragment : RxFragment<JobberReportViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private lateinit var adapter : JobberReportAdapter
    private var _binding: JobberReportFragmentBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(JobberReportViewModel::class.java)
        _binding = JobberReportFragmentBinding.inflate(inflater, container, false)

        adapter = JobberReportAdapter {
            findNavController().navigate(JobberReportFragmentDirections.actionNavigationReportToServicesReportFragment(adapter.getService(position = it)))
        }
        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.recyclerView.adapter = adapter
        binding.recyclerView.addOnScrollListener(object: EndlessRecyclerOnScrollListener() {
            override fun onLoadMore() {
                viewModel.page++
                viewModel.getReports()
            }
        })

        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        addToDisposableBag(viewModel.reports.subscribe {
            if (binding.loadingFlipper.displayedChild == 0)
                if (it.isEmpty()) binding.loadingFlipper.displayedChild = 2 else binding.loadingFlipper.displayedChild = 1
            adapter.append(it)
        })

        viewModel.waiting.observe(viewLifecycleOwner, {
            if (it) adapter.showLoading() else adapter.hideLoading()
        })

        if (!viewModel.loaded) {
            viewModel.page = 0
            viewModel.getReports()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        Log.i("VIEWESTROID","sdfsdfdsdf")
    }

}