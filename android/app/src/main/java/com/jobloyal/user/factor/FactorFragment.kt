package com.jobloyal.user.factor

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.jobloyal.R
import com.jobloyal.databinding.FactorFragmentBinding
import com.jobloyal.databinding.UserInvoiceFragmentBinding
import com.jobloyal.user.UserActivity
import com.jobloyal.user.adapter.UserInvoiceAdapter
import com.jobloyal.user.invoice.UserInvoiceViewModel
import com.jobloyal.user.model.request.ServiceInCreateNewRequest
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.getFranc
import com.jobloyal.utility.toHourAndMin
import com.stripe.android.paymentsheet.PaymentSheet
import com.stripe.android.paymentsheet.PaymentSheetResult

class FactorFragment : RxFragment<UserInvoiceViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: FactorFragmentBinding? = null
    private val binding get() = _binding!!
    var sum = 0f
    private val args : FactorFragmentArgs by navArgs()
    private lateinit var paymentSheet: PaymentSheet

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(UserInvoiceViewModel::class.java)
        _binding = FactorFragmentBinding.inflate(inflater, container, false)
        sum = args.totalPrice
        binding.titleOfService.text = args.serviceTitle?.capitalize()
        binding.price.text = args.price.getFranc()
        binding.countTV.text = args.totalTimeInterval.toHourAndMin()
        binding.backBtn.setOnClickListener {
            findNavController().popBackStack()
        }

        return binding.root
    }

    private fun totalPayUpdate () {
        val walletAmount = viewModel.wallet.value ?: 0f
        val payable = (if (sum - walletAmount > 0) sum - walletAmount else 0f).getFranc()
        binding.sumAndCommission.text = sum.getFranc()
        binding.totalPayTV.text = payable
        binding.totalPayableTV.text = payable
        binding.totalPayableWithWallet.text = payable

    }

    private fun refreshRequestStatus () {
        (activity as? UserActivity)?.viewModel?.getLastRequestDetail()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        paymentSheet = PaymentSheet(this) { result ->
            onPaymentSheetResult(result)
        }

        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.nextAndRequestBtn.delegate.setBackgroundColor(ContextCompat.getColor(requireContext(), if (!it) R.color.blue_500 else R.color.disabled_button_background))
            binding.nextAndRequestBtn.text = if (it) getString(R.string.sending) else getString(R.string.next_and_pay)
        }
        viewModel.navigate.observe(viewLifecycleOwner) {
            if (it == 2) {
                refreshRequestStatus()
            }
            else if (it == 3) {
                presentPaymentSheet()
            }
        }
        binding.nextAndRequestBtn.setOnClickListener {
            if (viewModel.payInfoResultModel == null) viewModel.pay()
            else presentPaymentSheet()
        }
        addToDisposableBag(viewModel.wallet.subscribe {
            if (it == 0f) {
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

    private fun presentPaymentSheet() {
        viewModel.payInfoResultModel?.client_secret?.let {secret ->
            paymentSheet.presentWithPaymentIntent(
                secret,
                PaymentSheet.Configuration(
                    merchantDisplayName = "Jobloyal"
                )
            )
        }
    }
    private fun onPaymentSheetResult(
        paymentSheetResult: PaymentSheetResult
    ) {
        when(paymentSheetResult) {
            is PaymentSheetResult.Canceled -> {
                Toast.makeText(
                    requireContext(),
                    "Payment Canceled",
                    Toast.LENGTH_LONG
                ).show()
            }
            is PaymentSheetResult.Failed -> {
                Toast.makeText(
                    requireContext(),
                    "Payment Failed" + " " + paymentSheetResult.error,
                    Toast.LENGTH_LONG
                ).show()
                Log.e("App", "Got error: ${paymentSheetResult.error}")
            }
            is PaymentSheetResult.Completed -> {
                viewModel.checkPayment()
            }
        }
    }


}