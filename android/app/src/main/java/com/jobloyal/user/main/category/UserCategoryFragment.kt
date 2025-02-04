package com.jobloyal.user.main.category

import android.annotation.SuppressLint
import android.graphics.drawable.Animatable
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import androidx.core.view.updateLayoutParams
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.findNavController
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.textfield.TextInputLayout
import com.jobloyal.R
import com.jobloyal.databinding.UserCategoryFragmentBinding
import com.jobloyal.jobber.category.CategoryFragmentDirections
import com.jobloyal.user.adapter.UserCategoryAdapter
import com.jobloyal.user.adapter.UserSearchServiceResultAdapter
import com.jobloyal.user.main.category.subcategory.UserSubCategoryFragmentArgs
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.getWidowsPhoneSize
import com.jobloyal.utility.px
import java.util.*

class UserCategoryFragment : RxFragment<UserCategoryViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private lateinit var categoryAdapter : UserCategoryAdapter
    private lateinit var searchServiceAdapter : UserSearchServiceResultAdapter
    private var _binding: UserCategoryFragmentBinding? = null
    private val binding get() = _binding!!

    var heightOfRecyclerView = 0

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(UserCategoryViewModel::class.java)
        _binding = UserCategoryFragmentBinding.inflate(inflater, container, false)

        categoryAdapter = UserCategoryAdapter {
            if (categoryAdapter.getChildOf(it) == null) {
                findNavController().navigate(UserCategoryFragmentDirections.actionUserCategoryFragmentToUserSubCategoryFragment(categories = null, categoryAdapter.getTitleOf(position = it), categoryAdapter.getIdOf(position = it)))
            } else {
                findNavController().navigate(UserCategoryFragmentDirections.actionUserCategoryFragmentToUserSubCategoryFragment(categories = categoryAdapter.getChildOf(position = it), categoryAdapter.getTitleOf(position = it), null))
            }
        }
        searchServiceAdapter = UserSearchServiceResultAdapter {
            val service = searchServiceAdapter.getModel(position = it)
            findNavController().navigate(UserCategoryFragmentDirections.actionUserCategoryFragmentToJobbersListFragment(service.job_id, service.service_id, service.job_title ?: ""))
        }
        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        switchBox(true)

        binding.profileBtn.setOnClickListener {
            activity?.findNavController(R.id.nav_host_fragment)?.navigate(R.id.action_userMainFragment_to_userProfileFragment)
        }
        return binding.root
    }


    fun switchBox (toCategory: Boolean) {
        if (toCategory) {
            binding.titleOfBox.setText(R.string.titleOfCategoryBox)
            binding.recyclerView.adapter = categoryAdapter
        }
        else {
            binding.titleOfBox.setText(R.string.titleOfServiceSearch)
            binding.recyclerView.adapter = searchServiceAdapter
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        addToDisposableBag(viewModel.searchedServices.subscribe {
            binding.appbar.setExpanded(false, true)
            searchServiceAdapter.replace(it)
            hideSearchLoading()
        })

        addToDisposableBag(viewModel.categories.subscribe {
            categoryAdapter.replace(it)
        })
        viewModel.getCategories()
        binding.searchET.setOnClickListener {
            binding.appbar.setExpanded(false, true)
        }
        binding.searchET.setOnFocusChangeListener { view, b ->
            if (b) binding.appbar.setExpanded(false, true)
        }
        binding.searchET.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
            private var timer: Timer = Timer()
            private val DELAY: Long = 300
            override fun afterTextChanged(p0: Editable?) {
                switchBox(p0.toString().isEmpty())
                showSearchLoading()
                if (p0.toString().isEmpty()) {
                    hideSearchLoading()
                }
                viewModel.disposable?.dispose()
                timer.cancel()
                timer = Timer()
                timer.schedule(
                    object : TimerTask() {
                        override fun run() {
                            activity?.runOnUiThread {
                                if (binding.searchET.text.toString().isNotEmpty()) {
                                    viewModel.searchService(binding.searchET.text.toString())
                                }
                            }
                        }
                    },
                    DELAY
                )
            }
        })
    }
    var loading = false
    private fun showSearchLoading() {
        if (!loading) {
            binding.progressSearch.visibility = View.VISIBLE
            loading = true
        }
    }

    private fun hideSearchLoading () {
        loading = false
        binding.progressSearch.visibility = View.INVISIBLE
    }


}