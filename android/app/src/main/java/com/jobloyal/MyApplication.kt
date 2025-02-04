package com.jobloyal

import android.app.Activity
import android.app.Application
import com.jobloyal.utility.Const.Companion.getToken
import com.stripe.android.PaymentConfiguration


class MyApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        getToken(this, true)
        PaymentConfiguration.init(
            applicationContext,
            "pk_live_51IMohRJeuajFZKTVB2RuslwExTdoXHhFIoeRpodHY3xomsJkC8MDxin6tIUkFnj4vPpEcEcAPXY6NDgs75lUPHwY00COGmm5qn"
        )
    }

    private var mCurrentActivity: Activity? = null
    fun getCurrentActivity(): Activity? {
        return mCurrentActivity
    }

    fun setCurrentActivity(mCurrentActivity: Activity?) {
        this.mCurrentActivity = mCurrentActivity
    }
}