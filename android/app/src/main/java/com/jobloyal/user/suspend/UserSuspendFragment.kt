package com.jobloyal.user.suspend

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.activity.OnBackPressedCallback
import com.jobloyal.R
import com.jobloyal.databinding.UserRateFragmentBinding
import com.jobloyal.databinding.UserSuspendFragmentBinding
import com.jobloyal.jobber.suspend.SuspendViewModel
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.dateToFormat

class UserSuspendFragment : RxFragment<SuspendViewModel>() {


    private var _binding: UserSuspendFragmentBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(SuspendViewModel::class.java)
        _binding = UserSuspendFragmentBinding.inflate(inflater, container, false)

        activity?.onBackPressedDispatcher?.addCallback(object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {

            }
        })
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        addToDisposableBag(viewModel.detail.subscribe {
            if (it.finite == true) {
                if (it.reason != null)
                    binding.descriptionTV.text = getString(R.string.yourAccountFinitelySuspended,it.expired?.dateToFormat("HH:mm dd/MM/yy") ,it.reason)
                else
                    binding.descriptionTV.text = getString(R.string.yourAccountFinitelySuspendedWithoutReason,it.expired?.dateToFormat("HH:mm dd/MM/yy"))
            }
            else {
                if (it.reason != null)
                    binding.descriptionTV.text = getString(R.string.yourAccountInfinitelySuspended ,it.reason)
                else
                    binding.descriptionTV.text = getString(R.string.yourAccountInfinitelySuspendedWithoutReason)
            }
        })
        viewModel.getDetail()
    }

}