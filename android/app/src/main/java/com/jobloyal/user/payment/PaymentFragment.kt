package com.jobloyal.user.payment

import android.content.Intent
import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContract
import androidx.activity.result.contract.ActivityResultContracts
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.jobloyal.R
import com.jobloyal.databinding.PaymentFragmentBinding
import com.jobloyal.databinding.UserProfileFragmentBinding
import com.jobloyal.user.profile.UserProfileViewModel
import com.jobloyal.utility.RxFragment
import com.stripe.android.PaymentConfiguration
import com.stripe.android.Stripe
import com.stripe.android.getPaymentIntentResult
import com.stripe.android.model.ConfirmPaymentIntentParams
import com.stripe.android.model.StripeIntent
import com.stripe.android.paymentsheet.PaymentSheet
import com.stripe.android.paymentsheet.PaymentSheetResult
import kotlinx.coroutines.launch
import java.lang.ref.WeakReference

class PaymentFragment  : RxFragment<PaymentViewModel>() {

    private var _binding: PaymentFragmentBinding? = null
    private val binding get() = _binding!!
    private lateinit var paymentIntentClientSecret: String
    private lateinit var stripe: Stripe
    private val args : PaymentFragmentArgs by navArgs()


    private lateinit var paymentSheet: PaymentSheet

    private lateinit var customerId: String
    private lateinit var ephemeralKeySecret: String


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(PaymentViewModel::class.java)
        _binding = PaymentFragmentBinding.inflate(inflater, container, false)
        paymentIntentClientSecret = args.payInfo?.client_secret ?: ""
        customerId = args.payInfo?.customer ?: ""
        ephemeralKeySecret = args.payInfo?.ephemeral_key ?: ""

        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        paymentSheet = PaymentSheet(this) { result ->
            onPaymentSheetResult(result)
        }
        binding.payButton.setOnClickListener {
            presentPaymentSheet()
        }
    }
    private fun presentPaymentSheet() {
        paymentSheet.presentWithPaymentIntent(
            paymentIntentClientSecret,
            PaymentSheet.Configuration(
                merchantDisplayName = "Example, Inc.",
                customer = PaymentSheet.CustomerConfiguration(
                    id = customerId,
                    ephemeralKeySecret = ephemeralKeySecret
                )
            )
        )
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
                    "Payment Failed. See logcat for details.",
                    Toast.LENGTH_LONG
                ).show()
                Log.e("App", "Got error: ${paymentSheetResult.error}")
            }
            is PaymentSheetResult.Completed -> {
                Toast.makeText(
                    requireContext(),
                    "Payment Complete",
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    }
//    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
//        super.onViewCreated(view, savedInstanceState)
//        binding.payButton.setOnClickListener {
//            val params = binding.cardInputWidget.paymentMethodCreateParams
//            Log.i("dsfsdfsdfsdfsdf324555", "params: $params")
//
//            if (params != null) {
//
//                val confirmParams = ConfirmPaymentIntentParams
//                    .createWithPaymentMethodCreateParams(params, paymentIntentClientSecret)
//                stripe = Stripe(requireContext(), PaymentConfiguration.getInstance(requireContext()).publishableKey)
//                stripe.confirmPayment(this, confirmParams)
//            }
//        }
//    }

}