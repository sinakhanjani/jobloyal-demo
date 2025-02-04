package com.jobloyal

import android.app.Application
import android.content.Context
import com.jobloyal.login.model.SetRegionRequestModel
import com.jobloyal.network.CommonApiService
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.Const
import com.jobloyal.utility.Const.Companion.getIsJobberApp
import com.jobloyal.utility.RxActivity
import com.jobloyal.utility.RxViewModel
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class MainActivityViewModel(val app : Application) : RxViewModel(app) {

    fun registerRegionToServer (region : String) = Single.create<Boolean> { single ->
        subscribe(
            HttpClient.buildRx<CommonApiService>(context = getApplication())
                .setRegion(if (app.getIsJobberApp() == true) "jobber" else "user", SetRegionRequestModel(region)).subscribeOn(
                    Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccessOrNot(it, {
                        it?.token?.let {updateTokenPreferences(it) }
                        single.onSuccess(true)
                    },{
                        single.onSuccess(false)
                        false
                    })
                    single.onSuccess(true)
                }, {
                    single.onSuccess(false)
                })
        )
    }

    private fun updateTokenPreferences (token : String) {
        app.getSharedPreferences("settings", Context.MODE_PRIVATE)
            .edit()
            .putString("token", token)
            .apply()
        Const.getToken(app, true)
    }

}