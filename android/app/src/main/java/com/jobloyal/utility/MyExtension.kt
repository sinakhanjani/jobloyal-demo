package com.jobloyal.utility


import android.app.Activity
import android.content.Context
import android.content.res.Resources
import android.os.Build
import android.util.DisplayMetrics
import android.util.Log
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.view.animation.AlphaAnimation
import android.view.animation.Animation
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.core.content.res.ResourcesCompat
import androidx.core.widget.NestedScrollView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.play.core.internal.t
import com.jobloyal.R
import java.text.SimpleDateFormat
import java.util.*


val Int.dp: Int
    get() = (this / Resources.getSystem().displayMetrics.density).toInt()
val Int.px: Int
    get() = (this * Resources.getSystem().displayMetrics.density).toInt()

fun Activity.statusBarIconDark(dark: Boolean) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        if (dark) {
            val view = window.decorView
            view.systemUiVisibility = view.systemUiVisibility or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
        } else {
            val view = window.decorView
            view.systemUiVisibility = view.systemUiVisibility and View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR.inv()
        }
    }
}
fun Double?.getMeter () : String {
    return if (this == null) "0 M"
    else {
        when {
            (this/1000).toInt() <= 0 -> "${String.format("%.2f", this)} M"
            (this/1000).toInt() <= 20 -> "${String.format("%.2f", this / 1000)} KM"
            else -> "${(this/1000).toInt()} KM"
        }
    }
}

fun Double?.getFranc () = String.format("%.2f", this ?: 0.0)
fun Float?.getFranc () = String.format("%.2f", this ?: 0.0)
fun Int.toHourAndMin () : String {
    val hours: Int = this / 60 //since both are ints, you get an int
    val minutes: Int = this % 60
    return String.format("%d:%02d", hours, minutes)
}
fun Activity.updateStatusBarColor(color: Int) {
        val window: Window = window
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
        window.statusBarColor = color
}
fun View.startAlphaAnimation(
    from: Float,
    to: Float,
    startOffset: Long = 0,
    duration: Long = 500,
    animationEndElementListener: (() -> Unit)? = null
){
    val animation1 = AlphaAnimation(from, to)
    animation1.duration = duration
    animation1.startOffset = startOffset
    animation1.fillAfter = true
    if (animationEndElementListener != null) {
        animation1.setAnimationListener(object : Animation.AnimationListener {
            override fun onAnimationRepeat(p0: Animation?) {

            }

            override fun onAnimationEnd(p0: Animation?) {
                animationEndElementListener()
            }

            override fun onAnimationStart(p0: Animation?) {
            }

        })
    }
    this.startAnimation(animation1)
}
fun Activity.getWidowsPhoneSize () : DisplayMetrics {
        val outMetrics = DisplayMetrics()

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            val display = this.display
            display?.getRealMetrics(outMetrics)
        } else {
            val display = this.windowManager.defaultDisplay
            display.getMetrics(outMetrics)
        }
        return outMetrics
}
fun View.invalidateHeightForStatusBarAndToolbar () {
    val params = this.layoutParams
    params?.let { params->
        params.height = getStatusBarHeight(this.resources)
        this.layoutParams = params
    }
}
fun View.invalidateHeightForNavBar () {
    val params = this.layoutParams
    params?.let { params->

        params.height = if (hasNavigationBar(this.resources)) getNavBarHeight(this.resources) else 0
        this.layoutParams = params
    }
}
fun View.invalidateToZero () {
    val params = this.layoutParams
    params?.let { params->
        params.height = 0
        this.layoutParams = params
    }
}

fun getStatusBarHeight(resource: Resources): Int {
    var result : Double = 0.0
    val resourceId = resource.getIdentifier("status_bar_height", "dimen", "android")

    result = if (resourceId > 0)
        resource.getDimensionPixelSize(resourceId).toDouble()
    else
        Math.ceil(if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) (24 * resource.getDisplayMetrics().density).toDouble() else (25 * resource.getDisplayMetrics().density).toDouble())
    Log.i("STATUS", "STATUS HEOGHT + $result")
    return result.toInt()
}
fun getNavBarHeight(resources: Resources): Int {
    val resourceId =
            resources.getIdentifier("navigation_bar_height", "dimen", "android")
    return if (resourceId > 0) {
        resources.getDimensionPixelSize(resourceId)
    } else 0
}
fun hasNavigationBar(resources: Resources): Boolean {
    val id = resources.getIdentifier("config_showNavigationBar", "bool", "android")
    return id > 0 && resources.getBoolean(id)
}
fun String.separate3Digits() : String = String.format("%,d", this.toInt())
fun Int.separate3Digits() =  String.format("%,d", this)
fun Long.secondToString () : String {
    val hours = this / 3600;
    val minutes = (this % 3600) / 60;
    val seconds = this % 60;
    return if (hours > 0) String.format("%02d:%02d:%02d", hours, minutes, seconds) else String.format(
        "%02d:%02d",
        minutes,
        seconds
    )
}
fun Context.toast(text: Int, time: Int = Toast.LENGTH_SHORT) {
    val toast = Toast.makeText(this, text, time)
    val toastLayout = toast.getView() as? LinearLayout
    if (toastLayout != null) {
        val toastTV = toastLayout.getChildAt(0) as TextView
        toastTV.typeface = ResourcesCompat.getFont(this, R.font.lato_regular)
    }
    toast.show()
}

fun Activity.transparentStatusBar(enableTransparent: Boolean) {
    val w = this.window
    if (enableTransparent) {
        window.addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
        if (this.findViewById<View>(R.id.simpleNavBar) != null) {
            this.findViewById<View>(R.id.simpleNavBar).invalidateHeightForNavBar()
        }
    }
    else {
        w.clearFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)
        w.clearFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)
        if (this.findViewById<View>(R.id.simpleNavBar) != null) {
            this.findViewById<View>(R.id.simpleNavBar).invalidateToZero()
        }
    }
}

fun Int.twoDigit() : String{
    return if (this < 10) "0$this" else this.toString()
}

fun String.toDate(
    dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timeZone: TimeZone = TimeZone.getTimeZone(
        "UTC"
    )
): Date? {
    val parser = SimpleDateFormat(dateFormat, Locale.getDefault())
    parser.timeZone = timeZone
    return parser.parse(this)
}

fun Date.formatTo(dateFormat: String, timeZone: TimeZone = TimeZone.getDefault()): String {
    val formatter = SimpleDateFormat(dateFormat, Locale.getDefault())
    formatter.timeZone = timeZone
    return formatter.format(this)
}

fun String.dateToFormat(format: String): String? {
    val parser = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.getDefault())
    parser.timeZone = TimeZone.getTimeZone("UTC")
    val date = parser.parse(this)
    val formatter = SimpleDateFormat(format, Locale.getDefault())
    formatter.timeZone = TimeZone.getDefault()
    return formatter.format(date)
}

fun NestedScrollView.setEndlessScroll(
    recyclerView: RecyclerView,
    shouldEndLessEnable: () -> Boolean,
    complete: (NestedScrollView) -> Unit
) {
    this.setOnScrollChangeListener { v: NestedScrollView, scrollX: Int, scrollY: Int, oldScrollX: Int, oldScrollY: Int ->
        if (shouldEndLessEnable()) {
            if ((scrollY >= (v.getChildAt(v.childCount - 1).measuredHeight - v.measuredHeight)) &&
                    scrollY > oldScrollY
            ) {
                val visibleItemCount =
                        (recyclerView.layoutManager as? LinearLayoutManager)?.childCount ?: 0
                val totalItemCount = recyclerView.layoutManager?.itemCount ?: 0
                val firstVisibleItem =
                        (recyclerView.layoutManager as? LinearLayoutManager)?.findFirstVisibleItemPosition()
                                ?: 0
                if ((visibleItemCount + firstVisibleItem) >= totalItemCount) {
                    if (this.tag != "Loading") {
                        this.tag = "Loading"
                        complete(this)
                    }

                }
            }
        }
    }
}

fun NestedScrollView.finishEndless () {
    this.tag = "Loaded"
}

fun RecyclerView.finishEndless () {
    this.tag = "Loaded"
}