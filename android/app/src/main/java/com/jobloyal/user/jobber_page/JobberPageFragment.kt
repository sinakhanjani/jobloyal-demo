package com.jobloyal.user.jobber_page

import android.content.Intent
import android.graphics.Color
import android.net.Uri
import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.os.CountDownTimer
import android.telephony.PhoneNumberUtils
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.jobloyal.R
import com.jobloyal.databinding.JobberPageFragmentBinding
import com.jobloyal.databinding.UserMainFragmentBinding
import com.jobloyal.user.UserActivity
import com.jobloyal.user.adapter.CommentAdapter
import com.jobloyal.user.adapter.NumericServicesAdapter
import com.jobloyal.user.adapter.TimeBaseServicesAdapter
import com.jobloyal.user.adapter.UserReservedServiceAdapter
import com.jobloyal.user.model.jobber.page.JobberPageModel
import com.jobloyal.utility.*
import com.stripe.android.paymentsheet.PaymentSheet
import com.stripe.android.paymentsheet.PaymentSheetResult
import java.util.*

class JobberPageFragment : RxFragment<JobberPageViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: JobberPageFragmentBinding? = null
    private val binding get() = _binding!!
    private lateinit var timeBaseAdapter: TimeBaseServicesAdapter
    private lateinit var numericServicesAdapter: NumericServicesAdapter
    private lateinit var userReservedServiceAdapter: UserReservedServiceAdapter
    private lateinit var commentAdapter: CommentAdapter
    var requestPage = false
    private val args : JobberPageFragmentArgs by navArgs()
    var countDownTimer : CountDownTimer? = null
    private lateinit var paymentSheet: PaymentSheet

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(JobberPageViewModel::class.java)
        _binding = JobberPageFragmentBinding.inflate(inflater, container, false)
        activity?.updateStatusBarColor(Color.WHITE)
        binding.jobTitle.text = args.jobTitle?.capitalize(Locale.getDefault())

        if (args.jobId == null) {
            requestPage = true
            initializeViewsForRequestPage()
        }
        else
            initializeViewsForJobberPage()

        binding.commentRC.layoutManager = LinearLayoutManager(requireContext())
        commentAdapter = CommentAdapter()

        binding.nextButton.setOnClickListener {
            findNavController().navigate(JobberPageFragmentDirections.actionJobberPageFragmentToUserInvoiceFragment(numericServicesAdapter.getAllSelectedServices()?.toTypedArray(),args.jobberId,args.jobTitle,args.lat,args.lng))
        }
        binding.backBtn.setOnClickListener { findNavController().popBackStack() }

        return binding.root
    }

    private fun initializeViewsForRequestPage () {
        binding.reservedServiceRC.layoutManager = LinearLayoutManager(requireContext())
        userReservedServiceAdapter = UserReservedServiceAdapter {}
        binding.reservedServiceRC.adapter = userReservedServiceAdapter

        addToDisposableBag((activity as? UserActivity)?.viewModel?.lastRequest?.subscribe {
            if (viewModel.jobberPage.value != null && it.data?.status != viewModel.lastStatus) {
                viewModel.getDetailOfLastRequest()
            }
        })
    }

    private fun initializeViewsForJobberPage (){
        viewModel.jobId = args.jobId
        viewModel.jobberId = args.jobberId
        binding.distance.text = args.distance
        binding.TimeBaseServiceRC.layoutManager = LinearLayoutManager(requireContext())
        binding.numericServiceRC.layoutManager = LinearLayoutManager(requireContext())

        numericServicesAdapter = NumericServicesAdapter {
            val selection = numericServicesAdapter.getAllSelectedServices()?.size ?: 0
            if (selection == 0) {
                binding.bottomBar.visibility = View.GONE
            }
            else {
                binding.bottomBar.visibility = View.VISIBLE
                binding.countSelectedServiceTV.text = getString(R.string.servicesSelectedCount, selection)
            }
        }
        timeBaseAdapter = TimeBaseServicesAdapter {
            findNavController().navigate(JobberPageFragmentDirections.actionJobberPageFragmentToUserInvoiceFragment(
                arrayOf(timeBaseAdapter.getModel(position = it)!!),args.jobberId,args.jobTitle,args.lat,args.lng))
        }


        binding.TimeBaseServiceRC.adapter = timeBaseAdapter
        binding.numericServiceRC.adapter = numericServicesAdapter
    }


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.waitingOperation.observe(viewLifecycleOwner) {
            binding.distance.isEnabled = !it
            binding.nextAndPayButton.isEnabled = !it
            binding.verifyButton.isEnabled = !it
            if (it) {
                binding.distance.setTextColor(ContextCompat.getColor(requireContext(), R.color.disabled_button_background))
                binding.nextAndPayButton.delegate.setBackgroundColor(ContextCompat.getColor(requireContext(), R.color.disabled_button_background))
                binding.verifyButton.delegate.setBackgroundColor(ContextCompat.getColor(requireContext(), R.color.disabled_button_background))
            }
            else {
                binding.distance.setTextColor(ContextCompat.getColor(requireContext(), R.color.error))
                binding.nextAndPayButton.delegate.setBackgroundColor(ContextCompat.getColor(requireContext(), R.color.blue_500))
                binding.verifyButton.delegate.setBackgroundColor(Color.parseColor("#20A613"))
            }
            if (!it) {
                binding.waitingFlipper.displayedChild = 0
            }
        }
        viewModel.navigate.observe(viewLifecycleOwner) {
            if (it == 2) {
                refreshRequestStatus()
            }
            else if (it == 3) {
                presentPaymentSheet()
            }
        }
        addToDisposableBag(viewModel.jobberPage.subscribe {
            if (requestPage) viewModel.waitingOperation.value = false
            binding.viewFlipper.displayedChild = 1
            bindJobberInfo(it)
        })
        if (!requestPage) {
            viewModel.getJobberPage()
        }
        else {
            viewModel.getDetailOfLastRequest()
        }
        paymentSheet = PaymentSheet(this) { result ->
            onPaymentSheetResult(result)
        }
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

    private fun bindJobberInfo (jobPage : JobberPageModel) {
        binding.nameAvatar.text = jobPage.avatar
        binding.nameTV.text = jobPage.identifier
        binding.workCount.text = getString(R.string.workCount, (jobPage.work_count ?: 0).toString())
        binding.rateBar.rating = jobPage.rate?.toFloat() ?: 0f
        binding.rate.text = getString(R.string.rateAndComment,jobPage.rate ?: "0.0", (jobPage.total_comments ?: 0).toString())
        binding.aboutMeTV.text = jobPage.about_me
        binding.commentRC.adapter = commentAdapter
        if (jobPage.comments?.size ?: 0 == 0) {
            binding.commentsBox.visibility = View.GONE
        }
        else {
            commentAdapter.replace(jobPage.comments!!)
            binding.moreButton.setOnClickListener {
                findNavController().navigate(JobberPageFragmentDirections.actionJobberPageFragmentToUserCommentFragment(viewModel.jobId, viewModel.jobberId))
            }
        }
        if (!requestPage) {
            val timeBaseServices = jobPage.services?.filter { it.unit == null }
            if (timeBaseServices?.size ?: 0 > 0) {
                timeBaseServices?.let { timeBaseAdapter.replace(it) }
            } else {
                binding.timerBaseServiceBox.visibility = View.GONE
            }

            val otherServices = jobPage.services?.filter { it.unit != null }
            if (otherServices?.size ?: 0 > 0) {
                otherServices?.let { numericServicesAdapter.replace(it) }
            } else {
                binding.numericServiceBox.visibility = View.GONE
            }
        }
        else {

            binding.distance.setTextColor(ContextCompat.getColor(requireContext(), R.color.error))
            binding.avatarFlipper.displayedChild = 1
            binding.reservedServiceBox.visibility = View.VISIBLE
            binding.servicesBox.visibility = View.GONE
            jobPage.request?.services?.let { userReservedServiceAdapter.replace(it) }
            Glide.with(requireContext()).load(jobPage.avatar).centerCrop().circleCrop().placeholder(R.drawable.ic_camera_profile).into(binding.avatarImage)
            binding.bottomBar.visibility = View.VISIBLE
            showViewRelatedToState(jobPage.request?.status ?: "accepted", jobPage.request?.time_base ?: false,jobPage)

            //Handle Cancel Button on 2 state 1. accepted 2. paid
            if (jobPage.request?.status == "accepted" || jobPage.request?.status == "paid") {
                binding.arrivalTimeBox.visibility = View.VISIBLE
                binding.arriavalTime.text = jobPage.request.arrival_time?.dateToFormat("HH:mm")
                binding.distance.setText(R.string.cancel)
                binding.distance.setOnClickListener {
                    AlertDialogFactory(requireActivity()).confirmDialog(
                        R.string.cancel,
                        R.string.cancelRequestUserSubTitle,
                        R.string.cancelRequestUserContent,
                        {
                            binding.waitingFlipper.displayedChild = 1
                            viewModel.cancel()
                            it.dismiss()
                        }) {
                        it.dismiss()
                    }.show()
                }
            }
            else {
                binding.distance.visibility = View.INVISIBLE
                binding.arrivalTimeBox.visibility = View.GONE
            }

        }
    }

    private fun refreshRequestStatus () {
        (activity as? UserActivity)?.viewModel?.getLastRequestDetail()
    }

    private fun startTimer (time : Int) {
        countDownTimer?.cancel()
        countDownTimer = null
        countDownTimer = object : CountDownTimer(((time - 1) * 1000).toLong(), 1000) {
            override fun onTick(millisUntilFinished: Long) {
                binding.remainingTime.text = (millisUntilFinished / 1000).toInt().toHourAndMin()
            }
            override fun onFinish() {
                payTimeHasBeenFinished()
            }
        }
        countDownTimer?.start()
    }
    private fun payTimeHasBeenFinished () {
        binding.timerBox.visibility = View.GONE
    }
    private fun showViewRelatedToState (status : String,isTimeBase : Boolean, jobPage : JobberPageModel) {
        binding.timerBox.visibility = View.GONE
        when (status) {
            "accepted", "paid", "arrived" -> {
                if (isTimeBase || status == "paid" || status == "arrived") {
                    binding.bottomBarFlipper.displayedChild =  2
                    binding.callButton.setOnClickListener {
                        val intent = Intent(Intent.ACTION_DIAL, Uri.fromParts("tel", jobPage.phone_number, null))
                        startActivity(intent)
                    }
                    val phoneNumber = jobPage.phone_number?.let { PhoneNumberUtils.formatNumber(it, "CH"); }
                    binding.phoneNumber.text = phoneNumber
                }
                else {
                    binding.bottomBarFlipper.displayedChild = 1
                    binding.total.text = jobPage.request?.total_pay.getFranc()
                    if (jobPage.request?.remaining_time ?: 0 > 1) {
                        binding.timerBox.visibility = View.VISIBLE
                        startTimer(time = jobPage.request?.remaining_time ?: 0)
                    }
                    else {
                        payTimeHasBeenFinished()
                    }
                    binding.titleRemainingTime.text = getString(R.string.reservedJobberFornMin, ((jobPage.request?.user_time_paying ?: 0) / 60))
                    binding.nextAndPayButton.setOnClickListener {
                        if (viewModel.payInfoResultModel == null) viewModel.pay()
                        else presentPaymentSheet()
                    }
                }
            }
            "started" -> {
                binding.bottomBarFlipper.displayedChild =  3
            }
            "finished" -> {
                binding.bottomBarFlipper.displayedChild =  4
                binding.verifyButton.setOnClickListener {
                    if (isTimeBase){
                        findNavController().navigate(JobberPageFragmentDirections.actionJobberPageFragmentToFactorFragment(jobPage.request?.total_time_interval ?: 0, jobPage.request?.services?.firstOrNull()?.price ?: 0f, jobPage.request?.services?.firstOrNull()?.title ?: "", jobPage.request?.total_pay ?: 0f))
                    }
                    else
                        viewModel.verify()
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        countDownTimer?.cancel()
    }
}