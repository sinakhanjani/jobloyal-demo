package com.jobloyal.custom.views

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import androidx.appcompat.widget.Toolbar


class NotClickableToolbar @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : Toolbar(context, attrs, defStyleAttr) {

    override fun onTouchEvent(ev: MotionEvent?): Boolean {
        return false
    }
}