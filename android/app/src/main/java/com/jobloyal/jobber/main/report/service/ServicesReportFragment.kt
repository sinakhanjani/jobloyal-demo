package com.jobloyal.jobber.main.report.service

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.jobloyal.R
import com.jobloyal.databinding.JobberReportFragmentBinding
import com.jobloyal.databinding.ServicesReportFragmentBinding
import com.jobloyal.jobber.adapter.JobberAcceptedServices
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.dateToFormat
import com.jobloyal.utility.getFranc
import java.util.*

class ServicesReportFragment : RxFragment<ServicesReportViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = true
    private var _binding: ServicesReportFragmentBinding? = null
    private val binding get() = _binding!!
    private val args : ServicesReportFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(ServicesReportViewModel::class.java)
        _binding = ServicesReportFragmentBinding.inflate(inflater, container, false)

        viewModel.requestId = args.report?.id

        binding.jobTitleTv.text = args.report?.job_title?.capitalize(Locale.ROOT)
        binding.addressTv.text = args.report?.address
        binding.dateTv.text = args.report?.created_at?.dateToFormat("yy/MM/dd HH:mm")
        binding.tag.delegate.setBackgroundColor(ContextCompat.getColor(requireContext(), if (args.report?.tag == "accepted") R.color.blue_700 else R.color.grayBlack))
        if (args.report?.tag == "accepted") binding.tag.setText( R.string.accepted)
        else binding.tag.text = args.report?.tag

        binding.acceptedServicesRecyclerView.isNestedScrollingEnabled = false
        binding.rejectedRecyclerView.isNestedScrollingEnabled = false

        binding.rejectedRecyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.acceptedServicesRecyclerView.layoutManager = LinearLayoutManager(requireContext())

        binding.backBtn.setOnClickListener {
            findNavController().popBackStack()
        }

        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        addToDisposableBag(viewModel.services.subscribe {
            binding.loadingFlipper.displayedChild = 1
            if (it.isNotEmpty()) {
                if (args.report?.tag == "accepted") {
                    if (it.size == 1 && it.first().unit == null) {
                        if (it.first().accepted == true) {
                            binding.acceptedServicesRecyclerView.adapter =
                                JobberAcceptedServices(it, true) {}
                            binding.rejectedTitle.visibility = View.GONE
                            binding.totalIncome.text =
                                it.first().let {(it.total_price ?: it.price).getFranc() }
                        } else {
                            binding.rejectedRecyclerView.adapter =
                                JobberAcceptedServices(it, true) {}
                            binding.acceptedServicesTitle.visibility = View.GONE
                            binding.totalSum.visibility = View.GONE
                        }
                    } else {
                        val accepted = it.filter { it.accepted == true }
                        val rejected = it.filter { it.accepted == false }
                        if (accepted.isEmpty()) {
                            binding.acceptedServicesTitle.visibility = View.GONE
                            binding.totalSum.visibility = View.GONE
                        } else {
                            binding.acceptedServicesRecyclerView.adapter =
                                JobberAcceptedServices(accepted, true) {}
                            binding.totalIncome.text =
                                accepted.sumByDouble { it.total_price ?: 0.0 }.getFranc()
                        }
                        if (rejected.isEmpty()) {
                            binding.rejectedTitle.visibility = View.GONE
                        } else {
                            binding.rejectedRecyclerView.adapter =
                                JobberAcceptedServices(rejected, true) {}
                        }
                    }
                }
                else {
                    binding.rejectedRecyclerView.adapter =
                        JobberAcceptedServices(it, true) {}
                    binding.acceptedServicesTitle.visibility = View.GONE
                    binding.totalSum.visibility = View.GONE
                }

            }
        })
        viewModel.getServicesOfRequest()
    }

}