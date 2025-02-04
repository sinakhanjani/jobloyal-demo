package com.jobloyal.user.raiting

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.bumptech.glide.Glide
import com.jobloyal.R
import com.jobloyal.databinding.UserRateFragmentBinding
import com.jobloyal.databinding.UserWaitingFragmentBinding
import com.jobloyal.user.UserActivity
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.toast

class UserRateFragment : RxFragment<UserRateViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: UserRateFragmentBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(UserRateViewModel::class.java)
        _binding = UserRateFragmentBinding.inflate(inflater, container, false)

        (activity as? UserActivity)?.viewModel?.lastRequest?.value?.data?.let {
            binding.nameTV.text = "${it.jobber?.name} ${it.jobber?.family}"
            binding.idTV.text = it.jobber?.identifier
            Glide.with(requireContext()).load(it.jobber?.avatar).centerCrop().circleCrop().placeholder(R.drawable.ic_camera_profile).into(binding.avatar)
            binding.submitButton.setOnClickListener {
                viewModel.rate = binding.ratebar.rating.toInt()
                viewModel.comment = binding.commentET.text?.toString()
                if (viewModel.rate == 0) {
                    activity?.toast(R.string.rateIsRequire)
                }
                else {
                    binding.loadingFlipper.displayedChild = 1
                    viewModel.submitComment()
                }
            }
        }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.navigate.observe(viewLifecycleOwner) {
            if (it == 1) {
                (activity as? UserActivity)?.viewModel?.getLastRequestDetail()
            }
        }
    }
}