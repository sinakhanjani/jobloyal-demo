package com.jobloyal.user.profile

import android.content.Intent
import android.graphics.Color
import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import android.telephony.PhoneNumberUtils
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.findNavController
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.jobloyal.MainActivity
import com.jobloyal.R
import com.jobloyal.databinding.JobberPageFragmentBinding
import com.jobloyal.databinding.UserProfileFragmentBinding
import com.jobloyal.jobber.adapter.ProfileAdapter
import com.jobloyal.jobber.main.JobberMainFragmentDirections
import com.jobloyal.utility.*

class UserProfileFragment : RxFragment<UserProfileViewModel>() {

    override val invalidateStatusBarHeight: Boolean
        get() = false
    private var _binding: UserProfileFragmentBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(UserProfileViewModel::class.java)
        _binding = UserProfileFragmentBinding.inflate(inflater, container, false)
        activity?.transparentStatusBar(false)
        activity?.updateStatusBarColor(Color.WHITE)

        binding.recyclerView.layoutManager = LinearLayoutManager(requireContext())
        val options = resources.getStringArray(R.array.userProfileOptions).toList()
        binding.recyclerView.adapter = ProfileAdapter(options) {
            val nav = activity?.findNavController(R.id.nav_host_fragment)
            when (it) {
                0 -> {
                    findNavController().navigate(UserProfileFragmentDirections.actionUserProfileFragmentToReservedServicesFragment(true))
                }
                1 -> {
                    findNavController().navigate(UserProfileFragmentDirections.actionUserProfileFragmentToReservedServicesFragment(false))
                }
                2 -> {
                    findNavController().navigate(UserProfileFragmentDirections.actionUserProfileFragmentToUserEditProfileFragment(viewModel.profile.value))
                }
                3 -> { findNavController().navigate(R.id.action_userProfileFragment_to_userMessageFragment)}
                4 -> {nav?.navigate(R.id.termsFragment2)}
                5 -> {nav?.navigate(R.id.aboutUsFragment2)} //about us deleted in this version
                6 -> {
                    AlertDialogFactory(requireActivity())
                        .confirmDialog(R.string.exit, R.string.exitSubTitle, R.string.exitDescription, {
                            viewModel.deleteDevice().subscribe ({
                                Const.resetToken(requireContext())
                                activity?.finish()
                                activity?.startActivity(Intent(requireContext(), MainActivity::class.java))
                            }, {})
                        }) {
                            it.dismiss()
                        }.show()
                }
            }
        }
        binding.backBtn.setOnClickListener { findNavController().popBackStack() }

        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        addToDisposableBag(viewModel.profile.subscribe {
            binding.nameTV.text = "${it.name} ${it.family}"
            it.phone_number?.let { binding.phoneNumberTv.text = PhoneNumberUtils.formatNumber(it, "CH"); }
            if (it.credit ?: 0.0 > 0 ) {
                binding.walletRow.visibility = View.VISIBLE
                binding.creditTV.text = it.credit.getFranc()
            }
        })
        viewModel.getProfile()
    }

}