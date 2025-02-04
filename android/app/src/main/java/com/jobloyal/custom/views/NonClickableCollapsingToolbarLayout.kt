package com.jobloyal.custom.views

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import com.google.android.material.appbar.CollapsingToolbarLayout

class NonClickableCollapsingToolbarLayout @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : CollapsingToolbarLayout(context, attrs, defStyleAttr) {
    override fun onTouchEvent(ev: MotionEvent?): Boolean {
        return false
    }
}