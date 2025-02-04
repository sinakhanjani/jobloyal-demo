package com.jobloyal.jobber.category

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.jobloyal.R
import com.jobloyal.databinding.CategoryFragmentBinding
import com.jobloyal.databinding.JobsFragmentBinding
import com.jobloyal.jobber.adapter.JobberCategoryAdapter
import com.jobloyal.utility.RxFragment

class CategoryFragment : RxFragment<CategoryViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    lateinit var adapter: JobberCategoryAdapter
    private var _binding: CategoryFragmentBinding? = null
    private val binding get() = _binding!!
    val args: CategoryFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(CategoryViewModel::class.java)
        _binding = CategoryFragmentBinding.inflate(inflater, container, false)


        adapter = JobberCategoryAdapter { position ->
            if (adapter.getChildOf(position) == null) {
                findNavController().navigate(CategoryFragmentDirections.actionCategoryFragmentToJobsCategoryFragment(adapter.getIdentifierOf(position)))
            } else {
                findNavController().navigate(CategoryFragmentDirections.actionCategoryFragmentSelf(adapter.getChildOf(position)))
            }
        }
        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.recyclerView.adapter = adapter

        binding.backBtn.setOnClickListener { findNavController().popBackStack() }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        if (args.children != null) {
            binding.viewFlipper.displayedChild = 1
            adapter.replaceCategories(args.children!!)
        }
        else {
            addToDisposableBag(viewModel.categories.subscribe {
                binding.viewFlipper.displayedChild = 1
                adapter.replaceCategories(it)
            })
            viewModel.getCategories()
        }

    }

}