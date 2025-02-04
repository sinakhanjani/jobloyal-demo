package com.jobloyal.jobber.addservice.newservice

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.AutoCompleteTextView
import androidx.appcompat.widget.AppCompatAutoCompleteTextView
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.jobloyal.R
import com.jobloyal.databinding.NewServiceFragmentBinding
import com.jobloyal.jobber.JobberActivity
import com.jobloyal.jobber.model.addservice.Unit
import com.jobloyal.utility.HRArrayAdapter
import com.jobloyal.utility.RxFragment
import com.jobloyal.utility.toast
import com.jobloyal.utility.transparentStatusBar
import java.util.*

class NewServiceFragment : RxFragment<NewServiceViewModel>() {

    private var _binding: NewServiceFragmentBinding? = null
    private val binding get() = _binding!!
    private val args : NewServiceFragmentArgs by navArgs()


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        viewModel = ViewModelProvider(this).get(NewServiceViewModel::class.java)
        _binding = NewServiceFragmentBinding.inflate(inflater, container, false)
        viewModel.service = args.selectedService
        viewModel.selectedUnit = args.selectedService?.unit
        viewModel.isNewJob = args.isNewJob
        viewModel.isNewJobReal = args.isNewJob
        viewModel.jobId = args.jobId

        binding.backBtn.setOnClickListener {
            findNavController().popBackStack()
        }
        return binding.root
    }

    override fun onResume() {
        super.onResume()
        activity?.transparentStatusBar(false)
    }

    override fun onStop() {
        super.onStop()
        activity?.transparentStatusBar(true)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val unitTypeList = listOf(getString(R.string.timebaseUnitType), getString(R.string.numeric))

        binding.addBtn.setOnClickListener {

            if (viewModel.unitType == NewServiceViewModel.UnitType.NUMERIC) {
                if (binding.unitTitle.editText?.text?.toString()?.trim()?.isNotEmpty() == true) {
                    if (!binding.unitTitle.editText?.text?.toString()?.trim()
                            .equals(viewModel.selectedUnit?.title?.trim(), true)
                    ) {
                        viewModel.selectedUnit = viewModel.units.value?.firstOrNull {
                            it.title.equals(
                                binding.unitTitle.editText?.text?.toString()?.trim(), false
                            )
                        }
                        if (viewModel.selectedUnit == null) {
                            viewModel.selectedUnit = Unit(
                                title = binding.unitTitle.editText?.text?.toString()?.trim(),
                                id = null
                            )
                        }
                    }
                }
                else {
                    activity?.toast(R.string.selectUnit)
                    return@setOnClickListener
                }
            }
            else if (viewModel.unitType == NewServiceViewModel.UnitType.TIME_BASE) {
                viewModel.selectedUnit = null
            }
            else {
                activity?.toast(R.string.selectUnitType)
                return@setOnClickListener
            }
            if ((binding.price.editText?.text.toString()?.toFloatOrNull() ?: 0f) > 0f) {
                viewModel.price = binding.price.editText?.text.toString().toFloat()
            }
            else {
                activity?.toast(R.string.typePriceGreaterThanZero)
                return@setOnClickListener
            }
            if (viewModel.price > 0 && ((viewModel.unitType == NewServiceViewModel.UnitType.NUMERIC && viewModel.selectedUnit != null) || (viewModel.unitType == NewServiceViewModel.UnitType.TIME_BASE && viewModel.selectedUnit == null))) {
                viewModel.save()
            }
            else {
                activity?.toast(R.string.pleaseComplete)
            }
        }

        viewModel.waiting.observe(viewLifecycleOwner) {
            binding.addBtn.setWaiting(it)
        }

        addToDisposableBag(viewModel.units.subscribe {
            val adapter1 = HRArrayAdapter<String>(
                requireContext(),
                R.layout.country_code_item,
                it.map { it.title })
            (binding.unitTitle.editText as? AppCompatAutoCompleteTextView)?.setAdapter(adapter1)
            (binding.unitTitle.editText as? AppCompatAutoCompleteTextView)?.threshold = 1;
        })

        (binding.unitTitle.editText as? AppCompatAutoCompleteTextView)?.setOnItemClickListener { adapterView, view, i, l ->
            val item: String = adapterView.getItemAtPosition(i).toString()
            binding.price.editText?.requestFocus()
            viewModel.selectedUnit = viewModel.units.value?.firstOrNull { it.title.equals(item, false) }
        }

        val adapter = ArrayAdapter(requireContext(), R.layout.country_code_item, unitTypeList)
        (binding.unitTypeEt.editText as? AutoCompleteTextView)?.setAdapter(adapter)
        (binding.unitTypeEt.editText as? AutoCompleteTextView)?.setOnItemClickListener { adapterView, view, i, l ->
            viewModel.unitType = if(i == 0) NewServiceViewModel.UnitType.TIME_BASE else NewServiceViewModel.UnitType.NUMERIC
            switchViews(i == 0)
        }

        binding.serviceTitle.text = args.selectedService?.title?.capitalize()
        if (args.selectedService?.id!= null) {
            if (args.selectedService?.unit != null) {
                viewModel.unitType = NewServiceViewModel.UnitType.NUMERIC
                (binding.unitTypeEt.editText as? AutoCompleteTextView)?.setText(unitTypeList[1])
                switchViews(false)
            }
        }
        viewModel.getAllUnits()

        viewModel.navigate.observe(viewLifecycleOwner) {
            when (it) {
                1 -> {
                    if ((activity as? JobberActivity)?.viewModel?.state?.startsWith("add_job") != true)
                    (activity as? JobberActivity)?.viewModel?.state = if (viewModel.isNewJobReal) "add_job|${viewModel.jobId}" else "add_service|${viewModel.jobId}";
                    findNavController().popBackStack(R.id.jobPageFragment, false)
                }
            }
        }
    }

    private fun switchViews(toTimeBaseMode: Boolean) {
        if(toTimeBaseMode) {
            binding.unitTitle.isEnabled = false
            binding.unitTitle.editText?.setText(R.string.hour)
        }
        else {
            binding.unitTitle.isEnabled = true
            binding.unitTitle.editText?.setText("")
            binding.unitTitle.editText?.setText(viewModel.selectedUnit?.title)
        }
    }

}