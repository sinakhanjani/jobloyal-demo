package com.jobloyal.jobber.estimate

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.jobloyal.jobber.model.request.AcceptionRequestModel
import com.jobloyal.jobber.model.request.estimated.GetLocationRequestModel
import com.jobloyal.jobber.model.status.GetLocationModel
import com.jobloyal.network.Http.HttpClient
import com.jobloyal.network.JobberApiService
import com.jobloyal.utility.RxViewModel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.BehaviorSubject

class EstimateErivalTimeViewModel(app : Application) : RxViewModel(app) {

    var requestID : String? = null
    var arrivalTime : Int? = null
    var waiting = MutableLiveData<Boolean>()
    var location : BehaviorSubject<GetLocationRequestModel> = BehaviorSubject.create()
    var acceptedIds : List<Int>? = null

    fun getLocationOfRequest () {
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .getLocation(requestID).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    ifSuccess(it) {
                        it?.let { location.onNext(it) }
                    }

                }, {
                })
        )
    }

    fun accept () {
        waiting.value = true
        subscribe(
            HttpClient.buildRx<JobberApiService>(context = getApplication())
                .acceptRequest(AcceptionRequestModel(acceptedIds, arrivalTime, requestID)).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    waiting.value = false
                    ifSuccess(it) {
                        navigate.value = 1
                    }
                }, {
                    waiting.value = false
                })
        )
    }
}