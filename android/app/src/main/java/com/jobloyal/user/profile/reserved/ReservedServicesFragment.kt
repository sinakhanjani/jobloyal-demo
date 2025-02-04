package com.jobloyal.user.profile.reserved

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
import com.jobloyal.databinding.ReservedServicesFragmentBinding
import com.jobloyal.databinding.UserProfileFragmentBinding
import com.jobloyal.user.adapter.ReservedReportAdapter
import com.jobloyal.utility.RxFragment

class ReservedServicesFragment : RxFragment<ReservedServicesViewModel>() {

    private var _binding: ReservedServicesFragmentBinding? = null
    private val binding get() = _binding!!
    lateinit var adapter : ReservedReportAdapter
    val args : ReservedServicesFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(ReservedServicesViewModel::class.java)
        _binding = ReservedServicesFragmentBinding.inflate(inflater, container, false)
        viewModel.accepted = args.reserved
        adapter = ReservedReportAdapter(args.reserved)
        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.recyclerView.adapter = adapter
        binding.backBtn.setOnClickListener {
            findNavController().popBackStack()
        }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        addToDisposableBag(viewModel.services.subscribe {
            binding.loadingFlipper.displayedChild = 1
            if (viewModel.page == 0) adapter.replace(it)
        })

        viewModel.getServices()
    }


}