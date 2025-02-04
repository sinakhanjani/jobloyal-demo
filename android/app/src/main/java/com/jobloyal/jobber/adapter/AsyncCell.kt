package com.jobloyal.jobber.adapter

import android.content.Context
import android.view.View
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.widget.FrameLayout
import androidx.asynclayoutinflater.view.AsyncLayoutInflater


open class AsyncCell(context: Context,height: Int) : FrameLayout(context, null, 0, 0) {
    init {
        layoutParams = LayoutParams(MATCH_PARENT, height)
    }

    open val layoutId = -1 // override with your layout Id
    private var isInflated = false
    private val bindingFunctions: MutableList<AsyncCell.() -> Unit> = mutableListOf()

    fun inflate() {
        val aaa = AsyncLayoutInflater(context);
        aaa.inflate(layoutId, this){ view, _, _ ->
            isInflated = true
            addView(createDataBindingView(view))
            bindView()
        }
    }

    private fun bindView() {
        with(bindingFunctions) {
            forEach { it() }
            clear()
        }
    }

    fun bindWhenInflated(bindFunc: AsyncCell.() -> Unit) {
        if (isInflated) {
            bindFunc()
        } else {
            bindingFunctions.add(bindFunc)
        }
    }

    open fun createDataBindingView(view: View): View? = view // override for usage with dataBinding

}