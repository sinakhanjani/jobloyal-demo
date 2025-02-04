package com.jobloyal.jobber.category.jobs

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.findNavController
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.jobloyal.R
import com.jobloyal.databinding.CategoryFragmentBinding
import com.jobloyal.jobber.adapter.JobberCategoryAdapter
import com.jobloyal.jobber.category.CategoryFragmentDirections
import com.jobloyal.jobber.main.JobberMainFragmentDirections
import com.jobloyal.utility.RxFragment

class JobsCategoryFragment : RxFragment<JobsCategoryViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    lateinit var adapter: JobberCategoryAdapter
    private var _binding: CategoryFragmentBinding? = null
    private val binding get() = _binding!!
    val args : JobsCategoryFragmentArgs by navArgs()


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(JobsCategoryViewModel::class.java)
        _binding = CategoryFragmentBinding.inflate(inflater, container, false)
        binding.pageTitle.setText(R.string.selectYourSkill)
        viewModel.categoryId = args.categoryId

        adapter = JobberCategoryAdapter { position ->
            if (adapter.getIdentifierOf(position) != null) {
                val jobberMainFragment =
                    JobberMainFragmentDirections.actionMainJobberFragmentToJobPageFragment(
                        adapter.getIdentifierOf(position), true, adapter.getTitleOf(position)
                    )
                activity?.findNavController(R.id.nav_host_fragment)?.navigate(jobberMainFragment)
            }
        }
        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.recyclerView.adapter = adapter

        binding.backBtn.setOnClickListener { findNavController().popBackStack() }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        addToDisposableBag(viewModel.jobs.subscribe {
            binding.viewFlipper.displayedChild = 1
            adapter.replaceCategories(it)
        })
        viewModel.getCategories()
    }

}