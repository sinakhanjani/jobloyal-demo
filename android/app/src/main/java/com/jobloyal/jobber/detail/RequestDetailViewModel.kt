package com.jobloyal.jobber.detail

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.request.AcceptionRequestModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class RequestDetailViewModel(app : Application) : RxViewModel(app) {

    var waiting = MutableLiveData<Boolean>()
    enum class StatusRequest  {
        accepted, paid,started,finished,arrived;
        fun getStepNumber () =
            when (this) {
                accepted,paid -> 0
                arrived -> 1
                started -> 2
                finished -> 3
                else -> 0
            }
    }

    fun getEnumOfStatus (status : String) = StatusRequest.valueOf(status)

    fun arrive () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .arriveJob().subscribeOn(
                    Schedulers.io()
                )
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
    fun start () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .startJob().subscribeOn(
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
    fun finish () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .finishJob().subscribeOn(
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

    fun cancel () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
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