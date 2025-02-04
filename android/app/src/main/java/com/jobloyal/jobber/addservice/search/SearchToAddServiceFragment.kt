package com.jobloyal.jobber.addservice.search

import android.app.Activity
import android.content.Context
import android.graphics.drawable.Animatable
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import androidx.core.content.res.getDrawableOrThrow
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.textfield.TextInputLayout
import com.jobloyal.databinding.SearchToAddServiceFragmentBinding
import com.jobloyal.jobber.adapter.JobberSearchServiceAdapter
import com.jobloyal.jobber.model.addservice.SearchServiceModel
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.transparentStatusBar
import java.util.*


class SearchToAddServiceFragment : RxFragment<SearchToAddServiceViewModel>() {

    private var _binding: SearchToAddServiceFragmentBinding? = null
    private val binding get() = _binding!!
    lateinit var adapter : JobberSearchServiceAdapter
    private val args : SearchToAddServiceFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        viewModel = ViewModelProvider(this).get(SearchToAddServiceViewModel::class.java)
        _binding = SearchToAddServiceFragmentBinding.inflate(inflater, container, false)
        viewModel.jobId = args.jobId

        adapter = JobberSearchServiceAdapter {
            val imm = requireActivity().getSystemService(Activity.INPUT_METHOD_SERVICE) as InputMethodManager
            var view = requireActivity().currentFocus
            if (view == null) {
                view = View(activity)
            }
            imm.hideSoftInputFromWindow(view.windowToken, 0)

            val service = adapter.getService(position = it)
            findNavController().navigate(
                SearchToAddServiceFragmentDirections.actionSearchToAddServiceFragmentToNewServiceFragment(
                    args.isNewJob, args.jobId!!, service ?: SearchServiceModel(
                        title = viewModel.searchedService
                    )
                )
            )
        }
        binding.loadingIndicator.root.visibility = View.GONE
        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.recyclerView.adapter = adapter
        binding.backBtn.setOnClickListener { findNavController().popBackStack() }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        addToDisposableBag(viewModel.services.subscribe {
            binding.loadingIndicator.root.visibility = View.GONE
            hideSearchLoading()
            if (viewModel.searchedService != null && viewModel.searchedService?.isNotEmpty() == true && !viewModel.searchedService?.trim()
                    .equals(
                        it.getOrNull(
                            0
                        )?.title?.trim(), true
                    )
            ) {
                adapter.replaceServices(it, viewModel.searchedService)
            } else adapter.replaceServices(it)
        })
//        viewModel.getAllServices()

        binding.searchET.editText?.addTextChangedListener(
            object : TextWatcher {
                override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {}
                override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int) {}
                private var timer: Timer = Timer()
                private val DELAY: Long = 300
                override fun afterTextChanged(s: Editable) {
                    showSearchLoading()
                    viewModel.disposable?.dispose()
                    timer.cancel()
                    timer = Timer()
                    timer.schedule(
                        object : TimerTask() {
                            override fun run() {
                                activity?.runOnUiThread {
                                    if (binding.searchET.editText?.text.toString().isNotEmpty() && binding.searchET.editText?.text.toString().length > 2) {
                                        viewModel.searchServiceByName(binding.searchET.editText?.text.toString())
                                    } else {
                                        adapter.replaceServices(listOf(), binding.searchET.editText?.text.toString())
                                        hideSearchLoading()
                                    }
                                }
                            }
                        },
                        DELAY
                    )
                }
            }
        )


    }

    var loading = false
    private fun showSearchLoading() {
        if (!loading) {
            binding.searchET.isErrorEnabled = false
            binding.searchET.endIconMode = TextInputLayout.END_ICON_CUSTOM
            val drawable = progressDrawable()
            binding.searchET.endIconDrawable = drawable;
            (drawable as? Animatable)?.start()
            loading = true
        }
    }

    private fun hideSearchLoading () {
        loading = false
        binding.searchET.endIconMode = TextInputLayout.END_ICON_NONE
    }

    private fun progressDrawable(): Drawable {
        val value = TypedValue()
        requireActivity()?.theme.resolveAttribute(
            android.R.attr.progressBarStyleSmall,
            value,
            false
        )
        val progressBarStyle = value.data
        val attributes = intArrayOf(android.R.attr.indeterminateDrawable)
        val array = requireContext().obtainStyledAttributes(progressBarStyle, attributes)
        val drawable = array.getDrawableOrThrow(0)
        array.recycle()
        return drawable
    }

    override fun onResume() {
        super.onResume()
        activity?.transparentStatusBar(false)
        binding.searchET.post {
            binding.searchET.requestFocus()
            val imgr: InputMethodManager =
                requireActivity().getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imgr.toggleSoftInput(
                InputMethodManager.SHOW_FORCED,
                InputMethodManager.HIDE_IMPLICIT_ONLY
            );
            imgr.showSoftInput(binding.searchET, InputMethodManager.SHOW_IMPLICIT)
        }
    }

    override fun onStop() {
        super.onStop()
        activity?.transparentStatusBar(true)
    }
}