package com.jobloyal.user.waiting

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.network.UserApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class UserWaitingViewModel(app: Application) : RxViewModel(app) {

    var waiting = MutableLiveData<Boolean>()

    fun cancel () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<UserApiService>(context = getApplication())
                .cancelJob().subscribeOn(
                    Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccessOrNot(it , {
                        navigate.value = 1
                    }, {
                        waiting.value = false
                        true
                    })
                }, {
                    waiting.value = false
                })
        )
    }
}