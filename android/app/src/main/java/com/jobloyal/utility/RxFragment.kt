package com.jobloyal.utility

import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.Fragment
import com.jobloyal.R
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import java.util.*


open class RxFragment<T : RxViewModel> : Fragment() {

    open lateinit var viewModel: T
    open val invalidateStatusBarHeight = false
    val subscriptions = CompositeDisposable()

    fun addToDisposableBag(disposable: Disposable?): Disposable? {
        if (disposable != null) subscriptions.add(disposable)
        return disposable
    }

    override fun onStop() {
        super.onStop()
//        subscriptions.dispose() //delete and don't lets to add new to it

    }

    override fun onDestroy() {
        super.onDestroy()

    }

    override fun onDestroyView() {
        super.onDestroyView()
        subscriptions.clear()
    }


    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        initArgs()

        return super.onCreateView(inflater, container, savedInstanceState)
    }


    private fun buildDialog(title: String?, message: String) {
        AlertDialogFactory(requireActivity()).warningDialog(
            title ?: getString(R.string.oops),
            message
        ) {
            it.dismiss()
        }.show()
    }

    open fun initArgs() {

    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        if (this::viewModel.isInitialized) {
            viewModel.error.observe(viewLifecycleOwner) {
                if (it != null) {
                    buildDialog(null, getMessageLocalized(it.code))
                    viewModel.error.value = null
                }
            }
        }
        view.findViewById<View>(R.id.statusbar)?.let {
            if (invalidateStatusBarHeight) {
                it.invalidateHeightForStatusBarAndToolbar()
            }
        }
    }

    private fun getMessageLocalized(code: Int): String {
        val errorString =
        when (code) {
            0 ->   R.string.error_code_0
            401 -> R.string.error_code_401
            403 -> R.string.error_code_403
            404 -> R.string.error_code_404
            500 -> R.string.error_code_500
            101 -> R.string.error_code_101
            102 -> R.string.error_code_102
            103 -> R.string.error_code_103
            104 -> R.string.error_code_104
            105 -> R.string.error_code_105
            106 -> R.string.error_code_106
            107 -> R.string.error_code_107
            108 -> R.string.error_code_108
            109 -> R.string.error_code_109
            110 -> R.string.error_code_110
            111 -> R.string.error_code_111
            112 -> R.string.error_code_112
            113 -> R.string.error_code_113
            114 -> R.string.error_code_114
            115 -> R.string.error_code_115
            116 -> R.string.error_code_116
            117 -> R.string.error_code_117
            118 -> R.string.error_code_118
            119 -> R.string.error_code_119
            120 -> R.string.error_code_120
            121 -> R.string.error_code_121
            122 -> R.string.error_code_122
            123 -> R.string.error_code_123
            124 -> R.string.error_code_124
            125 -> R.string.error_code_125
            126 -> R.string.error_code_126
            127 -> R.string.error_code_127
            128 -> R.string.error_code_128
            else -> R.string.error_code_0
        }
        return getString(errorString)
    }
}