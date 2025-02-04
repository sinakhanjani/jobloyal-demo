package com.jobloyal.login.phonenumber

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.drawable.InsetDrawable
import android.os.Build
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import androidx.annotation.MenuRes
import androidx.appcompat.view.menu.MenuBuilder
import androidx.appcompat.widget.PopupMenu
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.jobloyal.R
import com.jobloyal.custom.views.textwatcher.MaskedEditTextWatcher
import com.jobloyal.custom.views.textwatcher.MaskedEditTextWatcherDelegate
import com.jobloyal.databinding.PhoneNumberFragmentBinding
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.px
import com.jobloyal.utility.transparentStatusBar


class PhoneNumberFragment : RxFragment<PhoneNumberViewModel>() {

    companion object {
        fun newInstance() = PhoneNumberFragment()
    }

    override val invalidateStatusBarHeight: Boolean
        get() = false

    private var _binding: PhoneNumberFragmentBinding? = null
    private val binding get() = _binding!!
    val args: PhoneNumberFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(PhoneNumberViewModel::class.java)
        _binding = PhoneNumberFragmentBinding.inflate(inflater, container, false)
        activity?.transparentStatusBar(false)
        binding.nextButton.isEnabled = false

        binding.countryCodeDD.setOnClickListener {
            showMenu(it, R.menu.countries)
        }

        val simpleListener = MaskedEditTextWatcher(binding.phoneNumber.editText,
            MaskedEditTextWatcherDelegate {
                when (binding.codeTV.text.toString()) {
                    "+41" -> {
                        return@MaskedEditTextWatcherDelegate "(##) ### ####"
                    }
                    "+33" -> {
                        return@MaskedEditTextWatcherDelegate "(##) ### ####"
                    }
                    else -> null
                }
            })
        binding.phoneNumber.editText?.addTextChangedListener(simpleListener)


        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.phoneNumber.editText?.isEnabled = !it
            binding.nextButton.setWaiting(it)
        }
        viewModel.navigate.observe(viewLifecycleOwner) {
            if (it == 1) {
                viewModel.navigate.value = 2
                findNavController().navigate(
                    PhoneNumberFragmentDirections.actionPhoneNumberFragmentToLoginVerificationFragment(
                        args.isJobberApp,
                        viewModel.phoneNumber
                    )
                )
                viewModel.waiting.value = false
            }
        }
        binding.nextButton.setOnClickListener {
            viewModel.phoneNumber = binding.codeTV.text.toString() + " " + binding.phoneNumber.editText?.text.toString()
            viewModel.sendOTP()
        }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.phoneNumber.editText?.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
            override fun afterTextChanged(p0: Editable?) {
                binding.nextButton.isEnabled = p0?.toString()?.length ?: 0 >= "(##) ### ####".length
            }
        })
    }

    override fun onDestroyView() {
        super.onDestroyView()
        activity?.transparentStatusBar(true)
    }
    override fun onResume() {
        super.onResume()
        binding.phoneNumber.post {
            binding.phoneNumber.requestFocus()
            val imgr: InputMethodManager =
                requireActivity().getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imgr.toggleSoftInput(
                InputMethodManager.SHOW_FORCED,
                InputMethodManager.HIDE_IMPLICIT_ONLY
            );
            imgr.showSoftInput(binding.phoneNumber, InputMethodManager.SHOW_IMPLICIT)
        }
    }
    @SuppressLint("RestrictedApi")
    private fun showMenu(v: View, @MenuRes menuRes: Int) {
        val popup = PopupMenu(requireContext(), v)
        popup.menuInflater.inflate(menuRes, popup.menu)

        if (popup.menu is MenuBuilder) {
            val menuBuilder = popup.menu as MenuBuilder
            menuBuilder.setOptionalIconsVisible(true)
            for (item in menuBuilder.visibleItems) {
                val iconMarginPx = 10.px
                if (item.icon != null) {
                    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP) {
                        item.icon = InsetDrawable(item.icon, iconMarginPx, 0, iconMarginPx, 0)
                    } else {
                        item.icon =
                            object : InsetDrawable(item.icon, iconMarginPx, 0, iconMarginPx, 0) {
                                override fun getIntrinsicWidth(): Int {
                                    return intrinsicHeight + iconMarginPx + iconMarginPx
                                }
                            }
                    }
                }
            }
        }
        popup.setOnMenuItemClickListener { menuItem: MenuItem ->
            if (menuItem.itemId == R.id.switzerland) {
                binding.codeTV.text = "+41"
                binding.flagIcon.setImageResource(R.drawable.ic_switzerland_flag)
            }
            else if (menuItem.itemId == R.id.france) {
                binding.codeTV.text = "+33"
                binding.flagIcon.setImageResource(R.drawable.ic_flag_france)
            }
            false
        }
        popup.show()
    }

}