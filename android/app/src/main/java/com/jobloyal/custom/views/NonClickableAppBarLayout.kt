package com.jobloyal.custom.views

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import com.google.android.material.appbar.AppBarLayout

class NonClickableAppBarLayout @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : AppBarLayout(context, attrs, defStyleAttr) {
    override fun onTouchEvent(ev: MotionEvent?): Boolean {
        return false
    }
}