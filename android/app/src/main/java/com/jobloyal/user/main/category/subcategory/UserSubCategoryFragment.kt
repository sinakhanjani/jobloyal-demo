package com.jobloyal.user.main.category.subcategory

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
import com.jobloyal.databinding.UserCategoryFragmentBinding
import com.jobloyal.databinding.UserSubCategoryFragmentBinding
import com.jobloyal.user.adapter.UserCategoryAdapter
import com.jobloyal.utility.RxFragment
import java.util.*

class UserSubCategoryFragment : RxFragment<UserSubCategoryViewModel>() {


    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: UserSubCategoryFragmentBinding? = null
    private val binding get() = _binding!!
    private lateinit var adapter : UserCategoryAdapter
    val args : UserSubCategoryFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(UserSubCategoryViewModel::class.java)
        _binding = UserSubCategoryFragmentBinding.inflate(inflater, container, false)
        binding.titleOfBox.text = args.categoryTitle?.capitalize(Locale.getDefault())

        adapter = UserCategoryAdapter {
            if (args.catId == null) {
                if (adapter.getChildOf(it) == null)
                    findNavController().navigate(UserSubCategoryFragmentDirections.actionUserSubCategoryFragmentSelf(categories = null, adapter.getTitleOf(position = it), adapter.getIdOf(position = it)))
                else
                    findNavController().navigate(UserSubCategoryFragmentDirections.actionUserSubCategoryFragmentSelf(categories = adapter.getChildOf(position = it), adapter.getTitleOf(position = it), null))
            }
            else {
                findNavController().navigate(UserSubCategoryFragmentDirections.actionUserSubCategoryFragmentToJobbersListFragment(adapter.getIdOf(it), null, adapter.getTitleOf(it) ?: ""))
            }
        }
        binding.titleOfBox.setOnClickListener {
            findNavController().popBackStack()
        }
        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.recyclerView.adapter = adapter

        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        addToDisposableBag(viewModel.jobs.subscribe {
            binding.waitingFlipper.displayedChild = 0
            adapter.replace(it)
        })

        if (args.catId == null) {
            if (args.categories?.size ?: 0 > 0)
                adapter.replace(args.categories?.toList()!!)
        }
        else {
            viewModel.categoryId = args.catId
            binding.waitingFlipper.displayedChild = 1
            viewModel.getJobs()
        }
    }

}