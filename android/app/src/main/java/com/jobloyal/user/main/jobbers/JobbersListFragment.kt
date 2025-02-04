package com.jobloyal.user.main.jobbers

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.findNavController
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.jobloyal.R
import com.jobloyal.databinding.JobbersListFragmentBinding
import com.jobloyal.databinding.UserCategoryFragmentBinding
import com.jobloyal.user.adapter.JobbersListAdapter
import com.jobloyal.user.main.UserMainFragment
import com.jobloyal.user.main.UserMainFragmentDirections
import com.jobloyal.utility.EndlessRecyclerOnScrollListener
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.getMeter
import java.util.*

class JobbersListFragment : RxFragment<JobbersListViewModel>() {

    private var _binding: JobbersListFragmentBinding? = null
    private val binding get() = _binding!!
    private lateinit var adapter : JobbersListAdapter
    private val args : JobbersListFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(JobbersListViewModel::class.java)
        _binding = JobbersListFragmentBinding.inflate(inflater, container, false)
        binding.title.text = args.jobTitle.capitalize(Locale.getDefault())
        viewModel.jobId = args.jobId
        viewModel.serviceId = args.serviceId
        (parentFragment?.parentFragment as? UserMainFragment)?.cameraPosition?.let {
            viewModel.lat = it.latitude
            viewModel.long = it.longitude
        }
        adapter = JobbersListAdapter {
            val jobber = adapter.getModel(it)
            activity?.findNavController(R.id.nav_host_fragment)?.navigate(UserMainFragmentDirections.actionUserMainFragmentToJobberPageFragment(jobber.jobber_id, jobber.job_id, args.jobTitle, jobber.distance.getMeter(),viewModel.lat as java.lang.Double, viewModel.long as java.lang.Double))
        }
        binding.recyclerView.adapter = adapter
        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())

        binding.backBtn.setOnClickListener {
            findNavController().popBackStack()
        }
        binding.recyclerView.addOnScrollListener(object: EndlessRecyclerOnScrollListener() {
            override fun onLoadMore() {
                viewModel.page++
                if (args.serviceId != null)
                    viewModel.getJobbersByServiceId()
                else
                    viewModel.getJobbersByJobId()
            }
        })
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        addToDisposableBag(viewModel.jobbers.subscribe {
            if (binding.viewFlipper.displayedChild == 0)
                if (it.isEmpty()) binding.viewFlipper.displayedChild = 2 else binding.viewFlipper.displayedChild = 1
            if (viewModel.page == 0) adapter.replace(it)
            else adapter.append(it)
        })

        if (args.serviceId != null)
            viewModel.getJobbersByServiceId()
        else
            viewModel.getJobbersByJobId()
    }
    override fun onResume() {
        super.onResume()
        (requireParentFragment().parentFragment as? UserMainFragment)?.hideToolbar()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        (requireParentFragment().parentFragment as? UserMainFragment)?.showToolbar()
    }

}