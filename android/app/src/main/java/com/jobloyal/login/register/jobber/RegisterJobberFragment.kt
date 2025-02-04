package com.jobloyal.login.register.jobber

import android.content.Context
import android.content.Intent
import android.graphics.drawable.Animatable
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import androidx.core.content.ContextCompat
import androidx.core.content.res.getDrawableOrThrow
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.google.android.material.progressindicator.CircularProgressIndicatorSpec
import com.google.android.material.progressindicator.IndeterminateDrawable
import com.google.android.material.textfield.TextInputLayout
import com.jobloyal.R
import com.jobloyal.databinding.RegisterJobberFragmentBinding
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.user.UserActivity
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.px
import com.jobloyal.utility.toast
import com.jobloyal.utility.transparentStatusBar
import java.util.*


class RegisterJobberFragment : RxFragment<RegisterJobberViewModel>() {

    private var _binding: RegisterJobberFragmentBinding? = null
    private val binding get() = _binding!!
    val args by navArgs<RegisterJobberFragmentArgs>()
    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(RegisterJobberViewModel::class.java)
        _binding = RegisterJobberFragmentBinding.inflate(inflater, container, false)
        requireActivity().transparentStatusBar(false)
        viewModel.token = args.token
        viewModelToEditText()
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.nextButton.setWaiting(it)
            binding.nameET.isEnabled = !it
            binding.familyET.isEnabled = !it
            binding.zipCodeET.isEnabled = !it
            binding.idEt.isEnabled = !it
        }
        binding.termAndConditionCheck.setOnClickListener {
            binding.switchButton.toggle(true)
        }
        binding.termAndCondition.setOnClickListener {
            dataToViewModel()
            findNavController().navigate(R.id.termsFragment3)
        }
        binding.nextButton.setOnClickListener {
            dataToViewModel()
            if (viewModel.firstName.isEmpty() || viewModel.lastName.isEmpty() || viewModel.zipCode.isEmpty()) {
                activity?.toast(R.string.error_all_field_should_complete)
            }
            else if (viewModel.identifier?.isEmpty() == true) {
                activity?.toast(R.string.error_id_should_complete)
            }
            else if (!binding.switchButton.isChecked) {
                activity?.toast(R.string.error_accept_terms)
            }
            else {
                viewModel.register()
            }
        }

        viewModel.navigate.observe(viewLifecycleOwner) {
            when (it) {
                RegisterJobberViewModel.NavigateRegisterJobberViewModel.IdIsAvailable.ordinal -> {
                    checkedIconIdBox()
                    loading = false
                }
                RegisterJobberViewModel.NavigateRegisterJobberViewModel.IdAlreadyExist.ordinal -> {
                    setErrorBox()
                    loading = false
                }
                RegisterJobberViewModel.NavigateRegisterJobberViewModel.NextToApp.ordinal -> {
                    val intent = Intent(requireActivity(),JobberActivity::class.java )
                    startActivity(intent)
                    activity?.finish()
                }
            }
        }
        binding.idEt.editText?.addTextChangedListener(
            object : TextWatcher {
                override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {}
                override fun beforeTextChanged(
                    s: CharSequence,
                    start: Int,
                    count: Int,
                    after: Int
                ) {
                }

                private var timer: Timer = Timer()
                private val DELAY: Long = 300
                override fun afterTextChanged(s: Editable) {
                    loadingIdBox()
                    viewModel.disposable?.dispose()
                    timer.cancel()
                    timer = Timer()
                    timer.schedule(
                        object : TimerTask() {
                            override fun run() {
                                activity?.runOnUiThread {
                                    if (binding.idEt.editText?.text.toString().length >= 3) {
                                        viewModel.checkIdentifier(binding.idEt.editText?.text.toString())
                                    } else {
                                        viewModel.identifier = null
                                        loading = false
                                        setErrorBox(true)
                                    }
                                }
                            }
                        },
                        DELAY
                    )
                }
            }
        )

    }
    private fun dataToViewModel () {
        viewModel.firstName = binding.nameET.editText?.text.toString()
        viewModel.lastName =  binding.familyET.editText?.text.toString()
        viewModel.zipCode =   binding.zipCodeET.editText?.text.toString()
    }
    private fun viewModelToEditText () {
        binding.nameET.editText?.setText(viewModel.firstName)
        binding.familyET.editText?.setText(viewModel.lastName)
        binding.zipCodeET.editText?.setText(viewModel.zipCode)
        binding.idEt.editText?.setText(viewModel.identifier)
    }
    var loading = false
    private fun loadingIdBox() {
        if (!loading) {
            binding.idEt.isErrorEnabled = false
            binding.idEt.endIconMode = TextInputLayout.END_ICON_CUSTOM
            val drawable = progressDrawable()
            binding.idEt.endIconDrawable = drawable;
            (drawable as? Animatable)?.start()
            loading = true
        }
    }

    private fun checkedIconIdBox() {
        binding.idEt.isErrorEnabled = false
        binding.idEt.endIconMode = TextInputLayout.END_ICON_CUSTOM
        binding.idEt.setEndIconDrawable(R.drawable.ic_checked_blue)
    }

    private fun setErrorBox(empty: Boolean = false) {
        binding.idEt.endIconMode = TextInputLayout.END_ICON_NONE
        binding.idEt.isErrorEnabled = true
        binding.idEt.error =
            getString(if (empty) R.string.error_code_id_should_not_empty else R.string.error_code_107)
        val regex = "^([_a-zA-Z][_a-zA-Z0-9.]{0,30})".toRegex()
        val isMatched = regex matches binding.idEt.editText?.text.toString()
        if (!empty && !isMatched) {
            binding.idEt.error =
                getString(R.string.error_code_108)
        }
    }

    private fun progressDrawable(): Drawable {
        val value = TypedValue()
        requireActivity()?.theme.resolveAttribute(
            android.R.attr.progressBarStyleSmall,
            value,
            false
        )
        val progressBarStyle = value.data
        val attributes = intArrayOf(android.R.attr.indeterminateDrawable)
        val array = requireContext().obtainStyledAttributes(progressBarStyle, attributes)
        val drawable = array.getDrawableOrThrow(0)
        array.recycle()
        return drawable
    }

    override fun onResume() {
        super.onResume()
        binding.nameET.post {
            binding.nameET.requestFocus()
            val imgr: InputMethodManager =
                requireActivity().getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imgr.toggleSoftInput(
                InputMethodManager.SHOW_FORCED,
                InputMethodManager.HIDE_IMPLICIT_ONLY
            );
            imgr.showSoftInput(binding.nameET, InputMethodManager.SHOW_IMPLICIT)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        requireActivity().transparentStatusBar(true)
    }
}