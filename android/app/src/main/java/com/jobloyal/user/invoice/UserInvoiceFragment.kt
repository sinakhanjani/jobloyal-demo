package com.jobloyal.user.invoice

import android.graphics.Color
import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.jobloyal.R
import com.jobloyal.databinding.UserInvoiceFragmentBinding
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.user.UserActivity
import com.jobloyal.user.adapter.UserInvoiceAdapter
import com.jobloyal.user.adapter.UserTimeBaseInvoiceAdapter
import com.jobloyal.user.model.request.ServiceInCreateNewRequest
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.getFranc

class UserInvoiceFragment : RxFragment<UserInvoiceViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: UserInvoiceFragmentBinding? = null
    private lateinit var adapter: UserInvoiceAdapter
    private val binding get() = _binding!!
    private val args : UserInvoiceFragmentArgs by navArgs()
    private var isTimeBase = false
    private var isInvoice = true

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(UserInvoiceViewModel::class.java)
        _binding = UserInvoiceFragmentBinding.inflate(inflater, container, false)
        binding.titleOfjob.text = args.jobTitle?.capitalize()
        viewModel.jobberId = args.jobberId
        viewModel.latitude = args.lat as? Double
        viewModel.longitiude = args.lng as? Double
        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        args.services?.let {
            if (args.services?.size ?: 0 == 1 && args.services?.first()?.unit == null) {
                isTimeBase = true
                binding.payableBottomBar.visibility = View.INVISIBLE
                binding.recyclerView.adapter = UserTimeBaseInvoiceAdapter(args.services)
                totalPayUpdate()
            }
            else {
                adapter = UserInvoiceAdapter(it, requireContext()) {
                    totalPayUpdate()
                }
                binding.recyclerView.adapter = adapter
            }
        }
        binding.backBtn.setOnClickListener {
            findNavController().popBackStack()
        }

        return binding.root
    }

    private fun totalPayUpdate () {
        val walletAmount = viewModel.wallet.value ?: 0f
        if (!isTimeBase) {
            val enabled = !adapter.getServices().any { it.count == null }
            binding.nextAndRequestBtn.isEnabled = enabled
            binding.nextAndRequestBtn.delegate.setBackgroundColor(ContextCompat.getColor(requireContext(), if (enabled) R.color.blue_500 else R.color.disabled_button_background))
            val sum = adapter.getServices().sumByDouble { ((it.price ?: 0f) * (it.count ?: 0) * ((it.commission ?: 1) + 100) / 100 ).toDouble()}.toFloat()
            val payable = (if (sum - walletAmount > 0) sum - walletAmount else 0f).getFranc()
            binding.sumAndCommission.text = sum.getFranc()
            binding.totalPayTV.text = payable
            binding.totalPayableTV.text = payable
            binding.totalPayableWithWallet.text = payable
        }
        else {
            binding.titleOfTotalPay.setText(R.string.payForAnHour)
            binding.totalPayableTV.text = ((args.services?.first()?.price ?: 0f) *  ((args.services?.first()?.commission ?: 1) + 100) / 100).getFranc()
        }
    }
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.nextAndRequestBtn.delegate.setBackgroundColor(ContextCompat.getColor(requireContext(), if (!it) R.color.blue_500 else R.color.disabled_button_background))
            binding.nextAndRequestBtn.text = if (it) getString(R.string.sending) else getString(R.string.next_and_request)
        }
        viewModel.navigate.observe(viewLifecycleOwner) {
            if (it == 1) {
//                addToDisposableBag((activity as? UserActivity)?.viewModel?.lastRequest?.subscribe { if (it.data != null) findNavController().navigateUp() })
                (activity as? UserActivity)?.viewModel?.getLastRequestDetail()
                viewModel.navigate.value = 0
//                findNavController().popBackStack(R.id.userMainFragment, false)
            }
        }
        binding.nextAndRequestBtn.setOnClickListener {
            if (!isTimeBase) {
                viewModel.services = adapter.getServices().map { ServiceInCreateNewRequest(it.count, it.id) }
            }
            else {
                viewModel.services = args.services?.map { ServiceInCreateNewRequest(0, it.id) }
            }
            viewModel.sendRequest()
        }
        addToDisposableBag(viewModel.wallet.subscribe {
            if (it == 0f || (isTimeBase && isInvoice)) {
                binding.viewFlipper.displayedChild = 1
                binding.totalPayableTV.text = 0.toString()
            }
            else {
                binding.viewFlipper.displayedChild = 2
                binding.walletAmount.text = it.getFranc()
                binding.sumAndCommission.text = 0.toString()
                binding.totalPayableWithWallet.text = 0.toString()
            }
            totalPayUpdate()
        })
        viewModel.getWallet()
    }
}