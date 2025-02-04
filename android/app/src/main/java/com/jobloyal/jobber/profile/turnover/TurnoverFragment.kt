package com.jobloyal.jobber.profile.turnover

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.jobloyal.R
import com.jobloyal.databinding.SuspendFragmentBinding
import com.jobloyal.databinding.TurnoverFragmentBinding
import com.jobloyal.jobber.adapter.TurnoverAdapter
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.transparentStatusBar

class TurnoverFragment : RxFragment<TurnoverViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: TurnoverFragmentBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(TurnoverViewModel::class.java)
        _binding = TurnoverFragmentBinding.inflate(inflater, container, false)
        activity?.transparentStatusBar(false)

        binding.turnoverRecyclerView.layoutManager = LinearLayoutManager(requireContext())


        binding.backBtn.setOnClickListener {
            findNavController().popBackStack()
        }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        addToDisposableBag(viewModel.turnovers.subscribe {
            binding.viewFlipper.displayedChild = 1
            if (it.isEmpty()) binding.viewFlipper.displayedChild = 2
            binding.turnoverRecyclerView.adapter = TurnoverAdapter(it) {}
        })
        viewModel.getAllTurnover()
    }

}